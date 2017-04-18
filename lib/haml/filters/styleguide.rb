module Haml::Filters::Styleguide
  include Haml::Filters::Base

  def compile(compiler, text)
    parsed = Haml::Parser.new(<<-EXAMPLE, compiler.options).parse
%pre.styleguide-example
  :plain
    #{text}
#{text}
    EXAMPLE
    compiler.compile(parsed)
  end
end
