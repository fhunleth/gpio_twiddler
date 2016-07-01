defmodule GpioTwiddler.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "bbb"

  def project do
    [app: :gpio_twiddler,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "0.1.3"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:elixir_make] ++ Mix.compilers,
     make_clean: ["clean"],
     aliases: aliases(),
     deps: deps() ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {GpioTwiddler, []},
     applications: [:nerves, :logger, :elixir_ale]]
  end

  def deps do
    [{:nerves, "~> 0.3.0"}]
  end

  def system(target) do
    [{:"nerves_system_#{target}", github: "nerves-project/nerves_system_#{target}", branch: "pre"},
     {:elixir_make, "~> 0.3"},
     {:elixir_ale, "~> 0.5.4"}
    ]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
