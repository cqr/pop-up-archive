angular.module('Directory.organizations.controllers', ['Directory.loader', 'Directory.user', 'Directory.organizations.models'])
.controller('OrganizationCtrl', ['$scope', 'Organization', 'Loader', 'Me', function OrganizationCtrl($scope, Organization, Loader, Me) {

  Me.authenticated(function (me) {
    Loader.page(Organization.get(me.organization.id), 'Organization', $scope).then(function (data) {
    });
  });

}]);
