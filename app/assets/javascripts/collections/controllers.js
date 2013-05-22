angular.module('Directory.collections.controllers', ['Directory.loader', 'Directory.user', 'Directory.collections.models'])
.controller('CollectionsCtrl', ['$scope', 'Collection', 'Loader', 'Me', function CollectionsCtrl($scope, Collection, Loader, Me) {
  Me.authenticated(function (me) {
    Loader.page(Collection.query(), Collection.get(me.uploadsCollectionId), 'Collections', $scope).then(function (data) {
      $scope.collection = undefined;
      $scope.uploadsCollection = Loader.page(data[1].fetchItems());
    });

    $scope.selectedItems = [];

    $scope.toggleItemSelection = function (item) {
      if (item.selected) {
        item.selected = false;
        if ($scope.selectedItems.indexOf(item) != -1) {
          $scope.selectedItems.splice($scope.selectedItems.indexOf(item), 1);
        }
      } else {
        item.selected = true;
        if ($scope.selectedItems.indexOf(item) == -1) {
          $scope.selectedItems.push(item);
        }
      }
    }

    $scope.clearSelection = function () {
      angular.forEach($scope.selectedItems, function (item) {
        item.selected = false;
      })
      $scope.selectedItems = [];
    }

    $scope.delete = function(index) {
      var confirmed = confirm("Delete collection and all items?");
      if (!confirmed) {
        return false;
      }

      var collection = $scope.collections[index];
      collection.deleting = true;
      collection.delete().then(function() {
        $scope.collections.splice(index, 1);
      });
    }
  });
}])
.controller('CollectionCtrl', ['$scope', '$routeParams', 'Collection', 'Loader', 'Item', '$location', '$timeout', function CollectionCtrl($scope, $routeParams, Collection, Loader, Item, $location, $timeout) {
  $scope.canEdit = false;

  Loader.page(Collection.get($routeParams.collectionId), Collection.query(), 'Collection/' + $routeParams.collectionId,  $scope).then(function () {
    angular.forEach($scope.collections, function (collection) {
      if (collection.id == $scope.collection.id) {
        $scope.canEdit = true;
      }
    });
  });

  $scope.edit = function () {
    $scope.editItem = true;
  }

  $scope.close = function () {
    $scope.editItem = false;
    $scope.item = new Item({collectionId:parseInt($routeParams.collectionId)});
  }

  $scope.itemAdded = function (item) {
    $timeout(function(){ $scope.$broadcast('datasetChanged')}, 750);
  }

  $scope.close();

  $scope.hasFilters = false;
}])
.controller('PublicCollectionsCtrl', ['$scope', 'Collection', 'Loader', function PublicCollectionsCtrl($scope, Collection, Loader) {
  $scope.collections = Loader(Collection.public());
}])
.controller('CollectionFormCtrl', ['$scope', 'Collection', function CollectionFormCtrl($scope, Collection) {

  $scope.edit = function (collection) {
    $scope.collection = collection;
  }

  $scope.submit = function() {

    // make sure this is a resource object.
    var collection = new Collection($scope.collection);

    if (collection.id) {
      collection.update();
    } else {
      collection.create().then(function (data) {
        $scope.collections.push(collection);
      });
    }
  }
}])
.controller('UploadCategorizationCtrl', ['$scope', function($scope) {
  var dismiss = $scope.dismiss;

  $scope.$watch('collections', function (is, was) {
    if (typeof is !== 'undefined') {
      for (var i=0; i < $scope.collections.length; i++) {
        if ($scope.collections[i].id != $scope.currentUser.uploadsCollectionId) {
          $scope.selectedItems.collectionId = $scope.collections[i].id;
          break;
        }
      }
    }
  });


  $scope.dismiss = function () {
    $scope.clearSelection();
    dismiss();
  }

  $scope.submit = function () {
    angular.forEach($scope.selectedItems, function (item) {
      console.log("should move " + item.getTitle() + " to collection " + $scope.selectedItems.collectionId);
    });
    $scope.dismiss();
  }
}]);
