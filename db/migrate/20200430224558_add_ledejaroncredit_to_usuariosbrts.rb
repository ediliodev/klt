class AddLedejaroncreditToUsuariosbrts < ActiveRecord::Migration[5.1]
  def change
    add_column :usuariosbrts, :ledejaroncredit, :boolean
  end
end
