angular.module('Directory.collections.controllers', ['Directory.loader', 'Directory.user', 'Directory.collections.models'])
.controller('CollectionsCtrl', ['$scope', 'Collection', 'Loader', 'Me', function CollectionsCtrl($scope, Collection, Loader, Me) {
  Me.authenticated(function (data) {
    Loader.page(Collection.query(), 'Collections', $scope);

    $scope.delete = function(index) {
      var collection = $scope.collections[index];
      collection.deleting = true;
      collection.delete().then(function() {
        $scope.collections.splice(index, 1);
      });
    }
  });
}])
.controller('CollectionCtrl', ['$scope', '$routeParams', 'Collection', 'Loader', 'Item', function CollectionCtrl($scope, $routeParams, Collection, Loader, Item) {
  Loader.page(Collection.get($routeParams.collectionId), 'Collection/' + $routeParams.collectionId,  $scope);

  $scope.openAddItem = function () {
    $scope.addingItem = true;
  }

  $scope.closeAddItem = function () {
    $scope.newItem = new Item;
    $scope.addingItem = false;
  }

  $scope.closeAddItem();
}])
.controller('CollectionFormCtrl', ['$scope', 'Collection', function CollectionFormCtrl($scope, Collection) {
  $scope.open = function () {
    $scope.shouldBeOpen = true;
  };


  $scope.close = function () {
    $scope.shouldBeOpen = false;
  };

  $scope.collection = ($scope.collection || new Collection);

  $scope.submit = function() {
    $scope.collection.create().then(function(data) {
      $scope.collections.push($scope.collection);
      $scope.collection = new Collection;
      $scope.close();
    });
  }
}]);
