defmodule Flow.FleetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Flow.Fleet` context.
  """

  @doc """
  Generate a vehicle.
  """
  def vehicle_fixture(attrs \\ %{}) do
    {:ok, vehicle} =
      attrs
      |> Enum.into(%{
        license_plate: "some license_plate",
        status: :active
      })
      |> Flow.Fleet.create_vehicle()

    vehicle
  end

  @doc """
  Generate a telemetry_event.
  """
  def telemetry_event_fixture(attrs \\ %{}) do
    vehicle_id = Map.get(attrs, :vehicle_id) || vehicle_fixture().id

    {:ok, telemetry_event} =
      attrs
      |> Enum.into(%{
        latitude: 120.5,
        longitude: 120.5,
        speed: 120.5,
        timestamp: ~U[2026-02-08 03:10:00Z],
        vehicle_id: vehicle_id
      })
      |> Flow.Fleet.create_telemetry_event()

    telemetry_event
  end

  @doc """
  Generate a alert.
  """
  def alert_fixture(attrs \\ %{}) do
    vehicle_id = Map.get(attrs, :vehicle_id) || vehicle_fixture().id

    {:ok, alert} =
      attrs
      |> Enum.into(%{
        description: "some description",
        resolved: true,
        type: "some type",
        vehicle_id: vehicle_id
      })
      |> Flow.Fleet.create_alert()

    alert
  end
end
