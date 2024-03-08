class ReportetsController < ApplicationController
  #http_basic_authenticate_with name: "ventas", password: "456456", except: [:index, :autoreportet]
 # before_action :hacer_login, except: [:index] # 

  before_action :set_reportet, only: [:show, :edit, :update, :destroy]

  # GET /reportets
  # GET /reportets.json
  def index

    @flag_auto =  false # defino y seteo en false default, flag de control que me permite hacer reportees de cualquier mes del anio ok.
    #verificar si llega algun param en index, en este caso para saber si es un auto report de un mes completo cualquiera del anio:
   

    if ( (not params.permit(:auto_month).values[0].nil?) && (not params.permit(:auto_year).values[0].nil?) )
      
      @auto_month = params.permit(:auto_month).values[0].to_s 
      @auto_year  = params.permit(:auto_year).values[0].to_s  # ojo cuidar que sean de 4 digitos, ej. 2020, 1998, etc..
      
      if ( ( @auto_year.to_i  < (Time.now.year - 3) ) || ( @auto_year.to_i > (Time.now.year)  ) )
        @auto_year = Time.now.year # esto para que autoreporte sean del anio actual si tratan de consultar fuera del rango de 3 anios ok ted.
      end

      @my = [1,2,3,4,5,6,7,8,9,10,11,12] # 12 months number of the year
      
      if  @my.include?(@auto_month.to_i) # Si el arreglo de meses del anio incluye ese numero de mes conditio ok ted.
         @flag_auto =  true # este flag activado me permite consultar cualquier mes del anio para el autoreporte excell ok debajo ok.
         #@reportets = Reportet.all

         #verificar si el mes es de 30,31,  28 o visiestro 29 con esta simple funcion:  days = Time.days_in_month(m, y), pasar el mes y el anio. ok sacado de  link: https://stackoverflow.com/questions/1489826/how-to-get-the-number-of-days-in-a-given-month-in-ruby-accounting-for-year
         @total_dias_de_ese_mes = Time.days_in_month(@auto_month.to_i , @auto_year.to_i) # days = Time.days_in_month(m, y)

         session[:fecha_venta_dia_1] = {"desde(3i)"=>"1", "desde(2i)"=>  @auto_month.to_s, "desde(1i)"=> @auto_year.to_i.to_s } # Time.now.year.to_s Significa del anio actual ok.
         session[:fecha_venta_dia_2] = {"hasta(3i)"=> @total_dias_de_ese_mes.to_s, "hasta(2i)"=> @auto_month.to_s, "hasta(1i)"=> @auto_year.to_i.to_s }
      end

    end



    
    @day1 = session[:fecha_venta_dia_1]
    @day2 = session[:fecha_venta_dia_2]

 # @primero = ganadores.primero < 10 ? ("0" + ganadores.primero.to_s) : ganadores.primero.to_s
    session[:fecha_venta_dia_1].values[2] = session[:fecha_venta_dia_1].values[2].to_i < 10 ? (session[:fecha_venta_dia_1].values[2] = "0" + session[:fecha_venta_dia_1].values[2] ) : (session[:fecha_venta_dia_1].values[2])
    session[:fecha_venta_dia_2].values[2] = session[:fecha_venta_dia_2].values[2].to_i < 10 ? (session[:fecha_venta_dia_2].values[2] = "0" + session[:fecha_venta_dia_2].values[2] ) : (session[:fecha_venta_dia_2].values[2])

    @dia1 = session[:fecha_venta_dia_1].values.reverse.join("-") # hash.values retorna array. para la consulta de by_day(fehca en ingles yyyy-mm-dd)    
    @dia2 = session[:fecha_venta_dia_2].values.reverse.join("-")

    # lo sigeuinte es para evitar que el 31-10-2018 sea mayor que el 01-11-2018 en la comparacion de fecha.to_i (agregar 0 deciumal que falta en noviembre)
    #@dia1 => "2018-10-31" 
    @day = @dia2.split("-")[2].to_i < 10 ? "0"+@dia2.split("-")[2] : @dia2.split("-")[2]
    ymd = @dia2.split("-")
    ymd[2] = @day
    @dia2 = ymd.join("-")

    # Lo mismo pada dia1 porque tambien tiene el mismo error. 5 => 05 ok.
    @day = @dia1.split("-")[2].to_i < 10 ? "0"+@dia1.split("-")[2] : @dia1.split("-")[2]
    ymd = @dia1.split("-")
    ymd[2] = @day
    @dia1 = ymd.join("-")


    if @dia1.split("-").join("").to_i > @dia2.split("-").join("").to_i
       redirect_to "/reportets/new", notice: "Fecha final debe se mayor a la fecha de inicio." and return
    end

    y, m, d = @dia2.to_s.split("-")

    if not (Date.valid_date? y.to_i, m.to_i, d.to_i) # sacado de link: https://stackoverflow.com/questions/2955830/how-to-check-if-a-string-is-a-valid-date
      redirect_to "/reportets/new", notice: "Debe elegir una fecha final valida. Ej. favor verifiicar si el mes es de 30 o 31 dias." and return
    end

    y, m, d = @dia1.to_s.split("-")
    
    if not (Date.valid_date? y.to_i, m.to_i, d.to_i) # sacado de link: https://stackoverflow.com/questions/2955830/how-to-check-if-a-string-is-a-valid-date
      redirect_to "/reportets/new", notice: "Debe elegir una fecha de inicio valida. Ej. favor verifiicar si el mes es de 30 o 31 dias." and return
    end

   # @dia2 = @dia2.to_date.tomorrow # OJO YA NO ES NECESARIO ESTO. OK. SI VAS A USAR BETWEEN TIMES EN LA GEMA BY_DAY, YA QUE ELLA SOLA AUTOMATICAMENTE ELIGE EL RANGO FINAL DEL DIA, EJ. SI ES EL DIA (1RO DE OCTUBRE) 2019-10-01   BETWENN HARA EL OFFSET DEL SEGUND DIA AUTOMATICO, ENTONCES SE DEBE DE PONER ASI Modelo.beetween_times("2019-10-01".to_date, "2019-10-01".to_date ) => del 01 ocubre a las 00:00:00 horas( + GMT si esta configurado Time Zone en rails, en nuestro caso si 4 horas, hasta el mismo 01 oct a las 23:59:59 + el GMT) ok ted. probar en Rails c


    @dia1 = @dia1.to_date

    #@valor es ventas
    #Defino @objeto_array_ventas para no hacer dos consultas al ActiveRecord de @valor (sum) y de @cantidad_de_tickets_vendidos (count) ok ted.
  #  @objeto_array_ventas = Jugadalot.between_times(@dia1.to_date , @dia2 ).where(:ticket_id => Ticket.between_times(@dia1.to_date , @dia2 ).where(:user_id => current_user.id , :activo => "si").ids )
   
   # @valor = @objeto_array_ventas.sum(:monto) 
   # @cantidad_de_tickets_vendidos = @objeto_array_ventas.count



  
  #  @ganadores_cuadre = Ticketsganadorest.between_times(@dia1.to_date , @dia2).where(:sucursal => current_user.email.split('@')[0]).sum(:montoacobrar)

    #Tickets pendientes de pago son Todos los tickets ganadores de ese rango de fecha no pagados.sumatoria
  #  @cantidad_de_tickets_pendiente_de_pago = Ticketsganadorest.between_times(@dia1.to_date , @dia2 ).where(:ticket_id => Ticket.between_times(@dia1.to_date , @dia2 ).where(:user_id => current_user.id , :activo => "si", :ganador => "si", :pago => nil).ids).count

#loop para reporte resumido dia x dia like excell, (usaremos las mismas variables, solo haremos un loop con la logica de abajo. ok. ted. Esto para prueba generar reportes like nestor excell ok.)

@veces = (@day2.values.join("-").to_date - @day1.values.join("-").to_date ).to_i  # devuelve un muero racional que dividido da un numero entero correspondiente a la cantidad de dias de la resta realizada.

# @veces  contiene la cantidad de dias que hay entre el rango de fecha seleccionado. Esto para sacar el reporte diaxdia. ok.

#@veces.times do |dia|
#  @total_in =  Transaccionest.between_times(@dia1.to_date, @dia2 + dia.to_i).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
#  @total_out =  Postransaccionest.between_times(@dia1.to_date, @dia2).sum(:cantidad)
#
#  @total_net = @total_in.to_i - @total_out.to_i
#
#end


# Me insteresa limpiar la tabla de reportes rapidamente, uso delete en ves de destroy porque obvia el dependent destroy model relations. ojo usar con responsabilidad. ok. este modelo no tiene dependencia alga de otro. ok.
@limpiar_tabla_reporte = Reportetipoexcell.delete_all #  Returns the number of rows affected.  link: https://apidock.com/rails/ActiveRecord/Base/delete_all/class

