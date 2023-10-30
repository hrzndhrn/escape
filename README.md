# Escape

[![Hex.pm: version](https://img.shields.io/hexpm/v/escape.svg?style=flat-square)](https://hex.pm/packages/escape)
[![GitHub: CI status](https://img.shields.io/github/actions/workflow/status/hrzndhrn/escape/ci.yml?branch=main&style=flat-square)](https://github.com/hrzndhrn/escape/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://github.com/hrzndhrn//blob/main/LICENSE.md)

The `Escape` module provides functionality to render ANSI escape sequences.

The module is similar to `IO.ANSI` but add a theme option to `Escape.format/2`.

Documentation can be found at [https://hexdocs.pm/escape](https://hexdocs.pm/escape).

## Installation

The package can be installed by adding `escape` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:escape, "~> 0.1"}
  ]
end
```

## Examples

![Examples](examples.png)
