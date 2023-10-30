Mix.install([{:escape, "~> 0.1"}])

per_line =  8

for code <- 0..255 do
  color = %{color_background: IO.ANSI.color_background(code)}
  text = code |> to_string() |> String.pad_leading(4) |> String.pad_trailing(5)
  newline = if rem(code + 1, per_line) == 0, do: "\n", else: ""

  Escape.write(
    [ :white, :color_background, text, :black, text, :reset, newline ],
    theme: color
  )
end
