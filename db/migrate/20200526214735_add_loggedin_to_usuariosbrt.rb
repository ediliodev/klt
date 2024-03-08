class AddLoggedinToUsuariosbrt < ActiveRecord::Migration[5.1]
  def change
    add_column :usuariosbrts, :loggedin, :string
  end
end
