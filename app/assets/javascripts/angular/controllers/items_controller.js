(window.controllers = window.controllers || angular.module('Directory.controllers', []))
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', function ItemsCtrl($scope, Item, Loader) {
  $scope.items = Loader.page(Item.query(), 'Items');
}]);