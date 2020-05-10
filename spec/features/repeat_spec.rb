# rspec spec/features/repeat_spec.rb
require 'rails_helper'
describe "repeat any", type: :feature do
  it "repeating ..." do
    http_request_repeats = HttpRequestRepeat.all
    http_request_repeats.each {|req|
      alert, msg = ApplicationController.helpers.fb_send_response(req.url, req.method, 'success', req.param.presence || :nil)
      if alert == :success
        req.destroy!
      end
    }

  end
end

