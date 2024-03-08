class ContadorestsController < ApplicationController
  before_action :set_contadorest, only: [:show, :edit, :update, :destroy]

  # GET /contadorests
  # GET /contadorests.json
  def index
    @contadorests = Contadorest.all
  end

  # GET /contadorests/1
  # GET /contadorests/1.json
  def show
  end

  # GET /contadorests/new
  def new
    @contadorest = Contadorest.new
  end

  # GET /contadorests/1/edit
  def edit
  end

  # POST /contadorests
  # POST /contadorests.json
  def create
    @contadorest = Contadorest.new(contadorest_params)

    respond_to do |format|
      if @contadorest.save
        format.html { redirect_to @contadorest, notice: 'Contadorest was successfully created.' }
        format.json { render :show, status: :created, location: @contadorest }
      else
        format.html { render :new }
        format.json { render json: @contadorest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contadorests/1
  # PATCH/PUT /contadorests/1.json
  def update
    respond_to do |format|
      if @contadorest.update(contadorest_params)
        format.html { redirect_to @contadorest, notice: 'Contadorest was successfully updated.' }
        format.json { render :show, status: :ok, location: @contadorest }
      else
        format.html { render :edit }
        format.json { render json: @contadorest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contadorests/1
  # DELETE /contadorests/1.json
  def destroy
    @contadorest.destroy
    respond_to do |format|
      format.html { redirect_to contadorests_url, notice: 'Contadorest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contadorest
      @contadorest = Contadorest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contadorest_params
      params.require(:contadorest).permit(:totalin, :totalout, :totalnet)
    end
end
