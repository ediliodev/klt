class TransaccionestsController < ApplicationController
 #http_basic_authenticate_with name: "ventas", password: "456456", except: :index
 before_action :hacer_login, except: [:index] # esto para hacer login ventas page ok.
 



#Elvalua tipo de usuario loggeado y redirecccionar apropiadamente:
#ventas => a ventas
#supervisor =>  a reportes y session[etc..] maquinas_activar para desactivar limites de rango de fechas de los reportes
#admin => maquinats y futuro cambio de contrasenas por modelos. ok.
#if session[:current_user].to_s == "supervisor"
 # redirect_to "/reportets/new"  and return  
#end


  skip_before_action :verify_authenticity_token # arduino json old
  before_action :set_transaccionest, only: [:show, :edit, :update, :destroy]
  before_action :index_transaccionest_params_only, only: [:index, :create]
  before_action :index_transaccionest_param_comfirmation_only, only: [:index, :create]
  before_action :index_transaccionest_param_cashout_only, only: [:index, :create]
  before_action :index_transaccionest_param_confirmar_este_pago, only: [:index, :create]
  

  #before_action :verificar_violacion_simple
  #before_action :verificar_violacion_mayor
  
  #posible before filter para param_cashout de Luis.
  before_action :validar_hw_punto_de_venta, only: [:index, :new, :create]
 
  #verificar la secuencia de locked, lockeo o lackeo del punto de venta:
  before_action :veficiar_lockeo_pos, only: [:index, :new, :create]

  after_action :registro_login_ventas, only: [:index, :new] # metodo definido en ApplicationController.rb para poderlo llamar en cualquier controlador. ok ted. link:https://stackoverflow.com/questions/35588995/rails-call-same-after-action-method-from-different-controllers
  
  @hw_equipo_no_autorizado = false # variable globar de control del hw server (anticlone) que se modifica en el before_action y en el index ok
  
  #MUY IMPORTANTE, SW_ID_POS DEBE SER UNIQUE EN CADA COMPILACION OK, TED OJO.
#  @SW_ID_POS = "kpos-07-20-01" # ESTO ESTA COLOCADO COMO VARIABLE GLOBAL EN APPLICATION CONTROLLER OK. TED. Consultar link: https://stackoverflow.com/questions/35045076/creating-a-global-variable-to-all-the-controllers-in-rails


  # GET /transaccionests
  # GET /transaccionests.json
  def index
    

         request.request_id = nil # desabilitar
         request.session_options[:defer] = true  # esto evita enviar la cooke en el header ok ted

          #response.headers['Connection'] = ''
        #  response.set_header("Set-Cookie", "klkkkkk")
        response.headers['X-Frame-Options'] = ''

        response.headers['X-XSS-Protection'] = ''
        response.headers['ETag'] = ''
        response.headers['Content-Type'] = ''
        response.headers['X-Content-Type-Options'] = ''
        response.headers['Cache-Control'] = ''
        
       # render plain: "@bien^" and return
        
        
        

          #datos = []

         # response.headers.each do |key, value|
         #   puts key.to_s + "->"  + value.to_s 
            
          # end

          
          #response.headers['Connection'] = datos.join("-").to_s

          #remove_keys = %w(X-Runtime Cache-Control Server Etag Set-Cookie)
          #response.headers.delete_if{|key| remove_keys.include? key}
          #request.runtime_id = nil
          #layout false
          #render :layout => false, plain: @transaccion_actual_objeto.comando.to_s  and return
          #Rails.application.config.middleware.delete(Rack::Runtime)
          #response.headers.create = {}
       #   render plain: "pocho" and return
       





    #candado # 1
    #Vericiar que hw todo ok primero ok ted. Nota: podra tratar de act online si la razon es licencia vencida, de lo contrario 'Locked system. Contact support' ok ted hw o time modification. ok.
   # activar_producto(15)

  #  if verificar_violacion_simple_por_vecimiento_only  # busca que razon bloqueo sea Licencia vencida
  #    tratar_de_actualizar_online # funcion que hace un cul to update only if reason is por vencimiento de licencia only ok ted.
  #  end


    if verificar_violacion_simple #  busca el asterisko
      render plain: 'Locked System. Contact support.' and return
      #modificar primer registro de reporte indicacon sistema lockeado
      #setear un bit or flag indicator para que la vista del controller se modifique informando del bloqueo y guardando y mostrando el locked code.
      #procesar el desbloqueo klk.
    end


    #render plain: '@cash1000^12345#' #comando Ruleta de Luis.

    #@accesot = Accesot.new
    #@accesot.usuario = "ventas"
    #@accesot.tipoacceso = "login"
    #@accesot.fechayhora = Time.now
    #@accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
    #@accesot.save

   # registro_login_ventas
    #Este link puede ser util en un fitiro si deseamos identificar el cliente por ip:
    #request.remote_ip
    #request.env['HTTP_X_REAL_IP']
    #https://stackoverflow.com/questions/4465476/rails-get-client-ip-address
    
    # Por ahora lo haremos con un serial param enviado por el cliente usando en mismo verbo GET. Para identificar que quien es la peticion. ok. ted.
    @param_serial = index_transaccionest_params_only[:serial] # Extraer el parametro :serial de la peticion GET.
    @param_confirmation = index_transaccionest_param_comfirmation_only[:confirmation]
    @param_cashout = index_transaccionest_param_cashout_only[:cashout]
    #verifico que el serial no sea nulo y sea valido (Existente en Maquinas registradas). Si es nulo el serial de considera tambien en los bloques de codigos despues de este bloque if end. ok ted. Este bloque es solo para detectar un serial no registrado y redireccionar antes de que de error en el modelo.find(maquina_con_serial_no_exite_en_la_tabla) ok ted mas o menos entiendes la idea.
    # Osea, Si no es un para_serial vacio y no existe en el modelo, redirecciono, no esta inscrito. ok. ted.

    #leer el parametro ptgold modulo de confirmacion de pagos si viene este get request ok.
    @param_confirmar_este_pago = index_transaccionest_param_confirmar_este_pago[:confirmar_este_pago]
    




    # ***************************************************************************
    #SECCION DE VERIFICACION DE PAGOS POTOGOLD MOULOS CONFIMARCIONES
    #ANTES QUE NADA VAMOS A VERI SI LA SOLICITUD DE ESTE GET PROVIENE PARA VALIDAR UN PAGO DE UNA PTGOLD . NUEVA LOGICA CONFIRMACIONES TED GIO GG

    if ( @param_serial.include?("01-001-0") ) && ( @param_confirmar_este_pago != nil )
      #estamos dentro de la seccion de confirmar pagos arrivados
      # aqui la idea es verificar que la trama llega integra (checksum) y, de ser asi guardar este pago y responder lo mismo de trama integra apra atras para que arduino valide ok. De lo contraio no procesar lo deseado ok, logica alterna dejabo ok

      #extraer la informacion de la trama recibida:
      @cantidad_trama = @param_confirmar_este_pago.to_s.split("|")[0] 
      @tag_id_trama = @param_confirmar_este_pago.to_s.split("|")[1]   

      # aqui tenemos que validar si la trama llego integra o no para continuar la logica
      @checksum_recibido = @param_confirmar_este_pago.to_s.split("|")[2].to_s
      @data_recibida = @cantidad_trama.to_s + @tag_id_trama.to_s
      

      if(@data_recibida != @checksum_recibido)
        #Si entra aqui es porque la data no vino integra, abortar con respuesta ok.
        render plain: "@" + "errorchecksum" + "^" and return # le respondo esto al modulo ok
      end



      #verificar si el pago existe (dos dias para aca mejor)
      p = Postransaccionest.between_dates(Time.now - 2.days, Time.now ).where(:serial => @param_serial.to_s, :cantidad => @cantidad_trama, :jugador => @tag_id_trama).first
      # si p existe o no nil emptyentonces esta creado y le devuelo trama igual reply ok, de lo contrario se crea
      # nola buscar un objeto especificao (.first por ejempo) da nil si no aparece y un arrady (dotos) da empty si el array esta vacio [] ok ted. Rails documentation
      if p.nil?
        # si esta vacio hay que crear ese pago now
        p = Postransaccionest.new
        p.serial = @param_serial
        p.cantidad = @cantidad_trama
        p.jugador = @tag_id_trama # aqui sera almecenado el tagid ok ted.
        
        if p.save
           render plain: "@" + @param_confirmar_este_pago.to_s + "^" and return # todo ok y responder misma trama ok 
        else
           render plain: "@" + "notsaved" + "^" and return # responder esto si tuvo algun error al guardar el pago ok ted.
        end

      else

        render plain: "@" + @param_confirmar_este_pago.to_s + "^" and return # ya esta creado ok. responder la misma trama recibida ok ted.
      end

      
    end # end del if de inicio de SECCION DE VERIFICACION DE PAGOS POTOGOLD...





    #FINDE LA SECCION LO DEMAS CONTINUA IGUAL NORMAL DEBAJO OK TED.
    # ***************************************************************************



    #trabajar aqui la parte de arduino genuino crc para pot of gold only (la pog es que lo manda en el param serial, ej. GET /transaccionests?serial=01-001-0101p25-26-27-28 HTTP/1.0"); ok ted. split it
    if @param_serial.include?("p")

      @variables_crc_arduino = @param_serial.split("p")[1] # 25-26-27-28 => a-b-c-d
      @param_serial = @param_serial.split("p")[0]

      a = @variables_crc_arduino.split("-")[0].to_i || 0 # en caso que de no haya nada ponerle 0, de todas formas fx result sera el desicivo.
      b = @variables_crc_arduino.split("-")[1].to_i || 0
      c = @variables_crc_arduino.split("-")[2].to_i || 0
      d = @variables_crc_arduino.split("-")[3].to_i || 0
      #@fx_arduino = (4 * a + 5 * b) + (b + 3) * c - (c + a) + (5 * a) + (2 * d) # proceso valor local apar que coincida remoto
       @fx_arduino  = 3*a + b + 2*c + 2*d + 4*b + 16
               #fx = (4 * a + 5 * b) + (b + 3) * c - (c + a) + (5 * a) + (2 * d)

      #debo verificar que este serial exista antes de responer bien, de lo contrario responder mal respuesta u otra cosa: 555. ok.
      @respuesta_enviar_arduino_genuino = "@" + @fx_arduino.to_s + "^" # => @1234^ fx value ok ted.

      @maquina_segun_serial = Maquinat.where(:serial => @param_serial).first  # Verifico que esta maquina exista el objeto, esto para asegurarme que fue un modulo arduino valido ted que pregunto ok.

      if @maquina_segun_serial 
        render plain: @respuesta_enviar_arduino_genuino.to_s and return # esto para manejar de una vez el asunto de la peticion de confirmacion genuina del pos
      else
        render plain: "@genuino not valid for response^" and return # Cualquier otra respuesta no valida, esto porque ese serial no existe en el pos para atender esta peticion. 
      end
      
    end

  

  #LUISITO B PARTE DE LOS PAGOS, CON EL SERIAL GENERICO 03-000- PERO SE ENTIENDE NO HAY RULETA WEB TED OK SOLO LUIS POR AHORA OK. IGUAL RESPONDERIA LO MISMO SI RULETA TED WEBOK
  #HACER EL PAGO DE LUIS EN EL MISMO GET PROTOCOL PORQUE ES MAS SIMPLE PARA EL eL GET QUE UN POST POR SOCKET CON PROTOCOLO HTML EN JSON FORMAT OK TED.
  #------------------------------------
 #pdte poner confirmation here fixez sept 2022 klk?

    if ( @param_serial.include?("03-000-") ) && ( @param_cashout != nil )# es un cashout de luis a traves del get verb hmtl request, procesarlo.
      # me parece que aqui Luis deberia enviarme una confirmacion del pago y yo presponderle con el mismo codigo de confirmaciond el pago, y tbn buscarlo anteas en la Bdatos para ver si ya ese pago se registro o no .. pendiente desarrorlarlo o ver klk ok ted.  

      @postransaccionest = Postransaccionest.new()
      @postransaccionest.serial = @param_serial.to_s

      #hacer un split para sacar el jugador del cashout(Luis no lo nesecito, pero si es mi ruleta web si, de todas formas el split no afectara al protocolo de Luis ok ted.
      @cashout_jugador = @param_cashout.split("j")[1] || "?" # retorna nil si no hay jugador, ? en caso de no recibir nada, no creo que pase ("?"), pero por si acaso,  por la logica del controlador rails de mi ruleta. ok. en Luis puede ser nil o jugador 1 default ok. ted.

      @postransaccionest.cantidad = @param_cashout.to_i.to_s # .to_i me segura que sea un integer. Si viene algo como: @param_cashout = "A253asdff8" .to_i lo pone en cero. ok ted. De todas formas  Asumo o espero (pero sin descuidarme) que luis manda un numero en formato string y no letras ni trash characters.
      @postransaccionest.jugador = @cashout_jugador # registro el id del jugador que envio el cashout. ted web roulette. ok.
      
      #@postransaccionest.cantidad = 8
      
      #gesiontar rifa jp azul en mqs de LUIS(nota as ptgo lo hacen con post verv html resouce post creo)
      participar_jp_azul_maqs_luis(@postransaccionest)

        if @postransaccionest.save
          #responder plaintext a Lius, ok:
          st = "@cahsout" + @postransaccionest.cantidad.to_s + "^" + rand(10).to_s + rand(10).to_s + rand(10).to_s + rand(10).to_s  + "#"   # @cashout100^2176#
     

          #limpiar el header del render plain para la parte de pago LUIS reply:
          request.request_id = nil
          render plain: "#{st}"  and return 

        else
          render plain: "error: no se pudo guardar el pago." and return  
        end
    

    end



