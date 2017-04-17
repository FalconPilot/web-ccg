defmodule Webccg.PageController do
  use Webccg.Web, :controller
  alias Webccg.Repo

  # Default page rendering
  def display(conn, url) do
    conn
      |> assign(:loginset, User.changeset(%User{}))
      |> render(url)
  end

  # Site index
  def index(conn, _params) do
    display(conn, "index.html")
  end

  # Userlist display
  def userlist(conn, _params) do
    conn
      |> assign(:userlist, Repo.all(User))
      |> display("userlist.html")
  end

  # Single user display
  def user(conn, %{"id" => user_id}) do
    case Integer.parse(user_id) do
      {id, _point} ->
        case Repo.get_by(User, id: id) do
          nil ->
            conn
              |> put_flash(:error, "Utilisateur inconnu")
              |> redirect(to: "/users")
          user ->
            cards = CardHelpers.get_cards(user.cards)
            conn
              |> assign(:pageuser, user)
              |> assign(:pagecards, cards)
              |> display("profile.html")
        end
      :error ->
        conn
          |> put_flash(:error, "URL invalide")
          |> redirect(to: "/users")
    end
  end

  # Cardlist display
  def cardlist(conn, _params) do
    query = from(c in Card, order_by: c.rarity)
    conn
      |> assign(:cardlist, Repo.all(query))
      |> assign_admin(:cardform, Card.changeset(%Card{}))
      |> display("cardlist.html")
  end

  # Assign if admin
  defp assign_admin(conn, key, value) do
    case get_session(conn, :current_user) do
      nil ->
        conn
      user ->
        if user.privilege >= 3 do
          conn |> assign(key, value)
        else
          conn
        end
    end
  end
end
