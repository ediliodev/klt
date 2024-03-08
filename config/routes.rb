Rails.application.routes.draw do

  resources :ganadoresmegajackpots
  resources :contribuyentets
# MODIFICACION GENERAL DE ALGUNAS RUTAS NO DISPONIBLE POR LA WEB PUBLIC OK. TED.

  resources :usuariosbrts # privional comentar en produccion ok.
  resources :jackpots
  resources :historypostransaccionests
#  resources :singlepostransaccionests

  #Algunas rutas desabilitadas para produccion r12v ns ok:
  #    get 'gameroom', to: 'rondaruletabbts#gameroom'
      get 'androidgame', to: 'rondaruletabbts#androidgame'
      get 'settingsgame', to: 'rondaruletabbts#androidgame'
   #   get 'iphonegame', to: 'rondaruletabbts#iphonegame'
   #   get 'dashgame',  to: 'rondaruletabbts#dashgame' #old bancagame nombre feo ok. new name route ok ted.
   #   get 'dashgameh',  to: 'rondaruletabbts#dashgameh' #horizontal version of multiplayer r12 ted ok.
      get 'dashgamev',  to: 'rondaruletabbts#dashgamev' #vertical version of multiplayer r12 ted ok.


  get 'pos', to: 'transaccionests#new'
 

  
  resources :rondaruletabbts
# resources :fondots
# resources :contadorests
# resources :cashboxts
  #resources :rondaruletabts # no necesario para ruleta project ok. ted.
  resources :rondaruletats
# resources :rondats
  resources :reportetipoexcells
  resources :accesots
# resources :mixtransaccionests
  resources :reportets
  get 'autoreportets',  to: 'reportets#autoreportet' #vertical version of multiplayer r12 ted ok.

  resources :postransaccionests # Se realizaron comentarios en las vistas y modificaciones de acceso publico para asegurar mas este controlador  ok.
  resources :transaccionests
  resources :maquinats
  resources :tipomaquinats #provisional , comentar en produccion ok ted.
  resources :localidadts

  root to: 'transaccionests#new' 
  #root to: 'rondaruletabbts#gameroom' Nota: pone un dns redirect si quieres un dns to this route as default for webclients, ok. No puero ponerlo aqui, porque esta ruta root es para /pos ok ted. reportes y demas ok.
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
