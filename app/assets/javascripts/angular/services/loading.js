(function () {

  /* Probably a better way to do this, but not that I could think of.
   * Chris Rhoden 2013 for PRX and Pop Up Archive.
   */

  var $realRootScope, actuallyIsLoading = 0, pretendLoading = 0, pageLoadings = 0;

  function loading (val) {
    if (val === true) {
      pretendLoading += 1;
    } else if (val === false) {
      pretendLoading -=1;
      if (pretendLoading < 0) pretendLoading = 0;
    } else {
      return (actuallyIsLoading || pretendLoading);
    }
  }

  function pageLoading (val) {
    if (val === true) {
      pageLoadings += 1;
    } else if (val === false) {
      pageLoadings -= 1;
      if (pageLoadings < 0) pageLoadings = 0;
    } else {
      return !!pageLoadings;
    }
  }

  angular.module('ngLoadingIndicators', [])
  .config(['$httpProvider', function ($httpProvider) {
    $httpProvider.responseInterceptors.push('myHttpInterceptor');
    function setIsLoading (data, headersGetter) {
      actuallyIsLoading += 1;
      return data;
    };
    $httpProvider.defaults.transformRequest.push(setIsLoading);
  }])
  .factory('myHttpInterceptor', ['$q', '$rootScope', function ($q, $rootScope) {
    if (typeof $rootScope.setIsLoading === 'undefined') {
      $realRootScope = $rootScope;
      $rootScope.loading = loading;
      $rootScope.pageLoading = pageLoading;
    }

    return function (promise) {
      return promise.then(function (response) {
        actuallyIsLoading -= 1;
        if (actuallyIsLoading < 0) actuallyIsLoading = 0;
        return response;
      }, function (response) {
        actuallyIsLoading -= 1;
        if (actuallyIsLoading < 0) actuallyIsLoading = 0;
        return $q.reject(response);
      });
    };
  }])
  .factory('loading', function() {
    function maskedLoading (val) {
      return loading(val);
    }

    maskedLoading.page = function (val) {
      return pageLoading(val);
    }
    
    return maskedLoading;
  });
}());

