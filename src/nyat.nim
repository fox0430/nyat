import os, unicode, sequtils, posix

type
  FileNameAndOption = tuple[fileNameList: seq[string], options: seq[char]]
  OptionList = tuple[
    setLineNumber: bool,
    numberNoBlank: bool,
    squeezeBlank: bool
  ]

proc initOptionList(): OptionList =
  result.setLineNumber = false
  result.numberNoBlank = false
  result.squeezeBlank = false

proc parseBuffer(buffer: string): seq[string] =
  result = newSeq[string]()
  var line  = ""
  for i in 0 ..< buffer.len:
    if buffer[i] == '\n':
      result.add(line)
      line = ""
    else:
      line.add(buffer[i])

proc openFile(fileName: string): seq[string] =
  if existsFile(fileName) == false:
    echo "No such file"

  try:
    let buffer = readFile(fileName)
    result = parseBuffer(buffer)

  except IOError:
    echo "IOError: Failed to open file"
    quit()
  except OSError:
    echo "OSError: Failed to open file"
    quit()

proc concatenateBuffer(bufferList: seq[seq[string]]): seq[string] =
  result = @[]
  for i in 0 ..< bufferList.len:
    result = concat(result, bufferList[i])

proc parseCommnadLineParams(line: seq[string]): FileNameAndOption =
  for i in 0 ..< line.len:
    if line[i][0] == '-':
      result.options.add(line[i][1])
    else:
      result.fileNameList.add(line[i])
      
proc parseCommanLineOption(options: seq[char]): OptionList =
  result = initOptionList()
  for i in 0 ..< options.len:
    case options[i]:
      of 'n':
        result.setLineNumber = true
      of 'b':
        result.numberNoBlank = true
      of 's':
        result.squeezeBlank = true
      else:
        echo "invalid option: -" & options[i]
        quit()

proc setBufferList(fileNameList: seq[string]): seq[seq[string]] =
  result = @[]
  for i in 0 ..< fileNameList.len:
    result.add(openFile(fileNameList[i]))

proc displayBuffer(buffer: seq[string], option: OptionList) =
    var
      lineNumber = 1
      writeLine = ""
      ignoreLine = false

    for i in 0 ..< buffer.len:
      if i < buffer.high and option.squeezeBlank:
        if buffer[i] == "" and buffer[i + 1] == "":
          ignoreLine = true

      if option.numberNoBlank:
        if buffer[i] != "":
          writeLine = "  " & $lineNumber & "  "
          lineNumber.inc
        else:
          writeLine = ""

      if option.setLineNumber:
          writeLine = "  " & $lineNumber & "  "
          lineNumber.inc

      if ignoreLine == false:
        echo writeLine & buffer[i]

      ignoreLine = false

when isMainModule:
  if commandLineParams().len == 0:
    setControlCHook(proc() {.noconv.} = quit())
    while true:
      discard readLine(stdin)

  if commandLineParams().len > 0:
    let
      line = parseCommnadLineParams(commandLineParams())
      bufferList = setBufferList(line.fileNameList)
      buffer = concatenateBuffer(bufferList)

    let optionList = parseCommanLineOption(line.options)
    displayBuffer(buffer, optionList)
