angular.module('Directory.searches.controllers', ['Directory.loader', 'Directory.searches.models', 'Directory.searches.filters', 'Directory.collections.models'])
.controller('SearchCtrl', ['$scope', '$location', 'Query', function ($scope, $location, Query) {
  $scope.location = $location;
  $scope.$watch('location.search().query', function (search) {
    $scope.query = new Query(search);
  });
}])
.controller('SearchResultsCtrl', ['$scope', 'Search', 'Loader', '$location', '$routeParams', 'Query', 'Collection', function ($scope, Search, Loader, $location, $routeParams, Query, Collection) {
  $scope.location = $location;
  
  $scope.$watch('location.search().query', function (searchquery) {
    $scope.query = new Query(searchquery);
    console.log($scope.query);
    fetchPage();
  });

  $scope.nextPage = function () {
    $location.search('page', (parseInt($location.search().page) || 1) + 1);
    fetchPage();
  }

  $scope.backPage = function () {
    $location.search('page', (parseInt($location.search().page) || 2) - 1);
    fetchPage();
  }


  $scope.addSearchFilter = function (filter) {
    $scope.query.add(filter.field+":"+'"'+filter.name+'"');
  }

  function fetchPage () {
    searchParams = {};

    if ($routeParams.contributorName) {
      searchParams['filters[contributor]'] = $routeParams.contributorName;
    }

    if (typeof $routeParams.collectionId !== 'undefined') {
      searchParams['filters[collection_id]'] = $routeParams.collectionId;
    }

    if ($scope.query) {
      searchParams.query = $scope.query.toSearchQuery();
    }
    searchParams.page = $location.search().page;

    if (!$scope.search) {
      $scope.search = Loader.page(Search.query(searchParams));
    } else {
      Loader(Search.query(searchParams), $scope);
    }
  }
}]);