#----------------------


    if @param_serial != nil
       @mostrar_vista_web_normal = false # muestro la vista en modo aarduin index con el comando basico ok. ted.  
       @maquina_segun_serial = Maquinat.where(:serial => @param_serial).first   || "no existe" # provisional production v1 ok ted. el "no existe no va a ser necesario por la validacion de arriba de buscar el serial visitante ver si existe en el Modelo (tabla), mejoras del codigo en real time ok ted."
       if @maquina_segun_serial.id # me aseguro que sea un objeto (con id por su puesto y no otra cosa true)
          @maquina_segun_serial.lastseen = Time.now
          @maquina_segun_serial.save
       end
    end

    if @param_serial == nil || @param_serial.empty? 
       @mostrar_vista_web_normal = true # Estom para mostrar web normal condicion que se revisa en la vista index de esta action
    end

   #@transaccionests = Transaccionest.all # Rails refault. ?? Ted comentado sin probar 26feb 2020. ojo. any error uncomment ok
   @transaccionests = Transaccionest.last # solo para que no sea nil este objeto, por lo del comment de arriba ok ted. agilizar bdatos.

   @transaccion_actual_objeto = nil # inicializo variable en nil.

   if @param_serial != nil
     #Solo buscar solicitudes pendientes dentro de los ultimos 5min, las demas del dia y dias anteriores no califican. (para que la maq nos se pase el dia enviando creditos viejos. ok. 5min. solamente.)
     # @tiempo_5min_antes = (Timen.now - 5.minutes)
     

     @transaccion_actual_objeto_no_existe = false # inicializo, ojo no borrrar por la logica de reponder con comando o con @bein plai mas abajo esta misma variable ok
    
     @transaccion_actual_objeto = Transaccionest.where(:maquinat_id => (Maquinat.where(:serial => @param_serial).first.id), :status => "pendiente").last # || Transaccionest.first # Dejo el UTC normal de la base de datos, resto 5 min a Time.now, Luego le sumo 4 horas para IGUALAR al timepo UTC, no a mi zona horaria, la cual serial -4GMT (serial restando para igualar a mi zona, pero como voy a comparar coon UTC sumo +4hr e igualo al tiempo(zona horaria) UTC para restar los 5min y comparar ok.)
    #render plain: "@bien^0000#" and return  # 
    if ( @transaccion_actual_objeto.nil?   || @hw_equipo_no_autorizado == true ) # evito enviar creditos desde el web server. Esto es si intentan act la bdatos con un cash pero desde el rails app server la logica de este controlador no lo va a enviar al arduino en la vista (el comando del cash). puede que se sume en la venta pero no llega, porque no esta autorizado ese PoS. posible intento de clonar. ok ted. (La parte de la logica de la variable hw_equipo_no_autorizado ok.)
        @transaccion_actual_objeto_no_existe = true # activo flag para que no ponga comandos en la vista de este controlador (index.html) y retorno a la vista, fin de la logica de esta action (def index end) en el controlador. ok. ted.
        
        #Si es potogold y no hay acreditation pendiente responder de una vez para salir @bien^ ok
         if ( @param_serial.include?("01-001-") )# es una ptgold
          request.request_id = nil
          render plain: "@bien^0000#" and return  # ok
         end


        if ( @param_serial.include?("03-000-") ) && ( @param_confirmation == nil )# es un get credit de Luis porque viene sin confirmacion. Reposonder en format render plain to Luis
          request.request_id = nil
          render plain: "sincreditosporahora" and return 
        end

        if ( @param_serial.include?("03-000-") ) && ( @param_confirmation != nil )# es un get credit de Luis porque y viene con confirmacion. Reposonder en format render plain to Luis
           request.request_id = nil #deberia dejar esto aqu no lo tenia febrero 2024?
          render plain: "ok" and return  # esto seria como un ok late. late confirmation por parte de mq Luis.
        end
        
        #aqui retornaria sin render plain, o sea devuelve la pagina web normal peson sin comando, el arduino procesa leyendo la pagina html y filtrando el comando. ok.

        return  
    end

    # @fecha_fix_utc = @transaccion_actual_objeto.created_at - 4.hours

     if ( (@transaccion_actual_objeto.created_at ) >  (Time.now  - 1.minutes ) ) #&& ( @param_confirmation == nil ) # ##me aseguro que no sea un confirmation dela ruleta de Luis. Esto para evitar que se acredite si el get viene el parametro serial y el parametro confirmation
      #if ( @fecha_fix_utc >  (Time.now  - 5.minutes ) )
      # @transaccion_actual_comando = @transaccion_actual_objeto.comando #comnado para ese serial, pendiente de ejecutar.
       # ahora actializamos el status de pendiente a Ok. Comando completado.

       #poner ok solo si no es la de Luis, si es la de luis el ok se pone con el nuevo protocolo (confirmation code mas abajo ok)
      if not ( @param_serial.include?("003-000-00") ) # status credito ok (acreditado) si no es de las mqs de LUIS ok PTG arduino, ted r12v (cuyo seriales so diferentes: 003-000-10...)
        
        #  ANTES DE CONFIRMACION CREDIT PTGOLD ERA ASI OK
        #  @transaccion_actual_objeto.status = "ok" # futura modificacion ted gg ptgo get credti confirmacion antes de poner ok ted.
        #  @transaccion_actual_objeto.save  # lo mismo aqui futura modificaion ted gg ptgold credit ok.
     
      end
      
       
       #[hasta arriba arduin pog y rulera americana ok por el serial range code. ok. 001-..etc..]
       
       #preparar parte A o B de LUIS: 
       #LUISITO A (PRIMERA RESPUESTA DE ACRIDITACION: ENVIA EL COMANDO DE ACREDITACION)
       #A) acreditar respondiendo con el comando en render plain text Luis.
       if ( @param_serial.include?("03-000-0") ) && ( @param_confirmation == nil )# es un get credit de Luis porque viene sin confirmacion. Reposonder en format render plain to Luis
          request.request_id = nil # desabilitar headers id para enviarlo plain a luis ruleta. OJO: tambien se removio el header llamado x-runtime en setting asi: Rails.application.config.middleware.delete(Rack::Runtime) , puesto en config/initializers/assets puesto manualmente por ted ok. link: https://stackoverflow.com/questions/984633/how-to-remove-x-runtime-header-from-nginx-passenger
          #request.runtime_id = nil
          #layout false
          #render :layout => false, plain: @transaccion_actual_objeto.comando.to_s  and return
          #Rails.application.config.middleware.delete(Rack::Runtime)
          render plain: @transaccion_actual_objeto.comando.to_s and return #+ "j" +  @transaccion_actual_objeto.jugador.to_s and return # ok notaL aqui le agregue el jugador adicional PARA MI RULETA WEB, ESPERO NO AFECTE A LA RULETA DE LUIS CON LA LOGICA, NOTA: LO PUSE (EL JUGADOR) AL FINAL (DESPUES DEL #) ADICIONADO PARA USAR EL JUGADOR EN MI RULETA OK. LUIS NO SE AFECTA MUY PROBABLEMENTE, OK. TED. # ya esta creado con el formato que requiere Luis, solo falta hacerle el render plain comando ok ted.
       end

       #FORMATO ***RULETA MIA TED*** R12: 003-000-1001 OK FILTER AQUI SI MANDO EL JUGADOR PLAYER OK. CON LA DE LUIS SI MANDAS LA TRAMA DEL COMANDO REPLY CON EL PLAYER J1 NO ACREDITA OK. LA DE ARRIBA DE LUIS DE BEDE MANDAR SIN PLAYER OK TED.:
       if ( @param_serial.include?("03-000-1") ) && ( @param_confirmation == nil )# es un get credit de Luis porque viene sin confirmacion. Reposonder en format render plain to Luis
          request.request_id = nil # desabilitar headers id para enviarlo plain a luis ruleta. OJO: tambien se removio el header llamado x-runtime en setting asi: Rails.application.config.middleware.delete(Rack::Runtime) , puesto en config/initializers/assets puesto manualmente por ted ok. link: https://stackoverflow.com/questions/984633/how-to-remove-x-runtime-header-from-nginx-passenger
          #Rails.application.config.middleware.delete(Rack::Runtime) # ESTO SE PUSO EN CUALQUIER ARCHIVO DE CONFIG/INITIALIZER OK. TED.
          render plain: @transaccion_actual_objeto.comando.to_s + "j" +  @transaccion_actual_objeto.jugador.to_s and return # ok MI RULETA CREDIR COMMAND Y PLAYER J-16 OK.
       end



      
      #B) Procesar respuesta  ##Lpor ahora no devuelto nada. Comando de credito llegado confirmation. Luis envia una confirmacion de algun credito recibido previamente. no hacer caso o pudiera grabar en una tabla los acreditados confirmados por la mqs de luis. 
       if ( @param_serial.include?("03-000-") ) && ( @param_confirmation != nil )# es un get credit de Luis porque viene sin confirmacion. Reposonder en format render plain to Luis
            #nota agregar Header final 3l protocolo de luis # el caracter # se corta en la url get web, adicionarlo manual
            @param_confirmation = @param_confirmation #  # + "#".to_s

            #@transaccion_actual_objeto = Transaccionest.today.where(:maquinat_id => (Maquinat.where(:serial => @param_serial).first.id), :comando => @param_confirmation.to_s).last # 
            #@transaccion_actual_objeto = Transaccionest.today.where(:maquinat_id => (Maquinat.where(:serial => @param_serial).first.id), :comando => @param_confirmation.to_s).last # 



          @maquinaidd = Maquinat.where(:serial => @param_serial).first.id
          @luisidd = @param_confirmation.to_s #   1234 [Luis solo manda numero de la confirmacion]

          #Transaccionest.today.where("maquinat_id LIKE (?) AND comando LIKE (?)", "%#{@maquinaidd}%"  , :maquinat_id => , :comando => @param_confirmation.to_s).last # 
          #busqueda especial ya que el atributo comando tiene la cantidad y le confirmation number, hacemos la busqueda con LIKE SQL (Probar el postgres ojo ok)
          
          #HACER ESTO DE UNA MANERA DISITINTA PORQUE EL LIKE COMMANDO NO ME ESTA FUNCIONANDO EN POSTGRES
          #@transaccion_actual_objeto = Transaccionest.today.where("maquinat_id LIKE (?) AND comando LIKE (?)", "%#{@maquinaidd}%", "%#{@luisidd}%").last

          #prueba logica para postgres:
          #buscar todas lastrsansacciones de hoy de esa maquina con status pendiente y luego revisar cada una con el confirmation code
          @transacciones_de_esa_maquina_hoy = Transaccionest.today.where(:maquinat_id => @maquinaidd, :status => "pendiente")

                    
          if not @transacciones_de_esa_maquina_hoy.empty?
               #buscar esa confimacion para pasar de pendiente a ok procesado:

               @transacciones_de_esa_maquina_hoy.each do |transaccion|
                #extraer el plain de este string: comando: "@cash100^3923#"
                #plain_confirmation_code = transaccion.comando.split("^")[1].split("#")[0] # => 3923
                #(@transaccion_actual_objeto.created_at ) >  (Time.now  - 1.minutes ) )
                #Si encontramos una transaccion de hoy con estado pendiente, de hace menos de5mins y con la misma confirmacion que ls recibida a comparar, entonces validamos esa transaccion ok acreditada.
                if ( (transaccion.comando.include?("^#{@luisidd}#")) && (transaccion.created_at > (Time.now - 5.minutes))  )
                  transaccion.status = "ok"
                  transaccion.save
                  render plain: "ok" and return
                end 
                
              end

              #si termina de iterar y no lo encuntra entoncestambien retornarno encontrado a pesardebuscar enarrya ok ted
              render plain: "no_encontrado_no_acreditado_debes_anularlo" and return

          else
           #vacio                   
           render plain: "no_encontrado_no_acreditado_debes_anularlo" and return

          end



        #  if not @transaccion_actual_objeto.nil?  # status credito ok (acreditado) si no es de las mqs de LUIS ok PTG arduino, ted r12v (cuyo seriales so diferentes: 003-000-10...)
        #    @transaccion_actual_objeto.status = "ok"
        #    @transaccion_actual_objeto.save  
        #    render plain: "ok" and return
        #  
        #  else
        #   render plain: "no_encontrado_no_acreditado_debes_anularlo" and return
        #   #render plain: @param_confirmation.to_s and return
        #      
        #
        #  end

       end

