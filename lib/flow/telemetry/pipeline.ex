defmodule Flow.Telemetry.Pipeline do
  use Broadway

  alias Broadway.Message
  alias Flow.Fleet.TelemetryEvent
  alias Flow.Repo

  @batch_size 50
  @batch_timeout 500

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [module: {Broadway.DummyProducer, []}],
      processors: [default: [concurrency: System.schedulers_online()]],
      batchers: [default: [batch_size: @batch_size, batch_timeout: @batch_timeout]]
    )
  end

  @spec enqueue(map() | [map()]) :: :ok
  def enqueue(events) when is_list(events) do
    messages = Enum.map(events, &%Message{data: &1})
    Broadway.push_messages(__MODULE__, messages)
    :ok
  end

  def enqueue(event) when is_map(event), do: enqueue([event])

  @impl true
  def handle_message(_, %Message{data: data} = message, _) do
    case normalize_event(data) do
      {:ok, attrs} -> Message.put_data(message, attrs)
      {:error, reason} -> Message.failed(message, reason)
    end
  end

  @impl true
  def handle_batch(_, messages, _, _) do
    entries =
      messages
      |> Enum.reject(&(&1.status == :failed))
      |> Enum.map(& &1.data)

    case entries do
      [] ->
        :ok

      _ ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        rows =
          Enum.map(entries, fn attrs ->
            Map.merge(attrs, %{inserted_at: now, updated_at: now})
          end)

        Repo.insert_all(TelemetryEvent, rows)
    end

    messages
  end

  defp normalize_event(attrs) when is_map(attrs) do
    with {:ok, vehicle_id} <- get_attr(attrs, :vehicle_id),
         {:ok, latitude} <- get_attr(attrs, :latitude),
         {:ok, longitude} <- get_attr(attrs, :longitude),
         {:ok, speed} <- get_attr(attrs, :speed),
         {:ok, timestamp} <- get_attr(attrs, :timestamp),
         {:ok, vehicle_id} <- cast_uuid(vehicle_id),
         {:ok, latitude} <- cast_float(latitude),
         {:ok, longitude} <- cast_float(longitude),
         {:ok, speed} <- cast_float(speed),
         {:ok, timestamp} <- cast_timestamp(timestamp) do
      {:ok,
       %{
         vehicle_id: vehicle_id,
         latitude: latitude,
         longitude: longitude,
         speed: speed,
         timestamp: timestamp
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_attr(attrs, key) when is_atom(key) do
    string_key = Atom.to_string(key)

    cond do
      Map.has_key?(attrs, key) -> {:ok, Map.get(attrs, key)}
      Map.has_key?(attrs, string_key) -> {:ok, Map.get(attrs, string_key)}
      true -> {:error, {:missing, key}}
    end
  end

  defp cast_uuid(value) do
    case Ecto.UUID.cast(value) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> {:error, {:invalid, :vehicle_id}}
    end
  end

  defp cast_float(value) when is_float(value), do: {:ok, value}
  defp cast_float(value) when is_integer(value), do: {:ok, value * 1.0}

  defp cast_float(value) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> {:ok, number}
      _ -> {:error, {:invalid, :float}}
    end
  end

  defp cast_float(_value), do: {:error, {:invalid, :float}}

  defp cast_timestamp(%DateTime{} = value), do: {:ok, value}

  defp cast_timestamp(%NaiveDateTime{} = value) do
    case DateTime.from_naive(value, "Etc/UTC") do
      {:ok, datetime} -> {:ok, datetime}
      {:error, _reason} -> {:error, {:invalid, :timestamp}}
    end
  end

  defp cast_timestamp(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> {:ok, datetime}
      {:error, _reason} -> {:error, {:invalid, :timestamp}}
    end
  end

  defp cast_timestamp(_value), do: {:error, {:invalid, :timestamp}}
end
