class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  protect_from_forgery unless: -> { request.format.json? }  # agregado de este link ok ted: http://arduinoetcetera.blogspot.com/2017/04/example-ruby-on-rails-arduino-project.html
 # protect_from_forgery unless: -> { request.format.html? }


#Definiciond de la variable globar sw_id_pos, para que pueda ser modificada desde aqui en cada instalacion y accedida desde cualquier controller necesario, ok ted.
SW_ID_POS = "kpos-07-20-01"


#definicion general de los siguientes metodos para ser accesados o invocados posteriormente por ted desde cualquier controlador que herede de aqui, ok ted.

def registro_login_admin

  #consierar que no si no es nadie (cualquier cosa diferente de supervisor, admin, ventas, por ejemplo nil u otro valor desconocido, ok ted.) sea ventas el acceso.
  if( (session[:current_user].to_s != "ventas") && ( session[:current_user].to_s != "supervisor") && (session[:current_user].to_s != "admin") )
    session[:current_user] = "admin"
    @accesot = Accesot.new
    @accesot.usuario = "admin"
    @accesot.tipoacceso = "login"
    @accesot.fechayhora = Time.now
    @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
    @accesot.save
     
   end 

    if( (session[:current_user].to_s == "ventas") || (session[:current_user].to_s == "supervisor") )

      #registrar LOGOUT de admin o de supervisor, dependiendo valor de la session ok:       
      @accesot = Accesot.new
      @accesot.usuario = session[:current_user].to_s # selecciono el usuario a hacer logout. ok. (puede contener "admin" o "supervisor" solamente porque esta dentro del if condition ok ted.)
      @accesot.tipoacceso = "logout"
      @accesot.fechayhora = Time.now
      @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
      @accesot.save

      #registrar login ventas:
      session[:current_user] = "admin"
      @accesot = Accesot.new
      @accesot.usuario = "admin"
      @accesot.tipoacceso = "login"
      @accesot.fechayhora = Time.now
      @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
      @accesot.save

      #crear el scaffold de este modelo.
      #ver lo del after_filter action ok.
      #probarlo.
      #continuar lo mismo pero para admin, en los controladores requeridos.
       
    end 

  end #fin de la funcion  registro_login_admin


  def general_logged_in_user(usuario_actual_id)
      if Usuariosbrt.exists?(:id => usuario_actual_id)
       Usuariosbrt.find(usuario_actual_id).loggedin == 'y' || (usuario_actual_id.to_i == 1 ) || (usuario_actual_id.to_i == 2 )  || (usuario_actual_id.to_i == 3 ) || (usuario_actual_id.to_i == 4 ) || (usuario_actual_id.to_i == 5 ) || (usuario_actual_id.to_i == 6 ) #retorna true or false ok. || Bypass usuarios 1,2,3,4,5y6 para multiplayer roulette.
      else
        false # si no existe el else devuelve false ok.     
      end
      
  end



  def verificar_violacion_simple # ESTA FUNCION ESTA DEFINIDA EN APPLICATION CONTROLLER GRAL OK. PORQUE SE USA EN OTROS CONTROLADORES.

    t = Tipomaquinat.first # obtengo el primer registro

    if ( t.descripcion.include?('*') ) # sistema locked, solo se elimina manual ok. ted.
       true
    else
       false
    end
    
  end # fin de la funcion verificar_violacion_simple


  def verificar_violacion_simple_por_vecimiento_only # 

    t = Tipomaquinat.first # obtengo el primer registro

    if ( t.descripcion.include?('Licencia vencida') ) # por timepo vencido solamente, esto indica que no fue lockeo por situacion forzada como modifi de hw u hora ok. ted. solo timepo vencido ok.
       true
    else
       false
    end
    
  end # fin de la funcion verificar_violacion_simple



  def lockear_sistema razon # ESTA FUNCION ESTA DEFINIDA EN APPLICATION CONTROLLER GRAL OK.
    t = Tipomaquinat.first # apunto al primer registro
    t.descripcion =  "*" + "razon: " + razon.to_s # ej, razon: cambio de hw, atraso de hora intento, etc..
    t.save #modifico registro, indicado bloqueo con caracter.
  end # fin de la funcion lockear_sistema


  def hay_que_validar
    #utilizar registro para verificar expiracion y vencimiento ok ted.
     t = Tipomaquinat.first # apunto al primer registro
     
     if( (Time.now.to_date + 15.days) > t.created_at.to_date ) && ( not t.descripcion.include?("atraso") ) && ( not t.descripcion.include?("HW") ) && ( not t.descripcion.include?("administrativamente") )  # Hay que validar (online u offline) siempre y cuando no este lockeada por atraso de hora ni cambio de HW ok ted.
       true # hay que validar  
     else
       false # todavia no hay que validar
     end
    
  end # fin de la funcion hay_que_validar


  
  def licencia_vencida
     t = Tipomaquinat.first # apunto al primer registro
     
     if( (Time.now.to_date ) > t.created_at.to_date ) # puedo usar esta misma referencia: fecha vencimiento = 15 dias despues de la de expiracion, la ventana de actualizar expiracion no va a apermitier que llegue aqui si se mantiene actualizando online ok. ok ted.
       true # licencia vencida
     else
       false # todavia no. ok.
     end
    
  end # fin de la funcion licencia_vencida


  def activar_producto(dias_activos)

    #limpiar el bloqueo del lackqueo
    #activar producto por extension de dias activos.
    
    #desbloqueo y de una vez (usabdo el mismo objeto), extension del producto, activarlo ok.:
    t = Tipomaquinat.first # apunto al primer registro
    t.descripcion =  "" + "razon: all ok"  # desactivado
    t.created_at = Time.now.to_date + dias_activos.to_i.days # producto extendido ok.
    t.save #modifico registro, activar_producto ok.

  end # fin de la funcion activar_producto




 def generacion_codigos_actualizacion_offline


      a = rand(1..100)
      b = rand(50..100)
      c = rand(1..40)
      d = rand(1..100)
      e = rand(1..100)
      f = rand(10..100)
      g = rand(50..100)
      h = rand(1..100)

      valorfx1_offline = (3 * (5 + c + (b-c)) + 2 * a) + (d + 4 + e * 4 * f ) - g + (g + 3 * h) # esta funcion debe estar en el svr para evaluar y comparar lo que llego de peticion ok ted.
      contador_registros_offline = Transaccionest.all.count # obetner el total de transacciones realizadas de este pos, esto a modo de contador para licencia ok. ted.
     
      valorfx2_offline = (4 * (6 + d + (b-a)) + 2 * c) + (b - 8 + a + 10 + b ) + (d + 1 + e * 2 * f ) - 3 * g + (g + 3 * h)  # con esta descodificaremos respuesta del svr
     
     # La idea es mostrar el activation code y guardar las variables en un registro, cuando el user inserte el activation code manual (previamente gereado en un generador or admin web portal), validar con las variables del registro y activar.
     # Llevar tambien un registro contador de fallos, 5 fallos manual y lockeado(razon, brutal force, 5 manual activation codes invalid)


      #guardar variables:
      registro_improvisado = Tipomaquinat.last #Debe de ser la segunda al menos, esto para que no colisione con la first. Ojo manually set it up already in production. ok.
      codigo_validacion_offline = "#{SW_ID_POS}-#{a}-#{b}-#{c}-#{d}-#{e}-#{f}-#{g}-#{h}-#{contador_registros_offline}-#{valorfx1_offline}-#{c.to_i * rand(2..6)}" # #{c}-#{d} de relleno al final ok.
      registro_improvisado.descripcion = codigo_validacion_offline.to_s # "#{a}-#{b}-#{c}-#{d}|#{codigo_validacion_offline}"
      registro_improvisado.save


 end # fin de la funcion generacion_codigos_actualizacion_offline




end #fin de la Clase 



#Error: This POS is Not authorized, please contact support to activate it. That's a simple solution.!

# curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"temperature":0, "humidity":0}' http://localhost:3000/measures 