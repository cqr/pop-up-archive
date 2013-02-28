angular.module("Directory.searches.filters", [])
.filter('withoutFieldname', function() {
  return function (text) {
    return text.replace(/\w+:/,'');
  }
})