class AddSerialmaquinaToTransaccionests < ActiveRecord::Migration[5.1]
  def change
    add_column :transaccionests, :serialmaquina, :string
  end
end
