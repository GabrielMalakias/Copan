defmodule Copan.Consumers.AppointmentCreated do
  use Copan.Consumers.Base

  require IEx

  def start_link() do
    GenRMQ.Consumer.start_link(__MODULE__, name: __MODULE__)
  end

  def init() do
    [
      queue: "copan_appointment_created",
      exchange: "public",
      routing_key: ["appointments.v1.created"],
      uri: "amqp://guest:guest@localhost:5672",
      prefetch_count: "10",
      retry_delay_function: fn attempt -> :timer.sleep(2000 * attempt) end
    ]
  end

  def consumer_tag() do
    "appointment_created"
  end

  def execute(%GenRMQ.Message{payload: payload}) do
    payload
    |> Poison.decode
    |> Copan.Parsers.Broker.AppointmentCreated.call
    |> Copan.Commands.Appointment.Create.call
  end

  def handle_message(message) do
    try do
      execute(message)
      ack(message)
    rescue
      exception ->
        Logger.error(Exception.format(:error, exception, System.stacktrace()))
        reject(message, false)
    end
  end
end