(window.controllers = window.controllers || angular.module("Controllers", []))
.controller('UploadsCtrl', ['$scope', '$http', function($scope, $http) {
  $scope.upload = function() {

    var file = $scope.uploads[0];

    var fData = new FormData();
    fData.append('csv_import[file]', file);
    $http({
      method: 'POST',
      url: '/api/csv_imports',
      data: fData,
      headers: { "Content-Type": undefined },
      transformRequest: angular.identity
    }).success(function(data, status, headers, config) {
      $scope.import = data
    });
  }
}])
.controller("ImportCtrl", ['$scope', 'CsvImport', '$routeParams', '$timeout', 'Schema', function($scope, CsvImport, $routeParams, $timeout, Schema) {
  $scope.analyzed = false;
  $scope.data = {};
  $scope.schema = Schema.get();
  $scope.mapping = [];


  (function fetchImport () {

    CsvImport.get({importId:$routeParams.importId}, function(data) {

      angular.forEach(data.headers, function(header, index) {
        $scope.mapping[index] = ($scope.mapping[index] || {});
        $scope.$watch('mapping['+index+'].column', function(columnName) {
          if (columnName) {
            var column = $scope.schema.columnByName(columnName),
                type   = $scope.schema.types.get(column.typeId);
            $scope.mapping[index].type = type.name;
          }
        });
        $scope.$watch('mapping['+index+'].type', function(typeName) {
          var column = $scope.schema.columnByName($scope.mapping[index].column);
          if (column && $scope.schema.types.get(column.typeId).name != typeName) {
            $scope.mapping[index].column = undefined;
          }
        });
      });

      $scope.data.import = data;
      
      if($scope.data.import.state == 'analyzed'){
        if ($scope.timeout && $scope.timeout.cancel) {
          $scope.timeout.cancel();
        }
      } else {
        $scope.timeout = $timeout($scope.fetchImport, 1000);
      }
    });
  })();

  
}]);
