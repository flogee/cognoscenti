<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="java.io.File"
%><%@page import="java.io.FileInputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.OutputStream"
%><%@page import="java.io.OutputStreamWriter"
%><%@page import="java.io.PrintWriter"
%><%@page import="java.io.Writer"
%><%@page import="java.lang.StringBuffer"
%><%@page import="java.net.URLDecoder"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.text.SimpleDateFormat"
%><%@page import="java.util.Arrays"
%><%@page import="java.util.Date"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.HashMap"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Iterator"
%><%@page import="java.util.List"
%><%@page import="java.util.Map"
%><%@page import="java.util.Properties"
%><%@page import="java.util.Vector"
%><%@page import="java.util.ArrayList"
%><%@page import="org.socialbiz.cog.AddressListEntry"
%><%@page import="org.socialbiz.cog.AttachmentRecord"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.BaseRecord"
%><%@page import="org.socialbiz.cog.Cognoscenti"
%><%@page import="org.socialbiz.cog.CustomRole"
%><%@page import="org.socialbiz.cog.DecisionRecord"
%><%@page import="org.socialbiz.cog.GoalRecord"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.LicensedURL"
%><%@page import="org.socialbiz.cog.MeetingRecord"
%><%@page import="org.socialbiz.cog.MimeTypes"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGContainer"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGWorkspace"
%><%@page import="org.socialbiz.cog.NGRole"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.TopicRecord"
%><%@page import="org.socialbiz.cog.ProcessRecord"
%><%@page import="org.socialbiz.cog.ProfileRef"
%><%@page import="org.socialbiz.cog.RUElement"
%><%@page import="org.socialbiz.cog.ReminderMgr"
%><%@page import="org.socialbiz.cog.ReminderRecord"
%><%@page import="org.socialbiz.cog.RemoteGoal"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionForNotes"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionTask"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserManager"
%><%@page import="org.socialbiz.cog.UserPage"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UserRef"
%><%@page import="org.socialbiz.cog.UserCache"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="org.socialbiz.cog.WikiConverter"
%><%@page import="org.socialbiz.cog.WorkspaceStats"
%><%@page import="org.socialbiz.cog.WatchRecord"
%><%@page import="org.socialbiz.cog.dms.RemoteLinkCombo"
%><%@page import="org.socialbiz.cog.dms.ResourceEntity"
%><%@page import="org.socialbiz.cog.exception.NGException"
%><%@page import="org.socialbiz.cog.exception.ProgramLogicError"
%><%@page import="org.socialbiz.cog.mail.EmailSender"
%><%@page import="org.socialbiz.cog.rest.DataFeedServlet"
%><%@page import="org.socialbiz.cog.spring.NGWebUtils"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.workcast.json.JSONArray"
%><%@page import="org.workcast.json.JSONObject"
%><%@page import="org.workcast.streams.StreamHelper"
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"
%><%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
%>
<fmt:setBundle basename="messages"/>

