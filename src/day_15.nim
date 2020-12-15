import re, streams, strutils, sequtils, lists, bitops, tables, sugar, math, unicode
from strformat import fmt

proc game(input: seq[int], step: int): int =
  var
    last = input[^1]
    seen = collect(initTable(len(input))):
      for i, x in input.pairs():
        {x: (i + 1, i + 1)}

  for _ in len(input) .. (step - 1):
    let
      (prevSeen, lastSeen) = seen[last]
      next = lastSeen - prevSeen
      turn = lastSeen + 1
    # echo fmt"{last=} {seen[last]}"

    seen[next] =
      if next in seen:
        (seen[next][1], turn)
      else:
        (turn, turn)
    last = next

  return last


proc solution*(stream: FileStream) =
  let input = readLine(stream).split(",").mapIt(parseInt(it))

  let f = game(input, 2020)
  echo fmt"first {f}"
  let s = game(input, 30_000_000)
  echo fmt"second {s}"

