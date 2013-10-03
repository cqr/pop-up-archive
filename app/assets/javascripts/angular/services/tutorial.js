angular.module('ngTutorial', [])
.factory('Tutorial', ['$rootScope', '$timeout', '$location', '$cookies', function ($rootScope, $timeout, $location, $cookies) {

  var Tutorial = function(name) {
    this.name = name;
    this.$currentStep = 0;
    this.delay = 1000;
    this.steps = [];
    this.template = "" + 
      "<div id='tutorial-{{tutorial.name}}-{{stepOptions.step}}' class='tutorial-step'>" +
        "<div class='arrow'></div>" +
        "<div class='tutorial-content' ng-bind-html-unsafe='stepOptions.content'></div>" +
        "<nav class='tutorial-navigation'>" +
          "<div class='btn-group'>" +
            "<button ng-disabled='!tutorial.canPrevious()'  ng-click='tutorial.showPreviousStep()' class='btn btn-info'>&laquo; Prev</button>" +
            "<button ng-disabled='!tutorial.canNext()' ng-click='tutorial.showNextStep()' class='btn btn-info'>Next &raquo;</button>" +
          "</div>" +
          "<button ng-click='tutorial.endTutorial()' class='btn btn-info pull-right'>End tutorial</button>" +
        "</nav>" +
      "</div>";
  }

  Tutorial.prototype.addStep = function(num, step) {

    // console.log('addStep', step);

    var self = this;
    var n = parseInt(num, 10);
    self.steps[n] = step;

    if (!step.name) {
      step.name = this.name + 'Step' + num;
    }

    // if this is the first step, show it
    if (n == 0) {
      $timeout(function(){ self.start(); }, this.delay);
    }
  };

  Tutorial.prototype.cookieName = function () {
    var self = this;
    var cookieName = self.name + 'TutorialCookie';
    return cookieName;
  };

  Tutorial.prototype.start = function () {
    var self = this;
    var cookie = $cookies[self.cookieName()];

    if (!cookie || cookie != 't') {
      self.$currentStep = 0;
      self.showStep(self.$currentStep);
    }

    // $timeout(function(){ self.showNextStep(); }, self.delay);
  };

  Tutorial.prototype.canNext = function () {
    var self = this;
    return (self.$currentStep < (self.steps.length - 1));
  };

  Tutorial.prototype.canPrevious = function () {
    var self = this;
    return (self.$currentStep > 0);
  };

  Tutorial.prototype.showNextStep = function () {
    var self = this;
    if (self.canNext()) {
      self.$currentStep = self.$currentStep + 1;
      $timeout(function(){ self.showStep(self.$currentStep); }, 10);
    }
  };

  Tutorial.prototype.showPreviousStep = function () {
    var self = this;
    if (self.canPrevious()) {
      self.$currentStep = self.$currentStep - 1;
      $timeout(function(){ self.showStep(self.$currentStep); }, 10);
    }
  };

  Tutorial.prototype.showStep = function(s) {
    angular.forEach(this.steps, function(step, index){
      if (index == s) {
        // console.log('show this step', step);
        step.scope().show();
        var stepElId = "tutorial-" + step.scope().tutorial.name + '-' + s; 

        setTimeout(function() {
          $('html, body').animate({
            scrollTop: ($('#'+stepElId).offset().top - 200)
          }, 1000);
        }, 10);

      } else {
        step.scope().hide();
      }
    });
  };

  Tutorial.prototype.endTutorial = function(s) {
    var self = this;
    $cookies[self.cookieName()] = 't';
    self.showStep(-1);
  };

  return Tutorial;
}])
.directive('ngTutorial', ['Tutorial', function(Tutorial) {
  return {
    restrict: 'A',
    scope: false,
    compile: function compile(tElement, tAttrs, transclude) {
      return {
        pre: function preLink(scope, elm, attrs, ctrl) {
          // console.log('ng-tutorial', scope, elm, attrs, ctrl);
          scope.tutorial = new Tutorial(attrs.ngTutorial);
        },
        post: function postLink(scope, elm, attrs, ctrl) { return; }
      }
    }
  };
}])
.directive('tutorialStep', [
  '$parse',
  '$compile',
  '$http',
  '$timeout',
  '$q',
  '$templateCache',
  function ($parse, $compile, $http, $timeout, $q, $templateCache) {
    'use strict';
    $('body').on('keyup', function (ev) {
      if (ev.keyCode === 27) {
        $('.popover.in').each(function () {
          $(this).popover('hide');
        });
      }
    });
    return {
      restrict: 'A',
      scope: true,
      link: function postLink(scope, element, attr, ctrl) {
        var getter = $parse(attr.tutorialStep), setter = getter.assign, value = getter(scope), options = {};
        if (angular.isObject(value)) {
          options = value;
        }

        $q.when(options.content || $templateCache.get(value) || $http.get(value, { cache: true })).then(function onSuccess(template) {

          // console.log('template', template);

          scope.tutorial.addStep(options.step, element);
          scope.stepOptions = options;

          if (angular.isObject(template)) {
            template = template.data;
          }
          if (!!attr.unique) {
            element.on('show', function (ev) {
              $('.popover.in').each(function () {
                var $this = $(this), popover = $this.data('popover');
                if (popover && !popover.$element.is(element)) {
                  $this.popover('hide');
                }
              });
            });
          }
          if (!!attr.hide) {
            scope.$watch(attr.hide, function (newValue, oldValue) {
              if (!!newValue) {
                popover.hide();
              } else if (newValue !== oldValue) {
                popover.show();
              }
            });
          }

          var tutorialHtml = scope.tutorial.template;

          element.popover(angular.extend({}, options, {
            trigger: 'manual',
            content: tutorialHtml,
            html: true
          }));

          var popover = element.data('popover');
          popover.hasContent = function () {
            return this.getTitle() || template;
          };
          popover.getPosition = function () {
            var r = $.fn.popover.Constructor.prototype.getPosition.apply(this, arguments);
            $compile(this.$tip)(scope);
            scope.$digest();
            this.$tip.data('popover', this);
            return r;
          };
          scope.$popover = function (name) {
            popover(name);
          };
          angular.forEach([
            'show',
            'hide'
          ], function (name) {
            scope[name] = function () {
              popover[name]();
            };
          });
          scope.dismiss = scope.hide;
          angular.forEach([
            'show',
            'shown',
            'hide',
            'hidden'
          ], function (name) {
            element.on(name, function (ev) {
              scope.$emit('tutorial-step-' + name, ev);
            });
          });
        });
      }
    };
  }
]);
