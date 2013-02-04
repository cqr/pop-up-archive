(window.controllers = window.controllers || angular.module('Controllers', []))
.controller('FilesCtrl', ['$scope', '$http', 'CsvImport', '$timeout', function ($scope, $http, CsvImport, $timeout) {
  $scope.files = [];
  $scope.pendingActions = [];
  $scope.$watch('files', function(files) {
    var newFile;
    while (newFile = files.pop()) {
      (function(file){
        var action = {};

        action.message = "Uploading \"" + file.name + "\"...";
        action.progress = 0;
        $scope.pendingActions.push(action);

        var fData = new FormData();
        fData.append('csv_import[file]', file);

        $http({
          method: 'POST',
          url: '/api/csv_imports',
          data: fData,
          headers: { "Content-Type": undefined },
          transformRequest: angular.identity
        }).success(function(data, status, headers, config) {
          action.progress = 25;
          action.message = "\"" + file.name + "\" awaiting analysis...";
          watchImport(data.id, action);
        });
      }(newFile)); 
    }
  });

  function watchImport(importId, action) {
    (function fetchImport() {
      CsvImport.get({importId: importId}, function(data) {
        switch (data.state) {
          case 'analyzing':
            action.timeout = $timeout(fetchImport, 50);
            action.progress = 50;
            action.message = "Analyzing \"" + data.file + "\"...";
            break;
          case 'analyzed':
            action.progress  = 100;
            action.message = '"' + data.file + "\" is analyzed!";
            action.path = "/imports/"+data.id;
            break;
          default:
            action.timeout = $timeout(fetchImport, 250);
        }
      });
    })();
  }

  $scope.removeAction = function(index) {
    $scope.pendingActions.splice(index, 1);
  }

}]);

