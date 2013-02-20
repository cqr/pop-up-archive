angular.module('Directory.items.models', ['RailsModel'])
.factory('Item', ['Model', function (Model) {
  var Item = Model({url:'/api/items', name: 'item'});

  return Item;
}])
