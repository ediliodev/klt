class RondatsController < ApplicationController
  before_action :set_rondat, only: [:show, :edit, :update, :destroy]

  # GET /rondats
  # GET /rondats.json
  def index
    @rondats = Rondat.all
  end

  # GET /rondats/1
  # GET /rondats/1.json
  def show
  end

  # GET /rondats/new
  def new
    @rondat = Rondat.new
  end

  # GET /rondats/1/edit
  def edit
  end

  # POST /rondats
  # POST /rondats.json
  def create
    @rondat = Rondat.new(rondat_params)
    #sobreescribir valores de la calle, no necesito algunos params externo que puedar ser creados o modificados desde afuera. ok. provisional ok ted.
     @rondat.credito = 0    #resetar este valor externo.
     @rondat.cartucho = 0   #resetar este valor externo.
     @rondat.resultado = 0  # resetar este valor externo.

     if @rondat.posiciondisparo != 0
        @disparar_html = ''
       
     end

    redirect_to new_rondat_path and return

    # respond_to do |format|
    # if @rondat.save
    # format.html { redirect_to @rondat, notice: 'Rondat was successfully created.' }
    # format.json { render :show, status: :created, location: @rondat }
    # else
    # format.html { render :new }
    # format.json { render json: @rondat.errors, status: :unprocessable_entity }
    # end
    # end

  end


  # PATCH/PUT /rondats/1
  # PATCH/PUT /rondats/1.json
  def update
    respond_to do |format|
      if @rondat.update(rondat_params)
        format.html { redirect_to @rondat, notice: 'Rondat was successfully updated.' }
        format.json { render :show, status: :ok, location: @rondat }
      else
        format.html { render :edit }
        format.json { render json: @rondat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rondats/1
  # DELETE /rondats/1.json
  def destroy
    @rondat.destroy
    respond_to do |format|
      format.html { redirect_to rondats_url, notice: 'Rondat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rondat
      @rondat = Rondat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rondat_params
      params.require(:rondat).permit(:jugador, :credito, :cartucho, :posiciondisparo, :resultado)
    end
end
