import streams, strutils
from strformat import fmt
from algorithm import sort


proc first(data: seq[int]): int =
  var
    joltage = 0
    diffOne = 0
    diffThree = 0

  for adapter in data:
    let diff = adapter - joltage

    if diff == 1:
      inc diffOne
    if diff == 3:
      inc diffThree

    joltage = adapter

  inc diffThree
  return diffOne * diffThree

proc second(data: seq[int]): int =
  var track = newSeq[int](len(data))
  track[0] = 1

  for i in 0 .. high(data):
    for j in i + 1 .. min(i + 3, high(data)):
      if data[j] - data[i] <= 3:
        track[j] += track[i]
        
  return track[high(track)]


proc solution*(stream: FileStream) =
  var data: seq[int]

  for line in stream.lines():
    data.add(parseInt(line))

  data.add(0)
  sort(data)

  let f = first(data)
  let s = second(data)

  echo fmt"{f} {s}"

