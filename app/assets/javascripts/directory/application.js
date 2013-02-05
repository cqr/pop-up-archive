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
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require bootstrap
//= require angular
//= require_tree ../angular

// require angle-up THIS IS BROKEN

;(function() {

  function applicationConfig($httpProvider, $locationProvider, $routeProvider) {

    // Add our CSRF stuff to all our requests by default
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');

    // Set up routing
    $locationProvider.html5Mode(true);

    $routeProvider.when('/', {
      templateUrl: "items",
      controller: "ItemsCtrl"
    }).when('/collections', {
      templateUrl: "collections",
      controller: "CollectionsCtrl"
    }).when('/collections/:collectionId', {
      templateUrl: "collection",
      controller: "CollectionCtrl"
    })
    .when('/imports/:importId', {
      templateUrl: "import",
      controller: "ImportCtrl"
    })
    .otherwise({
      template: "<h1>404 - not found</h1>"
    })

  }

  window.directory = angular.module('Directory', ['ngResource', 'fileDropzone', 'Directory.controllers', 'Directory.models', 'Directory.filters']);
  window.directory.config(["$httpProvider", "$locationProvider", "$routeProvider", applicationConfig]);

}());
