class UsuariosbrtsController < ApplicationController
  before_action :set_usuariosbrt, only: [:show, :edit, :update, :destroy]

  # GET /usuariosbrts
  # GET /usuariosbrts.json
  def index
    @usuariosbrts = Usuariosbrt.all
  end

  # GET /usuariosbrts/1
  # GET /usuariosbrts/1.json
  def show
  end

  # GET /usuariosbrts/new
  def new
    @usuariosbrt = Usuariosbrt.new
  end

  # GET /usuariosbrts/1/edit
  def edit
  end

  # POST /usuariosbrts
  # POST /usuariosbrts.json
  def create
    @usuariosbrt = Usuariosbrt.new(usuariosbrt_params)

    respond_to do |format|
      if @usuariosbrt.save
        format.html { redirect_to @usuariosbrt, notice: 'Usuariosbrt was successfully created.' }
        format.json { render :show, status: :created, location: @usuariosbrt }
      else
        format.html { render :new }
        format.json { render json: @usuariosbrt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuariosbrts/1
  # PATCH/PUT /usuariosbrts/1.json
  def update
    respond_to do |format|
      if @usuariosbrt.update(usuariosbrt_params)
        format.html { redirect_to @usuariosbrt, notice: 'Usuariosbrt was successfully updated.' }
        format.json { render :show, status: :ok, location: @usuariosbrt }
      else
        format.html { render :edit }
        format.json { render json: @usuariosbrt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuariosbrts/1
  # DELETE /usuariosbrts/1.json
  def destroy
    @usuariosbrt.destroy
    respond_to do |format|
      format.html { redirect_to usuariosbrts_url, notice: 'Usuariosbrt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuariosbrt
      @usuariosbrt = Usuariosbrt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usuariosbrt_params
      params.require(:usuariosbrt).permit(:nombre, :apellido, :usuario, :contrasena, :telefono, :email, :cedula, :direccion, :tipousuario, :md5pc, :consorcioasociado)
    end
end
