Main = self

module RubyUatFramework
  class CucumberHooks
    attr_accessor :current_world
    @hooks_registered = false
    # unless current_world is global the hooks don't seem to have access to it.
    # not sure why this is.
    @@current_world = nil
    def register(world)
      @@current_world = world
      if not @hooks_registered
        Main.Before do
          if (respond_to?('before'))
            before
          else
            @@current_world.before
          end
        end
        Main.After do |scenario|
          if (respond_to?('after'))
            after(scenario)
          else
            @@current_world.after(scenario)
          end
        end
        hook_at_exit do
          if (respond_to?('on_exit'))
            on_exit
          else
            @@current_world.on_exit
          end
        end
      end
      @hooks_registered = true
    end

    def hook_at_exit(&block)
      at_exit &block
    end
  end
end