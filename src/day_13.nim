import algorithm
import lists
import math
import re
import sequtils
import streams
import strutils
import sugar
import tables

from strformat import fmt

proc first(estimation: int, table: seq[string]): int =
  let buses = collect(newSeq):
    for bus in table:
      if bus != "x": parseInt(bus)
  let waitTimes = buses.mapIt(it - (estimation mod it))
  let i = waitTimes.minIndex()
  return buses[i] * waitTimes[i]


proc second(table: seq[string]): int64 =
  let buses = collect(newSeq):
    for pos, bus in table.pairs():
      if bus != "x":
        parseInt(bus)
      else:
        1

  var
    inc = buses[0]
    idx = 1
    timestamp = inc

  while idx < len(buses):
    if (timestamp + idx) mod buses[idx] == 0:
      # this is the key operation
      inc *= buses[idx]

      inc idx
    else:
      timestamp += inc

  return timestamp


proc solution*(stream: FileStream) =
  let estimation = parseInt(stream.readLine())
  let buses = stream.readLine().split(",")

  echo first(estimation, buses)
  echo second(buses)
