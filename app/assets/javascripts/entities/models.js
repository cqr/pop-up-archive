angular.module('Directory.entities.models', ['RailsModel'])
.factory('Entity', ['Model', function (Model) {
  var Entity = Model({url:'/api/items/{{itemId}}/entities/{{id}}', name: 'entity', only: ['isConfirmed', 'score']});

  // Entity.attrAccessible = ['isConfirmed', 'score'];

  return Entity;
}]);