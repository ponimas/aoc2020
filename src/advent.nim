import parseopt, streams

import day_18

when isMainModule:
  var parser = parseopt.initOptParser()
  parser.next()
  let filename = parser.key
  let strm = newFileStream(filename, fmRead)

  solution(strm)
