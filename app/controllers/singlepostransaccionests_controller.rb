class SinglepostransaccionestsController < ApplicationController
  before_action :set_singlepostransaccionest, only: [:show, :edit, :update, :destroy]

  # GET /singlepostransaccionests
  # GET /singlepostransaccionests.json
  def index
    @singlepostransaccionests = Singlepostransaccionest.all
  end

  # GET /singlepostransaccionests/1
  # GET /singlepostransaccionests/1.json
  def show
  end

  # GET /singlepostransaccionests/new
  def new
    @singlepostransaccionest = Singlepostransaccionest.new
  end

  # GET /singlepostransaccionests/1/edit
  def edit
  end

  # POST /singlepostransaccionests
  # POST /singlepostransaccionests.json
  def create
    @singlepostransaccionest = Singlepostransaccionest.new(singlepostransaccionest_params)

    respond_to do |format|
      if @singlepostransaccionest.save
        format.html { redirect_to @singlepostransaccionest, notice: 'Singlepostransaccionest was successfully created.' }
        format.json { render :show, status: :created, location: @singlepostransaccionest }
      else
        format.html { render :new }
        format.json { render json: @singlepostransaccionest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /singlepostransaccionests/1
  # PATCH/PUT /singlepostransaccionests/1.json
  def update
    respond_to do |format|
      if @singlepostransaccionest.update(singlepostransaccionest_params)
        format.html { redirect_to @singlepostransaccionest, notice: 'Singlepostransaccionest was successfully updated.' }
        format.json { render :show, status: :ok, location: @singlepostransaccionest }
      else
        format.html { render :edit }
        format.json { render json: @singlepostransaccionest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /singlepostransaccionests/1
  # DELETE /singlepostransaccionests/1.json
  def destroy
    @singlepostransaccionest.destroy
    respond_to do |format|
      format.html { redirect_to singlepostransaccionests_url, notice: 'Singlepostransaccionest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_singlepostransaccionest
      @singlepostransaccionest = Singlepostransaccionest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def singlepostransaccionest_params
      params.require(:singlepostransaccionest).permit(:creditin, :cashout)
    end
end