# COMENTADO PARA AUMENTAR DE 1 DIA A 186 DIAS LAS CONSULTA DE REPORTES USUARIO VENTAS OK.
# ===========  
  # Evitar que hagan consultas pasadas con uno o dos dias de diferencia ej. del 01/10/2019 al 02/10/2019, y no podran si no es admin, porque Date.today lo tomo como referencia asi ok: ( (Date.today - @day1.values.join("-").to_date) > 1 ) 
   # if (  ( (@veces > 1) || ( (Date.today - @day1.values.join("-").to_date) > 1 )  )  && ( session[:reporte].to_s != "supervisor_ok") && (session[:reporte].to_s != "admin_ok") )
   #      redirect_to "/transaccionests/new", notice: "Puedes consultar ventas del dia actual y del anterior, para otro tipo de reportes favor contactar a su supervisor." and return  
   # end
# ===========  

# Evitar que hagan consultas pasadas con mas de un mes (186 dias maximos). Especial fix de solo dos dias a 186 dias ok. ted.
#nota:modificaremos esto a 6 mese ok ted. Esto porque ene cada cambio de mas duran hasta 15 dias tirando reporte de mes anterior de la ultima semana del cierre ok ted.
# 31 dia x 6 mese =  186 dias aprox ok ted.
#MODIFICADO TODO A 186 DIAS QUE SON 6 MESES APROX OK TED
if ( (  ( (@veces > 186) || ( (Date.today - @day1.values.join("-").to_date) > 186 )  )  && ( session[:reporte].to_s != "supervisor_ok") && (session[:reporte].to_s != "admin_ok") ) && ( @flag_auto == false) ) # Esto lo filtro con el boolena flag de control flag_auto para que si el reporte es auto poder sacar un mes completo cualquiera del anio para reporte excell remotos ok.
      redirect_to "/transaccionests/new", notice: "Puedes consultar ventas del dia actual y hasta un mes, para otro tipo de reporte favor contactar a su supervisor." and return  

end


#seccion multiusuario y determinar si el usuario que pide la consulta es de ventas, reportes o admin level ok ted:

#SI EL TIPOUSUARIO ES ADMIN O REPROTES HACE LA CONSUTLA GLOBAL DE TODAS LAS TRANSASCIONES: 
  tipo_usuario_consultador = Usuariosbrt.where(:usuario => session[:usuario_actual]).last.tipousuario #
  
  #LA LOGIGA ES QUE SI ES AMDIN O REPORTE SE GENERA EL RERPORTE SEGUN EL FILTRO RECIBIDO, SI EL FILTRO ESTA MAL, HACER UN NOTICE ERROR, Y SI NO ES ADMIN O REPORTE SE GENERA UNO SIMPLE DE LA SUCURSAL DE ESE USUARIO LOGEADO POSIBLIMENTE VENTASOK TED
  if (  (tipo_usuario_consultador == "admin") || (tipo_usuario_consultador == "reporte") )
  
      

      
        #verificar parametros para determinar cuales filtro aplicar en la consulta del reporte:
        @param_supervisor = session[:filtro_reporte_supervisor].to_s  #reportet_params[:supervisor] # Extraer el parametro.
        @param_sucursal = session[:filtro_reporte_sucursal].to_s        #reportet_params[:sucursal] # Extraer el parametro.
        @param_tipomaquina = session[:filtro_reporte_tipomaquina].to_s  # reportet_params[:tipomaquina] # Extraer el parametro.


        if (@param_supervisor.empty? && @param_sucursal.empty? && @param_tipomaquina.empty?)
              # Reporte filtro global ok:
              
              #puts "valoressssssssssssss reporte:   @param_supervisor >> " + @param_supervisor.to_s
              #puts "valoressssssssssssss reporte:   @param_sucursal >> " + @param_sucursal.to_s
              #puts "valoressssssssssssss reporte:   @param_tipomaquina >> " + @param_tipomaquina.to_s
              #puts "valoressssssssssssss reporte:   desde >> " + session[:fecha_venta_dia_1].to_s # reportet_params[:password].to_s


              (@veces + 1).times do |offset| # para incluir el ultimo dia en la consulta ej. 1-18 oct solo salen 17 dias, el 18avo dia se suma en el loop ara que lo corra al final ok ted.
              #Reciclo esta parte del codigo de abajo, esto solo para provecharlo y utilizar la logica para implementarla en el reporter anidado del reporte excell. ok. ted.
                #@total_in =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
                #@total_out =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).sum(:cantidad)
                
                #Suma Especial iterada para evitar el error por el postgres String.sum error en production ok ted.
                @total_in = @total_out = 0

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok", :supervisor => @param_supervisor)
                
                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
               #vamos a probar con el supervisor:
                transaccionest_ojb = Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                @total_in_especial = []

                @total_in_especial = transaccionest_ojb # LO ASIGNO TODOS, EL REPORTE ES GLOBAL OK TED.

                #SECCION DE FILTRO POR SUPERVISOR MAS DEBAJO, ELIMINADA DE AQUI PORUE NO ES NECESAIRA OK TED.
                

                
                postransaccionest_ojb = Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
                @total_out_especial = []
                
                @total_out_especial = postransaccionest_ojb # LO ASIGNO TODOS, EL REPORTE ES GLOBAL OK TED.

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
                


                @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

                @total_out_especial.each do |valor|
                  @total_out += valor.cantidad.to_i

                end


                @total_net = @total_in.to_i - @total_out.to_i

                @entrada_objeto = Reportetipoexcell.new
                @entrada_objeto.fecha = @dia1.to_date + offset
                @entrada_objeto.in = @total_in
                @entrada_objeto.out = @total_out
                @entrada_objeto.net = @total_net
                @entrada_objeto.save

              end

              @veces +=1 # esto para ell viwe solamente del counter 0..veces ok ted. no altera el ciclo de arriba ok.

              @reporte_tipo_excell = Reportetipoexcell.all # Seleccion todos los valores dia x dia del reporte tipo excell. Esto para ser mostrado en la vista.




              #@total_in =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@total_out =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date)).sum(:cantidad)

              #Suma Especial otra vez ok, iterada para evitar el error por el postgres String.sum error en production ok ted.
              #@total_in_especial =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))

              @total_in = @total_out = 0



              #vamos a probar con el supervisor:
              transaccionest_ojb = Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              @total_in_especial = []

              @total_in_especial = transaccionest_ojb # LO ASIGNO TODOS EL RERPOTE ES GLOBAL OK TED.



                
              postransaccionest_ojb =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))
              @total_out_especial = []
              @total_out_especial = postransaccionest_ojb 

              #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
             
              


              @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

              @total_out_especial.each do |valor|
                @total_out += valor.cantidad.to_i

              end


              @total_net = @total_in.to_i - @total_out.to_i

              @d1 = @dia1
              @d2 = @dia2

              @dia2 = @dia2.to_date # no borrar esto para setear formato de esta variable al tipo to_date para la logica de abajo en adelante y no tener que modificarla una a una debajo. ok. ted.

              
              #modificaciones provisionales para juntar el reporte detallado de ambas tablas Creditos/Debitos Modelos Transaccionest y Postransaccionest ted ok provisional work production ok v1.
              #@array_consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              #@array_consultas_postransacciones = Postransaccionest.between_times(@dia1.to_date, @dia2)

              #vamos a probar con el supervisor:
              array_consultas_transacciones_obj = Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              @array_consultas_transacciones = []
              @array_consultas_transacciones = array_consultas_transacciones_obj # LO ASIGNO TODOS, EL REPORTE ES GLOBAL.

              #vamos a probar con el supervisor:
              array_consultas_postransacciones_obj = Postransaccionest.between_times(@dia1.to_date, @dia2)

              @array_consultas_postransacciones = []
              array_consultas_postransacciones = array_consultas_postransacciones_obj # LO ASIGNO TODOS, EL REPORTE ES GLOBAL.


              session[:tipo_reporte] = "Global"

              @ids_maquinas_activas = Maquinat.where(:activa => "si" ).ids
              session[:fecha_venta_detalladaxmaquina_dia_1] = @dia1.to_date # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              session[:fecha_venta_detalladaxmaquina_dia_2] =  @dia2        # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              #@detallada_in = Transaccionest.between_times(@dia1.to_date, @dia2).where(:maquinat_id => 77 ,  :tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@venta_detallada_por_maquina = Maquinat.where(:activa => "si").ids
              #etc..

              #IMPORTANTE ESTA PARTE DE ABAJO EN LA VISTA TED OK KOLLECTOR FUSION PROJECT OK.

              @dia1 = session[:fecha_venta_dia_1].values.join("-") # para el show dd-mm-aaaa
              @dia2 = session[:fecha_venta_dia_2].values.join("-") # para el show dd-mm-aaaa
       
              session[:fecha_venta_dia_1] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              session[:fecha_venta_dia_2] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              # Gererar cadena de impresion de este cuadre para version impresion movil:    
                                 
          
        elsif ( ( not @param_supervisor.empty?) && (@param_sucursal.empty?) && (@param_tipomaquina.empty?) )
              # Filtro x supervisor:
              

              (@veces + 1).times do |offset| # para incluir el ultimo dia en la consulta ej. 1-18 oct solo salen 17 dias, el 18avo dia se suma en el loop ara que lo corra al final ok ted.
              #Reciclo esta parte del codigo de abajo, esto solo para provecharlo y utilizar la logica para implementarla en el reporter anidado del reporte excell. ok. ted.
                #@total_in =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
                #@total_out =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).sum(:cantidad)
                
                #Suma Especial iterada para evitar el error por el postgres String.sum error en production ok ted.
                @total_in = @total_out = 0

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok", :supervisor => @param_supervisor)
                
                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
               #vamos a probar con el supervisor:
                transaccionest_ojb = Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                @total_in_especial = []
