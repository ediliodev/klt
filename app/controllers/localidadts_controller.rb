class LocalidadtsController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "64738", except: :index

  before_action :set_localidadt, only: [:show, :edit, :update, :destroy]
  after_action :registro_login_admin,  except: :index

  # GET /localidadts
  # GET /localidadts.json
  def index
    
    if verificar_violacion_simple 
      render plain: 'Locked System. Contact support.' #comando Ruleta de Luis.
    end

    @localidadts = Localidadt.all
  end

  # GET /localidadts/1
  # GET /localidadts/1.json
  def show
  end

  # GET /localidadts/new
  def new
    @localidadt = Localidadt.new
  end

  # GET /localidadts/1/edit
  def edit
  end

  # POST /localidadts
  # POST /localidadts.json
  def create
  #  @localidadt = Localidadt.new(localidadt_params)

    respond_to do |format|
      if true #@localidadt.save # No Allowed to create new localidads from web. Only project admin. ok ted.
        format.html { redirect_to @localidadt, notice: 'Localidadt was not (not allowed, contact admin) successfully created.' }
        format.json { render :show, status: :created, location: @localidadt }
      else
        format.html { render :new }
        format.json { render json: @localidadt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /localidadts/1
  # PATCH/PUT /localidadts/1.json
  def update
    respond_to do |format|
      if @localidadt.update(localidadt_params)
        format.html { redirect_to @localidadt, notice: 'Localidadt was successfully updated.' }
        format.json { render :show, status: :ok, location: @localidadt }
      else
        format.html { render :edit }
        format.json { render json: @localidadt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /localidadts/1
  # DELETE /localidadts/1.json
  def destroy
   # @localidadt.destroy # NOt Allowed from web, only admin. ted. ok. 
    respond_to do |format|
      format.html { redirect_to localidadts_url, notice: 'Localidadt not allowed to delete. Admin only. Incident reported.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_localidadt
      @localidadt = Localidadt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def localidadt_params
      params.require(:localidadt).permit(:consorcio, :sucursal, :direccion)
    end
end
