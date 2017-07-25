<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="include.jsp"
%><%

    ar.assertLoggedIn("Must be logged in to edit roles");

    //set 'forceTemplateRefresh' in config file to 'true' to get this
    String templateCacheDefeater = "";
    if ("true".equals(ar.getSystemProperty("forceTemplateRefresh"))) {
        templateCacheDefeater = "?t="+System.currentTimeMillis();
    }
    
    String pageId      = ar.reqParam("pageId");
    String siteId      = ar.reqParam("siteId");
    String roleName    = ar.reqParam("role");
    
    //page must work for both workspaces and for sites
    NGContainer ngc = ar.getCogInstance().getWorkspaceOrSiteOrFail(siteId, pageId);
    ar.setPageAccessLevels(ngc);
    UserProfile uProf = ar.getUserProfile();

    CustomRole theRole = ngc.getRole(roleName);
    JSONObject role = theRole.getJSONDetail();



%>

<script type="text/javascript">

var app = angular.module('myApp', ['ui.bootstrap','ngTagsInput','ui.bootstrap.datetimepicker']);
app.controller('myCtrl', function($scope, $http, $modal, AllPeople) {
    $scope.role = <%role.write(out,2,4);%>;
    $scope.showInput = false;

    window.setMainPageTitle("Define Role: "+$scope.role.name);
    $scope.showInput = false;
    $scope.showError = false;
    $scope.errorMsg = "";
    $scope.errorTrace = "";
    $scope.showTrace = false;
    $scope.reportError = function(serverErr) {
        errorPanelHandler($scope, serverErr);
    };
    
    $scope.goNominate = function(aterm) {
        window.location = "roleNomination.htm?role="+$scope.role.name+"&term="+aterm.key;
    }
    $scope.deleteResponsibility = function(resp) {
        if (confirm("Are you sure you want to delete this responsibility?")) {
            resp["_DELETE_ME_"] = true;
            $scope.updateResponsibility(resp);
        }
    }
    $scope.deleteTerm = function(term) {
        if (confirm("Are you sure you want to delete term?")) {
            term["_DELETE_ME_"] = true;
            $scope.updateTerm(term);
        }
    }
    $scope.updateResponsibility = function(resp) {
        var roleObj = {};
        roleObj.name = $scope.role.name;
        roleObj.responsibilities = [];
        roleObj.responsibilities.push(resp);
        $scope.updateRole(roleObj);
    }
    $scope.updateTerm = function(term) {
        var roleObj = {};
        roleObj.name = $scope.role.name;
        roleObj.currentTerm = $scope.role.currentTerm;
        roleObj.terms = [];
        roleObj.terms.push(term);
        $scope.updateRole(roleObj);
    }
    $scope.updateRole = function(role) {
        var key = role.name;
        var postURL = "roleUpdate.json?op=Update";
        var postdata = angular.toJson(role);
        $scope.showError=false;
        $http.post(postURL ,postdata)
        .success( function(data) {
            $scope.role = data;
        })
        .error( function(data, status, headers, config) {
            $scope.reportError(data);
        });
    };
    $scope.selectCurrentTerm = function(term) {
        $scope.role.currentTerm = term.key;
    }
    
    $scope.getDays = function(term) {
        if (term.termStart<100000) {
            return 0;
        }
        if (term.termEnd<100000) {
            return 0;
        }
        var diff = Math.floor((term.termEnd - term.termStart)/(1000*60*60*24));
        return diff;
    }
    
    $scope.termColor = function(aterm) {
        if ($scope.role.currentTerm == aterm.key) {
            return {"background-color": "lightyellow"};
        }
        else {
            return {"background-color": "white"};
        }
    }

    $scope.openResponsibilityModal = function (resp) {
        var isNew = false;
        if (!resp) {   
            resp = {};
            isNew = true;
        }
        var modalInstance = $modal.open({
            animation: false,
            templateUrl: '<%=ar.retPath%>templates/Responsibility.html<%=templateCacheDefeater%>',
            controller: 'Responsibility',
            size: 'lg',
            backdrop: "static",
            resolve: {
                responsibility: function () {
                    return JSON.parse(JSON.stringify(resp));
                },
                isNew: function() {return isNew;},
                parentScope: function() { return $scope; }
            }
        });

        modalInstance.result.then(function (message) {
            //what to do when closing the role modal?
        }, function () {
            //cancel action - nothing really to do
        });
    };
    
    $scope.openTermModal = function (term) {
        var isNew = false;
        if (!term) {   
            term = {};
            isNew = true;
        }
        var modalInstance = $modal.open({
            animation: false,
            templateUrl: '<%=ar.retPath%>templates/TermModal.html<%=templateCacheDefeater%>',
            controller: 'TermModal',
            size: 'lg',
            backdrop: "static",
            resolve: {
                term: function () {
                    return JSON.parse(JSON.stringify(term));
                },
                isNew: function() {return isNew;},
                parentScope: function() { return $scope; }
            }
        });

        modalInstance.result.then(function (message) {
            //what to do when closing the role modal?
        }, function () {
            //cancel action - nothing really to do
        });
        
    };
});

</script>
<script src="../../../jscript/AllPeople.js"></script>

<div ng-app="myApp" ng-controller="myCtrl">

