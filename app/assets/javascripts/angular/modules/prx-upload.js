// angular.module('prxUpload', [])
//   .directive('prxUploadDropzone', function() {
//     var delegate;

//     return {
//       restrict: 'A',
//       scope: {},
//       compile: function(tElement, tAttrs, transclude) {
//         if (tAttrs.prxUploadDropzone && tAttrs.prxUploadDropzone != '') {
//           delegate = angular.element(tAttrs.prxUploadDropzone);
//         };

//         return function(scope, element, attrs) {
//           console.log(element);
//           element.bind('dragenter', function() { delegate.triggerHandler('dragenter'); });
//           element.bind('dragover', function() { delegate.triggerHandler('dragover'); });
//           element.bind('dragleave', function() { delegate.triggerHandler('dragleave'); });
//           element.bind('drop', function() { delegate.triggerHandler('drop'); });
//         }
//       }
//     }
//   })
//   .directive('prxUploadDropzoneDelegate', function() {
//     return {
//       restrict: 'A',
//       scope: {},
//       compile: function(tElement, tAttrs, transclude) {
//         return function(scope, element, attrs) {
//           function _dragenter (e) {
//             console.log('drop');
//             e.stopPropagation();
//             e.preventDefault();
//           }

//           function _dragover (e) {
//             console.log('drop');
//             e.stopPropagation();
//             e.preventDefault();
//           }

//           function _dragleave (e) {
//             console.log(e);
//             e.stopPropagation();
//             e.preventDefault();
//           }

//           function _drop (e) {
//             e.stopPropagation();
//             e.preventDefault();

//             // console.log('drop');

//             // if (!scope.uploads) {
//             //   scope.uploads = [];
//             // }

//             // angular.forEach(e.originalEvent.dataTransfer.files, function(file) {
//             //   scope.uploads.push(file);
//             // })
//             // console.log(scope.uploads);

//             // scope.$digest();
//           }

//           element.bind('dragenter', _dragenter);
//           element.bind('dragover', _dragover);
//           element.bind('dragleave', _dragleave);
//           element.bind('drop', _drop);
//         }
//       }
//     }
//   });



angular.module('prxUpload', []).directive('prxUploadDropzone', function() {
  return function(scope, element, attrs) {
    var modalIsVisible = false;
    var dragleaveCount = 0;

    function _dragenter (e) {
      e.stopPropagation();
      e.preventDefault();

      if (!modalIsVisible) {
        angular.element('.dropperModal').first().modal('show');
        dragleaveCount = 0;
        modalIsVisible = true;
      }
    }

    function _dragover (e) {
      e.stopPropagation();
      e.preventDefault();
    }

    function _dragleave (e) {
      e.stopPropagation();
      e.preventDefault();

      dragleaveCount = dragleaveCount + 1;

      if (modalIsVisible  && dragleaveCount > 1) {
        angular.element('.dropperModal').first().modal('hide');
        modalIsVisible = false;
      }
    }

    function _drop (e) {
      e.stopPropagation();
      e.preventDefault();

      if (!scope.uploads) {
        scope.uploads = [];
      }

      angular.forEach(e.originalEvent.dataTransfer.files, function(file) {
        scope.uploads.push(file);
      })

      scope.$digest();
    }

    element.bind('dragenter', _dragenter);
    element.bind('dragover', _dragover);
    element.bind('dragleave', _dragleave);
    element.bind('drop', _drop);
  }
})
