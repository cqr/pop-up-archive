;(function(){
angular.module('Directory.collections.models', ['RailsModel'])
.factory('Collection', ['Model', 'Item', function (Model, Item) {
  var Collection = Model({url:'/api/collections/{{id}}', name: 'collection'});
  var PublicCollection = Model({url:'/api/collections/public', name:'collection'});
  Collection.public = function () {
    return PublicCollection.query.apply(PublicCollection, arguments);
  }

  Collection.prototype.fetchItems = function () {
    var self = this;
    return Item.get({collectionId: this.id}).then(function (items) {
      self.items = items;
      return self;
    });
  }

  Collection.attrAccessible = ['title', 'description', 'itemsVisibleByDefault'];

  return Collection;
}])
.filter('publicCollections', function () {
  return buildCollectionFilter(true);
})
.filter('privateCollections', function() {
  return buildCollectionFilter(false);
})
.filter('notUploads', ['Me', function (Me) {
  var user = {};
  Me.authenticated(function (currentUser) {
    user = currentUser;
  });
  return function (collections) {
    var c = [];
    if (angular.isArray(collections)) {
      angular.forEach(collections, function (collection, index) {
        if (collection.id != user.uploadsCollectionId) {
          c.push(collection);
        }
      });
      return c;
    } else {
      return collections;
    }
  };
}]);

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