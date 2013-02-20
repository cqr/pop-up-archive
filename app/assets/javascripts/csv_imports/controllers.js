angular.module('Directory.csvImport.controllers', ['Directory.alerts', 'Directory.csvImports.models', 'Directory.collections.models', 'Directory.loader', 'Directory.csvImports.filters'])
.controller("ImportCtrl", ['$scope', 'CsvImport', '$routeParams', 'Collection', 'Loader', function($scope, CsvImport, $routeParams, Collection, Loader) {

  Loader.page(CsvImport.get($routeParams.importId), Collection.query(), 'importEdit-'+$routeParams.importId, $scope).then(function (data) {
    $scope.collections = [{id:0, title:"New Collection: " + $scope.csvImport.file}].concat($scope.collections);
  });

  $scope.getNewPreviewRows = function getNewPreviewRows () {
     CsvImport.get($scope.csvImport.id).then(function(data) {
      $scope.csvImport.previewRows = data.previewRows;
     });
  }

  $scope.save = function save () {
    $scope.csvImport.update();
  }

}])
.controller("ImportMappingCtrl", ['$scope', 'Schema', 'Alert', function ($scope, Schema, Alert) {
  $scope.schema = Schema.get();

  $scope.submitMapping = function submitMapping () {
    var i = $scope.csvImport;
    i.commit = 'import';
    var alert = new Alert({status:"Submitting", message:i.file, progress:1});
    alert.i = i;
    alert.add();
    console.log(i);
    i.update().then(function () {
      alert.sync = function (alert) {
        return alert.i.constructor.get(alert.i.id).then(function(im) {
          alert.i = im;
          if (im.state == 'error') {
            alert.status = "Error";
            delete alert.progress;
            alert.done = true;
            alert.path = "/imports/" + im.id;
          } else if (im.state == 'queued_import') {
            alert.status = "Waiting";
            alert.progress = 10;
          } else if (im.state == 'importing') {
            alert.status = "Importing";
            alert.progress = 30;
          } else if (im.state == 'imported') {
            alert.status = "Imported";
            alert.done = true;
            alert.progress = 100;
            alert.path = "/collections/" + im.collectionId; 
          }
          return im;
        });
      }
      alert.startSync();
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
.controller('AlertCtrl', ['$scope', 'Alert', '$timeout', function ($scope, Alert, $timeout) {
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
      $timeout(function () { $scope.forceAlertsShow = false }, 2000);
    }
    return oldAddAlert.call(this);
  }
}])
.controller('ImportsCtrl', ['$scope', 'CsvImport', 'Loader', function ($scope, CsvImport, Loader) {
  Loader.page(CsvImport.query(), 'Imports', $scope);
}])