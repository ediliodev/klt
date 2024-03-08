class JackpotsController < ApplicationController
  #CONTROL DE ACCEOS A MODIFICAR JP PR LA WEB GESTIONANDO PWD OK TED:
  http_basic_authenticate_with name: "admin", password: "64738", except: :show # quiero no pwd para show ok

  before_action :set_jackpot, only: [:show, :edit, :update, :destroy]

  # GET /jackpots
  # GET /jackpots.json
  def index
    @jackpots = Jackpot.all
  end

  # GET /jackpots/1
  # GET /jackpots/1.json


  def show
  
    
    @sonar_musica_jp_ganador = false # defalut FALSE MUSCIA DEL JP GANADOR para la vista del show ok (no sonido por ahora em la vista html)
   
    @sin_layout = true # Con esto muestro solo la pagina del jp ok ted. 
    @porcentaje_retencion_jackpot_azul = 0.01 # Valor porcentual de retencion de la entraga para el JP ok.

    #verificar si hay un jackpot azul, si no crearlo:
    jpazul = Jackpot.where(:color => "azul").last 

    #CREAR EL JP AZUL SI ES NECESARIO PRIMERA VEZ OK
    if jpazul.nil?
      #crearlo first time
      jpazul = Jackpot.new
  
      jpazul.color = "azul"
      jpazul.totalinold = "0|0|" + Time.now.to_s + "|1|50|MQXX" # => 0|0|2023-23-04|1(JACKPOT AZUL ACTIVO OK)|50(PAGO MINIMO PARTICIPANTE)|maquina ganadora ..etc.. ok registro de last jp ganadores etc inicial ok
      jpazul.totalinnow = 0
      jpazul.cantidad = 0
      jpazul.trigger = 100
      jpazul.save
      
    end


    #definir variable global con los datos adicionales a mostras. ejemplo: fecha y monto ultimo jackpot ganador de estos ok ted..
    #seccion de manejo del show del jackpot del sistema kollector (Jackpot Azul)

    #El jp azul es un porcentaje de la entrada del sistema para que sea ascendente y porcentual a la venta (no a los beneficios ok)
    #definir el porcentaje de entrada para el jackpot
    #crear la logica de visuallizacion del porcentaje y las condiciones para ser ganador
    #Si no es ganador sigue aumentanto y si es ganandor pasar al proceso de entrga y registro de historial
    #probar



    #@consulta_rutinaria_megajackpot = "curl -m 5  -k  \'http://127.0.0.1:3000/contribuyentets?serial=#{@serial_global_mq}&contador=request_rutinario\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.

    #Comando consulta de production server:
    #@consulta_rutinaria_megajackpot = "curl -m 5  -k  \'https://10.0.7.220/contribuyentets?serial=#{@serial_global_mq}&contador=request_rutinario\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