# nene up
                if transaccionest_ojb
                  transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.supervisor == @param_supervisor.to_s
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                  end
                  
                end

                
                postransaccionest_ojb = Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
                @total_out_especial = []

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
                if postransaccionest_ojb

                    postransaccionest_ojb.each do |postransaccion|
                       m = Maquinat.where(:serial => postransaccion.serial).last

                       if m.supervisor == @param_supervisor.to_s 
                         @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                       end

                    end
                  
                end



                @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

                @total_out_especial.each do |valor|
                  @total_out += valor.cantidad.to_i

                end


                @total_net = @total_in.to_i - @total_out.to_i

                @entrada_objeto = Reportetipoexcell.new
                @entrada_objeto.fecha = @dia1.to_date + offset
                @entrada_objeto.in = @total_in
                @entrada_objeto.out = @total_out
                @entrada_objeto.net = @total_net
                @entrada_objeto.save

              end

              @veces +=1 # esto para ell viwe solamente del counter 0..veces ok ted. no altera el ciclo de arriba ok.

              @reporte_tipo_excell = Reportetipoexcell.all # Seleccion todos los valores dia x dia del reporte tipo excell. Esto para ser mostrado en la vista.




              #@total_in =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@total_out =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date)).sum(:cantidad)

              #Suma Especial otra vez ok, iterada para evitar el error por el postgres String.sum error en production ok ted.
              #@total_in_especial =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))

              @total_in = @total_out = 0



              #vamos a probar con el supervisor:
              transaccionest_ojb = Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              @total_in_especial = []

              if transaccionest_ojb
                transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.supervisor == @param_supervisor.to_s
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

                
              postransaccionest_ojb =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))
              @total_out_especial = []

              #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
             
              if postransaccionest_ojb
                
                  postransaccionest_ojb.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last

                     if m.supervisor == @param_supervisor.to_s 
                       @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end

                  end
                
              end



              @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

              @total_out_especial.each do |valor|
                @total_out += valor.cantidad.to_i

              end


              @total_net = @total_in.to_i - @total_out.to_i

              @d1 = @dia1
              @d2 = @dia2

              @dia2 = @dia2.to_date # no borrar esto para setear formato de esta variable al tipo to_date para la logica de abajo en adelante y no tener que modificarla una a una debajo. ok. ted.

              
              #modificaciones provisionales para juntar el reporte detallado de ambas tablas Creditos/Debitos Modelos Transaccionest y Postransaccionest ted ok provisional work production ok v1.
              #@array_consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              #@array_consultas_postransacciones = Postransaccionest.between_times(@dia1.to_date, @dia2)

              #vamos a probar con el supervisor:
              array_consultas_transacciones_obj = Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              @array_consultas_transacciones = []

              if array_consultas_transacciones_obj
                array_consultas_transacciones_obj.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.supervisor == @param_supervisor.to_s
                    @array_consultas_transacciones << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

              #vamos a probar con el supervisor:
              array_consultas_postransacciones_obj = Postransaccionest.between_times(@dia1.to_date, @dia2)

              @array_consultas_postransacciones = []

              if array_consultas_postransacciones_obj
                array_consultas_postransacciones_obj.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last
                     if m.supervisor == @param_supervisor.to_s 
                       @array_consultas_postransacciones << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end
                end
                
              end

              session[:tipo_reporte] = "Superv: " + @param_supervisor.to_s 

              @ids_maquinas_activas = Maquinat.where(:activa => "si", :supervisor => @param_supervisor.to_s ).ids
              session[:fecha_venta_detalladaxmaquina_dia_1] = @dia1.to_date # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              session[:fecha_venta_detalladaxmaquina_dia_2] =  @dia2        # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              #@detallada_in = Transaccionest.between_times(@dia1.to_date, @dia2).where(:maquinat_id => 77 ,  :tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@venta_detallada_por_maquina = Maquinat.where(:activa => "si").ids
              #etc..

              #IMPORTANTE ESTA PARTE DE ABAJO EN LA VISTA TED OK KOLLECTOR FUSION PROJECT OK.

              @dia1 = session[:fecha_venta_dia_1].values.join("-") # para el show dd-mm-aaaa
              @dia2 = session[:fecha_venta_dia_2].values.join("-") # para el show dd-mm-aaaa
       
              session[:fecha_venta_dia_1] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              session[:fecha_venta_dia_2] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              # Gererar cadena de impresion de este cuadre para version impresion movil: 



        elsif ( (@param_supervisor.empty?) && ( not @param_sucursal.empty?) && (@param_tipomaquina.empty?) )
              # Filtro x sucursal:
              

              (@veces + 1).times do |offset| # para incluir el ultimo dia en la consulta ej. 1-18 oct solo salen 17 dias, el 18avo dia se suma en el loop ara que lo corra al final ok ted.
              #Reciclo esta parte del codigo de abajo, esto solo para provecharlo y utilizar la logica para implementarla en el reporter anidado del reporte excell. ok. ted.
                #@total_in =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
                #@total_out =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).sum(:cantidad)
                
                #Suma Especial iterada para evitar el error por el postgres String.sum error en production ok ted.
                @total_in = @total_out = 0

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok", :supervisor => @param_supervisor)
                
                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
               #vamos a probar con el supervisor:
                transaccionest_ojb = Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                @total_in_especial = []

                if transaccionest_ojb
                  transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.sucursal == @param_sucursal.to_s
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                  end
                  
                end

                
                postransaccionest_ojb = Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
                @total_out_especial = []

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
                if postransaccionest_ojb

                    postransaccionest_ojb.each do |postransaccion|
                       m = Maquinat.where(:serial => postransaccion.serial).last

                       if m.sucursal == @param_sucursal.to_s 
                         @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                       end

                    end
                  
                end



                @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

                @total_out_especial.each do |valor|
                  @total_out += valor.cantidad.to_i

                end


                @total_net = @total_in.to_i - @total_out.to_i

                @entrada_objeto = Reportetipoexcell.new
                @entrada_objeto.fecha = @dia1.to_date + offset
                @entrada_objeto.in = @total_in
                @entrada_objeto.out = @total_out
                @entrada_objeto.net = @total_net
                @entrada_objeto.save

              end

              @veces +=1 # esto para ell viwe solamente del counter 0..veces ok ted. no altera el ciclo de arriba ok.

              @reporte_tipo_excell = Reportetipoexcell.all # Seleccion todos los valores dia x dia del reporte tipo excell. Esto para ser mostrado en la vista.




              #@total_in =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@total_out =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date)).sum(:cantidad)

              #Suma Especial otra vez ok, iterada para evitar el error por el postgres String.sum error en production ok ted.
              #@total_in_especial =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))

              @total_in = @total_out = 0



              #vamos a probar con el supervisor:
              transaccionest_ojb = Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              @total_in_especial = []

              if transaccionest_ojb
                transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.sucursal == @param_sucursal.to_s
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

                
              postransaccionest_ojb =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))
              @total_out_especial = []

              #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
             
              if postransaccionest_ojb
                
                  postransaccionest_ojb.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last

                     if m.sucursal == @param_sucursal.to_s 
                       @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end

                  end
                
              end



              @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

              @total_out_especial.each do |valor|
                @total_out += valor.cantidad.to_i

              end


              @total_net = @total_in.to_i - @total_out.to_i

              @d1 = @dia1
              @d2 = @dia2

              @dia2 = @dia2.to_date # no borrar esto para setear formato de esta variable al tipo to_date para la logica de abajo en adelante y no tener que modificarla una a una debajo. ok. ted.

              
              #modificaciones provisionales para juntar el reporte detallado de ambas tablas Creditos/Debitos Modelos Transaccionest y Postransaccionest ted ok provisional work production ok v1.
              #@array_consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              #@array_consultas_postransacciones = Postransaccionest.between_times(@dia1.to_date, @dia2)

              #vamos a probar con el supervisor:
              array_consultas_transacciones_obj = Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              @array_consultas_transacciones = []

              if array_consultas_transacciones_obj
                array_consultas_transacciones_obj.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.sucursal == @param_sucursal.to_s
                    @array_consultas_transacciones << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

              #vamos a probar con el supervisor:
              array_consultas_postransacciones_obj = Postransaccionest.between_times(@dia1.to_date, @dia2)

              @array_consultas_postransacciones = []

              if array_consultas_postransacciones_obj
                array_consultas_postransacciones_obj.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last
                     if m.sucursal == @param_sucursal.to_s 
                       @array_consultas_postransacciones << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end
                end
                
              end

              session[:tipo_reporte] = "Suc: " + @param_sucursal.to_s
      

              @ids_maquinas_activas = Maquinat.where(:activa => "si", :sucursal => @param_sucursal.to_s ).ids
              session[:fecha_venta_detalladaxmaquina_dia_1] = @dia1.to_date # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              session[:fecha_venta_detalladaxmaquina_dia_2] =  @dia2        # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              #@detallada_in = Transaccionest.between_times(@dia1.to_date, @dia2).where(:maquinat_id => 77 ,  :tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@venta_detallada_por_maquina = Maquinat.where(:activa => "si").ids
              #etc..

              #IMPORTANTE ESTA PARTE DE ABAJO EN LA VISTA TED OK KOLLECTOR FUSION PROJECT OK.

              @dia1 = session[:fecha_venta_dia_1].values.join("-") # para el show dd-mm-aaaa
              @dia2 = session[:fecha_venta_dia_2].values.join("-") # para el show dd-mm-aaaa
       
              session[:fecha_venta_dia_1] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              session[:fecha_venta_dia_2] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              # Gererar cadena de impresion de este cuadre para version impresion movil:    
   





        elsif ( (@param_supervisor.empty?) && ( @param_sucursal.empty?) && ( not @param_tipomaquina.empty?) )
              # Filtro x TipoMaquina:
              

              (@veces + 1).times do |offset| # para incluir el ultimo dia en la consulta ej. 1-18 oct solo salen 17 dias, el 18avo dia se suma en el loop ara que lo corra al final ok ted.
              #Reciclo esta parte del codigo de abajo, esto solo para provecharlo y utilizar la logica para implementarla en el reporter anidado del reporte excell. ok. ted.
                #@total_in =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
                #@total_out =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).sum(:cantidad)
                
                #Suma Especial iterada para evitar el error por el postgres String.sum error en production ok ted.
                @total_in = @total_out = 0

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok", :supervisor => @param_supervisor)
                
                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
               #vamos a probar con el supervisor:
                transaccionest_ojb = Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                @total_in_especial = []

                if transaccionest_ojb
                  transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.tipomaquinat.tipomaquina == @param_tipomaquina.to_s
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                  end
                  
                end

                
                postransaccionest_ojb = Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
                @total_out_especial = []

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
                if postransaccionest_ojb

                    postransaccionest_ojb.each do |postransaccion|
                       m = Maquinat.where(:serial => postransaccion.serial).last

                       if m.tipomaquinat.tipomaquina == @param_tipomaquina.to_s 
                         @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                       end

                    end
                  
                end



                @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

                @total_out_especial.each do |valor|
                  @total_out += valor.cantidad.to_i

                end


                @total_net = @total_in.to_i - @total_out.to_i

                @entrada_objeto = Reportetipoexcell.new
                @entrada_objeto.fecha = @dia1.to_date + offset
                @entrada_objeto.in = @total_in
                @entrada_objeto.out = @total_out
                @entrada_objeto.net = @total_net
                @entrada_objeto.save

              end

              @veces +=1 # esto para ell viwe solamente del counter 0..veces ok ted. no altera el ciclo de arriba ok.

              @reporte_tipo_excell = Reportetipoexcell.all # Seleccion todos los valores dia x dia del reporte tipo excell. Esto para ser mostrado en la vista.




              #@total_in =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@total_out =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date)).sum(:cantidad)

              #Suma Especial otra vez ok, iterada para evitar el error por el postgres String.sum error en production ok ted.
              #@total_in_especial =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))

              @total_in = @total_out = 0



              #vamos a probar con el supervisor:
              transaccionest_ojb = Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              @total_in_especial = []

              if transaccionest_ojb
                transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.tipomaquinat.tipomaquina == @param_tipomaquina.to_s
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

                
              postransaccionest_ojb =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))
              @total_out_especial = []

              #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
             
              if postransaccionest_ojb
                
                  postransaccionest_ojb.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last

                     if m.tipomaquinat.tipomaquina == @param_tipomaquina.to_s 
                       @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end

                  end
                
              end



              @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

              @total_out_especial.each do |valor|
                @total_out += valor.cantidad.to_i

              end


              @total_net = @total_in.to_i - @total_out.to_i

              @d1 = @dia1
              @d2 = @dia2

              @dia2 = @dia2.to_date # no borrar esto para setear formato de esta variable al tipo to_date para la logica de abajo en adelante y no tener que modificarla una a una debajo. ok. ted.

              
              #modificaciones provisionales para juntar el reporte detallado de ambas tablas Creditos/Debitos Modelos Transaccionest y Postransaccionest ted ok provisional work production ok v1.
              #@array_consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              #@array_consultas_postransacciones = Postransaccionest.between_times(@dia1.to_date, @dia2)

              #vamos a probar con el supervisor:
              array_consultas_transacciones_obj = Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              @array_consultas_transacciones = []

              if array_consultas_transacciones_obj
                array_consultas_transacciones_obj.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.tipomaquinat.tipomaquina == @param_tipomaquina.to_s
                    @array_consultas_transacciones << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

              #vamos a probar con el supervisor:
              array_consultas_postransacciones_obj = Postransaccionest.between_times(@dia1.to_date, @dia2)

              @array_consultas_postransacciones = []

              if array_consultas_postransacciones_obj
                array_consultas_postransacciones_obj.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last
                     if m.tipomaquinat.tipomaquina == @param_tipomaquina.to_s 
                       @array_consultas_postransacciones << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end
                end
                
              end

              session[:tipo_reporte] = "TipoMaq: " + @param_tipomaquina.to_s

              #Encontar el id de ese tipo de maquina en Tipomaquinat model para hacer el filtro en el ForeingKey de Maquinat ok ted:
              tipo_maquina_id = Tipomaquinat.where(:tipomaquina => @param_tipomaquina.to_s) || nil 

              @ids_maquinas_activas = Maquinat.where(:activa => "si", :tipomaquinat => tipo_maquina_id ).ids
              session[:fecha_venta_detalladaxmaquina_dia_1] = @dia1.to_date # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              session[:fecha_venta_detalladaxmaquina_dia_2] =  @dia2        # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              #@detallada_in = Transaccionest.between_times(@dia1.to_date, @dia2).where(:maquinat_id => 77 ,  :tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@venta_detallada_por_maquina = Maquinat.where(:activa => "si").ids
              #etc..

              #IMPORTANTE ESTA PARTE DE ABAJO EN LA VISTA TED OK KOLLECTOR FUSION PROJECT OK.

              @dia1 = session[:fecha_venta_dia_1].values.join("-") # para el show dd-mm-aaaa
              @dia2 = session[:fecha_venta_dia_2].values.join("-") # para el show dd-mm-aaaa
       
              session[:fecha_venta_dia_1] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              session[:fecha_venta_dia_2] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              # Gererar cadena de impresion de este cuadre para version impresion movil:    
   



