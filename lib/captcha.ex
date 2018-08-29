defmodule Captcha do
  use Application

  def start(_, _) do
    Captcha.Cache.start_link()
  end

  # allow customize receive timeout, default: 10_000
  def get() do
    cmd = Path.join(:code.priv_dir(:captcha), "captcha")
    { <<text::bytes-size(5), img::binary>>, _ } = System.cmd(cmd, [])

    {:ok, text, img }
  end

  def verify?(key, value) do
    case Captcha.Cache.get(key) do
      ^value -> :ok
      _ -> { :error, "invalid captcha" }
    end
  end

  def generate_and_cache(key) do
    { :ok, text, img } = get()
    Captcha.Cache.set(key, text)
    img
  end
end
