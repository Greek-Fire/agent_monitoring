class CreateAgents < ActiveRecord::Migration[6.0]
    def change
      create_table :agents do |t|
        t.string :network
        t.string :status
        t.string :agent
        t.string :host
  
        t.timestamps
      end
  
      add_index :agents, :network
      add_index :agents, :status
      add_index :agents, :agent
      add_index :agents, :host
    end
  end  