class RondaruletatsController < ApplicationController
  before_action :set_rondaruletat, only: [:show, :edit, :update, :destroy]
 
  

  # GET /rondaruletat
  # GET /rondaruletats.json
  def index

    #Nota: EL SERIAL DE LA ESTA RULETA DEBER SER UNICO Y DEFINIDO EN EL CURL GET CREDIT DE ABAJO O AQUI PARA PRODUCTION VARIAS EN RED. OK. "#{@serial_ruleta}" algo asi ok ted.
    @serial_global_mq = "003-000-1001" # completar la sustitucion en todo el controlador ok ted.
    
    #definicion de los codigos de admin (Dentro del controller index) (contadores, comandos especiales para request info ruleta. etc.. ok)
    @admin_function_code =  "222120" # "80550338" # admin_code para request de contadores y demas supervisor info ok.
    @contadores_code = "212522" # codigo para funcion de solicitud de contadores ruleta. ok.
    @last_credit_in_out_code = "172529" # codigo para funcion de solicitud last credit in/out ruleta.
    @all_player_balance_code = "212229" # "39906516" provisional
    @latest_player_online_code = "212230" # "39906517" provisional
    @reset_user_pwd_code = "212599" # provisional  "80556688" # "80556688u## numero del usuario al pwd reset. Ej. 80556688u25 (codigo recibido from js client ok hacer split y comparar en el code ok.) => usuario 25 pwd reset ok ted" provisional

    #Activar o desactivar el megajackpot en red, default activado.
    @megajackpot_enable_code =  "3990" # Nota: enabled default.
    @megajackpot_disable_code = "3991" # Code to disable megajackpot.

    @factor_monetario = 10 # Este es el factor monetario base de una ruleta de 10, para recibir creditos ok 
    
    #pdtes:
    #La matematicas
    #Cobro js y rails.
    #Los contadores
    #JS obsfucation y webview klk o rdp tserver ws klk.

    # @rondaruletats = Rondaruletat.all # provisional .all comentar todo

     #Inicailizar el has de posiciones de ruleta spin:
     #@hash_posiciones = {"posicion" => "valor"} ...
     #@hash_posiciones contiente la ubicacion de los numeros en base a las posisiones de la ruleta spin ok
     @hash_posiciones = {"1" => "0", "2" => "5", "3" => "12", "4" => "3", "5" => "10", "6" => "1", "7" => "8", "8" => "9", "9" => "2", "10" => "7", "11" => "6", "12" => "11", "13" => "4"}

     #@hash_numeros te devuelve la 'posicion' del numero consultado. ok. ted.
     @hash_numeros = {"0" => "1", "1" => "6", "2" => "9", "3" => "4", "4" => "13", "5" => "2", "6" => "11", "7" => "10", "8" => "7", "9" => "8", "10" => "5", "11" => "12", "12" => "3"}


     @hash_cant_apostada_por_numero = { "0" => 0 , "1" => 0, "2" => 0, "3" => 0, "4" => 0, "5" => 0, "6" => 0, "7" => 0, "8" => 0, "9" => 0, "10" => 0, "11" => 0, "12" => 0 } # todos en cero inicialmente.
     #ojo arriba es por numero no por posiciones ok ted.
     #futuro sort: h.sort_by {|k,v| v}.reverse
     
     #PROVISIONAL OK. BORRAR X 3 LINEAS DE CODIGO OK.
  #   if( params.permit(:credit).values[0].to_s.include?("get_credit") )
  #      render plain: "1111 - 111 - 111" and return 
  #   end

     #PROVISIONAL OK. BORRAR X 3 LINEAS DE CODIGO OK.
   #  if( params.permit(:credit).values[0].to_s.include?("ask_new_credit") )
   #      render plain: "nada" and return 
   #  end



  #  MANDAR EL CREDIT EN UN REQUEST O UN REFRESH PAGE:
      #identificar y sacar el jugador del comnado si es un get_creditj1 command
      if( params.permit(:credit).values[0].to_s.include?("get_credit") ) # get_creditj1 command lo incluye => true
        @get_credit_player = params.permit(:credit).values[0].to_s.split("j")[1] || "-1" # => 1 || "-1" avoid nil player, ok. De todas formas el where retorna nil pero no de creditos sin jugadores, sino de player -1. ok. ted.
        @get_credit_command = params.permit(:credit).values[0].to_s.split("j")[0] 
      end

      #verificar si es una consulta del multijackpot: ajax get_credit_multijackpotj (el split quita la j ok) del @get_credit_command recibido
      if (@get_credit_command == "get_creditm") 

        #verificar status flag activacion local:
        if verificar_flag_activacion_mj_local # funcion que dice si el megajackpot local feature esta activo o no en la mq. 
            # si esta activo, consultar balance
            @flag_control_mostrar_mega = "enabled" 

            #hacer consulta remota rutinaria (puede ser de hasta 5 seg timetou, es un ajax js asincrono, no afecta el juego ok. delay ok.)
            #Comando consulta de prueba local, development:
            #@consulta_rutinaria_megajackpot = "curl -m 5  -k  \'http://127.0.0.1:3000/contribuyentets?serial=#{@serial_global_mq}&contador=request_rutinario\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
           
            #Comando consulta de production server:
            @consulta_rutinaria_megajackpot = "curl -m 5  -k  \'https://10.0.7.220/contribuyentets?serial=#{@serial_global_mq}&contador=request_rutinario\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
           

            comando = ` #{@consulta_rutinaria_megajackpot} ` # esto ejecuta el string de arriba en bash ok ted. 
           
            # Fortmato de trama de respuesta esperada:  "Mega-#{@mega_sum}-request_rutinario_ok"
            #filtar respuesta, el curl puede traer no conexion tbn:
            if comando.to_s.split("-")[2] == "request_rutinario_ok"
              #todo normal al parecer por ahora, responder el js el request rutinario del balance del megajackpot:
              @acumulado_mega = comando.to_s.split("-")[1].to_i # balance actual del mega ok. Monto actual acumulado.
              render plain: "#{@flag_control_mostrar_mega}-Mega-#{@acumulado_mega}" and return # ok
            
            else
              #curl no recibio lo esperado desde el server, conexion offline, timeout, etc..., responder diferente al js ok. ted.
              # algo  paso que no tuve respuesta esperada, responder que no se va a mostrar en js ok:
              @flag_control_mostrar_mega = "disabled" 
              #megajackpot no esta activo localmente, no mostrar en js ruleta ok:
              render plain: "#{@flag_control_mostrar_mega}-Mega-***" and return # no se va amostrar en js por el disabled response ok. ted.
            end

        else
            @flag_control_mostrar_mega = "disabled" 
            #megajackpot no esta activo localmente, no mostrar en js ruleta ok:
            render plain: "#{@flag_control_mostrar_mega}-Mega-***" and return # no se va amostrar en js por el disabled response ok. ted.

        end # fin del condition verificar_flag_activacion_mj_local

      end # fin del condition  if (@get_credit_command == "get_creditm")  ok.


     #responder credito de un jugador normal, que no sea j* indica multiplayer ok
     if( (@get_credit_command == "get_credit") && (@get_credit_player != '*') ) # comando para pedir el credito rul bergmann from js.
         # credito = '0050' # provisional, sacar de ActiveRecord.

          #verifico que el credito exista para ese jugador, o lo mando en 0. ok. Esto porque un nuevo usuario creado va a dar error si no existe creditos para el todavia enviado desde el POS. ok. Se manda el credit en CERO. ok. Hasta que le pongan credit.
           
          if ( Rondaruletabbt.exists?(:jugador => @get_credit_player) )
             credito = Rondaruletabbt.where(:jugador => @get_credit_player).last.credit # este va a tener el credito actual.
          else
             credito = 0
          end


          @formated_credito = formatear_credito_en_4_digitos_para_win_display(credito.to_i)

          #aprovecho y envio los montos de los jackpots, negro y rojo para ser actualizados en los display js on page refresh:
          @jp_black = Jackpot.where(:color => "negro").first.cantidad.to_i
          @jp_red   = Jackpot.where(:color => "rojo").first.cantidad.to_i

          #visualizar un minimo de 100:
          @jp_black = (@jp_black <= 100)? "100" : @jp_black
          @jp_red   = (@jp_red <= 100)?   "100" : @jp_red

        
        render plain: "#{@formated_credito} - #{@jp_black} - #{@jp_red}}" and return 
     end

     #responder credito de los 6 multiplayer, modo j* ok:
     if( (@get_credit_command == "get_credit") && (@get_credit_player == '*') ) # comando para pedir el credito rul bergmann from js.
         # credito = '0050' # provisional, sacar de ActiveRecord.
          @array_credit_each_multiplayer = [] # almacenara el credito de cada unos de los 6 jugadores respectivamente ok.
          
          #verifico que el credito exista para ese jugador, o lo mando en 0. ok. Esto porque un nuevo usuario creado va a dar error si no existe creditos para el todavia enviado desde el POS. ok. Se manda el credit en CERO. ok. Hasta que le pongan credit.
          [1,2,3,4,5,6].each do |jugador|

              @get_credit_player = jugador # consultar credito actual para los 6 jugadores ok.
              if ( Rondaruletabbt.exists?(:jugador => @get_credit_player) )
                 credito = Rondaruletabbt.where(:jugador => @get_credit_player).last.credit # este va a tener el credito actual.
              else
                 credito = 0
              end

              @formated_credito = formatear_credito_en_4_digitos_para_win_display(credito.to_i)
              @array_credit_each_multiplayer << @formated_credito
          end

          #aprovecho y envio los montos de los jackpots, negro y rojo para ser actualizados en los display js on page refresh:
          @jp_black = Jackpot.where(:color => "negro").first.cantidad.to_i
          @jp_red   = Jackpot.where(:color => "rojo").first.cantidad.to_i

          #visualizar un minimo de 100:
          @jp_black = (@jp_black <= 100)? "100" : @jp_black
          @jp_red   = (@jp_red <= 100)?   "100" : @jp_red

        render plain: " #{@array_credit_each_multiplayer[0]} - #{@array_credit_each_multiplayer[1]} - #{@array_credit_each_multiplayer[2]} - #{@array_credit_each_multiplayer[3]} - #{@array_credit_each_multiplayer[4]} - #{@array_credit_each_multiplayer[5]} - #{@jp_black} - #{@jp_red}" and return 
     end


  

      # Atender peticion de pregunta periodica por nuevo credito (ask_new_credit)
      if( params.permit(:credit).values[0].to_s.include?("ask_new_credit") ) # get_creditj1 command lo incluye => true
        @get_ask_player = params.permit(:credit).values[0].to_s.split("j")[1] || "-1" # => 1 || "-1" avoid nil player, ok. De todas formas el where retorna nil pero no de creditos sin jugadores, sino de player -1. ok. ted.
        @get_ask_command = params.permit(:credit).values[0].to_s.split("j")[0] 
      end


      if (@get_ask_command == "ask_new_credit") # comando para pedir el credito rul bergmann from js.
         #llamar funcion que pregunta por credit en el pos
         #buscar_credito_pos()
         #Verificar si el jugador es una x, logout, recuerda que el web js logout hace este mismo tipo de request pero en este caso indico jugador como 'x' y de esta forma sabremos que es una peticion logout ok. ted.
          if (@get_ask_player == 'x' ) # verificar si el jugador es una x, logout,

                #   b = session[:token_ced] = "0"

                #manual provisional:
                #         u = Usuariosbrt.find(3)
                #         u.contrasena = "bolita" + rand(50).to_s
                #         u.save
            hacer_login_logic_to_logout(5) # nota este helper ya tiene un redirect embebido ok ted.
                #  session[:candado] = 5

                #    if (@get_ask_player == 'x' )
                #   render plain: "reload_new_credit #{b}" and return
                #  end



                #esperar 5segs
                # sleep(15)
                # u.contrasena = "12345"
                # u.save

                # return
          end
          

          #verificar si el player es un '*' significa revisar los 6 players (dashgame.html js client) y responder
          if (@get_ask_player == '*' ) 
              @respuesta_creditos = buscar_credit_de_los_6_players()
           #   puts "klkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"
           #   puts  "...tarumm.. #{@respuesta_creditos}"
           #  debugger
              
              if @respuesta_creditos #.inlucludes?('etc... ted.')
                  render plain: "#{@respuesta_creditos}" and return # hay_credito  = true y reload page js directo ok. ted.
              else               
                 render plain: "nadamultibalances" and return # no hay_credito para multiplayer dashgame roulette ok ted.
              end # end del @hay_que_actualizar_creditos_6_players
     
          end # end del  if (@get_ask_player == '*' )




         #Si preguntan por credit, primero busco local, si tiene el flag activado significa que ya otro cliente lo busco por el y para el y solo falta indicarle que actualice ok. ted
         #Verificar en Usuarios si hay credit listo para ese usuario:
         if( Usuariosbrt.exists?(@get_ask_player.to_i) )

            @solicitante_credito = Usuariosbrt.find(@get_ask_player.to_i)
            
            #Si exite, leer y actuar:
            if( @solicitante_credito.ledejaroncredit == true )
              
              @solicitante_credito.ledejaroncredit =  false # desactivo el flag de notification
              @solicitante_credito.save! # object save! ok.

              render plain: "reload_new_credit" and return # hay_credito  = true y reload page js directo ok. ted.
            
            end

         end 


         #buscar o preguntar si hay credito en pos:
         respuesta_array_buscar_credito_multiplayer = buscar_credito_multiplayer_pos() # array [credito , jugador] ok ted.

         @multicredit = respuesta_array_buscar_credito_multiplayer[0] # asignar valores del array retornado.
         @multiplayer = respuesta_array_buscar_credito_multiplayer[1]
         #puts("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxvalores encontrados:  #{@multicredit} - #{@multiplayer}")
         # revisar si le pusieron new credit from pos...
         # s = Singlepostransaccionest.first
         
          hay_credito = false          
         
          if( (@multicredit != nil ) && (@multiplayer != nil) )
           
            if( @get_ask_player.to_i == @multiplayer.to_i ) # Me aseguro que quien pregunto sea el dueno del credito, si es asi el js hace el reload ok, de lo contrario acredita pero no para este jugador, para el dueno apropiado, hay que buscar la manera de avisarle a ese para su prox ask_credit suene el js y reload ok. Ojo si esta juagando se autoacreditara ok. Pues el mismo (este ultimo) fue quie pago por el credit ok. 
              hay_credito  = true # activo flag indicando que hay credito disponible desde POS.
            
            elsif Usuariosbrt.exists?(@multiplayer.to_i) # si el jugador_id existe dentro de los Usuarios creados entonces le avisamos con el flag ok. Si no existe anulo el proceso y no le ponemos credito(balance) a un jugador que no esta en este grupo agregado. ok.
                #hubo una adicion de credito pero de otro jugador, el jugador: @multiplayer.to_i
                #usar la tabla de usuarios para indicarle a ses user que debe act su credito en su proximo ask_new_credit js periodico ok.
                
                   @usuario_acreditado = Usuariosbrt.find(@multiplayer.to_i)
                   @usuario_acreditado.ledejaroncredit = true # activo flag ok.
                   @usuario_acreditado.save!             
            end
                 

            @jugador = @multiplayer.to_s

            @credit_remoto = @multicredit.to_i
            
            ronda_actual =  Rondaruletabbt.where(:jugador => @jugador ).last ||  Rondaruletabbt.new # (si no existe lo creo) ronda y credito de ESE JUGADOR ok.
           
            ronda_actual.status = "cashin event: credito_actual + acreditado_from_pos = #{ronda_actual.credit.to_s} + #{@credit_remoto} al jugador j#{@jugador} = #{(ronda_actual.credit.to_i + @credit_remoto )}" #llevar un registro de envento acreditaciones en el status de esa ronda con ese credito ok ted.  real time logs.
            ronda_actual.credit = ronda_actual.credit.to_i + @credit_remoto # acredito balance.
            
            #Todo normal hasta aqui, pero si el jugador no existe en usuario, aunque la ronda se cree con este jugador, prefiero ponerle el credit en cero ok. Esto porque un futuro este user se crea nuevo puede tener credit viejo disponible en la ronda ok. Que este en la ronda no importa, pero que empiece en cero si ok.
            if not  Usuariosbrt.exists?(@multiplayer.to_i) # si no existe en User, guardo esta ronda con credit=0 ok. Y si existe todo sigue normal. Se le gurada al que existe para que cuando se loggee o pregunte este su credito ahi ok. Siempre y cunado exista va a tener credito > 0 ok.
               ronda_actual.credit = 0
            end

            ronda_actual.jugador =  @jugador   # =>  s.creditin.split("j")[1].to_s  # ok lo mismo
            ronda_actual.save # Acutualiza el balance ('save' has same id as 'update' here? ok.)

            #llevar el creditin al historial transacicones credit/cahsout history de la maquina:
            h = Historypostransaccionest.new
            h.creditin = @credit_remoto
            h.cashout = 0
            h.jugador = @jugador
            h.save

           # s.creditin = 0 # reset to zero creditin. ok.
           # s.save # limpio el creditin acreditado. ok.
         end
         

         if hay_credito # revisar si le pusieron new credit from pos, puede ser otro campo y vaciarlo to credit ok. pos_balace if >0 y setear en cero again. ok.
          #HACER ESTO APARTE FASE2 ABAJO
          render plain: "reload_new_credit" and return

         else
          render plain: "nada" and return 
         end

      end


      #  VERIFICAR SI ES UN COMANDO CASHOUT REQUEST Y DEMAS:
      if( params.permit(:credit).values[0].to_s.include?("cashout_credit") ) # get_creditj1 command lo incluye => true
        @get_cashout_player = params.permit(:credit).values[0].to_s.split("j")[1] || "-1" # => 1 || "-1" avoid nil player, ok. De todas formas el where retorna nil pero no de creditos sin jugadores, sino de player -1. ok. ted.
        @get_cashout_command = params.permit(:credit).values[0].to_s.split("j")[0] 
        puts ("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^cashout player: #{@get_cashout_player}")
        puts ("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^cashout command: #{@get_cashout_command}")
      end

  
     if ( @get_cashout_command == "cashout_credit") # comando para pedir el credito rul bergmann from js.
        
        if( Usuariosbrt.exists?(@get_cashout_player.to_i) )
            # SI existe busco el credit cashout del usuario vaaalido y lo mando a pagar, si no existe ese user, entonces el monto del pago a enviar es de 0 cero, y por la logica, si es cero no mando a pagar nada ok.
            @solicitante_pago = @get_cashout_player.to_i
            credito_cashout = Rondaruletabbt.where(:jugador => @solicitante_pago ).last.credit # este va a tener el credito actual.
        else 
          credito_cashout = 0
        end
            

        
         if(credito_cashout.to_i > 0) #hacer cashout si es mayor que cero.

             #bill in - bill out, not coin-in/coin-out ok. credit cash client. Por eso no van alos contadores de la mq, ya que la maq no paga todo el credit que tiene el cliente de balance, ok ted. El POS tira los reportes vtas.
             #GUARDAR LOS VALORES EN LA TABLA INTERMEDIARIA: Singlepostransaccionest

             s = Singlepostransaccionest.first
             s.cashout = credito_cashout
             s.save 

             #llevar el pago al historial transacicones credit/cahsout history de la maquina:
             h = Historypostransaccionest.new
             h.cashout = credito_cashout
             h.creditin = 0
             h.jugador = @get_cashout_player.to_i # mejor con esta variable ok. ted.
             h.save

             new_ronda = Rondaruletabbt.new
             new_ronda.credit = 0 # setear credit en cero luego de un cashout.
             new_ronda.jugador = @solicitante_pago
             new_ronda.status = "cashout: #{credito_cashout}"
             new_ronda.save
             
             #ahora gestiono el envio al pos de este cashout (cobro):
             enviar_cashout_pos(credito_cashout.to_s + "j" + @solicitante_pago.to_s )

         end

        render plain: "cashout_request_ok" and return  #repoonder al js ok.
     end


      #  VERIFICAR SI ES UNA SOLICITUD DE CAMBIO DE CONTRASENA DE USUARIO:
      if( params.permit(:credit).values[0].to_s.include?("change_pwd") ) # get_creditj1 command lo incluye => true
        
        @comando_cambio_pwd   = params.permit(:credit).values[0].to_s.split("...")[0]
        @usuario_cambio_pwd   = params.permit(:credit).values[0].to_s.split("...")[1].split("j")[1] || "-1"
        @current_pwd          = params.permit(:credit).values[0].to_s.split("...")[2].to_s[1..-1] # tambien puede ser string.reverse!.chop().reverse! algo asi ok.
        @new_pwd              = params.permit(:credit).values[0].to_s.split("...")[3].to_s[1..-1]
        @new_pwd_confirmation = params.permit(:credit).values[0].to_s.split("...")[4].to_s[1..-1]
        #[1..-1] recorta la primera letra del string, que en nuesto caso es un espacio obligatorio para el split("..."), para que podamos hacer el split de tres puntos en caso de que manden contrasena nueva vacia ok ted.
        #idea de este link: https://stackoverflow.com/questions/3614389/what-is-the-easiest-way-to-remove-the-first-character-from-a-string


     #   @get_user_player = params.permit(:credit).values[0].to_s.split("j")[1] || "-1" # => 1 || "-1" avoid nil player, ok. De todas formas el where retorna nil pero no de creditos sin jugadores, sino de player -1. ok. ted.
      #  @get_change_pwd_command = params.permit(:credit).values[0].to_s.split("j")[0] 
      #  puts ("^^^^^^^^change pwd user player: #{@usuario_cambio_pwd}")
      #  puts ("^^^^^^^^change pwd command: #{@comando_cambio_pwd}")
      #   puts ("^^^^^^^^Line Debug 1 - OK ")
      end

  
     if ( @comando_cambio_pwd == "change_pwd") # comando para pedir el credito rul bergmann from js.
        

        if( (Usuariosbrt.exists?(@usuario_cambio_pwd.to_i) ) && ( session[:usuario_actual_id].to_s  == @usuario_cambio_pwd.to_s ) )
           
          # render plain: "#{@current_pwd} - #{@admin_function_code} - 55" and return

           #veriricar si es un admin code function para algun admin request (contadores, last paid, etc)
            if( ( @current_pwd.to_s == @admin_function_code.to_s )  && ( @new_pwd.to_s == @new_pwd_confirmation.to_s ) )
              
              #funcion evaluar contadores  request:
              if (@new_pwd.to_s == @contadores_code.to_s)
                @contadores_info = solicitar_info_contadores() # funcion de envio de contadores y return
                render plain: "#{@contadores_info}" and return  #reponder al js ok.
              end

              #funcion evaluar last_credit_in_out  request:
              if (@new_pwd.to_s == @last_credit_in_out_code.to_s)
                @last_credit_in_out_info = solicitar_info_last_credit_in_out(@usuario_cambio_pwd.to_i) # funcion de envio de contadores y return
                render plain: "#{@last_credit_in_out_info}" and return  #reponder al js ok.
              end
              
              #funcion solicitud balance de todos los jugadores
              if (@new_pwd.to_s == @all_player_balance_code.to_s)
                @balance_all_players = solicitar_balance_de_todos_los_players()
                render plain: "#{@balance_all_players}" and return  #reponder al js ok.
              end

              #funcion solicitud ultimos jugadores online
              if (@new_pwd.to_s == @latest_player_online_code.to_s)
                @balance_all_players = solicitar_latest_players() 
                render plain: "#{@balance_all_players}" and return  #reponder al js ok.
              end

               #funcion activar el megajackpot red por code
              if (@new_pwd.to_s == @megajackpot_enable_code.to_s)
                @object_to_record_value_megajackpot_status_reference = (Jackpot.where(:color => "megajackpot" ).first ) || Jackpot.new  # Uno nuevo si es nil. Aqui la idea es modificar un atributo del objeto usado para representar el Megajackpot del modelo Jackpot para saber si lo activamos o no posteriormente en las consultar al server del megajackpot. Si el objeto no existe se crea y de modifica dicho parametro ok. ted.
                @object_to_record_value_megajackpot_status_reference.color = "megajackpot" # para que se creen en caso de ser new.
                @object_to_record_value_megajackpot_status_reference.cantidad = "1"
           
                #salvar la modificacion del registro usado como flag ok:
                if @object_to_record_value_megajackpot_status_reference.save
                   render plain: "Megajackpot enabled, activation Ok." and return  #reponder al js ok.
                else
                   render plain: "X Megajackpot error activation." and return  #reponder al js ok.
                end

              end

                #funcion desactivar el megajackpot red por code. (DESACTIVAR)
              if (@new_pwd.to_s == @megajackpot_disable_code.to_s)
                @object_to_record_value_megajackpot_status_reference = (Jackpot.where(:color => "megajackpot" ).first ) || Jackpot.new  # Uno nuevo si es nil. Aqui la idea es modificar un atributo del objeto usado para representar el Megajackpot del modelo Jackpot para saber si lo activamos o no posteriormente en las consultar al server del megajackpot. Si el objeto no existe se crea y de modifica dicho parametro ok. ted.
                @object_to_record_value_megajackpot_status_reference.color = "megajackpot" # para que se creen en caso de ser new.
                @object_to_record_value_megajackpot_status_reference.cantidad = "-1" # el -1 va a indicar que esta desactivado ok. ted.
           
                #salvar la modificacion del registro usado como flag ok:
                if @object_to_record_value_megajackpot_status_reference.save
                   render plain: "Megajackpot Disabled, ok." and return  #reponder al js ok.
                else
                   render plain: "X Megajackpot disable Error." and return  #reponder al js ok.
                end

              end

              

              #funcion solicitud reset pwd user(forget pwd)
              if (@new_pwd.split('u')[0].to_s == @reset_user_pwd_code.to_s)
                #hacer un cashout de ese usuario y proceder a resetear el pwd de ese usuario a '0000'
                #pedir cambio de pwd after first login?
                @usuario_a_resetear = @new_pwd.split('u')[1].to_i # usuario 25 por ejemplo. ok.
               
                #verificar que exista
                if ( Usuariosbrt.exists?(@usuario_a_resetear.to_i) )
                  #hacer un cashout de ese usuario. No se puede dejar credito antes del reset pwd por seguridad de las cuentas activas ok.
                   @solicitante_pago = @usuario_a_resetear.to_i
                   credito_cashout = Rondaruletabbt.where(:jugador => @solicitante_pago ).last.credit  || 0 # en caso de nil ponemos 0. ok.
                                     
                   if(credito_cashout.to_i > 0) #hacer cashout si es mayor que cero.

                       #bill in - bill out, not coin-in/coin-out ok. credit cash client. Por eso no van alos contadores de la mq, ya que la maq no paga todo el credit que tiene el cliente de balance, ok ted. El POS tira los reportes vtas.
                       #GUARDAR LOS VALORES EN LA TABLA INTERMEDIARIA: Singlepostransaccionest

                       s = Singlepostransaccionest.first
                       s.cashout = credito_cashout
                       s.save 

                       #llevar el pago al historial transacicones credit/cahsout history de la maquina:
                       h = Historypostransaccionest.new
                       h.cashout = credito_cashout
                       h.creditin = 0
                       h.jugador = @solicitante_pago.to_i # mejor con esta variable ok. ted.
                       h.save

                       new_ronda = Rondaruletabbt.new
                       new_ronda.credit = 0 # setear credit en cero luego de un cashout.
                       new_ronda.jugador = @solicitante_pago
                       new_ronda.status = "cashout mandatory because of a password reset ok, cantidad: #{credito_cashout}"
                       new_ronda.save

                       #ahora gestiono el envio al pos de este cashout (cobro):
                       enviar_cashout_pos(credito_cashout.to_s + "j" + @solicitante_pago.to_s )
                    
                    end #  del condition: if(credito_cashout.to_i > 0)

                    #proceder a resetear el pwd del user luego del cashout
                    user_to_pwd_reset = Usuariosbrt.find(@usuario_a_resetear.to_i ) #user obj ok.
                    user_to_pwd_reset.contrasena = '0000'
                    user_to_pwd_reset.save
                        
                else
                  render plain: "X Error Reset: USER NOT FOUND." and return  #reponder al js ok.
                end # del condition if ( Usuariosbrt.exists?(@usuario_a_resetear.to_i) )
                
                #listo.
                render plain: "Pwd Reset ok. User must change it on next login." and return  #reponder al js ok.
              end  # del condition:  if (@new_pwd.split('0000')[0].to_s == @reset_user_pwd_code.to_s)               
              

            end # del condition de si es un verification admin code:  if( ( @current_pwd.to_s == @admin_function_code.to_s )  && ( @new_pwd.to_s == @new_pwd_confirmation.to_s ) )

           #De lo contrario, si no es un admin code el codigo de cambio de contrasena normal sigue hacia abajo con su logica normal  ok. ted.
           #Busco la contrasena original:

           @usuario_seleccionado = Usuariosbrt.find(@usuario_cambio_pwd.to_i) # => object ok.
          # puts ("^^^^^^^^Line Debug 2 - OK ")

           #Verificar que los parametros suministrados sean correctos y proceder al cambio:
           if( ( @usuario_seleccionado.contrasena == @current_pwd ) && ( @new_pwd == @new_pwd_confirmation ) && ( @new_pwd.to_s[@new_pwd.to_s.size-1] != "." ) ) # que la nueva contrasena no termine en punto, porque el '.' esta reservado ok ted.
              @usuario_seleccionado.contrasena = @new_pwd 
              @usuario_seleccionado.save! #cambio de contrasena realizado. ok.
             # puts ("^^^^^^^^Line Debug 3 - OK ")
              render plain: "pwd_changed_ok" and return  #reponder al js ok.
           else
             # puts ("^^^^^^^^Line Debug 4 - OK ")
              render plain: "pwd_fail" and return  #reponder al js: pwd_fail or does not match confirmation ok. ted.
             
           end

        else 
          # render Usuario no existe o session no valida. ok.
          render plain: "invalid_user_or_session_command" and return
          
        end
           
     end 


