defmodule Monopoly.MixProject do
  use Mix.Project

  def project do
    [
      app: :monopoly,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Monopoly.Game],
      deps: deps()
    ]
  end

  # log: :none | :basic | :all

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [log_level: :basic, default_turn: 50_000]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
