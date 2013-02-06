(window.controllers = window.controllers || angular.module("Directory.controllers", ['Directory.alerts']))
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

  $scope.save = function () {
    $scope.import.saving = true;
    return $scope.import.update().then(function() {
      delete($scope.import.saving);
      return $scope.import;
    });
  }

}])
.controller("ImportMappingCtrl", ['$scope', 'Schema', 'Alert', function ($scope, Schema, Alert) {
  $scope.schema = Schema.get();

  $scope.submitMapping = function submitMapping () {
    $scope.import.commit = 'import';
    return $scope.import.update().then(function(i) {
      alert = new Alert({status:"Importing", progress: 50});
      alert.add();
    });
  }

  $scope.$watch('import.headers', function watchImportHeaders (headers) {
    angular.forEach(headers, function forEachHeader (header, index) {
      $scope.$watch('import.mappings['+index+'].column', function watchMappingColumn (columnName) {
          if (columnName) {
            var type, column = $scope.schema.columnByName(columnName);
            if (column) {
              type = $scope.schema.types.get(column.typeId);
              $scope.import.mappings[index].type = type.name;
            }
          }
        });
        $scope.$watch('import.mapping['+index+'].type', function watchMappingType (typeName) {
          if (typeName) {
            var column = $scope.schema.columnByName($scope.mapping[index].column);
            if (column && $scope.schema.types.get(column.typeId).name != typeName) {
              $scope.import.mappings[index].column = undefined;
            }
          }
        });
    });
  });
  
}])
.controller('AlertCtrl', ['$scope', 'Alert', function ($scope, Alert) {
  $scope.alertData = {};
  $scope.alertData.alerts = Alert.getAlerts();

  $scope.dismissIfDone = function(alert) {
    $scope.forceAlertsShow = false;
    if (alert.path || alert.done) {
      alert.dismiss();
    }
  }

  // Wrap that method up - middleware style
  var oldAddAlert = Alert.prototype.add;
  Alert.prototype.add = function () {
    if ($scope.alertData.alerts.length < 1) {
      $scope.forceAlertsShow = true;
    }
    return oldAddAlert.call(this);
  }
}]);
