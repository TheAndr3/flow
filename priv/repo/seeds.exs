# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Flow.Repo.insert!(%Flow.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Flow.Fleet

vehicles =
	Fleet.list_vehicles()
	|> Enum.map(& &1.license_plate)
	|> MapSet.new()

plates =
	1..10
	|> Enum.map(fn index -> "FLOW-" <> String.pad_leading(Integer.to_string(index), 3, "0") end)

Enum.each(plates, fn plate ->
	if MapSet.member?(vehicles, plate) do
		:ok
	else
		{:ok, _vehicle} =
			Fleet.create_vehicle(%{
				license_plate: plate,
				status: :active
			})
	end
end)

IO.puts("Seeded #{length(plates)} vehicles (skipping existing).")
