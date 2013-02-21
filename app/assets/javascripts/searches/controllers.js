angular.module('Directory.searches.controllers', ['Directory.loader', 'Directory.searches.models'])
.controller('SearchCtrl', ['$scope', '$location', function ($scope, $location) {
  $scope.fetchResults = function (e) {
    $location.path('/search').search('query', $scope.search.query);
  }
}])
.controller('SearchResultsCtrl', ['$scope', 'Search', 'Loader', '$location', '$routeParams', function ($scope, Search, Loader, $location, $routeParams) {
  searchParams = {};
  if ($routeParams.contributorName) {
    searchParams['filters[contributor]'] = $routeParams.contributorName;
  }

  $scope.search = {query: $location.search().query};
  if ($scope.search) {
    searchParams.query = $scope.search.query;
  }

  $scope.search = Loader.page(Search.query(searchParams));

  $scope.$watch(function () {
    return $location.search().query;
  }, function (is, was, scope) {
    if (was != is) {
      scope.search.query = $location.search().query;
      Loader(Search.query({query:is}), scope);
    }
  });
}]);