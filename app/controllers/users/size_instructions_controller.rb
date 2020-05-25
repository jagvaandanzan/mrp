class Users::SizeInstructionsController < Users::BaseController
  load_and_authorize_resource
  before_action :set_size_instruction, only: [:edit, :update, :destroy]

  def index
    @size_instruction = params[:size_instruction]
    @size_instructions = SizeInstruction.search(@size_instruction).page(params[:page])
    cookies[:size_instruction_page_number] = params[:page]
  end

  def new
    @size_instruction = SizeInstruction.new
    @size_instruction.queue = SizeInstruction.all.count
  end

  def create
    @size_instruction = SizeInstruction.new(size_instruction_params)

    if @size_instruction.save
      flash[:success] = t('alert.saved_successfully')
      redirect_to action: :index
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @size_instruction.attributes = size_instruction_params
    if @size_instruction.save
      flash[:success] = t('alert.info_updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def destroy
    @size_instruction.destroy!

    flash[:success] = t('alert.deleted_successfully')
    redirect_to action: :index
  end

  private

  def set_size_instruction
    @size_instruction = SizeInstruction.find(params[:id])
  end

  def size_instruction_params
    params.require(:size_instruction).permit(:queue, :instruction)
  end
end
