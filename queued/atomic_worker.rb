# It's called AtomicWorker because there's a mutex around code that
# actually pulls something off the queue and does something with it. Even if
# you had lots of threads trying to run this code the mutex.synchronize call
# is going to do this:
#  "Obtains a lock, runs the block, and releases the lock when the
#   block completes."
# Further reading:
#   https://ruby-doc.org/core-2.6/Mutex.html#method-i-synchronize
class AtomicWorker
  def initialize(queue:)
    @queue = queue
  end

  def start
    mutex = Mutex.new
    Thread.new do
      while queue_ready?
        mutex.synchronize { work_the_queue }
      end
    end
  end

  def add_to_queue(receiver, message)
    queue.push([receiver, message])
  end

  private

  attr_reader :queue

  def work_the_queue
    puts "worker is ready to process donations"
    receiver, message = pop_or_wait
    puts "worker is processing a donation..."
    receiver.send(message) { sleep 5 } if receiver
    puts "worker finshed processing a dontation!"
    puts "jobs left in queue: #{@queue.size}"
  end

  def queue_ready?
    !queue.closed? || !queue.empty?
  end

  # if the queue is empty, the calling thread is simply suspended
  # https://ruby-doc.org/core-2.6/Queue.html#method-i-pop
  def pop_or_wait
    queue.pop
  end
end
