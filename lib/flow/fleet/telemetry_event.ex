defmodule Flow.Fleet.TelemetryEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "telemetry_events" do
    field :latitude, :float
    field :longitude, :float
    field :speed, :float
    field :timestamp, :utc_datetime
    belongs_to :vehicle, Flow.Fleet.Vehicle

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(telemetry_event, attrs) do
    telemetry_event
    |> cast(attrs, [:latitude, :longitude, :speed, :timestamp, :vehicle_id])
    |> validate_required([:latitude, :longitude, :speed, :timestamp, :vehicle_id])
    |> foreign_key_constraint(:vehicle_id)
  end
end
