import re, streams, strutils, sequtils, lists, bitops, tables, sugar, math, unicode
from strformat import fmt


type
   Command = ref object of RootObj
   Mask = ref object of Command
      value: string
   Write = ref object of Command
      value: uint
      address: uint

proc first(programm: seq[Command]): uint =
   var
      mem = initTable[uint, uint]()
      mask: string
      sum: uint

   for command in programm:
      if command of Mask:
         mask = Mask(command).value
      else:
         var val: uint = Write(command).value
         for i, m in mask:
            if m == '1':
               val.setBit(i)
            elif m == '0':
               val.clearBit(i)
         mem[Write(command).address] = val
   for val in mem.values():
      sum += val
   return sum


proc second(programm: seq[Command]): uint =
   var
      mem = initTable[uint, uint]()
      mask: string
      sum: uint

   for command in programm:
      if command of Mask:
         mask = Mask(command).value
      else:
         var val: uint = Write(command).value
         var addresses = @[Write(command).address]
         for i, m in mask:
            if m == '1' or m == 'X':
               for a in addresses.mitems():
                  a.setBit(i)

            if m == 'X':
               var ac = addresses
               for a in ac.mitems():
                  a.clearBit(i)
                  addresses.add(a)

         for address in addresses:
            mem[address] = val

   for val in mem.values():
      sum += val
   return sum


proc solution*(stream: FileStream) =
   let
      reMask = re"^mask = ([01X]{36})$"
      reMem = re"^mem\[(\d+)\] = (\d+)$"
   var
      matches: array[2, string]

   let programm = collect(newSeq):
      for line in stream.lines():
         if match(line, reMask, matches):
            Mask(value: reversed(matches[0]))
         elif match(line, reMem, matches):
            Write(value: parseUInt(matches[1]),
                  address: parseUInt(matches[0]))

   let f = first(programm)
   echo fmt"first {f}"
   let s = second(programm)
   echo fmt"second {s}"

