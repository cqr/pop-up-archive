(window.controllers = window.controllers || angular.module('Directory.controllers', []))
.controller('ItemsCtrl', [ '$scope', 'Item', function ItemsCtrl($scope, Item) {
  $scope.items = ($scope.items || JSON.parse(localStorage['popUpItems']) || []);

  Item.query().then(function (items) {
    $scope.items = items;
    localStorage['popUpItems'] = JSON.stringify(items);
  });
}]);

