(window.controllers = window.controllers || angular.module('Directory.controllers', []))
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', function ItemsCtrl($scope, Item, Loader) {
  Loader.page(Item.query(), $scope);
}]);