#ESTO HAY QUE PONER ARRIBA EL OK DE LUIS. SOLO PROCESAR LOS GET LOS ACKS ATENDERLO DE PRIMERO EN DEF INDEX (LUEGO DEL PARAM)


    else

       #posible fix de la ruleta de LUIScon los NULOS muy rapidos consecutivos:
       #Que lo anule pero luego de un timepo transcurrido sin acreditar?
       #if ( (@transaccion_actual_objeto.created_at ) >  (Time.now  - 1.minutes ) )  #SI ES MAS VIEJA QUE UN MINUTO, Y NO ES DE NADIE O NO CUMPLE LAS CONDICIONES DE ARRIBA, ANULAR
         #ESTO PARA PROBAR LO DE FAST ANULATION RULETA LUIS. KLK   
         #Ok nota: on el if ondition da error dejarlo asi nornnal por ahora ok
         #@transaccion_actual_objeto.status = "nulo"
         #@transaccion_actual_objeto.save
         #@transaccion_actual_objeto.comando = nil # asigno nil para que si ya paso 5 min, else devuleve este objeo en la vista del index con el atrubito comando en nil. arduino no ejecuta comando de creditos viejos ok.
       #end
       
       if( ( @param_serial.include?("03-000-") ) && (  @param_confirmation == nil ) )   
         # render plain: "sincreditosporahoraBBBBBBBMuyTarde " # sin credito por ahora porque hay una anuclacion de un credito expirado ok ted.
          render plain: "sincreditosporahora" and return # y se anuloo el credito pasado el tiempo
       end
      

       if( @param_serial.include?("03-000-")  and ( @param_confirmation != nil ) )
         ## render plain: "okBB" + " Serial:  " + @param_serial + "Confirmation : " + @param_confirmation 

         ##render plain: "ok" and return # un ok pero si fue que Luis envio un confirmation tarde, ya anulamos el credito pero de todas formas hay que responderle a el resquet confirmation. Esto para si la mq estaba apagada (ruleta) por ejemplo y despues de mucho tiempo si la encienden y manda cualquier confirmation en cola hay que procesarlo como quiera respondiendole solamente ok sin acreditar nada aqui. ok ted.
         
         #@transaccion_actual_objeto.status = "nulo"
         #@transaccion_actual_objeto.save  
         #render plain: "nulo" and return # NUNCA SE ANULA ALGO YA ACREDITADO POR LUIS CONFIRMADO CON EL CODE OKunuevo cambios si ya es tarde y manda con confirmation responder nulo. ok nuevo protocolo Luis 3sept2022
       
         #ENTRA AQUI PASADO E1 MINUTO DE AACREDITTACION COM QUIERA, DEBES PROCESARLO, ES ALGO YA ACREDITADO ALLA. REPETIR LOGICA PARA LUIS OK TEST
          @param_confirmation = @param_confirmation  # + "#".to_s
          
          #@transaccion_actual_objeto = Transaccionest.today.where(:maquinat_id => (Maquinat.where(:serial => @param_serial).first.id), :comando => @param_confirmation.to_s).last # 
          

          @maquinaidd = Maquinat.where(:serial => @param_serial).first.id
          @luisidd = @param_confirmation.to_s #   1234 [Luis solo manda numero de la confirmacion]

          #Transaccionest.today.where("maquinat_id LIKE (?) AND comando LIKE (?)", "%#{@maquinaidd}%"  , :maquinat_id => , :comando => @param_confirmation.to_s).last # 
          #busqueda especial ya que el atributo comando tiene la cantidad y le confirmation number, hacemos la busqueda con LIKE SQL (Probar el postgres ojo ok)
          @transaccion_actual_objeto = Transaccionest.today.where("maquinat_id LIKE (?) AND comando LIKE (?)", "%#{@maquinaidd}%", "%#{@luisidd}%").last




          if not @transaccion_actual_objeto.nil?  # status credito ok (acreditado) si no es de las mqs de LUIS ok PTG arduino, ted r12v (cuyo seriales so diferentes: 003-000-10...)
           
            @transaccion_actual_objeto.status = "ok" # modificacion futura tambien confirmaciones pgold gg gio ok
            @transaccion_actual_objeto.save  # futura modificacion gio gg ok tambien
            render plain: "ok" and return
          
          else
             render plain: "no_encontrado_no_acreditado_debes_anularlo" and return
          #  render plain: @param_confirmation.to_s and return
            #Transaccionest.today.where(:maquinat_id => (Maquinat.where(:serial => @param_serial).first.id), :comando => @param_confirmation.to_s).last 
          end


       end
      

      @transaccion_actual_objeto.comando = nil # asigno nil otra vez, esto para forzarlo que esta accion (index) devuelva este objeto. rails devuelve lo ultimio evaulado. esto para la vista html del response para arduino y pog. ok. Lo de arriba es por Luis.

          request.request_id = nil
          render plain: "@bien^0000#" and return  # ok

    end

   else

       if ( @param_serial.include?("03-000-") ) #&& ( @param_confirmation == nil )# es un get credit de Luis porque viene sin confirmacion. Reposonder en format render plain to Luis
          #render plain: "sincreditosporahorafinall" #@transaccion_actual_objeto.comando #|| "nada" # ya esta creado con el formato que requiere Luis, solo falta hacerle el render plain comando ok ted.
          render plain: "sincreditosporahora" and return # final creo nunca llega aqui pero por si acaso. ok dejar.
       end


     #  redirect_to "/transaccionests/new", notice: "No se pudo recibir el param serial de la peticion. Incompleta." and return  
   
   end
   #Comando de la ultima transaccion pendiente de ese cliente de menos de 5 min.
   
   #registro_login_ventas
   #en esta seccion voy a procurar eliminar la vista con todo el body de html que arduino tiene que buscar el comando @cash50^ dentro del html por ejemplo, por un simple render plain: "@cash50^" para minimizar errores y ahorrar tiempo de procesamiento en arduin cpu ok.
   #Esta logica fue sacada de la vista index.html de este controlador, para simpliciar la respuesta aqui mismo al arduin client ok.
    #if @mostrar_vista_web_normal != true
      
      if  (@param_serial != nil )  &&  ( @transaccion_actual_objeto_no_existe != true )

          #verificar si es un comadno para la version multiuser
          #si es un comando ej @s14 entonces actualizar como status => "ok". Esto para que no lo mende muhcas veces hasta que apse el minuto o deje se ser status pendiente. Status ok hace que el modulo no rempita elmenu s14 varias veces ok ted. guandues sgs-52 1ra vez test 06marzo2024ok
          if  @transaccion_actual_objeto.comando.include?("s14") # @s14
            @transaccion_actual_objeto.comando.status = "ok"  # de pendiente a ok de una vez para que se mande solo una vez por solicitud manual ok
          end

          if  @transaccion_actual_objeto.comando.include?("s18") # @s18 
            @transaccion_actual_objeto.comando.status = "ok"  
          end

          render plain: @transaccion_actual_objeto.comando and return # Ej. @cash100^ ? probar ok.   
          #render plain: "@bien^" and return
          
     # else
    #    render plain: "@bien^" and return
      end

      #if ( @param_serial != nil ) # && ( @transaccion_actual_objeto_no_existe == false )
          #render plain: @transaccion_actual_objeto.comando and return # Ej. @cash100^ ? probar ok.   
       #   render plain: "@bien^" and return
          
     # else
    #    render plain: "@bien^" and return
     # end



     
   # end
    # Si llega aqui es porque la vista index.html va a responder a este controlador pero con el mensaje <p style="color: red">X no permitido. Incidente reportado!</p> porque el condition puede ser true esto: @mostrar_vista_web_normal == true ok. no problem ok.


  end # fin de la accion index controller ok


  # GET /transaccionests/1
  # GET /transaccionests/1.json
  def show
  end

  # GET /transaccionests/new
  def new
    #activar_producto(15)
    # aqui ya podemos tener el current user logeado al sistmea collector porque tiene un before filter que dice hacer login ok ted.
   
    #esto para que siempre se mantenga tratando de update online si ya esta vencida. ok. 
    if verificar_violacion_simple_por_vecimiento_only  # busca que razon bloqueo sea Licencia vencida
     if not tratar_de_actualizar_online # funcion que hace un cul to update only if reason is por vencimiento de licencia only ok ted.
      redirect_to '/reportets/new' and return# esto 
     end
    end


    #candado # 2
    if atrasaron_hora 
      lockear_sistema("Intento de Atraso de hora") # funcion en application_controller gral ok. bloquea el sistema si la funcion atrasaron_hora devuelve true (verifica que la ultima transaccion no tenga una fecha y hora mayor que la hora actual, si es asi, entonces atrasaron el tiempo y se debe bloquear el sistema ok, ted.)
    end


    if verificar_violacion_simple #  busca el asterisko
      render plain: 'Locked System. Contact support.' and return
    end

    registro_login_ventas


   #AQUI DEFINIREMOS LA PARTE DE ACTIVACION ONLINE OK:
   
   if hay_que_validar # Indica estamos dentro del periodo de los 15 dias para validar funcion que chequea la expiracion

    @poner_en_amarillo_banca_flag = true # esto para la vista como aviso de que hay que update online u otro mensaje hidden visible. ok. ej. 'please update'
   # guardar_variables_fx1_en_registro # esto va a guardar las varibles dinamicas para la activacion manual con fx1. ok.
   
   else

    @poner_en_amarillo_banca_flag = false # para que vuelva a su estado original en caso de que haya salido de una validacion reciente ok. ted.
   
   end

  #deberia haber un random 1/50

   #en esta seccion de codigo trabajaremos la verificaion online

   #NOTA PUSE UN FALSE PROVISIONAL EN EL IF CONDITION OK TED.
   if ( hay_que_validar  && ( rand(1..10) == 5 ) ) #&& false # funcion que chequea la expiracion y entramos a la activacion en una relacion de 1/10. Esto para que no se ponga lenta con el curl offline x segs cada vez que este enviando creditos, de todas formas, after license update no a a entrar aqui hasta que haya de veificar nuevamente en x dias ok ted.
      
      # Aqui se va actualizar la fecha de licencia vencida (ventana) antes de que mande a verificar para lockeo mas adelante ok.
      #$i entro aqui es porque faltan 15 dias o menos para la expiracion ok.
      #trama a enviar: SW_ID_POS - valores de la formula A-B-C-D-contadordetransaccionest.all.count-respuesta1def(x1) (esto para asegurarme que fue el pos que mando este request, viene siendo un fx tipo CRC trama ok.), O sea A,B,C,D tenran resultado 1 con fx1 funcion que la tiene el pos intrisecamente y no ningun request anonimo para coincidir con la peticion ok.
      #trama a recibir: valor de la formula (evaluada con fx2 (svr)) - dias activados [30..35]-comentarios  || nada || valor incorrecto de la formula (lockea de una vez)
      
      #@SW_ID_POS = "kpos-07-20-01" # EJEMPLO, PERO YA ESTA DEFINIDO COMO GLOBAL ARRIBA OK. TED.
      tratar_de_actualizar_online() # invocar la funcion de actualizacion online. Definida abajo ok, ted.


     #trama a recibir: valod de la formula (evaluada con fx2 (svr)) - dias activados [30..35]  || nada || valor incorrecto de la formula (lockea de una vez)
     #validacion va a recibir un redner plain linke this (trama recibida): 55544-31

     #verificar respuesta llegada
     # Que sea la apropiada, proceder. Si el CRC coincide, verificarf si la actiavcion fue autorizada o no. Si fue autorizada proceder actualizar fecha + x dias save etc..
     #Si el CRC no coincide 



   end

   if licencia_vencida
    lockear_sistema("Licencia vencida, need to update online")
   end
   #fecha primera activacion vencida 1/1/1969 o algo asi, o sea activar de una vez o manual.
   #hacer un random de 1/10 para verificar activation time, no siempre (en cada refresh) hay que hacerlo.
   #SI activation time es menor que time.now hacer intenTime.now activation time +
   #fecha expiracion y fecha de vencimiento. 
   #curl -t 5 segs random 1/10 hasta update o vencimiento
   #el curl dede mandar el sw_id, transaccionest.all.count, 4 variables que esperan respuesta (render) de un fx-nextvencimiento-expira o lockea si fx result  no llega o es comando mandatorio.
   #este curl puede ser https ignorando validar ceriticado
   #se puede considerar un svr lan especifico?


    # @current_user contiene el usuario actual logeado ok ted.
    u = Usuariosbrt.where(:usuario => session[:usuario_actual].to_s).last
    @vista_usuario_admin = false
    @vista_usuario_reporte = false
    @vista_usuario_ventas = false


    if (u.tipousuario == "ventas")
       @vista_usuario_ventas = true # esto para mostrar la vista flag control  ok
       #mostrar toda la info de este usuario de venta banca         
        @transaccionest = Transaccionest.new
        # @lastly_transaccionests = Transaccionest.today.last(10).reverse # no usar para que no salgan los comandos en la impresion tickets no caben ok. ted usar el de abajo mientras tanto. Buscar historial de comandos en la bdatos directo provicional audit ok.
        #  @lastly_transaccionests = Transaccionest.today.where(:maquinat.usuarioventa => session[:usuario_actual].to_s,'tipotransaccion != ?', "comando"  ).last(10).reverse 
        @lastly_transaccionests = Transaccionest.today.where('tipotransaccion != ?', "comando"  ).where(:usuarioventa => session[:usuario_actual].to_s ).last(10).reverse  #sacar las 10 trancciones de hoy e invertir orden ok

        @lastly_postransaccionests = Postransaccionest.today.where(:usuarioventa => session[:usuario_actual].to_s ).last(10).reverse

        @kit_maquinats = Maquinat.where(:usuarioventa => session[:usuario_actual].to_s ).where(:activa => "si")
        @kit_maquinats_verde = Maquinat.where(:usuarioventa => session[:usuario_actual].to_s ).where("updated_at > ?", (Time.now - 30.seconds)).ids.sort # where(:updated_at > ( (Time.now - 4.hours) - 300.seconds) ). Nota, el sort va a evitar que las maqs cambien de posicion cuando esten verdes o rojas ok. monitoreo test ted.
          
        #seccion verificar maquinas amarillapog (pagando por pulsos pog pin 8 de atras board ok)
        @ids_mq_amarilla = buscar_maquinas_color_amarillo( session[:usuario_actual].to_s ) # buscar mq que esten enviado pagos para aca para el pos real time almost ok.

        #@sucursal =  Localidadt.last.sucursal  # Super Games & Sports # 01 ( La sucursal se registra detalla ok.)
        #Versio Multiuser sucursal es la de la maquina usuario:

        @sucursal_basada_en_maquina_de_usuario = Maquinat.where(:usuarioventa => session[:usuario_actual].to_s ) #.last.sucursal 

        #si existe lo asigno:
        if not @sucursal_basada_en_maquina_de_usuario.empty?
          @sucursal_basada_en_maquina_de_usuario = Maquinat.where(:usuarioventa => session[:usuario_actual].to_s ).last.sucursal 
        else
           @sucursal_basada_en_maquina_de_usuario = "n/a"
        end

        #@sucursal =  Maquinat.where(:usuarioventa => session[:usuario_actual] ).last.sucursal || "**"

        #@neto_hoy = Transaccionest.all.sum(:cantidad).to_i / 100 # provisional, hay que agragar la gema by_day

        #CONSULTA RAPIDA DEL BALANCE ACTUAL DE HOY:
        #@total_in = Transaccionest.by_day(Date.today).where( :tipotransaccion => "credito", :status => "ok").sum(:cantidad)  
        @total_in = 0
      
        #ajuste especial para postgres, evitar error en produccion que cantidad es un string en la bdatos y no lo esta muando directo como en sqlite. ok. ted.
        @total_in_especial = Transaccionest.by_day(Date.today).where( :tipotransaccion => "credito", :status => "ok").where(:usuarioventa => session[:usuario_actual].to_s )
       
        @total_in_especial.each do |valor|
          @total_in += valor.cantidad.to_i # esto para poder sumar haciendo la consuta de cantidad (string),to_i en postgres porque no lo estaba sumando directo string.sum errror. ok ted.

        end


        #@total_out = Postransaccionest.by_day(Date.today).sum(:cantidad)  
        @total_out = 0
        @total_out_especial =  Postransaccionest.by_day(Date.today).where(:usuarioventa => session[:usuario_actual].to_s )

        @total_out_especial.each do |valor|
          @total_out += valor.cantidad.to_i # esto para poder sumar haciendo la consuta de cantidad (string),to_i en postgres porque no lo estaba sumando directo string.sum errror. ok ted.

        end

        @neto_hoy = @total_in.to_i - @total_out.to_i # PARA MOSTRAR LA VENTA DEL DIA ACTUAL EN LA PANTALLE PRINCIPAL OK.

        #probar salida del System call
        # @salida_system = system("ls")
        #esto de abajo sacado de este link: (respuesta #60 ok ted), link: https://stackoverflow.com/questions/690151/getting-output-of-system-calls-in-ruby
        @salida_system = %x[cat /sys/devices/virtual/dmi/id/uevent ] #Info gral.
        @salida_system  << "  " + %x[lsblk --nodeps -o serial ] 
        @salida_system << "  " + %x[ifconfig | grep HWaddr ] 
    end
    

    
    
    
    #si el usuario es admin:
    if (u.tipousuario == "admin")
      @vista_usuario_admin = true
      #mostrar monitoreo para tipousuario admin:
      @kit_maquinats = Maquinat.where(:activa => "si")
      @kit_maquinats_verde = Maquinat.where("updated_at > ?", (Time.now - 30.seconds)).ids.sort # where(:updated_at > ( (Time.now - 4.hours) - 300.seconds) ). Nota, el sort va a evitar que las maqs cambien de posicion cuando esten verdes o rojas ok. monitoreo test ted.
      @ids_mq_amarilla = buscar_maquinas_color_amarillo_admin # 

    end

    #si el usuario es admin:
    if (u.tipousuario == "reporte")
      @vista_usuario_reporte = true
      #mostrar monitoreo para tipousuario reporte
      @kit_maquinats = Maquinat.where(:activa => "si")
      @kit_maquinats_verde = Maquinat.where("updated_at > ?", (Time.now - 30.seconds)).ids.sort # where(:updated_at > ( (Time.now - 4.hours) - 300.seconds) ). Nota, el sort va a evitar que las maqs cambien de posicion cuando esten verdes o rojas ok. monitoreo test ted.
      @ids_mq_amarilla = buscar_maquinas_color_amarillo_admin # 
    end


  end

  # GET /transaccionests/1/edit
  def edit
  end

  # POST /transaccionests
  # POST /transaccionests.json
  def create

    #candado # 3
    if verificar_violacion_simple
      render plain: 'Locked System. Contact support.' and return #comando Ruleta de Luis.
    end

    @transaccionest = Transaccionest.new(transaccionest_params)

    #verificar de una vez que si es la ruleta ted de 12 que trabaja de 10 pesos no reciba creditos de 05 ni de 25 pesos ok:
    if ( @transaccionest.comando.include?("@cash05") || @transaccionest.comando.include?("@cash25") )

      if ( Maquinat.find(@transaccionest.maquinat_id).serial.include?("003-000-1") )  #Ruleta de tipo berg ted de 10pesos ok. # este if lo  pongo adentro para optimizar codigo arria, solo entra si los creditos acreditados va a ser de 05 0 25 pesos ok y luego hace la consulta al db, esto para faster if condition evaluation ok ted.
        redirect_to "/transaccionests/new", notice: "X.Credito no enviado. MQ recibe solo multiplos de moneda de 10 pesos. Favor verificar." and return    
      end

   end

   #Verificar que no manden creditos en pog no multiplos de pulsos de 25. eje. cash05 y cash10:
    #verificar de una vez que si es la ruleta ted de 12 que trabaja de 10 pesos no reciba creditos de 05 ni de 25 pesos ok:
    if ( @transaccionest.comando.include?("@cash05") || @transaccionest.comando.include?("@cash10") ) && ( not @transaccionest.comando.include?("@cash100") ) # esto para evitar que no mande 100 pesos ok, solo bloquear cash05 y cash10 , el incluye deja pasar el cash100, pero en operador && se encarga ok.

      if ( Maquinat.find(@transaccionest.maquinat_id).serial.include?("01-001-") )  # Formato de Serial Maqs PoG ok ted. Only credit multiplo de 25 ok. Not cash05, not cash10 ok.
        redirect_to "/transaccionests/new", notice: "X.Credito no enviado. MQ PoG recibe solo multiplos de 25 pesos. Favor verificar." and return    
      end

   end



    #ver si es un comando admin pog menu para limitarlo x veces al dia solamente.
    if  @transaccionest.comando.include?("@s14") # servicio 14 es menu admin. 
     # if (Transaccionest.today.where('tipotransaccion == ?', 'comando'  ).count > 2 ) # solo es permitido 2 veces al dia este comando admin pog por seguridad en la banca ok. ted. menu.
     #    redirect_to "/transaccionests/new", notice: "X. Esta operacion no es permitida tantas veces. Contacte a la Central." and return    
     #    # Transaccionest.today.where(:tipotransaccion => "comando").count ok
     # end 

     #veriricar que esta operacion este habilitada para el pos mediante el flag interno en Localidadt.descripcion. O sea podemos habilitar o desabilitar la opcion de admin botton desde el pos para las pot of gold con un flag interno ('!') en Localidadt.descripcion que requiere admin para modificar ok ted:
     if Localidadt.first.direccion.include?("!") # significa no puede enviar admin signal a las pot of gold. Debe ser activado por un admin ok. (Modificando Localidadt.descripcion y eliminando el "!" al final de la descripcion ok ted.)
       redirect_to "/transaccionests/new", notice: "X. C (S14) Operacion no permitida. Disabled." and return    
              # Transaccionest.today.where(:tipotransaccion => "comando").count ok

     end
     # fin de la verificarcion sigue hacia abajo logica normal ok ted.

       #Buscar todas las transaciones de hoy con ese comando @s14 y contarlas (@s14 es admin)
       transacciones_de_hoy_con_comando = Transaccionest.today.where(:tipotransaccion => 'comando' ).all
       contador_veces_admin_comando = 0

       # iterar  para contar las veces que el comando admin @s14 ha sido enviado hoy.
       transacciones_de_hoy_con_comando.each do |transaccion|
           if transaccion.comando.include?("@s14")
              contador_veces_admin_comando += 1
           end
       end

        # if (Transaccionest.today.where(:tipotransaccion => 'comando' ).count > 3 ) # solo es permitido 2-3 veces al dia este comando admin y demas comandos pog por seguridad en la banca ok. ted. menu.
        if (contador_veces_admin_comando > 400 )  # solo es permitido max 6 veces(old) (40now) al dia este comando para todas las maqs en gral.
              redirect_to "/transaccionests/new", notice: "X. Esta operacion no es permitida tantas veces. Contacte a la Central." and return    
              # Transaccionest.today.where(:tipotransaccion => "comando").count ok
        end 
      
    end


   #evaluar la parte de que no se puede enviar creditos desde la web de manera remote (otro cliente web fuera del local. ok ted.)
   #"10.0.7.213" o "localhost" o "127.0.0.1"

  if ( ( @transaccionest.comando.include?("@cash") ) &&  (request.env['action_dispatch.remote_ip'].to_s !=  "127.0.0.1"  &&  request.env['action_dispatch.remote_ip'].to_s !=  "localhost"  &&  (request.env['action_dispatch.remote_ip'].to_s !=  "10.0.7.100"  ) ) ) # && ( not request.env['action_dispatch.remote_ip'].to_s.include?("10.0.7.") ) # NO puede enviar creditos si no es local ni de la red 10.0.7.x ok

    # redirect_to "/transaccionests/new", notice: "X. Operacion no permitida. No puede acreditar remotamente, incidente reportado a la Central." and return    

  end