#nene down
        elsif ( ( not @param_supervisor.empty?) && ( @param_sucursal.empty?) && ( not @param_tipomaquina.empty?) )
              # Filtro x Supervisor x TipoMaquina:
              

              (@veces + 1).times do |offset| # para incluir el ultimo dia en la consulta ej. 1-18 oct solo salen 17 dias, el 18avo dia se suma en el loop ara que lo corra al final ok ted.
              #Reciclo esta parte del codigo de abajo, esto solo para provecharlo y utilizar la logica para implementarla en el reporter anidado del reporte excell. ok. ted.
                #@total_in =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
                #@total_out =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).sum(:cantidad)
                
                #Suma Especial iterada para evitar el error por el postgres String.sum error en production ok ted.
                @total_in = @total_out = 0

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok", :supervisor => @param_supervisor)
                
                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
               #vamos a probar con el supervisor:
                transaccionest_ojb = Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                @total_in_especial = []


                if transaccionest_ojb
                  transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if ( (transaccion.maquinat.tipomaquinat.tipomaquina == @param_tipomaquina.to_s) && ( transaccion.maquinat.supervisor == @param_supervisor.to_s ) )
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                  end
                  
                end

                
                postransaccionest_ojb = Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
                @total_out_especial = []

                #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
                #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
               
                if postransaccionest_ojb

                    postransaccionest_ojb.each do |postransaccion|
                       m = Maquinat.where(:serial => postransaccion.serial).last

                       if ((m.tipomaquinat.tipomaquina == @param_tipomaquina.to_s ) && (m.supervisor == @param_supervisor.to_s) )
                         @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                       end

                    end
                  
                end



                @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

                @total_out_especial.each do |valor|
                  @total_out += valor.cantidad.to_i

                end


                @total_net = @total_in.to_i - @total_out.to_i

                @entrada_objeto = Reportetipoexcell.new
                @entrada_objeto.fecha = @dia1.to_date + offset
                @entrada_objeto.in = @total_in
                @entrada_objeto.out = @total_out
                @entrada_objeto.net = @total_net
                @entrada_objeto.save

              end

              @veces +=1 # esto para ell viwe solamente del counter 0..veces ok ted. no altera el ciclo de arriba ok.

              @reporte_tipo_excell = Reportetipoexcell.all # Seleccion todos los valores dia x dia del reporte tipo excell. Esto para ser mostrado en la vista.




              #@total_in =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@total_out =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date)).sum(:cantidad)

              #Suma Especial otra vez ok, iterada para evitar el error por el postgres String.sum error en production ok ted.
              #@total_in_especial =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))

              @total_in = @total_out = 0



              #vamos a probar con el supervisor:
              transaccionest_ojb = Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
              @total_in_especial = []

              if transaccionest_ojb
                transaccionest_ojb.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if ( (transaccion.maquinat.tipomaquinat.tipomaquina == @param_tipomaquina.to_s) && ( transaccion.maquinat.supervisor == @param_supervisor.to_s ) )
                    @total_in_especial << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

                
              postransaccionest_ojb =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))
              @total_out_especial = []

              #@total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
              #@total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
             
              if postransaccionest_ojb
                
                  postransaccionest_ojb.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last

                     if ((m.tipomaquinat.tipomaquina == @param_tipomaquina.to_s ) && (m.supervisor == @param_supervisor.to_s) )                    
                       @total_out_especial << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end

                  end
                
              end




              @total_in_especial.each do |valor|
                  @total_in += valor.cantidad.to_i

                end

              @total_out_especial.each do |valor|
                @total_out += valor.cantidad.to_i

              end


              @total_net = @total_in.to_i - @total_out.to_i

              @d1 = @dia1
              @d2 = @dia2

              @dia2 = @dia2.to_date # no borrar esto para setear formato de esta variable al tipo to_date para la logica de abajo en adelante y no tener que modificarla una a una debajo. ok. ted.

              
              #modificaciones provisionales para juntar el reporte detallado de ambas tablas Creditos/Debitos Modelos Transaccionest y Postransaccionest ted ok provisional work production ok v1.
              #@array_consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              #@array_consultas_postransacciones = Postransaccionest.between_times(@dia1.to_date, @dia2)

              #vamos a probar con el supervisor:
              array_consultas_transacciones_obj = Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )
              @array_consultas_transacciones = []

              if array_consultas_transacciones_obj
                array_consultas_transacciones_obj.each do |transaccion|
                  #buscar solo las que cumplen requisitos:
                  if transaccion.maquinat.tipomaquinat.tipomaquina == @param_tipomaquina.to_s
                    @array_consultas_transacciones << transaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                  end

                end
                
              end

              #vamos a probar con el supervisor:
              array_consultas_postransacciones_obj = Postransaccionest.between_times(@dia1.to_date, @dia2)

              @array_consultas_postransacciones = []

              if array_consultas_postransacciones_obj
                array_consultas_postransacciones_obj.each do |postransaccion|
                     m = Maquinat.where(:serial => postransaccion.serial).last
                     if ((m.tipomaquinat.tipomaquina == @param_tipomaquina.to_s ) && (m.supervisor == @param_supervisor.to_s) )                    
                       @array_consultas_postransacciones << postransaccion  # voy seleccionando los objetos o transacciones de las maquinas que pertenecen a esa sucursal
                     end
                end
                
              end


              session[:tipo_reporte] = "SupxTipoMq: " + @param_supervisor.to_s + "/" + @param_tipomaquina.to_s

              #Encontar el id de ese tipo de maquina en Tipomaquinat model para hacer el filtro en el ForeingKey de Maquinat ok ted:
              tipo_maquina_id = Tipomaquinat.where(:tipomaquina => @param_tipomaquina.to_s) || nil 

              @ids_maquinas_activas = Maquinat.where(:activa => "si", :tipomaquinat => tipo_maquina_id, :supervisor=> @param_supervisor.to_s ).ids
              session[:fecha_venta_detalladaxmaquina_dia_1] = @dia1.to_date # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              session[:fecha_venta_detalladaxmaquina_dia_2] =  @dia2        # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
              #@detallada_in = Transaccionest.between_times(@dia1.to_date, @dia2).where(:maquinat_id => 77 ,  :tipotransaccion => "credito", :status => "ok").sum(:cantidad)
              #@venta_detallada_por_maquina = Maquinat.where(:activa => "si").ids
              #etc..

              #IMPORTANTE ESTA PARTE DE ABAJO EN LA VISTA TED OK KOLLECTOR FUSION PROJECT OK.

              @dia1 = session[:fecha_venta_dia_1].values.join("-") # para el show dd-mm-aaaa
              @dia2 = session[:fecha_venta_dia_2].values.join("-") # para el show dd-mm-aaaa
       
              session[:fecha_venta_dia_1] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              session[:fecha_venta_dia_2] = nil # Limpio la variable para evitar cookie oversize en el cliente.
              # Gererar cadena de impresion de este cuadre para version impresion movil:    



        elsif 
          #si no cumple con el filtro seteado (global, supervisor, sucursal o tipomaquina soloamente ), render mensaje
          redirect_to "/reportets/new", notice: "X. Debes elegir una opcion valida para general el reporte. Favor verificar." and return    



        end
          


      
  


  else # este else es el bloque  de arriba que dice if (  (tipo_usuario_consultador == "admin") || (tipo_usuario_consultador == "reporte") )
    #es un usuario del tipo "ventas" u otra cosa menor nivel ok.
    #en esta seccion del bloque tipo_usuario_consultador puede ternet "ventas" u otra cosa vacia ok



      (@veces + 1).times do |offset| # para incluir el ultimo dia en la consulta ej. 1-18 oct solo salen 17 dias, el 18avo dia se suma en el loop ara que lo corra al final ok ted.
      #Reciclo esta parte del codigo de abajo, esto solo para provecharlo y utilizar la logica para implementarla en el reporter anidado del reporte excell. ok. ted.
        #@total_in =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
        #@total_out =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).sum(:cantidad)
        
        #Suma Especial iterada para evitar el error por el postgres String.sum error en production ok ted.
        @total_in = @total_out = 0

        @total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").where(:usuarioventa => session[:usuario_actual])
        @total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).where(:usuarioventa => session[:usuario_actual])
       
        @total_in_especial.each do |valor|
          @total_in += valor.cantidad.to_i

        end

        @total_out_especial.each do |valor|
          @total_out += valor.cantidad.to_i

        end


        @total_net = @total_in.to_i - @total_out.to_i

        @entrada_objeto = Reportetipoexcell.new
        @entrada_objeto.fecha = @dia1.to_date + offset
        @entrada_objeto.in = @total_in
        @entrada_objeto.out = @total_out
        @entrada_objeto.net = @total_net
        @entrada_objeto.save

      end

      @veces +=1 # esto para ell viwe solamente del counter 0..veces ok ted. no altera el ciclo de arriba ok.

      @reporte_tipo_excell = Reportetipoexcell.all # Seleccion todos los valores dia x dia del reporte tipo excell. Esto para ser mostrado en la vista.




      #@total_in =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
      #@total_out =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date)).sum(:cantidad)

      #Suma Especial otra vez ok, iterada para evitar el error por el postgres String.sum error en production ok ted.
      @total_in_especial =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok").where(:usuarioventa => session[:usuario_actual])
      @total_out_especial =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date)).where(:usuarioventa => session[:usuario_actual])

      @total_in = @total_out = 0


      @total_in_especial.each do |valor|
          @total_in += valor.cantidad.to_i

        end

      @total_out_especial.each do |valor|
        @total_out += valor.cantidad.to_i

      end




      @total_net = @total_in.to_i - @total_out.to_i

      @d1 = @dia1
      @d2 = @dia2

      @dia2 = @dia2.to_date # no borrar esto para setear formato de esta variable al tipo to_date para la logica de abajo en adelante y no tener que modificarla una a una debajo. ok. ted.

      # Transaccionest id: 44, 
      # maquinat_id: 1, 
      # tipotransaccion: "credito",
      #  cantidad: "100", 
      #  status: "ok", 
      #  created_at: "2019-07-26 06:06:11", 
      #  updated_at: "2019-07-26 06:06:17", 
      #  comando: "@cash100^">

      # arreglos de objetos para mostrar la tabal de transacciones en ese rango de fechas:

      # @consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where(:tipotransaccion => in ["credito", "debito"], :status => "ok").sum(:cantidad)

      #modificaciones provisionales para juntar el reporte detallado de ambas tablas Creditos/Debitos Modelos Transaccionest y Postransaccionest ted ok provisional work production ok v1.
      @array_consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" ).where(:usuarioventa => session[:usuario_actual])

      @array_consultas_postransacciones = Postransaccionest.between_times(@dia1.to_date, @dia2).where(:usuarioventa => session[:usuario_actual])


      @ids_maquinas_activas = Maquinat.where(:activa => "si").where(:usuarioventa => session[:usuario_actual]).ids
      session[:fecha_venta_detalladaxmaquina_dia_1] = @dia1.to_date # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
      session[:fecha_venta_detalladaxmaquina_dia_2] =  @dia2        # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
      #@detallada_in = Transaccionest.between_times(@dia1.to_date, @dia2).where(:maquinat_id => 77 ,  :tipotransaccion => "credito", :status => "ok").sum(:cantidad)
      #@venta_detallada_por_maquina = Maquinat.where(:activa => "si").ids
      #etc..


          #IMPORTANTE ESTA PARTE DE ABAJO EN LA VISTA TED OK KOLLECTOR FUSION PROJECT OK.

          @dia1 = session[:fecha_venta_dia_1].values.join("-") # para el show dd-mm-aaaa
          @dia2 = session[:fecha_venta_dia_2].values.join("-") # para el show dd-mm-aaaa

        
          session[:fecha_venta_dia_1] = nil # Limpio la variable para evitar cookie oversize en el cliente.
          session[:fecha_venta_dia_2] = nil # Limpio la variable para evitar cookie oversize en el cliente.
        








  end

