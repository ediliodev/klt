class CreateUsuariosbrts < ActiveRecord::Migration[5.1]
  def change
    create_table :usuariosbrts do |t|
      t.string :nombre
      t.string :apellido
      t.string :usuario
      t.string :contrasena
      t.string :telefono
      t.string :email
      t.string :cedula
      t.string :direccion

      t.timestamps
    end
  end
end
