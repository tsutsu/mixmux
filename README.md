mixmux
======

mixmux lets you use an Erlang VM sort of like a Unix system, where you can manipulate the active set of installed packages with commands sent to the running system itself.

Typing some commands and realize that you need a package?

  iex(3)> Jazz.encode [1, "2", [3]]
  ** (UndefinedFunctionError) undefined function: Jazz.encode/1 (module Jazz is not available)
      Jazz.encode([1, "2", [3]])

Just tell Mixmux to start the application, as if it was already available:

  iex(3)> Mixmux.start :jazz
  ==> mixmux_mockapp
  Running dependency resolution
  Unlocked:   jazz
  Dependency resolution completed successfully
    jazz: v0.2.1
  * Getting jazz (package)
  Checking package (http://s3.hex.pm/tarballs/jazz-0.2.1.tar)
  Fetched package
  Unpacked package tarball (/root/.hex/packages/jazz-0.2.1.tar)
  ==> jazz
  Compiled lib/jazz.ex
  Compiled lib/jazz/parser.ex
  Compiled lib/jazz/decoder.ex
  Compiled lib/jazz/encoder.ex
  Generated jazz.app
  :ok

  iex(4)> Jazz.encode [1, "2", [3]]
  {:ok, "[1,\"2\",[3]]"}

You can remove packages as well (which implies, of course, that you can upgrade packages):

  iex(6)> Mixmux.remove :jazz
  01:16:45.069 [info]  Application jazz exited: :stopped
  ==> mixmux_mockapp
  * Cleaning jazz
  :ok

  iex(7)> Jazz.encode [1, "2", [3]]
  ** (UndefinedFunctionError) undefined function: Jazz.encode/1 (module Jazz is not available)
      Jazz.encode([1, "2", [3]])
