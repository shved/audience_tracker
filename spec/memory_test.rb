require 'get_process_mem'

file = File.new('log/mem_log.txt', 'w')
pid = Process.spawn('make run')
mem = GetProcessMem.new(pid)

20.times do
  sleep(5)
  file << mem.inspect
  file << "\n"
end

file.close

Process.kill('TERM', pid)
Process.wait(pid)
