angular.module('Directory.users.models', ['RailsModel'])
.factory('User', ['Model', function (Model) {
  var User = Model({url:'/api/users', name: 'user'});

  User.prototype.authenticated = function (callback, errback) {
    var self = this;
    if (self.id) {
      if (callback) {
        callback(self);
      }

      return true;
    }

    if (errback) {
      errback(self);
    }
    
    return false;
  }

  User.prototype.canEdit = function (obj) {
    if (this.authenticated() && obj && obj.collectionId) {
      return (this.collectionIds.indexOf(obj.collectionId) > -1);
    } else {
      return false;
    }
  }

  User.prototype.canOrderTranscript = function (obj) {
    if (this.authenticated() && obj) {
      return (this.organizationId && (this.organizationId > 0));
    } else {
      return false;
    }
  }

  return User;
}])
