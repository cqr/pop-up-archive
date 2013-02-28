angular.module('Directory.items.controllers', ['Directory.loader', 'Directory.items.models'])
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', function ItemsCtrl($scope, Item, Loader) {
  $scope.items = Loader.page(Item.query(), 'Items');
}])
.controller('ItemCtrl', ['$scope', 'Item', 'Loader', '$routeParams', function ItemCtrl($scope, Item, Loader, $routeParams) {
  if ($routeParams.id) {
    Loader.page(Item.get($routeParams.id), 'Item/'+$routeParams.id, $scope);
  }
}]);