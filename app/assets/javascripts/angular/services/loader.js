angular.module('Directory.loader', ['ngLoadingIndicators'])
.factory('Loader', ['$q', 'loading', '$timeout', function ($q, loading, $timeout) {

 function camelize(key) {
    if (!angular.isString(key)) {
      return key;
    }
    return key.replace(/_[\w\d]/g, function (match, index, string) {
      return index === 0 ? match : string.charAt(index + 1).toUpperCase();
    });
  }

  function load () {
    var argumentsArray = Array.prototype.slice.call(arguments);
    var $scope         = argumentsArray.pop();
    argumentsArray.push(minimumDuration());

    return $q.all(argumentsArray).then(function (data) {
      angular.forEach(data, function (response) {
        if (angular.isArray(response) && response.length > 0) {
          $scope[camelize(response[0].constructor.rootPluralName)] = response;
        } else if (typeof response !== 'undefined') {
          $scope[camelize(response.constructor.rootName)] = response;
        }
      });
      return data;
    }, function (data) {
      console.error(data);
      return $q.reject(data);
    });

  }

  function minimumDuration () {
    return $timeout(angular.identity, 250);
  }

  function loadPage () {
    loading.page(true)
    return load.apply(this, arguments).then(function (data) {
      loading.page(false);
      return data;
    }, function (data) {
      loading.page(false);
      return $q.reject(data);
    });
  }

  var Loader = load;
  Loader.page = loadPage;

  return Loader;
}]);