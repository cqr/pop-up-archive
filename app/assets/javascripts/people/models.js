angular.module('Directory.people.models', ['RailsModel'])
.factory('Person', ['Model', function (Model) {
  var Person = Model({url:'/api/collections/{{collectionId}}/people/{{id}}', name: 'person'});

  Person.attrAccessible = ['name'];

  Person.prototype.text = function () {
    return this.name;
  }

  return Person;
}])
.factory('Contribution', ['Model', function (Model) {
  var Contribution = Model({url:'/api/items/{{itemId}}/contributions/{{id}}', name: 'contribution', requestTransformers: ['set_person_id']});

  Contribution.attrAccessible = ['personId', 'role'];
  // Contribution.attrNested = ['person_id'];

  Contribution.prototype.text = function () {
    return this.name;
  }

  return Contribution;
}]);
