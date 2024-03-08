class ContribuyentetsController < ApplicationController
  http_basic_authenticate_with name: "megajackpot", password: "megajp6idd", except: :index
  before_action :set_contribuyentet, only: [:show, :edit, :update, :destroy]
  before_action :index_serial_param_ted, only: [:index]
  before_action :index_contador_param_ted, only: [:index]
  

  # GET /contribuyentets
  # GET /contribuyentets.json
  def index
    #esto debe respondet tipo render plain para mejor tiempos de respuetas qweb, menor header html, etc, al momento de sortear ok.
    
    #@contribuyentets = Contribuyentet.all

    #SETTING DEL MEGAJACKPOT:
    @fondo_inicial = 105 # Megajackpot Fondo conteo inicial. Monedas de fondo inicial para empezar el megajackpot.
    @trigger_megajackpot = 2000 # trigger de activacion del megajackpot. ok.
    @margen_del_mega = 0.005 #  es el porciento a retener del total del contador de entrada del contribuyente. ok.
    @margen_de_retencion_mnt_plataforma = 0.12 # margen porcentual de retencion del megajackpot plataforma. Sirve como margen de seguridad, cubrir gastos de tramites de pago, publicidad, fotos, impuesots minimos, imprevistos, etc.. #convertir a float, etc.. ok.

   
    #/contribuyentets?serial=003-000-1001&contador=09989
    @serial_mq_mj = index_serial_param_ted[:serial] # capturar parametros de entrada a traves de este controlador procesado con el vervo get ok.
    @contador_mq_mj = index_contador_param_ted[:contador] # capturar parametros de entrada a traves de este controlador procesado con el vervo get ok.
    @no_ganador_update_only = index_contador_param_ted[:contador].to_s.split("-")[1] || nil # si no es ganador :contador param vendra en modo update only, procesarlo en la logia ok. ej: contribuyentets?serial=#{@serial_global_mq}&contador=#{@contador.totalin}-rondanoganadora'  ok


    #IDENTIFICAR al contribuyente que realiza la peticion, ver si esta inscrito valido ok ted:
    @contribuyentet_segun_serial = Contribuyentet.where(:serialmq => @serial_mq_mj).first


    #Verificar si es atender peticion del mega de rutina, consulta get only, no una consulta sorteable ok.
    if ( (@contribuyentet_segun_serial) && ( @contador_mq_mj.to_s == "request_rutinario"))
     # @mega_sum = Contribuyentet.all.sum(:aportemega).to_i + @fondo_inicial.to_i # adicionar el fondo del mega. ok.
      @mega_sum = determinar_valor_del_megajackpot_neto()
      render plain: "Mega0-#{@mega_sum}-request_rutinario_ok" and return # responde el mega de rutina ok.
    end

    #Verificar si es atender peticion del mega de una ronda normal participante del sorteo, en este caso llega con el serial y el contador actual del contribuyente participante, ok ted.
    if ( (@contribuyentet_segun_serial) && ( @contador_mq_mj.to_i > @contribuyentet_segun_serial.countermeterold.to_i ) ) # existe el contribuyente, actualizar su contador, procesar, ver tirgger, sortear y  responder etc..
      #estamos con un contribuyente normal
      
       # el countermeterold debe ser el mismo siempre, para mantener la ventada de diferencia en el aporte al megajackpot, solo cambiara al haber un ganador y se pone en cero, o inicialmente si es 0, autoguardar el contero inicial cuando empieza a aportar y participar ok ted.
      #actualizar contador viejo con el nuevo valor:
      if( @contribuyentet_segun_serial.countermeterold.to_i == 0 ) # si es nil tambien aplica el condition ok, porque nil.to_i => 0 ok ted.
        @contribuyentet_segun_serial.countermeterold = @contador_mq_mj.to_i # actualizo contador viejo con el valor nuevo, esto para la proxima futura resta ok.
        @contribuyentet_segun_serial.aportemega = 0 # estamos inciando contador nuevo el aporte empieza en la proxima ronda de este contribuyente ok.
        @contribuyentet_segun_serial.save
        @mega_sum = determinar_valor_del_megajackpot_neto() # esto para la variable @mega_sum no sea nil on reply ok.
        render plain: "Mega1-#{@mega_sum}-sigaparticipando" and return # Primera vez, inscribo contador inicial, y respondo que sigaparticipando en las demas ok.
      end


      #calcular y aplicar la retencion del aporte:
      @delta_total_in_recaudado = (@contador_mq_mj.to_i - @contribuyentet_segun_serial.countermeterold.to_i)
    #  @rebaja_del_aportemega =  ( @delta_total_in_recaudado * @margen_de_retencion_mnt_plataforma )  # Debe ser float normal, no redondear decimales porque se va a perder mucho, recuerda que el mega es la sumatoria del aporte de todos los contribuyentes. sin redondear este atributo por ahora ok. ok, ted. @contribuyentet_segun_serial.
      @aporte_neto_mega = @margen_del_mega * @delta_total_in_recaudado #( @delta_total_in_recaudado - @rebaja_del_aportemega )

      #actualizar el aporte neto de ese contribuyente:
      @contribuyentet_segun_serial.aportemega = @aporte_neto_mega.to_f.round(4).to_s # ensure decimal values ok, seran sumados todos los aportes de todos los contribuyentes mas el valor incial y ese si es el Megajackpot.to_i se puede redondear ok. ted. only ok.


      #salvar el objeto para actualizar registro:
       @guardar_ok = @contribuyentet_segun_serial.save

       #Considerar caso en que no se pueda guardar normal el registro ok:
       if not @guardar_ok
        render plain: "Mega2-E5-sigaparticipando" and return # Responde codigo de error E5: indica error 5. Error saving register ok. ted.
       end

     
      #Funcion que calcula y nos retorna el valor del Megajackpot Neto:
      @mega_sum = determinar_valor_del_megajackpot_neto()

      #veficiar el trigger y responder de una vez si no cumple ok:
      # Si el acumulado es mayor que el trigger, sortear. De lo contrario siga participando.
      #Nota: el sorteo del megajackpot se hace solo si la ronda del juego en la maq es ganadora, si no es ganadora se act los acumulados only y no esta aqui abajo ok. Esto se logra con este flag: @no_ganador_update_only  ok ted.
      if ( (@mega_sum.to_i > (@trigger_megajackpot.to_i + @fondo_inicial.to_i ) ) && ( @no_ganador_update_only != "rondanoganadora") ) # Esto para que no lo empiece a sortear 100 monedas antes de llegar al trigger por ejemplo, esto por el valor incial seteado ok. ted.
        #sortear 1 de 20,000 partiendo de 1 jugada por minuto * 60 = 60 jugadas por hora * 5 horas al dia = 300 jugadas por dia por ruleta * 20 maqs operando = 6,000 boletos de sorteo al dia * 3.3 dias jugando de ese modo sale. Esto es una referencia. Todo depende de la suerte y de la frecuencia de juego de cada maq. ok. ted. aprox test.
        if (50 == rand(20000)) 
          #contribuyente ganador, procesar pasos restantes.
         registro_flag = registrar_ganador_historial_megajackpot(@serial_mq_mj, @mega_sum) # flag value will be true or false,  Registrar ganador segun parametros enviados: serial y monto ganador. nota: atreves del serial se incluyen mas detalles del ganador ok. incluir fecha, serail mq, datos del ganador y detalle de los aportes de cada contribuyente para el pago del premio ok. ted.
         
         #TO DO PENDIENTES:
         #FIX LA PARTE DE LOGICA DE ARRIBA, CONTADORES OLD Y NEW DEL ACUMULADO KLK PDTE OK. TED.
         #FIX EN LA PARTE DEL RESET SI SETEAR EN CERO CNTADORES O LAST VALUE CREO OK.
         #PROVBAR MJ GANADOR CON JUGADAS Y SI PIERDE NO SALGA, Y ESCENARIO MULTIJUGADORES WIN Y LOSE Y MEGAJACKPOT REPARTICION PROBAR ANOTNADO BALANCES TED KLK

         resetmj_flag  = resetear_megajackpot_contadores() # resetear el megajackpot (aportes en 0) y los contadores de cada contribuyente ok.
          
          if ( registro_flag && resetmj_flag )
            # todo normal con el reset y registro al historial del ganador, anunciar que es ganador y terminar.
            render plain: "Mega3-#{@mega_sum}-ganador" and return # Ok.
          else
            #hubo algun error con el proceso del reset o del historial, informar error 6, guardar logs y no anunciar ganador. Verificar en logs y corregir porsible causa ok.
            #Lo verificas en los logs y te das cuenta si el megajackpot baja de valor, por un proceso de reset no completado por ejemplo, etc.. ok
            puts("Error procesando el ganador megajackpot, algun registro no guardado (save) de manera normal, verificar via consola admin only, ok.")
            render plain: "Mega4-#{@mega_sum}-sigaparticipando" and return # Normal, no ganador para no alarmar, pero revisar posible fallo, buscar en el historial de ganadores, detalles, etc.. Restaurar monto de ese megajackpot y anular last process en caso de ser necesario para resolver a la normalidad ok ted. 
          end
          #registrar el historial
          #procesar y resetear si ganador
         
          #setear al minimo el megajackpot con valor iniciar y guardar
          #responder si o no klk


        else
          render plain: "Mega5-#{@mega_sum}-sigaparticipando" and return # Si no es agraciado en el sorteo, terminar y que siga participando. ok. 
        end

       
      else
        render plain: "Mega6-#{@mega_sum}-sigaparticipando" and return # Si no alcanza el trigger responder normal Mega-Valor-Sigaparticipando.
      end



    else
      #si llega aqui es porque no es valido o el acceso va a ser web para mostrar todos los contribuyentes detallados con la vista gral de rails, pero para eso debo enviar un valor especifico en el parametro de contador para que el controlador sepa que es una consulta web ok, asi:

      if index_contador_param_ted[:contador] == "detallado_web"
         @contribuyentets = Contribuyentet.all # esto termina aqui y la vista se va procesar con la de rails default listando en tabla todos los contribuyentes con sus aportes ok. ted.
         return # retorna mostrando la vista normal de rails, ya que no se especifico ningun render ok. default.
      end

      render plain: "X. Not a valid member or counter." and return #

    end

    #recibir param  serial, contador
    #procesar y responder si ganador si o no. etc.
    #render plain: @respuesta_enviar_arduino_genuino.to_s and return #


  end

  # GET /contribuyentets/1
  # GET /contribuyentets/1.json
  def show
  end

  # GET /contribuyentets/new
  def new
    @contribuyentet = Contribuyentet.new
  end

  # GET /contribuyentets/1/edit
  def edit
  end

  # POST /contribuyentets
  # POST /contribuyentets.json
  def create
    @contribuyentet = Contribuyentet.new(contribuyentet_params)

    respond_to do |format|
      if @contribuyentet.save
        format.html { redirect_to @contribuyentet, notice: 'Contribuyentet was successfully created.' }
        format.json { render :show, status: :created, location: @contribuyentet }
      else
        format.html { render :new }
        format.json { render json: @contribuyentet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contribuyentets/1
  # PATCH/PUT /contribuyentets/1.json
  def update
    respond_to do |format|
      if @contribuyentet.update(contribuyentet_params)
        format.html { redirect_to @contribuyentet, notice: 'Contribuyentet was successfully updated.' }
        format.json { render :show, status: :ok, location: @contribuyentet }
      else
        format.html { render :edit }
        format.json { render json: @contribuyentet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contribuyentets/1
  # DELETE /contribuyentets/1.json
  def destroy

     redirect_to "/contribuyentets", notice: "X. Not allowed, please contact support for this type of operation." and return    
     
      #  @contribuyentet.destroy
      #  respond_to do |format|
      #    format.html { redirect_to contribuyentets_url, notice: 'Contribuyentet was successfully destroyed.' }
      #    format.json { head :no_content }
      #  end

  end

  private

    #Funcion que determina el valor del megajackpot neto (descuentos aplicados) ok ted:
    def determinar_valor_del_megajackpot_neto
      #Hacer un pequeno ajuste de la logica ya que postgress no me esta sumando todos los atributos del Tipo String. Ok. Recorrer cada entrada y hacer un casting to_float para sumar todos los decimales ok. ted.
      suma_decimal = 0 #Contribuyentet.all.sum(:aportemega).to_f 
      
      Contribuyentet.all.each do |contribuyentet|  
        suma_decimal += contribuyentet.aportemega.to_f # voy sumando los valores decimales, luego del casting to_float porque postgres no devuelve la sumatoria global de atributos del tipo string, ok ted. Elimino el error que sale en el log de produccion ok.
      end
      #suma_decimal = Contribuyentet.all.sum(:aportemega).to_f # De String a Flotante decimal ok ted. Suma de aportes decimales ok. + @fondo_inicial # adicionar el fondo del mega. ok. 
      
      suma_rebaja_mnt_plataforma = suma_decimal - ( suma_decimal * @margen_de_retencion_mnt_plataforma.to_f ) # a la megasuma de decimales le descuento el margen de retencion de mnt plataforma para formar el megajackpot real a mostras mas el valor inicial del mismo que adicionaremos abajo ok. ted.
      valor_neto_retornar = suma_rebaja_mnt_plataforma.to_i + @fondo_inicial.to_i # Este es el Megajackpot con descuentos aplicados y el fondo incial ok. Este es el valor REAL a mostrar del megajackpot ok ted.
    end

    
    def registrar_ganador_historial_megajackpot(serial_mq_mj, cantidad) 
       contribuyentet_ganador = Contribuyentet.where( :serialmq => serial_mq_mj ).first

       montoxcontribuyente_detallado_aporte_al_megajackpot = []
       #Ingresar detalles de cuota de pago del megajackpot de cada contribuyente
       Contribuyentet.all.each do |contribuyentet|
         montoxcontribuyente_detallado_aporte_al_megajackpot << "Sucursal: " + contribuyentet.consorcio.to_s + " - " +  contribuyentet.sucursal.to_s + ", TerminalSerialMq: " + contribuyentet.serialmq.to_s[8..11]  + ", Aporte: " +  contribuyentet.aportemega.to_s + " | "
       end
       #crear objeto del modelo Ganadoresmegajackpot para ingresar el nuevo ganador:
       nuevo_ganador           = Ganadoresmegajackpot.new
       nuevo_ganador.fecha     = Time.now
       nuevo_ganador.consorcio = contribuyentet_ganador.consorcio
       nuevo_ganador.sucursal  = contribuyentet_ganador.sucursal
       nuevo_ganador.localidad = contribuyentet_ganador.localidad
       nuevo_ganador.serialmq  = contribuyentet_ganador.serialmq
       nuevo_ganador.cantidad  = cantidad # Monto ganador del megajackpot a registar ganador en el historial para es contribuyente ganador ok. ted.
       nuevo_ganador.montoxcontribuyente =  montoxcontribuyente_detallado_aporte_al_megajackpot.to_s # El arrego pero en String. ok ted.
       
       nuevo_ganador.save # devuelve true or false ok ted.

    end


    def resetear_megajackpot_contadores
      reset_flag_ok = true # flag de control inicial ok.
      # iterar cada registro y resetear valores a cero para el nuevo conteo del nuevo megajackpot ok:
      todos_contribuyentes = Contribuyentet.all

      todos_contribuyentes.each do |contribuyentet|
        contribuyentet.countermeterold = 0
        contribuyentet.countermeternew = 0
        contribuyentet.aportemega = 0
        if not contribuyentet.save
          reset_flag_ok = false # el flag de ok se pone en false is hay algun registro que no se haya guardado normalmente. ok. ted. buenas practicas de prog ok.
        end
       
      end # fin del bloque Contribuyentet.all.each do |contribuyentet|

      reset_flag_ok # retorna true or false ok. ted.
      
    end # fin de la funcion o metodo: resetear_megajackpot_contadores


    # Use callbacks to share common setup or constraints between actions.
    def set_contribuyentet
      @contribuyentet = Contribuyentet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contribuyentet_params
      params.require(:contribuyentet).permit(:consorcio, :sucursal, :siglas, :localidad, :serialmq, :countermeterold, :countermeternew, :aportemega)
    end
    
    #algunas acciones definidas por ted ok:
    def index_serial_param_ted
      params.permit(:serial) # Permito la entrada del serial de la mq a sotearse en ese momento en el megajackpot.
    
    end
      #algunas acciones definidas por ted ok:
    def index_contador_param_ted
      params.permit(:contador) # Permito la entrada del serial de la mq a sotearse en ese momento en el megajackpot.
    
    end



end # fin de la clase
