defmodule Flow.FleetTest do
  use Flow.DataCase

  alias Flow.Fleet

  describe "vehicles" do
    alias Flow.Fleet.Vehicle

    import Flow.FleetFixtures

    @invalid_attrs %{status: nil, license_plate: nil}

    test "list_vehicles/0 returns all vehicles" do
      vehicle = vehicle_fixture()
      assert Fleet.list_vehicles() == [vehicle]
    end

    test "get_vehicle!/1 returns the vehicle with given id" do
      vehicle = vehicle_fixture()
      assert Fleet.get_vehicle!(vehicle.id) == vehicle
    end

    test "create_vehicle/1 with valid data creates a vehicle" do
      valid_attrs = %{status: :active, license_plate: "some license_plate"}

      assert {:ok, %Vehicle{} = vehicle} = Fleet.create_vehicle(valid_attrs)
      assert vehicle.status == :active
      assert vehicle.license_plate == "some license_plate"
    end

    test "create_vehicle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleet.create_vehicle(@invalid_attrs)
    end

    test "update_vehicle/2 with valid data updates the vehicle" do
      vehicle = vehicle_fixture()
      update_attrs = %{status: :maintenance, license_plate: "some updated license_plate"}

      assert {:ok, %Vehicle{} = vehicle} = Fleet.update_vehicle(vehicle, update_attrs)
      assert vehicle.status == :maintenance
      assert vehicle.license_plate == "some updated license_plate"
    end

    test "update_vehicle/2 with invalid data returns error changeset" do
      vehicle = vehicle_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleet.update_vehicle(vehicle, @invalid_attrs)
      assert vehicle == Fleet.get_vehicle!(vehicle.id)
    end

    test "delete_vehicle/1 deletes the vehicle" do
      vehicle = vehicle_fixture()
      assert {:ok, %Vehicle{}} = Fleet.delete_vehicle(vehicle)
      assert_raise Ecto.NoResultsError, fn -> Fleet.get_vehicle!(vehicle.id) end
    end

    test "change_vehicle/1 returns a vehicle changeset" do
      vehicle = vehicle_fixture()
      assert %Ecto.Changeset{} = Fleet.change_vehicle(vehicle)
    end
  end

  describe "telemetry_events" do
    alias Flow.Fleet.TelemetryEvent

    import Flow.FleetFixtures

    @invalid_attrs %{timestamp: nil, speed: nil, latitude: nil, longitude: nil, vehicle_id: nil}

    test "list_telemetry_events/0 returns all telemetry_events" do
      telemetry_event = telemetry_event_fixture()
      assert Fleet.list_telemetry_events() == [telemetry_event]
    end

    test "get_telemetry_event!/1 returns the telemetry_event with given id" do
      telemetry_event = telemetry_event_fixture()
      assert Fleet.get_telemetry_event!(telemetry_event.id) == telemetry_event
    end

    test "create_telemetry_event/1 with valid data creates a telemetry_event" do
      vehicle = vehicle_fixture()
      valid_attrs = %{
        timestamp: ~U[2026-02-08 03:10:00Z],
        speed: 120.5,
        latitude: 120.5,
        longitude: 120.5,
        vehicle_id: vehicle.id
      }

      assert {:ok, %TelemetryEvent{} = telemetry_event} = Fleet.create_telemetry_event(valid_attrs)
      assert telemetry_event.timestamp == ~U[2026-02-08 03:10:00Z]
      assert telemetry_event.speed == 120.5
      assert telemetry_event.latitude == 120.5
      assert telemetry_event.longitude == 120.5
    end

    test "create_telemetry_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleet.create_telemetry_event(@invalid_attrs)
    end

    test "update_telemetry_event/2 with valid data updates the telemetry_event" do
      telemetry_event = telemetry_event_fixture()
      update_attrs = %{timestamp: ~U[2026-02-09 03:10:00Z], speed: 456.7, latitude: 456.7, longitude: 456.7}

      assert {:ok, %TelemetryEvent{} = telemetry_event} = Fleet.update_telemetry_event(telemetry_event, update_attrs)
      assert telemetry_event.timestamp == ~U[2026-02-09 03:10:00Z]
      assert telemetry_event.speed == 456.7
      assert telemetry_event.latitude == 456.7
      assert telemetry_event.longitude == 456.7
    end

    test "update_telemetry_event/2 with invalid data returns error changeset" do
      telemetry_event = telemetry_event_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleet.update_telemetry_event(telemetry_event, @invalid_attrs)
      assert telemetry_event == Fleet.get_telemetry_event!(telemetry_event.id)
    end

    test "delete_telemetry_event/1 deletes the telemetry_event" do
      telemetry_event = telemetry_event_fixture()
      assert {:ok, %TelemetryEvent{}} = Fleet.delete_telemetry_event(telemetry_event)
      assert_raise Ecto.NoResultsError, fn -> Fleet.get_telemetry_event!(telemetry_event.id) end
    end

    test "change_telemetry_event/1 returns a telemetry_event changeset" do
      telemetry_event = telemetry_event_fixture()
      assert %Ecto.Changeset{} = Fleet.change_telemetry_event(telemetry_event)
    end
  end

  describe "alerts" do
    alias Flow.Fleet.Alert

    import Flow.FleetFixtures

    @invalid_attrs %{type: nil, description: nil, resolved: nil, vehicle_id: nil}

    test "list_alerts/0 returns all alerts" do
      alert = alert_fixture()
      assert Fleet.list_alerts() == [alert]
    end

    test "get_alert!/1 returns the alert with given id" do
      alert = alert_fixture()
      assert Fleet.get_alert!(alert.id) == alert
    end

    test "create_alert/1 with valid data creates a alert" do
      vehicle = vehicle_fixture()
      valid_attrs = %{type: "some type", description: "some description", resolved: true, vehicle_id: vehicle.id}

      assert {:ok, %Alert{} = alert} = Fleet.create_alert(valid_attrs)
      assert alert.type == "some type"
      assert alert.description == "some description"
      assert alert.resolved == true
    end

    test "create_alert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleet.create_alert(@invalid_attrs)
    end

    test "update_alert/2 with valid data updates the alert" do
      alert = alert_fixture()
      update_attrs = %{type: "some updated type", description: "some updated description", resolved: false}

      assert {:ok, %Alert{} = alert} = Fleet.update_alert(alert, update_attrs)
      assert alert.type == "some updated type"
      assert alert.description == "some updated description"
      assert alert.resolved == false
    end

    test "update_alert/2 with invalid data returns error changeset" do
      alert = alert_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleet.update_alert(alert, @invalid_attrs)
      assert alert == Fleet.get_alert!(alert.id)
    end

    test "delete_alert/1 deletes the alert" do
      alert = alert_fixture()
      assert {:ok, %Alert{}} = Fleet.delete_alert(alert)
      assert_raise Ecto.NoResultsError, fn -> Fleet.get_alert!(alert.id) end
    end

    test "change_alert/1 returns a alert changeset" do
      alert = alert_fixture()
      assert %Ecto.Changeset{} = Fleet.change_alert(alert)
    end
  end
end
