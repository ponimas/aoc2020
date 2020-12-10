from strformat import fmt

import re, streams, sequtils
from strutils import parseInt

proc solution*(fileStrm: FileStream) =
  let rx = re"(\d+)-(\d+)\s(\w):\s(\w+)"

  var
    line = ""
    firstValidCounter = 0
    secondValidCounter = 0

  while fileStrm.readLine(line):
    var matches: array[4, string];
    var charCounter: int = 0

    let
      _ = match(line, rx, matches)
      lower = parseInt(matches[0])
      higher = parseInt(matches[1])
      chr = matches[2]
      passwd = matches[3]

    # echo fmt"{lower=} {higher=} {chr=} {passwd=}"

    for ch in filter(passwd, proc(c: char): bool = $c == chr):
      inc charCounter

    if $passwd[lower - 1] == chr xor $passwd[higher - 1] == chr:
      inc secondValidCounter

    if lower <= charCounter and charCounter <= higher:
      inc firstValidCounter

  echo fmt"{firstValidCounter=}"
  echo fmt"{secondValidCounter=}"
