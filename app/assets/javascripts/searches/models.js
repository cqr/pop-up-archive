angular.module('Directory.searches.models', ['RailsModel', 'Directory.items.models'])
.factory('Search', ['Model', 'Item', 'Facet',  function (Model, Item, Facet) {
  var Search = Model({url:'/api/search', name: 'search'});

  Search.prototype.resultsAsItems = function () {
    if (typeof this.itemsResults !== 'undefined') {
      return this.itemsResults;
    }
    
    this.itemsResults = [];

    angular.forEach(this.results, function (result) {
      this.itemsResults.push(new Item(result));
    }, this);

    return this.itemsResults;
  }

  Search.prototype.lastItemNumber = function () {
    return Math.min(this.page * 25, this.totalHits);
  }

  Search.prototype.firstItemNumber = function () {
    return Math.max((this.page-1)*25 + 1, 1);
  }

  Search.prototype.hasMoreResults = function () {
    return (this.lastItemNumber() < this.totalHits);
  }

  Search.prototype.facetsAsObjects = function () {
    if (typeof this._facetObjects !== 'undefined') {
      return this._facetObjects;
    }

    this._facetObjects = [];
    angular.forEach(this.facets, function (facet, name) {
      this.push(new Facet(name, facet));
    }, this._facetObjects);

    return this._facetObjects;
  }

  return Search;
}])
.factory('Facet', function() {
  function FacetEntry(name, count, field) {
    this.name = name;
    this.count = count;
    this.field = field;
  }

  function Facet(name, options) {
    this.name    = name;
    this.type    = options._type;
    this.data    = options;
  }

  Facet.prototype.visible = function () {
    return (this._entries && this._entries.length > 1);
  }

  Facet.prototype.entries = function () {
    if (typeof this._entries !== 'undefined') {
      return this._entries;
    }
    this._entries = [];

    var name = this.name;
    switch (this.type) {
    case "terms":
      angular.forEach(this.data.terms, function (term) {
        this.push(new FacetEntry(term.term, term.count, name));
      }, this._entries);
    }

    return this._entries;
  }

  return Facet;
});
