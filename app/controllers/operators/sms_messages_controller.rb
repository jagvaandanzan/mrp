class Operators::SmsMessagesController < Operators::BaseController
  load_and_authorize_resource
  before_action :set_sms_message, only: [:edit]

  def index
    @recipient = params[:recipient]
    @amount = params[:amount]
    @date = if params[:date].present?
              params[:date].to_time
            else
              Time.now.beginning_of_day
            end
    @sms_messages = SmsMessage.search(@recipient, @amount, @date).page(params[:page])
    cookies[:sms_message_page_number] = params[:page]
  end


  def new
    @sms_message = SmsMessage.new
  end

  def create
    @sms_message = SmsMessage.new(sms_message_params)

    if @sms_message.valid?

      response = ApplicationController.helpers.api_send("http://web2sms.skytel.mn/apiSend?token=#{ENV['SKYTEL_SMS']}&sendto=#{@sms_message.recipient}&message=#{@sms_message.full_message}", 'post')
      Rails.logger.info("web2sms=> #{response.code.to_s} => #{response.body.to_s}")
      if response.code.to_i == 200

        json = JSON.parse(response.body)
        if json["status"] == 1
          @sms_message.save
          flash[:success] = t('alert.saved_successfully')
          redirect_to action: :index
        else
          @sms_message.errors.add(:recipient, ": мессеж явсангүй!")
          render 'new'
        end
      end

    else
      logger.info(@sms_message.errors.full_messages)
      render 'new'
    end

  end

  def edit
  end

  private

  def set_sms_message
    @sms_message = SmsMessage.find(params[:id])
  end

  def sms_message_params
    params.require(:sms_message).permit(:recipient, :amount)
        .merge(:operator => current_operator)
  end

end
