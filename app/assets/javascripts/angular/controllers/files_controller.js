(window.controllers = window.controllers || angular.module('Directory.controllers', ['Directory.alerts']))
.controller('FilesCtrl', ['$scope', '$http', 'CsvImport', '$timeout', 'Alert', function ($scope, $http, CsvImport, $timeout, Alert) {
  $scope.files = [];
  $scope.$watch('files', function(files) {
    var newFile;
    while (newFile = files.pop()) {
      (function(file){
        var alert = new Alert();

        alert.status = "Uploading";
        alert.progress = 0;
        alert.message = file.name;

        alert.add();

        var fData = new FormData();
        fData.append('csv_import[file]', file);

        $http({
          method: 'POST',
          url: '/api/csv_imports',
          data: fData,
          headers: { "Content-Type": undefined },
          transformRequest: angular.identity
        }).success(function(data, status, headers, config) {
          alert.progress = 25;
          alert.status = "Waiting";
          watchImport(data.id, alert);
        });
      }(newFile));
    }
  });

  function watchImport(importId, alert) {
    (function fetchImport() {
      CsvImport.get(importId).then(function(data) {
        switch (data.state) {
          case 'analyzing':
            alert.timeout  = $timeout(fetchImport, 50);
            alert.progress = 50;
            alert.status   = "Analyzing";
            break;
          case 'analyzed':
            alert.progress = 100;
            alert.status   = "Analyzed";
            alert.done     = true;
            alert.path     = "/imports/"+data.id;
            break;
          default:
            alert.timeout = $timeout(fetchImport, 250);
        }
      });
    })();
  }
}]);

