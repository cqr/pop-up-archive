angular.module('Directory.loader', [])
.service('Loader', ['$q', function ($q) {

 function camelize(key) {
    if (!angular.isString(key)) {
      return key;
    }

    // should this match more than word and digit characters?
    return key.replace(/_[\w\d]/g, function (match, index, string) {
      return index === 0 ? match : string.charAt(index + 1).toUpperCase();
    });
  }

  function load () {
    var argumentsArray = Array.prototype.slice.call(arguments);
    var $scope         = argumentsArray.pop();

    return $q.all(argumentsArray).then(function (data) {
      angular.forEach(data, function (response) {
        if (angular.isArray(response)) {
          $scope[camelize(response[0].constructor.rootPluralName)] = response;
        } else {
          $scope[camelize(response.constructor.rootName)] = response;
        }
      });
      return data;
    });

  };

  function loadPage () {
    var $scope = arguments[arguments.length-1];
    $scope.pageLoading(true);
    return load.apply(this, arguments).then(function(data) {
      $scope.pageLoading(false);
    });
  }

  return {load: load, loadPage: loadPage};
}]);