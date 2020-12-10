import streams, sets, sequtils
from strformat import fmt


proc count(answers: seq[HashSet[char]], first: var int, second: var int) =
  if len(answers) == 0: return

  first += len(foldl(answers, a + b, answers[0]))
  second += len(foldl(answers, a * b, answers[0]))


proc solution*(stream: FileStream) =
  var
    line = ""
    answers: seq[HashSet[char]]
    first = 0
    second = 0

  while stream.readLine(line):
    if line == "":
      count(answers, first, second)
      answers = @[]
    else:
      answers.add(toHashSet(line))

  count(answers, first, second)

  echo fmt"{first} {second}"
