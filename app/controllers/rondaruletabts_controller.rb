class RondaruletabtsController < ApplicationController
  before_action :set_rondaruletabt, only: [:show, :edit, :update, :destroy]

  # GET /rondaruletabts
  # GET /rondaruletabts.json
  def index
  #  @rondaruletabts = Rondaruletabt.all
  end

  # GET /rondaruletabts/1
  # GET /rondaruletabts/1.json
  def show
  end

  # GET /rondaruletabts/new
  def new
    @rondaruletabt = Rondaruletabt.new
  end

  # GET /rondaruletabts/1/edit
  def edit
  end

  # POST /rondaruletabts
  # POST /rondaruletabts.json
  def create
    @rondaruletabt = Rondaruletabt.new(rondaruletabt_params)

    respond_to do |format|
      if @rondaruletabt.save
        format.html { redirect_to @rondaruletabt, notice: 'Rondaruletabt was successfully created.' }
        format.json { render :show, status: :created, location: @rondaruletabt }
      else
        format.html { render :new }
        format.json { render json: @rondaruletabt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rondaruletabts/1
  # PATCH/PUT /rondaruletabts/1.json
  def update
    respond_to do |format|
      if @rondaruletabt.update(rondaruletabt_params)
        format.html { redirect_to @rondaruletabt, notice: 'Rondaruletabt was successfully updated.' }
        format.json { render :show, status: :ok, location: @rondaruletabt }
      else
        format.html { render :edit }
        format.json { render json: @rondaruletabt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rondaruletabts/1
  # DELETE /rondaruletabts/1.json
  def destroy
    @rondaruletabt.destroy
    respond_to do |format|
      format.html { redirect_to rondaruletabts_url, notice: 'Rondaruletabt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rondaruletabt
      @rondaruletabt = Rondaruletabt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rondaruletabt_params
      params.require(:rondaruletabt).permit(:jugador, :win, :credit, :jugadas, :totalbet, :winnernumberspin, :status)
    end
end
