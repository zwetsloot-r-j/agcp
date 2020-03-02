# Agcp

agcp is a command line tool that wraps ag to be able to easily copy the parts of it output you need to the clipboard.
It is intended to improve productivity by being able to copy searched file paths without the need to select them with a mouse.

## Usage:

agcp [ag command] [options]

options:
-l [--line] copy given line number of the output
-p [--pattern] filter the output by the given pattern and copy the result

## Installation

### Prerequisites

- ag silversearcher
- erlang

linux ubuntu:

```
sudo apt install silversearcher-ag
sudo apt install erlang
```

### Install

Clone the repository:

```
git clone https://github.com/nanaki04/agcp.git
cd agcp
```

Add the binary to an executable location:

```
cp agcp /usr/local/bin/agcp
```

Or alternatively add the location of the agcp file to your $PATH

## Development

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
