class TeamCityFormatter 
  attr_reader :step_mother
  def initialize(step_mother, io, options)
    @step_mother = step_mother
    @message_factory=TeamCityMessageFactory.new(io)
    @io = io
    @options = options
    @current_feature = nil
    @current_step=nil


    # TeamCity seems to ignore "ERROR"
    @statusMap= { :passed => 'NORMAL',
                  :skipped => 'WARNING',
                  :pending => 'WARNING',
                  :undefined => 'WARNING',
                  :failed => 'WARNING'
    }
  end

  # = AST Visitor hooks

  # visitor looks pretty much like this:
  # (not complete! this misses out e.g. examples)
  #
  # visit_features
  #   for each: visit_feature
  #     visit_comment
  #     visit_tags
  #       for each: visit_tag_name
  #     visit_feature_name
  #     visit_background        (invokes background steps)
  #     for each: visit_feature_element (feature_element is Scenario or ScenarioOutline)
  #       visit_comment
  #       visit_tags
  #         for each: visit_tag_name
  #       visit_scenario_name
  #       for each: visit_steps (steps is StepCollection)
  #         visit_step (step is StepInvocation or Step)
  #           invoke (!!)
  #           visit_step_result
  #             visit_step_name
  #             visit_multiline_arg if multiline_arg
  #             visit_exception if exception
  #       visit_examples_array  (if ScenarioOutline)
  #         for each: visit_examples    (looping over example sections)
  #           visit_examples_name       (keyword, name)
  #           visit_outline_table
  #
  # if !options[:expand] (default)
  #
  #             for each: visit_table_row       (looping over cells)
  #               visit_table_cell              (cell has status set to :skipped_param for header)
  #                 visit_table_cell_value


  class TeamCityMessageFactory
    def initialize(io)
      @io=io
      @batched_messages=[]
    end

    def test_suite_started(name)
      name=escape(name)
      @io.puts "##teamcity[testSuiteStarted #{timestamp} name='#{name}']"
      @io.flush
    end

    def test_suite_finished(name)
      name=escape(name)
      @io.puts "##teamcity[testSuiteFinished #{timestamp} name='#{name}']"
      @io.flush
    end

    def test_started(name)
      name=escape(name)
      @io.puts "##teamcity[testStarted #{timestamp} name='#{name}' captureStandardOutput='true']"
      @io.flush
    end

    def test_failed(name, msg, details='')
      name=escape(name)
      msg=escape(msg)
      details=escape(details)
      @io.puts "##teamcity[testFailed #{timestamp} name='#{name}' message='#{msg}' details='#{details}']"
      @io.flush
    end

    def test_ignored(name, msg)
      name=escape(name)
      msg=escape(msg)
      @io.puts "##teamcity[testIgnored #{timestamp} name='#{name}' message='#{msg}']"
      @io.flush
    end

    def test_finished(name)
      name=escape(name)
      @io.puts "##teamcity[testFinished #{timestamp} name='#{name}']"
      @io.flush
    end

    def progress_start(msg)
      msg=escape(msg)
      @io.puts "##teamcity[progressStart '#{msg}']"
      @io.flush
    end

    def progress_finish(msg)
      msg=escape(msg)
      @io.puts "##teamcity[progressFinish '#{msg}']"
      @io.flush
    end

    def message(msg, status='NORMAL')
      @io.puts format_message(msg, status)
      @io.flush
    end

    def push_message(msg, status='NORMAL')
      @batched_messages.push(format_message(msg, status))
    end

    def output_messages
      @batched_messages.each{|m| @io.puts m }
      @batched_messages=[]
      @io.flush
    end

    def format_message(msg, status='NORMAL')
      msg=escape(msg)
      "##teamcity[message #{timestamp} text='#{msg}|n' status='#{status}']"
    end

    def puts(m)
      @io.puts m
      @io.flush
    end

    def whitespace
      @io.puts
      @io.puts
      @io.flush
    end

    private

    def escape(str)
      str = str.to_s.strip
      str.gsub!('|', '||')
      str.gsub!("\n", '|n')
      str.gsub!("\r", '|r')
      str.gsub!("'", "|'")
      str.gsub!(']', '|]')
      return str
    end

    def timestamp
      t = Time.now
      ts=t.strftime('%Y-%m-%dT%H:%M:%S.%%0.3d') % (t.usec/1000)
      " timestamp='#{ts}' "
    end
  end


  class FeatureElementStrategy
    attr_accessor :name

    def initialize(visitor, message_factory)
      @visitor=visitor
      @message_factory=message_factory

      # TeamCity seems to ignore "ERROR"
      @statusMap= { :passed => 'NORMAL',
                    :skipped => 'WARNING',
                    :pending => 'WARNING',
                    :undefined => 'WARNING',
                    :failed => 'WARNING',
                    :outline => 'NORMAL'
      }
    end

    protected

    def format_step(keyword, step_match, status)
      %q{%s %11s %s %-90s @ %s} % [timestamp_short, '(' + status.to_s + ')', keyword,
                                   step_match.format_args(lambda{|param| param}),
                                   step_match.file_colon_line]
    end

    def format_exception(exception)
      (["#{exception.message} (#{exception.class} Exception)\n"] + exception.backtrace).join("\n") + "\n"
    end

    def timestamp_short
      t = Time.now
      ts=t.strftime('%H:%M:%S.%%0.3d') % (t.usec/1000)
    end
  end


  class ScenarioStrategy < FeatureElementStrategy

    def initialize(visitor, message_factory)
      super(visitor, message_factory)
      @scenario_ignored=false
    end


    def feature_element_start()
      @message_factory.test_started(@name)
    end

    def step_start(step_name)
      @message_factory.progress_start(step_name)
      @step_name=step_name
    end

    def step_details(keyword, step_match, status, source_indent, background)
      @message_factory.push_message(format_step(keyword, step_match, status), @statusMap[status])
    end

    def multiline_arg_table_strategy
      MultilineArgTableStrategy.new(@message_factory)
    end

    def visit_exception(exception, status, snippet)
      case status
        when :pending
          @message_factory.test_ignored(@name, "Step '#{@step_name}' is marked as pending")
          @scenario_ignored=true
        when :undefined
          @message_factory.push_message(snippet, 'WARNING')
          @message_factory.test_failed(@name, exception.message, format_exception(exception)) unless @scenario_ignored
        else
          @message_factory.test_failed(@name, @step_name, format_exception(exception))
      end
    end


    def step_finish(step_name)
      @message_factory.progress_finish(step_name)
    end

    def feature_element_finish()
      @message_factory.output_messages
      @message_factory.test_finished(@name)
    end
  end


  class MultilineArgTableStrategy
    def initialize(message_factory)
      @message_factory = message_factory
    end

    def table_row_start(table_row)
      @row_text = ''
    end

    def cell_value(value, width, status)
      @row_text = @row_text + "| " + (value.to_s || '').ljust(width)
    end

    def table_row_finish(table_row)
      @message_factory.push_message(@row_text + ' |')
    end
  end


  class ScenarioOutlineStrategy < FeatureElementStrategy
    def feature_element_start()
      @message_factory.test_suite_started(@name)
      @example_details=[]
    end

    def step_start(step_name)
      # Cucumber walks the steps without executing them
    end

    def step_details(keyword, step_match, status, source_indent, background)
      @example_details.push(@message_factory.format_message(format_step(keyword, step_match, "outline"), 'NORMAL'))
    end

    def multiline_arg_table_strategy
      MultilineArgTableStrategy.new(@message_factory)
    end

    class MultlineArgTableStrategy
      def initialize(scenario_outline_strategy)
        @scenario_outline_strategy = scenario_outline_strategy
      end

      def table_row_start(table_row)
      end

      def cell_value(value, width, status)
        puts "value=#{value}, status=#{status}"
      end

      def table_row_finish(table_row)
      end
    end

    def step_finish(step_name)
      # Cucumber walks the steps without executing them
    end

    def examples_section_header(keyword, name)
      @example_details.push(@message_factory.format_message("#{keyword} #{name}"))
      @header=true
    end

    def outline_table_strategy
      OutlineTableStrategy.new(self)
    end

    class OutlineTableStrategy
      def initialize(scenario_outline_strategy)
        @scenario_outline_strategy = scenario_outline_strategy
      end

      def table_row_start(table_row)
        @example_name="Example: #{table_row.name}"
        @scenario_outline_strategy.example_start(@example_name)
      end

      def cell_value(value, width, status)
        @scenario_outline_strategy.example_cell_result(value, width, status)
      end

      def table_row_finish(table_row)
        @scenario_outline_strategy.example_finish(@example_name)
      end
    end

    def example_start(name)
      @test_name=name
      @message_factory.test_started(name) unless @header
      @current_example_result=''
      @current_example_status=:passed
    end

    def example_cell_result(value, width, status)
      status = nil if status==:skipped_param
      @current_example_result += format_table_cell_value(value, width, status)

      if status != nil then
        if @current_example_status==:passed
          @current_example_status=status
        elsif @current_example_status==:pending && status!=:passed
          @current_example_status=status
        elsif @current_example_status==:undefined && status!=:passed && status!=:pending
          @current_example_status=status
        end
      end
    end

    def example_finish(name)
      example_result=@current_example_result + " |"
      if @header then
        @example_details.push(@message_factory.format_message(example_result))
        @header=false
      else
        case @current_example_status
          when :passed
            # do nothing
          when :pending
            @message_factory.test_ignored(@test_name, "One or more steps are marked as pending")
          when :undefined
            # TODO: It would be nice to be able to display the undefined snippet here, but I don't think I can get at it
            #step_message(format_undef_step_snippet(@current_step_name, exception, @current_step.multiline_arg, @current_step.keyword))
            @message_factory.test_failed(@test_name, "One or more steps were undefined")
          else
            @message_factory.test_failed(@test_name, "One of more steps failed")
        end

        @example_details.each{|m| @message_factory.puts m }
        @message_factory.message(example_result)
        @message_factory.test_finished(name)

        @message_factory.whitespace
      end
    end

    def feature_element_finish()
      @message_factory.output_messages
      @message_factory.test_suite_finished(@name)
    end

    private

    def format_table_cell_value(value, width, status=nil)
      status_msg = status==nil ? "" : " (#{status.to_s})"
      "| " + ((value.to_s || '') + "#{status_msg}").ljust(width+12)
    end
  end

 def before_feature(feature)

 end

  def after_feature(*args)
    @message_factory.test_suite_finished(@current_feature)
    @message_factory.whitespace
  end

  def feature_name(name)
    @current_feature=name.split("\n").first
    @message_factory.test_suite_started(@current_feature)
  end

  def before_feature_element(feature_element)
    @visitor_strategy = ScenarioOutlineStrategy.new(self, @message_factory) if feature_element.class == ::Cucumber::Ast::ScenarioOutline
    @visitor_strategy = ScenarioStrategy.new(self, @message_factory) if feature_element.class == ::Cucumber::Ast::Scenario
  end

   def after_feature_element(feature_element)
    @visitor_strategy.feature_element_finish
    @message_factory.whitespace
  end

  def scenario_name(keyword, name, file_colon_line, source_indent)
    feature_element_name=%Q(#{keyword} #{name})
    if @options[:source]
      feature_element_name=feature_element_name+' (@' + file_colon_line + ')'
    end

    @visitor_strategy.name=feature_element_name
    @visitor_strategy.feature_element_start
  end

  def before_step(step)
    @current_step=step

    step_name="#{step.keyword} #{step.name}"
    @visitor_strategy.step_start(step_name)
  end

   def after_step(step)
     step_name="#{step.keyword} #{step.name}"
    @visitor_strategy.step_finish(step_name)
  end

  def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
    # Oddly, cucumber 0.3.11 stops passing exception through if it's an Undefined exception. I don't know why.
    # We'll make it look like it has been reported
    if status == :undefined
      exception = @current_step.exception
    end


  end

  def step_name(keyword, step_match, status, source_indent, background)
    @visitor_strategy.step_details(keyword, step_match, status, source_indent, background)

  end

  def before_multiline_arg(multiline_arg)
    @table_strategy = @visitor_strategy.multiline_arg_table_strategy
  end
  def after_multiline_arg(multiline_arg)
    @table_strategy = nil
  end

  def exception(exception, status)
    snippet=''
    snippet=format_undef_step_snippet(exception.step_name, @current_step.multiline_arg, @current_step.keyword) if exception.class == ::Cucumber::Undefined
    @visitor_strategy.visit_exception(exception, status, snippet)
  end

  def examples_name(keyword, name)
    @visitor_strategy.examples_section_header(keyword, name)

  end

  def before_outline_table(outline_table)
    @table_strategy = @visitor_strategy.outline_table_strategy
  end
  def after_outline_table(outline_table)
    @table_strategy = nil
  end

  def before_table_row(table_row)
    @table_strategy.table_row_start(table_row)
  end
  
  def after_table_row(table_row)
    @table_strategy.table_row_finish(table_row)
  end

  def table_cell_value(value, width, status)
    @table_strategy.cell_value(value, width, status)
  end

  private

  # = Formating Methods

  def format_undef_step_snippet(step_name, step_multiline_arg, step_keyword)
    step_multiline_class = step_multiline_arg ? step_multiline_arg.class : nil
    snippet = @step_mother.snippet_text(step_keyword || "", step_name, step_multiline_class)

    "\n\nYou can implement step definitions for undefined steps with these snippets:\n\n#{snippet}"
  end

end