<%@include file="ErrorPanel.jsp"%>

    
    <div class="row">
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label for="synopsis">Description:</label>
                <span class="fa fa-question-circle helpIcon" ng-click="descHelp=!descHelp"></span>
                <textarea ng-model="role.description" class="form-control" placeholder="Enter description"></textarea>
            </div>
            <div class="guideVocal" ng-show="descHelp" ng-click="descHelp=false">
                The description is something for everyone to see to give a basic understanding of 
                what the role are expected to do.  The first place that people will go
                when they want to know more about a role is the description.  You should try to be
                succinct and explain in 3 sentences or less.
            </div>
            <div class="form-group">
                <label for="synopsis">Eligibility:</label>
                <span class="fa fa-question-circle helpIcon" ng-click="eligHelp=!eligHelp"></span>
                <textarea ng-model="role.requirements" class="form-control" placeholder="Enter requirements"></textarea>
            </div>
            <div class="guideVocal" ng-show="eligHelp" ng-click="eligHelp=false">
                The eligibility is a little more detail about what qualities one would expected
                of a role player.  Perhaps there are some skills required.  In some cases there
                are eligibility requirements, like having participated in the group for a period
                of time before they can be considered for the roles.
            </div>
            <div style="margin-bottom:40px">
                <button ng-click="updateRole(role)" class="btn btn-default btn-raised">Save</button>
            </div>
            <div class="form-group">
                <label for="synopsis">Responsibilities:</label>
                <table class="table">
                <tr ng-repeat="aresp in role.responsibilities" >
                    <td class="actions">
                        <button type="button" name="edit" class="btn btn-primary" 
                                ng-click="openResponsibilityModal(aresp)">
                            <span class="fa fa-edit"></span>
                        </button>
                    </td>
                    <td ng-click="openResponsibilityModal(aresp)">{{aresp.text}}</td>
                    <td class="actions">
                        <button type="button" name="delete" class='btn btn-warning' 
                                ng-click="deleteResponsibility(aresp)">
                            <span class="fa fa-trash"></span>
                        </button>
                    </td>
                </tr>
                </table>
                <div ng-show="role.responsibilities.length==0" class="guideVocal">
                There are no responsibilities listed for this role.
                </div>
            </div>
            <div>
                <button ng-click="openResponsibilityModal()" class="btn btn-default btn-raised">
                    Create Responsibility
                </button>
                <span class="fa fa-question-circle helpIcon" ng-click="respHelp=!respHelp"></span>
            </div>
            <div class="guideVocal" ng-show="respHelp" ng-click="respHelp=false">
                You can list a set of responsibilities that the player of this role
                normally takes care of.  These should be descriptive of the role.
                List as many as possible as long as the list is helpful in guiding
                people while they play the role, or in helping people to decide who
                might be the best person for the role.
            </div>
        </div>
        
        <div class="col-md-6 col-sm-12">
            <div class="form-group">
                <label for="synopsis">Terms on Record:</label>
                <table class="table">
                <tr>
                    <td></td>
                    <td></td>
                    <td>Start</td>
                    <td>Days</td>
                </tr>
                <tr ng-repeat="aterm in role.terms" >
                    <td class="actions" title="Edit this term to sent time span and to make it the current term.">
                        <button type="button" name="edit" class="btn btn-primary" 
                                ng-click="openTermModal(aterm)">
                            <span class="fa fa-edit"></span>
                        </button>
                    </td>
                    <td class="actions" title="Nominations and elections of members to the term of the role.">
                        <button type="button" name="edit" class="btn btn-primary" 
                                ng-click="goNominate(aterm)">
                            <span class="fa fa-flag"></span>
                        </button>
                    </td>
                    <td ng-click="openTermModal(aterm)" ng-style="termColor(aterm)" 
                        title="Date that the term is proposed to start - click to edit">
                        {{aterm.termStart |  date}}</td>
                    <td ng-click="openTermModal(aterm)"
                        title="The term in days is set by setting the end date - click to edit">
                        {{getDays(aterm)}}</td>
                    <td class="actions">
                        <button type="button" name="delete" class='btn btn-warning' 
                                ng-click="deleteTerm(aterm)"
                                title="Click here to delete this term">
                            <span class="fa fa-trash"></span>
                        </button>
                    </td>
                </tr>
                </table>
                <div ng-show="role.terms.length==0" class="guideVocal">
                    There are no designated terms for this role.
                </div>
            </div>
            <div>
                <button ng-click="openTermModal()" class="btn btn-default btn-raised">Create Term</button>
                <span class="fa fa-question-circle helpIcon" ng-click="termHelp=!termHelp"></span>
            </div>
            <div class="guideVocal" ng-show="termHelp" ng-click="termHelp=false">
                You can create 'terms' for this role, those are particular time periods for which 
                people will hold the role.  Terms can be set up in advance so that you are prepared
                to pass the role from one player to another.  Terms also serve as a record of who
                played the role in the past, and when they did so.  When a new term is proposed,
                it supports the nomination and selection process for that new time period for the role.
            </div>
        </div>

    </div>

</div>

<script src="<%=ar.retPath%>templates/Responsibility.js"></script>
<script src="<%=ar.retPath%>templates/TermModal.js"></script>
