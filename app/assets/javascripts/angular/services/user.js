angular.module('Directory.user', ['Directory.loader', 'Directory.users.models'])
.run(['$route', 'Me', '$q', '$rootScope', '$injector', function ($route, Me, $q, $rootScope, $injector, undefined) {
  var loggedIn = $q.defer(),
      currentUserDeferred = $q.defer();
      meRequired = $q.defer(),
      currentUser = undefined;

  Me.then(userLoaded, userLoadError);

  function userLoaded(user) {
    if (typeof currentUser === 'undefined') {
      currentUserDeferred.resolve(currentUser = user);
    }
    if (user.id) {
      loggedIn.resolve(true);
      meRequired.resolve(currentUser);
    } else {
      loggedIn.resolve(false);
      meRequired.reject('loginFailed');
    }
  }

  function userLoadError() {
    loggedIn.resolve(false);
    meRequired.reject('loginFailed');
  }

  function loggedInPromise() {
    return loggedIn.promise;
  }

  function loginRequiredUserPromise() {
    return meRequired.promise;
  }

  function currentUserPromise() {
    return currentUserDeferred.promise;
  }

  $rootScope.$on('$routeChangeError', function (event, route, previous, error) {
    if (error === 'loginFailed') {
      window.location = "/users/sign_in";
    }
  });

  $rootScope.$on('$routeChangeStart', function () {
    Me.then(userLoaded, userLoadError);
  });

  angular.forEach($route.routes, function (routePlan) {
    routePlan.resolve = routePlan.resolve || {};
    routePlan.resolve.loggedIn = loggedInPromise;
    if (routePlan.loginRequired) {
      routePlan.resolve.currentUser = loginRequiredUserPromise;
    } else {
      routePlan.resolve.currentUser = currentUserPromise;
    }
    if (typeof routePlan.controller !== 'undefined') {
      try {
        angular.extend(routePlan.resolve, $injector.get(routePlan.controller + "Resolutions"));
      } catch (error) {}
    }
  });
}])
.factory('Me', ['$q', '$timeout', 'Loader', 'User', '$rootScope', function ($q, $timeout, Loader, User, $rootScope) {
  var currentUser;
  var authenticatedParams = [];

  var Me = Loader(User.get('me', {timestamp: new Date()})).then(function (user) {
    currentUser = user;
    $rootScope.currentUser = user;

    var authArgsArray;
    while (authArgsArray = authenticatedParams.pop()) {
      Me.authenticated.apply(Me, authArgsArray);
    }

    return currentUser;
  });

  Me.authenticated = function () {
    var argsArray = Array.prototype.slice.call(arguments);
    if (currentUser) {
      currentUser.authenticated.apply(currentUser, argsArray);
    } else {
      authenticatedParams.push(argsArray);
    }
  }

  return Me;
}]);
