require "sqlite3"
require "pry-byebug"
DB = SQLite3::Database.new("tasks.db")

class Task
  attr_accessor :name, :done
  attr_reader :id

  def initialize(args = {})
    @id = args[:id] || args['id']
    @name = args[:name] || args['name']
    @done = args[:done] || args['done'] ||  false
  end

  def save
    if @id.nil?
      DB.execute(<<-SQL
                 INSERT INTO tasks (name, done)
                 VALUES ("#{@name}", #{done_to_i})
                 SQL
                 )
      @id = DB.last_insert_row_id
    else
      DB.execute(<<-SQL
                 UPDATE tasks
                 SET name = "#{@name}", done = #{done_to_i}
                 WHERE id = #{@id}
                 SQL
                 )
    end
  end

  def self.all
    DB.results_as_hash = true
    tasks_data = DB.execute("SELECT * FROM tasks")
    tasks_data.map do |task_data|
      i_to_done!(task_data)
      new(task_data)
    end
  end

  def self.find(id)
    DB.results_as_hash = true
    task_data = DB.execute(<<-SQL
               SELECT * FROM tasks
               WHERE id = #{id}
                 SQL
                 ).first
    return nil if task_data.nil?
    i_to_done!(task_data)
    new(task_data)
  end

  private

  def done_to_i
    @done ? 1 : 0
  end

  def self.i_to_done!(task_data)
    task_data["done"] = !task_data["done"].zero?
  end
end


Task.new(name: 'Faire le live code').save
task = Task.find(1)
task.done = true
task.save

p Task.all

