require_relative 'core'

module Decanter
  module Squasher
    class Base
      include Core
      def self.inherited(subclass)
        Squasher.register(subclass)
      end
    end
  end
end

