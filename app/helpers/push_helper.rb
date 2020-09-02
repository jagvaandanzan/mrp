require 'fcm'
module PushHelper

  def send_notification(user, options)
    fcm = FCM.new(ENV['FCM_API_KEY'])
    registration_id = user.device_token
    fcm.send([registration_id], options) if registration_id
  end

  def send_notifications(users, options)
    fcm = FCM.new(ENV['FCM_API_KEY'])
    users.each do |user|
      registration_id = user.device_token
      fcm.send([registration_id], options) if registration_id
    end
  end

end
