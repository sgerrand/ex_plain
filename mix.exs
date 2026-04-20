defmodule ExPlain.MixProject do
  use Mix.Project

  @repo_url "https://github.com/sgerrand/ex_plain"
  @version "0.1.0"

  def project do
    [
      app: :ex_plain,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: package(),
      description: description(),
      source_url: @repo_url,

      # Docs
      name: "ExPlain",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:plug, "~> 1.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir client for the Plain GraphQL API"
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end

  defp package do
    [
      licenses: ["BSD-2-Clause"],
      links: %{
        "GitHub" => @repo_url,
        "Changelog" => "https://hexdocs.pm/ex_plain/changelog.html"
      }
    ]
  end
end
