defmodule Flow.Repo do
  use Ecto.Repo,
    otp_app: :flow,
    adapter: Ecto.Adapters.Postgres
end
