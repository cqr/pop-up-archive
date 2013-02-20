angular.module('Directory.searches.models', ['RailsModel'])
.factory('Search', ['Model', function (Model) {
  var Search = Model({url:'/api/search', name: 'search'});

  return Search;
}])
