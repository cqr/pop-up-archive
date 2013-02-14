angular.module('RailsUjs', [])
.directive('method', function () {
  return function(scope, el, attrs) {
    if (el[0].nodeName == "A" && attrs.method && attrs.target) {
      el.bind('click', function (e) {
        e.stopPropagation();
        e.preventDefault();
        var form = angular.element("<div style='display:none'><form action='" + attrs.href +
          "' method='POST'><input type='hidden' name='_method' value='" + attrs.method +
          "' ></form></div>")
        el.parent().append(form);
        form.children()[0].submit();
      });
    }
  }
});