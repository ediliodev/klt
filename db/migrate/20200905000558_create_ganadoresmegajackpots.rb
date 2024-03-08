class CreateGanadoresmegajackpots < ActiveRecord::Migration[5.1]
  def change
    create_table :ganadoresmegajackpots do |t|
      t.string :fecha
      t.string :consorcio
      t.string :sucursal
      t.string :localidad
      t.string :serialmq
      t.string :cantidad
      t.string :montoxcontribuyente

      t.timestamps
    end
  end
end
