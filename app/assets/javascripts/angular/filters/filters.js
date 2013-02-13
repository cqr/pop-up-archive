angular.module('Directory.filters', ['Directory.models'])
.filter('type', ['Schema', function(Schema) {
  return function (inputs, cond) {
    if (typeof cond == 'undefined' || cond == null || cond == '' || cond == '*') {
      return inputs;
    }
    var things = [];
    angular.forEach(inputs, function (thing) {
      var type;
      if (type = Schema.types.get(thing.typeId)) {
        if (type.name == cond) {
          things.push(thing);
        }
      } else {
        things.push(thing);
      }
    });
    return things;
  };
}])
.filter('schemaMapped', ['Schema', function(Schema) {
  return function (columns, mapping) {
    var things = [];
    angular.forEach(columns, function(column) {
      if (Schema.isMapped(column, mapping)) {
        things.push(column);
      }
    });
    return things;
  }
}])
.filter('isExtraField', ['Schema', function(Schema) {
  return function isExtraField (headers, mapping) {
    if (mapping) {
      var things = [];
      angular.forEach(mapping, function (mapping, index) {
        var match  = false;
        angular.forEach(Schema.columns, function (column) {
          if (column.name == mapping.column) match = true;
        })
        if (!match) things.push(headers[index]);
      });
      return things;
    } else {
      return headers;
    }
  }
}]);