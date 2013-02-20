// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require_tree .
//= require angular
//= require ui-bootstrap-tpls
//= require angularjs/rails/resource
//= require_tree ../

if(window.location.hash=="#_=_"){window.location.hash = ""}

;(function() {

  function applicationConfig($httpProvider, $locationProvider, $routeProvider) {

    // Add our CSRF stuff to all our requests by default
    var metaTags = document.getElementsByTagName('meta'), token = "";
    angular.forEach(metaTags, function(element) {
      element = angular.element(element);
      if (element.attr('name') == 'csrf-token') {
        token = element.attr('content');
      }
    });

    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token;

    // Set up routing
    $locationProvider.html5Mode(true);

    $routeProvider
    .when('/', {
      templateUrl: "/assets/items/index.html",
      controller: "ItemsCtrl"
    })
    .when('/collections', {
      templateUrl: "/assets/collections/index.html",
      controller: "CollectionsCtrl"
    })
    .when('/collections/:collectionId', {
      templateUrl: "/assets/collections/show.html",
      controller: "CollectionCtrl"
    })
    .when('/imports', {
      templateUrl: "/assets/imports/index.html",
      controller: "ImportsCtrl"
    })
    .when('/search', {
      templateUrl: "/assets/search/index.html",
      controller: "SearchCtrl",
      reloadOnSearch: false
    })
    .when('/imports/:importId', {
      templateUrl: "/assets/imports/show.html",
      controller: "ImportCtrl"
    })
    .otherwise({
      template: "<h1>404 - not found</h1>"
    })

  }

  applicationConfig.$inject = ["$httpProvider", "$locationProvider", "$routeProvider"];

  var depends =  ['ui.bootstrap',
                  'RailsUjs',
                  'Directory.files.controllers',
                  'Directory.csvImport.controllers',
                  'Directory.searches.controllers',
                  'Directory.items.controllers',
                  'Directory.collections.controllers'];

  window.directory = angular.module('Directory', depends);
  window.directory.config(applicationConfig);

}());
