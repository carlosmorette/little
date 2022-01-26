defmodule Little.Repo do
  use Ecto.Repo,
    otp_app: :little,
    adapter: Ecto.Adapters.Postgres
end
