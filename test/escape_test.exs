defmodule EscapeTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Prove

  alias IO.ANSI

  if IO.ANSI.enabled?(), do: doctest(Escape)

  batch "format" do
    prove format("hello") == "hello"
    prove format(["hello"]) == "hello"
    prove format(["he", "llo"]) == "hello"
    prove format([~c"he", ~c"llo"]) == "hello"
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
    prove format("hello", theme: %{}) == "hello"

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

  batch "format overwrites known sequences" do
    prove format([:reset], theme: %{reset: :white}, reset: false) ==
            format([:white], reset: false)

    prove format([:green, :red], theme: %{green: :white, red: :white}, reset: false) ==
            format([:white, :white], reset: false)
  end

  batch "puts/2 with chardata" do
    prove capture_io(fn -> Escape.puts("hello", emit: true) end) == "hello\n"
    prove capture_io(fn -> Escape.puts(:hello, emit: true) end) == "hello\n"
    prove capture_io(fn -> Escape.puts(["he", "llo"], emit: true) end) == "hello\n"
    prove capture_io(fn -> Escape.puts(13, emit: true) end) == "13\n"
    prove capture_io(fn -> Escape.puts(~c"hello", emit: true) end) == "hello\n"
  end

  batch "puts/2 with sequence" do
    prove capture_io(fn -> Escape.puts([:red, "hello"], emit: true) end) ==
            "#{ANSI.red()}hello#{ANSI.reset()}\n"

    prove capture_io(fn -> Escape.puts([ANSI.color(55), "hello"], emit: true) end) ==
            "#{ANSI.color(55)}hello#{ANSI.reset()}\n"

    prove capture_io(fn -> Escape.puts([ANSI.color_background(55), "hello"], emit: true) end) ==
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
    prove capture_io(fn -> Escape.write("hello", emit: true) end) == "hello"

    prove capture_io(fn -> Escape.write([:red, "hello"], emit: true) end) ==
            "#{ANSI.red()}hello#{ANSI.reset()}"

    prove capture_io(fn -> Escape.write([ANSI.color(55), "hello"], emit: true) end) ==
            "#{ANSI.color(55)}hello#{ANSI.reset()}"

    prove capture_io(fn -> Escape.write([ANSI.color_background(55), "hello"], emit: true) end) ==
            "#{ANSI.color_background(55)}hello#{ANSI.reset()}"
  end

  batch "write/2 with sequence and emit: false" do
    prove capture_io(fn -> Escape.write([:red, "hello"], emit: false) end) ==
            "hello"

    prove capture_io(fn -> Escape.write([ANSI.color(55), "hello"], emit: false) end) ==
            "hello"
  end

  batch "color_doc/2" do
    prove color_doc("hello", :ok) == "hello"

    prove "hello" |> color_doc(:ok, theme: %{ok: :green}) |> render_doc ==
            "\e[32mhello\e[0m"

    prove "hello" |> color_doc(:ok, theme: %{ok: :green, reset: :red}) |> render_doc() ==
            "\e[32mhello\e[31m"
  end

  prove "default_color", Escape.sequence(:default_color) == ANSI.default_color()
  prove "default_background", Escape.sequence(:default_background) == ANSI.default_background()

  test "sequences" do
    for sequence <- Escape.sequences() do
      assert Escape.sequence(sequence) == apply(ANSI, sequence, [])
    end
  end

  describe "format/2" do
    test "raises error for an unknown sequence" do
      message = "invalid sequence specification: :foo"

      assert_raise ArgumentError, message, fn -> Escape.format([:foo, "hello"], emit: true) end
    end

    test "raises error for a cyclic sequence" do
      message = "cyclic sequence specification: :foo"

      assert_raise ArgumentError, message, fn ->
        format([:foo, "bar"], theme: %{foo: :bar, bar: :foo})
      end
    end
  end

  describe "split_at/2" do
    prove Escape.split_at("foobar", 3) == String.split_at("foobar", 3)
    prove Escape.split_at("foo", 0) == {"", "foo"}
    prove Escape.split_at("foo", 0) == {"", "foo"}
    prove Escape.split_at("foo", 10) == {"foo", ""}
    prove Escape.split_at("", 10) == {"", ""}
    prove Escape.split_at("\e[0m", 0) == {"", "\e[0m"}
    prove Escape.split_at("\e[0m", 1) == {"\e[0m", ""}
    prove Escape.split_at("a\e[0m", 0) == {"", "a\e[0m"}
    prove Escape.split_at("a\e[0m", 1) == {"a", "\e[0m"}
    prove Escape.split_at("a\e[0m", 2) == {"a\e[0m", ""}

    test "splits a string with sequences" do
      string =
        [:red, "red", :green, "green"]
        |> Escape.format(reset: false, emit: true)
        |> IO.iodata_to_binary()

      assert Escape.split_at(string, 2) == {"\e[31mre", "d\e[32mgreen"}
      assert Escape.split_at(string, 3) == {"\e[31mred", "\e[32mgreen"}
      assert Escape.split_at(string, 4) == {"\e[31mred\e[32mg", "reen"}

      length = Escape.length(string) + 1

      for at <- 0..length do
        assert {left, right} = Escape.split_at(string, at), "split fails at #{at}"
        assert left <> right == string, "split fails at #{at}: #{inspect(left <> right)}"
      end
    end

    test "splits a string with sequences and sequence at the end" do
      string =
        [:red, "red", :green, "green"]
        |> Escape.format(emit: true)
        |> IO.iodata_to_binary()

      assert Escape.split_at(string, 2) == {"\e[31mre", "d\e[32mgreen\e[0m"}
      assert Escape.split_at(string, 3) == {"\e[31mred", "\e[32mgreen\e[0m"}
      assert Escape.split_at(string, 4) == {"\e[31mred\e[32mg", "reen\e[0m"}
      assert Escape.split_at(string, 7) == {"\e[31mred\e[32mgree", "n\e[0m"}
      assert Escape.split_at(string, 8) == {"\e[31mred\e[32mgreen", "\e[0m"}
      assert Escape.split_at(string, 9) == {"\e[31mred\e[32mgreen\e[0m", ""}

      length = Escape.length(string) + 1

      for at <- 0..length do
        assert {left, right} = Escape.split_at(string, at), "split fails at #{at}"
        assert left <> right == string, "split fails at #{at}: #{inspect(left <> right)}"
      end
    end

    test "splits a string with several sequences one after the other" do
      string =
        [:red, "red", :green, :reverse, "green"]
        |> Escape.format(reset: false, emit: true)
        |> IO.iodata_to_binary()

      assert Escape.split_at(string, 2) == {"\e[31mre", "d\e[32m\e[7mgreen"}
      assert Escape.split_at(string, 3) == {"\e[31mred", "\e[32m\e[7mgreen"}
      assert Escape.split_at(string, 4) == {"\e[31mred\e[32m\e[7mg", "reen"}

      length = Escape.length(string) + 1

      for at <- 0..length do
        assert {left, right} = Escape.split_at(string, at), "split fails at #{at}"
        assert left <> right == string, "split fails at #{at}: #{inspect(left <> right)}"
      end
    end

    test "with long string" do
      string =
        [:red, "red", :green, :reverse, "green", :blue, "blue"]
        |> List.duplicate(100)
        |> Escape.format(reset: false)
        |> IO.iodata_to_binary()

      length = Escape.length(string) + 1

      # assert Escape.split_at(string, 1000) == {"", ""}

      for at <- 0..length do
        assert {left, right} = Escape.split_at(string, at), "split fails at #{at}"
        assert left <> right == string, "split fails at #{at}: #{inspect(left <> right)}"
      end
    end
  end

  defp format(ansidata, opts \\ []) do
    opts = Keyword.put_new(opts, :emit, true)
    ansidata |> Escape.format(opts) |> IO.iodata_to_binary()
  end

  defp color_doc(doc, ansicode, opts \\ []) do
    opts = Keyword.put_new(opts, :emit, true)
    Escape.color_doc(doc, ansicode, opts)
  end

  defp render_doc(doc), do: doc |> Inspect.Algebra.format(80) |> IO.iodata_to_binary()
end
