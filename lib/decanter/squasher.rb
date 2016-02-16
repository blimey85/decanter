module Decanter
  module Squasher
    @@squashers = {}

    def self.register(squasher)
      @@squashers[squasher.name.demodulize] = squasher
    end

    def self.squasher_for(sym)
      p "find squasher for #{sym}"
      @@squashers["#{sym.to_s.camelize}Squasher"] || (raise NameError.new("unknown squasher #{sym.to_s.capitalize}Squasher"))
    end
  end
end

require_relative 'squasher/base'
require_relative 'squasher/core'
require_relative 'squasher/date_squasher'
