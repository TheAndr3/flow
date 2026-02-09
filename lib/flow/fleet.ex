defmodule Flow.Fleet do
  @moduledoc """
  The Fleet context.
  """

  import Ecto.Query, warn: false
  alias Flow.Repo

  alias Flow.Fleet.Vehicle

  @doc """
  Returns the list of vehicles.

  ## Examples

      iex> list_vehicles()
      [%Vehicle{}, ...]

  """
  @spec list_vehicles() :: [Vehicle.t()]
  def list_vehicles do
    Repo.all(Vehicle)
  end

  @doc """
  Gets a single vehicle.

  Raises `Ecto.NoResultsError` if the Vehicle does not exist.

  ## Examples

      iex> get_vehicle!(123)
      %Vehicle{}

      iex> get_vehicle!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_vehicle!(Ecto.UUID.t()) :: Vehicle.t()
  def get_vehicle!(id), do: Repo.get!(Vehicle, id)

  @doc """
  Creates a vehicle.

  ## Examples

      iex> create_vehicle(%{field: value})
      {:ok, %Vehicle{}}

      iex> create_vehicle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_vehicle(map()) :: {:ok, Vehicle.t()} | {:error, Ecto.Changeset.t()}
  def create_vehicle(attrs) do
    %Vehicle{}
    |> Vehicle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vehicle.

  ## Examples

      iex> update_vehicle(vehicle, %{field: new_value})
      {:ok, %Vehicle{}}

      iex> update_vehicle(vehicle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_vehicle(Vehicle.t(), map()) :: {:ok, Vehicle.t()} | {:error, Ecto.Changeset.t()}
  def update_vehicle(%Vehicle{} = vehicle, attrs) do
    vehicle
    |> Vehicle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vehicle.

  ## Examples

      iex> delete_vehicle(vehicle)
      {:ok, %Vehicle{}}

      iex> delete_vehicle(vehicle)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_vehicle(Vehicle.t()) :: {:ok, Vehicle.t()} | {:error, Ecto.Changeset.t()}
  def delete_vehicle(%Vehicle{} = vehicle) do
    Repo.delete(vehicle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vehicle changes.

  ## Examples

      iex> change_vehicle(vehicle)
      %Ecto.Changeset{data: %Vehicle{}}

  """
  @spec change_vehicle(Vehicle.t(), map()) :: Ecto.Changeset.t()
  def change_vehicle(%Vehicle{} = vehicle, attrs \\ %{}) do
    Vehicle.changeset(vehicle, attrs)
  end

  alias Flow.Fleet.TelemetryEvent

  @doc """
  Returns the list of telemetry_events.

  ## Examples

      iex> list_telemetry_events()
      [%TelemetryEvent{}, ...]

  """
  @spec list_telemetry_events() :: [TelemetryEvent.t()]
  def list_telemetry_events do
    Repo.all(TelemetryEvent)
  end

  @spec list_recent_telemetry_events(pos_integer()) :: [TelemetryEvent.t()]
  def list_recent_telemetry_events(limit \\ 25) do
    TelemetryEvent
    |> order_by([t], desc: t.timestamp)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets a single telemetry_event.

  Raises `Ecto.NoResultsError` if the Telemetry event does not exist.

  ## Examples

      iex> get_telemetry_event!(123)
      %TelemetryEvent{}

      iex> get_telemetry_event!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_telemetry_event!(Ecto.UUID.t()) :: TelemetryEvent.t()
  def get_telemetry_event!(id), do: Repo.get!(TelemetryEvent, id)

  @doc """
  Creates a telemetry_event.

  ## Examples

      iex> create_telemetry_event(%{field: value})
      {:ok, %TelemetryEvent{}}

      iex> create_telemetry_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_telemetry_event(map()) :: {:ok, TelemetryEvent.t()} | {:error, Ecto.Changeset.t()}
  def create_telemetry_event(attrs) do
    %TelemetryEvent{}
    |> TelemetryEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a telemetry_event.

  ## Examples

      iex> update_telemetry_event(telemetry_event, %{field: new_value})
      {:ok, %TelemetryEvent{}}

      iex> update_telemetry_event(telemetry_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_telemetry_event(TelemetryEvent.t(), map()) ::
          {:ok, TelemetryEvent.t()} | {:error, Ecto.Changeset.t()}
  def update_telemetry_event(%TelemetryEvent{} = telemetry_event, attrs) do
    telemetry_event
    |> TelemetryEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a telemetry_event.

  ## Examples

      iex> delete_telemetry_event(telemetry_event)
      {:ok, %TelemetryEvent{}}

      iex> delete_telemetry_event(telemetry_event)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_telemetry_event(TelemetryEvent.t()) ::
          {:ok, TelemetryEvent.t()} | {:error, Ecto.Changeset.t()}
  def delete_telemetry_event(%TelemetryEvent{} = telemetry_event) do
    Repo.delete(telemetry_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking telemetry_event changes.

  ## Examples

      iex> change_telemetry_event(telemetry_event)
      %Ecto.Changeset{data: %TelemetryEvent{}}

  """
  @spec change_telemetry_event(TelemetryEvent.t(), map()) :: Ecto.Changeset.t()
  def change_telemetry_event(%TelemetryEvent{} = telemetry_event, attrs \\ %{}) do
    TelemetryEvent.changeset(telemetry_event, attrs)
  end

  alias Flow.Fleet.Alert

  @doc """
  Returns the list of alerts.

  ## Examples

      iex> list_alerts()
      [%Alert{}, ...]

  """
  @spec list_alerts() :: [Alert.t()]
  def list_alerts do
    Repo.all(Alert)
  end

  @spec list_active_alerts(pos_integer()) :: [Alert.t()]
  def list_active_alerts(limit \\ 20) do
    Alert
    |> where([a], a.resolved == false)
    |> order_by([a], desc: a.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets a single alert.

  Raises `Ecto.NoResultsError` if the Alert does not exist.

  ## Examples

      iex> get_alert!(123)
      %Alert{}

      iex> get_alert!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_alert!(Ecto.UUID.t()) :: Alert.t()
  def get_alert!(id), do: Repo.get!(Alert, id)

  @doc """
  Creates a alert.

  ## Examples

      iex> create_alert(%{field: value})
      {:ok, %Alert{}}

      iex> create_alert(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_alert(map()) :: {:ok, Alert.t()} | {:error, Ecto.Changeset.t()}
  def create_alert(attrs) do
    %Alert{}
    |> Alert.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a alert.

  ## Examples

      iex> update_alert(alert, %{field: new_value})
      {:ok, %Alert{}}

      iex> update_alert(alert, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_alert(Alert.t(), map()) :: {:ok, Alert.t()} | {:error, Ecto.Changeset.t()}
  def update_alert(%Alert{} = alert, attrs) do
    alert
    |> Alert.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a alert.

  ## Examples

      iex> delete_alert(alert)
      {:ok, %Alert{}}

      iex> delete_alert(alert)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_alert(Alert.t()) :: {:ok, Alert.t()} | {:error, Ecto.Changeset.t()}
  def delete_alert(%Alert{} = alert) do
    Repo.delete(alert)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking alert changes.

  ## Examples

      iex> change_alert(alert)
      %Ecto.Changeset{data: %Alert{}}

  """
  @spec change_alert(Alert.t(), map()) :: Ecto.Changeset.t()
  def change_alert(%Alert{} = alert, attrs \\ %{}) do
    Alert.changeset(alert, attrs)
  end
end
