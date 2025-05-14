# Crawlio

Crawlio is a system call interceptor that slows down I/O operations by adding configurable sleep durations to common I/O operations (read, write, open, and close).

Some of possible use cases:

- Testing application behavior under slow I/O conditions
- Slowing down applications that produce large amounts of output
- Bringing back the dial-up nostalgia

## Usage

```sh
crawlio [options] -- program [args...]
```

- `-h, --help`: Show help message
- `-a, --all-sleep MS`: Set sleep duration for all syscalls (in milliseconds)
- `-r, --read-sleep MS`: Set sleep duration for read syscalls (in milliseconds)
- `-w, --write-sleep MS`: Set sleep duration for write syscalls (in milliseconds)
- `-o, --open-sleep MS`: Set sleep duration for open syscalls (in milliseconds)
- `-c, --close-sleep MS`: Set sleep duration for close syscalls (in milliseconds)
- `-l, --lib PATH`: Path to the crawlio.so library (default: crawlio.so)

## Examples

```sh
# Add 25ms delay to all supported syscalls when running vim
crawlio -a 25 -- vim

# Add different delays for read (50ms) and write (100ms) operations
crawlio -r 50 -w 100 -- cat /etc/passwd

# Add 200ms delay to file open operations
crawlio -o 200 -- find / -name '*.txt'
```

## Building and installing

Build:

```sh
make
```

Install (by default installs to /usr/local):

```sh
make install
```

Uninstall:

```sh
make uninstall
```

## How It Works

Crawlio uses the `LD_PRELOAD` mechanism to override certain system calls and inject configurable delays before each operation. It can currently override the following calls:

`read()`, `write()`, `open()`, `close()`
