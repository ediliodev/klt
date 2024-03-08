class GanadoresmegajackpotsController < ApplicationController
  before_action :set_ganadoresmegajackpot, only: [:show, :edit, :update, :destroy]

  # GET /ganadoresmegajackpots
  # GET /ganadoresmegajackpots.json
  def index
    @ganadoresmegajackpots = Ganadoresmegajackpot.all.last(10).reverse # Mostrar ultimos 10 ganadores del Megajackpot ok.
  end

  # GET /ganadoresmegajackpots/1
  # GET /ganadoresmegajackpots/1.json
  def show
  end

  # GET /ganadoresmegajackpots/new
  def new
    @ganadoresmegajackpot = Ganadoresmegajackpot.new
  end

  # GET /ganadoresmegajackpots/1/edit
  def edit
  end

  # POST /ganadoresmegajackpots
  # POST /ganadoresmegajackpots.json
  def create
    render plain: "Admin only. Not allowed. Reported." and return # evitar cambios viael controlador web ok. ted.
    #    @ganadoresmegajackpot = Ganadoresmegajackpot.new(ganadoresmegajackpot_params)

    #    respond_to do |format|
    #      if @ganadoresmegajackpot.save
    #        format.html { redirect_to @ganadoresmegajackpot, notice: 'Ganadoresmegajackpot was successfully created.' }
    #        format.json { render :show, status: :created, location: @ganadoresmegajackpot }
    #      else
    #        format.html { render :new }
    #        format.json { render json: @ganadoresmegajackpot.errors, status: :unprocessable_entity }
    #      end
    #    end
  end

  # PATCH/PUT /ganadoresmegajackpots/1
  # PATCH/PUT /ganadoresmegajackpots/1.json
  def update
    render plain: "Admin only. Not allowed. Reported." and return # evitar cambios viael controlador web ok. ted.

  #  respond_to do |format|
  #    if @ganadoresmegajackpot.update(ganadoresmegajackpot_params)
  #      format.html { redirect_to @ganadoresmegajackpot, notice: 'Ganadoresmegajackpot was successfully updated.' }
  #      format.json { render :show, status: :ok, location: @ganadoresmegajackpot }
  #    else
  #      format.html { render :edit }
  #      format.json { render json: @ganadoresmegajackpot.errors, status: :unprocessable_entity }
  #    end
  #  end
  end

  # DELETE /ganadoresmegajackpots/1
  # DELETE /ganadoresmegajackpots/1.json
  def destroy
   # @ganadoresmegajackpot.destroy
   # respond_to do |format|
   #   format.html { redirect_to ganadoresmegajackpots_url, notice: 'Ganadoresmegajackpot was successfully destroyed.' }
   #   format.json { head :no_content }
   # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ganadoresmegajackpot
      @ganadoresmegajackpot = Ganadoresmegajackpot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ganadoresmegajackpot_params
      params.require(:ganadoresmegajackpot).permit(:fecha, :consorcio, :sucursal, :localidad, :serialmq, :cantidad, :montoxcontribuyente)
    end
end
