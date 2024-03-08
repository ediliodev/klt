class Maquinat < ApplicationRecord
  belongs_to :tipomaquinat
  validates :serial, uniqueness: true # cada serial de maquina debe ser unico probar ok
  validates_presence_of :consorcio, :sucursal, :descripcion, :serial, :usuarioventa, :supervisor, :message => "Debes completar esa informacion."

  #guardar enminuscula estos tres campos clave es reportes para luego poder comparar correctamente y evitar mistyping errors reportes ok
  before_save {self.sucursal.downcase!}
  before_save {self.usuarioventa.downcase!}
  before_save {self.supervisor.downcase!}

end
