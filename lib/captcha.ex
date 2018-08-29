defmodule Captcha do
  use Application

  def start(_, _) do
    Captcha.Cache.start_link()
  end

  # allow customize receive timeout, default: 10_000
  def get(timeout \\ 1_000) do
    port = Port.open({:spawn, Path.join(:code.priv_dir(:captcha), "captcha")}, [:binary])

    # Allow set receive timeout
    receive do
      {^port, {:data, data}} ->
        <<text::bytes-size(5), img::binary>> = data
        {:ok, text, img }
    after timeout ->
      {:timeout}
    end
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
