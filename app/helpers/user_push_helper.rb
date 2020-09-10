require 'fcm'
module UserPushHelper

  def send_noti_user(user, options)
    fcm = FCM.new(ENV['FCM_API_KEY_USER'])
    registration_id = user.device_token
    fcm.send([registration_id], options) if registration_id
  end

  def send_noti_users(users, options)
    fcm = FCM.new(ENV['FCM_API_KEY_USER'])
    users.each do |user|
      registration_id = user.device_token
      fcm.send([registration_id], options) if registration_id
    end
  end

end
