defmodule Captcha do
  use Application

  def start(_, _) do
    Captcha.Cache.start_link()
  end

  def get(path \\ Application.app_dir(Application.get_application(__MODULE__),"priv/captcha")) do
    Port.open({:spawn, path}, [:binary])
    receive do
      {_, {:data, data}} ->
        <<text::bytes-size(5), img::binary>> = data
        {:ok, text, img }
      other -> other
    after
      1_000 -> { :timeout }
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
