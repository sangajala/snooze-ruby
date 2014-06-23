require 'rspec'
module RubyUatFramework
#  include Spec::Matchers

  class DialogNotHandledException < RuntimeError
  end

  class DialogUnexpectedTextException < RuntimeError
  end

  class DialogHandler
    attr_accessor :optional

    def start_watchdog(timeout)
      @timeout = timeout
      @watchdog = Thread.new do
        begin
          Watir::Waiter.wait_until(timeout) {@dialog_was_handled}
        rescue Watir::TimeOutException
          kill_all_ie_windows if not optional
        end
      end
    end

    def initialize(timeout = 60)
      raise "Must be called from a code block!" if !block_given?
      #set up watchdog at 60 seconds
      @dialog_was_handled = false
      start_watchdog(timeout)
      yield self
      @watchdog.join
      raise DialogNotHandledException.new if not @dialog_was_handled
    end

    protected
    def timeout
      @timeout
    end

    private
    def kill_all_ie_windows
      `taskkill /IM iexplore.exe /T /F`
    end
  end
end