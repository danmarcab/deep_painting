defmodule Studio.Painter.TestPycasso do

  def start(_painting) do
    Port.open({:spawn, code}, [:binary, {:packet, 4}, :nouse_stdio, :exit_status])
  end

  defp code() do
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

send_response("{\"iteration\": 0, \"file_name\": \"file0.png\", \"loss\": \"3.00\"}")
n = 0
while True:
  input_received = receive_input()
  if input_received == "CONT":
    n += 1
    send_response("{\"iteration\": " +  str(n) + ", \"file_name\": \"file.png\", \"loss\": \"3.13\"}")
  else:
    break
  sleep(0.001)
  ' 2> /dev/null
"""
  end
end
