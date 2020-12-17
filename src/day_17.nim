import streams
import strutils
import sequtils
from strformat import fmt

# can be optimised: dimensions z and w are symmetric
# so cube[-z] == cube[z], and the same for hypercube

type
  Slice = seq[string]
  Cube = seq[Slice]
  Hypercube = seq[Cube]

# proc print(g: Cube) =
#   echo repeat("-", len(g[0]))
#   for s in g:
#     echo ""
#     for l in s:
#       echo l

iterator flatItems*[T](s: openarray[T]): auto {.noSideEffect.} =
  # taken from https://github.com/nim-lang/Nim/pull/6807
  for item in s:
    when item is array|seq:
      for subitem in flatItems(item):
        yield subitem
    else:
      yield item

proc mkEmptyRow(len: int): string =
  return repeat(".", len)

proc mkEmptySlice(width: int, length: int): Slice =
  return newSeqWith(length, mkEmptyRow(width))

proc mkEmptyCube(width: int, length: int, height: int): Cube =
  return newSeqWith(height, mkEmptySlice(width, length))

proc grow(cube: Cube): Cube =
  let
    nWidth = len(cube[0][0]) + 2
    nLength = len(cube[0]) + 2

  var extendedCube = @[mkEmptySlice(nWidth, nLength)]

  for slice in cube:
    var nSlice = @[mkEmptyRow(nWidth)]
    for row in slice:
      nSlice.add(fmt".{row}.")
    nSlice.add(mkEmptyRow(nWidth))
    extendedCube.add(nSlice)

  extendedCube.add(mkEmptySlice(nWidth, nLength))
  extendedCube

proc growHyper(hyper: Hypercube): Hypercube =
  let
    nWidth = len(hyper[0][0][0]) + 2
    nLength = len(hyper[0][0]) + 2
    nHeight = len(hyper[0]) + 2

  var extendedHCube = @[mkEmptyCube(nWidth, nLength, nHeight)]

  for cube in hyper:
    extendedHCube.add(grow(cube))

  extendedHCube.add(mkEmptyCube(nWidth, nLength, nHeight))
  return extendedHCube


proc cycle(oldCube: Cube): Cube =
  let cube = grow(oldCube)
  var nextCube = cube

  for z, s in cube:
    for y, r in s:
      for x, c in r:
        var populated: int
        # echo "X"
        for dx in max(x-1, 0) .. min(x+1, high(r)):
          for dy in max(y-1, 0) .. min(y+1, high(s)):
            for dz in max(z-1, 0) .. min(z+1, high(cube)):
              if dz == z and dy == y and dx == x:
                continue
              # echo fmt"{x=},{y=},{z=}  {c} | {dx=},{dy=},{dz=} {cube[dz][dy][dx]}"
              if cube[dz][dy][dx] == '#':
                inc populated

        # echo fmt"{x=},{y=},{z=} {populated}"
        if c == '#':
          if populated > 3 or populated < 2:
            nextCube[z][y][x] = '.'
        else:
          if populated == 3:
            nextCube[z][y][x] = '#'
  nextCube

proc hyperCycle(oldCube: Hypercube): Hypercube =
  let cube = growHyper(oldCube)
  var nextCube = cube
  for w, d in cube:
    for z, s in d:
      for y, r in s:
        for x, c in r:

          var populated: int

          for dw in max(w-1, 0) .. min(w+1, high(d)):
            for dx in max(x-1, 0) .. min(x+1, high(r)):
              for dy in max(y-1, 0) .. min(y+1, high(s)):
                for dz in max(z-1, 0) .. min(z+1, high(cube)):
                  if dz == z and dy == y and dx == x and dw == w:
                    continue
                  # echo fmt"{x=},{y=},{z=}  {c} | {dx=},{dy=},{dz=} {cube[dz][dy][dx]}"
                  if cube[dw][dz][dy][dx] == '#':
                    inc populated

          # echo fmt"{x=},{y=},{z=} {populated}"
          if c == '#':
            if populated > 3 or populated < 2:
              nextCube[w][z][y][x] = '.'
          else:
            if populated == 3:
              nextCube[w][z][y][x] = '#'
  nextCube

proc first(s: Slice): int =
  var
    g = @[s]
    active: int
  for _ in 0 .. 5:
    g = cycle(g)

  for x in flatItems(g):
    active += count(x, '#')
  return active

proc second(s: Slice): int =
  var
    g = @[@[s]]
    active: int

  for _ in 0 .. 5:
    g = hyperCycle(g)

  for x in flatItems(g):
    active += count(x, '#')

  return active

proc solution*(stream: FileStream) =
  # io.readLines() btw
  let input = toSeq(stream.lines())

  let f = first(input)
  echo fmt"first {f}"
  let s = second(input)
  echo fmt"second {s}"

