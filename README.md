# nim_kv

A high-performance, in-memory key-value store with persistence written in Nim.

## Features

- Fast in-memory operations backed by Nim tables
- Asynchronous file persistence
- RESTful API interface
- Thread-safe architecture
- Zero external runtime dependencies

## Installation

Requires Nim 2.2.6 or higher.

```bash
nimble install
```

## Usage

Start the server:

```bash
nim_kv
```

The server listens on port 5000 by default.

### API Endpoints

- `GET /` - Check service status
- `GET /:key` - Retrieve value by key
- `POST /:key` - Store value by key (JSON body required)
- `DELETE /:key` - Delete value by key

## Development

Build release binary:

```bash
nim c -d:release --mm:orc src/nim_kv.nim
```
