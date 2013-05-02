angular.module('Directory.people.models', ['RailsModel'])
.factory('Person', ['Model', function (Model) {
  var Person = Model({url:'/api/collections/{{collectionId}}/people/{{id}}', name: 'person'});

  Person.attrAccessible = ['name'];

  Person.prototype.text = function () {
    return this.name;
  }

  return Person;
}]);