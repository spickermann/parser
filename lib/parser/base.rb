module Parser
  class Base < Racc::Parser
    def self.parse(string, file='(string)', line=1)
      source_file = SourceFile.new(file, line)
      source_file.source = string

      new.parse(source_file)
    end

    attr_reader :static_env

    def initialize(builder=Parser::Builders::Sexp.new)
      @static_env = StaticEnvironment.new

      @lexer = Lexer.new(version)
      @lexer.static_env = @static_env

      @builder = builder
      @builder.parser = self

      reset
    end

    def version
      raise NotImplementedError, "implement #{self.class}#version"
    end

    def reset
      @source_file = nil
      @def_level   = 0 # count of nested def's.

      @lexer.reset
      @static_env.reset

      self
    end

    def parse(source_file)
      @source_file  = source_file
      @lexer.source = source_file.source

      do_parse
    end

    def in_def?
      @def_level > 0
    end

    protected

    def value_expr(v)
      p 'value_expr', v
      v
    end

    def arg_blk_pass(v1, v2)
      p 'arg_blk_pass', v1, v2
      v1
    end

    def next_token
      @lexer.advance
    end

    def on_error(error_token_id, error_value, value_stack)
      # TODO: emit a diagnostic
      super
    end
  end
end
