angular.module('RailsModel', ['rails'])
.factory('Model', ['railsResourceFactory', '$q', '$rootScope', function (railsResourceFactory, $q, $rootScope) {
  var requestTransformers =  'protectedAttributeRemovalTransformer updateParentNestedValue railsRootWrappingTransformer railsFieldRenamingTransformer'.split(' ');
  return function (options) {

    var idMap = {"__identity": options.name};
    var queryCache = {"__identity": options.name};

    function objectForData(klass, data) {
      var result;
      if (typeof data.id !== 'undefined') {
        if (typeof idMap[data.id] != 'undefined') {
          result = idMap[data.id];
        } else {
          result = new klass();
          idMap[data.id] = result;
        }
      } else {
        result = new klass();
      }
      return angular.extend(result, data);
    }


    options.requestTransformers = requestTransformers;
    options.responseInterceptors = ['railsFieldRenamingInterceptor', 'railsRootWrappingInterceptor', [function () {
      return function (promise) {
        var RailsResource = promise.resource;
        promise.resource.processResponse = function (promise) {
          promise = RailsResource.callInterceptors(promise);
          return promise.then(function (response) {
            var result;
            if (angular.isArray(response.data)) {
              result = [];
              angular.forEach(response.data, function (value) {
                result.push(objectForData(RailsResource, value));
              });
            } else if (angular.isObject(response.data)) {
              result = objectForData(RailsResource, response.data);
            } else {
              result = response.data;
            }
            return result;
          });
        };
        return promise;
      }
    }]];

    var factory = railsResourceFactory(options);
    var originalUpdate = factory.prototype.update;
    var originalCreate = factory.prototype.create;
    var originalRemove = factory.prototype.remove;

    factory.prototype.update = function () {
      this.isSaving = true;
      return originalUpdate.apply(this, arguments).then(function(data) { data.isSaving = false });
    }

    factory.prototype.create = function () {
      this.isSaving = true;
      return originalCreate.apply(this, arguments).then(function(data) { data.isSaving = false });
    }

    factory.prototype.remove = function () {
      this.isSaving = true;
      return originalRemove.apply(this, arguments).then(function(data) { data.isSaving = false });
    }

    factory.get = function (context, queryParams) {
      var result;
      if (angular.isNumber(context)) {
        if (typeof idMap[context] !== 'undefined') {
          result = idMap[context];
        }
      } else if (angular.isNumber(context.id)) {
        if (typeof idMap[context.id] !== 'undefined') {
          result = idMap[context.id];
        }
      }

      if (typeof result !== 'undefined') {
        var deferred = $q.defer();
        deferred.resolve(result);
        factory.$get(factory.resourceUrl(context), queryParams).then(function (data) {
          angular.extend(result, data);
        });
        return deferred.promise;
      } else {
        return factory.query(queryParams, context);
      }
    };

    factory.query = function (queryParams, context) {
      queryParams = queryParams || {};
      context = context || {};
      var hash = JSON.stringify([queryParams, context]);

      var result = factory.$get(factory.resourceUrl(context), queryParams).then(function (data) {
        if (typeof queryCache[hash] == 'undefined') {
          queryCache[hash] = data;
        } else {
           if (angular.isArray(data)) {
            var array = queryCache[hash];
            var loc = -1;
            angular.forEach(data, function (obj, index) {
              loc = array.indexOf(obj);
              if (loc !== -1 && loc !== index) {
                array.splice(loc, 1);
                loc = -1;
              }
              if (loc == -1) {
                array.splice(index, 0, obj);
              }
            });
            array.length = data.length;
          } else {
            angular.forEach(data, function (value, key) {
              queryCache[hash][key] = value;
            });
          }
        }
        if(!$rootScope.$$phase) {
          $rootScope.$digest();
        }
        return queryCache[hash];
      });

      if (typeof queryCache[hash] !== 'undefined') {
        var deferred = $q.defer();
        deferred.resolve(queryCache[hash]);
        result = deferred.promise;
      }

      return result;
    }

    return factory;
  }
}])
.factory('updateParentNestedValue', [function () {
  return function (data, resource) {
    if (resource.attrNested && resource.attrNested.length && resource.attrNested.length > 0) {
      for (index in resource.attrNested) {
        var key = resource.attrNested[index];
        var attrVals = key.split('_');
        if (attrVals.length == 2) {
          var nestedAttr = data[attrVals[0]][attrVals[1]];
          data[key] = nestedAttr;          
        }
      }
    }
    return data;
  }
}])
.factory('protectedAttributeRemovalTransformer', [function () {
  return function (data, resource) {
    var obj = data;
    if (resource.attrAccessible && resource.attrAccessible.length && resource.attrAccessible.length > 0) {
      obj = {};
      for (index in resource.attrAccessible) {
        var key = resource.attrAccessible[index];
        var val = data[key.replace(/Attributes$/, '')];
        if (typeof val !== 'undefined' && val != null && !(angular.isArray(val) && !val.length)) {
          obj[key] = val;
        }
      }
    }
    return obj;
  }
}]);
