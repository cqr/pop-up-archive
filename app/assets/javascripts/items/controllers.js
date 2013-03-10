angular.module('Directory.items.controllers', ['Directory.loader', 'Directory.user', 'Directory.items.models'])
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', 'Me', function ItemsCtrl($scope, Item, Loader, Me) {
  Me.authenticated(function (data) {
    $scope.items = Loader.page(Item.query(), 'Items');
  });
}])
.controller('ItemCtrl', ['$scope', 'Item', 'Loader', '$routeParams', function ItemCtrl($scope, Item, Loader, $routeParams) {

  if ($routeParams.id) {
    Loader.page(Item.get({collectionId:$routeParams.collectionId, id: $routeParams.id}), 'Item/'+$routeParams.id, $scope);
  }
}]);
