class PostransaccionestsController < ApplicationController
  skip_before_action :verify_authenticity_token # arduino json 
  before_action :set_postransaccionest, only: [:show, :edit, :update, :destroy]

  # GET /postransaccionests
  # GET /postransaccionests.json
  def index
    @postransaccionests = Postransaccionest.all
  end

  # GET /postransaccionests/1
  # GET /postransaccionests/1.json
  def show
  end

  # GET /postransaccionests/new
  def new
    @postransaccionest = Postransaccionest.new
  end

  # GET /postransaccionests/1/edit
  def edit
  end

  # POST /postransaccionests
  # POST /postransaccionests.json
  def create

      @postransaccionest = Postransaccionest.new(postransaccionest_params)




     #SECCION PARA ELIMINAR HEADERS  PARA UN MEJOR ARDUINO REPLY:
      request.request_id = nil # desabilitar
      request.session_options[:defer] = true  # esto evita enviar la cooke en el header ok ted
    
     # response.headers['X-Frame-Options'] = ''
      response.headers['X-XSS-Protection'] = ''
      response.headers['ETag'] = ''
      response.headers['Content-Type'] = ''
      response.headers['X-Content-Type-Options'] = ''
      response.headers['Cache-Control'] = ''
    

      #USAREMOS ESTA SECCION PARA VALIDAR LOS CREDITOS TAMBIEN, YA QUE ARDUINO CODE SOLO USAREMOS POST POR UN TEMA DE ESPACIO DE CODIGO EN ARDUINO OK:
      # EN ESTA OCASION SI EL  PARAMETRO JUGADOR ES IGUAL A 99 YA SABEMOS QUE ES UNA PETICION PARA MANEJAR UN GET CREDIT CONFIRMATION OK
      if  @postransaccionest.jugador.to_s == 99.to_s
        #confirmar una acreditacion 
        #bucar matcheo de hoy (md5_get_credit logic) que aqui es el comando de esa transaccion
        #actualizar status a ok
        #responder confimacion

        @confirmacion_del_get_recibida = @postransaccionest.confirmation.to_s

        #buscar matcheo (que sea de hoy el ultimo recienta con ese md5 confirmation ya que es una validacion de  credito de estado pendiente a  estadook .
       # @transaccion_actual_objeto = Transaccionest.today.where(:maquinat_id => (Maquinat.where(:serial => @postransaccionest.serial.to_s).first.id), :comando => @confirmacion_del_get_recibida.to_s , :status => "pendiente").last # || Transaccionest.first # Dejo el UTC normal de la base de datos, resto 5 min a Time.now, Luego le sumo 4 horas para IGUALAR al timepo UTC, no a mi zona horaria, la cual serial -4GMT (serial restando para igualar a mi zona, pero como voy a comparar coon UTC sumo +4hr e igualo al tiempo(zona horaria) UTC para restar los 5min y comparar ok.)
         # con estado sin importar para confirmarlo varias veces si arduino lo necesita que se confirme (verifica 4 intnetos)
         @transaccion_actual_objeto = Transaccionest.today.where(:maquinat_id => (Maquinat.where(:serial => @postransaccionest.serial.to_s).first.id), :comando => @confirmacion_del_get_recibida.to_s ).last # || Transaccionest.first # Dejo el UTC normal de la base de datos, resto 5 min a Time.now, Luego le sumo 4 horas para IGUALAR al timepo UTC, no a mi zona horaria, la cual serial -4GMT (serial restando para igualar a mi zona, pero como voy a comparar coon UTC sumo +4hr e igualo al tiempo(zona horaria) UTC para restar los 5min y comparar ok.)
       

        #puts "*****"
        #puts "*****"
       # puts "*******confirmacion_del_get_recibida : #{@confirmacion_del_get_recibida }  "
        
        #if ( (@transaccion_actual_objeto.created_at ) >  (Time.now  - 1.minutes ) )
        if @transaccion_actual_objeto.nil? 
          #repsonder negativo
          #SECCION PARA ELIMINAR HEADERS  PARA UN MEJOR ARDUINO REPLY:
          
          render plain: "@cash00^9999#" and return # fin ok "@cash00^9999# indica valor no encontrado, nutnca mandamos un @cash00 a a creditar logic ok ted. Y asi se mantiene el estandar del protocolo arduino para desifrar tramas validar ok 
          
        end

        #actualizar contadores de entrada de Maquinat de ese serial de esa transaccion:
       # m = Maquinat.where(:serial => @transaccion_actual_objeto.serial ).last 

        entrada_actual = @transaccion_actual_objeto.maquinat.entrada.to_i
        acreditacion_adicional = @transaccion_actual_objeto.cantidad.to_i

        @transaccion_actual_objeto.maquinat.entrada = entrada_actual + acreditacion_adicional
        #actuzlizar status
        @transaccion_actual_objeto.status = "ok" 


        #Guardar bien los registro actualizados transacciones y Maquinat.entrada ok ted y responder confirmation ok
        if ( ( @transaccion_actual_objeto.save ) && ( @transaccion_actual_objeto.maquinat.save ) )
           render plain: @transaccion_actual_objeto.comando.to_s and return
        else
           render plain: "@cash00^7777#" and return #negativo tambien pero 777 indicando negativo pero por no poder guardarlo ok. ok. En este caso no se puedo guardar bien este registro ok ted.
        end


      end # fin del condition if  @postransaccionest.jugador.to_s == 99.to_s


      # fin de la seccion de confirmacion de creditos usando post controller ok.



     # puts("Entrando 1 plai params")
      #puts("cantidad" + #{ @postransaccionest.cantidad.to_i  indice_de_pago.to_i)})
     # puts("cantidad: #{@postransaccionest.cantidad.to_i }" )

      #@ntidad = @postransaccionest.cantidad.split("L")[0]

      #PAGO EN MODO CONFIRMACIONES
      # NOTA: @postransaccionest.jugador YA CONTIENE LA CONFIRMACION PROVENIENDTE DEL MODULO  PTGOLD OK => @100^123456789#



      @postransaccionest.cantidad = @postransaccionest.cantidad.split("L")[0] # Esto para Limpiar el String de cantidad de las POG que viene asi: 4.00LEISURETIME ej. ok. ted.


    # En caso de que la cantiadad a pagar provenga desde la Ruleta de Tiago, debo separar la cant y el jugador a pagarle, recueda que es multijugador. ok ted.
    # json from tiago ruleta: { 'cantidad:500j2', 'serial:02-000-0001' }
      @postransaccionest.cantidad = @postransaccionest.cantidad.split("j")[0] # OJO j minuscula Tiago !



    # @postransaccionest.jugador =  @postransaccionest.cantidad.split("j")[1].nil? ? "1" : @postransaccionest.cantidad.split("j")[1]
    #PROBAR ESTA PARTE DE ARRRIBA CON TIAGO EN UNOS DE LOS POST CANTIDAD JUGADOR 1..6 DE SU RULETA.

    #Verificacion de factor multiplicativo de pago (1:1 default, 1:5, etc) maquinas ptg pago mas rapido pulsos recibidos ok Fary.
    #verificar si se puso alguna configuracion de la realcion de pago por web en el programa:

    indice_de_pago = Localidadt.first.direccion.split("$")[1] || 1.to_i # realcion de pago 1:1 default ok.
    #aplicar el factor multiplicativo de el indice de pagoa al pago recibido (factor multiplicatio ok 1:1, 1:5, etc)
    @postransaccionest.cantidad = (@postransaccionest.cantidad.to_i * indice_de_pago.to_i)

   

    #Si es Luis pago Ruleta argentina Neon, debe hacer un socket y tratar de enviar algo como esto:
    # Socket.send ( 'POST /postransaccionests HTTP/1.1\r\nHost: ruletatest.redirectme.net:3000\r\nContent-Type: application/json\r\nContent-Length: 47\r\n\r\n{\"cantidad\":\"500\" , \"serial\":\"003-000-0001\"}\r\n'
    # data= "{\"cantidad\":\"500\" , \"serial\":\"003-000-0001\"}");
    #O TAMBIEN EN ULTIMA INSTANCIA LUIS PUEDE ENVIAR EL CAHSOUT POR UN GET PARAMS LIKE HE DID WITH SERIAL AND CONFIRMATION SOLO AGREGAR ?serial=003-000-0001&cashout=500 yo le respondo un render plain: pago_ok algo mas sencillo asi seria para el. Para Mi manejarlo en el controlador con la accion index


    # Aqui podemos trabajar la seccion del Jackpot azul (Kollector system Jackpot) ya que los pagos, serial y demas parametros estan ready por aqui.

    #condiciones para ganador del jp azul:
    # que exista un limite de un pago minimo particiapnte ok
    # que el trigger sea alcanzado ok
    # que el ultimo pago de esa maquina sea un minimo mayor a 5mins trancurrido. (esto para evitar envio y recepcion continuos para ganar)
    # que el ultimo pago no coincia con la misma cantidad del anterior, se relaciona con lo de arriba ok
    # si es ganador: actualizar valores y dispoayy sonar musica y probar si pago llego con credtio ok.

   # ESTA SECCION DE PAGOS ES PARA PTOGOLD LA IDEA ES VALIDAR SI LA MQ EXITE Y NO DESABILITADA ANTES DE REGISTRAR PAGOS ENVIADOS OK. 
    #tenemos que verificar que la maquina que manda el pago no este desabilitada administrativamente por la Web
    #Si la maq esta desbilitada no deberia mandar pagos si recibir creditos ok. ted

    #variable de abajo me indica si la maquina de ese pago existe o no existe [true o false]
    maquina_existe =  ! (Maquinat.where(:serial =>  @postransaccionest.serial ).last.nil?) # not nil devuelve true que existe ok
    
    maquina_activa = false #default hasta que validemos lo contrario debajo ok  
    
    if maquina_existe
      #si la maquina existe aprovecho y le asigo el atributo de ususarioventa de ese pago de esa mauinta:
      @postransaccionest.usuarioventa = Maquinat.where(:serial => @postransaccionest.serial).last.usuarioventa # consigo el usuario de esa maquina y completo el atributo de usuarioventa de postransaccionest ojbecto ok

      #continuar con la logica del bloque if ok ted...
      verificar_status_maquina_activa  =  Maquinat.where(:serial =>  @postransaccionest.serial ).last.activa # "si" o  "no"  
      if verificar_status_maquina_activa == "si"
        maquina_activa = true
      end
    end
    
     



        respond_to do |format|
          
          if (maquina_activa)
            #verificar que ses pago no este registrado para guardarlo (registrar) y si ya esta registrado solo responder confirmacion para atras sin registrar nuevamente
            # Si la cantidad de registro de hoy  de esa confimacion es > 0  entonces hay al menos un registro ok y el segundo no va a suceder porque no se hace el save, solo responder confirmation back ok ted.
            registro = Postransaccionest.today.where(:confirmation => @postransaccionest.confirmation.to_s ).count

            if (registro > 0) # registrado, solo responder confirmation back y no guardad nada de nuevo
               response.headers['X-Frame-Options'] = @postransaccionest.confirmation.to_s
               render plain: @postransaccionest.confirmation.to_s and return # fin ok
            end
              # si registro < = 0 entonces va a continuar aqui debajo normal, gardadno y respondiendo.

              #validar y agregar a contador de salida ok
              m = Maquinat.where(:serial => @postransaccionest.serial).last

              m.salida = m.salida.to_i + @postransaccionest.cantidad.to_i

              #validar guardar ambos

              if ( @postransaccionest.save && m.save )
               # valoi = "klkkk" # @postransaccionest.jugador.split("@")[1].split("^").join().to_s # todo string klk
                response.headers['X-Frame-Options'] = @postransaccionest.confirmation.to_s
                #render plain: "@200^12345#" and return
                render plain: @postransaccionest.confirmation.to_s and return

                format.html { redirect_to @postransaccionest, notice: 'Postransaccionest was successfully created.' }
                format.json { render :show, status: :created, location: @postransaccionest }
              else
                format.html { render :new }
                format.json { render json: @postransaccionest.errors, status: :unprocessable_entity }
              end 
          end

              format.html { render :new }
              format.json { render json: @postransaccionest.errors, status: :unprocessable_entity }
        end

  end

  # PATCH/PUT /postransaccionests/1
  # PATCH/PUT /postransaccionests/1.json
  def update
    respond_to do |format|
      if true # @postransaccionest.update(postransaccionest_params) # NO SE PUEDEN ACTUZALIZAR LAS POSTRANSACCIONES POR EL PORTAL WEB POR MOTIVO DE SEG. CONTACTAR ADMIN A BAJO NIVEL PARA ESO. OK. LOGICA DEL CONTROLADOR DESABILIDATA PARA ESOS FINES OK. TED.
        format.html { redirect_to @postransaccionest, notice: 'Postransaccionest NOT PERMITED TO UPDATE WHIS WAY. INCIDENT REPORTED. CONTACT ADMIN.' }
        format.json { render :show, status: :ok, location: @postransaccionest }
      else
        format.html { render :edit }
        format.json { render json: @postransaccionest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /postransaccionests/1
  # DELETE /postransaccionests/1.json
  
  def destroy
  
    # @postransaccionest.destroy # NO SE PUEDE ELIMINAR UN POSTTRANSACCION DESDE LA WEB. DEBE CONTACTAR AL ADMIN. (OK TED.)
  
    respond_to do |format|
      format.html { redirect_to postransaccionests_url, notice: 'Postransaccionest cannot be destroyed. Contact admin. Incident Report.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    



    def set_postransaccionest
      @postransaccionest = Postransaccionest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def postransaccionest_params
      params.require(:postransaccionest).permit(:cantidad, :serial, :jugador, :confirmation, :usuarioventa)
    end
end



#Migraciones agregadas al controlador para los pagos y confirmacione s3feb2024
#rails g migration AddConfirmationToPostransaccionests confirmation:string