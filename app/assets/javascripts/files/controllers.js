angular.module('Directory.files.controllers', ['fileDropzone', 'Directory.csvImports.models', 'Directory.alerts'])
.controller('FilesCtrl', ['$scope', '$http', 'CsvImport', '$timeout', 'Alert', function ($scope, $http, CsvImport, $timeout, Alert) {
  $scope.files = [];

  $scope.$watch('files', function(files) {
    var newFile;
    while (newFile = files.pop()) {
      (function(file){
        var alert = new Alert();

        alert.status = "Uploading";
        alert.progress = 1;
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
          var csvImport = new CsvImport({id:data.id});
          alert.progress = 25;
          alert.status = "Waiting";
          alert.startSync(csvImport.alertSync());
        });
      }(newFile));
    }
  });
}]);

