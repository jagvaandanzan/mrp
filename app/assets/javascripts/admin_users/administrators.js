$(document).ready(function() {
  $('#modal-admin-user-delete').on('show.bs.modal', function(e) {
    var adminId = $(e.relatedTarget).data('admin-user-id');
    var el = $(e.currentTarget).find('#admin-user-delete-link');
    var newLink = el.attr('href').replace('0', adminId);
    el.attr('href', newLink);
  });

  $('#admin-user-delete-link').on('ajax:success', function(e) {
    if (e.originalEvent.detail[0].status == 'ok') {
      window.location.reload();
    }
  }).on('ajax:error', function(e) {
    window.location.reload();
  });

});