#    @consulta_rutinaria_megajackpot = "curl  \'http://localhost:3000/autoreportets\'"  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.

    #comando = ` #{@consulta_rutinaria_megajackpot} ` # esto ejecuta el string de arriba en bash ok ted. 
    #comando = "hola"
    
    #Consultar la suma de todas las transacciones status ok del anio.
    #t = Transaccionest.between_dates(Time.now)


    #@respuesta_jp = comando.to_s

    # Fortmato de trama de respuesta esperada:  "Mega-#{@mega_sum}-request_rutinario_ok"
    #filtar respuesta, el curl puede traer no conexion tbn:
    #if comando.to_s.split("-")[2] == "request_rutinario_ok"

    # ESTA ES LA SECCION DEL JAKTPO DODNE VA SUBIENDO SEGUN LA ENTRADA DEL ANIO, PARA EVITAR CARGA EN LA VISTADEL JACKPOT REALIZAREMOS CONSULTA CADA 60 SEG POR EJEMPLO REFRESH PAGE PERO LA RECALCULACION DEL ACUIMULADO DEL ANIO LO HAREMOS ALEATORIO POR LO MENOS CADA UNA HORA DE CONSUITLA USANDO RANDOM OK TED.

    jpa = Jackpot.where(:color => "azul").last # ESTO PARA CONTINUAR CON LA LOGIA QUE VA DESPUES DE ESTA SECCION DEL RANDOM


    #hacer seccion de actualizar entrada_manual
    #si entrada_anual.update_at < Time.now - 1.day (actualizar) esto hace sonsulta del reporte venta del anio sea solo 1 vez al dia
    #nota para esto usaremos el registro Fondot.first ok
    fondo_obj = Fondot.first # objeto Fondot

    
    @sonar_actualizacion_jp = false # inicializacion de flag deactivar ssonidio cuando actualice jp, falso por defecto ok, solo se activa abajo y en proximo request se pone falso aqui ok

    
    #if f.update_at < (Time.now  - 0.25.day ) ) # 4 veces el dia (o saea cada 6 horas) si es mas viejo que un dia vamos a actualizar el fondo, que viene siendo el registro de entrada del anio ok
    #ponerlo que update cada 0.25.days (cada 6 horas) y que suene al update indicando que funciona y sube y lo vean caundo sube ok audio.
    if ( fondo_obj.updated_at < (Time.now - 1.minute ) ) # 4hes es por la direfecnia horaira de la dbatos ok por ahora cada x minutos mas rapido ok
      fondo_obj.touch # HECMOS ESTO PORQUE SAVE NO ACTUALIZA EL UPDATED AT ATTRIBUTE PREO TOUCH SI OK TED 

      @sonar_actualizacion_jp = true #
      

      @inicio_fecha_calcular_jackpot = desde = ( (Time.now.year.to_i) - (1.to_i) ).to_s + "-01-01" # => 2023-01-01 inicio del anio
      @fin_fecha_calcular_jackpot = hasta = (Time.now ) # => hasta hoy
      
      # este el el reporte que puede cargar un pco si ejecutamos muy continuo ok ted.
      objeto_transaccionests = Transaccionest.between_dates(desde , hasta ).where(:tipotransaccion => "credito" ,  :status => "ok") 
     
      @suma_corriente = 0 #inicializar suma en cero

      if not objeto_transaccionests.empty?
         #realizar la sumatoria de todas las entradas consultadas en ese rango de fecha
         objeto_transaccionests.each do |t|

           @suma_corriente += t.cantidad.to_i # sumar todas las entrada del anio hasta ayer ok
           
         end

      end

      #ahora fondo tiene la sumatoria de todas las entradas del anio hasta ayer. aqui abajo:
      fondo_obj.cantidad = @suma_corriente
      fondo_obj.save # este equivale al touch ok

      
    end # fin de la seccion de revisar el reporte fondo anual entrada updated hasta ayer ok

    #ahroa coninuamos con el reporte de hoy para agregar el total jp acumulado, esot para cagas mas rapido la pag, ya que el reporte grande se hace peridico ok no simepre (1vez al dia o cada x minuutos ok ted)
    
    
    #sacar el erporte de hoy y luego sumar todo para sacar el porcentaje:
    
   # reporte_entrada_venta_hoy = 0
    # sacar entrada de hoy si las hay:
    # este el el reporte que puede cargar un pco si ejecutamos muy continuo ok ted.
  #  objeto_transaccionests_hoy = Transaccionest.between_dates(Time.now , Time.now ).where(:tipotransaccion => "credito" ,  :status => "ok") 
     
  #  @suma_corriente_hoy = 0 #inicializar suma en cero

  #  if not objeto_transaccionests_hoy.empty?
       #realizar la sumatoria de todas las entradas consultadas en ese rango de fecha
  #     objeto_transaccionests_hoy.each do |t|

  #       @suma_corriente_hoy += t.cantidad.to_i # sumar todas las entrada del anio hasta ayer ok
         
  #     end

  #  end

    #suma_corriente_hoy tiene  0 o el total hata aqui ok
  #  reporte_entrada_venta_hoy = @suma_corriente_hoy


  #  retencion_cruda = (fondo_obj.cantidad.to_f + reporte_entrada_venta_hoy.to_f) * @porcentaje_retencion_jackpot_azul.to_f

    retencion_cruda = (fondo_obj.cantidad.to_f ) * @porcentaje_retencion_jackpot_azul.to_f
   
    jpa = Jackpot.where(:color => "azul").last
    jpa.totalinnow = retencion_cruda # esto porque se mide en cantidades del jackpot no de entrada de venta ok es un flotante por lo que podemos redondear ok

    jpazulold = jpa.totalinold.to_s.split("|")[0].to_f # aqui guardaremos los registros de los ganadores tambien ok ted ej. 0|200|2023-04-05 ok
    jpa.cantidad = (jpa.totalinnow.to_f - jpazulold.to_f).round(2) # resta devuelve un flotante usar metodo round para redondear el resultado a dos cifras decimales ok

    #jpa.cantidad.to_f.round(2) 

    jpa.save #actulizo el incremento del jp para la vista del display ok
     


    @respuesta_jp = jpa.cantidad


    if ( @respuesta_jp.to_i < 0 )
      @respuesta_jp = 0 # evitar mostrar valores de jp negativo, especialmente en cambio del anio ok
    end

    @vista_jp_azul = @respuesta_jp.to_f
    @vista_jp_ganador = jpa.totalinold.to_s.split("|")[1]

    #vista maquina ganadora:
    @maquina_ganadora_jp = jpa.totalinold.to_s.split("|")[5].to_s[0..19]
   


    @vista_fecha_jp_ganador = jpa.totalinold.to_s.split("|")[2][0..9].to_s # Seleccionar la fecha ultimo ganador ok ted.
    
    # tenemos que voltear la fecha en formato dia-mes-anio:
    @fecha_provisional = @vista_fecha_jp_ganador.split("-")[2].to_s + "-" + @vista_fecha_jp_ganador.split("-")[1].to_s + "-" + @vista_fecha_jp_ganador.split("-")[0].to_s

    @vista_fecha_jp_ganador =  @fecha_provisional # volteado ok



    #seccion para verificarcion y rifa del jp
    #verificar umbrales y verificar pagos recientes
    #verificar si califican
    #rifar
    #si es ganando proceder a entregar y sonar y recalcular
    #final 




    # INICIO DE  SECCION DEL JACKPOT AZUL:
  

   jpazul = Jackpot.where(:color => "azul").last 

    #VALIDAR QUE EXISTA EL JP PARA PROCEDER A LO DEMAS 
    #***NOTA IMPORTANTE***: OJOJ esta es la seccion del pago jackpot para las maquinas pot of gold o los pagos que vienen por Arduino (Postcontroller), PARA LAS MAQUINAS DIGITALES RULETA LUIS Y DEMAS DIGITALES CONSULTAR EL OTRO CONTROLADOR QUE RECIBE DICHOS PAGOS USANGO GET VERB, transaccioenstcontroller me parece ok ted.
    
    if not jpazul.nil?
      if ( jpazul.cantidad.to_i >=  jpazul.trigger.to_i )

        # sin entra aqui es porque el trigger se cumple
        #Debemos buscar pagos o creditos recientes (porque se le paga ahi mismo al jugador) 30seg maximo procesado.
        #vamos von el ultimo pago reciendte 30seg y que no sea cantidades repetidas
        ultimo_pago = Postransaccionest.last
        penultimo_pago = Postransaccionest.last.previous
        trasantepenultimo_pago = Postransaccionest.find( (penultimo_pago.id.to_i - 1) ) #esto porque a veces un pago manda dos registros por ejemplo 0 y luego 100 ok ted. 
        #verificar ogica simple de brute attacK: que los pagos no sean repetidos no importa la maq y el ultimo sea 30segs om meno para participar
        # Por ahora que no sean repetidos los ultimos dos pagos, esa es al condicion ademas del trigger y los 30seg receites ok

        @hay_pago_repetido = false # default false ok

        if ( (ultimo_pago.cantidad.to_i == penultimo_pago.cantidad.to_i ) || (ultimo_pago.cantidad.to_i == trasantepenultimo_pago.cantidad.to_i )  )
          @hay_pago_repetido = true          
        end


        @hay_que_sortear = false # default en false ok
       
        # si no hay patrones de pago repetido 1-2 o 1-3 (pagos repetido con el ultimo ok) procedemos a verificar si ultimo pago es reciente
        if ( not(@hay_pago_repetido) && (ultimo_pago.created_at > (Time.now - 30.seconds) ) ) # hcerel refresh jp cada 15 segs aprox ok
          #no hay pago repetido y el ultimo pago es recientem hay que sortear ok
          @hay_que_sortear = true
        end


      

        # @pago_minimo_participante = jpazul.totalinold.to_s.split("|")[4].to_s # Cualquier valor por ahora participa en el  pago
        if @hay_que_sortear  # verificar_condiciones_para_ganar_jp_azul(@postransaccionest, @pago_minimo_participante) #verificar_condiciones_para_ganar_jp_azul(@postransaccionest, @pago_minimo_participante)
            #si entra aqui es porque cumple con las condiciones para ser ganador
            #hacer rifa
             if ( (3 == rand(1..5) ) )  # provosional nota rand(10) va del 0 al 9 y rand(1..10) va del 1 al 10 cerrado y rand(0..200) va [0-200] => 201 elementos. ok probar en irb. Solo conocimiento Gral. ok.
              #ganador
              #si es ganador procesar ganador de lo contrario siga participando en otro pago ok
              #procesar el ganador implica guardar monto es este mismo pago ok, etc..
              #precesar ganador aqui mismo:
              ultimo_pago.cantidad = (ultimo_pago.cantidad.to_i + jpazul.cantidad.to_i) #adicionar monto ganador a su pago ok
              ultimo_pago.save # agrepar el pago del jp y guardarlo ok

              #Identificar la maquina ganadora del jackpot para mostrar en pantalla:
              maquina_ganadora = Maquinat.where(:serial => ultimo_pago.serial).last 

              if not maquina_ganadora.nil?
                @descripcion_maquina_ganadora = maquina_ganadora.descripcion.to_s
              end
              

              #actualizar registro ganadores y fecha y nuevos totales de conteo:
              @nuevo_totalinold_solo = jpazul.cantidad.to_i + jpazul.totalinold.to_s.split("|")[0].to_i # sumar contero to jackpots ganadores para restar a direrecntia de venta global menos el nuevo conteo del nuevo jackpot ok.

              jpazul.totalinold = "#{@nuevo_totalinold_solo}|" + "#{jpazul.cantidad}|" + Time.now.to_s + "|1|50|" + "#{@descripcion_maquina_ganadora}" # => 0|0|2023-23-04|1(JACKPOT AZUL ACTIVO OK)|50(PAGO MINIMO PARTICIPANTE)| maquina ganadora
              jpazul.save # actualizo registros ok. 
              
              @sonar_musica_jp_ganador = true

             end 
        

        end # end del @hay_que_sortear condition
      end # end el triggger condition


      #verificar si el jp es ganador, entonces hay que actualizar la vista del jp pantalla con el monto ganador en la maquina ganadora y la nueva cantidad, para que al moento de sonar se vea actulizado en la pantalla:
      #si es ganador, actualizar la vistsa:
      if (@sonar_musica_jp_ganador == true ) # esto para valida con boolean porque un objeto por si solo ya es true ok ted.
        
            jpa = jpazul # iguala objeto para seguir la misma logica del copu paste de arriba visualizacion actualizada del show view ok
            @respuesta_jp = jpa.cantidad

            if ( @respuesta_jp.to_i < 0 )
            @respuesta_jp = 0 # evitar mostrar valores de jp negativo, especialmente en cambio del anio ok
            end

            @vista_jp_azul = @respuesta_jp.to_f
            @vista_jp_ganador = jpa.totalinold.to_s.split("|")[1]

            #vista maquina ganadora:
            @maquina_ganadora_jp = jpa.totalinold.to_s.split("|")[5].to_s[0..19]



            @vista_fecha_jp_ganador = jpa.totalinold.to_s.split("|")[2][0..9].to_s # Seleccionar la fecha ultimo ganador ok ted.

            # tenemos que voltear la fecha en formato dia-mes-anio:
            @fecha_provisional = @vista_fecha_jp_ganador.split("-")[2].to_s + "-" + @vista_fecha_jp_ganador.split("-")[1].to_s + "-" + @vista_fecha_jp_ganador.split("-")[0].to_s

            @vista_fecha_jp_ganador =  @fecha_provisional # volteado ok

      end


    
    end # end del if not jpazul.nil? condition



  end # fin de la accion show ok




  # GET /jackpots/new
  def new
    @jackpot = Jackpot.new
  end

  # GET /jackpots/1/edit
  def edit
  end

  # POST /jackpots
  # POST /jackpots.json
  def create
    @jackpot = Jackpot.new(jackpot_params)

    respond_to do |format|
      if @jackpot.save
        format.html { redirect_to @jackpot, notice: 'Jackpot was successfully created.' }
        format.json { render :show, status: :created, location: @jackpot }
      else
        format.html { render :new }
        format.json { render json: @jackpot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jackpots/1
  # PATCH/PUT /jackpots/1.json
  def update
    respond_to do |format|
      if @jackpot.update(jackpot_params)
        format.html { redirect_to @jackpot, notice: 'Jackpot was successfully updated.' }
        format.json { render :show, status: :ok, location: @jackpot }
      else
        format.html { render :edit }
        format.json { render json: @jackpot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jackpots/1
  # DELETE /jackpots/1.json
  def destroy
    @jackpot.destroy
    respond_to do |format|
      format.html { redirect_to jackpots_url, notice: 'Jackpot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.


    def verificar_condiciones_para_ganar_jp_azul(postransaccionest_obj, pago_minimo_participante)
      #verifcar condiciones del objeto recibido que es el pago reciente a valdiar requisitos:  
      respuesta = true # INICIALIZAR EN TRUE OK por ahora cumple

      #verifcar que se cumpla la condifion del pago minimo participante:
      if postransaccionest_obj.cantidad.to_i < pago_minimo_participante.to_i
        respuesta = false
      end

      #verifcar que se cumpla la condifion del pago no repetido y concurrente de una misma maquina con una misma cantidad. Evitar brute force jp attack basico:
      #if postransaccionest_obj.cantidad.to_i < pago_minimo_participante.to_i
        last_pago_esa_maquina_obj = Postransaccionest.where(:serial => postransaccionest_obj.serial).last 
        
        if not last_pago_esa_maquina_obj.nil?
        
          monto_ultimo_pago_recibido = last_pago_esa_maquina_obj.cantidad.to_i
          fecha_ultimo_pago = last_pago_esa_maquina_obj.created_at

          if ( monto_ultimo_pago_recibido.to_i == postransaccionest_obj.cantidad.to_i )
            respuesta = false #pudiera considerar el timepo aqui pero por ahora asi es mejor. Que tanta coicidencia con ultimo pargo el mismo. no particia ok.
          end

          if (fecha_ultimo_pago > ( Time.now - 1.minutes) ) # provisional 1 minuto, debe ser 5mins aprox ok.
            respuesta = false # no participa si resibimos pagos continuos (menos de 5mins) de la misma maquina solo para cocursar ok ted.
          end

        else

          respuesta = false # si el utlimo pago no existe de esa maq es porque primer pago, ponerlo false, que participe en los pagos posteriores de ella ok.          
        
        end



      respuesta # RETORNAR boolean respuesta objeto ok.
      #PROVISIONAL
      #false
      true

    end



    def set_jackpot
      @jackpot = Jackpot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jackpot_params
      params.require(:jackpot).permit(:color, :totalinold, :totalinnow, :cantidad, :trigger)
    end
end
