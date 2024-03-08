class CreateFondots < ActiveRecord::Migration[5.1]
  def change
    create_table :fondots do |t|
      t.string :cantidad

      t.timestamps
    end
  end
end
