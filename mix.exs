defmodule Stubby.Mixfile do
  use Mix.Project

  @version "0.2.0"

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
    A simple stubbing library that aligns with http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/ and attempts to support earlier versions of Elixir.
    """
  end
end
