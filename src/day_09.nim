import streams, strutils
from strformat import fmt
from algorithm import binarySearch, lowerBound, sorted


proc first(data: seq[int], preambleLen: int): int =
  let preambleHigh = preambleLen - 1
  var preamble = sorted(data[0 .. preambleHigh])

  for i in preambleLen .. high(data):
    var found = false
    let num = data[i]

    for x in preamble:
      found = 0 <= binarySearch(preamble, num - x)
      if found: break

    if not found:
      return num

    preamble.delete(binarySearch(preamble, data[i - preambleLen]))
    insert(preamble, num, lowerBound(preamble, num))

proc second(data: seq[int], num: int): int =
  for i in 0 .. high(data):
    var x = data[i]

    for j in i + 1 .. high(data):
      x += data[j]
      if x > num: break

      if x == num:
        let l = sorted(data[i .. j])
        return l[0] + l[high(l)]



proc solution*(stream: FileStream) =
  var
    data: seq[int]



  for line in stream.lines():
    data.add(parseInt(line))

  let f = first(data, 25)
  let s = second(data, f)

  echo fmt"{f} {s}"

