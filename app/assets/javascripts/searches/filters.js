angular.module("Directory.searches.filters", [])
.filter('withoutFieldname', function() {
  return function (text) {
    return text.replace(/\w+:/,'');
  }
})
.filter('highlightMatches', function() {
  var ary = [];
  return function (obj, matcher) {
    if (matcher && matcher.length) {
      var regex = new RegExp("(\\w*" + matcher + "\\w*)", 'ig');
      ary.length = 0;
      angular.forEach(obj, function (object) {
        if (object.text.match(regex)) {
          ary.push(angular.copy(object));
          ary[ary.length-1].text = object.text.replace(regex, "<em>$1</em>");
        }
      });
      if (ary.length == 0) {
        return obj;
      }
      return ary;
    } else  {
      return obj;
    }
  }
});