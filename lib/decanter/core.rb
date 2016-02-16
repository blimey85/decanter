module Decanter
  module Core

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def associations
        @associations ||= {}.with_indifferent_access
      end

      def inputs
        @inputs ||= {}.with_indifferent_access
      end

      def squashed_inputs
        @squashed_inputs ||= {}.with_indifferent_access
      end

      def parsed_inputs
        @parsed_inputs
      end

      def input(name=nil, type, **options)
        set_input options, {
          name:    name,
          options: options.reject { |k| k == :context },
          type:    type
        }
      end

      def squashed_input(name=nil, type, **options)
        set_squashed_input options, {
          name:    name,
          options: options.reject { |k| k == :context },
          type:    type
        }
      end

      def set_input(options, input_cfg)
        set_for_context options, input_cfg, inputs
      end

      def input_for(name, context)
        (inputs[context || :default] || {})[name]
      end

      def squashed_input_for(name, context)
        (squashed_inputs[context || :default] || {})[name]
      end

      def set_squashed_input(options, squashed_input_cfg)
        set_for_context options, squashed_input_cfg, squashed_inputs
      end

      def has_many(name=nil, **options)
        set_association options, {
          key:     options[:key] || "#{name}_attributes".to_sym,
          name:    name,
          options: options.reject { |k| k == :context },
          type:    :has_many
        }
      end

      def has_one(name=nil, **options)
        set_association options, {
          key:     options[:key] || "#{name}_attributes".to_sym,
          name:    name,
          options: options.reject { |k| k == :context },
          type:    :has_one
        }
      end

      def has_many_for(key, context)
        (associations[context || :default] || {})
          .detect { |name, assoc| assoc[:type] == :has_many && assoc[:key] == key.to_sym}
      end

      def has_one_for(key, context)
        (associations[context || :default] || {})
          .detect { |name, assoc| assoc[:type] == :has_one && assoc[:key] == key.to_sym}
      end

      def set_association(options, assoc)
        set_for_context options, assoc, associations
      end

      def set_for_context(options, arg, hash)
        context = options[:context] || @context || :default
        hash[context] = {} unless hash.has_key? context
        hash[context][arg[:name]] = arg
      end

      def with_context(context, &block)
        raise NameError.new('no context argument provided to with_context') unless context

        @context = context
        block.arity.zero? ? instance_eval(&block) : block.call(self)
        @context = nil
      end

      def decant(args={}, context=nil)
        run_parsers(args, context)
        run_squashers(context)
        transform(@parsed_inputs)
      end

      def run_parsers(args={}, context=nil)
        # args.keys.each do |key|
        #   key_array = handle_arg(key, args[key], context)
        #   @parsed_inputs[key_array.first] = key_array.second
        # end
        @parsed_inputs = Hash[
          *args.keys.map { |key| handle_arg(key, args[key], context) }.flatten.compact
        ].with_indifferent_access
      end

      def run_squashers(context=nil)
        squashed_inputs_keys = squashed_inputs[context || :default].try(:keys) || []
        squashed_inputs_keys.each do |key|
          key_array = handle_arg(key, nil, context)
          @parsed_inputs[key_array.first] = key_array.second
        end
        @parsed_inputs
      end

      def transform(args)
        # hook for subclasses
        args
      end

      def handle_arg(name, value, context)
        case
        when input_cfg = input_for(name, context)
          parse(name, input_cfg[:type], value, input_cfg[:options]).flatten
        when assoc = has_one_for(name, context)
          [assoc.pop[:key], Decanter::decanter_for(assoc[1][:options][:decanter] || assoc.first).decant(value, context)]
        when assoc = has_many_for(name, context)
          decanter = Decanter::decanter_for(assoc[1][:options][:decanter] || assoc.first)
          [assoc.pop[:key], value.map { |val| decanter.decant(val, context) }]
        when squashed_input_cfg = squashed_input_for(name, context)
          [name, squash(name, squashed_input_cfg[:type], squashed_input_cfg[:options])]
        else
          context ? nil : [name, value]
        end
      end

      def squash(name, type, options)
        inputs_to_squash = options[:squash]
        values = inputs_to_squash.map { |input| @parsed_inputs[input] }
        squashed_value = Squasher.squasher_for(type).squash(name, values, options)
        inputs_to_squash.each do |key_to_squash|
          @parsed_inputs.delete(key_to_squash)
        end
        squashed_value
      end

      def parse(name, type, val, options)
        type ?
          ValueParser.value_parser_for(type).parse(name, val, options) :
          [name, val]
      end
    end
  end
end
