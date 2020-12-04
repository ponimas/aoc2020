import parseopt, streams

import day_1, day_2, day_3, day_4

when isMainModule:
  var parser = parseopt.initOptParser()
  parser.next()
  let filename = parser.key
  let strm = newFileStream(filename, fmRead)

  fourthDay(strm)
