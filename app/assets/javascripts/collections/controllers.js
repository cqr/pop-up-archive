angular.module('Directory.collections.controllers', ['Directory.loader', 'Directory.user', 'Directory.collections.models'])
.controller('CollectionsCtrl', ['$scope', 'Collection', 'Loader', 'Me', function CollectionsCtrl($scope, Collection, Loader, Me) {
  Me.authenticated(function (data) {
    Loader.page(Collection.query(), 'Collections', $scope);

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
    // console.log('ItemCtrl on fileAdded', file);
    var item = new Item({collectionId:$routeParams.collectionId, title:file.name});
    item.create().then(function () {
      item.addAudioFile(file).then(function(data) {
        $scope.addMessage({
          'type': 'success',
          'title': 'Congratulations!',
          'content': 'Your upload completed. <a data-dismiss="alert" href="' + item.link() + '">View and edit the new item!</a>'
        });
      }, function(data){
        console.log('fileAdded: addAudioFile: reject', data, item);
      });
    });
  });

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
}]);
