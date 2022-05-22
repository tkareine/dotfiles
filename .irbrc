# frozen_string_literal: true

ARGV.concat %w[--readline --prompt-mode simple]

require "irb/completion"
require "irb/ext/save-history"

IRB.conf[:SAVE_HISTORY] = 2000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

require "pp"
require "rubygems"

# From <http://ozmm.org/posts/time_in_irb.html>
def time(times = 1)
  require "benchmark"
  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end

# From <http://github.com/rtomayko/dotfiles/blob/rtomayko/.irbrc>
def local_methods(obj = self)
  (obj.methods - obj.class.superclass.instance_methods).sort
end

def ls(obj = self)
  width = `stty size 2>/dev/null`.split(/\s+/, 2).last.to_i
  width = 80 if width.zero?
  local_methods(obj).each_slice(3) do |meths|
    pattern = "%-#{width / 3}s" * meths.length
    puts pattern % meths
  end
end
