class HistorypostransaccionestsController < ApplicationController
  before_action :set_historypostransaccionest, only: [:show, :edit, :update, :destroy]

  # GET /historypostransaccionests
  # GET /historypostransaccionests.json
  def index
    # @historypostransaccionests = Historypostransaccionest.all
    # Consultar Historual ultimas 25 transaccioens de credit/pago para mostrar:
    @historypostransaccionests = Historypostransaccionest.last(25).reverse
  end

  # GET /historypostransaccionests/1
  # GET /historypostransaccionests/1.json
  def show
  end

  # GET /historypostransaccionests/new
  def new
    @historypostransaccionest = Historypostransaccionest.new
  end

  # GET /historypostransaccionests/1/edit
  def edit
    #Redireccionar esta accion, evitar modificaciones via web, ok. El edit redireccionar al index ok.
    redirect_to historypostransaccionests_path  and return
  end

  # POST /historypostransaccionests
  # POST /historypostransaccionests.json
  def create
    @historypostransaccionest = Historypostransaccionest.new(historypostransaccionest_params)

    respond_to do |format|
      if @historypostransaccionest.save
        format.html { redirect_to @historypostransaccionest, notice: 'Historypostransaccionest was successfully created.' }
        format.json { render :show, status: :created, location: @historypostransaccionest }
      else
        format.html { render :new }
        format.json { render json: @historypostransaccionest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /historypostransaccionests/1
  # PATCH/PUT /historypostransaccionests/1.json
  def update
    #Redireccionar esta accion, evitar modificaciones via web, ok.
    redirect_to historypostransaccionests_path  and return

    respond_to do |format|
      if @historypostransaccionest.update(historypostransaccionest_params)
        format.html { redirect_to @historypostransaccionest, notice: 'Historypostransaccionest was successfully updated.' }
        format.json { render :show, status: :ok, location: @historypostransaccionest }
      else
        format.html { render :edit }
        format.json { render json: @historypostransaccionest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /historypostransaccionests/1
  # DELETE /historypostransaccionests/1.json
  def destroy
    #Redireccionar esta accion, evitar modificaciones via web, ok.
    redirect_to historypostransaccionests_path and return

    @historypostransaccionest.destroy
    respond_to do |format|
      format.html { redirect_to historypostransaccionests_url, notice: 'Historypostransaccionest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_historypostransaccionest
      @historypostransaccionest = Historypostransaccionest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def historypostransaccionest_params
      params.require(:historypostransaccionest).permit(:creditin, :cashout)
    end
end
