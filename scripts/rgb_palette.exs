Mix.install([{:escape, "~> 0.1"}])

per_line = 6

colors =
  for r <- 0..5,
      g <- 0..5,
      b <- 0..5 do
    text = " #{r}/#{g}/#{b} "
    color = if g < 3, do: :white, else: :black
    {text, %{color_background: IO.ANSI.color_background(r, g, b), color: color}}
  end

for {{text, theme}, index} <- Enum.with_index(colors, 1) do
  newline = if rem(index, per_line) == 0, do: "\n", else: ""
  Escape.write([:color, :color_background, text, :reset, newline], theme: theme)
end
