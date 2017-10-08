<%@page import="org.socialbiz.cog.NGRole"
%><%@ include file="/spring/jsp/include.jsp"
%><%
    
    String pageId = ar.reqParam("pageId");
    String siteId = ar.reqParam("siteId");
    NGWorkspace ngp = ar.getCogInstance().getWSBySiteAndKeyOrFail(siteId, pageId).getWorkspace();
    NGBook site = ngp.getSite();
    if (!site.isMoved()) {
        throw new Exception("Redirected page should only be called on workspaces/sites that are moved.");
    }
    String newBaseUrl = site.getMovedTo();
    System.out.println("Site MovedTo URL = "+newBaseUrl);
    if (!newBaseUrl.endsWith("/")) {
        throw new Exception("MovedTo URL must end with a slash: "+newBaseUrl);
    }
    String reqUrl = ar.realRequestURL;
    String ctxFrag = ar.req.getContextPath() + "/t/";
    int pos = reqUrl.indexOf(ctxFrag);
    if (pos<0) {
        throw new Exception("Can't understand why context ("+ctxFrag+") is not in real URL: "+reqUrl);
    }
    String remaining = reqUrl.substring(pos + ctxFrag.length() + siteId.length() + 1);
    newBaseUrl = newBaseUrl + remaining;

%>
<!-- Redirected.jsp -->
<script>
var app = angular.module('myApp', ['ui.bootstrap','ngTagsInput']);
app.controller('myCtrl', function($scope, $http) {
    window.setMainPageTitle("Moved to New Location");
    $scope.siteInfo = <%site.getConfigJSON().write(out,2,4);%>;
    $scope.newBaseUrl = "<% ar.writeJS(newBaseUrl); %>";
    $scope.workspaceName = "<% ar.writeJS(ngp.getFullName()); %>";
});
</script>

<div ng-app="myApp" ng-controller="myCtrl">

<%@include file="ErrorPanel.jsp"%>

    <div class="guideVocal" style="max-width:400px" ng-click="window.location = newBaseUrl">
        This workspace has been relocated to a new location. 
        <br/>
        If you have a favorites bookmark please update it with the new address.        
        <br/>
        <br/>
        <a href="<%=newBaseUrl%>" class="btn">Click here to navigate to <br/><b>{{workspaceName}}</b></a>
    </div>

</div>
