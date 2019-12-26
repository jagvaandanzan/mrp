// app/assets/javascripts/channels/call_service.js

//= require cable
//= require_self
//= require_tree .

this.App = {};

App.cable = ActionCable.createConsumer();