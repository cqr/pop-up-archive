angular.module('Directory.collections.models', ['RailsModel'])
.factory('Collection', ['Model', function (Model) {
  var Collection = Model({url:'/api/collections/{{id}}', name: 'collection'});
  var PublicCollection = Model({url:'/api/collections/public', name:'collection'});
  Collection.public = function () {
    return PublicCollection.query.apply(PublicCollection, arguments);
  }

  Collection.attrAccessible = ['title', 'description', 'itemsVisibleByDefault'];

  return Collection;
}]);