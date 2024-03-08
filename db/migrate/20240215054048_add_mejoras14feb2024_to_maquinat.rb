class AddMejoras14feb2024ToMaquinat < ActiveRecord::Migration[5.1]
  def change
    add_column :maquinats, :consorcio, :string
    add_column :maquinats, :sucursal, :string
    add_column :maquinats, :supervisor, :string
    add_column :maquinats, :usuarioventa, :string
  end
end
