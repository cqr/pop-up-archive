angular.module('Directory.user', ['Directory.loader', 'Directory.users.models'])
.factory('Me', ['$q', '$timeout', 'Loader', 'User', function ($q, $timeout, Loader, User) {
  var Me = Loader(User.get('me')).then(function(data) {
    Me.authenticated = data.authenticated;

    data.authenticated.apply(data, Me.authenticatedParams);

    return data;
  });

  Me.authenticated = function () {
    this.authenticatedParams = Array.prototype.slice.call(arguments);
  }

  return Me;
}]);
