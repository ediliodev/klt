class AddUsuarioventaToTransaccionests < ActiveRecord::Migration[5.1]
  def change
    add_column :transaccionests, :usuarioventa, :string
  end
end
