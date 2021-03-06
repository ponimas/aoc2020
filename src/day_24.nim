import re
import sets
import sequtils
import streams
import strutils
import tables

import memo

from strformat import fmt

# https://www.redblobgames.com/grids/hexagons/#coordinates-cube
type Tile = tuple
  x: int
  y: int
  z: int

let tileRx = re"(se)|(sw)|(nw)|(ne)|(e)|(w)"

proc find(steps: seq[string]): Tile =
  var loc: Tile
  for step in steps:
    case step:
      of "e":
        inc loc.x
        dec loc.y
      of "w":
        dec loc.x
        inc loc.y
      of "se":
        inc loc.z
        dec loc.y
      of "sw":
        inc loc.z
        dec loc.x
      of "ne":
        dec loc.z
        inc loc.x
      of "nw":
        dec loc.z
        inc loc.y
  loc

proc neighbours(t: Tile): Hashset[Tile] {.memoized.} =
  toHashSet(@[
    (t.x - 1, t.y + 1, t.z),
    (t.x + 1, t.y - 1, t.z),
    (t.x, t.y - 1, t.z + 1),
    (t.x, t.y + 1, t.z - 1),
    (t.x - 1, t.y, t.z + 1),
    (t.x + 1, t.y, t.z - 1),
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
    let intersection = neighbours(tile) * blackTiles
    if len(intersection) > 2:
      flipToWhite.incl(tile)
    if len(intersection) == 0:
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