#PROCESAR JUGADAS NORMAL, SI EL JUGADOR_RONDA EN '*', MUTIPLAYER, PREPARAR UN SOLO PAQUETE HASH Y SORTEO Y DEMAS ...

if not params.permit(:jugadas).values[0].to_s.empty? # procesar si llegan jugadas como parametro...
     
  #  LEER LAS JUGADAS RECIBIDAS Y PROCESAR: ( ahora mismo no manejo excepciones por el public resouces ok ted. provisional, avanzar.)
     jugadas = params.permit(:jugadas).values[0].to_s.split("...")[0]
     jugador_ronda = ( params.permit(:jugadas).values[0].to_s.split("...")[1].split("j")[1] ) || "-1" # => 1 jugador por ejemplo ok.

   #verificar si es una ronda multiplayer (j*), procesarlo mediante una funcion, de lo contrario, si es un monojugador, procesarlo normal ok.
   if(jugador_ronda == '*') #if condition que verifica si es un monojugador o un mutijugador para procesar los hashes de jugadas ok
     @st_respuesta = procesamiento_multijugador()
     render plain: "#{@st_respuesta}" and return    
   else   
     
     #verificar si el jugador tiene credito > 0 y si no es "-1" para hacer el juego. La verificacion del credit viene para evitar que dos cel se loggeen mismo user uno haga cashout y el otro no y siga jugando, no debe haber sorteo en ajax del js cliente ok.
     if( ( Rondaruletabbt.where(:jugador => jugador_ronda ).last.credit.to_i == 0 ) || ( jugador_ronda == "-1") )
       render plain: "notienecreditosparajugar" and return 
     end


    #@current_user_id = Usuariosbrt.where(:usuario => @current_user).first.id # consigo el id de este usuario.
    #session[:usuario_actual] = @current_user # Lo pongo (el usuario actual) en la sesion de js. para fines de informacion o consulta necesaria
    #session[:usuario_actual_id] = @current_user_id # put the user.id info en session ok.
    #HACER FUNCIOM Y LO MISMO PARA ASK_NEW CREDIT REFRESH LOGIN

    #u_obj = Usuariosbrt.find(session[:usuario_actual_id]) # objeto usuario, leer flag_logout database



     #verificar si el jugador esta loggeado o no, leyendo el flag_logout ok:
     if not general_logged_in_user(session[:usuario_actual_id]) # esta funcion esta en general Application_controller ok. si devuelve true, el usuario si esta loggeado. ok.
       render plain: "nopuedejugarnologgeado" and return 
     end

   #  if( session[:flag_logout] == 1 )
   #    render plain: "nopuedejugarnologgeadoahoramismo" and return 
   #  end






    # puts("&&&&&&&&&&&&&&&&&&&&&&& Balance actual: "  + Rondaruletabbt.where(:jugador => jugador_ronda ).last.credit.to_s)
     
    # puts("&&&&&&&&&&&&&&&&&&&&&&& JugadoR actual: " + Rondaruletabbt.where(:jugador => jugador_ronda ).last.jugador.to_s)

     #separar las jugadas y procesar la ronda..
     array_separacion_a = jugadas.split(" ")
     hash_jugadas = {} # inicializo el hash que va a contener las jugadas que llegaron
     total_apostado = 0;
     
     #sacar las jugadas y luego posible suma de total bet de esa ronda ok.
     array_separacion_a.each do |botones|
       hash_jugadas["#{botones.split('>')[0]}"] = botones.split('>')[1] # "btn_0_1"=>"y", etc..De esta forma asigno los key values y voy llenando el hash_jugadas. ok ted.     
        #voy sumando el total apostado:
        if (botones.split('>')[1]  == 'y' )
          total_apostado += botones.split('>')[0].split("_")[2].to_i # "btn_0_1".split("_")[2] => 1

          #tambien aprovechar este loop para saber cuanto hay apostado por numero, usar el otro hash      
          @hash_cant_apostada_por_numero["#{botones.split('>')[0].split("_")[1]}"] +=  botones.split('>')[0].split("_")[2].to_i

        end
      
     end # fin del ciclo array_separacion_a.each do |botones|

       #organizo en sort el hash @hash_cant_apostada_por_numero
    ##    puts("..........#{@hash_cant_apostada_por_numero.sort_by {|k,v| v}}") 
    ##    puts("..........#{@hash_cant_apostada_por_numero.sort_by {|k,v| v}.flatten.join(",").split(",")}") 

        #Organizar cantidad apostada por numero de menor a mayor para evaluarlo en modo recovery ok.
    ###    strict_array_global = @hash_cant_apostada_por_numero.sort_by {|k,v| v}.flatten.join(",").split(",")

    ###    strict_array_candidatos = strict_array_global[0], strict_array_global[2] , strict_array_global[4] # , strict_array_global[6] => tres lugares mientras tanto ok.
       
    ###    posicion_win_spin = @hash_numeros["#{strict_array_candidatos.shuffle[0]}"] #sacar la posicion en base al num ganador sorteado. ok ted. Porque al js se manda la posicion donde stop spin, no el numero ok. ted.
        
        #HASTA AQUI OK MODO STRCI FUNCIONANDO SIN EL IF CONDITION, PONERLO Y HACER LA CONTABILIDAD
        #LUEGO EL CASHOUT Y EL CREDIT JS TIMER  

    ###    puts("Data: strict_array_global: #{strict_array_global}")       
    ###    puts("Data: strict_array_candidatos: #{strict_array_candidatos.flatten}")       
    ###    puts("Data: posicion_win_spin: #{posicion_win_spin}")       


      #  puts("klkkkkkkkkkkkkkkkkkkkkkkkkkkk" + hash_jugadas.to_s)
     #   puts("klkkkkkkkkkkkkkkkkkkkkkkkkkkk" + total_apostado.to_s)
    #   0-1,2,3,4
    #   1-1,2,3,4

    # h  = Hash.new
    # h = {"carro1":"toyota", }

   ####    #Actualizar el credito
   ####    ronda_obj = Rondaruletabbt.last
   ####    ronda_obj.credit = ronda_obj.credit.to_i - total_apostado.to_i # arriba revisar que sea mayor que cero para procesar la jugada, en js del html esta considerando pero no es seguro, validar en el controller tbn ok ted pendiente.
       
   ####    ronda_obj.save! # consierar execpciones futuras pendiente ok ted. Lo act de una vez porque si se va la luz (intencionalmente o no) descuento al apuesta. La cashier reportara?  
     # if( (ronda_obj.credit.to_i - total_apostado.to_i) >= 0) # nunca se puede apostar mas que el credito disponible, seguridad evitar inventos desde web js ok ted. 
     #   ronda_obj.save! # consierar execpciones futuras pendiente ok ted. Lo act de una vez porque si se va la luz (intencionalmente o no) descuento al apuesta. La cashier reportara?  
     # else
     #   ronda_obj.credit = 0; # le cancelo el credito por intendo de apostar mas de lo que tiene... provisional.
     #   ronda_obj.save!
     # end

     


   #procesar las matematicas y demas:
   #play normal(implica 7.7 beneficio pero no estable) y si el cashbox < 13%fondo, se pone en modo recovery strict  dato:normal deja un 13/12 = 7.7% paga un 92.3% aprox.
   @fondo_disponible = Fondot.first.cantidad.to_f # flotante .. ok. 100 # Debe ser via ACTIVE RECORD.... ok..nota el FONDO ES LO RECAUDADO, NO EL TOTAL IN. OK TED. EL FONDO ES EL BALANCE ACTUAL.
   
   @contador = Contadorest.first 

   @cashbox =  Cashboxt.first.cantidad # ES UN PORCENTADE DE LA ENTRADA APOSTADA PERDEDORA, LA OTRA PARTE VA A LOS JKPYS Y AL FONDODISPONIBLE
   
   @jackpot_rojo = 0
   @jackpot_negro = 0
   #@total_in = 0
   #@total_out = 0
   
  # puts("+++**************cashbox: #{@cashbox}")

   #valor1b = ( 0.13 * @contador.totalnet.to_f.round(4) )  
  # puts("+++**************0.13 x contador.totalnet: #{ valor1b}")

  # valor1 = ( 0.13 * @fondo_disponible )
  # puts("*****************0.13xfondodisp: #{valor1}")
  # puts("***************fondo_disponible: #{@fondo_disponible}")    

  # puts("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk")      
   #bbb = ( 0.13 * @contador.totalin.to_f.round(4) ).round(4)
 # puts("_________________contador total in x 0.13: #{bbb}") 
 #  puts("_________________contador total net #{@contador.totalnet.to_f.round(4)}")


   #verifico si no hay que entrar en modo recovery:
   #NOTA EL VALOR DEL CASHBOX ES UN 13 PORCIENTO DEL CONTADOR totalin Y LO COMPARO CON UN PORCENTAJE DEL FONDO DISPONIBLE PARA SABER SI ENTRA O NO AL STRICT MODE. OK.
  # if( ( (@cashbox.to_f.round(4) ) < ( 0.13 * @contador.totalin.to_f.round(4) ).round(4) )  ||  ( @contador.totalnet.to_f <= 0 ) ) 
   if( ( ( @contador.totalnet.to_f.round(4) ) < ( 0.13 * @contador.totalin.to_f.round(4) ).round(4) )  ||  ( @contador.totalnet.to_f.round(4) <= 0 ) ) 
    #entramos al modo recovery
    #Se revisan todas las apuestas y se sortean las 3 de 13 posibilidades con menor riesgo de pago.
     #Organizar cantidad apostada por numero de menor a mayor para evaluarlo en modo recovery ok.
      strict_array_global = @hash_cant_apostada_por_numero.sort_by {|k,v| v}.flatten.join(",").split(",")

      strict_array_candidatos = strict_array_global[0], strict_array_global[2] , strict_array_global[4] # , strict_array_global[6] => tres lugares mientras tanto ok.
     
      posicion_win_spin = @hash_numeros["#{strict_array_candidatos.shuffle[0]}"] #sacar la posicion en base al num ganador sorteado. ok ted. Porque al js se manda la posicion donde stop spin, no el numero ok. ted.
      
      #HASTA AQUI OK MODO STRCI FUNCIONANDO SIN EL IF CONDITION, PONERLO Y HACER LA CONTABILIDAD
      #LUEGO EL CASHOUT Y EL CREDIT JS TIMER  
 ##     puts("Data: strict_array_global: #{strict_array_global}")       
 ##     puts("Data: strict_array_candidatos: #{strict_array_candidatos.flatten}")       
 ##     puts("Data: posicion_win_spin: #{posicion_win_spin}")       
    #De las entragas descontar lo sgte: un porciento va al cash, otro al fondo, otro a los jkpots rojo y negro. De las entradas.
   
   elsif ( ( @contador.totalnet.to_f.round(4) ) > ( 0.30 * @contador.totalin.to_f.round(4) ).round(4) )
      #Si entra aqui es porque la recudacion sobrepasa el 30porciento del totalin, vamos a repartir al jugador para que las recaudaciones no suban tanto y ellos se motiven y no se espanten. Justo.
  ##    puts("oooooooooooooooooEstamos en la parte de mayor al 30 porciento recaudaddo: premios mas grandes ok.")
      strict_array_global = @hash_cant_apostada_por_numero.sort_by {|k,v| v}.reverse.flatten.join(",").split(",")

      strict_array_candidatos = strict_array_global[0], strict_array_global[2] , strict_array_global[4] # , strict_array_global[6] => tres lugares mientras tanto ok.
     
      posicion_win_spin = @hash_numeros["#{strict_array_candidatos.shuffle[0]}"] #sacar la posicion en base al num ganador sorteado. ok ted. Porque al js se manda la posicion donde stop spin, no el numero ok. ted.
      
   else     
      #natural mode:
      posicion_win_spin = rand(1..13) # => retorna aleatorio entre 1 y 13 ok ted intervalos cerrados ok [1-13].
      #recuerda que n es la posicion, para saber el numero que hay en esa posicion consultamos el hash de posiciones. ok ted.
      #recuerda que la posicion representa los numeros, hay que hashearlo para sacar los valores... ok
   end
   #posicion_win_spin = 13

   #in = 30 (apostado) # => total_apostado
   #out = 0 (ganado)
   #net = in - out (neto)
   #distribucion:
  # cashbox = 0.13 * neto
  # jackpot_rojo = 0.01 * neto
  # jackpot_negro = 0.01 * neto
  # @fondo_disponible += (1 - 0.13 - 0.1 - 0.1 ) * neto

   #seguimos normal..

   #modo recovery strict:
   #Consultar parametros (Active Record): fondo, cashbox; y las jugadas y el total apostado etc..
   #saber cuanto tiene apostado cada numero? modo strict_recovery



     valor_spin = @hash_posiciones[posicion_win_spin.to_s]
    #Note: this put id for Debugger only  ok. ted.
    # puts("Ganador es: #{valor_spin} ....  en la posicion #{posicion_win_spin}")
     #hash_jugadas["#{botones.split('>')[0]}"] = botones.split('>')[1] # "btn_0_1"=>"y"
     win_display = 0
     array_btn_resaltar_gandarores = "" # aqui se van a enviar los botones ganadores a resaltar ok. ted. 

     if (hash_jugadas["btn_#{valor_spin}_1"] == 'y' )
          win_display += 12
          array_btn_resaltar_gandarores += "btn_#{valor_spin}_1" + "k" # el separador es para el split('-') en js ok ted.
     end

     if (hash_jugadas["btn_#{valor_spin}_2"] == 'y' )
          #win_display += 24
           win_display += 25 #pago especial
          array_btn_resaltar_gandarores += "btn_#{valor_spin}_2" + "k"
     end

     if (hash_jugadas["btn_#{valor_spin}_3"] == 'y' )
          #win_display += 36
          win_display += 38 #pago especial
          array_btn_resaltar_gandarores += "btn_#{valor_spin}_3" + "k"
     end

     if (hash_jugadas["btn_#{valor_spin}_4"] == 'y' )
         # win_display += 48
          win_display += 50 #pago especial
          array_btn_resaltar_gandarores += "btn_#{valor_spin}_4" + "k"
     end


