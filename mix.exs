defmodule XeroXero.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xeroxero,
      version: "0.7.1",
      elixir: "~> 1.10",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:req, "~> 0.5"},
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ecto, "~> 2.1 or ~> 3.0"}
    ]
  end

  defp description do
    """
    Xero API elixir SDK
    """
  end

  defp package do
    [
      maintainers: ["MJMortimer"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/handdii/elixero"}
    ]
  end
end
