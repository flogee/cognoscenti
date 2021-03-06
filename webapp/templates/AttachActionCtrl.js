app.controller('AttachActionCtrl', function($scope, $modalInstance, $http, containingQueryParams, AllPeople) {

    $scope.allActions = [];
    $scope.selectedActions = [];
    $scope.newGoal = {};
    $scope.newGoal.assignTo = [];
    $scope.containingQueryParams = containingQueryParams;
    $scope.realFilter = "";
    
    $scope.retrieveActionList = function() {
        var getURL = "allActionsList.json";
        $scope.showError=false;
        $http.get(getURL)
        .success( function(data) {
            $scope.allActions = data.list;
        })
        .error( function(data, status, headers, config) {
            $scope.reportError(data);
        });

        var getURL = "attachedActions.json?"+containingQueryParams;
        $http.get(getURL)
        .success( function(data) {
            console.log("AttachActionCtrl RECEIVED ACTION LIST: ", data);
            $scope.selectedActions = data.list;
        })
        .error( function(data, status, headers, config) {
            $scope.reportError(data);
        });

    }
    $scope.retrieveActionList();
    
    $scope.saveActions = function() {
        var getURL = "attachedActions.json?"+containingQueryParams;
        var newData = {list: $scope.selectedActions};
        console.log("AttachDocumentCtrl SAVED ACTION LIST: ", newData);
        return $http.post(getURL, JSON.stringify(newData));
    }
    

    $scope.filterActions = function() {
        var filterlc = $scope.realFilter.toLowerCase();
        var rez =  $scope.allActions.filter( function(oneAct) {
            return (filterlc.length==0
                || oneAct.synopsis.toLowerCase().indexOf(filterlc)>=0
                || oneAct.description.toLowerCase().indexOf(filterlc)>=0);
        });
        rez = rez.sort( function(a,b) {
            return a.rank - b.rank;
        });
        return rez;
    }
    $scope.itemHasAction = function(oneAct) {
        var res = false;
        var found = $scope.selectedActions.forEach( function(actionId) {
            if (actionId == oneAct.universalid) {
                res = true;
            }
        });
        return res;
    }
    $scope.itemActions = function() {
        return $scope.allActions.filter( function(oneAct) {
            return $scope.itemHasAction(oneAct);
        });
    }
    $scope.addActionToList = function(oneAct) {
        if (!$scope.itemHasAction(oneAct)) {
            $scope.selectedActions.push(oneAct.universalid);
        }
    }
    $scope.removeActionFromList = function(oneAct) {
        $scope.selectedActions = $scope.selectedActions.filter( function(actionId) {
            return (actionId != oneAct.universalid);
        });
    }
    
    $scope.getPeople = function(query) {
        return AllPeople.findMatchingPeople(query);
    }
    
    $scope.datePickOptions = {
        formatYear: 'yyyy',
        startingDay: 1
    };
    $scope.datePickOpen1 = false;
    $scope.openDatePicker1 = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.datePickOpen1 = true;
    };
    $scope.datePickDisable = function(date, mode) {
        return false;
    };
    $scope.loadPersonList = function(query) {
        return AllPeople.findMatchingPeople(query);
    }
    
    $scope.createActionItem = function(item) {
        var postURL = "createActionItem.json";
        var newSynop = $scope.newGoal.synopsis;
        if (newSynop == null || newSynop.length==0) {
            alert("must enter a description of the action item");
            return;
        }
        $scope.newGoal.state=2;
        $scope.newGoal.assignTo.forEach( function(player) {
            if (!player.uid) {
                player.uid = player.name;
            }
        });

        var postdata = angular.toJson($scope.newGoal);
        $scope.showError=false;
        $http.post(postURL ,postdata)
        .success( function(data) {
            $scope.allActions.push(data);
            $scope.selectedActions.push(data.universalid);
            console.log("ACTION ITEM CREATED", data);
            $scope.saveActions();
            $scope.newGoal = {};
            $modalInstance.close($scope.selectedActions);
        })
        .error( function(data, status, headers, config) {
            $scope.reportError(data);
        });
    };

    $scope.ok = function () {
        $scope.saveActions()
        .success( function(data) {
            console.log("AttachDocumentCtrl VERIFIED ACTION LIST: ", data);
            $modalInstance.close($scope.selectedActions);
        });
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
    $scope.selectedTab = "Create";

});