#ACTUALIZAR LOS CONTADORES:
   @contador = Contadorest.first # siempre actualizaremos una sola linea, la primera. ok. ted. standar.
   @contador.totalin  =  @contador.totalin.to_i + total_apostado.to_i  # in bet (total apostado in, no credito, sino apostado para las matematicas ok.)  like cashin vs coin in => coin in ok. ted.
   @contador.totalout =  @contador.totalout.to_i + win_display.to_i
   @contador.totalnet =  (@contador.totalin.to_i -  @contador.totalout.to_i).to_i
   @contador.save! # provisional save ok. Actualizo los contadores.



#formato para mostar win_display utilizando una funcion ya creada para new credit que tambien aplica para esto si hay win gandaores ok ted.
     win_display = formatear_credito_en_4_digitos_para_win_display(win_display)

     #ACTUALIZAR TABLAS MATEMATICAS Y REGISTAR RONDAS
     ronda_objold = Rondaruletabbt.where(:jugador => jugador_ronda ).last # 
     ronda_obj = Rondaruletabbt.new # este es en new actual a grabar ok.
     ronda_obj.jugador = jugador_ronda
     ronda_obj.win = win_display.to_i

     #aqui trabajamos con el viejo (ronda_objold) ok:
     ronda_obj.credit   = ronda_objold.credit.to_i - total_apostado.to_i  + win_display.to_i # Resto apostado y sumo Ganadores, si los hay ok. credito nueva ronda
     ronda_obj.jugadas  = hash_jugadas.flatten
     ronda_obj.totalbet = total_apostado.to_i
     ronda_obj.winnernumberspin = valor_spin
     ronda_obj.status = (win_display.to_i > 0)? "ganador" : "perdedor" # De la ronda, este estatus no incluye jacpots status ok ted, asociar este ultimo con el id de la ronda ok.
     ronda_obj.save!

