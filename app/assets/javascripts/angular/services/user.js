angular.module('Directory.user', ['Directory.loader', 'Directory.users.models'])
.factory('Me', ['$q', '$timeout', 'Loader', 'User', '$rootScope', function ($q, $timeout, Loader, User, $rootScope) {
  var currentUser;

  var Me = Loader(User.get('me')).then( function (user) {
    console.log('Me - user loaded');
    currentUser = user;
    $rootScope.currentUser = user;
    Me.authenticated.apply(Me, Me.authenticatedParams);
    return currentUser;
  });

  Me.authenticated = function () {
    console.log('Me.authenticated - called');
    var argsArray = Array.prototype.slice.call(arguments);
    if (currentUser) {
      console.log('Me.authenticated - apply!');
      currentUser.authenticated.apply(currentUser, argsArray);
    } else {
      console.log('Me.authenticated - no currentUser');
      this.authenticatedParams = argsArray;  
    }
  }


  return Me;
}]);
