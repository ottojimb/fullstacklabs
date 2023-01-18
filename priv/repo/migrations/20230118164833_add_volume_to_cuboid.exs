defmodule App.Repo.Migrations.AddVolumeToCuboid do
  use Ecto.Migration

  def change do
    alter table(:cuboids) do
      add :volume, :integer, null: false
    end
  end
end
