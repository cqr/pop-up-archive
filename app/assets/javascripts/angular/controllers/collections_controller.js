function CollectionsCtrl($scope, $resource) {
  $scope.collectionFetcher = $resource('/api/collections.json');
  $scope.data = $scope.collectionFetcher.get();
}

function CollectionCtrl($scope, $resource, $routeParams) {
  $scope.collectionId = $routeParams.collectionId;

  $scope.collectionFetcher = $resource('/api/collections/:id.json', { id: $scope.collectionId });
  $scope.data = $scope.collectionFetcher.get({}, function(data) {
    console.log()
  });
}
