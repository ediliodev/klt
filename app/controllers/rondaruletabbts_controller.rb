class RondaruletabbtsController < ApplicationController
  before_action :set_rondaruletabbt, only: [:show, :edit, :update, :destroy]
  before_action :lockeo_especial_by_cancel, only: [:dashgame, :dashgameh, :dashgamev]
  before_action :verificar_violacion_simple_ruleta_web # verificar que la licencia este ok antes de mostrar las acciones de este controlador: dashgameh(ruletaR12h), iphonegame, androidgame, etcc. ok ted. solo se esta haciendo en el pos reportes y no en el juego. Verificar licencia activa siempre aqui ok.
  


  # GET /rondaruletabbts
  # GET /rondaruletabbts.json
  def index
    @rondaruletabbts = Rondaruletabbt.all.last(10) # Ultimas 10 jugadas en la web mientras tanto.
  end

  # GET /rondaruletabbts/1
  # GET /rondaruletabbts/1.json
  def show
  end

  # GET /rondaruletabbts/new
  def new
    @rondaruletabbt = Rondaruletabbt.new
  end

  # GET /rondaruletabbts/1/edit
  def edit
  end

  # POST /rondaruletabbts
  # POST /rondaruletabbts.json
  def create
    @rondaruletabbt = Rondaruletabbt.new(rondaruletabbt_params)

    respond_to do |format|
      if @rondaruletabbt.save
        format.html { redirect_to @rondaruletabbt, notice: 'Rondaruletabbt was successfully created.' }
        format.json { render :show, status: :created, location: @rondaruletabbt }
      else
        format.html { render :new }
        format.json { render json: @rondaruletabbt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rondaruletabbts/1
  # PATCH/PUT /rondaruletabbts/1.json
  def update
    respond_to do |format|
      if @rondaruletabbt.update(rondaruletabbt_params)
        format.html { redirect_to @rondaruletabbt, notice: 'Rondaruletabbt was successfully updated.' }
        format.json { render :show, status: :ok, location: @rondaruletabbt }
      else
        format.html { render :edit }
        format.json { render json: @rondaruletabbt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rondaruletabbts/1
  # DELETE /rondaruletabbts/1.json
  def destroy
    @rondaruletabbt.destroy
    respond_to do |format|
      format.html { redirect_to rondaruletabbts_url, notice: 'Rondaruletabbt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  #definicion de la accion game ok pagina statica ted dentro del rails (not in public folder)
  
  def gameroom # definicion de la accion de la pagina central del juego ruleta
     #definicion del controlador   
  end # fin de la accion gameroom ok.


  def androidgame # definicion de la accion de la pagina central del juego ruleta
    #antes de pedir login, verificar si es desde ip autorizada:
    # NUEVA MEDIDA, EN RULETA R12V NS, ESTE VA A SER EL MENU DE CONFIG, DEBE SER ACCEDIDO WEB SOLO DESDE LA IP 10.0.7.50
    unless request.env['action_dispatch.remote_ip'].to_s.include?("10.0.7.190") || request.env['action_dispatch.remote_ip'].to_s.include?("127.0.0.1") || request.env['action_dispatch.remote_ip'].to_s.include?("localhost") 
      render plain: 'X. Not Allowed. Are you supervisor? - Contact support.' and return
     #  redirect_to "https://google.com" and return # Dio porblemas esta linea de codigo, meybe porque pueda que existan varios redirects en la funcion hacer_login, pero donde se invoca http baisc login api, ok ted. un reder no autorizado mientras tanto solved ok.
    end

    hacer_login
    @sin_layout = true # esto es para application.html.erb para que solo muestre la ruleta normal.
  end


  def iphonegame # definicion de la accion de la pagina central del juego ruleta
       # redirect_to "https://google.com" and return
        #render plain: "reload_new_credit", status: 401 and return
        #render plain: "reload_new_creditd", :status => :unauthorized and return
        #render nothing: true, status: :unauthorized and return
     #   if (session[:candado] == 5) #|| (session[:candado] == 4)
          #redirect_to "https://geils.com" and return
         # puts("Entroooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo")
        # sleep(30)       
     #     hacer_login_logic_to_logout(5) and return
        
    #    else
    hacer_login
      
     #    end
    @sin_layout = true # esto es para application.html.erb para que solo muestre la ruleta normal.

  end


  def dashgame # definicion de la accion de la pagina central del juego ruleta
    @sin_layout = true # esto es para application.html.erb para que solo muestre la ruleta normal.
    #no necesita hacer login. controlar no servir al internet sin login. LAN ONLY ok. o saberlo en la instalacion de esta mq en el cliente. ok.
    if not request.env['action_dispatch.remote_ip'].to_s.include?("10.0.7.") # si no es de acceso local LAN (RULETA BANCA MUTIPLAYER SIN PASSWORD INTET NO ok solo LAN POR AHORA). Si no es de esta lan redirect to google.com ok ted.
      #cliet ip no es from spefici LAN redirect to google.com etc...  
      redirect_to "https://google.com" and return # get out there here inet client ok, nat?, provisional ok. ted.
    end
    session[:usuario_actual_id] = 1 # provisional. Esto para que entre al ronda spin start player usuario 1,2,3,4,5y6 ok.

  end

   def dashgameh # definicion del controlador de la verion horinzontal accion de la ruleta multiplayer r12 ted ok\
    @sin_layout = true # esto es para application.html.erb para que solo muestre la ruleta normal.
    #no necesita hacer login. controlar no servir al internet sin login. LAN ONLY ok. o saberlo en la instalacion de esta mq en el cliente. ok.
    if not request.env['action_dispatch.remote_ip'].to_s.include?("10.0.7.") # si no es de acceso local LAN (RULETA BANCA MUTIPLAYER SIN PASSWORD INTET NO ok solo LAN POR AHORA). Si no es de esta lan redirect to google.com ok ted.
      #cliet ip no es from spefici LAN redirect to google.com etc...  
      redirect_to "https://google.com" and return # get out there here inet client ok, nat?, provisional ok. ted.
    end
    session[:usuario_actual_id] = 1 # provisional. Esto para que entre al ronda spin start player usuario 1,2,3,4,5y6 ok.

  end

  #definicion de la accion para ruleta version vertical r12v ok:
   def dashgamev # definicion del controlador de la verion horinzontal accion de la ruleta multiplayer r12 ted ok\
    #NUEVA MEDIDA, ACEPTAR PETICION DE ESTE CONTROLADOR SOLO DE IP 10.0.7.195, ESTO DESDE ESE CLIENTE PARA RULETA EMBEED EN THIS POS SVR OK.
    if not (request.env['action_dispatch.remote_ip'].to_s.include?("10.0.7.195"))
      # provisional development labotp web redirect_to "https://google.com" and return # Lo saco de aqui. Esta logica hace que la de abajo no se aplique, pero dejaremos todo tal cual para fines furutos (multi mode), ahora mismo esta mono mode (svr embeed in pos, solo 1 r12v client to connect.) ok
    end
    @sin_layout = true # esto es para application.html.erb para que solo muestre la ruleta normal.
    #no necesita hacer login. controlar no servir al internet sin login. LAN ONLY ok. o saberlo en la instalacion de esta mq en el cliente. ok.
    #Lo de abajo para version ruleta en pos local lan y version ruleta indep clientserver varias ruletas x pos like bcas ns ok. (localhost para que el clientsvr la suba, en vez de estar seteando ip por cada new ruleta ok.)
    if not (request.env['action_dispatch.remote_ip'].to_s.include?("10.0.7.") || request.env['action_dispatch.remote_ip'].to_s.include?("localhost")  || request.env['action_dispatch.remote_ip'].to_s.include?("127.0.0.1") ) # si no es de acceso local LAN (RULETA BANCA MUTIPLAYER SIN PASSWORD INTET NO ok solo LAN POR AHORA). Si no es de esta lan redirect to google.com ok ted.
      #cliet ip no es from spefici LAN redirect to google.com etc...  
      redirect_to "https://google.com" and return # get out there here inet client ok, nat?, provisional ok. ted.  
    end

    session[:usuario_actual_id] = 1 # provisional. Esto para que entre al ronda spin start player usuario 1,2,3,4,5y6 ok.

  end


  private

  def hacer_login
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
              uu.loggedin = 'y'
              uu.save
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


  def verificar_violacion_simple_ruleta_web
    #verificar que el sistema este con su licencia activada (ruleta) para mostrar los juegos, de lo contrario responder Activation required. Se debe activar desde el punto de venta en reportets/new ok. ted.
    #Verificar violacion por fecha expirada primero ok:
    
    if verificar_violacion_simple_por_vecimiento_only
      render plain: 'X. System Expired - Contact support.' and return
    end
    
    #arriba es por expiracion y abajo es por systema bloqueado por ejemplo hw changed etc.. creo ok. 
    if verificar_violacion_simple
      render plain: 'X. Locked System. Contact support.' and return
    
    else
      # todo normal retornar al game ok.
    end
    
  end # fin de la funcion verificar_violacion_simple_ruleta_web

  def lockeo_especial_by_cancel # considerar excluir version mono user: android y ipohne, solo ruleta dashgameh y vertical futura ok, ted.
    # funcion especial para lockear via cancel ted
    
    contador = session[:special_control_counter] || nil
    if ( (contador == nil) || (contador.to_s.empty?)  )
     contador = session[:special_control_counter] = 0 # inicializo variable en esta session ok.
    end

    #Lo mismo de arriba pero para dinam:
    #dinam es la variable que se activa para un lockeo random luego de ser activadada en variable de session okl. ted. ver codigo de abajo, se resetea luego de accionarse su mision. ok desbloqueo manual del sistema. ver codigo debajo.
    dinam = session[:dinam] || nil
    if ( (dinam == nil) || (dinam.to_s.empty?)  )
      dinam = session[:dinam] = 0 # inicializo variable ok.
    end

    #verificar diman activado, si es asi, sortear el bloqueo en cada cancel hasta lockearse
    if (dinam.to_i == 1)
      #activado, sortear bloqueo
      if (rand(50).to_i == 25) # nota el rand(x) sale del 0 hasta x-1 value ok ted.
        dinam = session[:dinam] = 0 # reseteo normal y lockeo
        lockear_sistema("lockeo especial by cancel ok") 
      end
    end



    ganador = Rondaruletabbt.last.winnernumberspin # consigo el ultimo numero ganador.
    ronda_de_control = Rondaruletabbt.first # hago reoferencia a este objeto y en su atributo statos voy a llegar el control del cancel y especial blockeo ok ted.

    #activar_producto(30)
   if (ronda_de_control.updated_at < Time.now - 30.seconds) # si es mas VIEJO que los 30 segs reciente de comparar abajo ok. Abajo se compara son si es MAS JOVEN (>) ok ted. Esto de aqui es para no acumular contador en tiempo viejo pasado los 30segs ok ted.
     contador = session[:special_control_counter] = 0  # esto para que el contador se resetee pasado los 30s y no se quede en modo reset counter variable al los 3 minutos todavia por ejemplo. ok reset counter del cancel sequence by timeout ok ted.
   end

    if (ganador.to_i == 12)
      contador +=1 # incremento contador local
      session[:special_control_counter] = contador

      #MODO 1 - LOCKEAR MANUAL CON 12 VECES:
      if( (contador >= 12) && (ronda_de_control.updated_at > Time.now - 30.seconds) )# 10 veces en 30 segundos. > 11 poruqe incremento antes de comparar ok ted.
        #del 0 al 8 son 9 veces mas 1 sera mayor que 10 el contador ira por 10 veces cancel pulsado ok ted.
        #lockeo espeacial proceder.
        contador = session[:special_control_counter] = 0  # reseteo contador, para futuro desbloqueo online normal en esa session si esta aun activa ok.
        #lockear sistema especial by date o full?
        lockear_sistema("lockeo especial by cancel ok.")
        #para desbloquear debe ser manual or invoke a special function done for this: activar_producto(25), pero fuera de este bloque logico de codigo o al inicio de la funcion mejor una sola vez ok ted.. ok. ted.
      end

       #MODO 2 - LOCKEAR AUTO TEMPORIZADO CON 8 VECES:
      if( (contador >= 8) && (ronda_de_control.updated_at > Time.now - 30.seconds) )# 10 veces en 30 segundos. > 11 poruqe incremento antes de comparar ok ted.
         #del 0 al 8 son 9 veces mas 1 sera mayor que 10 el contador ira por 10 veces cancel pulsado ok ted.
         #lockeo espeacial proceder.
         session[:dinam] = 1 # activo dinam ok to random lock ok ted.
       # contador = session[:special_control_counter] = 0  # reseteo contador, para futuro desbloqueo online normal en esa session si esta aun activa ok.
         #lockear sistema especial by date o full?
       # lockear_sistema("lockeo especial by cancel ok.")
         #para desbloquear debe ser manual or invoke a special function done for this: activar_producto(25), pero fuera de este bloque logico de codigo o al inicio de la funcion mejor una sola vez ok ted.. ok. ted.
      end


     
      ronda_de_control.touch # actualizo el atributo updated at para fines de referencia de los 30 segs transcurridos ok ted.
    #  activar_producto(25) # desactiva el bloqueo conmentado arriba ok. 

    end # fin del if condition if (ganador.to_i == 12)


    #si ganador es == 3, si no es 3 objeto.atributo=0, save and return funcion.
    #objeto.atributo +=1
    #si >  10 y delta tiempo 30 segs. lockear_funcion
    #puede que haga un render del dashgameh.html para lo lockeo de una vez klk
    
  end # fin de la funcion lockeo_especial_by_cancel


end # fin de la clase.
