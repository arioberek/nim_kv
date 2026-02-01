import unittest, json, httpclient, os, osproc, strutils, tables

const
  BaseUrl = "http://localhost:5000"
  DbFile = "nim_kv.json"

suite "nim_kv integration tests":
  var serverProc: Process

  setup:
    # Ensure clean state
    if fileExists(DbFile): removeFile(DbFile)
    
    # Start server in background
    # We assume the binary is already built at src/nim_kv.out
    serverProc = startProcess("./src/nim_kv.out", options = {poStdErrToStdOut, poUsePath})
    sleep(1000) # Wait for server to start

  teardown:
    # Kill server
    serverProc.kill()
    serverProc.close()
    if fileExists(DbFile): removeFile(DbFile)

  test "server is running":
    let client = newHttpClient()
    let response = client.get(BaseUrl & "/")
    check response.code == Http200
    let body = parseJson(response.body)
    check body["status"].getStr == "ok"
    client.close()

  test "put and get value":
    let client = newHttpClient()
    client.headers = newHttpHeaders({"Content-Type": "application/json"})
    
    let payload = %* {"name": "Nim", "type": "language"}
    let postResp = client.post(BaseUrl & "/testkey", $payload)
    check postResp.code == Http201

    let getResp = client.get(BaseUrl & "/testkey")
    check getResp.code == Http200
    check parseJson(getResp.body) == payload
    client.close()

  test "persistence":
    # 1. Write data
    var client = newHttpClient()
    client.headers = newHttpHeaders({"Content-Type": "application/json"})
    let payload = %* {"persistent": true}
    discard client.post(BaseUrl & "/persist", $payload)
    client.close()

    # 2. Restart server (simulated by killing and starting new one)
    serverProc.kill()
    serverProc.close()
    sleep(500)
    serverProc = startProcess("./src/nim_kv.out", options = {poStdErrToStdOut, poUsePath})
    sleep(1000)

    # 3. Read data back
    client = newHttpClient()
    let getResp = client.get(BaseUrl & "/persist")
    check getResp.code == Http200
    check parseJson(getResp.body) == payload
    client.close()

  test "delete value":
    let client = newHttpClient()
    client.headers = newHttpHeaders({"Content-Type": "application/json"})
    
    let payload = %* {"temp": "data"}
    discard client.post(BaseUrl & "/delkey", $payload)
    
    let delResp = client.request(BaseUrl & "/delkey", httpMethod = HttpDelete)
    check delResp.code == Http200
    
    let getResp = client.get(BaseUrl & "/delkey")
    check getResp.code == Http404
    client.close()
