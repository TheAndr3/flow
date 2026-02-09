defmodule Flow.Fleet.Alert do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "alerts" do
    field :type, :string
    field :description, :string
    field :resolved, :boolean, default: false
    belongs_to :vehicle, Flow.Fleet.Vehicle

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:type, :description, :resolved, :vehicle_id])
    |> validate_required([:type, :description, :resolved, :vehicle_id])
    |> foreign_key_constraint(:vehicle_id)
  end
end
