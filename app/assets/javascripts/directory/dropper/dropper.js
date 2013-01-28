function Dropper(target, modal) {
  this.node = target;
  this.modal = modal;
  this.acceptableFiles = [];

  this.initialize = function() {
    this.node.addEventListener('dragenter', this.dragenter, false);
    this.node.addEventListener('dragover', this.dragover, false);
    this.node.addEventListener('dragleave', this.dragleave, false);
    this.node.addEventListener('drop', this.drop, false);

    $('button.upload', this.modal).click(this.upload);
  }

  this.upload = function() {
    if (this.acceptableFiles.length > 0) {
      $('.progress', this.modal).show();
    };
  }

  this.dragenter = function(e) {
    e.stopPropagation();
    e.preventDefault();
    if (!this.modalIsVisible) {
      modal.modal('show')
      this.dragleaveCount = 0;
      this.modalIsVisible = true;
    };
  }
  this.dragover = function(e) {
    e.stopPropagation();
    e.preventDefault();
  }
  this.dragleave = function(e) {
    e.stopPropagation();
    e.preventDefault();
    this.dragleaveCount = this.dragleaveCount + 1;

    if (this.modalIsVisible && this.dragleaveCount > 1) {
      this.modalIsVisible = false;
      modal.modal('hide')
    };
  }
  this.drop = function(e) {
    e.stopPropagation();
    e.preventDefault();

    var files = e.dataTransfer.files;
    var acceptableFiles = [];

    $.each(files, function (i, file) {
      if (file.type == 'text/csv') {
        acceptableFiles.push(file);
      };
    });

    this.acceptableFiles = acceptableFiles;

    if (acceptableFiles.length > 0) {
      $('.no-files', this.modal).hide();
    } else {
      $('.no-files', this.modal).show();
    }

    $('ol.files', this.modal).empty();
    $.each(acceptableFiles, function(i, file) {
      $('ol.files', this.modal).append("<li>" + file.name + "</li>");
    });
  }
}
