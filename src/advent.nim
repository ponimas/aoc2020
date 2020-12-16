import parseopt, streams

import day_16

when isMainModule:
  var parser = parseopt.initOptParser()
  parser.next()
  let filename = parser.key
  let strm = newFileStream(filename, fmRead)

  solution(strm)