#ACTUALIZAR LA DISTRIBUCION MATEMATICA:

     #net = in - out (neto)
   #distribucion:
   @cashbox = Cashboxt.first # primer registro siempre ok.
  # @cashbox.cantidad = (@cashbox.cantidad.to_f + ( 0.13 *  @contador.totalnet.to_f)).to_s
   @cashbox.cantidad =  ( 0.13 *  @contador.totalnet.to_f).round(4).to_s # NO SUMA ACUMULATIVA COMO ARRIBA OK.
   @cashbox.save

   #CONSULTAR LOS VALORES DEL LOS JACKPOTS:
   @jackpot_negro_obj = Jackpot.where(:color => "negro").first # objeto.
   @jackpot_rojo_obj  = Jackpot.where(:color => "rojo").first # objeto.

   #actualizo los totalin de los jackpots con el contador de entrada (totalin (coin in) ok)
   @jackpot_negro_obj.totalinnow =  @contador.totalin.to_i
   @jackpot_rojo_obj.totalinnow  =  @contador.totalin.to_i

   #actualizo la cantidad de ambos jackpots:
   @jackpot_negro_obj.cantidad =  ( (@jackpot_negro_obj.totalinnow.to_i - @jackpot_negro_obj.totalinold.to_i ) * 0.01 ).to_i #
   @jackpot_rojo_obj.cantidad  =  ( (@jackpot_rojo_obj.totalinnow.to_i  - @jackpot_rojo_obj.totalinold.to_i )  * 0.01 ).to_i
   
   #Guardar cambios jackpots:
   @jackpot_negro_obj.save!
   @jackpot_rojo_obj.save!

   @jpblackwin = 'n' # inicializar valor de variable en no ('n'). para no dejarla en nil ok. ted.
   @jpredwin = 'n' # inicializar valor de variable en no ('n'). para no dejarla en nil ok. ted.



   #jackpot negro:

   if( (@jackpot_negro_obj.cantidad.to_i > @jackpot_negro_obj.trigger.to_i) ) 
     #sortear jackpot negro
     # 1/200.
     if( (50 == rand(100)) && (win_display.to_i > 0) )  # nota rand(200) va del 0 al 199 (200 elementos) y rand(1..200) va del 1 al 200 cerrado y rand(0..200) va [0-200] => 201 elementos. ok probar en irb. Solo conocimiento Gral. ok. como esta esta funciona OK.sorteo aleatorio del premio 50 Y QUE SEA UNA JUGADA GANADORA 12,24,ETC.., con probabilidad ganadora de 1/200 ok.
      #ganador
      @jpblackwin = 'y'

      #acreditar al jugador (ANTES DE HACER EL RESET PAR DE LINEAS DE CODIGO DEBAJO - OK.)
      ronda_obj.credit = ronda_obj.credit.to_i + @jackpot_negro_obj.cantidad.to_i 

      #setear el nuevo conteo modificando totalinold a su nuevo valor Y EL NUEVO VALOR DEL JACKPOT QUE VA A INICIAR EN CERO OK TED. ok. rodar ventada delta acumulado ok.
      @jackpot_negro_obj.totalinold = @jackpot_negro_obj.totalinnow

      @jackpot_negro_ganador_actual_solo_display = @jackpot_negro_obj.cantidad.to_i # Esto solo para mostrarlo en esta ronda antes de resetearlo a CERO ok ted.
      #setear el jackpot en cero ok (X-X = 0 ) ok. 
      @jackpot_negro_obj.cantidad = 0 # para que se muestre en el minimo (100) de una vez en la ruleta. ok. Reset.
      @jackpot_negro_obj.save!

      @jackpot_negro_obj.cantidad = @jackpot_negro_ganador_actual_solo_display # SOLO REASIGNAR EL VALOR EN RAM, NO GUARDAR, ESTO PARA QUE SE VISUALICE EN EN CLIENTE JS ESTA VEZ SOLAMENTE AL GANADOR. OK.
      
      #registar ganador de jackpot de esta ronda en su propio status para fines de consulta ok.
      ronda_obj.status = ronda_obj.status.to_s + ". Tambien ganador del Jackpot Negro: #{@jackpot_negro_obj.cantidad.to_i}"
      ronda_obj.save!
     end

   end


   #jackpot rojo:

   if( (@jackpot_rojo_obj.cantidad.to_i > @jackpot_rojo_obj.trigger.to_i) ) 
    #sortear jackpot rojo
     # 1/100 
     if( (50 == rand(100))  && (win_display.to_i > 0) )  # sorteo aleatorio del premio 50 y QUE SEA UNA JUGADA GANADORA 12,24,ETC, con probabilidad ganadora de 1/100 ok.
      #ganador
      @jpredwin = 'y'

      #acreditar al jugador (ANTES DE HACER EL RESET PAR DE LINEAS DE CODIGO DEBAJO - OK.)
      ronda_obj.credit = ronda_obj.credit.to_i + @jackpot_rojo_obj.cantidad.to_i 

      #setear el nuevo conteo modificando totalinold a su nuevo valor Y EL NUEVO VALOR DEL JACKPOT QUE VA A INICIAR EN CERO OK TED. ok. rodar ventada delta acumulado ok.
      @jackpot_rojo_obj.totalinold = @jackpot_rojo_obj.totalinnow
      
      @jackpot_rojo_ganador_actual_solo_display = @jackpot_rojo_obj.cantidad.to_i # CAPTURO VALOR EN MEMORIA RAM, ANTES DEL RESET OK. Esto solo para mostrarlo en esta ronda antes de resetearlo a CERO ok ted.

      #setear el jackpot en cero ok (X-X = 0 ) ok. 
      @jackpot_rojo_obj.cantidad = 0 # para que se muestre en el minimo (100) de una vez en la ruleta luego de la ronda js ok.
      @jackpot_rojo_obj.save!

      @jackpot_rojo_obj.cantidad = @jackpot_rojo_ganador_actual_solo_display # SOLO REASIGNAR EL VALOR EN RAM, NO GUARDAR, ESTO PARA QUE SE VISUALICE EN EN CLIENTE JS ESTA VEZ SOLAMENTE AL GANADOR. OK.
      
      #registar ganador de jackpot de esta ronda en su propio status para fines de consulta ok.
      ronda_obj.status = ronda_obj.status.to_s + ". Tambien ganador del Jackpot Rojo: #{@jackpot_rojo_obj.cantidad.to_i}"
      ronda_obj.save!

     end

   end


   #COMO EL JP ES UN PORCENTAJE, PUEDES RESETEAR EL CONTADOR, O PASARLO AL REGISTRO EN CUANTO ESTABA CUANDO SACARON EL JP, O INICIAR UN CONTADOR PARALEO (CONT_NEW-CONT_OLD X 0.01) ALGO ASI.. LATER.. YA QUE EL NO PUEDE SER UN 0.01 DEL TOTAL NET GLOBAL DE 5 ANIOS POR EJEMPLO.. OK.
  # @jackpot_negro =  (0.01 * @contador.totalin.to_f).round(4).to_s  # manejar el float como String, provisional.. luego..tambein seria += ojo en el modelo pendiete ok.
  # @jackpot_rojo = (0.01 * @contador.totalin.to_f).round(4).to_s  # seria += ojo en el modelo pendiete ok.

   # Si el jackpot es ganador acreditarto en del credit del player:   ronda_obj.credit += black/redjckpot.cantidad... etc...ronda_obj.save!


   @fondo = Fondot.first #.cantidad.to_f # primer registro siempre ok.
  # @fondo.cantidad = @fondo.cantidad.to_f  +  ((1 - 0.13 - 0.01 - 0.01 ) *  @contador.totalnet.to_f).to_f
   @fondo.cantidad =  ( (1 - 0.13 - 0.01 - 0.01 ) *  @contador.totalnet.to_f).to_f.round(4) #NO SUMA ACUMULATIVA 
   @fondo.cantidad = @fondo.cantidad.to_s # convertir el flotante a String.

   @fondo.save # actualizo el fondo del juego.



     #si la resta es negativa, mostrar solo el credit restante mientras se termina la ronda y el js lo normaliza con cancel refresh page. => significa que ya no le quedara mas balance para silimar cant de apuestas, mostrarle solo xx para no no pase el error del dia que mostro de balance credit "000-54" con balance y todos casallena varias veces. 76-130 = -54 ok ted.
     if ronda_obj.credit.to_i < 0  # ronda_obj.save!, ! devuelve el objeto en curso ok ted.
      ronda_obj.credit = 0 #provisional por si acaso. ok ted. Por si se repite el raro error. ok ted.
      ronda_obj.save # si hay alguna anormalia con el credit lo pongo en cero. castiago ok. js. 
     end
     new_credit  = formatear_credito_en_4_digitos_para_win_display(ronda_obj.credit)

     #verificar que los jackpots se muestren en 100 si estan por debajo de esa cantidad:
     @jpnegrodisplay = (@jackpot_negro_obj.cantidad.to_i <= 100)?  "100" : @jackpot_negro_obj.cantidad
     @jprojodisplay  = (@jackpot_rojo_obj.cantidad.to_i <= 100)?   "100" : @jackpot_rojo_obj.cantidad
             
     #test only:
    # @jpblackwin='y'
    # @jpredwin='y'        
                                                                                                                         # @jpnegrodisplay  - @jprojodisplay - @jpblackwin(y/n) - @jpredwin(y/n) [hacer las sumas en js, porque aqui en credit se va aponer y debe coincidir. ok. el efecto azul hacerlo luego del pago azul de la ruleta y verificar para ambor jkpots, se puede dar que ambos sean ganadores juntos ok. ted.]
     render plain: "#{posicion_win_spin}-#{win_display}-#{new_credit}-#{array_btn_resaltar_gandarores}-#{total_apostado}-#{@jpnegrodisplay}-#{@jprojodisplay}-#{@jpblackwin}-#{@jpredwin}" and return # win_position - win_display - win_credit - array_btn_resaltar_gandarores - totalapostado
     #monto apostado, si banlace da ok, si no refresh page y se limpian las jugadas prerealzadas y solo saldra el monto disponible actual
   
   end # fin del if condition if(jugador_ronda == '*') monojugador o multijugador para porcesamiento de hashes de jugadas entrantes ok. ted.  
   
     #NOTA:
     #LOS REPORTES DE VENTA LOS MANEJA EL PUNTO DE VENTA. AQUI SOLO EL PORCENTAJE MATEMATICO Y CONTADORES IN-OUT-NET, jackpots.. DESDE QUE EMPEZO Y LAST PLAYS AUDIT KLK Y COBRAR LAST PAID ETC...
end # fin del conditional: if not params.permit(:jugadas).values[0].to_s.empty?  ok

  #imprimir comando que esta llegando debug:
  puts(">>>>>>>>>>>>>>>>" + params.permit(:credit).values[0].to_s)

  render plain: "X Error: This view is not allowed and it will be reported! ok." and return 

