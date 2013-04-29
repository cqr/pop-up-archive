angular.module('Directory.items.controllers', ['Directory.loader', 'Directory.user', 'Directory.items.models', 'Directory.entities.models'])
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', 'Me', function ItemsCtrl($scope, Item, Loader, Me) {
  Me.authenticated(function (data) {
    if ($scope.collectionId) {
      $scope.items = Loader.page(Item.query(), 'Items');
    }
  });

  $scope.startUpload = function() {
    var newFiles = [];
    $scope.$emit('filesAdded', newFiles);
  }

}])
.controller('ItemCtrl', ['$scope', 'Item', 'Loader', 'Me', '$routeParams', 'Collection', 'Entity', function ItemCtrl($scope, Item, Loader, Me, $routeParams, Collection, Entity) {

  $scope.canEdit = false;

  if ($routeParams.id) {
    Loader.page(Item.get({collectionId:$routeParams.collectionId, id: $routeParams.id}), Collection.query(), 'Item/'+$routeParams.id, $scope).then(function (datum) {
      angular.forEach($scope.collections, function (collection) {
        if (collection.id == $scope.item.collectionId) {
          $scope.canEdit = true;
        }
      });
    });
  }

  $scope.deleteEntity = function(entity) {
    console.log('deleteEntity', entity);
    var e = new Entity(entity);
    e.itemId = $scope.item.id;
    e.deleting = true;
    e.delete().then(function() {
      $scope.item.entities.splice($scope.item.entities.indexOf(entity), 1);
    });
  }

  $scope.confirmEntity = function(entity) {
    console.log('confirmEntity', entity);
    entity.itemId = $scope.item.id;
    entity.isConfirmed = true;
    var entity = new Entity(entity);
    entity.update();
  }

}])
.controller('ItemFormCtrl', ['$scope', 'Schema', 'Item', function ($scope, Schema, Item) {

  $scope.item = {};
  $scope.itemTags = [];

  if ($scope.$parent.item) {
    angular.copy($scope.$parent.item, $scope.item);
    angular.forEach($scope.item.tags, function(v,k){ this.push({id:v, text:v}); }, $scope.itemTags);
  }

  $scope.fields = Schema.columns;

  $scope.tagSelect = {
    width: '220px',
    tags:[],
    initSelection: function (element, callback) { 
      callback($scope.itemTags);
    }
  };

  $scope.$parent.$watch('item', function (is) {
    if (is && $scope.item != is) {
      angular.copy(is, $scope.item);
      $scope.itemTags = [];
      angular.forEach($scope.item.tags, function(v,k){ this.push({id:v, text:v}); }, $scope.itemTags);
    }
  });

  $scope.submit = function () {

    var cleanTags = [];
    angular.forEach($scope.itemTags, function(v,k){ this.push(v.id); }, cleanTags);
    $scope.item.tags = cleanTags;
    
    if ($scope.item.id) {
      $scope.item.update().then(function (data) {
        angular.copy($scope.item, $scope.$parent.item);
        // $scope.close();
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