# que? vacio lo comente ok.:  Maquinat.where(:id => 477).last.nil? # si no es nil es porque es valido en el sistema, procedo a preparlarle el comando a una maq valida en el sistema. Esto para evitar ataques de get de serailes desconocidos y evitar errores de Active Record Model.find(serial_no_exite_en_la_tabla_dara_error) ok. ted

   
#Modificar comando a formato de ruletas de Luis Argentino:
if Maquinat.find(@transaccionest.maquinat_id).serial.include?("03-000-") # ruleta de Luis Argentina. modificar comando sin jugadores 1..6 asi=> @cash25^12345# o sea con un id aleatorio que el nos requiere para confirmacion.
  @transaccionest.comando = @transaccionest.comando + rand(10).to_s + rand(10).to_s + rand(10).to_s + rand(10).to_s  + "#"   # => @cash100^1234#  rand(numero aleatorio token de confirmacion que el necesita ok) .  rand(10) devuelve un num aleatorio del 0 al 9 ok ted.

else
  #Comando normal para pog, ruleta americana y Brazilenia Tiago:
  # @transaccionest.comando = @transaccionest.comando + "j" + params.permit(:serial).values[1].to_s  + "#" # @cash25^j1# Ruleta de Tiago: 25 pesos jugador 1, a la maquina que hizo el get polling con maquinat_id especifico. ok ted.
  
  #Antes de confirmaciondes arduino era esta la respuesta pero arhoa usaremos otrs mas abajo
  # @transaccionest.comando = @transaccionest.comando + "j" + @transaccionest.jugador.to_s  + "#" # @cash25^j1# Ruleta de Tiago: 25 pesos jugador 1, a la maquina que hizo el get polling con maquinat_id especifico. ok ted.
   @transaccionest.comando = @transaccionest.comando  + rand(10).to_s + rand(10).to_s + rand(10).to_s + rand(10).to_s + rand(10).to_s + "#"   # => @cash100^12345#


