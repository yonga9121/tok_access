class TokAccessCreateUsers < ActiveRecord::Migration[5.1]
  def change

    create_table :users do |t|
      t.string :password_digest, null: false, default: ""

      
    end
  end

end
