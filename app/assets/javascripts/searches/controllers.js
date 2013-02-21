angular.module('Directory.searches.controllers', ['Directory.loader', 'Directory.searches.models'])
.controller('SearchCtrl', ['$scope', '$location', function ($scope, $location) {
  $scope.fetchResults = function (e) {
    $location.path('/search').search('query', $scope.search.query);
  }
}])
.controller('SearchResultsCtrl', ['$scope', 'Search', 'Loader', '$location', '$routeParams', function ($scope, Search, Loader, $location, $routeParams) {
  

  $scope.$watch(function () {
    return $location.search().query;
  }, function (is, was, scope) {
    if (was != is) {
      scope.search.query = $location.search().query;
      Loader(Search.query({query:is}), scope);
    }
  });

  $scope.nextPage = function () {
    $location.search('page', (parseInt($location.search().page) || 1) + 1);
    fetchPage();
  }

  $scope.backPage = function () {
    $location.search('page', (parseInt($location.search().page) || 2) - 1);
    fetchPage();
  }


  function fetchPage () {
    searchParams = {};
    if ($routeParams.contributorName) {
      searchParams['filters[contributor]'] = $routeParams.contributorName;
    }

    $scope.search = {query: $location.search().query, page: $location.search().page};
    if ($scope.search) {
      searchParams.query = $scope.search.query;
    }
    if ($scope.search.page) {
      searchParams.page = $scope.search.page;
    }

    Loader(Search.query(searchParams), $scope);
  }

  fetchPage();
}]);