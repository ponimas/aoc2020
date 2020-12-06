import streams, sets, strutils, re

proc validate(passData: seq[string]): bool =
  let
    hgtRx = re"^(\d+)(cm|in)$"
    eyes = toHashSet(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])
    hclRx = re"^\#[a-f0-9]{6}$"
    pidRx = re"^\d{9}$"

  var required = toHashSet(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])

  for field in passData:

    let data = field[4 .. len(field) - 1]

    case field[0 .. 2]:
      of "byr":
        let yr = parseInt(data)
        if yr > 2002 or yr < 1920: return false

      of "iyr":
        let yr = parseInt(data)
        if yr > 2020 or yr < 2010: return false

      of "eyr":
        let yr = parseInt(data)
        if yr > 2030 or yr < 2020: return false

      of "hgt":
        var res: array[2, string]
        if not match(data, hgtRx, res): return false
        let h = parseInt(res[0])
        if res[1] == "cm":
          if h > 193 or h < 150: return false
        else:
          if h > 76 or h < 59: return false

      of "hcl":
        if not match(data, hclRx): return false

      of "ecl":
        if not eyes.contains(data): return false

      of "pid":
        if not match(data, pidRx): return false

      else:
        continue
    required.excl(field[0 .. 2])

  return len(required) == 0

proc solution*(stream: FileStream) =
  var
    line = ""
    valid = 0
    passData: seq[string]

  while stream.readLine(line):
    if line == "":
      if validate(passData): inc valid
      passData = @[]
      continue
    else:
      for field in strutils.splitWhitespace(line):
        passData.add(field)

  echo valid
