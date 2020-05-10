App.order = App.cable.subscriptions.create("FbCommentChannel", {
    connected: function () {
    },
    disconnected: function () {
    },
    received: function (data) {
        var tbody = $('tbody#fb_comment_index');
        if (tbody !== undefined) {
            if (data['destroy'] !== undefined) {
                tbody.find('tr#comment'+data['destroy']).remove();
            } else {
                tbody.prepend(data['comment']);
                tbody.scrollTop(0);
            }
        }
    }
});