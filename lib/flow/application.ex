defmodule Flow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlowWeb.Telemetry,
      Flow.Repo,
      {Oban, Application.fetch_env!(:flow, Oban)},
      {DNSCluster, query: Application.get_env(:flow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Flow.PubSub},
      Flow.Telemetry.Pipeline,
      # Start a worker by calling: Flow.Worker.start_link(arg)
      # {Flow.Worker, arg},
      # Start to serve requests, typically the last entry
      FlowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Flow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
