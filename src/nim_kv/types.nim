import std/[tables, json]

type
  KVStore* = ref object
    data*: TableRef[string, JsonNode]
    filePath*: string
