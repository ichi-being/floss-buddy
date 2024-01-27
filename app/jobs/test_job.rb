class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "===================="
    puts "Test job is performed at #{Time.now}"
    puts "===================="
  end
end
