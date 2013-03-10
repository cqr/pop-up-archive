angular.module('Directory.items.controllers', ['Directory.loader', 'Directory.user', 'Directory.items.models'])
.controller('ItemsCtrl', [ '$scope', 'Item', 'Loader', 'Me', function ItemsCtrl($scope, Item, Loader, Me) {
  Me.authenticated(function (data) {
    $scope.items = Loader.page(Item.query(), 'Items');
  });
}])
.controller('ItemCtrl', ['$scope', 'Item', 'Loader', '$routeParams', function ItemCtrl($scope, Item, Loader, $routeParams) {

  if ($routeParams.id) {
    Loader.page(Item.get({collectionId:$routeParams.collectionId, id: $routeParams.id}), 'Item/'+$routeParams.id, $scope);
  }

  $scope.edit = function () {
    $scope.editItem = true;
  }

  $scope.close = function () {
    $scope.editItem = false;
  }
}])
.controller('ItemFormCtrl', ['$scope', 'Schema', function ($scope, Schema) {
  $scope.item = {};
  $scope.$parent.$watch('item', function (is) {
    if (is && $scope.item != is) {
      angular.copy(is, $scope.item);
    }
  });
  $scope.fields = Schema.columns;

  $scope.submit = function () {
    if ($scope.item.id) {
      $scope.item.update().then(function (data) {
        angular.copy($scope.item, $scope.$parent.item);
        $scope.close();
      });
    } else {
      $scope.item.create().then(function (data) {
        $scope.close();
      });
    }
  }
}]);
