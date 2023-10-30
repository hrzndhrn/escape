defmodule Escape.Sequence do
  @moduledoc false

  defmacro defsequence(name, code, terminator) do
    quote bind_quoted: [name: name, code: code, terminator: terminator] do
      def sequence(unquote(name)) do
        "\e[#{unquote(code)}#{unquote(terminator)}"
      end
    end
  end
end
