defmodule Captcha.Cache do
  use GenServer

  @ttl 120

  def init(_) do
    table = :ets.new(:captcha_cache, [:set, :named_table])
    Process.send_after(self(), :timer, 1)
    { :ok, table }
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get(captcha_key), do: GenServer.call(__MODULE__, {:get, captcha_key})

  def set(captcha_key, value), do: GenServer.cast(__MODULE__, {:set, captcha_key, value})

  # cache_key found
  def handle_call({:get, key}, _from, table) do
    case :ets.lookup(table, key) do
      [ { ^key, { value, _expiry }} ] ->
        :ets.delete(table, key)
        { :reply, value, table }
      _ ->
        { :reply, nil, table }
    end
  end

  def handle_cast({:set, key, value}, table) do
    time = :os.system_time(:second)
    :ets.insert( table, { key, { value, time } } )
    { :noreply, table }
  end

  # delete anything that was saved @ttl ago
  def handle_info(:timer, table) do
    cutoff = :os.system_time(:second) - @ttl
    :ets.select_delete(table,
                       [{{ :_, {:_, :"$1"}  }, [{:"<", :"$1", cutoff}], [true]}])
    Process.send_after(self(), :timer, 1000)
    { :noreply, table }
  end

end
