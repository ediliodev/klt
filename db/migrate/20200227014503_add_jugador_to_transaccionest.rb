class AddJugadorToTransaccionest < ActiveRecord::Migration[5.1]
  def change
    add_column :transaccionests, :jugador, :integer
  end
end
