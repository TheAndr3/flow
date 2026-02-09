defmodule Flow.Workers.AlertGenerator do
  use Oban.Worker, queue: :high_priority, max_attempts: 5

  alias Flow.Fleet
  @alerts_topic "alerts"

  @type args :: %{
          "vehicle_id" => String.t(),
          "speed" => number(),
          "timestamp" => String.t()
        }

  @spec perform(Oban.Job.t()) :: :ok | {:error, term()} | {:discard, term()}
  def perform(%Oban.Job{args: %{"vehicle_id" => vehicle_id, "speed" => speed, "timestamp" => timestamp}}) do
    with {:ok, datetime, _offset} <- DateTime.from_iso8601(timestamp) do
      description =
        "Speed limit exceeded: #{speed} km/h at #{DateTime.to_iso8601(datetime)}"

      case Fleet.create_alert(%{
             vehicle_id: vehicle_id,
             type: "SPEED_LIMIT_EXCEEDED",
             description: description,
             resolved: false
           }) do
        {:ok, alert} ->
          Phoenix.PubSub.broadcast(Flow.PubSub, @alerts_topic, {:alert_created, alert})
          :ok
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, _reason} -> {:discard, :invalid_timestamp}
    end
  end

  def perform(_job), do: {:discard, :invalid_args}
end
