# frozen_string_literal: true

module Haml::Filters::Styleguide
  include Haml::Filters::Base

  def compile(compiler, text)
    code = <<~EXAMPLE
      %div.styleguide-variant
        %pre.styleguide-code
          :plain
            #{Haml::Helpers.preserve(Haml::Helpers.html_escape(text))}
        %div.styleguide-example
      #{text.indent(4)}
EXAMPLE

    parsed = Haml::Parser.new(code.strip, compiler.options).parse
    compiler.compile(parsed)
  end
end
