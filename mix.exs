defmodule WxHelper.Mixfile do
  use Mix.Project

  def project do
    [
      app: :wx_helper,
      version: "0.2.0-dev",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      description: description(),
      package: package(),
      deps: deps(),
      name: "WxHelper",
      source_url: "https://github.com/rtvu/wx_helper",
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp aliases do
    [
      clean: ["cmd elixir unmake.exs", "clean"],
      compile: ["cmd elixir make.exs", "compile"]
    ]
  end

  defp deps do
    []
  end

  defp description do
    "A helper module for using wxErlang in Elixir."
  end

  defp package do
    [
      licenses: ["MIT License"],
      maintainers: [],
      links: %{"Github" => "https://github.com/rtvu/wx_helper"}
    ]
  end
end
