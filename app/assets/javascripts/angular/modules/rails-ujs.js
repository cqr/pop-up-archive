angular.module('RailsUjs', [])
.directive('method', function () {
  return function(scope, el, attrs) {
    if (el[0].nodeName == "A" && attrs.method && attrs.target) {
      el.bind('click', function (e) {
        e.stopPropagation();
        e.preventDefault();

        angular.element("<form target='" + attrs.href +
          "' method='POST'><input type='hidden' name='_method' value='" + attrs.method +
          "' ></form>")[0].submit();
      });
    }
  }
});