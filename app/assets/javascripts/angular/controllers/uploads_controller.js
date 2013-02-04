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
.controller("ImportCtrl", ['$scope', 'CsvImport', '$routeParams', '$timeout', function($scope, CsvImport, $routeParams, $timeout) {
  $scope.analyzed = false;
  $scope.data = {};

  $scope.fetchImport = function () {

    CsvImport.get({importId:$routeParams.importId}, function(data) {

      $scope.data.import = data;
      
      if($scope.data.import.state == 'analyzed'){
        if ($scope.timeout && $scope.timeout.cancel) {
          $scope.timeout.cancel();
        }
      } else {
        $scope.timeout = $timeout($scope.fetchImport, 1000);
      }
    });
  }

  $scope.fetchImport();

  
}]);
