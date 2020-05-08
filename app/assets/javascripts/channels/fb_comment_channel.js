App.order = App.cable.subscriptions.create("fb_comment_channel", {
    connected: function() {
        alert("connected");
    },
    disconnected: function() {},
    received: function(data) {
        alert(data)
    }
});