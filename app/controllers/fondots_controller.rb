class FondotsController < ApplicationController
  before_action :set_fondot, only: [:show, :edit, :update, :destroy]

  # GET /fondots
  # GET /fondots.json
  def index
    @fondots = Fondot.all
  end

  # GET /fondots/1
  # GET /fondots/1.json
  def show
  end

  # GET /fondots/new
  def new
    @fondot = Fondot.new
  end

  # GET /fondots/1/edit
  def edit
  end

  # POST /fondots
  # POST /fondots.json
  def create
    @fondot = Fondot.new(fondot_params)

    respond_to do |format|
      if @fondot.save
        format.html { redirect_to @fondot, notice: 'Fondot was successfully created.' }
        format.json { render :show, status: :created, location: @fondot }
      else
        format.html { render :new }
        format.json { render json: @fondot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fondots/1
  # PATCH/PUT /fondots/1.json
  def update
    respond_to do |format|
      if @fondot.update(fondot_params)
        format.html { redirect_to @fondot, notice: 'Fondot was successfully updated.' }
        format.json { render :show, status: :ok, location: @fondot }
      else
        format.html { render :edit }
        format.json { render json: @fondot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fondots/1
  # DELETE /fondots/1.json
  def destroy
    @fondot.destroy
    respond_to do |format|
      format.html { redirect_to fondots_url, notice: 'Fondot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fondot
      @fondot = Fondot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fondot_params
      params.require(:fondot).permit(:cantidad)
    end
end
