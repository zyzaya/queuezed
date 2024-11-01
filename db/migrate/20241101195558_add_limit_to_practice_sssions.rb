class AddLimitToPracticeSssions < ActiveRecord::Migration[7.2]
  def change
    add_column :practice_sessions, :limit, :integer, default: -1
  end
end
