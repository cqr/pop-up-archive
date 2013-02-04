angular.module('Directory.models', ['ngResource'])
.factory('CsvImport', ['$resource', function($resource) {
  return $resource('/api/csv_imports/:importId', {importId:'@id'});
}]);