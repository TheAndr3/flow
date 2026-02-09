defmodule Flow.Fleet.Vehicle do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "vehicles" do
    field :license_plate, :string
    field :status, Ecto.Enum, values: [:active, :maintenance]

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:license_plate, :status])
    |> validate_required([:license_plate, :status])
    |> validate_inclusion(:status, [:active, :maintenance])
  end
end
