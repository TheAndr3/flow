defmodule Flow.Workers.AlertGeneratorTest do
  use Flow.DataCase, async: false

  alias Flow.Fleet
  alias Flow.Workers.AlertGenerator

  setup do
    {:ok, vehicle} =
      Fleet.create_vehicle(%{
        license_plate: "FLOW-777",
        status: :active
      })

    %{vehicle: vehicle}
  end

  test "perform creates alert for valid args", %{vehicle: vehicle} do
    timestamp = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()

    job = %Oban.Job{
      args: %{
        "vehicle_id" => vehicle.id,
        "speed" => 99.9,
        "timestamp" => timestamp
      }
    }

    assert :ok = AlertGenerator.perform(job)

    [alert] = Fleet.list_alerts()
    assert alert.type == "SPEED_LIMIT_EXCEEDED"
    assert alert.vehicle_id == vehicle.id
  end

  test "perform discards invalid timestamp", %{vehicle: vehicle} do
    job = %Oban.Job{
      args: %{
        "vehicle_id" => vehicle.id,
        "speed" => 85.0,
        "timestamp" => "invalid"
      }
    }

    assert {:discard, :invalid_timestamp} = AlertGenerator.perform(job)
  end

  test "perform discards invalid args" do
    assert {:discard, :invalid_args} = AlertGenerator.perform(%Oban.Job{args: %{}})
  end
end
