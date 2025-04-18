class CreateSolidQueueTables < ActiveRecord::Migration[8.0]
 def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :class_name, null: false
      t.text :arguments
      t.integer :priority, default: 0, null: false
      t.datetime :run_at, null: false
      t.datetime :locked_at
      t.string :locked_by
      t.integer :attempts, default: 0, null: false
      t.datetime :finished_at
      t.text :error
      t.timestamps
    end

    create_table :solid_queue_processes do |t|
      t.string :kind, null: false
      t.string :name
      t.datetime :last_heartbeat_at
      t.integer :supervisor_id
      t.integer :pid
      t.string :hostname
      t.text :metadata
      t.timestamps
    end

    create_table :solid_queue_ready_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false
    end

    create_table :solid_queue_blocked_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false
      t.string :concurrency_key, null: false
    end

    create_table :solid_queue_scheduled_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false
    end

    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end

    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false
      t.timestamps
    end

    create_table :solid_queue_recurring_executions do |t|
      t.string :task_key, null: false
      t.datetime :run_at, null: false
      t.text :arguments
      t.timestamps
    end

    create_table :solid_queue_failed_executions do |t|
      t.bigint :job_id, null: false
      t.string :error
      t.timestamps
    end

    add_index :solid_queue_jobs, :run_at
    add_index :solid_queue_jobs, :finished_at
    add_index :solid_queue_processes, :last_heartbeat_at
    add_index :solid_queue_ready_executions, [:queue_name, :priority, :scheduled_at]
    add_index :solid_queue_blocked_executions, :concurrency_key
    add_index :solid_queue_scheduled_executions, [:queue_name, :priority, :scheduled_at]
    add_index :solid_queue_semaphores, :key, unique: true
    add_index :solid_queue_pauses, :queue_name, unique: true
    add_index :solid_queue_recurring_executions, :task_key, unique: true
    add_index :solid_queue_failed_executions, :job_id, unique: true
  end
end
