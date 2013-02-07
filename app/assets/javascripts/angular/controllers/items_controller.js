(window.controllers = window.controllers || angular.module('Directory.controllers', []))
.controller('ItemsCtrl', [ '$scope', 'Item', function ItemsCtrl($scope, Item) {
  $scope.items = ($scope.items || []);

  Item.query().then(function (items) {
    $scope.items = items;
  });
}]);

