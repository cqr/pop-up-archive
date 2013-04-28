angular.module('Directory.users.models', ['RailsModel'])
.factory('User', ['Model', function (Model) {
  var User = Model({url:'/api/users', name: 'user'});

  User.prototype.authenticated = function (callback) {
    if (!!this.id) {
      if (callback) {
        callback(this);
      }

      return true;
    }

    return false;
  }

  User.prototype.canEdit = function (obj) {
    if (this.authenticated && obj && obj.collectionId) {
      return (this.collectionIds.indexOf(obj.collectionId) > -1);
    } else {
      return false;
    }
  }

  return User;
}])
