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
.controller("ImportCtrl", ['$scope', 'CsvImport', '$routeParams', 'Collection', '$q', function($scope, CsvImport, $routeParams, Collection, $q) {
  $scope.analyzed = false;

  function prependNewCollection(i, collections) {
    return [{id:0, title:"New Collection: " + i.file}].concat(collections);
  }

  $scope.pageLoading(true);
  $q.all([CsvImport.get($routeParams.importId), Collection.query()]).then(function (data) {
    $scope.import = data[0];
    $scope.collections = prependNewCollection($scope.import, data[1]);
    $scope.pageLoading(false);
  });

  $scope.getNewPreviewRows = function getNewPreviewRows () {
     CsvImport.get($scope.import.id).then(function(data) {
      $scope.import.previewRows = data.previewRows;
     })
  }

  $scope.save = function save () {
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
    var alert = new Alert({status:"Submitting", message:$scope.import.file, progress:1});
    alert.import = $scope.import;
    alert.add();
    alert.import.update().then(function () {
      alert.sync = function (alert) {
        return alert.import.constructor.get(alert.import.id).then(function(im) {
          alert.import = im;
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

    $scope.importDestination = 'new';
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
}])
.controller('ImportsCtrl', ['$scope', 'CsvImport', function ($scope, CsvImport) {
  $scope.imports = ($scope.imports || []);

  CsvImport.query().then(function (imports) {
    $scope.imports = imports;
  });

}])
.controller('SearchCtrl', ['$scope', '$location', '$routeParams', function ($scope, $location, $routeParams) {
  $scope.search = {};
  $scope.search.query = $routeParams.query;

  $scope.fetchResults = function () {
    $location.path('/search/' + $scope.search.query);
    angular.forEach(document.getElementsByTagName('input'), function (el) {
      el.blur();
    });
  }

}])
.controller('SearchResultsCtrl', ['$scope', 'Search', function ($scope, Search) {
  $scope.search = Search.query({query:$scope.search.query});
}]);