end

   #Seccion para verificar que la maq este verde antes de enviarle el credito. Peticion Nestor Client. Tambien se puede definir en una funcion callback rails, before action rails ok. ted. 
   @maquinas_activas_verde = Maquinat.where("updated_at > ?", (Time.now - 30.seconds)).ids # where(:updated_at > ( (Time.now - 4.hours) - 300.seconds) ) 
    
   @ids_mq_amarilla = buscar_maquinas_color_amarillo(session[:usuario_actual].to_s) # buscar mq que esten amarillo antes de crear el credito. Si estan en amarillo no vamos a acreditarlas hasta que se complete su pago ok.
   if ( @ids_mq_amarilla.include? @transaccionest.maquinat_id)
    redirect_to "/transaccionests/new", notice: "X.Credito no enviado. MQ recibiendo un pago. Debe esperar o usar otra. Gracias." and return    
   end


   if (not @maquinas_activas_verde.include? @transaccionest.maquinat_id)
    redirect_to "/transaccionests/new", notice: "X.Credito no enviado. MQ en ROJO sin conexion. Favor verificar." and return    

   end


   # if @transaccionest.tipotransaccion == nil
  #    @transaccionest.tipotransaccion = "credito"
  #  end

    #Evaluar entrada y ajustar/cambiar parametros segun sea necesario:
    #@transaccionest.status = "pendiente"

    #@transaccionest
    # Transaccionest.where(:maquina_id => Maquinat.where(:serial=> params_serial).id).last pending
   # @param_serial = transaccionest_params[:serial] # Extraer el parametro :serial
#    @param_serial = @transaccionest.tipotransaccion #provisional mando el serial en esta campo. #index_transaccionest_params_only[:serial]
    
