defmodule Flow.Repo.Migrations.CreateTelemetryEvents do
  use Ecto.Migration

  def change do
    create table(:telemetry_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :speed, :float, null: false
      add :timestamp, :utc_datetime, null: false
      add :vehicle_id, references(:vehicles, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:telemetry_events, [:vehicle_id])
    create index(:telemetry_events, [:timestamp])
  end
end
