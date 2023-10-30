defmodule EscapeTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Prove

  alias IO.ANSI

  doctest Escape

  batch "format" do
    prove format("hello") == "hello"
    prove format(["hello"]) == "hello"
    prove format(["he", "llo"]) == "hello"
    prove format(['he', 'llo']) == "hello"
    prove format(77) == "M"

    prove format([:green, "hello"]) ==
            "#{ANSI.green()}hello#{ANSI.reset()}"

    prove format([:light_green, "hello"]) ==
            "#{ANSI.light_green()}hello#{ANSI.reset()}"

    prove format([:green_background, "hello"]) ==
            "#{ANSI.green_background()}hello#{ANSI.reset()}"

    prove format([:green_background, "hello"]) ==
            "#{ANSI.green_background()}hello#{ANSI.reset()}"

    prove format([:light_green_background, "hello"]) ==
            "#{ANSI.light_green_background()}hello#{ANSI.reset()}"

    prove format([:light_green_background, "hello"]) ==
            "#{ANSI.light_green_background()}hello#{ANSI.reset()}"

    prove format([ANSI.color_background(55), "hello"]) ==
            "#{ANSI.color_background(55)}hello#{ANSI.reset()}"

    prove format([ANSI.color(3, 3, 3), "hello"]) ==
            "#{ANSI.color(3, 3, 3)}hello#{ANSI.reset()}"

    prove format([ANSI.color(55), "hello"], reset: false) ==
            "#{ANSI.color(55)}hello"

    prove format([ANSI.color_background(3, 3, 3), "hello"], reset: false) ==
            "#{ANSI.color_background(3, 3, 3)}hello"
  end

  batch "format nested list" do
    prove format(["Hello, ", [:red, "world!"]]) ==
            "Hello, #{ANSI.red()}world!#{ANSI.reset()}"

    prove format(["Hello, ", [:red, "world!"]], emit: false) ==
            "Hello, world!"

    prove format(["Hello, ", [ANSI.color(5), "world!"]]) ==
            "Hello, #{ANSI.color(5)}world!#{ANSI.reset()}"
  end

  batch "format with theme" do
    prove format([:orange, "hello"], theme: %{orange: ANSI.color(214)}) ==
            "#{ANSI.color(214)}hello#{ANSI.reset()}"

    prove format([:orange_background, "hello"],
            theme: %{orange: 214, orange_background: ANSI.color_background(214)}
          ) == "#{ANSI.color_background(214)}hello#{ANSI.reset()}"

    prove format([:blank, "hello", :blank], theme: %{blank: " "}, reset: false) == " hello "

    prove format([:green_reverse, "hello"],
            theme: %{green_reverse: [:green, :reverse]},
            reset: false
          ) == "#{ANSI.green()}#{ANSI.reverse()}hello"

    prove format([:bg333, "hello"],
            theme: %{bg333: ANSI.color_background(3, 3, 3)},
            reset: false
          ) == "#{ANSI.color_background(3, 3, 3)}hello"

    prove format([:error, "error"], theme: %{red: :green, error: :red}) ==
            "#{ANSI.green()}error#{ANSI.reset()}"
  end

  batch "format with emit: false" do
    prove format([:green_background, "hello"], emit: false) == "hello"

    prove format([ANSI.color(11), "hello"], emit: false) == "hello"
  end

  batch "format with theme and emit: false" do
    prove format([:orange, "hello"], theme: %{orange: 214}, emit: false) == "hello"

    prove format([:orange_background, "hello"],
            theme: %{orange: ANSI.color(214), orange_background: ANSI.color_background(214)},
            emit: false
          ) == "hello"

    prove format([:blank, "hello", :blank], theme: %{blank: ""}, emit: false) == "hello"
  end

  batch "puts/2 with chardata" do
    prove capture_io(fn -> Escape.puts("hello") end) == "hello\n"
    prove capture_io(fn -> Escape.puts(:hello) end) == "hello\n"
    prove capture_io(fn -> Escape.puts(["he", "llo"]) end) == "hello\n"
    prove capture_io(fn -> Escape.puts(13) end) == "13\n"
    prove capture_io(fn -> Escape.puts('hello') end) == "hello\n"
  end

  batch "puts/2 with sequence" do
    prove capture_io(fn -> Escape.puts([:red, "hello"]) end) ==
            "#{ANSI.red()}hello#{ANSI.reset()}\n"

    prove capture_io(fn -> Escape.puts([ANSI.color(55), "hello"]) end) ==
            "#{ANSI.color(55)}hello#{ANSI.reset()}\n"

    prove capture_io(fn -> Escape.puts([ANSI.color_background(55), "hello"]) end) ==
            "#{ANSI.color_background(55)}hello#{ANSI.reset()}\n"
  end

  batch "puts/2 with sequence and emit: false" do
    prove capture_io(fn -> Escape.puts([:red, "hello"], emit: false) end) ==
            "hello\n"

    prove capture_io(fn -> Escape.puts([ANSI.color_background(55), "hello"], emit: false) end) ==
            "hello\n"

    prove capture_io(fn -> Escape.puts([ANSI.color(55), "hello"], emit: false) end) ==
            "hello\n"
  end

  batch "write/2 with sequence" do
    prove capture_io(fn -> Escape.write("hello") end) == "hello"

    prove capture_io(fn -> Escape.write([:red, "hello"]) end) ==
            "#{ANSI.red()}hello#{ANSI.reset()}"

    prove capture_io(fn -> Escape.write([ANSI.color(55), "hello"]) end) ==
            "#{ANSI.color(55)}hello#{ANSI.reset()}"

    prove capture_io(fn -> Escape.write([ANSI.color_background(55), "hello"]) end) ==
            "#{ANSI.color_background(55)}hello#{ANSI.reset()}"
  end

  batch "write/2 with sequence and emit: false" do
    prove capture_io(fn -> Escape.write([:red, "hello"], emit: false) end) ==
            "hello"

    prove capture_io(fn -> Escape.write([ANSI.color(55), "hello"], emit: false) end) ==
            "hello"
  end

  prove "default_color", Escape.sequence(:default_color) == ANSI.default_color()
  prove "default_background", Escape.sequence(:default_background) == ANSI.default_background()

  test "sequences" do
    for sequence <- Escape.sequences() do
      assert Escape.sequence(sequence) == apply(ANSI, sequence, [])
    end
  end

  test "raises error for an unknown sequence" do
    message = "invalid sequence specification: :foo"

    assert_raise ArgumentError, message, fn -> Escape.format([:foo, "hello"]) end
  end

  test "raises error for a cyclic sequence" do
    message = "cyclic sequence specification: :foo"

    assert_raise ArgumentError, message, fn ->
      format([:foo, "bar"], theme: %{foo: :bar, bar: :foo})
    end
  end

  defp format(ansidata, opts \\ []) do
    ansidata |> Escape.format(opts) |> IO.iodata_to_binary()
  end
end
