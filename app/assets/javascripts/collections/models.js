angular.module('Directory.collections.models', ['RailsModel'])
.factory('Collection', ['Model', function (Model) {
  var Collection = Model({url:'/api/collections', name: 'collection'});
  Collection.attrAccessible = ['title', 'description', 'itemsVisibleByDefault'];
  
  return Collection;
}])