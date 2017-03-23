defmodule WxHelper.Mixfile do
  use Mix.Project

  def project do
    [app: :wx_helper,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     name: "WxHelper",
     source_url: "https://github.com/rtvu/wx_helper",
     docs: [main: "readme", extras: ["README.md"]]]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end

  defp description do
    "A helper module for using wxErlang in Elixir."
  end

  defp package do
    [licenses: ["MIT License"],
     maintainers: [],
     links: %{"Github" => "https://github.com/rtvu/wx_helper"}]
  end
end
