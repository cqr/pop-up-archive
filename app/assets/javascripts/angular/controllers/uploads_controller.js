(window.controllers = window.controllers || angular.module("Directory.controllers", []))
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
.controller("ImportCtrl", ['$scope', 'CsvImport', '$routeParams', '$timeout', function($scope, CsvImport, $routeParams, $timeout) {
  $scope.analyzed = false;

  (function fetchImport () {

    CsvImport.get($routeParams.importId).then(function(data) {

      $scope.import = data;
      
      if($scope.import.state == 'analyzed'){
        if ($scope.timeout && $scope.timeout.cancel) {
          $scope.timeout.cancel();
        }
      } else {
        $scope.timeout = $timeout($scope.fetchImport, 100);
      }
    });
  })();

}])
.controller("ImportMappingCtrl", ['$scope', 'Schema', function ($scope, Schema) {
  $scope.schema = Schema.get();
  $scope.mapping = [];

  $scope.submitMapping = function () {
    $scope.import.mapping = $scope.mapping;
    $scope.import.update();
  }

  $scope.$watch('import.headers', function (headers) {
    $scope.mapping = [];
    angular.forEach(headers, function (header, index) {
      $scope.mapping[index] = {};
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
  });
  
}]);
