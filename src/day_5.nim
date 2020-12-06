import streams, algorithm
from strformat import fmt

proc solution*(stream: FileStream) =
  var
    line = ""
    max = 0
    occupied: seq[int]

  while stream.readLine(line):
    var
      row_h = 127
      row_l = 0
      seat_h = 7
      seat_l = 0
      row = 0
      seat = 0

    for r in line[0 .. 6]:
      if r == 'B':
        row_l = row_l + (row_h - row_l) div 2 + 1
        row = row_h

      else:
        row_h = row_h - (row_h - row_l) div 2 - 1
        row = row_l

      # echo fmt"{r=} {row_l=} {row_h=} {row=}"

    for s in line[7 .. 9]:
      if s == 'R':
        seat_l = seat_l + (seat_h - seat_l) div 2 + 1
        seat = seat_h
      else:
        seat_h = seat_h - (seat_h - seat_l) div 2 - 1
        seat = seat_l

      # echo fmt"{s=} {seat_l=} {seat_h=} {seat=}"

    let id = row * 8 + seat
    occupied.add(id)

    echo fmt"{line} {row=} {seat=} {id=}"

    if max < id: max = id

  sort(occupied)

  let
    maxId = occupied[high(occupied)]
    minId = occupied[0]

  var
    mine = (maxId * (maxId + 1) - (minId - 1) * minId) div 2

  for id in occupied:
    mine = mine - id

  echo fmt"{max=}, {mine=}"
