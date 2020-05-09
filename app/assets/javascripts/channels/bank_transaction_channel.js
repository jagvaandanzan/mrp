App.order = App.cable.subscriptions.create("BankTransactionChannel", {
    connected: function () {
    },
    disconnected: function () {
    },
    received: function (data) {
        var tbody = $('tbody#bank_transaction_index');
        if (tbody !== undefined) {
            tbody.prepend(data['bank_transaction']);
            tbody.scrollTop(0);
        }
    }
});