angular.module('RailsUjs', [])
.directive('method', ['$compile', function ($compile) {

  var template = $compile("<form style='display:none' action='{{formInfo.href}}' target='{{formInfo.target}}'><input type='hidden' name='_method' value='{{formInfo.method}}'></form>");

  return function(scope, el, attrs) {

    scope.formInfo = attrs;
    var form;

    template(scope, function(formElement) {
        form = angular.element(formElement);
        form.attr('method', "POST");
        el.append(form);
    });

    el.bind('click', function (e) {
      e.stopPropagation();
      e.preventDefault();
      form.submit();
    });

  }
}]);
