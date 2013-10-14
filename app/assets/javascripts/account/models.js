angular.module('Directory.account.models', [])
.factory('Plan', ['Model', function (Model) {
  return Model({url:'/api/plans', name: 'plan'})
}]);