angular.module('fileDropzone', [])
.directive('fileDropzone', ['$compile','$parse', function ($compile, $parse) {
    var overlayTemplateLinker;
    function linker(scope, element, attrs) {
            var parentScope = scope,
                scope = scope.$root.$new(true),
                overlay;
            scope.overlayText = attrs.dropzoneContent;
            scope.files = parentScope.$eval(attrs.fileDropzone);
            scope.overlayVisible = false;
            scope.overlayStyle = {
                width: '100%',
                height: '100%',
                background: 'rgba(0,0,0,0.8)',
                position: 'absolute',
                top: '0px',
                left: '0px',
                textAlign: 'center',
                color: '#FFF'
            };
            scope.overlayContainerStyle = {
                width: '100%',
                height: '0px',
                overflow: 'hidden',
                position: 'absolute',
                top: '0px',
                left: '0px'
            }

            overlayTemplateLinker(scope, function(overlayElement) {
                overlay = angular.element(overlayElement.children()[0]);
                element.append(overlayElement);
            });

            attrs.$observe('dropzoneContent', function (text) {
                if (typeof text !== 'undefined') {
                   scope.overlayText = text;
                } else {
                    scope.overlayText = "Drop file here to upload.";
                }
            });

            parentScope.$watch(attrs.fileDropzone, function (val) {
                if (typeof val === 'undefined') {
                    parentScope[attrs.fileDropzone] = [];
                    scope.files = [];
                } else {
                    scope.files = val;
                }
            });

            scope.$watch('files', function (val) {

            });

            if (element.css('position') == 'static') element.css({'position':'relative'});

            function _showOverlay(e) {
                stopEvent(e);
                scope.$apply(function (scope) {
                    scope.overlayContainerStyle.height = "100%";
                    scope.overlayVisible = true;
                });
            }

            function _hideOverlay(e) {
                stopEvent(e);
                scope.$apply(function (scope) {
                    scope.overlayContainerStyle.height = "0px";
                    scope.overlayVisible = false;
                });
            }

            function _drop(e) {
                _hideOverlay(e);
                var files = [];
                angular.forEach(e.dataTransfer.files, function (file) {
                    files.push(file);
                });
                scope.$apply(function (scope) {
                    $parse(attrs.fileDropzone).assign(parentScope, files);
                });
            }

            function stopEvent(e) {
                if (e) {
                    if (e.stopPropagation) e.stopPropagation();
                    if (e.preventDefault) e.preventDefault();
                }
            }

            element.bind('dragenter', _showOverlay);
            element.bind('dragover', _showOverlay);
            overlay.bind('dragleave', _hideOverlay);
            element.bind('drop', _drop);
        }
    return {
        compile: function () {
            overlayTemplateLinker = $compile("<div ng-style='overlayContainerStyle'><div ng-class='{in:overlayVisible}' class='fade file-drop-zone-overlay' ng-style='overlayStyle'>{{overlayText}}</div></div>");
            return linker;
        }
    };
}]);
