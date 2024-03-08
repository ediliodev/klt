class CashboxtsController < ApplicationController
  before_action :set_cashboxt, only: [:show, :edit, :update, :destroy]

  # GET /cashboxts
  # GET /cashboxts.json
  def index
    @cashboxts = Cashboxt.all
  end

  # GET /cashboxts/1
  # GET /cashboxts/1.json
  def show
  end

  # GET /cashboxts/new
  def new
    @cashboxt = Cashboxt.new
  end

  # GET /cashboxts/1/edit
  def edit
  end

  # POST /cashboxts
  # POST /cashboxts.json
  def create
    @cashboxt = Cashboxt.new(cashboxt_params)

    respond_to do |format|
      if @cashboxt.save
        format.html { redirect_to @cashboxt, notice: 'Cashboxt was successfully created.' }
        format.json { render :show, status: :created, location: @cashboxt }
      else
        format.html { render :new }
        format.json { render json: @cashboxt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cashboxts/1
  # PATCH/PUT /cashboxts/1.json
  def update
    respond_to do |format|
      if @cashboxt.update(cashboxt_params)
        format.html { redirect_to @cashboxt, notice: 'Cashboxt was successfully updated.' }
        format.json { render :show, status: :ok, location: @cashboxt }
      else
        format.html { render :edit }
        format.json { render json: @cashboxt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cashboxts/1
  # DELETE /cashboxts/1.json
  def destroy
    @cashboxt.destroy
    respond_to do |format|
      format.html { redirect_to cashboxts_url, notice: 'Cashboxt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cashboxt
      @cashboxt = Cashboxt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cashboxt_params
      params.require(:cashboxt).permit(:cantidad)
    end
end
