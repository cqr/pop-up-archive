(window.controllers = window.controllers || angular.module('Directory.controllers', []))
.controller('CollectionsCtrl', ['$scope', 'Collection', 'Loader', function CollectionsCtrl($scope, Collection, Loader) {
  Loader.loadPage(Collection.query(), $scope);

  $scope.delete = function(index) {
    var collection = $scope.collections[index];
    collection.deleting = true;
    collection.delete().then(function() {
      $scope.collections.splice(index, 1);
    });
  }
}])
.controller('CollectionCtrl', ['$scope', '$routeParams', 'Collection', 'Loader', function CollectionCtrl($scope, $routeParams, Collection, Loader) {
  Loader.loadPage(Collection.get($routeParams.collectionId), $scope);
}])
.controller('CollectionFormCtrl', ['$scope', 'Collection', function CollectionFormCtrl($scope, Collection) {
  $scope.collection = ($scope.collection || new Collection);

  $scope.submit = function() {
    $scope.collection.create().then(function(data) {
      $scope.collection = new Collection;
      $scope.collections.push(data);
    });
  }
}]);

