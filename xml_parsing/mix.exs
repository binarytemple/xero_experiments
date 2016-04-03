defmodule XmlParsing.Mixfile do
  use Mix.Project

  def project do
    [ app: :xml_parsing,
      version: "0.0.1",
      #elixir: "~> 0.11.3-dev",
      deps: deps ]
  end

  #Add add :remix as a development only OTP app.
  
  def application do
    [applications: applications(Mix.env)]
  end
  
  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:logger]

  ## Configuration for the OTP application
  #def application do
  #  [mod: { XmlParsing, [] }]
  #end

  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:erlsom, "~> 1.2.1" },
      {:remix, "~> 0.0.1", only: :dev}
    ]
  end


end
