class Operators::BonusController < Operators::BaseController
  load_and_authorize_resource
  before_action :set_bonus, only: [:edit, :update, :destroy]

  def index
    @phone = params[:phone]
    @min = params[:min]
    @max = params[:max]
    @bonus = Bonu.search(@phone, @min, @max).page(params[:page])
    cookies[:bonus_page_number] = params[:page]
  end

  def new
  end

  def create
    @bonu = Bonu.new(bonus_params)

    if @bonu.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @bonu.attributes = bonus_params
    if @bonu.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @bonu.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_bonus
    @bonu = Bonu.find(params[:id])
  end

  def bonus_params
    params.require(:bonu)
        .permit(:balance,
                bonus_phones_attributes: [:id, :phone, :_destroy])
  end
end
