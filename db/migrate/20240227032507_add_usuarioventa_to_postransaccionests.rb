class AddUsuarioventaToPostransaccionests < ActiveRecord::Migration[5.1]
  def change
    add_column :postransaccionests, :usuarioventa, :string
  end
end
