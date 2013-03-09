angular.module('Directory.items.models', ['RailsModel'])
.factory('Item', ['Model', function (Model) {
  var Item = Model({url:'/api/items', name: 'item'});

  Item.prototype.getTitle = function () {
    if (this.title) { return this.title + (this.identifier ? ' ('+ this.identifier +')' : ''); }
    if (this.episodeTitle) { return this.episodeTitle + " : " + this.identifier; }
    if (this.seriesTitle) { return this.seriesTitle + " : " + this.identifier; }
  } 

  Item.prototype.getDescription = function () {
    if (this.description) { return this.description; }
    if (this.notes) { return this.notes; }
  }

  return Item;
}])
