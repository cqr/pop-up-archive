angular.module('Directory.filters', ['Directory.models'])
.filter('type', ['Schema', function(Schema) {
  return function(inputs, cond) {
    if (typeof cond == 'undefined' || cond == '') {
      return inputs;
    }
    var things = [];
    angular.forEach(inputs, function(thing) {
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
}]);