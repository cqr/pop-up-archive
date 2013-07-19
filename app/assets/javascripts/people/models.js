angular.module('Directory.people.models', ['RailsModel'])
.factory('Person', ['Model', function (Model) {
  var Person = Model({url:'/api/collections/{{collectionId}}/people/{{id}}', name: 'person', only: ['name']});

  Person.prototype.text = function () {
    return this.name;
  }

  return Person;
}])
.factory('Contribution', ['Model', function (Model) {
  var Contribution = Model({url:'/api/items/{{itemId}}/contributions/{{id}}', name: 'contribution', only: ['personId', 'role']});

  Contribution.prototype.text = function () {
    return this.name;
  }

  return Contribution;
}]);
