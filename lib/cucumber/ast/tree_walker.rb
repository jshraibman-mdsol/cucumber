module Cucumber
  module Ast
    # Walks the AST, executing steps and notifying listeners
    class TreeWalker
      attr_accessor :configuration #:nodoc:
      attr_reader   :runtime #:nodoc:

      def initialize(runtime, listeners = [], configuration = Cucumber::Configuration.default)
        @runtime, @listeners, @configuration = runtime, listeners, configuration
      end

      def execute(scenario, skip_hooks)
        runtime.with_hooks(scenario, skip_hooks) do
          scenario.skip_invoke! if scenario.failed?
          scenario.steps.accept(self)
        end
      end

      # forwards on messages from the AST to the formatters
      def method_missing(message, *args, &block)
        broadcast_message(message, *args, &block)
      end

      def visit_multiline_arg(multiline_arg) #:nodoc:
        broadcast(multiline_arg) do
          multiline_arg.accept(self)
        end
      end

      private

      def broadcast(*args, &block)
        message = extract_method_name_from(caller[0])
        broadcast_message message, *args, &block
        self
      end

      def broadcast_message(message, *args, &block)
        return self if Cucumber.wants_to_quit
        message = message.to_s.gsub('visit_', '')
        if block_given?
          send_to_all("before_#{message}", *args)
          yield if block_given?
          send_to_all("after_#{message}", *args)
        else
          send_to_all(message, *args)
        end
        self
      end

      def send_to_all(message, *args)
        @listeners.each do |listener|
          if listener.respond_to?(message)
            listener.__send__(message, *args)
          end
        end
        self
      end

      def extract_method_name_from(call_stack_line)
        match = call_stack_line.match(/in `(.*)'/)
        match.captures[0]
      end

    end
  end
end
