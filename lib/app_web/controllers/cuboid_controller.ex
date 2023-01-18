defmodule AppWeb.CuboidController do
  use AppWeb, :controller

  alias App.Store
  alias App.Store.Cuboid

  action_fallback AppWeb.FallbackController

  def index(conn, _params) do
    cuboids = Store.list_cuboids()
    render(conn, "index.json", cuboids: cuboids)
  end

  def create(conn, cuboid_params) do
    with {:ok, %Cuboid{} = cuboid} <- Store.create_cuboid(cuboid_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.cuboid_path(conn, :show, cuboid))
      |> render("show.json", cuboid: cuboid)
    end
  end

  def show(conn, %{"id" => id}) do
    case Store.get_cuboid(id) do
      nil -> conn |> send_resp(404, "")
      cuboid -> render(conn, "show.json", cuboid: cuboid)
    end
  end

  def update(conn, %{"id" => id} = cuboid_params) do
    case Store.get_cuboid(id) do
      nil -> conn |> send_resp(404, "")
      cuboid ->
        with {:ok, %Cuboid{} = cuboid} <- Store.update_cuboid(cuboid, cuboid_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.cuboid_path(conn, :update, cuboid))
          |> render("show.json", cuboid: cuboid)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Store.get_cuboid(id) do
      nil -> conn |> send_resp(404, "")
      cuboid ->
        with {:ok, _} <- Store.delete_cuboid(cuboid) do
          conn
          |> put_status(200)
          |> put_resp_header("location", Routes.cuboid_path(conn, :delete, cuboid))
          |> render("show.json", cuboid: cuboid)
        end
      end
  end
end
