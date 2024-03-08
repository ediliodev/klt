class MaquinatsController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "64738", except: :index
  before_action :set_maquinat, only: [:show, :edit, :update, :destroy]

  # GET /maquinats
  # GET /maquinats.json
  def index
    
    if verificar_violacion_simple
      render plain: 'Locked System. Contact support.' #comando Ruleta de Luis.
    end

    @maquinats = Maquinat.all.order(:sucursal) #.reverse #organizar vista por sucursal despues asc ok.
  end

  # GET /maquinats/1
  # GET /maquinats/1.json
  def show
  end

  # GET /maquinats/new
  def new
    @maquinat = Maquinat.new
  end

  # GET /maquinats/1/edit
  def edit
  end

  # POST /maquinats
  # POST /maquinats.json
  def create
    @maquinat = Maquinat.new(maquinat_params)
    
     # la activacion de los modulos (seriales la haremos manual x banca para controllar el orden de los mismos en la calle y por seguridad) entonces asignamos uno aleatorio que no esta activado. ok ted
    if @maquinat.serial.nil?

      @maquinat.serial = "00-000-" + rand(9).to_s + rand(9).to_s + rand(9).to_s + rand(9).to_s # "00-000-0000" se asigno un serial aleatorio provisional no dentro del rengo de venta porque los de venta empiezan con 00-xxx-xxxx ok ted.

        
    end
     



    respond_to do |format|
      if @maquinat.save
        format.html { redirect_to @maquinat, notice: 'Maquinat was successfully created.' }
        format.json { render :show, status: :created, location: @maquinat }
      else
        format.html { render :new }
        format.json { render json: @maquinat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maquinats/1
  # PATCH/PUT /maquinats/1.json
  def update
    respond_to do |format|
      if @maquinat.update(maquinat_params)
        format.html { redirect_to @maquinat, notice: 'Maquinat was successfully updated.' }
        format.json { render :show, status: :ok, location: @maquinat }
      else
        format.html { render :edit }
        format.json { render json: @maquinat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maquinats/1
  # DELETE /maquinats/1.json
  def destroy
    #@maquinat.destroy # NO SE DEBEN DESTRUIR POR LAS RELACIONES EXISTENTES AL MENOS QUE CONFIGUREMOS DEPENDENT DETROY( NO RECOMENDABLE POR EL HISTORIAL DE VENTAS) SOLO DESABILITARLAS => ACTIVA => NO OK. TED.
    @maquinat.activa = "no"
    if @maquinat.save
        respond_to do |format|
          format.html { redirect_to maquinats_url, notice: 'Maquina desactivada. Para activarla nuevamente presione Editar' }
          format.json { head :no_content }
        end
    end # lo del error del .save (en caso que pase) no se considera por ahora, solo el if, para proteger al sw de una exception. ok.
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_maquinat
      @maquinat = Maquinat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def maquinat_params
      params.require(:maquinat).permit(:tipomaquinat_id, :descripcion, :serial, :activa, :lastseen, :consorcio, :sucursal, :usuarioventa, :supervisor, :entrada, :salida )
    end
end
