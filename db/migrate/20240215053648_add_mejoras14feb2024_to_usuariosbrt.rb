class AddMejoras14feb2024ToUsuariosbrt < ActiveRecord::Migration[5.1]
  def change
    add_column :usuariosbrts, :tipousuario, :string
    add_column :usuariosbrts, :md5pc, :string
    add_column :usuariosbrts, :consorcioasociado, :string
  end
end
