function ItemsController($scope, $resource) {
  $scope.items = $resource('/api/:action', { action: 'items.json' });
  $scope.itemResult = $scope.items.get();

  $scope.foo = function () {
    alert('1');
  }
}
