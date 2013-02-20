angular.module('Directory.searches.controllers', ['Directory.loader', 'Directory.searches.models'])
.controller('SearchCtrl', ['$scope', '$location', function ($scope, $location) {
  $scope.fetchResults = function (e) {
    $location.path('/search').search('query', $scope.search.query);
  }
}])
.controller('SearchResultsCtrl', ['$scope', 'Search', 'Loader', '$location', function ($scope, Search, Loader, $location) {
  
  $scope.search = {query: $location.search().query};
  Loader.page(Search.query({query:$scope.search.query}), $scope);

  $scope.$watch(function () {
    return $location.search().query;
  }, function (is, was, scope) {
    if (was != is) {
      scope.search.query = $location.search().query;
      Loader(Search.query({query:is}), scope);
    }
  });
}]);