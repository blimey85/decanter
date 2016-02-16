module Decanter
  module Squasher
    module Core

      def self.included(base)
        base.extend(ClassMethods)
        Squasher.register(base)
      end

      module ClassMethods

        def squash(name, values, options = {})
          # if inputs.blank?
          #   if options[:required]
          #     raise ArgumentError.new("No value for required argument: #{name}")
          #   else
          #     return inputs
          #   end
          # end

          unless @squasher
            raise ArgumentError.new("No squasher for argument: #{name} and type #{type}.")
          end

          @squasher.call(name, values, options)
        end

        def squasher(&block)
          @squasher = block
        end
      end
    end
  end
end
