class AddContadoresToMaquinat < ActiveRecord::Migration[5.1]
  def change
    add_column :maquinats, :entrada, :string
    add_column :maquinats, :salida, :string
  end
end