#limpiar variables de sessiones de reportes  (la sesion tiene memoria y evitar cruces ok )

session[:filtro_reporte_supervisor]  = nil 
session[:filtro_reporte_sucursal]    = nil 
session[:filtro_reporte_tipomaquina] = nil 



end # fin del index




# GET /reportets/1
# GET /reportets/1.json
def show

end



  # GET /reportets/new
 def new
     # Comento esta parte para que pueda mostar la activacion manual en esta vista ok.
     # if verificar_violacion_simple
     #   render plain: 'Locked System. Contact support.' #
     # end
     @reportet = Reportet.new

     #seccion multiuser pdventa ok
     #vamos a verificar si es usuario de venta banca
     tipo_usuario_obj = Usuariosbrt.where(:usuario => session[:usuario_actual]).last 

     tipo_usuario = Usuariosbrt.where(:usuario => session[:usuario_actual]).last.tipousuario # "ventas", "reportes",  "admin"

     @reporte_sucursal_actual_only = false # flag para determinar si va a generarse un reporte de ventas solo para esa sucursal en la vista ok
     
     if tipo_usuario == "ventas"
       @reporte_sucursal_actual_only = true
       @sucursal_del_usuario = tipo_usuario_obj.usuario.to_s # por eso deben usuario y sucursal deben ser iguales porque en el Modelo User no tiene el atributo sucursal, sino usuario ok. tes y en la vista de reprotes la logica simbolza un reporte de sucursal de ese usuario ok
     end
   
     
     if hay_que_validar # Indica estamos dentro del periodo de los 15 dias para validar funcion que chequea la expiracion
       @mostrar_offline_activation_code = true # esto para la vista como aviso de que hay que update online u otro mensaje hidden visible. ok. ej. 'please update'
       
       #generar y  guardar las varibles dinamicas para la activacion manual con fx1. ok.
       generacion_codigos_actualizacion_offline()
       registro_improvisado = Tipomaquinat.last
       @offline_activation_code = registro_improvisado.descripcion.to_s

     else
       @mostrar_offline_activation_code = false # para que vuelva a su estado original en caso de que haya salido de una validacion reciente ok. ted.
     end



  end

  
  # GET /reportets/1/edit
  def edit
  end

  # POST /reportets
  # POST /reportets.json
  def create
     #session[:klk] = params.require(:reportet).permit(:password).values[0]
    @pwd_sup = params.require(:reportet).permit(:password).values[0].to_s


    #capturar parametros de la consulta y pasarlo a variable de session para usarlo en index, ya que este medoto create lo estamos redireccionando a index con la vista de los reprtes ok ted.
    
    #verificar parametros para determinar cuales filtro aplicar en la consulta del reporte:
    session[:filtro_reporte_supervisor] = reportet_params[:supervisor].to_s # Extraer el parametro.
    session[:filtro_reporte_sucursal] = reportet_params[:sucursal].to_s # Extraer el parametro.
    session[:filtro_reporte_tipomaquina] = reportet_params[:tipomaquina].to_s # Extraer el parametro.

    #continuar con la logica de este controlador ok..

    #verificar si se quiere generar un reporte detallado(detalles de envios y pagos en el reprote)
    #opcion defaul es no detallado:
    session[:reporte_detallado] = "no" # no detallado por defecto ok ted.

    if ( @pwd_sup.to_s == "detallado" ) #usuario solicita la vista del reporte detallado
      session[:reporte_detallado] = "si" # activacion flag para vista de reporte dellatado ok.
    end   




    if ( @pwd_sup.include?("kpos") && hay_que_validar ) # posible trama recibida: kpos-fx2-diasactivos-comentarios (666 si no es el valido)
      #Estamos dentro de la seccion de validacion manual.
      #Leer registro almacenado
      #sacar la info del param @pwd_sup y comparar con lo que tenemos
      #si si ok y desbloquear,
      #si no slepp(20) # delay para atrofiar un posible brutal force ok ted.
      registro_improvisado = Tipomaquinat.last
      valores_string = registro_improvisado.descripcion # 
      #SACO LAS VARIABLES, PROCESO LA FX2, SI CODIGO REICIBIO == FX2, PROCESO LO DEMAS
      a = valores_string.split("-")[4].to_i #[4] al [11]
      b = valores_string.split("-")[5].to_i
      c = valores_string.split("-")[6].to_i
      d = valores_string.split("-")[7].to_i
      e = valores_string.split("-")[8].to_i
      f = valores_string.split("-")[9].to_i
      g = valores_string.split("-")[10].to_i
      h = valores_string.split("-")[11].to_i
      #contador = valores_string.split("-")[12]
      #fx1 = valores_string.split("-")[13]


      valorfx2_offline = (4 * (6 + d + (b-a)) + 2 * c) + (b - 8 + a + 10 + b ) + (d + 1 + e * 2 * f ) - 3 * g + (g + 3 * h)  # con esta descodificaremos respuesta del svr
    
      if( valorfx2_offline.to_i == @pwd_sup.split("-")[1].to_i ) #verifico que fx2 == CRC recibido. (fue procesado en svr local con fx2 alla, ok ted.)
         #CRC ok, proceder.
         dias_activos =  @pwd_sup.split("-")[2].to_i
         comentarios =   @pwd_sup.split("-")[3] || ""
        
         if( dias_activos.to_i > 365  || dias_activos < 0)
           dias_activos = 30 # esto para evitar mas de un anio activado o un nuemro negativo, ok ted control.
         end
         activar_producto(dias_activos.to_i) 
         redirect_to root_path and return # lo activa y lo manda a la pagina principal, aqui ya no debe mostrarse update mensaje ok ted.

      else
         if (rand(1..50) == 25) # que le lockee definitivo si no funciona el pwd local y rand(1..50) == 50 se da ok.. Esto para dejarlo con un margen de que trate de nuevo local pero con la prob de lockearlo definitivo si falla y falla ok.
           lockear_sistema("Licencia no activada administrativamente: intento manual fallido " + comentarios.to_s[0..25]) # Razon por la que no se activo, respuesta desde el server. ej. "alteracion de contadores del pos, clonado?", administrativamente desactivado, etc.. [1..25 corta este comentario a un numero manejable from inet ok ted.]
           redirect_to root_path and return #
         end
         sleep(10) #hacerle una pausa de 20 seg delay antes de continuar ok ted.
      end
      redirect_to root_path and return #  
      
     end



      #seccion para ajuste manual de errores de pago.
      #kposfix$500@40 # ajuste de oy de 500, el @40 es porque se hace el dia 20 (20*x2 = 40)
      #kposfixayer$500@40 # ajuste de oy de 500, el @40 es porque se hace el dia 20 (20*x2 = 40)
      if ( @pwd_sup.include?("kposfix") ) # posible trama recibida: kposfix$500@40
        #vericiar clave interna comando ok:
        dia = Time.now.day 
        clave_interna = dia.to_i * 2.to_i

        codigo_externo = @pwd_sup.split("@")[1] # leer el codigo externo ok.

        if ( clave_interna.to_i == codigo_externo.to_i )
          #comando recibido para saber si el ajuste de de hoy(si hay pagos o el last) o de ayer usando .yesterday para asegurarme de ayer ok
          comando = @pwd_sup.split("$")[0].to_s # debe retornar algo como: kposfix o kposfixayer 
          #cantidad a rebajar
          cantidad = @pwd_sup.split("$")[1].to_s.split("@")[0] # kposfix$500@40 => 500
          
          p = Postransaccionest.last

          #verificar si el fix es ayer
          if comando.to_s == "kposfixayer"
            p = Postransaccionest.yesterday.last          
          end

          p.cantidad = (p.cantidad.to_i) + cantidad.to_i
          #VERIFICAR BIEN ANTES DE GUARDAR:
          
          confirmacion_ajuste_a = "kposfix" + "$" + cantidad.to_s + "@" + clave_interna.to_s
          confirmacion_ajuste_b = "kposfixayer" + "$" + cantidad.to_s + "@" + clave_interna.to_s


          if ( (@pwd_sup.to_s == confirmacion_ajuste_a) || (@pwd_sup.to_s == confirmacion_ajuste_b) ) # me aseguro sea compando completo de hoy o ayer antes de modificar pagos ok
             p.save    
             redirect_to "/reportets/new", notice: "Procesado Ok. Verificar." and return
          else
             redirect_to "/reportets/new", notice: "X. No entiende comando." and return   
          end
          
          
        else 

          redirect_to "/reportets/new", notice: "X. No procesado." and return

        end# end condition ( clave_interna.to_i == codigo_externo.to_i )

      end # end condition ( @pwd_sup.include?("kposfix") )



    if @pwd_sup == "abc65535"
      session[:reporte] = "supervisor_ok"
      session[:klk] = @pwd_sup
      @accesot = Accesot.new
      @accesot.usuario = "supervisor"
      @accesot.tipoacceso = "login"
      @accesot.fechayhora = Time.now
      @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
      @accesot.descripcion = "Login consulta reporte de ventas"
      @accesot.save
    end


    if @pwd_sup == "64738"
       session[:reporte] = "admin_ok"
       session[:klk] =  session[:reporte] #@pwd_sup
       @accesot = Accesot.new
       @accesot.usuario = "admin"
       @accesot.tipoacceso = "login"
       @accesot.fechayhora = Time.now
       @accesot.ip = request.env['action_dispatch.remote_ip'].to_s # registro la ip desde donde se hace el request. ok.
       @accesot.descripcion = "Login consulta reporte de ventas"
       @accesot.save
    end

    

    @fecha1 = params.require(:reportet).permit(:desde) 
    @fecha2 = params.require(:reportet).permit(:hasta) 
    session[:fecha_venta_dia_1] = @fecha1
    session[:fecha_venta_dia_2] = @fecha2
    redirect_to reportets_path and return  # el create lo manda al index con las variables de dias1 y dia2 para mostrar el reporte en el index view luego de ser procesado por el controller. ok ted.
  end

  # PATCH/PUT /reportets/1
  # PATCH/PUT /reportets/1.json
  def update
    respond_to do |format|
      if @reportet.update(reportet_params)
        format.html { redirect_to @reportet, notice: 'Reportet was successfully updated.' }
        format.json { render :show, status: :ok, location: @reportet }
      else
        format.html { render :edit }
        format.json { render json: @reportet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reportets/1
  # DELETE /reportets/1.json
  def destroy
    @reportet.destroy
    respond_to do |format|
      format.html { redirect_to reportets_url, notice: 'Reportet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  #definicion de la accion de consultas de reportes automaticos mes x mes pero no por la web, sino usando curl local curl --outout to file to be send to a ftp server later: ejemplo comando to generate local file report and send to any ftp server defined: 
def autoreportet # genera un autoreporte del mes actual y anio actual y lo envia a un server ftp. Esto para ser invocado mediante un crontad en pos o remoto si se desea via cul especialmente asi: curl -k -T file.txt ftp://user:password@ipsvrftp.com/ 
  # ejemplo de consulta: 
  #A: curl http://localhost:3000/autoreportets --output file.txt # puerto https si es en produccion etc.. es solo un ejemplo ok ted.
  #B: curl -k -T file.txt ftp://user:password@ipsvrftp.com/ 
  #C: LISTO DEBE SUBIR LA VENTA DEL MES AL SVR FTP ok.

  #ASI:
  #A: curl http://localhost:3000/autoreportets --output mes_actual.html
  #B: curl -k -T mes_actual.html ftp://js08:12345@10.0.7.155/ 
  


  #Generar las fechas automaticas locales: mes y anio actual.
  @auto_year =  Time.now.year 
  @auto_month = Time.now.month # => 12 diceimbre, retorna el numeron (string) del mes actual en ok. 1..12 ok tested it con irb ok.



  #verificarl el param para saber si se solicita un autoreportet del mes anterior (cierre mes completo ok)
  #nota utilizaremos el para existente params[:desde] (ojo no asegurado paramas pero para ifnes de autoreportes is ok para indicarlo desde ahi mismo en la peticion ok

  autoreportet_mes_anterior = params[:desde]   # debo enviar ?desde=generar_mes_anterior params por aqui ok

  if ( autoreportet_mes_anterior.to_s == "generar_mes_anterior" )
     #veirifcar que si el mes es enero el mes anterior dera diciembre(12) con el anio anterior para fines de autoreporte ok
     if (Time.now.month.to_i == 1.to_i)
       @auto_month = 12 # seterar en  diciembre  y poner al anio pasado autoreportes ok
       @auto_year =  Time.now.year.to_i - 1.to_i # ejemplo 2023-1 = 2022 numero ok ted. 
     else
       @auto_month = (Time.now.month.to_i) - 1.to_i # mes anterior
       @auto_year =  Time.now.year # is ok mismo anio ok.   

     end

  end




  #verificar si el mes es de 30,31,  28 o visiestro 29 con esta simple funcion:  days = Time.days_in_month(m, y), pasar el mes y el anio. ok sacado de  link: https://stackoverflow.com/questions/1489826/how-to-get-the-number-of-days-in-a-given-month-in-ruby-accounting-for-year
  @total_dias_de_ese_mes = Time.days_in_month(@auto_month.to_i , @auto_year.to_i) # days = Time.days_in_month(m, y)

  @fecha_venta_dia_1 = {"desde(3i)"=>"1", "desde(2i)"=>  @auto_month.to_s, "desde(1i)"=> @auto_year.to_i.to_s } # Time.now.year.to_s Significa del anio actual ok.
  @fecha_venta_dia_2 = {"hasta(3i)"=> @total_dias_de_ese_mes.to_s, "hasta(2i)"=> @auto_month.to_s, "hasta(1i)"=> @auto_year.to_i.to_s }


    @day1 = @fecha_venta_dia_1
    @day2 = @fecha_venta_dia_2

 # @primero = ganadores.primero < 10 ? ("0" + ganadores.primero.to_s) : ganadores.primero.to_s
    @fecha_venta_dia_1.values[2] = @fecha_venta_dia_1.values[2].to_i < 10 ? (@fecha_venta_dia_1.values[2] = "0" + @fecha_venta_dia_1.values[2] ) : (@fecha_venta_dia_1.values[2])
    @fecha_venta_dia_2.values[2] = @fecha_venta_dia_2.values[2].to_i < 10 ? (@fecha_venta_dia_2.values[2] = "0" + @fecha_venta_dia_2.values[2] ) : (@fecha_venta_dia_2.values[2])

    @dia1 = @fecha_venta_dia_1.values.reverse.join("-") # hash.values retorna array. para la consulta de by_day(fehca en ingles yyyy-mm-dd)    
    @dia2 = @fecha_venta_dia_2.values.reverse.join("-")

    # lo sigeuinte es para evitar que el 31-10-2018 sea mayor que el 01-11-2018 en la comparacion de fecha.to_i (agregar 0 deciumal que falta en noviembre)
    #@dia1 => "2018-10-31" 
    @day = @dia2.split("-")[2].to_i < 10 ? "0"+@dia2.split("-")[2] : @dia2.split("-")[2]
    ymd = @dia2.split("-")
    ymd[2] = @day
    @dia2 = ymd.join("-")

    # Lo mismo pada dia1 porque tambien tiene el mismo error. 5 => 05 ok.
    @day = @dia1.split("-")[2].to_i < 10 ? "0"+@dia1.split("-")[2] : @dia1.split("-")[2]
    ymd = @dia1.split("-")
    ymd[2] = @day
    @dia1 = ymd.join("-")


    if @dia1.split("-").join("").to_i > @dia2.split("-").join("").to_i
       redirect_to "/reportets/new", notice: "Fecha final debe se mayor a la fecha de inicio." and return
    end

    y, m, d = @dia2.to_s.split("-")

    if not (Date.valid_date? y.to_i, m.to_i, d.to_i) # sacado de link: https://stackoverflow.com/questions/2955830/how-to-check-if-a-string-is-a-valid-date
      redirect_to "/reportets/new", notice: "Debe elegir una fecha final valida. Ej. favor verifiicar si el mes es de 30 o 31 dias." and return
    end

    y, m, d = @dia1.to_s.split("-")
    
    if not (Date.valid_date? y.to_i, m.to_i, d.to_i) # sacado de link: https://stackoverflow.com/questions/2955830/how-to-check-if-a-string-is-a-valid-date
      redirect_to "/reportets/new", notice: "Debe elegir una fecha de inicio valida. Ej. favor verificar si el mes es de 30 o 31 dias." and return
    end

   # @dia2 = @dia2.to_date.tomorrow # OJO YA NO ES NECESARIO ESTO. OK. SI VAS A USAR BETWEEN TIMES EN LA GEMA BY_DAY, YA QUE ELLA SOLA AUTOMATICAMENTE ELIGE EL RANGO FINAL DEL DIA, EJ. SI ES EL DIA (1RO DE OCTUBRE) 2019-10-01   BETWENN HARA EL OFFSET DEL SEGUND DIA AUTOMATICO, ENTONCES SE DEBE DE PONER ASI Modelo.beetween_times("2019-10-01".to_date, "2019-10-01".to_date ) => del 01 ocubre a las 00:00:00 horas( + GMT si esta configurado Time Zone en rails, en nuestro caso si 4 horas, hasta el mismo 01 oct a las 23:59:59 + el GMT) ok ted. probar en Rails c


    @dia1 = @dia1.to_date

   
@veces = (@day2.values.join("-").to_date - @day1.values.join("-").to_date ).to_i  # devuelve un muero racional que dividido da un numero entero correspondiente a la cantidad de dias de la resta realizada.

# Me insteresa limpiar la tabla de reportes rapidamente, uso delete en ves de destroy porque obvia el dependent destroy model relations. ojo usar con responsabilidad. ok. este modelo no tiene dependencia alga de otro. ok.
@limpiar_tabla_reporte = Reportetipoexcell.delete_all #  Returns the number of rows affected.  link: https://apidock.com/rails/ActiveRecord/Base/delete_all/class

# COMENTADO PARA AUMENTAR DE 1 DIA A 186 DIAS LAS CONSULTA DE REPORTES USUARIO VENTAS OK.
# ===========  
  # Evitar que hagan consultas pasadas con uno o dos dias de diferencia ej. del 01/10/2019 al 02/10/2019, y no podran si no es admin, porque Date.today lo tomo como referencia asi ok: ( (Date.today - @day1.values.join("-").to_date) > 1 ) 
   # if (  ( (@veces > 1) || ( (Date.today - @day1.values.join("-").to_date) > 1 )  )  && ( session[:reporte].to_s != "supervisor_ok") && (session[:reporte].to_s != "admin_ok") )
   #      redirect_to "/transaccionests/new", notice: "Puedes consultar ventas del dia actual y del anterior, para otro tipo de reportes favor contactar a su supervisor." and return  
   # end
# ===========  

# Evitar que hagan consultas pasadas con mas de un mes (186 dias maximos). Especial fix de solo dos dias a 186 dias ok. ted.
if ( (  ( (@veces > 186) || ( (Date.today - @day1.values.join("-").to_date) > 186 )  )  && ( session[:reporte].to_s != "supervisor_ok") && (session[:reporte].to_s != "admin_ok") ) && ( @flag_auto == false) ) # Esto lo filtro con el boolena flag de control flag_auto para que si el reporte es auto poder sacar un mes completo cualquiera del anio para reporte excell remotos ok.
      redirect_to "/transaccionests/new", notice: "Puedes consultar ventas del dia actual y hasta un mes, para otro tipo de reporte favor contactar a su supervisor." and return  

end



(@veces + 1).times do |offset| # para incluir el ultimo dia en la consulta ej. 1-18 oct solo salen 17 dias, el 18avo dia se suma en el loop ara que lo corra al final ok ted.
#Reciclo esta parte del codigo de abajo, esto solo para provecharlo y utilizar la logica para implementarla en el reporter anidado del reporte excell. ok. ted.
  #@total_in =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok").sum(:cantidad)
  #@total_out =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) ).sum(:cantidad)
  
  #Suma Especial iterada para evitar el error por el postgres String.sum error en production ok ted.
  @total_in = @total_out = 0

  @total_in_especial =  Transaccionest.between_times(@dia1.to_date + offset, (@dia1.to_date + offset)).where(:tipotransaccion => "credito", :status => "ok")
  @total_out_especial =  Postransaccionest.between_times(@dia1.to_date + offset,( @dia1.to_date + offset.days) )
 
  @total_in_especial.each do |valor|
    @total_in += valor.cantidad.to_i

  end

  @total_out_especial.each do |valor|
    @total_out += valor.cantidad.to_i

  end


  @total_net = @total_in.to_i - @total_out.to_i

  @entrada_objeto = Reportetipoexcell.new
  @entrada_objeto.fecha = @dia1.to_date + offset
  @entrada_objeto.in = @total_in
  @entrada_objeto.out = @total_out
  @entrada_objeto.net = @total_net
  @entrada_objeto.save

end

@veces +=1 # esto para ell viwe solamente del counter 0..veces ok ted. no altera el ciclo de arriba ok.

@reporte_tipo_excell = Reportetipoexcell.all # Seleccion todos los valores dia x dia del reporte tipo excell. Esto para ser mostrado en la vista.

#Suma Especial otra vez ok, iterada para evitar el error por el postgres String.sum error en production ok ted.
@total_in_especial =  Transaccionest.between_times((@dia1.to_date ), (@dia2.to_date )).where(:tipotransaccion => "credito", :status => "ok")
@total_out_especial =  Postransaccionest.between_times((@dia1.to_date), (@dia2.to_date))

@total_in = @total_out = 0


@total_in_especial.each do |valor|
    @total_in += valor.cantidad.to_i

  end

  @total_out_especial.each do |valor|
    @total_out += valor.cantidad.to_i

  end




  @total_net = @total_in.to_i - @total_out.to_i

  @d1 = @dia1
  @d2 = @dia2

  @dia2 = @dia2.to_date # no borrar esto para setear formato de esta variable al tipo to_date para la logica de abajo en adelante y no tener que modificarla una a una debajo. ok. ted.

  #modificaciones provisionales para juntar el reporte detallado de ambas tablas Creditos/Debitos Modelos Transaccionest y Postransaccionest ted ok provisional work production ok v1.
  @array_consultas_transacciones =  Transaccionest.between_times(@dia1.to_date, @dia2).where("tipotransaccion = ? or tipotransaccion = ?", "credito", "debito" )

  @array_consultas_postransacciones = Postransaccionest.between_times(@dia1.to_date, @dia2)


  @ids_maquinas_activas = Maquinat.where(:activa => "si").ids
  @fecha_venta_detalladaxmaquina_dia_1 = @dia1.to_date # Esto para llevarme las fechas a imprimir con el loop de detallado x maquina en el index reporte de la vista (view index.html de la pagina) ok
  @fecha_venta_detalladaxmaquina_dia_2 =  @dia2 
  #IMPORTANTE ESTA PARTE DE ABAJO EN LA VISTA TED OK KOLLECTOR FUSION PROJECT OK.

  @dia1 = @fecha_venta_dia_1.values.join("-") # para el show dd-mm-aaaa
  @dia2 = @fecha_venta_dia_2.values.join("-") # para el show dd-mm-aaaa


  @fecha_venta_dia_1 = nil # Limpio la variable para evitar cookie oversize en el cliente.
  @fecha_venta_dia_2 = nil # Limpio la variable para evitar cookie oversize en el cliente.


  
end





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reportet
      @reportet = Reportet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reportet_params
      params.require(:reportet).permit(:desde, :hasta, :password, :supervisor, :sucursal, :tipomaquina)
      #elimino requiere para no obligatorio todos los campos provisional ok
      #params.permit(:desde, :hasta, :password, :supervisor, :sucursal, :tipomaquina)
    end
end








