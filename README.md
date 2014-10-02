mixmux
======

mixmux lets you treat a running iex session sort of like an administrative shell on a Unix system, where you can tell the running system to reconfigure itself by installing/removing packages.

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

You can remove packages as well (thus allowing a limited form of upgrading):

    iex(6)> Mixmux.remove :jazz
    01:16:45.069 [info]  Application jazz exited: :stopped
    ==> mixmux_mockapp
    * Cleaning jazz
    :ok
    
    iex(7)> Jazz.encode [1, "2", [3]]
    ** (UndefinedFunctionError) undefined function: Jazz.encode/1 (module Jazz is not available)
        Jazz.encode([1, "2", [3]])

mixmux's installed packages, and their build files, are kept separate from your regular mix deps and build files. Deps retrieved by mixmux appear in the `mixmux/` directory, and build into the `_build/mixmux/` directory.
