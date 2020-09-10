require 'fcm'
module SalesmanPushHelper
  def push_options(type, id, title, body)
    {
        data: {type: type, id: id},
        notification: {
            title: title,
            body: body,
            sound: "default"},
        priority: 'high',
    }
  end

  def send_noti_salesman(salesman, options)
    fcm = FCM.new(ENV['FCM_API_KEY_SALESMAN'])
    registration_id = salesman.device_token
    fcm.send([registration_id], options) if registration_id
  end

  def send_noti_salesmen(salesmen, options)
    fcm = FCM.new(ENV['FCM_API_KEY_SALESMAN'])
    salesmen.each do |salesman|
      registration_id = salesman.device_token
      fcm.send([registration_id], options) if registration_id
    end
  end

end
