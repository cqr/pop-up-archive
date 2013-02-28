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
    return Math.min((this.page-1)*25 + 1, this.totalHits);
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

  Search.prototype.aFacetIsVisible = function () {
    var aFacetIsVisible = false;
    angular.forEach(this.facetsAsObjects(), function (facet) {
      if (facet.visible()) 
        aFacetIsVisible = true;
    });
    return aFacetIsVisible;
  }

  return Search;
}])
.factory('Facet', function () {
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
})
.factory('Query', ['$location', function ($location) {
  function getSearchFromQueryString (queryString) {
    if (typeof queryString !== 'undefined' && queryString !== null) {
      if (angular.isArray(queryString)) {
        return queryString;
      }
      var match = queryString.match(/('(?:[^']|\\')+'|"(?:[^"]|\\")+"|[^,]+)/g);
      if (match) {
        return match;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  function Query (queryString) {
    if (angular.isArray(queryString)) {
      this.queryParts = queryString;
      this.updateQueryString();
    } else if (angular.isString(queryString)) {
      this.queryString = queryString;
      this.updateQueryParts();
    } else if (typeof queryString !== 'undefined') {
      var query = Query(queryString.query);
      if (queryString.onQueryBuilt) {
        queryString.onQueryBuilt(query);
      }
      return query;
    } else {
      this.queryString = "";
      this.updateQueryParts();
    }
    this.string = "";
  }

  Query.prototype.updateQueryParts = function () {
    this.queryParts = getSearchFromQueryString(this.queryString);
  }

  Query.prototype.updateQueryString = function () {
    this.queryString = this.queryParts.join(",");
    if (this.queryString == '') {
      this.queryString = null;
    }
  }

  Query.prototype.commit = function () {
    if (this.string && this.string != '') {
      this.queryParts.push(this.string);
      this.string = "";
      this.perform();
    }
  }

  Query.prototype.add = function (thing) {
    this.queryParts.push(thing);
    this.perform();
  } 

  Query.prototype.remove = function (thing) {
    this.queryParts.splice(this.queryParts.indexOf(thing), 1);
    this.perform();
  }

  Query.prototype.perform = function () {
      this.updateQueryString();
      $location.search('page', 1);
      $location.search('query', this.queryString);
  }

  Query.prototype.toSearchQuery = function () {
    var string = this.queryParts.join(" AND ");
    if (string == '') {
      return null;
    }
    return string;
  }

  return Query;
}]);
