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
    |> cast(attrs, [:type, :description, :resolved])
    |> put_vehicle_id(attrs)
    |> validate_required([:type, :description, :resolved, :vehicle_id])
    |> foreign_key_constraint(:vehicle_id)
  end

  defp put_vehicle_id(changeset, attrs) do
    vehicle_id =
      case attrs do
        %{} -> Map.get(attrs, :vehicle_id) || Map.get(attrs, "vehicle_id")
        _ -> nil
      end

    if is_nil(vehicle_id) do
      changeset
    else
      put_change(changeset, :vehicle_id, vehicle_id)
    end
  end
end
