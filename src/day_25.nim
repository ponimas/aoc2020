import sequtils
import streams
import strutils
from strformat import fmt


let DIVIDER = 20201227

proc findLoopSize(pkey: int, subj: int = 7): int =
  var e = 1
  var l = 1
  while true:
    e = (e * subj) mod DIVIDER
    if e == pkey:
      return l
    inc l

proc findEncKey(pkey: int, loopSz: int): int =
  var e = 1
  for l in 1 .. loopSz:
    e = (e * pkey) mod DIVIDER
  return e


proc solution*(stream: FileStream) =
  let
    pkeys = toSeq(stream.lines()).mapIt(parseInt(it))
    cardPKey = pkeys[0]
    doorPKey = pkeys[1]

    cardLoopSize = findLoopSize(cardPKey)
    encKey = findEncKey(doorPKey, cardLoopSize)

  echo fmt"{encKey=}"

