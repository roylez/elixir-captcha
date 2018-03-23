defmodule Captcha.Controller do
  use Phoenix.Controller

  def show(conn, %{ "key" => key }) do
    captcha = Captcha.generate_and_cache(key)
    send_download(conn, {:binary, captcha}, filename: "captcha.gif")
  end
end