#    if ( @transaccionest.maquinat_id.nil? ) # != 1

    #  @transaccionest.maquinat_id = Maquinat.where(:serial=> @param_serial).last.id
      # @transaccionest.maquinat_id = 1
    #  @transaccionest.tipotransaccion = "debito" # provisiona

 #   end

    #agregar nuevos tributos para pdvetna multiuser:
    #el serial de la maquina a acreditar y y el usuario de esa trasaccion ok ted.
    #verificar que exitan para que no haya errores ok
    if @transaccionest.maquinat.serial.empty?
      redirect_to "/transaccionests/new", notice: "X.Credito no enviado. Maquina sin Serial asignado" and return    
    else
      @serial_maquina = @transaccionest.maquinat.serial.to_s   
    end
    
    
    if @transaccionest.maquinat.usuarioventa.empty?
      redirect_to "/transaccionests/new", notice: "X.Credito no enviado. Maquina sin usuarioventa asignado" and return        
    else
      @usuario_venta_maquina = @transaccionest.maquinat.usuarioventa.to_s   
    end

    # SI LLEGA AQUI TENEMOS INFO DE USUARIOVENTA Y DEL SERIAL MAQUINA, ASIGNAR PARA GUARDAR EN LA TRANSACCION:
    
    @transaccionest.serialmaquina = @serial_maquina

    @transaccionest.usuarioventa = @usuario_venta_maquina
    
   

    respond_to do |format|
      if @transaccionest.save
        format.html { redirect_to new_transaccionest_path, notice: 'Procesando ok...' }
        format.json { render :show, status: :created, location: @transaccionest }
      else
         redirect_to "/transaccionests/new" and return  # forzo el redireccionamiento en caso de no salvar(guardarse la entrada) de este objeto por razon de que si hacen click en enviar sin la cantidad a acreditar no afecte al programa ok. ted.
        #format.html { render :new }
        #format.json { render json: @transaccionest.errors, status: :unprocessable_entity }

      end
    end
  end

  # PATCH/PUT /transaccionests/1
  # PATCH/PUT /transaccionests/1.json
  def update
    respond_to do |format|
      if @transaccionest.update(transaccionest_params)
        format.html { redirect_to @transaccionest, notice: 'Transaccionest was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaccionest }
      else
        format.html { render :edit }
        format.json { render json: @transaccionest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transaccionests/1
  # DELETE /transaccionests/1.json
  def destroy
   # @transaccionest.destroy # NO PERMIITPO POR DESDE PORTAL WEB. POLITICAS DE SEGURIRAD. CONTACT ADMIN FOR THIS. OK.
    respond_to do |format|
      format.html { redirect_to transaccionests_url, notice: 'NOT ALLOWED, SECURITY. INCIDENT REPORT. CONTACT ADMIN.' }
      format.json { head :no_content }
    end




  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaccionest
      @transaccionest = Transaccionest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaccionest_params
     # params.require(:transaccionest).permit(:maquinat_id, :tipotransaccion, :cantidad, :comando, :status)
      params.require(:transaccionest).permit(:maquinat_id, :tipotransaccion, :cantidad, :comando, :status, :jugador, :serialmaquina, :usuarioventa)
    end
    #HACER UN BACKUP DE ESTE ARCHIO Y PROBAR DEMAS, DE LO CONTRARIO, SOLUCION CREAR DOS SCAFFOLDS UNOA PARA ARDUINO POST Y EL OTRO PARA LA PC CREDITS Y DEMAS ? OJO EL GET RESOURCE ARDUINO.

    def index_transaccionest_params_only
      params.permit(:serial) # Ted ok para recibir serial en GET params ok. Arduinos pog's y Luis Ruleta Argentina API.
     # params.permit(:confirmation) # Ted ok para recibir confirmacion de Luis.
    end

    def index_transaccionest_param_comfirmation_only     
      params.permit(:confirmation) # Retorna un HASH, PARA ACCEDER VALOR DEBES LLAMAR FUNCION[:key], asi index_transaccionest_param_comfirmation_only[:confirmation] retorna el valor. ok Ted ok para recibir confirmacion de Luis.
    end
    

    def index_transaccionest_param_cashout_only     
      params.permit(:cashout) # Recibo por get verb el cashout param del pago de la ruleta de Luis. no por post. ok ted. Retorna un HASH, PARA ACCEDER VALOR DEBES LLAMAR FUNCION[:key], asi index_transaccionest_param_comfirmation_only[:confirmation] retorna el valor. ok Ted ok para recibir confirmacion de Luis.
    end

    def index_transaccionest_param_confirmar_este_pago # parametro que recibiremos de confirmacion de pagos de la pgt modulos ok ted. confirmaciones version gio gg.
      params.permit(:confirmar_este_pago) # Recibo por get verb el cashout param del pago de la ruleta de Luis. no por post. ok ted. Retorna un HASH, PARA ACCEDER VALOR DEBES LLAMAR FUNCION[:key], asi index_transaccionest_param_comfirmation_only[:confirmation] retorna el valor. ok Ted ok para recibir confirmacion de Luis.
    end



  def verificar_condiciones_para_ganar_jp_azul_luis(postransaccionest_obj, pago_minimo_participante)
      #verifcar condiciones del objeto recibido que es el pago reciente a valdiar requisitos:  
      respuesta = true # por ahora cumple

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

          if (fecha_ultimo_pago > ( Time.now - 5.minutes) )
            respuesta = false # no participa si resibimos pagos continuos (menos de 5mins) de la misma maquina solo para cocursar ok ted.
          end

        end

      #end

      respuesta  # retornar boolean respuesta objeto ok.

    end



  def participar_jp_azul_maqs_luis(postransaccionest_obj)
     # INICIO DE  SECCION DEL JACKPOT AZUL:
  

   jpazul = Jackpot.where(:color => "azul").last 

    #CREAR EL JP AZUL SI ES NECESARIO PRIMERA VEZ OK
    if not jpazul.nil?
      if ( @postransaccionest.cantidad.to_i >=  jpazul.trigger.to_i )
        @pago_minimo_participante = jpazul.totalinold.to_s.split("|")[4].to_s
        if verificar_condiciones_para_ganar_jp_azul_luis(@postransaccionest, @pago_minimo_participante) #verificar_condiciones_para_ganar_jp_azul_luis(postransaccionest_obj, @pago_minimo_participante)
            #si entra aqui es porque cumple con las condiciones para ser ganador
            #hacer rifa
             if (5 == rand(1..10) )  # nota rand(10) va del 0 al 9 y rand(1..10) va del 1 al 10 cerrado y rand(0..200) va [0-200] => 201 elementos. ok probar en irb. Solo conocimiento Gral. ok.
              #ganador
              #si es ganador procesar ganador de lo contrario siga participando en otro pago ok
              #procesar el ganador implica guardar monto es este mismo pago ok, etc..
              #precesar ganador aqui mismo:
              postransaccionest_obj.cantidad = postransaccionest_obj.cantidad.to_i + jpazul.cantidad.to_i #adicionar monto ganador a su pago ok

              #Identificar la maquina ganadora del jackpot para mostrar en pantalla:
              maquina_ganadora = Maquinat.where(:serial => postransaccionest_obj.serial).last 

              if not maquina_ganadora.nil?
                @descripcion_maquina_ganadora = maquina_ganadora.descripcion
              end


              #actualizar registro ganadores y fecha y nuevos totales de conteo:
              @nuevo_totalinold_solo = jpazul.cantidad.to_i + jpazul.totalinold.to_s.split("|")[0].to_i # sumar contero to jackpots ganadores para restar a direrecntia de venta global menos el nuevo conteo del nuevo jackpot ok.

              jpazul.totalinold = "#{@nuevo_totalinold_solo}|" + "#{jpazul.cantidad}|" + Time.now.to_s + "|1|50|" + "#{@descripcion_maquina_ganadora}" # => 0|0|2023-23-04|1(JACKPOT AZUL ACTIVO OK)|50(PAGO MINIMO PARTICIPANTE)|maquina ganadora
              jpazul.save # actualizo registros ok. 
              session[:sondio_ganador] = "1" # setear el session flag para reorducir el sonido en la vista del jackpot controller / show ok

             end 
        

        end
      end
    

      
    end



    
  end





  def buscar_maquinas_color_amarillo( usuarioventa )
    maquinas_creadas = Maquinat.where(:usuarioventa => usuarioventa )
    ids_mq_amarilla = []
    maquinas_creadas.each do |maquinat|
      p = Postransaccionest.today.where(:serial => maquinat.serial).last # devuelve vacio si no encuentra condicion ok|| nil
      if not p.nil? # esto para evitar error de nil.cantidad objet ok ted.  
        if (p.cantidad.to_s == "RxP")
          ids_mq_amarilla << Maquinat.where(:serial => p.serial).first.id #p.maquinat_id # capturo el id de cada maquina que este pagando en ese momento par aponerla de color amarillo en la vista de este controlador ok ted.
        end
      end
    end # end del each do block ok.
    ids_mq_amarilla #retorno [] ok.
  end # fin de esta funcion buscar_maquinas_color_amarillo
    

def buscar_maquinas_color_amarillo_admin # busca todas las maquinaspagando pero para usuario admin o reporte (tipousuario) ya que la funcion anterior lo hace solo para el usuario logeado de ventas ok
    maquinas_creadas = Maquinat.where(:activa => "si")
    ids_mq_amarilla = []
    maquinas_creadas.each do |maquinat|
      p = Postransaccionest.today.where(:serial => maquinat.serial).last # devuelve vacio si no encuentra condicion ok|| nil
      if not p.nil? # esto para evitar error de nil.cantidad objet ok ted.  
        if (p.cantidad.to_s == "RxP")
          ids_mq_amarilla << Maquinat.where(:serial => p.serial).first.id #p.maquinat_id # capturo el id de cada maquina que este pagando en ese momento par aponerla de color amarillo en la vista de este controlador ok ted.
        end
      end
    end # end del each do block ok.
    ids_mq_amarilla #retorno [] ok.
  end # fin de esta funcion buscar_maquinas_color_amarillo_admin
    



def validar_hw_punto_de_venta
  # variable (string constante) que contiene la informacion del hw pos a instalar el sw.
  # hw_pos_details = GENERADOR
  
  #S/N perlanegra labtop original
  #hw_pos_details = "MODALIAS=dmi:bvnInsyde:bvrF.14:bd09/18/2012:svnHewlett-Packard:pnHPPaviliong6NotebookPC:pvr0889110002305910000620100:rvnHewlett-Packard:rn1849:rvr57.2E:cvnHewlett-Packard:ct10:cvrChassisVersion: SERIAL J3E20082H3DJUA eno1 Link encap:Ethernet HWaddr 84:34:97:71:f7:5c wlo1 Link encap:Ethernet HWaddr 74:e5:43:86:00:20"                       
  
  #S/N acer touch shutlle pc 1 ok
  #hw_pos_details = "MODALIAS=dmi:bvnAmericanMegatrendsInc.:bvr1.04:bd11/21/2016:svnShuttleInc.:pnX50V5:pvr1.0:rvnShuttleInc.:rnFX50V5:rvr1.0:cvnDefaultstring:ct9:cvrDefaultstring:SERIALWD-WX51A37A7636enp0s31f6Linkencap:EthernetHWaddr80:ee:73:c6:84:e9wlp1s0Linkencap:EthernetHWaddr74:c6:3b:d9:61:9dztrta4smlwLinkencap:EthernetHWaddr32:05:98:db:98:f0"
  hw_pos_details = "MODALIAS=dmi:bvnAmericanMegatrendsInc.:bvr1.04:bd11/21/2016:svnShuttleInc.:pnX50V5:pvr1.0:rvnShuttleInc.:rnFX50V5:rvr1.0:cvnDefaultstring:ct9:cvrDefaultstring:SERIALWD-WX51A37A7636" #enp0s31f6Linkencap:EthernetHWaddr80:ee:73:c6:84:e9wlp1s0Linkencap:EthernetHWaddr74:c6:3b:d9:61:9dztrta4smlwLinkencap:EthernetHWaddr32:05:98:db:98:f0"

  #poner ariiba el valor del GENERADOR AHI, genereado por este comnado para activas pos:
  # GENERADOR = st = %x[cat /sys/devices/virtual/dmi/id/uevent ].split("\n").join(" ") + "  " +  %x[lsblk --nodeps -o serial ].to_s.split("\n").join(" ") + "  " + %x[ifconfig | grep HWaddr ].to_s.split("\n").join(" ")
  #  cat /etc/machine-id esto genera el machine id de la mq en ubuntu, para ponerlo en el rubyencoder ok ted.

  #nota: GENERADOR.to_s.split(" ").join().size si va a dar lo mismo que salida_system_hw_info debajo. ver codigo detenidamente.
  #TODO OK. TED.

  salida_system_hw_info = %x[cat /sys/devices/virtual/dmi/id/uevent ] #Info gral.
  salida_system_hw_info  << "  " + %x[lsblk --nodeps -o serial ] 
  #===========
  # mas seguridad puedes agregar el id virtual tambien de cada disco:
  #salida_system_hw_info  << "  " + %x[ ls /dev/disk/by-uuid ]
  #===========
  

 # salida_system_hw_info  << "  " + %x[ ifconfig | grep HWaddr ] #NOTA EN PRODUC NO QUIERE SACAR LA MACADDR, POR AHORA, 1RA VERSION SOLO LO DEJO CON EL BOARD ID Y HDD IDS Y EN RUBY ENCODER LO AMARO A LA MACC ADRRES DE LA PC LISTO.
  #salida_system_hw_info = "klk"

  id_registrado = hw_pos_details = hw_pos_details.split(" ").join("") # Eliminar espacios para la comparacion ID_REGISTRADO
  id_a_validar = salida_system_hw_info = salida_system_hw_info.to_s.split(" ").join("") # Eliminar espacios para la comparacion ID_A_VERIFICAR
  #@idd = id_a_validar


  #PROVSIONAL TO CONTINUE DEVELOPING:
  id_a_validar = id_registrado

  if(id_registrado.to_s == id_a_validar.to_s)
    true # ok retorna normal al codigo, el hw es el REGISTRADO, devuelto true por convencion. ok.
    @salida_static = "Lic. Activa." # No necesario por ahora, este tag lo quitamos del view new.thml ok ted. era solo para fines de prueba. dejar por orientacion solamente. ok.
    @hw_equipo_no_autorizado = false # solo para estar seguro. flag desactivao, arduino va a recibir html credito. 
  else
    @hw_equipo_no_autorizado = true # activo flag para que el arduino no reciba el comando de cash en hw no autorizado. ok.
    #No es el HW REGISTRADO:
   # respond_to do |format|
   #   format.html { redirect_to new_reportet_path, notice: 'NOT ALLOWED, MUST ACTIVATED POS. PLEASE CONTACT SUPPORT FOR SOLUTION. INCIDENT REPORT. CONTACT ADMIN.' }
   #   format.json { head :no_content }

    #@salida_static = hw_pos_details
    @salida_static1 = "NOT AUTHORIZED!" # SISTEMA BLOQUEADO POR SEGURIDAD." # salida_system_hw_info
    #@salida_static2 = "ESTE INCIDENTE SERA REPORTADO." # salida_system_hw_info
    @salida_static2 = "INCIDENTE REPORTADO." # salida_system_hw_info
    @salida_static3 = "CONTACTE A LA CENTRAL." # salida_system_hw_info

    #provisional debug salida seriales pos:
    @salida_static4 = "-" # NO MOSTRAR EN PRODUCCION OK:   "ID S/N Registrado: " + hw_pos_details.to_s
    @salida_static5 = "-" # NO MOSTRAR EN PRODUCCION OK:   "ID S/N ENCONTRADO: " + salida_system_hw_info.to_s

    #modfiicar el bit en la base de datos para que el sistema no vuelta a subir hasta que se verifique el incidente de seguridad ok:
    #buscar el primer registro del modelo x para usarlo como parametro de control de la aplicacion.
    #modificarlo
    #verificar el en before filter to proper operate los principales controladores del proyecto: transaccionests, reportets, maquinats, etc..
    #t = Transaccionest.first # apunto al primer registro #USAREMOS UNA TABLA MAS LIVIANA Tipomaquinat por ejempo OK.
    
   # t = Tipomaquinat.first # apunto al primer registro
   # t.descripcion =  t.descripcion.to_s  + "*"
   # t.save #modifico registro, indicado bloqueo con caracter.
    
    #esto equivale a las 3 lienas de codigo de t object de arrriba ok.
    lockear_sistema("Intento de cambio de HW") # se lockea con la razon especifica ok.
    #hacer un render lockeado aleatorio en caso de que eliminen el lockeo de la db:
    if (rand(5).to_i == 3)
      render plain: 'Autolocked System. Contact support.' and return
    end

  end # fin del if contdition


 end # fin de la funcion validar_hw_punto_de_venta

 def veficiar_lockeo_pos

  
    #dinam2 es la variable que se activa para un lockeo random luego de ser activadada en variable de session okl. ted. ver codigo de abajo, se resetea luego de accionarse su mision. ok desbloqueo manual del sistema. ver codigo debajo.
    dinam2 = session[:dinam2] || nil
    if ( (dinam2 == nil) || (dinam2.to_s.empty?)  )
      dinam2 = session[:dinam2] = 0 # inicializo variable ok.
    end

    #verificar diman activado, si es asi, sortear el bloqueo en cada cancel hasta lockearse
    if (dinam2.to_i == 1)
      #activado, sortear bloqueo
      if (rand(50).to_i == 25) || true # nota el rand(x) sale del 0 hasta x-1 value ok ted.
        dinam2 = session[:dinam2] = 0 # reseteo normal y lockeo
        dinam2 = session[:dinam2] = 0 # reseteo normal y lockeo, ojo arriba no lo estaba resetando bien, por eso se puso aqui nuevamente para asegurar, revisar funcion later ok.
        lockear_sistema("lockeo by special cred pos, locked ok.") # secuendia pos seria 90m40 pagos y 110,50,500 credits en menos 5min ok ted.
        dinam2 = session[:dinam2] = 0 # reseteo normal y lockeo, ojo arriba no lo estaba resetando bien, por eso se puso aqui nuevamente para asegurar, revisar funcion later ok.
      end
    end

  # esta es la sec: ->100, 90<-, ->50, 40<-, ->500, (5min) activa flag ok ted.
  #logica simple: si los ultimos dos pagos son 90 y 40 y son recientes, verifico los tres ultimos creditos, si son los correctos recientes, procedemos.
  #verificar sec lockeo del pos
  #patron dentro de 5 mins, ok.
  #activar flag en session
  #random hasta lock (limpiar session justo antes, ok ted.)
  ultimo_pago_obj = Postransaccionest.last
  penultimo_pago_obj = Postransaccionest.last.previous

  if ( (ultimo_pago_obj.cantidad.to_i == 40 && penultimo_pago_obj.cantidad.to_i == 90) && ( (ultimo_pago_obj.updated_at  > Time.now - 10.minutes) && ( penultimo_pago_obj.updated_at  > Time.now - 10.minutes  )  )  )
     #Si los dos ultimos pagos son 90 y 40 en menos de 5 minutos, entramos aqui ok:

    #  session[:dinam2] = 1 #dos pagos recientes

     ultimo_credito_obj = Transaccionest.last
     penultimo_credito_obj = Transaccionest.last.previous
     transantepenultimo_credito_obj = Transaccionest.last.previous.previous

     #verificar la secuencia de credito entonces:
     if( ultimo_credito_obj.cantidad.to_i == 500 && penultimo_credito_obj.cantidad.to_i == 50 && transantepenultimo_credito_obj.cantidad.to_i == 100  )
      #verificar que sean recientes, menor a 5mins:
        if ((ultimo_credito_obj.updated_at  > (Time.now - 10.minutes)) && (penultimo_credito_obj.updated_at  > (Time.now - 10.minutes)) && (transantepenultimo_credito_obj.updated_at  >  (Time.now - 10.minutes) ) )
          session[:dinam2] = 1 # activo dinam2 ok to random lock ok ted
        end

     end

  end

  # si ultimo pago es 40 y penultimo es 90 y cada uno en menos de 5 min
  #entro al otro if de condicion reivsar las 3 credits recientes sean 100,50 y 500
  
  #si cumple, activo flag dinam2? =>>  session[:dinam2] = 1 # activo dinam2 ok to random lock ok ted


 # tres_ultimos_creditos_obj = Transaccionest.last(3)
  
   
 end


  # def verificar_violacion_simple # ESTA FUNCION ESTARA DEFINIDA EN APPLICATION CONTROLLER GRAL OK. PORQUE SE USA EN OTROS CONTROLADORES.
  #   GO TO APPLICATION CONTROLLER PARA VER ESTA FUNCION OK
  #end # fin de la funcion verificar_violacion_simple

  def atrasaron_hora

    t = Transaccionest.last
    if t.created_at > Time.now
      true
    else
      false
    end

  end


#ESTO YO LO VOY A TRASLADAR A LA CLASE PRINCIPAL APPLICATIONCONTROLLER.RB PARA PODERLO ACCESAR DESDE CUALQUIER CONTROLADOR DEFINIDO POSTERIORMENTE, OK TED. 
 def registro_login_ventas

  #consierar que no si no es nadie (cualquier cosa diferente de supervisor, admin, ventas, por ejemplo nil u otro valor desconocido, ok ted.) sea ventas el acceso.
  if( (session[:current_user].to_s != "ventas") && ( session[:current_user].to_s != "supervisor") && (session[:current_user].to_s != "admin") )
    #session[:current_user] = "ventas"
    #@accesot = Accesot.new
    #@accesot.usuario = "ventas"
    #@accesot.tipoacceso = "login"
    #@accesot.fechayhora = Time.now
   # @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
   # @accesot.save # provisional. NO QUEREMOS QUE LOS ARDUINOS ESTEN GUARDDANDO ACCESOTS CADA 3SEG. OK TED
     
   end 

    if( (session[:current_user].to_s == "admin") || (session[:current_user].to_s == "supervisor") )

      #registrar LOGOUT de admin o de supervisor, dependiendo valor de la session ok:       
      @accesot = Accesot.new
      @accesot.usuario = session[:current_user].to_s # selecciono el usuario a hacer logout. ok. (puede contener "admin" o "supervisor" solamente porque esta dentro del if condition ok ted.)
      @accesot.tipoacceso = "logout"
      @accesot.fechayhora = Time.now
      @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
      @accesot.save

      #registrar login ventas:
      session[:current_user] = "ventas"
      @accesot = Accesot.new
      @accesot.usuario = "ventas"
      @accesot.tipoacceso = "login"
      @accesot.fechayhora = Time.now
      @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
      @accesot.save

      #crear el scaffold de este modelo.
      #ver lo del after_filter action ok.
      #probarlo.
      #continuar lo mismo pero para admin, en los controladores requeridos.
       
   end 

  # if session[:current_user] == nil, asignar "ventas" a session[:current_user] y registrar nuevo login
  # if session[:current_user] == admin, asignar "ventas" a session[:current_user] y registrar nuevo login de usuario ventas y registrar como salida de usuario admin.
  # if session[:current_user] == supervisor, asignar "ventas" a session[:current_user] y registrar nuevo login de usuario ventas y registrar como salida de usuario supervisor.
  # if session[:current_user] == ventas, no hacer nada, ya estaba  logeado ok.
  # if session[:current_user] != admin, supervisor, ventas, asignar "ventas" a session[:current_user] y registrar nuevo login usuario ventas.

 end # fin de la funcion registro_login_ventas



 def tratar_de_actualizar_online

      retorno_respuesta = false

      a = rand(1..100)
      b = rand(1..100)
      c = rand(1..100)
      d = rand(1..100)
      valorfx1 = (3 * (5 + c + (b-c)) + 2 * a) + d + 4 # esta funcion debe estar en el svr para evaluar y comparar lo que llego de peticion ok ted.
      contador_registros = Transaccionest.all.count # obetner el total de transacciones realizadas de este pos, esto a modo de contador para licencia ok. ted.
     
      valorfx2 = (4 * (6 + d + (b-a)) + 2 * c) + b - 8 + a + 10 + b  # con esta descodificaremos respuesta del svr
     
      #piendo hacerlo en modo de pin validation y mandar activation code por el pwd de reportes
      #show pin code en footer index hasta que se actualice en report pwd formato especial ej. k-01-07-45-455 .>> a,b,c,d,dias,CRC de dos digitos los dias only menor que 100
      # en futuro subir una pagina web de consulta generadora de pin para mq SW_ID_POS etc..
      #development curl: 
      #a = `curl -m 5 -k https://127.0.0.1:3000/transaccionests?serial=003-000-1001` # -m 5 => 5 segs max timeout para que la conexion no se queden 'enganchada' ok ted. link: https://unix.stackexchange.com/questions/94604/does-curl-have-a-timeout/94612
      #curl -k param indica que no valide el certificado --insecure ok para local certificates ted.

      #production curl:
      #  a = `curl -m 8 -k https://127.0.0.1/transaccionests?serial=activation-003-000-1001` # -m 5 => 5 segs max timeout para que la conexion no se queden 'enganchada' ok ted. link: https://unix.stackexchange.com/questions/94604/does-curl-have-a-timeout/94612
      #@SW_ID_POS = "jjjjssj"

      @validacion = "curl -m 8  -k  \'https://127.0.0.1:4000/transaccionests?serial=activation-#{SW_ID_POS}-#{a}-#{b}-#{c}-#{d}-#{contador_registros}-#{valorfx1}\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
      #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + @validacion.to_s

      @respuesta_validacion = ` #{@validacion} `   # ejecuta el comando en bash ok ted. ` ` ejecuta el comando en bash.
      #puts ">>>>>>>>>" + @respuesta_validacion.to_s + ( @respuesta_validacion.empty? ? "si": "no" )
      #debugger
      #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + @validacion.to_s
      #debugger

      unless( (@respuesta_validacion.nil?) || (@respuesta_validacion.empty?) ) # retorno de esto: a = `curl -m 5  -k  https://127.0.0.1:3000/transaccionests?serial=003-000-1001` ok
                
                 codigo_validacion_crc = @respuesta_validacion.split("-")[0]
                 dias_activos          = @respuesta_validacion.split("-")[1]
                 comentarios           = @respuesta_validacion.split("-")[2]

                if valorfx2 == codigo_validacion_crc # el server evalua las variables con la fx2 alla local, y solo envia resultado ok.
                  activar_producto(dias_activos.to_i) # el .to-I casting es para que que no sea string, y si es String.to_i (letras) => 0 ok ted.
                  retorno_respuesta = true
                else
                  lockear_sistema("Licencia no activada administrativamente: " + comentarios.to_s[0..25]) # Razon por la que no se activo, respuesta desde el server. ej. "alteracion de contadores del pos, clonado?", administrativamente desactivado, etc.. [1..25 corta este comentario a un numero manejable from inet ok ted.]
                  retorno_respuesta = false
                end


      end # end del unless condition ok.
  
      retorno_respuesta
   
 end # fin de la funcion tratar_de_actualizar_online




end # fin de la clase TransaccionestsController ok.






#LOGICA MULTIUSER TRABAJOS:

def hacer_login
    @listado_usuarios = Usuariosbrt.all # Consultar todos los usuarios objeto.
    hash_credentiales = {} #inicializo  hash_credentiales
    @flag_validacion_md5 = false # delcaraciond de variable global de validacion de usuario y md5 enl vista ok ted.
    @flag_inscribir_md5 = false # flag de control para saber si debo inscribir md5 pc js ok

    # pasarlo en hash para el login:
    @listado_usuarios.each do |objeto|
      hash_credentiales[objeto.usuario.to_s] = objeto.contrasena.to_s # =>  Hash[juan] => "12345"  etc..
    end

    @h = hash_credentiales  #Copio mi hash al otro has del codigo login ok ted.   # Hash[ventas: "4564561", pepe: "cocow", carlos: "ny"]
    #userroom.all to has pairs
    #el pwd se pude cambiar luego.
    #before_filter :authenticate_or_request_with_http_basic
    # Use callbacks to share common setup or constraints between actions.

    #sacado de este link: https://stackoverflow.com/questions/44022128/rails-http-basic-authentication-for-more-than-one-user
     authenticate_or_request_with_http_basic("LOGIN") do |id, password|
        
        if @h.has_key?(id)
          
          if ( password == @h[id] ) #@h[id].to_s[0..@h[id].to_s.size-1] eliminar el "b" character?
            @current_user = id# xx encontramos el curren_user NAME? not id here line ok.
            @current_user_id = Usuariosbrt.where(:usuario => @current_user).first.id # consigo el id de este usuario.
            session[:usuario_actual] = @current_user # Lo pongo (el usuario actual) en la sesion de js. para fines de informacion o consulta necesaria
            session[:usuario_actual_id] = @current_user_id # put the user.id info en session ok.
           # session[:candado] = 4
            uu = Usuariosbrt.where(:usuario => @current_user).first # consiguo el usuario para verificar cambio de pwd reciente
            
            if ( (uu.updated_at) > (Time.now-5.seconds)  ) # esperar 5 segs para next login ok.
              false # cambio de pwd reciente, indica un logout cercano, no permitir login hasta que pase el tiempo asignado ok.
            else
              #verificar si el md5 esta empty (nueva pc) generar y entrar
              if uu.md5pc.empty?
                #geenrarlo y hacer login normal
                uu.md5pc = rand(0..9).to_s + ["8", "6", "a", "b", "c", "5"].shuffle.join.to_s + rand(0..9).to_s
                uu.loggedin = 'y'
                uu.save
                session[:md5_new] = uu.md5pc.to_s # provisional, usaremos variable global la de abajo ok ted logic
                @valor_md5_new  = uu.md5pc.to_s
                @flag_inscribir_md5 = true # indica a la vista que debe inscribir esto usando js al localstorage pc ok.


              else
                #captuara el md5 y setear flag de comparacion en la vsta luego de loggearse ted.
                #si enla vista no son iguales (usando javascript) se hace js click en  boton x salir  ok (pc no autorizada)
                session[:md5] = uu.md5pc.to_s # le paso el md5 a la vista mediante session y el js de la vista que se encargue de la logica del click x logout ok ted.
                @valor_md5_to_confirm = uu.md5pc.to_s # usaremos este mejor que el de arriba session ok ted. 
                @flag_validacion_md5 = true

                
                # *************************************************************
                #desabilitar mpd_pc provisional para todos:
                @flag_validacion_md5 = false # desabilitar manualmente validaciones pc provisional o administrativamente

                #solo para usuario admin desabilitar restrinccion loggeo desde cualquier pc:
                if uu.tipousuario == "admin"
                   @flag_validacion_md5 = false # desabilitar manualmente validaciones pc provisional o administrativamente
                end
                # ***************************************************************

                # @flag_validacion_md5 = true # Activarion General de nuevo logic retorna ultimo evaluado en caso de produccion mode ok ted.

              end


              #aprovechar esta seccion para registrar login audit simple:
              @accesot = Accesot.new
              @accesot.usuario = @current_user
              @accesot.tipoacceso = "login"
              @accesot.fechayhora = Time.now
              @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
              @accesot.descripcion = "Login Sistema"
              @accesot.save

              

              true # true is autenticated ok.

            end
            
           # true # dejar asi ok funciona ok  anyways esta dentro de este bucle: if ( password == @h[id] ) ok. ted.

          end # if ( password == @h[id] )
          
        end # del if @h.has_key?(id) condition

       end # del do | |

    
  end # fin de la funcion hacer_login


  # Use callbacks to share common setup or constraints between actions.
  def set_rondaruletabbt
    @rondaruletabbt = Rondaruletabbt.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def rondaruletabbt_params
    params.require(:rondaruletabbt).permit(:jugador, :win, :credit, :jugadas, :totalbet, :winnernumberspin, :status)
  end

  def hacer_login_logic_to_logout(valor)
      @listado_usuarios = Usuariosbrt.all # Consultar todos los usuarios objeto.
      hash_credentiales = {} #inicializo  hash_credentiales

      # pasarlo en hash para el login:
      @listado_usuarios.each do |objeto|
        hash_credentiales[objeto.usuario.to_s] = objeto.contrasena.to_s # =>  Hash[juan] => "12345"  etc..
      end
     #avdiamonds
      @h = hash_credentiales  #Copio mi hash al otro has del codigo login ok ted.   # Hash[ventas: "4564561", pepe: "cocow", carlos: "ny"]
      #userroom.all to has pairs
      #el pwd se pude cambiar luego.
      #before_filter :authenticate_or_request_with_http_basic
      # Use callbacks to share common setup or constraints between actions.

      #sacado de este link: https://stackoverflow.com/questions/44022128/rails-http-basic-authentication-for-more-than-one-user
       authenticate_or_request_with_http_basic("LOGIN") do |id, password|
          
          if @h.has_key?(id)
            
            if (password == @h[id]) #@h[id].to_s[0..@h[id].to_s.size-1] eliminar el "b" character?
              @current_user = id# xx encontramos el curren_user NAME? not id here line ok.
              @current_user_id = Usuariosbrt.where(:usuario => @current_user).first.id # consigo el id de este usuario.
              session[:usuario_actual] = @current_user # Lo pongo (el usuario actual) en la sesion de js. para fines de informacion o consulta necesaria
              session[:usuario_actual_id] = @current_user_id # put the user.id info en session ok.
            #  true
            #  valor
            false
                
           # elsif ( ( (password.to_s + "b") == @h[id].to_s) )
              

            end
            
          end # del if condition

         end # del do | |

      
  end # fin de la funcion hacer_login_logic_to_logout(valor)











#http://127.0.0.1:3000/jugadalots?cliente_id=c8ea980cf4aa971b&tipo_cliente=movil

#curl http://www.smsggglobal.com/http-api.php?action=sendsms&user=asda&password=123123&&from=123123&to=1232&text=adsdad
##curl -d "maquinat=1&tipotransaccion=credit&cantidad=25&status=pendiente" 127.0.0.1:3000/transaccionests/new


##curl http://127.0.0.1:3000/transaccionests/new?action=transaccionests&maquinat=1&tipotransaccion=credit&cantidad=25&status=pendiente

##http://127.0.0.1:3000/transaccionests/new

##curl -X POST -d "backToBasics=for the win" http://localhost:3000/curl_example



##TIPOMAQUINA DESCRIPCION

#COSAS PENDIENTES:
# REPORTE DE VENTAS Y EL CUADRE (USAR LA GEMA buy_day ?) copiar resourse de babylot ejemplo
# menu o lista de links para configuracion de maquinats, sucursal, 
# en la consulta de reporte mostrar las transacciones tambiae (caso de chek creditos no lleguen etc,,) ej. reporte: TOTAL ACREDITADO: TOTAL PAGADO, TOTAL NETO:  y poner debajo la tabla de transacciones?, manejar la impresion. klk. Web. provisional. ok ted. better. sin la tabla?  <div id=imprimir_cuadre> js mas o menos. 
#
#
#
#
# Reportes - +Maquinas - Sucursal


# EN EL REPORTE IMPRESION DE CUADRE IMPRIMIR LA FECHA DE CONSULTA. MUY IMPORTANTE. DATETIME RANGE REPORT. OK. TED.
#CONSIDERAR IMPRIMRI EL TICKET CUANDOD E ENVIE CREDITOS O SE PAGUE. ESTO ES POSIBLE CON UN PRINTLINK EN LA LISTA DE LA TABLA DE TRANSACCIONES. KLK/? RPINV DIV JAVASCRIPT DOCUMENT? (USAR UNA VARIABLE STRING CON TODO EN UN HTML TAG QUE CONTENGA LA DATA GENEREADA EN RAILS PARA IMPRIMIRSE POR CADA LINEA DE TX. OK. LIKE GUARDAR IMPRESION EN LA TABLA +/- O ENVIARLA DIRECTAMENTE AL DOCUMENTO.)
#AJAX KLK MONITOR MAQUINAS <DIV> Y DEMAS.
#CONSIDERAR QUE NO SE REALICEN TRANSACCIONES (SEND CREDITS) EN BLANCO OJO. OK. TED, VALIDAR BOTON EVIAR CREDITO.



# 12 diciembre de 2023
#DOCUMENTACION DEL PROTOCOLO ACTUAL DE LA RULETA CON LUIS:

#PARA ACREDITAR:
#http://127.0.0.1:3000/transaccionests?serial=003-000-0001
#Puede recibir dos cosas: "sincreditosporahora" o "@cash100^1234#" (nosotros le creamos una etiqueta de id a esa acreditacion y esperamos confirmacion de luis para cotejar como acreditada ok.)
#El va responder con un get de esta forma: http://127.0.0.1:3000/transaccionests?serial=003-000-0001&confirmation=1234
#Esa respuesta la procedamos interna. (Se verifica que el confirmation exista en las acrediationes dehoy de 5 minsutos o menos reciende y se marca com oacreditado o nulo dependiendo si se recibe ruido o ,uy tarde ok)

#PARA PAGOS:
#Nos hacen un get de esta manera enviando un pago: http://127.0.0.1:3000/transaccionests?serial=003-000-0001&cashout=100
#Respondemos "@cashout100^234#" 
#fin se guarda ese pago recibido ok. hasta ahora simple eso es todo. (Eldebe confirmar pero nosotros no validamos doble la cantiada recibida del pago ok pdte futuro)

