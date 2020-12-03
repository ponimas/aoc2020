import parseopt, streams

import day_1, day_2, day_3

when isMainModule:
  var parser = parseopt.initOptParser()
  parser.next()
  let filename = parser.key
  let strm = newFileStream(filename, fmRead)

  thirdDay(strm)
