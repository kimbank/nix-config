{
  stdenv,
  pnpm,
  nodejs-slim_22,
}:

if stdenv.isDarwin && stdenv.hostPlatform.isAarch64 then
  # TODO: Remove this override once the pinned nixpkgs includes the Node 24
  # Darwin fd-tracking fix. The affected Node build can make pnpm 11 emit
  # unmanaged-fd warnings and abort in libuv after a successful install.
  # https://github.com/NixOS/nixpkgs/issues/536039
  # https://github.com/NixOS/nixpkgs/issues/525627
  pnpm.override { nodejs-slim = nodejs-slim_22; }
else
  pnpm
