defmodule App.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Store.Cuboid

  @doc """
  Returns the list of cuboids.

  ## Examples

      iex> list_cuboids()
      [%Cuboid{}, ...]

  """
  def list_cuboids do
    Repo.all(Cuboid) |> Repo.preload(:bag)
  end

  @doc """
  Gets a single cuboid.

  Raises if the Cuboid does not exist.

  ## Examples

      iex> get_cuboid!(123)
      %Cuboid{}

  """
  def get_cuboid(id), do: Repo.get(Cuboid, id) |> Repo.preload(:bag)

  @doc """
  Creates a cuboid.

  ## Examples

      iex> create_cuboid(%{field: value})
      {:ok, %Cuboid{}}

      iex> create_cuboid(%{field: bad_value})
      {:error, ...}

  """
  def create_cuboid(attrs \\ %{}) do
    %Cuboid{}
    |> Cuboid.changeset(attrs)
    |> Repo.insert()
  end

  def update_cuboid(cuboid, attrs \\ %{}) do
    cuboid
    |> Cuboid.changeset(attrs)
    |> Repo.update()
  end

  def delete_cuboid(cuboid) do
    Repo.delete(cuboid)
  end

  alias App.Store.Bag

  @doc """
  Returns the list of bags.

  ## Examples

      iex> list_bags()
      [%Bag{}, ...]

  """
  def list_bags do
    query = from(
      b in Bag,
      left_join: c in assoc(b, :cuboids),
      select_merge: %{
        payloadVolume: coalesce(sum(c.volume), 0),
        availableVolume: b.volume - coalesce(sum(c.volume), 0)
      },
      group_by: b.id,
      order_by: b.id
    )
    Repo.all(query) |> Repo.preload(:cuboids)
  end

  @doc """
  Gets a single bag.

  Raises if the Bag does not exist.

  ## Examples

      iex> get_bag!(123)
      %Bag{}

  """
  def get_bag(id) do
    query = from(
      b in Bag,
      where: b.id == ^id,
      left_join: c in assoc(b, :cuboids),
      select_merge: %{
        payloadVolume: coalesce(sum(c.volume), 0),
        availableVolume: b.volume - coalesce(sum(c.volume), 0)
      },
      group_by: b.id,
      order_by: b.id
    )
    Repo.one(query) |> Repo.preload(:cuboids)
  end

  @doc """
  Creates a bag.

  ## Examples

      iex> create_bag(%{field: value})
      {:ok, %Bag{}}

      iex> create_bag(%{field: bad_value})
      {:error, ...}

  """
  def create_bag(attrs \\ %{}) do
    %Bag{}
    |> Bag.changeset(attrs)
    |> Repo.insert()
  end

  def check_bag_size(bag_id, volume) do
    case get_bag(bag_id) do
      nil ->
        {:error, :not_exists}
      bag ->
        if bag.availableVolume < volume do
          {:error, :not_space}
        else
          {:ok, bag}
        end
    end
  end
end
