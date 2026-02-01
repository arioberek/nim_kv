import std/[tables, json, os, asyncdispatch, asyncfile, options, syncio]
import types

proc newKVStore*(path: string): KVStore =
  result = KVStore(data: newTable[string, JsonNode](), filePath: path)
  if fileExists(path):
    try:
      let content = readFile(path)
      if content.len > 0:
        result.data = parseJson(content).to(TableRef[string, JsonNode])
    except JsonParsingError:
      discard 

proc save*(store: KVStore) {.async.} =
  let content = $ %* store.data
  var f = openAsync(store.filePath, fmWrite)
  await f.write(content)
  f.close()

proc get*(store: KVStore, key: string): Option[JsonNode] =
  if store.data.hasKey(key):
    return some(store.data[key])
  else:
    return none(JsonNode)

proc put*(store: KVStore, key: string, value: JsonNode) {.async.} =
  store.data[key] = value
  await store.save()

proc delete*(store: KVStore, key: string) {.async.} =
  if store.data.hasKey(key):
    store.data.del(key)
    await store.save()

proc count*(store: KVStore): int =
  return store.data.len

proc keys*(store: KVStore): seq[string] =
  result = newSeq[string]()
  for k in store.data.keys:
    result.add(k)
