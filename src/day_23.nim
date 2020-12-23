import math
import sequtils
import streams
import strutils
import tables
import sugar

from strformat import fmt

type
  Node = tuple
    prev: int
    next: int
  TableList = Table[int, Node]

proc `$`(data: TableList): string =
  var p = 1
  let l = collect(newSeq):
    for _ in data.keys():
      let pp = p
      p = data[p].next
      pp
  fmt"{l}"

proc solve(input: seq[int], moves: int = 10): seq[int] =
  var data: TableList = collect(initTable(1000)):
    for (i, v) in zip(toSeq(1 .. high(input)), input[1 .. ^1]):
      let node: Node = (input[i - 1], input[(i + 1) mod len(input)])
      {v: node}

  data[input[0]] = (input[^1], input[1])

  let minVal = input[input.minIndex()]
  let maxVal = input[input.maxIndex()]

  var current = input[0]

  for move in 1 .. moves:
    if moves <= 100:
      echo data
      
    var p = data[current]
    let selected = collect(newSeq):
      for _ in 1 .. 3:
        let pp = p.next
        p = data[pp]
        pp
        
    data[current].next = p.next

    var dest = current
    while true:
      dec dest
      if dest < minVal:
        dest = maxVal
      if not (dest in selected):
        break

    let oldNxt = data[dest].next

    data[dest].next = selected[0]
    data[selected[0]].prev = dest

    data[selected[^1]].next = oldNxt
    data[oldNxt].prev = selected[^1]

    current = data[current].next

  var x = 1

  return collect(newSeq):
    for _ in 0 .. high(input) - 1:
      x = data[x].next
      x

proc solution*(stream: FileStream) =
  let input = collect(newSeq):
    for c in stream.readLine():
      if c in Digits:
        parseInt($c)

  let maxVal = input[input.maxIndex()]
  let f = solve(input, 100).join("")
  echo fmt"first {f}"

  let huge = concat(input, toSeq((maxVal + 1) .. 1_000_000))
  let s = prod(solve(huge, 10_000_000)[0..1])
  echo fmt"second {s}"
