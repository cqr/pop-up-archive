;(function(){
angular.module('Directory.collections.models', ['RailsModel'])
.factory('Collection', ['Model', function (Model) {
  var Collection = Model({url:'/api/collections/{{id}}', name: 'collection'});
  var PublicCollection = Model({url:'/api/collections/public', name:'collection'});
  Collection.public = function () {
    return PublicCollection.query.apply(PublicCollection, arguments);
  }

  Collection.attrAccessible = ['title', 'description', 'itemsVisibleByDefault'];

  return Collection;
}])
.filter('publicCollections', function () {
  return buildCollectionFilter(true);
})
.filter('privateCollections', function() {
  return buildCollectionFilter(false);
});

function buildCollectionFilter(visible) {
  return function(collections) {
    if (angular.isArray(collections)) {
      var publicCollections = [];
      angular.forEach(collections, function(collection) {
        if (collection.itemsVisibleByDefault == visible) {
          publicCollections.push(collection);
        }
      });
      return publicCollections
    } else {
      return collections;
    }
  };
}
})();