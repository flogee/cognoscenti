package org.socialbiz.cog;

import java.io.File;

import com.purplehillsbooks.json.JSONArray;
import com.purplehillsbooks.json.JSONObject;

public class UserCache {
    JSONObject cacheObj;
    String userKey;
    File userCacheFile;

    UserCache(Cognoscenti cog, String _userKey) throws Exception {
        userKey = _userKey;
        File userFolder = cog.getConfig().getUserFolderOrFail();
        userCacheFile = new File(userFolder, userKey+".user.json");
        if (userCacheFile.exists()) {
            cacheObj = JSONObject.readFromFile(userCacheFile);
        }
        else {
            cacheObj = new JSONObject();
            save();
        }
    }

    public void save() throws Exception {
        cacheObj.writeToFile(userCacheFile);
    }

    // operation get task list.
    public void refreshCache(Cognoscenti cog) throws Exception {

        NGPageIndex.assertNoLocksOnThread();
        long nowTime= System.currentTimeMillis();

        JSONArray actionItemList = new JSONArray();
        JSONArray proposalList = new JSONArray();
        JSONArray openRounds = new JSONArray();
        JSONArray futureMeetings = new JSONArray();

        UserProfile up = UserManager.getUserProfileByKey(userKey);

        for (NGPageIndex ngpi : cog.getAllContainers()) {
            if (!ngpi.isProject() || ngpi.isDeleted) {
                continue;
            }
            NGPage aPage = ngpi.getWorkspace();
            if (aPage.isDeleted() || aPage.isFrozen()) {
                continue;
            }
            NGBook site = aPage.getSite();
            if (site.isDeleted() || site.isMoved() || site.isFrozen()) {
                //ignore any workspaces in deleted, frozen, or moved sites.
                continue;
            }
            
            for (GoalRecord gr : aPage.getAllGoals()) {

                if (gr.isPassive()) {
                    //ignore tasks that are from other servers.  They will be identified and tracked on
                    //those other servers
                    continue;
                }

                if (!gr.isAssignee(up)) {
                    continue;
                }

                actionItemList.put(gr.getJSON4Goal(aPage));
            }
            for (TopicRecord aNote : aPage.getAllNotes()) {
                String address = "noteZoom"+aNote.getId()+".htm";
                for (CommentRecord cr : aNote.getComments()) {
                    addPollIfNoResponse(proposalList, openRounds, cr, up, aPage, aNote.getTargetRole(), address, nowTime);
                }
            }
            for (MeetingRecord meet : aPage.getMeetings()) {

                if (meet.isBacklogContainer()) {
                    //don't ever get anything from the backlog container
                    continue;
                }

                String address = "meetingFull.htm?id="+meet.getId();
                for (AgendaItem ai : meet.getSortedAgendaItems()) {
                    for (CommentRecord cr : ai.getComments()) {
                        addPollIfNoResponse(proposalList, openRounds, cr, up, aPage, meet.getTargetRole(), address, nowTime);
                    }
                }

                //if the meeting is still planned to be run
                if (meet.getState() == MeetingRecord.MEETING_STATE_PLANNING 
                        || meet.getState() == MeetingRecord.MEETING_STATE_RUNNING) {
                    //now determine if the user is asked to attend this meeting
                    NGRole targetRole = aPage.getRole(meet.getTargetRole());
                    if (targetRole!=null && targetRole.isPlayer(up)) {
                        addMeetingToList(futureMeetings, meet, aPage, address);
                    }
                }
            }

            // clean out any outstanding locks in every loop
            NGPageIndex.clearLocksHeldByThisThread();
       }

        cacheObj.put("actionItems", actionItemList);
        cacheObj.put("proposals", proposalList);
        cacheObj.put("openRounds", openRounds);
        cacheObj.put("futureMeetings", futureMeetings);
    }

    private void addPollIfNoResponse(JSONArray proposalList, JSONArray openRounds, CommentRecord cr,
            UserProfile up, NGPage aPage, String targetRoleName, String address, long nowTime) throws Exception {

        //Draft comments/proposals/etc should not ever create an alert for notification
        //Closed ones should not either.  The only state we are worried about is OPEN
        if (cr.getState()==CommentRecord.COMMENT_STATE_OPEN) {
            if (up.equals(cr.getUser())) {
                //first ... is this the owner, and if overdue let them know
                //If user created this round, then remember that ... because it is still open or draft
                addRecordToList(openRounds, cr,  aPage, address);
            }


            //second .. see if there is a response needed.
            NGRole targetRole = aPage.getRole(targetRoleName);
            if (targetRole!=null && targetRole.isPlayer(up)) {
                ResponseRecord rr = cr.getResponse(up);
                if (rr==null) {
                    //add proposal info if there is no response from this user
                    //seems a bit overkill to have everything, but then,
                    //everything is there for displaying a list...
                    addRecordToList(proposalList, cr,  aPage, address);
                }
            }
        }

        //now check to see if there are any draft comments hanging around.
        else if (cr.getState()==CommentRecord.COMMENT_STATE_DRAFT) {
            if (up.equals(cr.getUser())) {
                addRecordToList(openRounds, cr,  aPage, address);
            }
        }
    }

