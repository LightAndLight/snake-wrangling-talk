#! /bin/sh

sh -c "nix-build . && cd result/ && python3 -m http.server 8000"
