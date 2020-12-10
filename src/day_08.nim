import streams, strutils, sets
from strformat import fmt

proc simulation(programm: seq[(string, int)]): (bool, int) =
  var
    pos = 0
    accumulator = 0
    visited: HashSet[int]

  while pos != high(programm):
    if visited.containsOrIncl(pos):
      return (false, accumulator)

    let (command, arg) = programm[pos]

    case command:
      of "acc":
        accumulator += arg
        pos += 1
      of "jmp":
        pos += arg
      of "nop":
        pos += 1

  return (true, accumulator)


proc solution*(stream: FileStream) =
  var programm: seq[(string, int)]

  for line in stream.lines():
    let command = line[0 .. 2]
    let arg = parseInt(line[4 .. high(line)])
    programm.add((command, arg))

  let (_, acc) = simulation(programm)
  echo fmt"first {acc=}"

  for pos in 0 .. high(programm):
    let (command, arg) = programm[pos]
    if command == "acc": continue

    var mut = programm

    case command:
      of "jmp":
        mut[pos] = ("nop", arg)
      of "nop":
        mut[pos] = ("jmp", arg)
      of "acc":
        continue

    let (success, acc) = simulation(mut)

    if success:
      echo fmt"second {pos=} {mut[pos]=} {programm[pos]=} {acc=}"
      break
