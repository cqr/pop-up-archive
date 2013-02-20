angular.module('Directory.items.controllers', ['Directory.loader', 'Directory.items.models'])
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', function ItemsCtrl($scope, Item, Loader) {
  $scope.items = Loader.page(Item.query(), 'Items');
}]);