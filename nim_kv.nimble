mode = ScriptMode.Verbose

packageName   = "nim_kv"
version       = "0.1.0"
author        = "Arielton Oberek"
description   = "A high-performance, in-memory key-value store with persistence"
license       = "MIT"
srcDir        = "src"
bin           = @["nim_kv"]

requires "nim >= 2.2.6"
requires "jester >= 0.6.0"
