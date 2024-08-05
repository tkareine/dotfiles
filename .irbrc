# frozen_string_literal: true

IRB.conf[:USE_MULTILINE] = true
IRB.conf[:SAVE_HISTORY] = 2000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
