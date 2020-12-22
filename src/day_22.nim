import sequtils
import sets
import streams
import strutils
import sugar
import deques
import unpack

from strformat import fmt

proc first(one: Deque[int], two: Deque[int]): int =
  var
    deckOne = one
    deckTwo = two

  while len(deckOne) > 0 and len(deckTwo) > 0:
    let
      o = deckOne.popFirst()
      t = deckTwo.popFirst()
    if o > t:
      deckOne.addLast(o)
      deckOne.addLast(t)
    else:
      deckTwo.addLast(t)
      deckTwo.addLast(o)

  let winner = if len(deckOne) > 0:
                 deckOne
               else:
                 deckTwo
  var score = 0
  for (i, c) in zip(toSeq(countdown(len(winner), 1)), toSeq(winner)):
    score += i * c
  score

proc second(one: Deque[int], two: Deque[int]): int =
  proc rc(one: Deque[int], two: Deque[int]): (Deque[int], Deque[int]) =
    var
      deckOne = one
      deckTwo = two
      seen: HashSet[(string, string)] # deque is unhashable

    while len(deckOne) > 0 and len(deckTwo) > 0:
      if seen.containsOrIncl(($deckOne, $deckTwo)):
        # player one is the winner of this game
        deckTwo = initDeque[int]()
        break

      let
        o = deckOne.popFirst()
        t = deckTwo.popFirst()

        firstWonRound =
          if len(deckOne) >= o and len(deckTwo) >= t:
            let (xo, xt) = rc(
              toDeque(toSeq(deckOne)[0 .. o - 1]),
              toDeque(toSeq(deckTwo)[0 .. t - 1])
            )
            len(xo) > len(xt)
          else:
            o > t
      if firstWonRound:
        deckOne.addLast(o)
        deckOne.addLast(t)
      else:
        deckTwo.addLast(t)
        deckTwo.addLast(o)
    (deckOne, deckTwo)

  let
    (deckOne, deckTwo) = rc(one, two)
    winner = if len(deckOne) > 0:
               deckOne
             else:
               deckTwo
  var score = 0
  for (i, c) in zip(toSeq(countdown(len(winner), 1)), toSeq(winner)):
    score += i * c
  score




proc parseDeck(input: string): seq[int] =
  collect(newSeq):
    for l in input.splitLines:
      if l != "" and (not l.startsWith("Player")):
        parseInt(l)

proc solution*(stream: FileStream) =
  [one, two] <- (stream
    .readAll()
    .split("\n\n")
    .mapIt(toDeque(parseDeck(it))))

  let f = first(one, two)
  echo fmt"first {f}"

  let s = second(one, two)
  echo fmt"second {s}"
