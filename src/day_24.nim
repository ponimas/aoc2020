import re
import sets
import sequtils
import streams
import strutils
import tables
from strformat import fmt


type Tile = tuple
  x: int
  y: int

let tileRx = re"(se)|(sw)|(nw)|(ne)|(e)|(w)"

proc find(steps: seq[string]): Tile =
  var loc: Tile
  for step in steps:
    case step:
      of "e":
        loc.x += 2
      of "w":
        loc.x -= 2
      of "se":
        inc loc.x
        inc loc.y
      of "sw":
        dec loc.x
        inc loc.y
      of "ne":
        inc loc.x
        dec loc.y
      of "nw":
        dec loc.x
        dec loc.y
  loc

proc neighbours(t: Tile): Hashset[Tile] =
  toHashSet(@[
    (t.x + 2, t.y),
    (t.x - 2, t.y),
    (t.x + 1, t.y + 1),
    (t.x - 1, t.y + 1),
    (t.x + 1, t.y - 1),
    (t.x - 1, t.y - 1)
  ])

proc init(tiles: seq[seq[string]]): Hashset[Tile] =
  var blacks: Hashset[Tile]
  for t in tiles.mapIt(find(it)):
    if blacks.missingOrExcl(t):
      blacks.incl(t)
  return blacks


proc day(blackTiles: Hashset[Tile]): Hashset[Tile] =
  var flipToWhite: Hashset[Tile]
  var flipToBlack: Hashset[Tile]
  var tmp: seq[Tile]


  for tile in blackTiles:
    if len(neighbours(tile) * blackTiles) > 2:
      flipToWhite.incl(tile)
    if len(neighbours(tile) * blackTiles) == 0:
      flipToWhite.incl(tile)
    for n in (neighbours(tile) - blackTiles):
      tmp.add(n)

  for (tile, blackNeighbours) in toCountTable(tmp).pairs():
    if blackNeighbours == 2:
      flipToBlack.incl(tile)

  blackTiles - flipToWhite + flipToBlack


proc solution*(stream: FileStream) =
  let input = toSeq(stream.lines()).filterIt(it != "").mapIt(findAll(it, tileRx))
  var floor = init(input)

  echo fmt"blacks: {len(floor)}"
  for d in 1 .. 100:
    floor = day(floor)
    if d <= 10 or (d mod 10) == 0:
      echo fmt"day {d}: {len(floor)}"
