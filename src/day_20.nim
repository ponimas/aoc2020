import algorithm
import math
import sugar
import sets
import streams
import strutils
import sequtils
import unicode
import memo
from strformat import fmt

type
  Tile = tuple
    id: int
    data: seq[string]
    borders: HashSet[string]

let m = [
  "                  # ",
  "#    ##    ##    ###",
  " #  #  #  #  #  #   "
]

let monster = collect(newSeq):
  for y, line in m:
    for x, c in line:
      if c == '#':
        (x, y)

proc print(tiles: seq[seq[Tile]]) =
  for l in tiles:
    for i in 0 .. high(l[0].data):
      echo l.mapIt(it.data[i]).join(" ")
    echo ""

iterator shrink(tiles: seq[seq[Tile]]): string =
  for l in tiles:
    for y in 1 .. (high(l[0].data) - 1):
      yield l.mapIt(it.data[y][1..^2]).join("")

proc left(data: seq[string]): string {.memoized.} =
  let x = collect(newSeq):
    for l in data:
      l[0]
  return x.join()

proc right(data: seq[string]): string {.memoized.} =
  let x = collect(newSeq):
    for l in data:
      l[^1]
  return x.join()

proc top(data: seq[string]): string {.memoized.} =
  return data[0]

proc bottom(data: seq[string]): string {.memoized.} =
  return data[^1]

proc flip(data: seq[string]): seq[string] {.memoized.} =
  return reversed(data)

proc rotateCW(data: seq[string]): seq[string] {.memoized.} =
  return collect(newSeq):
    for i in 0 .. high(data):
      reversed(data.mapIt($it[i])).join()

proc borders(data: seq[string]): HashSet[string] =
  return toHashSet(
    [
      top(data),
      bottom(data),
      left(data),
      right(data),
      reversed(top(data)),
      reversed(bottom(data)),
      reversed(left(data)),
      reversed(right(data))
  ])

iterator mutations(data: seq[string]): seq[string] =
  var dt = data
  yield dt
  yield flip(dt)
  for _ in 0 .. 2:
    dt = rotateCW(dt)
    yield dt
    yield flip(dt)

proc monsters(sea: seq[string]): int =
  for s in mutations(sea):
    var cnt: int
    for x in 0 .. high(s[0]) - len(m[0]):
      for y in 0 .. high(s) - 3:
        if monster.mapIt(s[y + it[1]][x + it[0]]).allIt(it == '#'):
          inc cnt
    if cnt > 0:
      return cnt

proc first(tiles: seq[Tile]): seq[Tile] {.memoized.} =
  var corners: seq[Tile]
  for i, t in tiles:
    var brdrs = t.borders
    for s in tiles:
      if s.id != t.id:
        brdrs = brdrs - s.borders
      if len(brdrs) < 4:
        break
    if len(brdrs) == 4:
      corners.add(t)
  return corners

proc second(tiles: seq[Tile]): int =
  let d = int(sqrt(float(len(tiles))))
  var pl = newSeqWith(d, newSeq[Tile](d))

  var placed: HashSet[int]

  let corner = first(tiles)[0]

  # assuming it's top left corner
  # top and left borders should be uniq
  for dc in mutations(corner.data):
    let
      t = top(dc)
      l = left(dc)

    var x: bool
    for tt in tiles.filterIt(it.id != corner.id):
      x = tt.borders.contains(t) or tt.borders.contains(l)
      if x: break

    if not x:
      pl[0][0] = (corner.id, dc, corner.borders)
      break

  placed.incl(corner.id)

  # first row
  for x in 1 .. (d - 1):
    let prev = pl[0][x - 1]
    for t in tiles.filterIt(not placed.contains(it.id)):
      if right(prev.data) in t.borders:
        for dt in mutations(t.data):
          if left(dt) == right(prev.data):
            pl[0][x] = (t.id, dt, t.borders)
            placed.incl(t.id)
            break
        break

  for y in 1 .. (d - 1):
    for x in 0 .. (d - 1):
      # checking only tile on the top.
      let prev = pl[y - 1][x]
      for t in tiles.filterIt(not placed.contains(it.id)):
        if bottom(prev.data) in t.borders:
          for dt in mutations(t.data):
            if top(dt) == bottom(prev.data):
              pl[y][x] = (t.id, dt, t.borders)
              placed.incl(t.id)
              break

  # print(pl)
  let sea = toSeq(shrink(pl))
  # echo toSeq(shrink(pl)).join("\n")
  return sea.join().count("#") - monsters(sea) * len(monster)

proc solution*(stream: FileStream) =
  # io.readLines() btw

  let input = stream.readAll().split("\n\n")
  let tiles = collect(newSeq):
    for t in input:
      let lines = t.splitLines().filterIt(it != "")
      (parseInt(lines[0][5 .. ^2]), lines[1..^1], borders(lines[1..^1]))

  let f = prod(first(tiles).mapIt(it.id))
  echo fmt"first {f}"
  let s = second(tiles)
  echo fmt"second {s}"

