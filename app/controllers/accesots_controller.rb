class AccesotsController < ApplicationController
  
  http_basic_authenticate_with name: "admin", password: "64738"
  #http_basic_authenticate_with name: Localidadt.last.id.to_s, password: Localidadt.last.id.to_s
  before_action :set_accesot, only: [:show, :edit, :update, :destroy]

  # GET /accesots
  # GET /accesots.json
  def index
    @accesots = Accesot.all.last(50) # Muestra los ultimmos 50 accesos recientes del sistema. ok.
  end

  # GET /accesots/1
  # GET /accesots/1.json
  def show
  end

  # GET /accesots/new
  def new
    
     if verificar_violacion_simple
      render plain: 'Locked System. Contact support.' #comando Ruleta de Luis.
    end

    @accesot = Accesot.new
  end

  # GET /accesots/1/edit
  def edit
    redirect_to accesots_url and return # arbitratio, ted no permitir editar. ok.
  end

  # POST /accesots
  # POST /accesots.json
  def create
    redirect_to accesots_url and return# arbitratio, ted no permitir crear desde la web panel ok. ok.
   # @accesot = Accesot.new(accesot_params)

   # respond_to do |format|
   #   if @accesot.save
   #     format.html { redirect_to @accesot, notice: 'Accesot was successfully created.' }
   #     format.json { render :show, status: :created, location: @accesot }
   #   else
   #     format.html { render :new }
   #     format.json { render json: @accesot.errors, status: :unprocessable_entity }
   #   end
    #end
  end

  # PATCH/PUT /accesots/1
  # PATCH/PUT /accesots/1.json
  def update
    respond_to do |format|
      if @accesot.update(accesot_params)
        format.html { redirect_to @accesot, notice: 'Accesot was successfully updated.' }
        format.json { render :show, status: :ok, location: @accesot }
      else
        format.html { render :edit }
        format.json { render json: @accesot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accesots/1
  # DELETE /accesots/1.json
  def destroy
   # @accesot.destroy
   # respond_to do |format|
   #   format.html { redirect_to accesots_url, notice: 'Accesot was successfully destroyed.' }
   #   format.json { head :no_content }
   # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_accesot
      @accesot = Accesot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def accesot_params
      params.require(:accesot).permit(:usuario, :tipoacceso, :fechayhora, :ip)
    end
end
