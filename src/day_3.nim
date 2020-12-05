from strformat import fmt
import re, streams, sequtils

proc thirdDay*(fileStream: FileStream) =
  var
    forest = newSeq[string]()
    line = ""
    y = 0
    counters: array[5, int]
    xs: array[5, int]

  let moves = [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]]

  while fileStream.readLine(line):
    for ix, move in moves:
      if y mod move[1] != 0: continue
      if line[xs[ix]] == '#': inc counters[ix]
      xs[ix] = (xs[ix] + move[0]) mod len(line)
    inc y

  let mul = foldl(counters, a * b)
  echo fmt"{counters=} {xs=} {mul=}"

