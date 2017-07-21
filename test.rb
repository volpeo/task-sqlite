require_relative "task"

Task.new(name: 'Faire le live code').save
p Task.find(1)
