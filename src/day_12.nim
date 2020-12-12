import re, streams, strutils, sequtils, lists
from strformat import fmt

type
  Coord = tuple
    x: int
    y: int
  Dir = int
  Command = tuple
    action: char
    value: int

proc moveFirst(command: Command, pos: Coord, dir: Dir): (Coord, Dir) =
  let newPos =
    if (command.action == 'F' and dir == 0) or command.action == 'N':
      (pos.x, pos.y + command.value)
    elif (command.action == 'F' and dir == 180) or command.action == 'S':
      (pos.x, pos.y - command.value)
    elif (command.action == 'F' and dir == 90) or command.action == 'E':
      (pos.x + command.value, pos.y)
    elif (command.action == 'F' and dir == 270) or command.action == 'W':
      (pos.x - command.value, pos.y)
    else:
      pos
  let newDir =
    if command.action == 'R': (dir + command.value) mod 360
    elif command.action == 'L': (dir + (360 - command.value)) mod 360
    else: dir
  return (newPos, newDir)


proc moveSecond(command: Command, pos: Coord, waypoint: Coord): (Coord, Coord) =
  let newPos =
    if command.action == 'F': (pos.x + waypoint.x * command.value, pos.y +
        waypoint.y * command.value)
    else: pos

  let newWaypoint =
    case command.action:
      of 'F': waypoint
      of 'N': (waypoint.x, waypoint.y + command.value)
      of 'S': (waypoint.x, waypoint.y - command.value)
      of 'E': (waypoint.x + command.value, waypoint.y)
      of 'W': (waypoint.x - command.value, waypoint.y)
      else:
        let rot =
          if command.action == 'L': 360 - command.value
          else: command.value
        case rot:
          of 90: (waypoint.y, - waypoint.x)
          of 180: ( - waypoint.x, - waypoint.y)
          else: ( - waypoint.y, waypoint.x)
  return (newPos, newWaypoint)


proc first(instructions: seq[Command]): int =
  var
    pos: Coord = (0, 0)
    dir: Dir = 90

  for command in instructions:
    (pos, dir) = moveFirst(command, pos, dir)
  return abs pos.x + abs pos.y


proc second(instructions: seq[Command]): int =
  var
    pos: Coord = (0, 0)
    waypoint: Coord = (10, 1)

  for command in instructions:
    (pos, waypoint) = moveSecond(command, pos, waypoint)
  return (abs pos.x) + (abs pos.y)


proc solution*(stream: FileStream) =
  let rx = re"(\w)(\d+)"
  var
    matches: array[2, string]
    instructions: seq[Command]

  for line in stream.lines():
    let _ = match(line, rx, matches)
    instructions.add((matches[0][0], parseInt(matches[1])))

  let f = first(instructions)
  echo fmt"first {f}"
  let s = second(instructions)
  echo fmt"second {s}"

