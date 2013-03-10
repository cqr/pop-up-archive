angular.module('RailsModel', ['rails'])
.factory('Model', ['railsResourceFactory', function (railsResourceFactory) {
  var requestTransformers =  'protectedAttributeRemovalTransformer railsRootWrappingTransformer railsFieldRenamingTransformer'.split(' ');
  return function (options) {
    options.requestTransformers = requestTransformers;
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

    return factory;
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