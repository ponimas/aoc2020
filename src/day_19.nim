import sequtils
import streams
import strutils
import tables

import unpack
import memo
from strformat import fmt


var rules: Table[string, string]

proc validate(msg: string, rule: string): bool {.memoized.} =
  if rule in ["\"a\"", "\"b\""]:
    return $rule[1] == msg

  if "|" in rule:
    for r in rule.split(" | "):
      if validate(msg, r):
        return true
  else:
    let r = rule.splitWhitespace()

    if len(r) == 1:
      return validate(msg, rules[rule])

    if len(r) == 2:
      [r1, r2] <- r
      for i in 0 .. high(msg):
        if validate(msg[0 .. i], rules[r1]) and validate(msg[i + 1 .. ^1],
            rules[r2]):
          return true

    if len(r) == 3:
      [r1, r2, r3] <- r
      for i in 0 .. high(msg) - 1:
        for j in i + 1 .. high(msg):
          if validate(msg[0 .. i], rules[r1]) and validate(msg[i + 1 .. j],
              rules[r2]) and validate(msg[j + 1 .. ^1], rules[r3]):
            return true


proc solution*(stream: FileStream) =
  [rulesInput, messages] <- stream
  .readAll()
  .split("\n\n", 2)
  .map(proc (s: string): seq[string] = s.strip(trailing = true).splitLines())

  for r in rulesInput:
    [ruleId, rule] <- r.split(": ", maxsplit = 1)
    rules[ruleId] = rule

  var cnt: int
  for msg in messages:
    if validate(msg, "0"): inc cnt
  echo fmt"first {cnt}"

  var plus = ""

  # 5 is enough for my input
  for i in 0..5:
    rules[fmt"8{plus}"] = fmt"42 | 42 8{plus}+"
    rules[fmt"11{plus}"] = fmt"42 31 | 42 11{plus}+ 31"
    plus = fmt"{plus}+"

  rules[fmt"8{plus}"] = fmt"42"
  rules[fmt"11{plus}"] = fmt"42 31"

  resetCacheValidate()

  cnt = 0
  for msg in messages:
    if validate(msg, "0"): inc cnt

  echo fmt"second {cnt}"
