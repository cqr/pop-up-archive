'use strict';

angular.module('analytics', []).provider('Analytics', function() {
  function createGaScriptTag() {
    var ga = document.createElement('script');
    ga.type = 'text/javascript';
    ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(ga, s);
  }

  var Analytics = [
    '$rootScope', '$window', 'account',
    function($rootScope, $window, account) {
      $window._gaq = $window._gaq || [];
      $window._gaq.push(['_setAccount', account]);

      this.trackPageview = function(path) {
        // console.log('ga', path);
        $window._gaq.push(['_trackPageview', path]);
      };
      
      createGaScriptTag();
    }
  ];

  this.$get = [
    '$injector',
    function($injector) {
      return $injector.instantiate(Analytics, {
        account: this.account
      });
    }
  ];
}).run([
  '$rootScope', '$routeParams', '$location', 'Analytics',
  function($rootScope, $routeParams, $location, Analytics) {

    var convertPathToQueryString = function(path, $routeParams) {
      for (var key in $routeParams) {
        var queryParam = '/' + $routeParams[key];
        path = path.replace(queryParam, '');
      }

      var querystring = decodeURIComponent($.param($routeParams));

      if (querystring === '') return path;

      return path + "?" + querystring;
    };

    $rootScope.$on('$viewContentLoaded', function() {
      var path = convertPathToQueryString($location.path(), $routeParams);
      // Analytics.trackPageview($location.path());
      Analytics.trackPageview(path);
    });
  }
]);
