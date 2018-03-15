defmodule Stubby.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :stubby,
      version: @version,
      elixir: ">= 1.3.0",
      start_permanent: Mix.env == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    %{
      licenses: ["Apache 2"],
      maintainers: ["Dave Shah"],
      links: %{"GitHub" => "https://github.com/daveshah/stubby"}
    }
  end

  defp description do
    """
    A simple stubbing library 👍 .
    """
  end
end