end # fin del index controller definition ok ted.


  # GET /rondaruletats/1
  # GET /rondaruletats/1.json
  def show
  end

  # GET /rondaruletats/new
  def new
    @rondaruletat = Rondaruletat.new

   # render: "st1.html"
  end

  # GET /rondaruletats/1/edit
  def edit
  end

  # POST /rondaruletats
  # POST /rondaruletats.json
  def create
    @rondaruletat = Rondaruletat.new(rondaruletat_params)



    redirect_to new_rondatruletat_path and return # PROVISIONAL


    respond_to do |format|
      if @rondaruletat.save
        format.html { redirect_to @rondaruletat, notice: 'Rondaruletat was successfully created.' }
        format.json { render :show, status: :created, location: @rondaruletat }
      else
        format.html { render :new }
        format.json { render json: @rondaruletat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rondaruletats/1
  # PATCH/PUT /rondaruletats/1.json
  def update
    respond_to do |format|
      if @rondaruletat.update(rondaruletat_params)
        format.html { redirect_to @rondaruletat, notice: 'Rondaruletat was successfully updated.' }
        format.json { render :show, status: :ok, location: @rondaruletat }
      else
        format.html { render :edit }
        format.json { render json: @rondaruletat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rondaruletats/1
  # DELETE /rondaruletats/1.json
  def destroy
    @rondaruletat.destroy
    respond_to do |format|
      format.html { redirect_to rondaruletats_url, notice: 'Rondaruletat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  

  def hacer_login_logic_to_logout(valor)
    @listado_usuarios = Usuariosbrt.all # Consultar todos los usuarios objeto.
    hash_credentiales = {} #inicializo  hash_credentiales

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
          
          if (password == @h[id]) #@h[id].to_s[0..@h[id].to_s.size-1] eliminar el "b" character?
            @current_user = id# xx encontramos el curren_user NAME? not id here line ok.
            @current_user_id = Usuariosbrt.where(:usuario => @current_user).first.id # consigo el id de este usuario.
            session[:usuario_actual] = @current_user # Lo pongo (el usuario actual) en la sesion de js. para fines de informacion o consulta necesaria
            session[:usuario_actual_id] = @current_user_id # put the user.id info en session ok.
          #  true
          #  valor
          #cambio de contrasena intencional:
          u = Usuariosbrt.where(:usuario => @current_user).first

           #     if not u.contrasena.to_s.include?("pwdchangedlogout")
           #       u.contrasena = u.contrasena.to_s + "pwdchangedlogout" # le agrego una letra al pwd cambiado ok.
           #     end
          
           #modificar contrasena para generar un login oblidatorio:
           #Si no tiene punto se lo pongo y si lo tiene se lo quito ok ted:
           if( u.contrasena.to_s[u.contrasena.to_s.size-1] == "." )
            u.contrasena = u.contrasena.to_s[0..u.contrasena.to_s.size-2] # se lo quito si lo tiene
           else
            u.contrasena = u.contrasena.to_s + "." #se lo pongo
           end
           u.loggedin = 'n' # marco como no loggeado el flag de control.
           u.save # guardo los cambios.
             #activar session flag logout 1 ok:
             #session[:flag_logout] = 1  
             #u.touch # hago un update del record ok. u.touch

           false #genero el tener que hacer re-login ok
              

          end # del if condition b
          
        end # del if condition a

       end # del do | | ok

    
  end #end de la funcion  hacer_login_logic_to_logout(valor)


    def get_megajackpot_balance
        #funcion para leer remoto el megajackpot. Devuelve valor_del_megajackpot, "###" o "xxx" dependiendo condiciones. ok. ted.
        @local_check_megajackpot_status = (Jackpot.where(:color => "megajackpot" ).first )
       
     #   unless (@object_to_check_value_megajackpot_status.cantidad == "-1") # NOTA MANEJAR LO DEL NIL.CANTIAD CLASS ERROR OK. 


         #primero verificar que este activado
    #     "xxx"
    #    end

    end # fin de la funcion get_megajackpot_balance


    #funcion que verifica el status de la activacion local del megajackpot de la mq. Retorna true or false. ok.
    def  verificar_flag_activacion_mj_local # funcion que dice si el megajackpot local feature esta activo o no en la mq. 
        Jackpot.where(:color => "megajackpot" ).first.cantidad == "1" # retorna true or false ok. ted. Partiendo de que este registro este creado ok. Crearlo en setup initial config ruleta megajackpot ok ted.
    end


    def solicitar_latest_players
      @latest_players_obj = Rondaruletabbt.last(50).reverse # listar ultimas 25 entradas ok. ted.

      #conseguir balance actual de cada uno de ellos
      @titulo_header_playing_players = "@ Latest Online Players: " # + "</br>"
      @latest_playing_players = "" # arra para el semdi body de esta info ok ted.
      @resumen_player=[] # con este array contare solo los player online

      @latest_players_obj.each do |latest_players_obj|    
        @latest_playing_players += "* P#{latest_players_obj.jugador} -> $#{latest_players_obj.credit} -> #{latest_players_obj.updated_at.to_s[0..18]}" + "</br>" # el alert de js solo muestra 999 characters 25 lineas de estas aprox. ok. latest players playing 
        @resumen_player << latest_players_obj.jugador
      end # end del each do block ok.

      #@resumen_player.uniq.sort #elimina player repetidos y 'sort' lo organiza.

      #adicionar un html para el document.write del js client to go back or refresh web page ok:
      @latest_playing_players += "</br>" + "<button onclick='window.location.reload();'>OK</button>"

      @respuesta_completa =  @titulo_header_playing_players + "</br>  [" + @resumen_player.uniq.count.to_s + "] Player(s) : "  + @resumen_player.uniq.sort.to_s + "</br></br>" + @latest_playing_players.to_s #[2..(@latest_playing_players.to_s.size-2)]  #esto para eliminar los corchetes del array to string en la vista web ok, ej.["1,2,3"] => 1,2,3 ok


      
      @respuesta_completa.to_s #.size
      #999 character max buffer size del alert de js. ok. ted.

      
    end

    def solicitar_balance_de_todos_los_players #funcion code #217100
      #listar usuarios
      usuarios_ids = Usuariosbrt.all.ids

      #conseguir balance actual de cada uno de ellos
      @balance_de_los_jugadores = "@ Player -> Credit:" + "</br>"

      usuarios_ids.each do |user_id|
         if ( Rondaruletabbt.exists?(:jugador => user_id) )
             credito = Rondaruletabbt.where(:jugador => user_id).last.credit # este va a tener el credito actual.
          else
             credito = 0
          end

        @balance_de_los_jugadores << "* P#{user_id}  ---------> $#{credito} "  + "</br>"


      end

      #retornar el listado usuario - balance (El arreglo en string y de lo demas se encarda el que invoque la  funcion.)
      #@balance_de_los_jugadores << "     80 ->    $650" + "\n"
      #adicionar un html para el document.write del js client to go back or refresh web page ok:
      @balance_de_los_jugadores << "</br></br>" + "<button onclick='window.location.reload();'>OK</button>"

      @balance_de_los_jugadores.to_s #.size
      #999 character max buffer size del alert de js. ok. ted.
      
    end

    def solicitar_info_last_credit_in_out(user) # funcion code #172529  de solicita el last paid y last chasout del user. ok.
      #last credit in de ese player es el ultimo registro inscrito en el histroy con cashout=0 (porque cashin es > 0 ok ted) seung logica del controlador arriba index controller ok.:
      @last_credit_in_obj  = Historypostransaccionest.where(:jugador => user, :cashout => "0").last 
      @last_credit_out_obj = Historypostransaccionest.where(:jugador => user, :creditin => "0").last 

      @last_credit_in = @last_credit_in_obj.nil?? "never" : ( @last_credit_in_obj.creditin.to_s + " -> " + @last_credit_in_obj.updated_at.to_s[0..18] ) # recorta el -04:00 GMT del datetime ok.
      @last_credit_out = @last_credit_out_obj.nil?? "never" : ( @last_credit_out_obj.cashout.to_s + " -> " + @last_credit_out_obj.updated_at.to_s[0..18] ) # recorta el -04:00 GMT del datetime ok.
      
      respuesta = "Last (chasout) paid: $" + "#{@last_credit_out}" +  " | " + "Last credit in: $" + "#{@last_credit_in}"

    end


    def solicitar_info_contadores #funcion code #212522 para retornar el conteo actual de los contadores de la mq ok.

      c = Contadorest.last
      "[ IN:" + c.totalin.to_s + " ] [ OUT:"  + c.totalout.to_s + " ] NET:" + c.totalnet.to_s # retorna String ok.

    end


    def formatear_credito_en_4_digitos_para_win_display (credito)

         if(credito.to_i < 10 ) # un digito, completar 3 ceros para el credit_display ruleta.
             credito = "000"+credito.to_s
          end

          if(credito.to_i >= 10  && credito.to_i < 100 ) # dos digitos, completar 2 ceros para el credit_display ruleta.
             credito = "00"+credito.to_s
          end

          if(credito.to_i >= 100  && credito.to_i < 1000 ) # tres digitos, completar 1 cero para el credit_display ruleta.
             credito = "0"+credito.to_s
          end

          if(credito.to_i >= 1000  && credito.to_i < 10000 ) # cuatro digitos, completar 0 ceros para el credit_display ruleta.
             credito = credito.to_s
          end

          if(credito.to_i >= 10000 ) # posible cash over flow revisar. ok ted. 
             credito = "0000" # Error setear credito en cero. No puede ser mayor de 10mil monedas ok ted. Evitar overflow cash. 
          end

         credito # retorna este valor, ya que en el if clause no lo retorna ok. ted.
      
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_rondaruletat
      @rondaruletat = Rondaruletat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rondaruletat_params
      params.fetch(:rondaruletat, {})
    end


    def buscar_credito_pos()
      #NOTA, ESTA ACCION PARECE NO ESTAR USANDOSE AL MOMENTO, LA DEJAREMOS DEFINIDA OK, PERO EN LA LOGICA CREO QUE NO ESTA EN USO. OK.
       #XXX development curl: #{@serial_global_mq}
       # XXX asi no: ok ted: >>>> a = `curl -m 5 -k https://127.0.0.1/transaccionests?serial=003-000-1001` # -m 5 => 5 segs max timeout para que la conexion no se queden 'enganchada' ok ted. link: https://unix.stackexchange.com/questions/94604/does-curl-have-a-timeout/94612
       #curl -k param indica que no valide el certificado --insecure ok para local certificates ted.
     

    #   #development curl:
    #   #Hacerlo sin error de sintaxis, recuerde es una modalidad distinta de sintaxis usando el serial de la maquina como variable global, asi, ok ted:
    #   a = "curl -m 5  -k  \'https://127.0.0.1/transaccionests?serial=#{@serial_global_mq}\' "  #  Sintaxis adecuada para poner el serial de la maquina retornado por el valor de la variable, ok esto para buena practica de programacion, y cambio de serial mq de manera mas facil por compilado x maquina ok ted.
    #   comando = ` #{a} `   # ejecuta el comando en bash ok ted. ` ` ejecuta el comando en bash.

       #production curl:
       #Hacerlo sin error de sintaxis, recuerde es una modalidad distinta de sintaxis usando el serial de la maquina como variable global, asi, ok ted:
       a = "curl -m 5  -k  \'https://10.0.7.55/transaccionests?serial=#{@serial_global_mq}\' "  #  Sintaxis adecuada para poner el serial de la maquina retornado por el valor de la variable, ok esto para buena practica de programacion, y cambio de serial mq de manera mas facil por compilado x maquina ok ted.
       comando = ` #{a} `   # ejecuta el comando en bash ok ted. ` ` ejecuta el comando en bash.


       #production curl:
    #   a = `curl -m 5 -k https://10.0.7.55/transaccionests?serial=#{@serial_global_mq}` # -m 5 => 5 segs max timeout para que la conexion no se queden 'enganchada' ok ted. link: https://unix.stackexchange.com/questions/94604/does-curl-have-a-timeout/94612
     
      unless( (a.nil?) || (a.empty?) )
  

           # si hay credito devuelve algo asi => "@cash25^3021#" o "sincreditosporahora" con el split el segundo da nil, y nil.to_i => 0 ok, podemos comparar asi: a.split("^")[0].split("@cash")[1].to_i > 0 para saber si llego credito. probado en consola irb ok.
           credito_buscado = a.split("^")[0].split("@cash")[1].to_i # => 25

           if(a.to_s != "sincreditosporahora" ) # es un cash mu probable,  la parte de nil o empty ya esta considerada en el if condition superior. ok ted.
              jugador_a_acreditar = a.split("^")[1].split("j")[1].split("#")[0].to_i # @cash05^j1# => 1.to_i ok ted. jugador.
           end              

           if(credito_buscado > 0 ) # si es nil no entra  ok, el split lo pone nil si no llega creditos cash o algo como nil o algo como "sincreditosporahora" ok no entrara al if condition. ok.
            #hay credito, llevarloa al modelo Singlepostransaccionest para que el programa se encargue del resto.ok.
             s = Singlepostransaccionest.first
             s.creditin = credito_buscado.to_s + "j" + jugador_a_acreditar.to_s # asigno el credito buscado y el jugador a acreditar balance ok. desde el pos
             s.save # lo acredito al modelo para que la logica del controllador donde se llama esta funcion se encargue del resto ok.

             #Como el pos es independiente (remoto LAN), procedemos a guardar el credito en la ruleta de manera que este disponible para jugarlo ok, aja js y local active record lo puedan ver normal, ok:
          #   credito_remoto_transaccion_obj = Transaccionest.new
          #   credito_remoto_transaccion_obj.maquinat_id = Tipomaquinat.last.id # El id de la ultima maquina creada, que el es primero y ultimo de la vm ruleta svr client independiente, esto para fines de requisitos de registro del credito remoto consultado en el pos y guardarlo local en la db local del juego r12v ok.
          #   credito_remoto_transaccion_obj.tipotransaccion = "credito"
          #   credito_remoto_transaccion_obj.cantidad = credito_buscado.to_i
          #   credito_remoto_transaccion_obj.status ="ok" # asumimos ok, todo normal.
          #   credito_remoto_transaccion_obj.comando = "@cash" + credito_buscado.to_s + "^9999#" # esto como requisito, para llenar ese atributo ok, ej. comando = "@cash10^3978#" ok.
          #   credito_remoto_transaccion_obj.jugador = jugador_a_acreditar.to_s # => "4" por ejempli, sin j, ok.
          #   credito_remoto_transaccion_obj.save # acreditacion local ok. 
           end

         #  if a contiene cash ... acreditarlo
            # s = Singlepostransaccionest.first
         #  end
      end
      
    end


    def buscar_credito_multiplayer_pos()    
      #   #development curl:
      #   #Hacerlo sin error de sintaxis, recuerde es una modalidad distinta de sintaxis usando el serial de la maquina como variable global, asi, ok ted:
      #   a = "curl -m 5  -k  \'https://127.0.0.1/transaccionests?serial=#{@serial_global_mq}\' "  #  Sintaxis adecuada para poner el serial de la maquina retornado por el valor de la variable, ok esto para buena practica de programacion, y cambio de serial mq de manera mas facil por compilado x maquina ok ted.
      #   comando = ` #{a} `   # ejecuta el comando en bash ok ted. ` ` ejecuta el comando en bash.

          #production curl:
          #Hacerlo sin error de sintaxis, recuerde es una modalidad distinta de sintaxis usando el serial de la maquina como variable global, asi, ok ted:
          st_curl = "curl -m 5  -k  \'https://10.0.7.55/transaccionests?serial=#{@serial_global_mq}\' "  #  Sintaxis adecuada para poner el serial de la maquina retornado por el valor de la variable, ok esto para buena practica de programacion, y cambio de serial mq de manera mas facil por compilado x maquina ok ted.
          a = ` #{st_curl} `   # ejecuta el comando en bash ok ted. ` ` ejecuta el comando en bash.

          valor1 = nil
          valor2 = nil
         # puts ">>>Resultado del curl reciente: #{a}"
          #debugger

      unless( (a.nil?) || (a.empty?) ) # retorno de esto: a = `curl -m 5  -k  https://127.0.0.1:3000/transaccionests?serial=003-000-1001` ok
          

           # si hay credito devuelve algo asi => "@cash25^3021#" o "sincreditosporahora" con el split el segundo da nil, y nil.to_i => 0 ok, podemos comparar asi: a.split("^")[0].split("@cash")[1].to_i > 0 para saber si llego credito. probado en consola irb ok.
           credito_buscado = (a.split("^")[0].split("@cash")[1]).to_i / @factor_monetario.to_i # => 200/10 = 20 monedas
           jugador_a_acreditar = nil #inicializo en nil para la logica gral abajo. ok.

           if(a.to_s != "sincreditosporahora" ) # es un cash mu probable,  la parte de nil o empty ya esta considerada en el if condition superior. ok ted.
              jugador_a_acreditar = a.split("^")[1].split("j")[1].split("#")[0].to_i # @cash05^j1# => 1.to_i ok ted. jugador.
           end              

           if((credito_buscado > 0 ) && jugador_a_acreditar != nil ) # si es nil no entra  ok, el split lo pone nil si no llega creditos cash o algo como nil o algo como "sincreditosporahora" ok no entrara al if condition. ok.
             #ahy credito y tenemos el jugador a acreditar
             
             valor1 = credito_buscado.to_s
             valor2 = jugador_a_acreditar.to_s # retorno estos dos valores: credito, valor.
           
            #hay credito, llevarloa al modelo Singlepostransaccionest para que el programa se encargue del resto.ok.
            # s = Singlepostransaccionest.first
           #  s.creditin = credito_buscado.to_s + "j" + jugador_a_acreditar.to_s # asigno el credito buscado y el jugador a acreditar balance ok. desde el pos
            # s.save # lo acredito al modelo para que la logica del controllador donde se llama esta funcion se encargue del resto ok.

           end

          # nil, nil # retorno nil, nil si no hay nada por acreditar u otra condicion extrana ok.

         #  if a contiene cash ... acreditarlo
            # s = Singlepostransaccionest.first
         #  end

      end

     retorno = [ valor1 , valor2 ]   # retornan el valor del credito y del jugador (al mismo timepo y solo si AMBOS son validos, de lo contrario aborta con nil, nil ok) si los hay o nil, nil respectivamente. ok. ted.
      
    end


    def enviar_cashout_pos(monto)
      #por ahora el pago sera simplemente enviado al pos y listo, si no llega verificar conexion y de todas formas se puede consultar en el historial de pagos de la mq, ok like pot of gold ok. Esto para fines de cuadre, ajustes o auditoria ok.
      
      #OJO NOTA:
      #AQUI monto viene String asi ej.: 500j1 pago de 500 pesos al jugador 1, so para multiplicar * factor monetario, hacemos un split y luego un join para formar todo de nuevo ok.
      #procesarlo a pesos con el factor monetario de la ruleta ok
      monto_cash = monto.split('j')[0].to_i * @factor_monetario.to_i # ok. eje: 10 monedas => 100 pesos cashout ok
      monto_player = "j" + monto.split('j')[1].to_s # => "j1" de nuevo ok. "j" + "1"

      #reasignar valor del monto y jugador con su factor_monetario mutiplicado para formar el string comando de pago ok:
      monto = monto_cash.to_s + monto_player.to_s

      #enviarlo al pos: Get verb lik luis protocol to pay too. ok. ted.
       # development curl:
       # @pago = "curl -m 10  -k  \'https://127.0.0.1:3000/transaccionests?serial=003-000-1001&cashout=#{monto}\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
       

      #PARA PRODUCCION REAL ESTAREMOS MANDANDO LOS PAGOS AL POS REMOTE Y TBN LOCALMENTE LO GUARDAREMOS REGISTRADOS OK. TED. (ESTO PARA CONTROL DE CREDIT EN POS E HISTORIAL DE PAGOS EN LA MQ RL. OK.) 
      # ------------------ 
       #*SECCION PARA PAGOS LOCALMENTE: IMPPORTANTE, ESTA PARTE DE ABAJO ES LA ORIGINAL COMENTADA, PERMITE ENVIAR LOS PAGOS LOCALMENTE, O SEA CUANDO LA RULETA ES EL MISMO PUNTO DE VENTA. OK. LE CAMBIO LA URL PARA ENVIAR LOS PAGOS AL POS GLOBAL QUE PUEDE MANEJAR VARIAS MAQUINAS OK.
       # production curl:
       @pago = "curl -m 10  -k  \'https://127.0.0.1/transaccionests?serial=#{@serial_global_mq}&cashout=#{monto}\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
       comando = ` #{@pago} `   # ejecuta el comando en bash ok ted. ` ` ejecuta el comando en bash.


       #*SECCION PARA PAGOS REMOTO DENTRO DE LA MISMA RED LAN (ip pos .55 here), PERO PARA PAGOS EN UN POS CON VARIAS MAQUINAS RULETAS CONECTADAS OK:
       @pago = "curl -m 10  -k  \'https://10.0.7.55/transaccionests?serial=#{@serial_global_mq}&cashout=#{monto}\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
       comando = ` #{@pago} `   # ejecuta el comando en bash ok ted. ` ` ejecuta el comando en bash.

      # ------------------


    end


    def procesamiento_multijugador
      #esta funcion procesa los hashes mutijugadores
      jugadas = params.permit(:jugadas).values[0].to_s.split("...")[0] # empaquetado de 7 strings de jugadas, nota el primero no se usa, es el base, se deja por la estrucutra del programa ok.
      #Asignar los has de jugadas de cada jugador
    # string_jugadas_p0 = jugadas.split("x")[0] # el base , No Necesario.
      string_jugadas_p1 = jugadas.split("x")[1]
      string_jugadas_p2 = jugadas.split("x")[2]
      string_jugadas_p3 = jugadas.split("x")[3]
      string_jugadas_p4 = jugadas.split("x")[4]
      string_jugadas_p5 = jugadas.split("x")[5]
      string_jugadas_p6 = jugadas.split("x")[6]
      

      jugadores_sin_credito = [] # array que guardara los jugadores sin credito para esta ronda. Seran excluidos porteriormente ok. ted.\
      #revisar que cada jugador tiene su credito disponible para las rondas, el que no tenga credito le ponemos que 'n' a todas sus jugadas ok.
      [1,2,3,4,5,6].each do |jugador|
        if( ( Rondaruletabbt.where(:jugador => jugador ).last.credit.to_i == 0 ) )
          jugadores_sin_credito << jugador
        end

      end

        hash_jugadas_p1 = hash_jugadas_p2 = hash_jugadas_p3 = hash_jugadas_p4 = hash_jugadas_p5 = hash_jugadas_p6 = {} # delcaracion de hashes a llenar convertidos de string (from js) a hashes de jugadas ok.
        indicador_hash_actual = 0 # variable de control (contador) para saber en cual string_jugadas van en el loop de 6 veces ok.
        @total_apostado_multiplayer = 0; #variable de balance apostado global.

        #variables de balance apostado individual cada player (esto para el control de los creditos independiente).
        @total_apostado_multiplayer_p1 = 0 
        @total_apostado_multiplayer_p2 = 0 
        @total_apostado_multiplayer_p3 = 0 
        @total_apostado_multiplayer_p4 = 0 
        @total_apostado_multiplayer_p5 = 0 
        @total_apostado_multiplayer_p6 = 0 
      
      #LOOP:
      #separar las jugadas(QUE AHORA MISMO NO SON HASH, SON STRINGs comming from js y lo convertimos en hashes ok. En este bloque, entre otras cosas suma totales, etc.. ok) y procesar la ronda..
      [string_jugadas_p1, string_jugadas_p2, string_jugadas_p3, string_jugadas_p4, string_jugadas_p5, string_jugadas_p6].each do |jugadas|
            indicador_hash_actual += 1 #incremento para indicar que ya estoy en el primero.
            array_separacion_a = jugadas.split(" ")
            hash_jugadas = {} # inicializo el hash que va a contener las jugadas que llegaron
             
             
            #sacar las jugadas y luego posible suma de total bet de esa ronda ok.
            array_separacion_a.each do |botones|
                hash_jugadas["#{botones.split('>')[0]}"] = botones.split('>')[1] # "btn_0_1"=>"y", etc..De esta forma asigno los key values y voy llenando el hash_jugadas. ok ted.     
                #voy sumando el total apostado:
                if( (botones.split('>')[1]  == 'y' ) && (not jugadores_sin_credito.include?(indicador_hash_actual)) )# que no este en la lista de jugadores sin credito
                  @total_apostado_multiplayer += botones.split('>')[0].split("_")[2].to_i # "btn_0_1".split("_")[2] => 1

                  #control de total apostado individual:
                  if( indicador_hash_actual == 1)
                    @total_apostado_multiplayer_p1 += botones.split('>')[0].split("_")[2].to_i
                  end

                  if( indicador_hash_actual == 2)
                    @total_apostado_multiplayer_p2 += botones.split('>')[0].split("_")[2].to_i
                  end

                  if( indicador_hash_actual == 3)
                    @total_apostado_multiplayer_p3 += botones.split('>')[0].split("_")[2].to_i
                  end

                  if( indicador_hash_actual == 4)
                    @total_apostado_multiplayer_p4 += botones.split('>')[0].split("_")[2].to_i
                  end

                  if( indicador_hash_actual == 5)
                    @total_apostado_multiplayer_p5 += botones.split('>')[0].split("_")[2].to_i
                  end

                  if( indicador_hash_actual == 6)
                    @total_apostado_multiplayer_p6 += botones.split('>')[0].split("_")[2].to_i
                  end

                  #tambien aprovechar este loop para saber cuanto hay apostado por numero, usar el otro hash      
                  @hash_cant_apostada_por_numero["#{botones.split('>')[0].split("_")[1]}"] +=  botones.split('>')[0].split("_")[2].to_i

                end

            end # fin del ciclo array_separacion_a.each do |botones|

            #asignar el hash de jugada correspondiente de cada jugador [1..6]
            if( indicador_hash_actual == 1)
              hash_jugadas_p1 = hash_jugadas
            end

            if( indicador_hash_actual == 2)
              hash_jugadas_p2 = hash_jugadas
            end

            if( indicador_hash_actual == 3)
              hash_jugadas_p3 = hash_jugadas
            end

            if( indicador_hash_actual == 4)
              hash_jugadas_p4 = hash_jugadas
            end

            if( indicador_hash_actual == 5)
              hash_jugadas_p5 = hash_jugadas
            end

            if( indicador_hash_actual == 6)
              hash_jugadas_p6 = hash_jugadas
            end

      end #fin del loop string hashes ok: 


         #procesar las matematicas y demas:
         #play normal(implica 7.7 beneficio pero no estable) y si el cashbox < 13%fondo, se pone en modo recovery strict  dato:normal deja un 13/12 = 7.7% paga un 92.3% aprox.
         @fondo_disponible = Fondot.first.cantidad.to_f # flotante .. ok. 100 # Debe ser via ACTIVE RECORD.... ok..nota el FONDO ES LO RECAUDADO, NO EL TOTAL IN. OK TED. EL FONDO ES EL BALANCE ACTUAL.
         
         @contador = Contadorest.first 

         @cashbox =  Cashboxt.first.cantidad # ES UN PORCENTADE DE LA ENTRADA APOSTADA PERDEDORA, LA OTRA PARTE VA A LOS JKPYS Y AL FONDODISPONIBLE
         
         @jackpot_rojo = 0
         @jackpot_negro = 0
        

         #verifico si no hay que entrar en modo recovery:
         #NOTA EL VALOR DEL CASHBOX ES UN 13 PORCIENTO DEL CONTADOR totalin Y LO COMPARO CON UN PORCENTAJE DEL FONDO DISPONIBLE PARA SABER SI ENTRA O NO AL STRICT MODE. OK.
        # if( ( (@cashbox.to_f.round(4) ) < ( 0.13 * @contador.totalin.to_f.round(4) ).round(4) )  ||  ( @contador.totalnet.to_f <= 0 ) ) 
         if( ( ( @contador.totalnet.to_f.round(4) ) < ( 0.13 * @contador.totalin.to_f.round(4) ).round(4) )  ||  ( @contador.totalnet.to_f.round(4) <= 0 ) ) 
          #entramos al modo recovery
          #Se revisan todas las apuestas y se sortean las 3 de 13 posibilidades con menor riesgo de pago.
           #Organizar cantidad apostada por numero de menor a mayor para evaluarlo en modo recovery ok.
            strict_array_global = @hash_cant_apostada_por_numero.sort_by {|k,v| v}.flatten.join(",").split(",")

            strict_array_candidatos = strict_array_global[0], strict_array_global[2] , strict_array_global[4] # , strict_array_global[6] => tres lugares mientras tanto ok.
           
            posicion_win_spin = @hash_numeros["#{strict_array_candidatos.shuffle[0]}"] #sacar la posicion en base al num ganador sorteado. ok ted. Porque al js se manda la posicion donde stop spin, no el numero ok. ted.
            
            #HASTA AQUI OK MODO STRCI FUNCIONANDO SIN EL IF CONDITION, PONERLO Y HACER LA CONTABILIDAD
            #LUEGO EL CASHOUT Y EL CREDIT JS TIMER  
       ##     puts("Data: strict_array_global: #{strict_array_global}")       
       ##     puts("Data: strict_array_candidatos: #{strict_array_candidatos.flatten}")       
       ##     puts("Data: posicion_win_spin: #{posicion_win_spin}")       
          #De las entragas descontar lo sgte: un porciento va al cash, otro al fondo, otro a los jkpots rojo y negro. De las entradas.
         
         elsif ( ( @contador.totalnet.to_f.round(4) ) > ( 0.30 * @contador.totalin.to_f.round(4) ).round(4) )
            #Si entra aqui es porque la recudacion sobrepasa el 30porciento del totalin, vamos a repartir al jugador para que las recaudaciones no suban tanto y ellos se motiven y no se espanten. Justo.
        ##    puts("oooooooooooooooooEstamos en la parte de mayor al 30 porciento recaudaddo: premios mas grandes ok.")
            strict_array_global = @hash_cant_apostada_por_numero.sort_by {|k,v| v}.reverse.flatten.join(",").split(",")

            strict_array_candidatos = strict_array_global[0], strict_array_global[2] , strict_array_global[4] # , strict_array_global[6] => tres lugares mientras tanto ok.
           
            posicion_win_spin = @hash_numeros["#{strict_array_candidatos.shuffle[0]}"] #sacar la posicion en base al num ganador sorteado. ok ted. Porque al js se manda la posicion donde stop spin, no el numero ok. ted.
            
         else     
            #natural mode:
            posicion_win_spin = rand(1..13) # => retorna aleatorio entre 1 y 13 ok ted intervalos cerrados ok [1-13].
            #recuerda que n es la posicion, para saber el numero que hay en esa posicion consultamos el hash de posiciones. ok ted.
            #recuerda que la posicion representa los numeros, hay que hashearlo para sacar los valores... ok
         end
         #posicion_win_spin = 13


           valor_spin = @hash_posiciones[posicion_win_spin.to_s]
          #Note: this put id for Debugger only  ok. ted.
          # puts("Ganador es: #{valor_spin} ....  en la posicion #{posicion_win_spin}")
           #hash_jugadas["#{botones.split('>')[0]}"] = botones.split('>')[1] # "btn_0_1"=>"y"
           win_display = 0 #global
           win_display_p1 = 0 #credit win individual player
           win_display_p2 = 0 #credit win individual player
           win_display_p3 = 0 #credit win individual player
           win_display_p4 = 0 #credit win individual player
           win_display_p5 = 0 #credit win individual player
           win_display_p6 = 0 #credit win individual player
           indicador_hash_actual = 0 # NOTA: LA VUELTO A RESETEAR EN CERO PARA USAR LA MISMA VARIABLE DE CONTADOR, NO ESTA DECLARADA AQUI, ESTA DECLARADA MAS ARRIBA OK. SIMPLEMENTE LA LLEVO A CERO DE NUEVO. OK.
           
           array_btn_resaltar_gandarores = "" # aqui se van a enviar los botones ganadores a resaltar ok. ted. 
           @array_player_reparticion_jackpot = [] # este array contrendra los jugadores ganadores de ronda, los cuales recibiran la division del jackpot en caso de ser ganador ok.
          #[]recorrer los 6 hashes de nuevo .each do |hash_jugadas| para que se renombre el mismo codigo aqui?
          [hash_jugadas_p1, hash_jugadas_p2, hash_jugadas_p3, hash_jugadas_p4, hash_jugadas_p5, hash_jugadas_p6].each do |hash_jugadas|
               indicador_hash_actual += 1 #incremento contador para indicar posicion de indices ok.
               if ((hash_jugadas["btn_#{valor_spin}_1"] == 'y') && (not jugadores_sin_credito.include?(indicador_hash_actual) ) ) 
                    win_display += 12 #win global ok.
                    #control de total apostado individual:
                    if( indicador_hash_actual == 1)
                      win_display_p1 += 12
                      @array_player_reparticion_jackpot << 1
                    end

                    if( indicador_hash_actual == 2)
                      win_display_p2 += 12
                      @array_player_reparticion_jackpot << 2
                    end

                    if( indicador_hash_actual == 3)
                      win_display_p3 += 12
                      @array_player_reparticion_jackpot << 3
                    end

                    if( indicador_hash_actual == 4)
                      win_display_p4 += 12
                      @array_player_reparticion_jackpot << 4
                    end

                    if( indicador_hash_actual == 5)
                      win_display_p5 += 12
                      @array_player_reparticion_jackpot << 5
                    end

                    if( indicador_hash_actual == 6)
                      win_display_p6 += 12
                      @array_player_reparticion_jackpot << 6
                    end


                    array_btn_resaltar_gandarores += "btn_#{valor_spin}_1" + "k" # el separador es para el split('-') en js ok ted.
               end

               if ( (hash_jugadas["btn_#{valor_spin}_2"] == 'y' )  && (not jugadores_sin_credito.include?(indicador_hash_actual)) )
                    win_display += 25 #pago especial
                     #control de total apostado individual:
                    if( indicador_hash_actual == 1)
                      win_display_p1 += 25 #pago especial
                      @array_player_reparticion_jackpot << 1
                    end

                    if( indicador_hash_actual == 2)
                      win_display_p2 += 25 #pago especial
                      @array_player_reparticion_jackpot << 2
                    end

                    if( indicador_hash_actual == 3)
                      win_display_p3 += 25 #pago especial
                      @array_player_reparticion_jackpot << 3
                    end

                    if( indicador_hash_actual == 4)
                      win_display_p4 += 25 #pago especial
                      @array_player_reparticion_jackpot << 4
                    end

                    if( indicador_hash_actual == 5)
                      win_display_p5 += 25 #pago especial
                      @array_player_reparticion_jackpot << 5
                    end

                    if( indicador_hash_actual == 6)
                      win_display_p6 += 25 #pago especial
                      @array_player_reparticion_jackpot << 6
                    end
                    array_btn_resaltar_gandarores += "btn_#{valor_spin}_2" + "k"
               end

               if ( (hash_jugadas["btn_#{valor_spin}_3"] == 'y' ) && (not jugadores_sin_credito.include?(indicador_hash_actual)) )
                    win_display += 38 #pago especial
                     #control de total apostado individual:
                    if( indicador_hash_actual == 1)
                      win_display_p1 += 38 #pago especial
                      @array_player_reparticion_jackpot << 1
                    end

                    if( indicador_hash_actual == 2)
                      win_display_p2 += 38 #pago especial
                      @array_player_reparticion_jackpot << 2
                    end

                    if( indicador_hash_actual == 3)
                      win_display_p3 += 38 #pago especial
                      @array_player_reparticion_jackpot << 3
                    end

                    if( indicador_hash_actual == 4)
                      win_display_p4 += 38 #pago especial
                      @array_player_reparticion_jackpot << 4
                    end

                    if( indicador_hash_actual == 5)
                      win_display_p5 += 38 #pago especial
                      @array_player_reparticion_jackpot << 5
                    end

                    if( indicador_hash_actual == 6)
                      win_display_p6 += 38 #pago especial
                      @array_player_reparticion_jackpot << 6
                    end
                    array_btn_resaltar_gandarores += "btn_#{valor_spin}_3" + "k"
               end

               if ( (hash_jugadas["btn_#{valor_spin}_4"] == 'y' ) && (not jugadores_sin_credito.include?(indicador_hash_actual)) )
                    win_display += 50 #pago especial
                     #control de total apostado individual:
                    if( indicador_hash_actual == 1)
                      win_display_p1 += 50 #pago especial
                      @array_player_reparticion_jackpot << 1
                    end

                    if( indicador_hash_actual == 2)
                      win_display_p2 += 50 #pago especial
                      @array_player_reparticion_jackpot << 2
                    end

                    if( indicador_hash_actual == 3)
                      win_display_p3 += 50 #pago especial
                      @array_player_reparticion_jackpot << 3
                    end

                    if( indicador_hash_actual == 4)
                      win_display_p4 += 50 #pago especial
                      @array_player_reparticion_jackpot << 4
                    end

                    if( indicador_hash_actual == 5)
                      win_display_p5 += 50 #pago especial
                      @array_player_reparticion_jackpot << 5
                    end

                    if( indicador_hash_actual == 6)
                      win_display_p6 += 50 #pago especial
                      @array_player_reparticion_jackpot << 6
                    end
                    array_btn_resaltar_gandarores += "btn_#{valor_spin}_4" + "k"
               end
          end #end del loop de hashes ok.


      #ACTUALIZAR LOS CONTADORES:
         @contador = Contadorest.first # siempre actualizaremos una sola linea, la primera. ok. ted. standar.
         @contador.totalin  =  @contador.totalin.to_i + @total_apostado_multiplayer.to_i  # in bet (total apostado in, no credito, sino apostado para las matematicas ok.)  like cashin vs coin in => coin in ok. ted.
         @contador.totalout =  @contador.totalout.to_i + win_display.to_i
         @contador.totalnet =  (@contador.totalin.to_i -  @contador.totalout.to_i).to_i
         @contador.save! # provisional save ok. Actualizo los contadores.



      #formato para mostar win_display utilizando una funcion ya creada para new credit que tambien aplica para esto si hay win gandaores ok ted.
           win_display = formatear_credito_en_4_digitos_para_win_display(win_display)
           array_win_player = win_display_p1, win_display_p2, win_display_p3, win_display_p4, win_display_p5, win_display_p6
           array_total_apostado_multiplayer = @total_apostado_multiplayer_p1, @total_apostado_multiplayer_p2, @total_apostado_multiplayer_p3, @total_apostado_multiplayer_p4, @total_apostado_multiplayer_p5, @total_apostado_multiplayer_p6
           array_hash_jugadas = hash_jugadas_p1, hash_jugadas_p2, hash_jugadas_p3, hash_jugadas_p4, hash_jugadas_p5, hash_jugadas_p6
     
      [1,2,3,4,5,6].each do |jugador_ronda|
           win_display = array_win_player[(jugador_ronda.to_i - 1)] # asigno el valor de cada player win ok.
           @total_apostado_multiplayer_px = array_total_apostado_multiplayer[(jugador_ronda.to_i - 1)] # asigno el valor de cada player apostado bet ok.
           @array_hash_jugadas_px = array_hash_jugadas[(jugador_ronda.to_i - 1)]
           #ACTUALIZAR TABLAS MATEMATICAS Y REGISTAR RONDAS
           ronda_objold = Rondaruletabbt.where(:jugador => jugador_ronda ).last # 
           ronda_obj = Rondaruletabbt.new # este es en new actual a grabar ok.
           ronda_obj.jugador = jugador_ronda
           ronda_obj.win = win_display.to_i

           #aqui trabajamos con el viejo (ronda_objold) ok:
           ronda_obj.credit   = ronda_objold.credit.to_i - @total_apostado_multiplayer_px.to_i  + win_display.to_i # Resto apostado y sumo Ganadores, si los hay ok. credito nueva ronda
           ronda_obj.jugadas  = @array_hash_jugadas_px.flatten
           ronda_obj.totalbet = @total_apostado_multiplayer_px.to_i
           ronda_obj.winnernumberspin = valor_spin
           ronda_obj.status = (win_display.to_i > 0)? "ganador" : "perdedor" # De la ronda, este estatus no incluye jacpots status ok ted, asociar este ultimo con el id de la ronda ok.
           ronda_obj.save!

      end # fin del loop de act los creditos de cada jugador: [1,2,3,4,5,6].each do |jugador_ronda| ok.

      #ACTUALIZAR LA DISTRIBUCION MATEMATICA:

           #net = in - out (neto)
         #distribucion:
         @cashbox = Cashboxt.first # primer registro siempre ok.
        # @cashbox.cantidad = (@cashbox.cantidad.to_f + ( 0.13 *  @contador.totalnet.to_f)).to_s
         @cashbox.cantidad =  ( 0.13 *  @contador.totalnet.to_f).round(4).to_s # NO SUMA ACUMULATIVA COMO ARRIBA OK.
         @cashbox.save

         #CONSULTAR LOS VALORES DEL LOS JACKPOTS:
         @jackpot_negro_obj = Jackpot.where(:color => "negro").first # objeto.
         @jackpot_rojo_obj  = Jackpot.where(:color => "rojo").first # objeto.

         #actualizo los totalin de los jackpots con el contador de entrada (totalin (coin in) ok)
         @jackpot_negro_obj.totalinnow =  @contador.totalin.to_i
         @jackpot_rojo_obj.totalinnow  =  @contador.totalin.to_i

         #actualizo la cantidad de ambos jackpots:
         @jackpot_negro_obj.cantidad =  ( (@jackpot_negro_obj.totalinnow.to_i - @jackpot_negro_obj.totalinold.to_i ) * 0.01 ).to_i #
         @jackpot_rojo_obj.cantidad  =  ( (@jackpot_rojo_obj.totalinnow.to_i  - @jackpot_rojo_obj.totalinold.to_i )  * 0.01 ).to_i
         
         #Guardar cambios jackpots:
         @jackpot_negro_obj.save!
         @jackpot_rojo_obj.save!

         @jpblackwin = 'n' # inicializar valor de variable en no ('n'). para no dejarla en nil ok. ted.
         @jpredwin = 'n' # inicializar valor de variable en no ('n'). para no dejarla en nil ok. ted.

         @ganador_jackpot_negro = false #inicializar flag de control del boleto a enviar al megajackpot si no hay jackpot locales ganadores ok.
         @ganador_jackpot_rojo  = false #inicializar flag de control del boleto a enviar al megajackpot si no hay jackpot locales ganadores ok.
         
         #totalizo el win_display, esto para saber si hay ganadores global [1..6players] y tbn enviarlo como total win al final de la funcion ok luego al js ok.
          win_display = win_display_p1 + win_display_p2 + win_display_p3 + win_display_p4 + win_display_p5 + win_display_p6

         #jackpot negro:

         if ( (@jackpot_negro_obj.cantidad.to_i > @jackpot_negro_obj.trigger.to_i) ) 
           #sortear jackpot negro
           # 1/200.
           if ( (50 == rand(100)) && (win_display.to_i > 0) )  # nota rand(200) va del 0 al 199 (200 elementos) y rand(1..200) va del 1 al 200 cerrado y rand(0..200) va [0-200] => 201 elementos. ok probar en irb. Solo conocimiento Gral. ok. como esta esta funciona OK.sorteo aleatorio del premio 50 Y QUE SEA UNA JUGADA GANADORA 12,24,ETC.., con probabilidad ganadora de 1/200 ok.
              #ganador
              @jpblackwin = 'y'
              @ganador_jackpot_negro = true # este flag de control para no enviar boleto al megajackpot si ya este jackpot es ganador ok.
              #AQUI DETERMINAR A QUIENES SE VA A ACREDITAR O SUMAR EL JACKPOT, LOS QUE HAYAN JUGADO EL NUMERO GANADOR Y DIVIDIR EL JACKPOT ENTRE LA CANT DE JUGADORES QUE APOSTARON A ESE NUMERO, ACREDITARSELO DE UNA VEZ OK. (ESTO SE PUEDE LOGRAR UN UN ARRAY DE JUGADORES GANADORES ARRIBA, ALGO PARECIDO A LA LOGICA DE LOS QUE NO TIENEN CREDITO OK TED.)
              #acreditar al jugador (ANTES DE HACER EL RESET PAR DE LINEAS DE CODIGO DEBAJO - OK.)
              #organizar el array de ganadores no repetidos
              @array_player_reparticion_jackpot = @array_player_reparticion_jackpot.uniq.sort #elimina item repetidos y lo organiza
              
              #hacer el calculo de la division, partes iguales redondeadas (monedas enteras ok) to_i (no redondea, solo coge la parte del numero entera ok, en caso de la division ser decimal, redondeamos a favor, no en contra porque es una reparticion equitativa de un jackpot de varios ok ted. matematicas local.)
              partes_iguales = @jackpot_negro_obj.cantidad.to_i / @array_player_reparticion_jackpot.size # esto retorna un integer, no decimal ok. Porque array.size retorna un numero entero. entero/entero = entero.
              
              #loop para asignale la parte correspondiente del jackpot a cada jugador agraciado.
              @array_player_reparticion_jackpot.each do |player|
                  if ( Rondaruletabbt.exists?(:jugador => player) ) #verificar todo, que exista porque vamos a entregar cash en credit de cada player ok.
                    ronda_obj = Rondaruletabbt.where(:jugador => player ).last # encuentro el player ganador de jacpot para acreditarle su parte
                    #miniloop start
                    ronda_obj.credit = ronda_obj.credit.to_i + partes_iguales.to_i 
                    #miniloop end
                    #registar ganador de jackpot de esta ronda en su propio status para fines de consulta ok.
                    ronda_obj.status = ronda_obj.status.to_s + ". Tambien ganador de parte del Jackpot Negro: #{@jackpot_negro_obj.cantidad.to_i}, con su parte correspondiente en reparticion de #{partes_iguales.to_i }"
                 #   ronda_obj.save!
                  else
                   puts ("Usuario: #{player} no encontrado, como ganador de una parte del jackpot. Favor verificar logs.")
                 
                  end # fin del if else end condition ok.

              end # fin del loop  @array_player_reparticion_jackpot.each do |player|

              
            #setear el nuevo conteo modificando totalinold a su nuevo valor Y EL NUEVO VALOR DEL JACKPOT QUE VA A INICIAR EN CERO OK TED. ok. rodar ventada delta acumulado ok.
            @jackpot_negro_obj.totalinold = @jackpot_negro_obj.totalinnow

            @jackpot_negro_ganador_actual_solo_display = @jackpot_negro_obj.cantidad.to_i # Esto solo para mostrarlo en esta ronda antes de resetearlo a CERO ok ted.
            #setear el jackpot en cero ok (X-X = 0 ) ok. 
            @jackpot_negro_obj.cantidad = 0 # para que se muestre en el minimo (100) de una vez en la ruleta. ok. Reset.
         #   @jackpot_negro_obj.save!

            @jackpot_negro_obj.cantidad = @jackpot_negro_ganador_actual_solo_display # SOLO REASIGNAR EL VALOR EN RAM, NO GUARDAR, ESTO PARA QUE SE VISUALICE EN EN CLIENTE JS ESTA VEZ SOLAMENTE AL GANADOR. OK.
            
            
           end

         end


         #jackpot rojo:

         if  ( (@jackpot_rojo_obj.cantidad.to_i > @jackpot_rojo_obj.trigger.to_i) ) 
          #sortear jackpot rojo
           # 1/100 
           if  ( (50 == rand(100))  && (win_display.to_i > 0) )  # sorteo aleatorio del premio 50 y QUE SEA UNA JUGADA GANADORA 12,24,ETC, con probabilidad ganadora de 1/100 ok.
            #ganador
            @jpredwin = 'y'
            @ganador_jackpot_rojo = true # este flag de control para no enviar boleto al megajackpot si ya este jackpot es ganador ok.
            #AQUI DETERMINAR A QUIENES SE VA A ACREDITAR O SUMAR EL JACKPOT, LOS QUE HAYAN JUGADO EL NUMERO GANADOR Y DIVIDIR EL JACKPOT ENTRE LA CANT DE JUGADORES QUE APOSTARON A ESE NUMERO, ACREDITARSELO DE UNA VEZ OK. (ESTO SE PUEDE LOGRAR UN UN ARRAY DE JUGADORES GANADORES ARRIBA, ALGO PARECIDO A LA LOGICA DE LOS QUE NO TIENEN CREDITO OK TED.)
              #acreditar al jugador (ANTES DE HACER EL RESET PAR DE LINEAS DE CODIGO DEBAJO - OK.)
              #organizar el array de ganadores no repetidos
              @array_player_reparticion_jackpot = @array_player_reparticion_jackpot.uniq.sort #elimina item repetidos y lo organiza
              
              #hacer el calculo de la division, partes iguales redondeadas (monedas enteras ok) to_i (no redondea, solo coge la parte del numero entera ok, en caso de la division ser decimal, redondeamos a favor, no en contra porque es una reparticion equitativa de un jackpot de varios ok ted. matematicas local.)
              partes_iguales = @jackpot_rojo_obj.cantidad.to_i / @array_player_reparticion_jackpot.size # esto retorna un integer.
              
              #loop para asignale la parte correspondiente del jackpot a cada jugador agraciado.
              @array_player_reparticion_jackpot.each do |player|
                  if ( Rondaruletabbt.exists?(:jugador => player) ) #verificar todo, que exista porque vamos a entregar cash en credit de cada player ok.
                    ronda_obj = Rondaruletabbt.where(:jugador => player ).last # encuentro el player ganador de jacpot para acreditarle su parte
                    #miniloop start
                    ronda_obj.credit = ronda_obj.credit.to_i + partes_iguales.to_i 
                    #miniloop end
                    #registar ganador de jackpot de esta ronda en su propio status para fines de consulta ok.
                    ronda_obj.status = ronda_obj.status.to_s + ". Tambien ganador de parte del Jackpot Rojo: #{@jackpot_rojo_obj.cantidad.to_i}, con su parte correspondiente en reparticion de #{partes_iguales.to_i }"
                    ronda_obj.save!
                  else
                   puts ("Usuario: #{player} no encontrado, como ganador de una parte del jackpot. Favor verificar logs.")
                 
                  end # fin del if else end condition ok.

              end # fin del loop  @array_player_reparticion_jackpot.each do |player|

              
            #setear el nuevo conteo modificando totalinold a su nuevo valor Y EL NUEVO VALOR DEL JACKPOT QUE VA A INICIAR EN CERO OK TED. ok. rodar ventada delta acumulado ok.
            @jackpot_rojo_obj.totalinold = @jackpot_rojo_obj.totalinnow
            
            @jackpot_rojo_ganador_actual_solo_display = @jackpot_rojo_obj.cantidad.to_i # CAPTURO VALOR EN MEMORIA RAM, ANTES DEL RESET OK. Esto solo para mostrarlo en esta ronda antes de resetearlo a CERO ok ted.

            #setear el jackpot en cero ok (X-X = 0 ) ok. 
            @jackpot_rojo_obj.cantidad = 0 # para que se muestre en el minimo (100) de una vez en la ruleta luego de la ronda js ok.
            @jackpot_rojo_obj.save!

            @jackpot_rojo_obj.cantidad = @jackpot_rojo_ganador_actual_solo_display # SOLO REASIGNAR EL VALOR EN RAM, NO GUARDAR, ESTO PARA QUE SE VISUALICE EN EN CLIENTE JS ESTA VEZ SOLAMENTE AL GANADOR. OK.
            

           end

         end

       

         @fondo = Fondot.first #.cantidad.to_f # primer registro siempre ok.
        # @fondo.cantidad = @fondo.cantidad.to_f  +  ((1 - 0.13 - 0.01 - 0.01 ) *  @contador.totalnet.to_f).to_f
         @fondo.cantidad =  ( (1 - 0.13 - 0.01 - 0.01 ) *  @contador.totalnet.to_f).to_f.round(4) #NO SUMA ACUMULATIVA 
         @fondo.cantidad = @fondo.cantidad.to_s # convertir el flotante a String.

         @fondo.save # actualizo el fondo del juego.


         #AQUI UN LOOP PENDIENTE. DE REVIAR LOS 6 CREDITOS NEGATIVOS O NO, PROBLAMENTE NO SERA NECESARIO POR EL REFRESH PAGE LATER EN JS.

           #si la resta es negativa, mostrar solo el credit restante mientras se termina la ronda y el js lo normaliza con cancel refresh page. => significa que ya no le quedara mas balance para silimar cant de apuestas, mostrarle solo xx para no no pase el error del dia que mostro de balance credit "000-54" con balance y todos casallena varias veces. 76-130 = -54 ok ted.
   #        if ronda_obj.credit.to_i < 0  # ronda_obj.save!, ! devuelve el objeto en curso ok ted.
   #         ronda_obj.credit = 0 #provisional por si acaso. ok ted. Por si se repite el raro error. ok ted.
   #         ronda_obj.save # si hay alguna anormalia con el credit lo pongo en cero. castiago ok. js. 
   #        end

           #ESTO PROBABLEMENTE NO NECESARIO TAMPOCO LATER.
   #        new_credit  = formatear_credito_en_4_digitos_para_win_display(ronda_obj.credit)

           #verificar que los jackpots se muestren en 100 si estan por debajo de esa cantidad:
           @jpnegrodisplay = (@jackpot_negro_obj.cantidad.to_i <= 100)?  "100" : @jackpot_negro_obj.cantidad
           @jprojodisplay  = (@jackpot_rojo_obj.cantidad.to_i <= 100)?   "100" : @jackpot_rojo_obj.cantidad
                   
           #test only:
          # @jpblackwin='y'
          # @jpredwin='y'        
          # @jpnegrodisplay  - @jprojodisplay - @jpblackwin(y/n) - @jpredwin(y/n) [hacer las sumas en js, porque aqui en credit se va aponer y debe coincidir. ok. el efecto azul hacerlo luego del pago azul de la ruleta y verificar para ambor jkpots, se puede dar que ambos sean ganadores juntos ok. ted.]
      
      new_credit = "0000"#provisional
      # puesto mas arriba para hacer la logica del jckpot ok. win_display = win_display_p1 + win_display_p2 + win_display_p3 + win_display_p4 + win_display_p5 + win_display_p6
      win_display  = formatear_credito_en_4_digitos_para_win_display(win_display)
      
      # Sortear el Megajackpot version multiplayers ok:
      # Si no tuvo suerte en los dos jackpot locales rojo y negro, probar suerte con el Megajackpot. (Se sorteara si no son ganadores del jackpot locales, probar suerte tambien ahora en el Megajackpot. Se puede ganar el rojo, el negro o ambos. El mega es unico y se puede ganar si no ha podido ganar uno local ok, ted. Js etc.. setup donde. ok.)
      # Parte del curl y sorteo del megajackpot:
      @object_to_check_value_megajackpot_status = (Jackpot.where(:color => "megajackpot" ).first )
     
     # puts  "...............................tarumm..mj check........VALORES: mj_STATUS: #{@object_to_check_value_megajackpot_status.cantidad}, win_display: #{win_display.to_i} "
     # debugger
        

      unless( (@object_to_check_value_megajackpot_status.cantidad == "-1") || ( @ganador_jackpot_negro == true ) || ( @ganador_jackpot_rojo == true ) || ( win_display.to_i == 0 ) ) # ( win_display.to_i == 0 ) indica que no hubo ganadores en la ronda procesamiento multiganador, esto para considerarlo explicitamente only en el unless ok. Si no hay ganadores, el sortoe megajackpot no aplica obviamente ok.# probar suerte en megajackpot al menos que este desactivado o haya ganado el jackpot negro o el jackpot rojo en esta ronda. Probar suerte en el megajackpot, gestionar sorteo remoto ok.
       # en el curl debemos especificar lo sgte: ip del server, serial de la maq participante, contador
        
        #pendientes lunes 8 sept: seesta quedando en timeout de este curl ok. Resetear contribuyentes playing againg ok. Mega3 reply is not working con contribuyentest controller 
        
        #Consulta boleto megajackpot server local, development pruebas:
        #@boleto_megajackpot = "curl -m 3  -k  \'http://127.0.0.1:3000/contribuyentets?serial=#{@serial_global_mq}&contador=#{@contador.totalin}\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
       
        #Consulta boleto megajackpot server produccion ok https and ip svr ok:
        @boleto_megajackpot = "curl -m 1  -k  \'https://10.0.7.220/contribuyentets?serial=#{@serial_global_mq}&contador=#{@contador.totalin}\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
       

        comando = ` #{@boleto_megajackpot} ` # esto ejecuta el string de arriba en bash ok ted. 
       
        # Fortmato de trama de respuesta esperada: "Mega-#{@mega_sum}-ganador"
        #Pendiente al martes 08 setp: seguir trabajando de aqui en adelante comado recibido del server:
        #Normalizar comando.
        #probar comando en producttion normal(hacer las migraciones, setup copia de una vps anfines, megajackpot create db production settings, probar, etc.. https fix controllers code, etc.., js updates, serial maquina, trigger jackpot todos y el MEGA quitar el 0.5 de prueba por el real porcentaje, etc...)

       # comando = "MegaTestTED-200-ganador"
       # puts "valor de comando mjp winner retorno: #{comando}" + " Ver si es ganador: " + comando.to_s.split("-")[2].to_s
        #debugger


        #Debemos recibir del server  de megajackpot la respuesta de ganador+MOTNOGANADOR, se ser ganador claro, y procesar reparticion del jackpot si es ganador y responder al ajax del js ok ted.
        #ej.  respuesta del server de megajackpot recibida: "ganador_megajackpot+9999" || siga_participando+9999 megajackpot actual
        if( comando.to_s.split("-")[2] == "ganador" )
            @cantidad_ganadora_megajackpot = comando.to_s.split("-")[1].to_i # => "9999".to_i por ejemplo
            #repartimos el megajackpot en partes iguales de los jugadores participantes ganadores en esta ronda ok.  y respondemos al js
            @array_player_reparticion_jackpot = @array_player_reparticion_jackpot.uniq.sort #elimina item repetidos y lo organiza
            
            #hacer el calculo de la division, partes iguales redondeadas (monedas enteras ok) to_i (no redondea, solo coge la parte del numero entera ok, en caso de la division ser decimal, redondeamos a favor, no en contra porque es una reparticion equitativa de un jackpot de varios ok ted. matematicas local.)
            partes_iguales = @cantidad_ganadora_megajackpot / @array_player_reparticion_jackpot.size # esto retorna un integer, no decimal ok. Porque array.size retorna un numero entero. entero/entero = entero.
            
            #loop para asignale la parte correspondiente del jackpot a cada jugador agraciado.
            @array_player_reparticion_jackpot.each do |player|
                if ( Rondaruletabbt.exists?(:jugador => player) ) #verificar todo, que exista porque vamos a entregar cash en credit de cada player ok.
                  ronda_obj = Rondaruletabbt.where(:jugador => player ).last # encuentro el player ganador de jacpot para acreditarle su parte
                  #miniloop start
                  ronda_obj.credit = ronda_obj.credit.to_i + partes_iguales.to_i 
                  #miniloop end
                  #registar ganador de jackpot de esta ronda en su propio status para fines de consulta ok.
                  ronda_obj.status = ronda_obj.status.to_s + ". Tambien ganador de parte del Megajackpot de red global: #{@cantidad_ganadora_megajackpot}, con su parte correspondiente en reparticion de #{partes_iguales.to_i }"
                  ronda_obj.save!
                else
                 puts ("Usuario: #{player} no encontrado, como ganador de una parte del megajackpot. Favor verificar logs.")
               
                end # fin del if else end condition ok.

            end # fin del loop  @array_player_reparticion_jackpot.each do |player|

            @jpnegrodisplay = "MEGA" # esto para mostrarlo en el display parte negra de la ruleta
            @jprojodisplay  = @cantidad_ganadora_megajackpot.to_s # esto para mostrarlo en el display parte negra de la ruleta
            @jpredwin = 'y' # esto para generar el efecto ganador y resaltar la parte roja del cuadro jkpot de la ruleta que mostrar el total del mega ok. ted.

        end # fin del condition: if comando.to_s.split("+")[0] == "ganador_megajackpot"

      end # fin del Unless condition

      # Si esta ronda no es ganadora de todas formas hay que registrar el aporte de esta jugada, pero esta ocasion que no realice sorteo alla, solo actualizar aportes. ok ted.
      #hace el condition para evitar que se cumpla lo del un jackpot ganador en el unless ok. ted:

      if( win_display.to_i == 0 ) # ronda perdedora pero hay que actualizar balances del megajackpot con la entrada ok.
        #server de prueba local
        #@boleto_megajackpot = "curl -m 3  -k  \'http://127.0.0.1:3000/contribuyentets?serial=#{@serial_global_mq}&contador=#{@contador.totalin}-rondanoganadora\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.
        
        #server de megajackpot produccion y https:
        @boleto_megajackpot = "curl -m 1  -k  \'https://10.0.7.220/contribuyentets?serial=#{@serial_global_mq}&contador=#{@contador.totalin}-rondanoganadora\' "  # las comillas simples ' 'son para poder enviar multiple parametros ok ted.

        #ejecutar comando ok:
        comando = ` #{@boleto_megajackpot} ` # esto ejecuta el string de arriba en bash ok ted. 
        # Fortmato de trama de respuesta esperada: "Mega-#{@mega_sum}-sigaparticipando" no lo necesito ok.
      end
      

      #descomentar esto que vendria siendo el retorno de la funcion ok ted PDTE
      #render plain: "#{posicion_win_spin}-#{win_display}-#{new_credit}-#{array_btn_resaltar_gandarores}-#{@total_apostado_multiplayer}-#{@jpnegrodisplay}-#{@jprojodisplay}-#{@jpblackwin}-#{@jpredwin}" and return # win_position - win_display - win_credit - array_btn_resaltar_gandarores - totalapostado
      #      "3-1234-1234- -2-300-300-n-n" 
      #retortnar este string de resultado para que quien invoco la funcion se encargue del render and return ok ted:  nota: #{total_apostado} = 13 fijo por ahora ok no se esta usando en ajax js alla pero lo dejaremos deficino ok.
      a_retornar = "#{posicion_win_spin}-#{win_display}-#{new_credit}-#{array_btn_resaltar_gandarores}-13-#{@jpnegrodisplay}-#{@jprojodisplay}-#{@jpblackwin}-#{@jpredwin}" 

      #pendientes:
      # lo mismo para la parte monoplayer del jackpot.No dejarlo asi el monoplayer, el mega es para la multiplayer ok. Le monoplayer le dejan uno fijo jugando y participa hasta salir. ted. do not complicate for beggining process ok.
      # el server megajackpot. 
      # actualizacion del megajackpot display en js, when enabled or disables how, cada 30seg o on refresh only, etc..
    end # fin de la funcion procesamiento_multijugador()


    def buscar_credit_de_los_6_players
      #pregunto local, si hay pendiente lo busco y se mandan los 6 balances
      #si no hay, busco en el pos, si hay y es de [1 in 6] lo mismo de arriba
              @st_listado_credito_6_players = nil # "reload_new_credit" # Este Sting va a contener el credito actual de los 6 jugadores para enviarlo en el comando js response ok.
              @hay_que_actualizar_creditos_6_players = false
              @jugador_acreditado_color_mamey = nil # esta variable identificara al jugador acreditato del mutiplayer para resaltarlo mamey en le js ok.
              #revisar los 6 jugadores
              [1,2,3,4,5,6].each do |player|
                    @get_ask_player = player # renombro variable para usar codigo copiado ok.
                    @solicitante_credito = Usuariosbrt.find(@get_ask_player.to_i)
                
                    #Si exite, leer y actuar:
                    if( @solicitante_credito.ledejaroncredit == true )
                      
                      @solicitante_credito.ledejaroncredit =  false # desactivo el flag de notification
                      @solicitante_credito.save! # object save! ok.
                      #buscar el credito de los 6 y enviarlo
                      @hay_que_actualizar_creditos_6_players = true #activo el flag de envio
                      @jugador_acreditado_color_mamey  = @solicitante_credito.id
                     
                    end # end del if( @solicitante_credito.ledejaroncredit == true )

                
              end # end del  [1,2,3,4,5,6].each do |player|

              if @hay_que_actualizar_creditos_6_players
                  @st_listado_credito_6_players = "reload_new_credit" # Este Sting va a contener el credito actual de los 6 jugadores para enviarlo en el comando js response ok.

                  [1,2,3,4,5,6].each do |player|
                    @st_listado_credito_6_players += "+" + formatear_credito_en_4_digitos_para_win_display(Rondaruletabbt.where(:jugador => player ).last.credit.to_i) # esto para mandarlo con el formato display ok, string.
                  end # end del loop
                  #aqui debe retonar con lo ultimo evaluado ok. ted.
                  #retornaria un string compuesto asi: "reload_new_credit+100+200+300+400+500+600" de ejemplo 6 balances credits. ok.
                  @st_listado_credito_6_players += "+" + @jugador_acreditado_color_mamey.to_s

              else
                  #preguntar al pos y revisar si mandaron para nosotros 6:
                  respuesta_array_buscar_credito_multiplayer = buscar_credito_multiplayer_pos() # array [credito , jugador] ok ted.

                  @multicredit = respuesta_array_buscar_credito_multiplayer[0] # asignar valores del array retornado.
                  @multiplayer = respuesta_array_buscar_credito_multiplayer[1]

                  if ( [1,2,3,4,5,6].include?(@multiplayer.to_i) && (@multicredit != nil ) )# otra forma de verificar si es para uno de los 6 jugadores ok. ted.
                       #hay credito para uno de los nuestros
                       #acreditarlo
                     #cargar todos los balances para responder ok.

                      @jugador = @multiplayer.to_s

                      @credit_remoto = @multicredit.to_i
                      
                      ronda_actual =  Rondaruletabbt.where(:jugador => @jugador ).last ||  Rondaruletabbt.new # (si no existe lo creo) ronda y credito de ESE JUGADOR ok.
                     
                      ronda_actual.status = "cashin event: credito_actual + acreditado_from_pos = #{ronda_actual.credit.to_s} + #{@credit_remoto} al jugador j#{@jugador} = #{(ronda_actual.credit.to_i + @credit_remoto )}" #llevar un registro de envento acreditaciones en el status de esa ronda con ese credito ok ted.  real time logs.
                      ronda_actual.credit = ronda_actual.credit.to_i + @credit_remoto # acredito balance.
                      
                      #Todo normal hasta aqui, pero si el jugador no existe en usuario, aunque la ronda se cree con este jugador, prefiero ponerle el credit en cero ok. Esto porque un futuro este user se crea nuevo puede tener credit viejo disponible en la ronda ok. Que este en la ronda no importa, pero que empiece en cero si ok.
                      if not  Usuariosbrt.exists?(@multiplayer.to_i) # si no existe en User, guardo esta ronda con credit=0 ok. Y si existe todo sigue normal. Se le gurada al que existe para que cuando se loggee o pregunte este su credito ahi ok. Siempre y cunado exista va a tener credito > 0 ok.
                         ronda_actual.credit = 0
                      end

                      ronda_actual.jugador =  @jugador   # =>  s.creditin.split("j")[1].to_s  # ok lo mismo
                      ronda_actual.save # Acutualiza el balance ('save' has same id as 'update' here? ok.)

                      #llevar el creditin al historial transacicones credit/cahsout history de la maquina:
                      h = Historypostransaccionest.new
                      h.creditin = @credit_remoto
                      h.cashout = 0
                      h.jugador = @jugador
                      h.save

                     # s.creditin = 0 # reset to zero creditin. ok.
                     # s.save # limpio el creditin acreditado. ok.

                     #Ya actualizamos el credito reciente, ahora buscamos el balance de los 6 para enviarlo ok:
                     @st_listado_credito_6_players = "reload_new_credit"  # esto si cumple con la condicion de arriba: if ( [1,2,3,4,5,6].include?(@multiplayer.to_i) && (@multicredit != nil ) ) ok ted.
                     @jugador_acreditado_color_mamey =  @jugador
                     
                    [1,2,3,4,5,6].each do |player|
                      @st_listado_credito_6_players += "+" + formatear_credito_en_4_digitos_para_win_display(Rondaruletabbt.where(:jugador => player ).last.credit.to_i)
                      #aqui debe retonar con lo ultimo evaluado ok. ted.
                    end # end del loop
                    #aqui dede retotar balances de los 6 ok.
                      @st_listado_credito_6_players += "+" + @jugador_acreditado_color_mamey.to_s 
                     


                  else
                     nil #retorna nil funcion. ok ted. para que mande 'nada' como respuesta si no hubo new credit ok.                   
                  end
                nil # devolver nil tambien por si acaso, de todas formas va a retornar false por el if condition evaluation ok ted. ok ted. 
              end #end del if else condition del if @hay_que_actualizar_creditos_6_players ok.
              @st_listado_credito_6_players # probar aqui
    end # end de la funcion buscar_credit_de_los_6_players()

# http://127.0.0.1:3000/transaccionests?serial=003-000-0001&cashout=200
# http://127.0.0.1:3000/transaccionests?serial=003-000-0001&cashout=200

end # end de la clase.
