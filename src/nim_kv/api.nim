import std/[json, options, asyncdispatch, strutils, os]
import jester
import store, types

var globalStore {.threadvar.}: KVStore
var dbPath {.threadvar.}: string

proc initApi*(path: string) =
  dbPath = path
  if globalStore.isNil:
    globalStore = newKVStore(path)

proc ensureStore() =
  if globalStore.isNil:
    if dbPath == "": 
      dbPath = getEnv("NIM_KV_DB_PATH", "nim_kv.json")
    globalStore = newKVStore(dbPath)

router kvRoutes*:
  get "/":
    ensureStore()
    resp Http200, {"Content-Type": "application/json"}, $ %* {
      "service": "nim_kv",
      "version": "0.1.0",
      "status": "operational",
      "items": globalStore.count()
    }

  get "/health":
    ensureStore()
    resp Http200, {"Content-Type": "application/json"}, $ %* {"status": "ok"}

  get "/keys":
    ensureStore()
    let k = globalStore.keys()
    var jsonKeys = newJArray()
    for key in k: jsonKeys.add(%key)
    resp Http200, {"Content-Type": "application/json"}, $ %* {"keys": jsonKeys, "count": k.len}

  get "/@key":
    ensureStore()
    let val = globalStore.get(@"key")
    if val.isSome:
      resp Http200, {"Content-Type": "application/json"}, $val.get
    else:
      resp Http404, {"Content-Type": "application/json"}, $ %* {"error": "Key not found", "code": 404}

  post "/@key":
    ensureStore()
    var bodyJson: JsonNode
    try:
      if request.body.strip() == "": raise newException(JsonParsingError, "Empty body")
      bodyJson = parseJson(request.body)
    except JsonParsingError:
      resp Http400, {"Content-Type": "application/json"}, $ %* {"error": "Invalid JSON body", "code": 400}
      return

    await globalStore.put(@"key", bodyJson)
    resp Http201, {"Content-Type": "application/json"}, $ %* {"status": "created", "key": @"key"}

  delete "/@key":
    ensureStore()
    await globalStore.delete(@"key")
    resp Http200, {"Content-Type": "application/json"}, $ %* {"status": "deleted", "key": @"key"}
