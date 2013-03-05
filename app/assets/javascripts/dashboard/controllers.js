angular.module('Directory.dashboard.controllers', ['Directory.loader', 'Directory.user'])
.controller('DashboardCtrl', [ '$scope', 'Item', 'Loader', 'Me', function ItemsCtrl($scope, Item, Loader, Me) {
  Me.authenticated(function (data) {
  });
}])
