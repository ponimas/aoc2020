import algorithm
import deques
import math
import re
import sequtils
import streams
import strutils

from strformat import fmt


proc precedenceOne(numbers: var Deque[int], ops: var seq[string]): int =
  var res = numbers.popFirst()
  for op in ops:
    if op == "*":
      res *= numbers.popFirst()
    else:
      res += numbers.popFirst()
  return res

proc precedenceTwo(numbers: var Deque[int], ops: var seq[string]): int =
  numbers.addLast(numbers.popFirst())
  for op in ops:
    if op == "+":
      numbers.addLast(numbers.popLast() + numbers.popFirst())
    else:
      numbers.addLast(numbers.popFirst())
  return prod(toSeq(numbers))


proc solve(e: seq[string], precedence: proc (n: var Deque[int], o: var seq[string]): int): int =
  var
    tokens = reversed(e)
    numbers: Deque[int]
    ops: seq[string]

  # echo "SOLVE ", tokens
  while len(tokens) > 0:
    let token = tokens.pop()
    if token == "(":
      var
        paren = 1
        subeq: seq[string]

      while true:
        let token = tokens.pop()
        if token == ")":
          dec paren
          if paren == 0:
            numbers.addLast(solve(subeq, precedence))
            break
        elif token == "(":
          inc paren
        subeq.add(token)
    elif token == "+" or token == "*":
       ops.add(token)
    else:
      numbers.addLast(parseInt(token))
  return precedence(numbers, ops)

  
proc solution*(stream: FileStream) =
  let rx = re"(\d+|\(|\)|\+|\*)"
  # io.readLines()
  let input = toSeq(stream.lines()).mapIt(it.findAll(rx))
  
  let f = sum(input.mapIt(solve(it, precedenceOne)))
  echo fmt"first {f}"

  let s = sum(input.mapIt(solve(it, precedenceTwo)))
  echo fmt"second {s}"

