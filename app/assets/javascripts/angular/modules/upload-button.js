angular.module('fileButton', [])
.directive('fileButton', ['$timeout', function ($timeout) {
  return {
    link: function(scope, element, attributes) {

      var el = angular.element(element);
      var button = angular.element(el.children()[0]);

      el.css({
        position: 'relative',
        overflow: 'hidden'
      });

      button.bind('mouseover', function (event) {                
        el.css({
          display: 'inline-block',
          width: button[0].offsetWidth,
          height: button[0].offsetHeight
        });
      });

      var fileInput = angular.element('<input type="file" multiple />');
      fileInput.css({
        position: 'absolute',
        top: 0,
        left: 0,
        'z-index': '2',
        marginTop: '0px',
        padding: '0',
        width: '100%',
        height: '100%',
        opacity: '0',
        cursor: 'pointer'
      });

      fileInput.bind('change', function() {
        scope.setFiles(fileInput);
        fileInput[0].value = "";
      });

      el.append(fileInput);
    }
  }
}]);
