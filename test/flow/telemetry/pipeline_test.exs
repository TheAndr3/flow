defmodule Flow.Telemetry.PipelineTest do
  use Flow.DataCase, async: false

  alias Broadway.Message
  alias Flow.Fleet
  alias Flow.Fleet.TelemetryEvent
  alias Flow.Repo
  alias Flow.Telemetry.Pipeline

  import Ecto.Query

  setup do
    {:ok, vehicle} =
      Fleet.create_vehicle(%{
        license_plate: "FLOW-999",
        status: :active
      })

    %{vehicle: vehicle}
  end

  test "handle_batch inserts telemetry and enqueues alerts for speed violations", %{vehicle: vehicle} do
    timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

    messages = [
      %Message{
        data: %{
          vehicle_id: vehicle.id,
          latitude: 1.0,
          longitude: 2.0,
          speed: 90.5,
          timestamp: timestamp
        }
      }
    ]

    Pipeline.handle_batch(:default, messages, %{}, %{})

    assert Repo.aggregate(TelemetryEvent, :count) == 1

    job = Repo.one(from j in Oban.Job, select: j)
    assert job.queue == "high_priority"
    assert job.args["vehicle_id"] == vehicle.id
  end

  test "handle_batch ignores alerts below threshold", %{vehicle: vehicle} do
    timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

    messages = [
      %Message{
        data: %{
          vehicle_id: vehicle.id,
          latitude: 1.0,
          longitude: 2.0,
          speed: 55.0,
          timestamp: timestamp
        }
      }
    ]

    Pipeline.handle_batch(:default, messages, %{}, %{})

    assert Repo.aggregate(Oban.Job, :count) == 0
  end
end
