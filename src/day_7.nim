import streams, re, tables, strutils, sets
from strformat import fmt

proc solution*(stream: FileStream) =
  var
    line = ""
    graph = initTable[string, seq[(string, int)]]()
    revGraph = initTable[string, seq[string]]()

  let rx = re" bags?(,\s|\.$)"

  while stream.readLine(line):
    var
      outer = ""
      inners = ""
      num = ""
      color = ""
      
    (outer, inners) = split(line, " bags contain ", maxsplit=1)

    if not graph.hasKey(outer): graph[outer] = @[]
    
    for match in re.split(inners, rx):

      if match in ["", "no other"]:         break

      (num, color) = splitWhitespace(match, maxsplit=1)
      
      if not revGraph.hasKey(color): revGraph[color] = @[]

      revGraph[color].add(outer)
      graph[outer].add((color, parseInt(num)))

  var
    visited = initHashSet[string]()
    v = "shiny gold"
    stack= revGraph[v]
  
  while len(stack) > 0:
    v = stack.pop()
    if visited.containsOrIncl(v): continue
    stack &= revGraph.getOrDefault(v)
    
  echo fmt"first = {len(visited)}"

  proc count(v: string): int =
    var i = 0
    for (adj, n) in graph[v]:
      i += n * (count(adj) + 1)
    return i

  let bagsNum = count("shiny gold")
  echo fmt"second = {bagsNum}"

