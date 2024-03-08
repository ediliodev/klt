class CreateContribuyentets < ActiveRecord::Migration[5.1]
  def change
    create_table :contribuyentets do |t|
      t.string :consorcio
      t.string :sucursal
      t.string :siglas
      t.string :localidad
      t.string :serialmq
      t.string :countermeterold
      t.string :countermeternew
      t.string :aportemega

      t.timestamps
    end
  end
end
