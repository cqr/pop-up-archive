(window.controllers = window.controllers || angular.module('Directory.controllers', []))
.controller('ItemsCtrl', ['$scope', '$resource', function ItemsCtrl($scope, $resource) {
  $scope.itemFetcher = $resource('/api/items.json');
  $scope.data = $scope.itemFetcher.get();
}]);

