import deques
import math
import re
import sequtils
import streams
import strutils
import sugar
import tables

from strformat import fmt

proc matchRule(val: int, rule: seq[int]): bool =
  return (rule[0] <= val and val <= rule[1]) or (rule[2] <= val and val <= rule[3])


proc first(rulesTable: TableRef[string, seq[int]], tickets: seq[seq[int]]): int =
  let rules = toSeq(rulesTable.values())

  let invalid = collect(newSeq):
    for ticket in tickets:
      for value in ticket:
        if rules.allIt(not matchRule(value, it)):
          value
  return sum(invalid)


proc second(rulesTable: TableRef[string, seq[int]], tickets: seq[seq[int]],
    myTicket: seq[int]): int =
  var
    correct: seq[string]
    rules = toDeque(toSeq(rulesTable.keys()).mapIt(@[it]))
  let validTickets = collect(newSeq):
    for ticket in tickets:
      if all(ticket, proc (val: int): bool = toSeq(rulesTable.values).anyIt(
          matchRule(val, it))):
        ticket

  while true:
    let rule = rules.popFirst()
    let field = high(rule)
    let check = rulesTable[rule[field]]

    if validTickets.allIt(matchRule(it[field], check)):
      if high(rule) == high(myTicket):
        correct = rule
        break

      for r in rulesTable.keys():
        if not (r in rule):
          var rn = rule
          rn.add(r)
          rules.addFirst(rn)

  let departure = collect(newSeq):
    for (i, k) in correct.pairs:
      if k.startsWith("departure"):
        myTicket[i]

  return foldl(departure, a * b, 1)


proc solution*(stream: FileStream) =
  let input = readAll(stream).split("\n\n")

  let ruleRx = re"(.+): (\d+)-(\d+) or (\d+)-(\d+)"
  var matches: array[5, string]

  let rules = collect(newTable(len(input[0]))):
    for rule in input[0].splitLines():
      if match(rule, ruleRx, matches):
        let bounds = matches[1..^1].map(parseInt)
        {matches[0]: bounds}

  let myTicket = input[1].splitLines()[1].split(",").mapIt(parseInt(it))

  let nearby = collect(newSeq):
    for ticket in input[2].splitLines().filterIt(match(it, re"(\d+,?)+")):
      ticket.split(",").map(parseInt)

  let f = first(rules, nearby)
  echo fmt"first {f}"

  let s = second(rules, nearby, myTicket)
  echo fmt"second {s}"
