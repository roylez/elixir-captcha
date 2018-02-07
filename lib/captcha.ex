defmodule Captcha do
  def get(path\\Application.app_dir(Application.get_application(__MODULE__),"priv/captcha")) do
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
end
