function ItemsCtrl($scope, $resource) {
  $scope.itemFetcher = $resource('/api/:action', { action: 'items.json' });
  $scope.data = $scope.itemFetcher.get();
}
