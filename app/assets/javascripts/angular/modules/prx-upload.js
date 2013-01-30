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
