(function () {
  var $realRootScope;
  angular.module('Directory.loading', [])
  .config(['$httpProvider', function ($httpProvider) {
    $httpProvider.responseInterceptors.push('myHttpInterceptor');
    function setIsLoading (data, headersGetter) {
      $realRootScope.actuallyIsLoading = true;
      return data;
    };
    $httpProvider.defaults.transformRequest.push(setIsLoading);
  }])
  .factory('myHttpInterceptor', ['$q', '$rootScope', function ($q, $rootScope) {
    $realRootScope = $rootScope;
    return function (promise) {
      return promise.then(function (response) {
        $rootScope.actuallyIsLoading = false;
        return response;
      }, function (response) {
        $rootScope.actuallyIsLoading = false;
        return $q.reject(response);
      });
    };
  }]);
}());

