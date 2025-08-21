defmodule Autogentic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Autogentic.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Autogentic.Finch},
      # Core Autogentic services
      {Autogentic.Effects.Engine, [name: Autogentic.Effects.Engine]},
      {Autogentic.Reasoning.Engine, [name: Autogentic.Reasoning.Engine]},
      {Autogentic.Learning.Coordinator, [name: Autogentic.Learning.Coordinator]},
      # Agent management
      {Autogentic.Agent.Registry, []},
      {Autogentic.Agent.Supervisor, []},
      # Start the Endpoint (http/https)
      AutogenticWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Autogentic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AutogenticWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
