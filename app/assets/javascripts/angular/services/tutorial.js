angular.module('ngTutorial', [])
.factory('Tutorial', ['$rootScope', '$timeout', function ($rootScope, $timeout) {

  function Tutorial() {
    this.currentStep = 0;
    this.delay = 1000;
    this.steps = [];
  }

  Tutorial.prototype = {
    start: function() {
      var step = this.steps[currentStep];
    }
  }

  return Tutorial;
}])
.directive('tutorialOrder', ['Tutorial', function(Tutorial) {
  return {
    restrict: 'A',
    scope: false,
    link: function (scope, el, attrs) {
      console.log('tutorial-step', scope, el, attrs, scope.tutorial);
    }
  };
}]);
