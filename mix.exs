defmodule PureHTTP.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @maintainers ["Aaron Renner"]
  @source_url "https://github.com/aaronrenner/pure_http"

  def project do
    [
      app: :pure_http,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      dialyzer: dialyzer(),

      # Docs
      name: "PureHTTP",
      docs: docs(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
 #
  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.7.0"},

      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},

      {:bypass, "~> 0.8", only: [:test], runtime: false},
      {:stream_data, "~> 0.1", only: :test},
    ]
  end

  # Run "mix help docs" to learn about docs
  defp docs do
    [
      main: "PureHTTP",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp dialyzer do
    [
      ignore_warnings: ".dialyzer_ignore",
      plt_add_apps: [:ex_unit],
    ]
  end

  defp description do
    "Wrapper around HTTPPoison building requests and handling responses " <>
    "with pure functions"
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{
        "Github" => @source_url
      }
    ]
  end
end
