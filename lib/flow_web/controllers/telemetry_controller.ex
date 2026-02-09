defmodule FlowWeb.TelemetryController do
  use FlowWeb, :controller

  alias Flow.Telemetry.Pipeline

  def create(conn, %{"events" => events}) when is_list(events) do
    if Enum.all?(events, &is_map/1) do
      :ok = Pipeline.enqueue(events)

      conn
      |> put_status(:accepted)
      |> json(%{status: "accepted", count: length(events)})
    else
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "events must be a list of maps"})
    end
  end

  def create(conn, params) when is_map(params) do
    :ok = Pipeline.enqueue(params)

    conn
    |> put_status(:accepted)
    |> json(%{status: "accepted", count: 1})
  end
end
