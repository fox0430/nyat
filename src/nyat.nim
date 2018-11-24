import os, unicode, sequtils, posix

type
  FileNameAndOption = tuple[fileNameList: seq[string], options: seq[char]]
  OptionList = tuple[setLineNumber: bool]

proc initOptionList(): OptionList =
  result.setLineNumber = false

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
      else:
        echo "invalid option: -" & options[i]
        quit()

proc setBufferList(fileNameList: seq[string]): seq[seq[string]] =
  result = @[]
  for i in 0 ..< fileNameList.len:
    result.add(openFile(fileNameList[i]))

proc displayBuffer(buffer: seq[string], optionList: OptionList) =
    for i in 0 ..< buffer.len:
      if optionList.setLineNumber:
        stdout.write $(i + 1) & " ".repeat(($buffer.len).len - ($i).len + 2)
      echo buffer[i]

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
