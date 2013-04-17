angular.module('Directory.items.controllers', ['Directory.loader', 'Directory.user', 'Directory.items.models'])
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', 'Me', function ItemsCtrl($scope, Item, Loader, Me) {
  Me.authenticated(function (data) {
    if ($scope.collectionId) {
      $scope.items = Loader.page(Item.query(), 'Items');
    }
  });
}])
.controller('ItemCtrl', ['$scope', 'Item', 'Loader', 'Me', '$routeParams', 'Collection', function ItemCtrl($scope, Item, Loader, Me, $routeParams, Collection) {

  $scope.canEdit = false;

  if ($routeParams.id) {
    Loader.page(Item.get({collectionId:$routeParams.collectionId, id: $routeParams.id}), Collection.query(), 'Item/'+$routeParams.id, $scope).then(function (datum) {
      angular.foreach($scope.collections, function (collection) {
        if (collection.id == $scope.item.collectionId) {
          $scope.canEdit = true;
        }
      });
    });
  }

  $scope.edit = function () {
    $scope.editItem = true;
  }

  $scope.close = function () {
    $scope.editItem = false;
  }

  $scope.$on("filesAddedNope", function (e, files) {
    console.log('ItemCtrl filesAdded', e, files);
    return;

    angular.forEach(files, function (file) {

      var alert = new Alert();
      alert.status = "Uploading";
      alert.progress = 1;
      alert.message = file.name;
      alert.add();

      $scope.item.addAudioFile(file).then(function(data) {
        $scope.item.audioFiles.push(data);
        $scope.addMessage({
          'type': 'success',
          'title': 'Congratulations!',
          'content': '"' + file.name + '" upload completed. <a data-dismiss="alert" data-target=":parent" href="' + $scope.item.link() + '">View and edit the item!</a>'
        });
        alert.progress = 100;
        alert.status = "Uploaded";

      }, function(data){
        $scope.addMessage({
          'type': 'error',
          'title': 'Oops...',
          'content': '"' + file.name + '" upload failed. Hmmm... try again?'
        });

        alert.progress = 100;
        alert.status = "Error";
      });

    });    
  });
}])
.controller('ItemFormCtrl', ['$scope', 'Schema', 'Item', function ($scope, Schema, Item) {

  $scope.item = {};
  $scope.$parent.$watch('item', function (is) {
    if (is && $scope.item != is) {
      angular.copy(is, $scope.item);
    }
  });

  $scope.fields = Schema.columns;
  // $scope.accessibleAttributes = Item.attrAccessible;

  $scope.submit = function () {
    if ($scope.item.id) {
      $scope.item.update().then(function (data) {
        angular.copy($scope.item, $scope.$parent.item);
        $scope.close();
      });
    } else {
      $scope.item.create().then(function (data) {
        if (angular.isFunction($scope.itemAdded)) {
          $scope.itemAdded($scope.item);
        }
        $scope.close();
      });
    }
  }
}]);
