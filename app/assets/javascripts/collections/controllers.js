angular.module('Directory.collections.controllers', ['Directory.loader', 'Directory.user', 'Directory.collections.models'])
.controller('CollectionsCtrl', ['$scope', 'Collection', 'Loader', 'Me', function CollectionsCtrl($scope, Collection, Loader, Me) {
  Me.authenticated(function (me) {
    Loader.page(Collection.query(), Collection.get(me.uploadsCollectionId), 'Collections', $scope).then(function (data) {
      $scope.collection = undefined;
      $scope.uploadsCollection = data[1];
      $scope.uploadsCollection.fetchItems();
    });

    $scope.selectedItems = [];

    $scope.$watch('uploadsCollection.items', function (is) {
      if (angular.isArray(is)) {
        angular.forEach(is, function (item) {
          if (item.selected && $scope.selectedItems.indexOf(item) == -1) {
            $scope.selectedItems.push(item);
          }
        });
      }
    }, true);

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

    $scope.selectAll = function (items) {
      angular.forEach(items, function (item) {
        if (!item.selected) {
          $scope.toggleItemSelection(item);
        }
      });
    }

    $scope.deleteSelection = function () {
      if (confirm("Are you sure you would like to delete these " + $scope.selectedItems.length + " items from My Uploads?\n\nThis is permanent and cannot be undone.")) {
        angular.forEach($scope.selectedItems, function (item) {
          item.delete();
          if ($scope.uploadsCollection.items.indexOf(item) !== -1) {
            $scope.uploadsCollection.items.splice($scope.uploadsCollection.items.indexOf(item), 1);
          }
        });
        $scope.selectedItems.length = 0;
      }
    }

    $scope.clearSelection = function () {
      angular.forEach($scope.selectedItems, function (item) {
        item.selected = false;
      })
      $scope.selectedItems.length = 0;
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

  $scope.delete = function () {
    if (confirm("Are you sure you want to delete the collection " + $scope.collection.title + " and all items it contains?\n\n This cannot be undone.")) {
      $scope.collection.delete().then(function () {
        $location.path('/collections');
      })
    }
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

  var currentCollection;

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

  $scope.$watch('selectedItsm.collectionId', function (is) {
    if (typeof is !== 'undefined') {
      for (var i=0; i < $scope.collections.length; i++) {
        if ($scope.collections[i].id == is) {
          currentCollection = $scope.collections[i];
          break;
        }
      }
    }
  })


  $scope.dismiss = function () {
    $scope.clearSelection();
    dismiss();
  }

  $scope.submit = function () {
    angular.forEach($scope.selectedItems, function (item) {
      item.adopt($scope.selectedItems.collectionId);
      $scope.uploadsCollection.items.splice($scope.uploadsCollection.items.indexOf(item), 1);
      if (currentCollection && currentCollection.items && currentCollection.items.push)
        curcurrentCollection.items.push(item);
    });
    $scope.dismiss();
  }
}])
.controller('NewPublicCollectionCtrl', ['$scope', 'Collection', function ($scope, Collection) {
  $scope.collection = new Collection({itemsVisibleByDefault: true});
}])
.controller('NewPrivateCollectionCtrl', ['$scope', 'Collection', function ($scope, Collection) {
  $scope.collection = new Collection({itemsVisibleByDefault: false});
}])
.controller('BatchEditCtrl', ['$scope', 'Loader', 'Collection', 'Me', function ($scope, Loader, Collection, Me) {
  Me.authenticated(function (currentUser) {
    Loader.page(Collection.query(), 'BatchEdit', $scope).then(function (collections) {
      angular.forEach(collections, function (collection) {
        collection.fetchItems();
      });
    });
  });

  $scope.sortType = 0;

  var itemsByMonth = {};
  var logged = false;

  $scope.$watch(function () {
    var items = [];
    if ($scope.collections) {
      angular.forEach($scope.collections, function (collection) {
        if (collection.items) {
          items.push.apply(items, collection.items);
        }
      });
    }
    return items;
  }, function (is) {
    $scope.itemsByMonth = {};
    $scope.itemsByCollection = {};
    $scope.selectedItems = [];
    if (is.length) {

      angular.forEach($scope.collections, function (collection) {
        if (collection.items && collection.items.length)
          $scope.itemsByCollection[collection.id] = {name: collection.title, items: collection.items};
      });

      var date, month, year, string;

      angular.forEach(is, function (item) {
        if (item.selected && $scope.selectedItems.indexOf(item) == -1) {
          $scope.selectedItems.push(item);
        }



        item.__dateHash = item.__dateHash || getDateHashForItem(item);
        $scope.itemsByMonth[item.__dateHash] = $scope.itemsByMonth[item.__dateHash] || {name: dateString(item.__dateHash), items: []};
        $scope.itemsByMonth[item.__dateHash].items.push(item);
      });
    }
  }, true);

  $scope.allTags = [];

  $scope.$watch('selectedItems', function (is) {
    $scope.allTags.length = 0;
    if (angular.isArray(is) && is.length) {
      var tagSet = {};
      angular.forEach(is, function (selectedItem) {
        angular.forEach(selectedItem.tags, function (tag) {
          tagSet[tag] = 1;
        });
      });
      $scope.allTags.push.apply($scope.allTags, Object.keys(tagSet));
    }
    
  });

  function getDateHashForItem(item) {
    date = new Date(item.dateAdded);
    month = date.getUTCMonth();
    year  = date.getUTCFullYear();
    return 1000000 - (year * 100 + month);
  }

  function dateString (dateHash) {
    dateHash = 1000000 - dateHash;

    var year = Math.floor(dateHash / 100);
    var month = dateHash - (year * 100);

    var string;

    switch (month) {
      case 0: string = "January"; break;
      case 1: string = "February"; break;
      case 2: string = "March"; break;
      case 3: string = "April"; break;
      case 4: string = "May"; break;
      case 5: string = "June"; break;
      case 6: string = "July"; break;
      case 7: string = "August"; break;
      case 8: string = "September"; break;
      case 9: string = "October"; break;
      case 10: string = "November"; break;
      case 11: string = "December"; break;
      default: string = "chris"; break;
    }

    return string + ", " + year;
  }

  $scope.selectedItems = [];

  $scope.sortedItems = function () {
    if ($scope.sortType) {
      return $scope.itemsByCollection;
    } else {
      return $scope.itemsByMonth;
    }
  }

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
  };

  $scope.clearSelection = function () {
    angular.forEach($scope.selectedItems, function (item) {
      item.selected = false;
    })
    $scope.selectedItems.length = 0;
  };

  $scope.deleteSelection = function () {
    if (confirm("Are you sure you would like to delete these " + $scope.selectedItems.length + " items from My Uploads?\n\nThis is permanent and cannot be undone.")) {
      angular.forEach($scope.selectedItems, function (item) {
        item.delete();
        item.getCollection().items.splice(item.getCollection().items.indexOf(item), 1);
      });
      $scope.selectedItems.length = 0;
    }
  };
}]);
