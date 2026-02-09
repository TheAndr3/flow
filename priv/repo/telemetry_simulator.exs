Mix.Task.run("app.start")

alias Flow.Fleet

api_url = System.get_env("FLOW_API_URL", "http://localhost:4000/api/telemetry")
interval_ms = System.get_env("FLOW_SIM_INTERVAL_MS", "500") |> String.to_integer()
vehicle_count = System.get_env("FLOW_SIM_VEHICLE_COUNT", "10") |> String.to_integer()

vehicles =
  case Fleet.list_vehicles() do
    [] ->
      Enum.map(1..vehicle_count, fn index ->
        plate = "FLOW-" <> String.pad_leading(Integer.to_string(index), 3, "0")

        {:ok, vehicle} =
          Fleet.create_vehicle(%{
            license_plate: plate,
            status: :active
          })

        vehicle
      end)

    existing ->
      existing
  end

IO.puts("Starting telemetry simulator for #{length(vehicles)} vehicles -> #{api_url}")

random_float = fn min, max ->
  min + :rand.uniform() * (max - min)
end

loop = fn loop_fun ->
  events =
    Enum.map(vehicles, fn vehicle ->
      %{
        vehicle_id: vehicle.id,
        latitude: random_float.(-23.7, -23.4),
        longitude: random_float.(-46.8, -46.4),
        speed: random_float.(40.0, 120.0),
        timestamp: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()
      }
    end)

  case Req.post(api_url, json: %{events: events}) do
    {:ok, %{status: status}} when status in 200..299 ->
      :ok

    {:ok, response} ->
      IO.puts("Non-2xx response: #{response.status}")

    {:error, reason} ->
      IO.inspect(reason, label: "Request error")
  end

  Process.sleep(interval_ms)
  loop_fun.(loop_fun)
end

loop.(loop)
