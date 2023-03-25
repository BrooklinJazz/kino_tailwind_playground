defmodule KinoTailwindPlayground.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_tailwind_playground,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
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
      {:kino, "~> 0.9"}
    ]
  end
end
