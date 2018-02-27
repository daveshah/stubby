defmodule Stubby.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :stubby,
      version: @version,
      elixir: ">= 1.3.0",
      start_permanent: Mix.env == :prod,
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    %{
      licenses: ["Apache 2"],
      maintainers: ["Dave Shah"],
      links: %{"GitHub" => "https://github.com/daveshah/stubby"}
    }
  end
end
