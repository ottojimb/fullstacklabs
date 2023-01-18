defmodule App.Store.Cuboid do
  @moduledoc """
  This module defines the Cuboid schema.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias App.Store

  schema "cuboids" do
    field :depth, :integer
    field :height, :integer
    field :width, :integer
    field :volume, :integer
    belongs_to :bag, App.Store.Bag

    timestamps()
  end

  def validate_bag_size(changeset, bag_id, volume) do
    case Store.check_bag_size(bag_id, volume) do
      {:error, :not_space} -> changeset |> add_error(:volume, "Insufficient space in bag")
      _ -> changeset
    end
  end

  def get_bag_size(%{changes: %{bag_id: bag_id, volume: volume}} = changeset, _) do
    validate_bag_size(changeset, bag_id, volume)
  end

  def get_bag_size(%{changes: %{volume: volume}} = changeset, %{bag_id: bag_id}) do
    validate_bag_size(changeset, bag_id, volume)
  end

  def get_bag_size(changeset, _), do: changeset

  def set_volume(%{changes: %{width: width, height: height, depth: depth}} = changeset) do
    changeset|>put_change(:volume, width * height * depth)
  end

  def set_volume(changeset), do: changeset

  @doc false
  def changeset(cuboid, attrs) do
    cuboid
    |> cast(attrs, [:width, :height, :depth, :bag_id, :volume])
    |> set_volume()
    |> get_bag_size(cuboid)
    |> validate_required([:width, :height, :depth, :volume])
    |> cast_assoc(:bag, require: true)
    |> assoc_constraint(:bag, require: true)
  end
end
