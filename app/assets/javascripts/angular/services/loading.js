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
    if (typeof $rootScope.setIsLoading === 'undefined') {
      $realRootScope = $rootScope;
      $rootScope.pretendLoading = 0;
      $rootScope.loading = function (val) {
        if (val === true) {
          $rootScope.pretendLoading += 1;
        } else if (val === false) {
          $rootScope.pretendLoading -=1;
          if ($rootScope.pretendLoading < 0) $rootScope.pretendLoading = 0;
        } else {
          return ($rootScope.actuallyIsLoading || $rootScope.pretendLoading);
        }
      }
      $rootScope.pageLoadings = 0;
      $rootScope.pageLoading = function (val) {
        if (val === true) {
          $rootScope.pageLoadings += 1;
        } else if (val === false) {
          $rootScope.pageLoadings -= 1;
          if ($rootScope.pageLoadings < 0) $rootScope.pageLoadings = 0;
        } else {
          return !!$rootScope.pageLoadings;
        }
      }
    }
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

