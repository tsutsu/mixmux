defmodule Mixmux.Mixfile do
  use Mix.Project

  def project do
    [app: :mixmux,
     version: "0.1.0",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end
