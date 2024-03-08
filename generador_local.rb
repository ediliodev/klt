

#!/usr/bin/ruby

#ESTA ES LA SEGUNDA SVERSION DEL ACTIVATOR SCRIPT
puts "Favor ingresar el codigo completo de activacion ej: kpos-07-20-01-66-58-26-92-27-67-64-7-3321-7674-78"
code = gets

#distribuir asigacion de cada variable:

#kpos-07-20-01-66-58-26-92-27-67-64-7-3321-7674-78

a = code.split("-")[4].to_i
b = code.split("-")[5].to_i
c = code.split("-")[6].to_i
d = code.split("-")[7].to_i
e = code.split("-")[8].to_i
f = code.split("-")[9].to_i
g = code.split("-")[10].to_i
h = code.split("-")[11].to_i





puts "VALOR DE LA FORMULA FX1 ES:"
valorfx1_offline = (3 * (5 + c + (b-c)) + 2 * a) + (d + 4 + e * 4 * f ) - g + (g + 3 * h)
puts valorfx1_offline


puts "VALOR DE LA FORMULA FX2 ES:"
valorfx2_offline = (4 * (6 + d + (b-a)) + 2 * c) + (b - 8 + a + 10 + b ) + (d + 1 + e * 2 * f ) - 3 * g + (g + 3 * h)  # con esta descodificaremos respuesta del svr
puts valorfx2_offline

puts "comando completo seria: " + "kpos-" + "#{valorfx2_offline}-30-nadacomentado" 
