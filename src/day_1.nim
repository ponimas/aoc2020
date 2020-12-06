from strformat import fmt # needed for debugprint

import streams

from strutils import parseInt, split
from algorithm import sort

proc solution*(strm: FileStream) =
  var ints = newSeq[int]()
  var line = ""

  while strm.readLine(line):
    ints.add(parseInt(line))

  ints.sort()

  for i in 0..ints.len():
    var y = ints.len() - 1
    while y > i:
      if ints[i] + ints[y] == 2020:
        echo fmt"{ints[i]} * {ints[y]} = {ints[i] * ints[y]}"
      dec y

  for i in 0..ints.len() - 1:
    for j in i..ints.len() - 1:
      for k in j..ints.len() - 1:
        if ints[i] + ints[j] + ints[k] > 2020:
          continue
        if ints[i] + ints[j] + ints[k] == 2020:
          echo fmt"{ints[i]} * {ints[j]} * {ints[k]} = {ints[i] * ints[j] * ints[k]}"


