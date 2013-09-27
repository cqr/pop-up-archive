angular.module('Directory.organizations.models', ['RailsModel'])
.factory('Organization', ['Model', function (Model) {
  var Organization = Model({url:'/api/organizations/{{id}}', name: 'organization', only: ['id', 'name', 'members']});

  return Organization;
}])