    private void addRecordToList(JSONArray list, CommentRecord cr, NGPage aPage, String address) throws Exception {
        JSONObject jo = cr.getJSON();
        String prop = cr.getContent();
        if (prop.length()>100) {
            prop = prop.substring(0,100);
        }
        jo.put("content", prop);
        jo.put("workspaceKey", aPage.getKey());
        jo.put("workspaceName", aPage.getFullName());
        NGBook site = aPage.getSite();
        jo.put("siteKey", site.getKey());
        jo.put("siteName", site.getFullName());
        jo.put("address", address+"#cmt"+cr.getTime());
        list.put(jo);
    }


    private void addMeetingToList(JSONArray list, MeetingRecord meet, NGPage aPage, String address) throws Exception {
        JSONObject jo = meet.getMinimalJSON();
        jo.put("workspaceKey", aPage.getKey());
        jo.put("workspaceName", aPage.getFullName());
        NGBook site = aPage.getSite();
        jo.put("siteKey", site.getKey());
        jo.put("siteName", site.getFullName());
        jo.put("address", address);
        list.put(jo);
    }


    public JSONArray getActionItems() throws Exception {
        //TODO: somehow this can be in a state of not being initialized.
        //this test prevents a problem, but still wonder why it exists on new users
        if (cacheObj.has("actionItems")) {
            return cacheObj.getJSONArray("actionItems");
        }
        return new JSONArray();
    }
    public JSONArray getProposals() throws Exception {
        //TODO: somehow this can be in a state of not being initialized.
        //this test prevents a problem, but still wonder why it exists on new users
        if (cacheObj.has("proposals")) {
            return cacheObj.getJSONArray("proposals");
        }
        return new JSONArray();
    }

    /**
     * Get a list of the comments (proposals and rounds) that still open
     * but not yet closed, whether overdue or not.
     */
    public JSONArray getOpenRounds() throws Exception {
        if (cacheObj.has("openRounds")) {
            return cacheObj.getJSONArray("openRounds");
        }
        return new JSONArray();
    }


    /**
     * Get a list of the meetings you are assigned to.
     */
    public JSONArray getFutureMeetings() throws Exception {
        if (cacheObj.has("futureMeetings")) {
            return cacheObj.getJSONArray("futureMeetings");
        }
        return new JSONArray();
    }

    public JSONObject getAsJSON() {
        return cacheObj;
    }
    
    public String genEmailAddressAttempt(String email) throws Exception {
        JSONArray allAttempts = cacheObj.requireJSONArray("emailAddAttempts");
        String token = IdGenerator.generateDoubleKey();
        JSONObject newAttempt = new JSONObject();
        newAttempt.put("email", email);
        newAttempt.put("timestamp", System.currentTimeMillis());
        newAttempt.put("token", token);
        allAttempts.put(newAttempt);
        save();
        return token;
    }

    public boolean verifyEmailAddressAttempt(UserProfile user, String token) throws Exception {
        JSONArray allAttempts = cacheObj.requireJSONArray("emailAddAttempts");
        JSONArray remainingAttempts = new JSONArray();
        boolean foundIt = false;
        long timeLimit = System.currentTimeMillis() - (7L * 24 * 60 * 60 * 1000);
        for (int i=0; i<allAttempts.length(); i++) {
            JSONObject oneAttempt = allAttempts.getJSONObject(i);
            //eliminate timed out attempts
            if (oneAttempt.getLong("timestamp")>timeLimit) {
                remainingAttempts.put(oneAttempt);
                if (token.equals(oneAttempt.getString("token"))) {
                    foundIt = true;
                    String email = oneAttempt.getString("email");
                    user.addId(email);
                    UserManager.writeUserProfilesToFile();
                }
            }
        }
        cacheObj.put("emailAddAttempts", remainingAttempts);
        save();
        return foundIt;
    }
    
}
