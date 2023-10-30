defmodule Escape do
  @moduledoc """
  Functionality to render ANSI escape sequences.

  This module is quite similar to the Elixir module `IO.ANSI`. For more info
  about [ANSI escape sequences](https://en.wikipedia.org/wiki/ANSI_escape_code),
  see the `IO.ANSI` documentation.

  For example, the function `IO.ANSI.format/1` and `Escape.format/1` working in
  the same way.

      iex> iodata = IO.ANSI.format([:green, "hello"])
      [[[[] | "\e[32m"], "hello"] | "\e[0m"]
      iex> iodata == Escape.format([:green, "hello"])
      true

  The `Escape` module adds the option `:theme` to `Escape.format/2`.

      iex> Escape.format([:say, "hello"], theme: %{say: :green})
      [[[[] | "\e[32m"], "hello"] | "\e[0m"]

  In the theme are ANSI escape sequeneces allowed.

      iex> Escape.format([:say, "hello"], theme: %{
      ...>   orange: IO.ANSI.color(178),
      ...>   say: :orange
      ...> })
      [[[[] | "\e[38;5;178m"], "hello"] | "\e[0m"]

  The theme can also contain further fromats.

      iex> theme = %{
      ...>   orange: IO.ANSI.color(5, 3, 0),
      ...>   gray_background: IO.ANSI.color_background(59),
      ...>   say: [:orange, :gray_background],
      ...>   blank: " "
      ...> }
      iex> Escape.format([:say, :blank, "hello", :blank], theme: theme)
      [[[[[[], [[] | "\e[38;5;214m"] | "\e[48;5;59m"] | " "], "hello"] | " "] | "\e[0m"]
      iex> Escape.format([:say, :blank, "hello", :blank], theme: theme, emit: false)
      [[], "hello"]

  See `Escape.format/2` for more info.
  """

  import Escape.Sequence

  @type ansicode :: atom
  @type ansidata :: ansilist | ansicode | binary
  @type ansilist ::
          maybe_improper_list(
            char | ansicode | binary | ansilist,
            binary | ansicode | []
          )

  named_colors = [
    :black,
    :red,
    :green,
    :yellow,
    :blue,
    :magenta,
    :cyan,
    :white
  ]

  colors =
    named_colors
    |> Enum.with_index()
    |> Enum.flat_map(fn {name, index} ->
      [
        {name, index + 30},
        {:"#{name}_background", index + 40},
        {:"light_#{name}", index + 90},
        {:"light_#{name}_background", index + 100}
      ]
    end)

  fonts =
    for font_n <- 1..9 do
      {:"font_#{font_n}", font_n + 10}
    end

  sequences =
    colors ++
      fonts ++
      [
        {:default_color, 39},
        {:default_background, 49},
        {:reset, 0},
        {:bright, 1},
        {:faint, 2},
        {:italic, 3},
        {:underline, 4},
        {:blink_slow, 5},
        {:blink_rapid, 6},
        {:inverse, 7},
        {:reverse, 7},
        {:conceal, 8},
        {:crossed_out, 9},
        {:primary_font, 10},
        {:normal, 22},
        {:not_italic, 23},
        {:no_underline, 24},
        {:blink_off, 25},
        {:inverse_off, 27},
        {:reverse_off, 27},
        {:framed, 51},
        {:encircled, 52},
        {:overlined, 53},
        {:not_framed_encircled, 54},
        {:not_overlined, 55},
        {:home, "", "H"}
      ]

  @sequences Enum.map(sequences, &elem(&1, 0))

  @doc """
  Returns a list of all available named ANSI sequences.
  """
  @spec sequences :: [ansicode]
  def sequences, do: @sequences

  @doc """
  Formats a named ANSI sequences into an ANSI sequence.

  The named sequences are represented by atoms.

  ## Examples

      iex> Escape.sequence(:reverse)
      "\e[7m"
  """
  @spec sequence(ansicode) :: String.t()
  def sequence(ansicode)

  Enum.map(sequences, fn
    {name, code} -> defsequence(name, code, "m")
    {name, code, terminator} -> defsequence(name, code, terminator)
  end)

  def sequence(ansicode) do
    raise ArgumentError, "invalid sequence specification: #{inspect(ansicode)}"
  end

  @doc """
  Writes `ansidata` to a `device`, similar to `write/2`, but adds a newline at
  the end.

  The device is passed to the function with the option `:device` in the opts and
  defaults to standard output.

  The function also accepts the same options as `Escape.format/2`.
  """
  @spec puts(ansidata, keyword) :: :ok
  def puts(ansidata, opts \\ [device: :stdio])

  def puts(ansidata, opts) when is_list(ansidata) do
    {device, opts} = Keyword.pop(opts, :device, :stdio)
    chardata = format(ansidata, opts)
    IO.puts(device, chardata)
  end

  def puts(ansidata, opts) do
    opts |> Keyword.get(:device, :stdio) |> IO.puts(ansidata)
  end

  @doc """
  Writes `ansidata` to a device.

  The device is passed to the function with the option `:device` in the opts and
  defaults to standard output.

  The function also accepts the same options as `Escape.format/2`.
  """
  @spec write(ansidata, keyword) :: :ok
  def write(ansidata, opts \\ [device: :stdio])

  def write(ansidata, opts) when is_list(ansidata) do
    {device, opts} = Keyword.pop(opts, :device, :stdio)
    chardata = format(ansidata, opts)
    IO.write(device, chardata)
  end

  def write(ansidata, opts) do
    opts |> Keyword.get(:device, :stdio) |> IO.write(ansidata)
  end

  @doc """
  Returns a function that accepts a string and a named sequence and returns
  iodata with the applied format.

  Accepts the same options as `format/2`.

  ## Examples

      iex> colorizer = Escape.colorizer(theme: %{say: :green})
      iex> colorizer.("hello", :say)
      [[[[] | "\e[32m"], "hello"] | "\e[0m"]
  """
  @spec colorizer(keyword) :: (String.t(), ansicode -> String.t())
  def colorizer(opts) do
    fn str, color ->
      format([color, str], opts)
    end
  end

  @doc """
  Returns a function that accepts a chardata-like argument and applies
  `Escape.format/2` with the argument and the given `opts`.

  ## Examples

      iex> formatter = Escape.formatter(theme: %{say: :green})
      iex> formatter.([:say, "hello"])
      [[[[] | "\e[32m"], "hello"] | "\e[0m"]
  """
  @spec formatter(keyword) :: (ansidata -> String.t())
  def formatter(opts) do
    fn ansidata ->
      format(ansidata, opts)
    end
  end

  @doc """
  Formats a chardata-like argument by converting named sequences into ANSI
  sequences.

  The named sequences are represented by atoms. The named sequences can be
  extended by a map for the option `:theme`.

  It will also append an `IO.ANSI.reset/0` to the chardata when a conversion is
  performed. If you don't want this behaviour, use the option `reset?: false`.

  The option `:emit` can be passed to enable or disable emitting ANSI codes.
  When false, no ANSI codes will be emitted. This option defaults to the return
  value of `IO.ANSI.enabled?/0`.

  ## Options

    * `:theme` a map that adds ANSI codes usable in the Chardata-like argument.
               The searching in the theme performs a deep search.

    * `:reset` append an `IO.ANSI.reset/0` when true.

    * `:emit` enables or disables emitting ANSI codes.

  ## Examples

      iex> theme = %{
      ...>   gainsboro: ANSI.color(4, 4, 4),
      ...>   orange: ANSI.color(5, 3, 0),
      ...>   aquamarine: ANSI.color(2, 5, 4),
      ...>   error: :red,
      ...>   debug: :orange,
      ...>   info: :gainsboro
      ...> }
      iex> Escape.format([:error, "error"], theme: theme)
      [[[[] | "\e[31m"], "error"] | "\e[0m"]
      iex> Escape.format([:info, "info"], theme: theme)
      [[[[] | "\e[38;5;188m"], "info"] | "\e[0m"]
      iex> Escape.format([:info, "info"], theme: theme, reset: false)
      [[[] | "\e[38;5;188m"], "info"]
      iex> Escape.format([:info, "info"], theme: theme, emit: false)
      [[], "info"]
  """
  @spec format(ansidata, keyword) :: IO.chardata()
  def format(ansidata, opts \\ [emit: IO.ANSI.enabled?(), reset: true]) do
    emit? = Keyword.get(opts, :emit, IO.ANSI.enabled?())
    reset = Keyword.get(opts, :reset, if(emit?, do: :maybe, else: false))
    theme = Keyword.get(opts, :theme)

    do_format(ansidata, [], [], emit?, reset, theme)
  end

  defp do_format([term | rest], rem, acc, emit?, reset, theme) do
    do_format(term, [rest | rem], acc, emit?, reset, theme)
  end

  defp do_format([], [next | rest], acc, emit?, reset, theme) do
    do_format(next, rest, acc, emit?, reset, theme)
  end

  defp do_format([], [], acc, _emit? = true, _reset = true, _theme) do
    [acc | sequence(:reset)]
  end

  defp do_format([], [], acc, _emit?, _reset, _theme) do
    acc
  end

  defp do_format(term, rem, acc, _emit? = true, reset, theme) when is_atom(term) do
    do_format([], rem, [acc | format_sequence(term, theme, [])], true, !!reset, theme)
  end

  defp do_format(term, rem, acc, _emit? = false, reset, theme) when is_atom(term) do
    do_format([], rem, acc, false, reset, theme)
  end

  defp do_format(term, rem, acc, _emit? = true, reset, theme) do
    do_format([], rem, [acc, term], true, reset?(term, reset), theme)
  end

  defp do_format(term, rem, acc, _emit? = false, _reset, theme) do
    acc = if sequence?(term), do: acc, else: [acc, term]
    do_format([], rem, acc, false, false, theme)
  end

  defp format_sequence(term, nil, _seen) when is_atom(term) do
    sequence(term)
  end

  defp format_sequence(term, theme, seen) when is_atom(term) and is_map(theme) do
    case Map.fetch(theme, term) do
      {:ok, seq} when is_binary(seq) ->
        seq

      {:ok, seq} when is_list(seq) ->
        do_format(seq, [], [], true, false, theme)

      {:ok, seq} when is_atom(seq) ->
        if seq in seen do
          raise ArgumentError, "cyclic sequence specification: #{inspect(term)}"
        else
          format_sequence(seq, theme, [seq | seen])
        end

      :error ->
        sequence(term)
    end
  end

  defp reset?(<<"\e[", _rest::binary>>, :maybe), do: true
  defp reset?(_term, reset), do: reset

  defp sequence?(<<"\e[", _rest::binary>>), do: true
  defp sequence?(_term), do: false
end
