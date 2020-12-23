import lists
import algorithm
import math
import sequtils
import sets
import streams
import strutils
import tables
import sugar
import deques
import unpack

from strformat import fmt

proc solve_deque(inp: seq[int], moves: int = 10): seq[int] =
  var input = toDeque(inp)
  let l = len(inp)
  let minVal = inp[inp.minIndex()]
  let maxVal = inp[inp.maxIndex()]

  for _ in 1 .. moves:
    let current = input.popFirst()
    let selected = collect(newSeq):
      for _ in 1 .. 3:
        input.popFirst()

    # echo fmt"{selected}"
    var lbl = current
    while true:
      dec lbl
      if lbl < minVal:
        lbl = maxVal
      if not (lbl in selected):
        break

    # echo fmt"{lbl}"
    input.addLast(current)

    var tmp = initDeque[int]()

    while true:
      let y = input.popFirst()
      tmp.addLast(y)

      if y == lbl:
        for i in reversed(selected):
          input.addFirst(i)

        while len(tmp) > 0:
          input.addFirst(tmp.popLast())
        break

  while input.peekFirst() != 1:
    input.addLast(input.popFirst())

  input.popFirst()
  toSeq(input)


proc solve_ring(input: seq[int], moves: int = 10): seq[int] =
  var ring = initDoublyLinkedRing[int]()

  let minVal = input[input.minIndex()]
  let maxVal = input[input.maxIndex()]

  var current = newDoublyLinkedNode[int](input[0])
  ring.append(current)

  for i in input[1 .. ^1]:
    ring.append(i)

  for move in 1 .. moves:
    var n = current
    let selected = collect(newSeq):
      for _ in 1 .. 3:
        n = n.next
        n

    var selectedValues: seq[int]
    for n in selected:
      selectedValues.add(n.value)
      ring.remove(n)

    # echo fmt"{selectedValues=}"

    var lbl = current.value

    while true:
      dec lbl
      if lbl < minVal:
        lbl = maxVal
      if not (lbl in selectedValues):
        break

    ring.head = ring.find(lbl).next

    for s in selectedValues:
      ring.append(s)

    current = current.next

  let one = ring.find(1)
  ring.head = one
  # echo fmt"{ring}"
  toSeq(ring)

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
    var n = data[current]
    let selected = collect(newSeq):
      for _ in 1 .. 3:
        let v = n.next
        n = data[v]
        v

    data[current].next = n.next
    var lbl = current

    while true:
      dec lbl
      if lbl < minVal:
        lbl = maxVal
      if not (lbl in selected):
        break

    let oldNxt = data[lbl].next

    data[lbl].next = selected[0]
    data[selected[0]].prev = lbl

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
