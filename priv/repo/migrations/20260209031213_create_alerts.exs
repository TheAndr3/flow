defmodule Flow.Repo.Migrations.CreateAlerts do
  use Ecto.Migration

  def change do
    create table(:alerts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :description, :string, null: false
      add :resolved, :boolean, default: false, null: false
      add :vehicle_id, references(:vehicles, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:alerts, [:vehicle_id])
  end
end
