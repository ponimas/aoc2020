import streams, sequtils
from strformat import fmt

iterator neighbours(x: int, y: int, ferry: seq[string]): char =
  for dx in -1 .. 1:
    let nx = x + dx
    if nx < 0 or nx > high(ferry[0]):
      continue
    for dy in -1 .. 1:
      let ny = y + dy
      if ny < 0 or ny > high(ferry) or (x == nx and y == ny):
        continue
      yield ferry[ny][nx]


iterator firstSeats(x: int, y: int, ferry: seq[string]): char =
  let
    left = toSeq(countdown(x - 1, 0))
    right = toSeq(x + 1 .. high(ferry[0]))
    up = toSeq(countdown(y - 1, 0))
    down = toSeq(y + 1 .. high(ferry))

    directions = [
      zip(left, repeat(y, len(ferry))),
      zip(right, repeat(y, len(ferry))),
      zip(repeat(x, len(ferry[0])), up),
      zip(repeat(x, len(ferry[0])), down),
      zip(left, up),
      zip(left, down),
      zip(right, up),
      zip(right, down)
    ]

  for direction in directions:
    for (nx, ny) in direction:
      if ferry[ny][nx] != '.':
        yield ferry[ny][nx]
        break


proc round(oldLayout: seq[string]): seq[string] =
  var newLayout = oldLayout

  for y in 0 .. high(oldLayout):
    for x, seat in oldLayout[y]:
      if seat == '.':
        continue

      var occupied = 0

      for neighbour in neighbours(x, y, oldLayout):
        if neighbour == '#': inc occupied

        if occupied >= 4:
          newLayout[y][x] = 'L'
          break

      if occupied == 0 and seat == 'L':
        newLayout[y][x] = '#'

  return newLayout

proc roundTwo(oldLayout: seq[string]): seq[string] =
  var newLayout = oldLayout

  for y in 0 .. high(oldLayout):
    for x, seat in oldLayout[y]:
      if seat == '.':
        continue
      var occupied = 0

      for neighbour in firstSeats(x, y, oldLayout):
        if neighbour == '#':
          inc occupied

        if occupied >= 5:
          newLayout[y][x] = 'L'
          break

      if occupied == 0 and seat == 'L':
        newLayout[y][x] = '#'
  return newLayout


proc printFerry(ferry: seq[string]) =
  for l in ferry:
    echo fmt"{l}"
  echo ""

proc first(layout: seq[string]): int =
  var
    l = layout
    occupied = 0
  # printFerry(l)

  while true:
    let nl = round(l)
    # printFerry(nl)

    if nl == l:
      break
    l = nl

  for line in l:
    for seat in line:
      if seat == '#':
        inc occupied
  return occupied


proc second(layout: seq[string]): int =
  var
    l = layout
    occupied = 0

  while true:
    let nl = roundTwo(l)

    if nl == l:
      break
    l = nl

  for line in l:
    for seat in line:
      if seat == '#':
        inc occupied
  return occupied

proc solution*(stream: FileStream) =
  var ferry: seq[string]

  for line in stream.lines():
    ferry.add(line)

  let f = first(ferry)
  let s = second(ferry)

  echo fmt"{f} {s}"


