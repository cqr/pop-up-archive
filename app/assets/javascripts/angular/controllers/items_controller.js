(window.controllers = window.controllers || angular.module('Directory.controllers', []))
.controller('ItemsCtrl', [ '$resource','$scope', function ItemsCtrl($resource, $scope) {
  var itemsFetcher = $resource('/api/items');
  $scope.data = itemsFetcher.get();
}]);

