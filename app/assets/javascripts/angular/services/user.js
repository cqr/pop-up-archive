angular.module('Directory.user', ['Directory.loader', 'Directory.users.models'])
.factory('Me', ['$q', '$timeout', 'Loader', 'User', function ($q, $timeout, Loader, User) {
  var currentUser;

  var Me = Loader(User.get('me')).then(function(user) {
    currentUser = user;
    Me.authenticated.apply(Me, Me.authenticatedParams);
    return currentUser;
  });

  Me.authenticated = function () {
    var argsArray = Array.prototype.slice.call(arguments);
    if (currentUser) {
      currentUser.authenticated.apply(currentUser, argsArray);
    } else {
      this.authenticatedParams = argsArray;  
    }
  }


  return Me;
}]);
