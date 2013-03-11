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
.controller('CollectionCtrl', ['$scope', '$routeParams', 'Collection', 'Loader', 'Item', '$location', '$timeout', function CollectionCtrl($scope, $routeParams, Collection, Loader, Item, $location, $timeout) {
  Loader.page(Collection.get($routeParams.collectionId), 'Collection/' + $routeParams.collectionId,  $scope);

  $scope.edit = function () {
    $scope.editItem = true;
  }

  $scope.close = function () {
    $scope.editItem = false;
    $scope.item = new Item({collectionId:$routeParams.collectionId});
  }

  $scope.itemAdded = function (item) {
    $timeout(function(){ $scope.$broadcast('datasetChanged')}, 750);
  }

  $scope.$on('fileAdded', function (e, file) {
    var item = new Item({collectionId:$routeParams.collectionId, title:file.name});
    item.create().then(function () {
      item.addAudioFile(file);
    });
  });

  $scope.close();

  $scope.hasFilters = false;
}])
.controller('PublicCollectionsCtrl', ['$scope', 'Collection', 'Loader', function PublicCollectionsCtrl($scope, Collection, Loader) {
  $scope.collections = Loader(Collection.public());
}])
.controller('CollectionFormCtrl', ['$scope', 'Collection', function CollectionFormCtrl($scope, Collection) {
  $scope.open = function () {
    $scope.editCollection = true;
  };

  $scope.edit = function (collection) {
    $scope.collection = (collection || new Collection);
    $scope.open();
  }

  $scope.close = function () {
    $scope.editCollection = false;
  };

  $scope.submit = function() {
    var promise;
    if ($scope.collection.id) {
      promise = $scope.collection.update().then(function (data) {
        $scope.close();
        return data;
      });
    } else {
      $scope.collection.create().then(function (data) {
        $scope.collections.push($scope.collection);
        return data;
      });
    }
    return promise.then(function (data) {
      $scope.close();
      return data;
    });
  }
}]);
