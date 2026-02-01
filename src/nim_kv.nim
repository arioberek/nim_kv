import std/[parseopt, strutils, os]
import jester
import nim_kv/api

const
  DefaultPort = 5000
  DefaultDb = "nim_kv.json"

proc main() =
  var port = DefaultPort
  var dbPath = DefaultDb

  var p = initOptParser()
  for kind, key, val in p.getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "port", "p": 
        try: port = val.parseInt
        except ValueError: echo "Invalid port, using default"
      of "db", "d": dbPath = val
      of "help", "h":
        echo "Usage: nim_kv [options]"
        echo "  -p, --port:PORT   Set server port (default: 5000)"
        echo "  -d, --db:FILE     Set database file (default: nim_kv.json)"
        echo "  -h, --help        Show this help"
        quit(0)
    else: discard

  # Initialize logic (sets the path for the main thread)
  putEnv("NIM_KV_DB_PATH", dbPath)
  
  initApi(dbPath)

  let settings = newSettings(port=port.Port)
  var jester = initJester(kvRoutes, settings=settings)
  echo "Starting nim_kv on port ", port, " with db ", dbPath
  jester.serve()

when isMainModule:
  main()
