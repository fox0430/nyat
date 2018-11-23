import os, unicode, sequtils, posix

type
  FileNameAndOption = tuple[fileNameList, options: seq[string]]

proc openFile(fileName: string): seq[Rune] =
  if existsFile(fileName) == false:
    echo "No such file"
    quit()

  try:
    let buffer = readFile(fileName)
    return buffer.toRunes
  except IOError:
    echo "IOError: Failed to open file"
  except OSError:
    echo "OSError: Failed to open file"

proc displayBuffer(buffer: seq[Rune]) =
  echo buffer

proc concatenateBuffer(bufferList: seq[seq[Rune]]): seq[Rune] =
  result = @[]
  for i in 0 ..< bufferList.len:
    result = concat(result, bufferList[i])

proc parseCommnadLineParams(line: seq[string]): FileNameAndOption =

  for i in 0 ..< line.len:
    if line[i][0] == '-':
      result.options.add(line[i])
    else:
      result.fileNameList.add(line[i])

proc setBufferList(fileNameList: seq[string]): seq[seq[Rune]] =
  result = @[]
  for i in 0 ..< fileNameList.len:
    result.add(openFile(fileNameList[i]))

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

    displayBuffer(buffer)
