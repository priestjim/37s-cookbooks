# This will ride alongside god and kill any rogue memory-greedy
# processes. Their sacrifice is for the greater good.
 
unicorn_worker_memory_limit = 300_000

# borrowed from passenger-memory-stats
# get the actual memory usage of a given process

def determine_private_dirty_rss(pid)
   total = 0
   File.read("/proc/#{pid}/smaps").split("\n").each do |line|
     line =~ /^(Private)_Dirty: +(\d+)/
     if $2
       total += $2.to_i
     end
   end
   if total == 0
     return nil
   else
     return total
   end
 rescue Errno::EACCES, Errno::ENOENT
   return nil
 end
 
Thread.new do
  loop do
    begin
      # unicorn workers
      #
      # ps output line format:
      # 31580 40533 unicorn_rails worker[15] -c /data/github/current/config/unicorn.rb -E production -D
      # pid rss command

      lines = `ps -e -www -o pid,rss,command | grep '[u]nicorn_rails worker'`.split("\n")
      lines.each do |line|
        parts = line.split(' ')
        
        # if Private Dirty RSS can be determined, use it. Otherwise, use the ps output
        rss = determine_private_dirty_rss(parts[0]) || parts[1]
        
        if rss > unicorn_worker_memory_limit
          # tell the worker to die after it finishes serving its request
          ::Process.kill('QUIT', parts[0].to_i)
        end
      end
    rescue Object
      # don't die ever once we've tested this
      nil
    end
 
    sleep 30
  end
end