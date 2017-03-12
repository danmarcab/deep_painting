defmodule Studio.Painter.Pycasso do

  def start(_painting) do
    Port.open({:spawn, code}, [:binary, {:packet, 4}, :nouse_stdio, :exit_status])
  end

  defp ruby_code do
    ~S"""
      ruby -e '
        @input = IO.new(3)
        @output = IO.new(4)
        @output.sync = true

        def receive_input
          encoded_length = @input.read(4)
          return nil unless encoded_length
          length = encoded_length.unpack("N").first
          @input.read(length)
        end

        def send_response(response)
          @output.write([response.bytesize].pack("N"))
          @output.write(response)
          true
        end

        send_response("iter0: init")
        n = 0
        while (cmd = receive_input) do
          n += 1
          send_response("iter#{n}:" + cmd)
        end
      '
    """
  end

  defp code do
~S"""
  python -u -c '
import os
import struct
from time import sleep

input = 3
output = 4

def receive_input():
  encoded_length = os.read(input, 4)

  if encoded_length == "":
    return None
  else:
    (length, ) = struct.unpack(">I", encoded_length)
    return os.read(input, length)

def send_response(response):
  os.write(output, struct.pack(">I", len(response)))
  os.write(output, response)

send_response("iter0: init")
n = 0
while True:
  input_received = receive_input()
  if input_received == "CONT":
    n += 1
    send_response("iter#{n}: " + input_received)
  else:
    break
  sleep(0.001)
  ' 2> /dev/null
"""
  end
end
