defmodule Agcp.MixProject do
  use Mix.Project

  def project do
    [
      app: :agcp,
      version: "0.1.0",
      elixir: "~> 1.10-rc",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Agcp.CLI, name: "agcp"],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.16", only: [:dev], runtime: false},
      {:clipboard, "~> 0.2.1"}
    ]
  end
end
