defmodule Monopelix.MixProject do
  use Mix.Project

  def project do
    [
      app: :monopelixx,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Monopelix.Escript],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [log_level: :basic, default_turn: 50_000]
    ]
  end
end
