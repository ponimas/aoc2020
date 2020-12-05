import parseopt, streams

import day_5

when isMainModule:
  var parser = parseopt.initOptParser()
  parser.next()
  let filename = parser.key
  let strm = newFileStream(filename, fmRead)

  fifthDay(strm)
