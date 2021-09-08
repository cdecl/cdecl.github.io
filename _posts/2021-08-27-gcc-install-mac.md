---
title: GCC 설치 (`macOS`, `Windows`)

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - gcc
  - g++
  - macos
  - homebrew
  - brew
  - choco
  - chocolatey
---

macOS 및 Windows 에 GCC 설치하기 

## MAC OS
- brew : macOS 용 패키지 관리자 <https://brew.sh/index_ko>{:target="_blank"}
- brew 사용 gcc 설치 

### Command line tools 설치 
- xcode 없이 개발툴 설치 

```sh
$ xcode-select --install
```

> `clang` 이 설치되고 `gcc`로 심볼링 링크 걸려 있음  

```sh
$ gcc -v
Configured with: --prefix=/Library/Developer/CommandLineTools/usr --with-gxx-include-dir=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/4.2.1
Apple clang version 12.0.5 (clang-1205.0.22.11)
Target: arm64-apple-darwin20.6.0
Thread model: posix
InstalledDir: /Library/Developer/CommandLineTools/usr/bin
```

### GCC (G++) 설치 

```sh
# 특정 버전으로 설치 가능 
$ brew search gcc
==> Formulae
gcc                 gcc@5               gcc@8               libgccjit           ghc                 ncc
gcc@10              gcc@6               gcc@9               x86_64-elf-gcc      scc
gcc@4.9             gcc@7               i686-elf-gcc        grc                 tcc
==> Casks
gcc-arm-embedded

# 기본(최신) 버전 설치 
$ brew install gcc
==> Auto-updated Homebrew!
Updated 1 tap (homebrew/core).
==> Updated Formulae
Updated 1 formula.

==> Downloading https://ghcr.io/v2/homebrew/core/gcc/manifests/11.2.0
Already downloaded: /Users/cdecl/Library/Caches/Homebrew/downloads/210783e77b227b8210d559abfe3514cdb95c915619fa3f785ad212120d6a36f9--gcc-11.2.0.bottle_manifest.json
==> Downloading https://ghcr.io/v2/homebrew/core/gcc/blobs/sha256:23ec727fa684a9f65cf9f55d61d208486d5202fb6112585a01426a
Already downloaded: /Users/cdecl/Library/Caches/Homebrew/downloads/8d1fae8a356d50aa911004b768eff64c241e170ce9be66e684b819fc4f67fc7c--gcc--11.2.0.arm64_big_sur.bottle.tar.gz
==> Pouring gcc--11.2.0.arm64_big_sur.bottle.tar.gz
🍺  /opt/homebrew/Cellar/gcc/11.2.0: 1,412 files, 339.5MB
```

#### 심볼릭링크 설정 및 PATH 설정 

```sh
$ cd /opt/homebrew/Cellar/gcc/11.2.0
$ ls -l
...
-rwxr-xr-x  1 cdecl  admin   1.7M  8 28 13:41 g++-11
-rwxr-xr-x  1 cdecl  admin   1.7M  8 28 13:41 gcc-11
...

$ ln -s g++-11 g++
$ ln -s gcc-11 gcc
```
- .zshrc or .bashrc

```
export PATH=/opt/homebrew/Cellar/gcc/11.2.0/bin:$PATH
```

```sh
$ g++ -v
Using built-in specs.
COLLECT_GCC=g++
COLLECT_LTO_WRAPPER=/opt/homebrew/Cellar/gcc/11.2.0/libexec/gcc/aarch64-apple-darwin20/11.1.0/lto-wrapper
Target: aarch64-apple-darwin20
Configured with: ../configure --prefix=/opt/homebrew/Cellar/gcc/11.2.0 --libdir=/opt/homebrew/Cellar/gcc/11.2.0/lib/gcc/11 --disable-nls --enable-checking=release --enable-languages=c,c++,objc,obj-c++,fortran --program-suffix=-11 --with-gmp=/opt/homebrew/opt/gmp --with-mpfr=/opt/homebrew/opt/mpfr --with-mpc=/opt/homebrew/opt/libmpc --with-isl=/opt/homebrew/opt/isl --with-zstd=/opt/homebrew/opt/zstd --with-pkgversion='Homebrew GCC 11.2.0' --with-bugurl=https://github.com/Homebrew/homebrew-core/issues --build=aarch64-apple-darwin20 --with-system-zlib --disable-multilib --with-native-system-header-dir=/usr/include --with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 11.1.0 (Homebrew GCC 11.2.0)
```

## Windows

### chocolatey
- chocolatey : Windows 용 패키지 관리자 <https://chocolatey.org/>{:target="_blank"}
- choco 사용 gcc 설치 

### GCC (G++) 설치  
- 패키지가 2개중에 하나 선택 
	- mingw : <https://community.chocolatey.org/packages/mingw>{:target="_blank"}
	- winlibs : <https://community.chocolatey.org/packages/winlibs>{:target="_blank"}

> `winlibs`가 버전이 높고 `mingw`는 버전인 올라가면서 posix thread가 문제가 있음 

```sh
$ choco install winlibs -y

$ g++ -v
Using built-in specs.
COLLECT_GCC=g++
COLLECT_LTO_WRAPPER=c:/programdata/chocolatey/lib/winlibs/tools/mingw64/bin/../libexec/gcc/x86_64-w64-mingw32/10.2.0/lto-wrapper.exe
OFFLOAD_TARGET_NAMES=nvptx-none
Target: x86_64-w64-mingw32
Configured with: ../configure --prefix=/R/winlibs64_stage/_TMP_/inst_gcc-10.2.0/share/gcc --build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --with-pkgversion='MinGW-W64 x86_64-posix-seh, built by Brecht Sanders' --with-tune=generic --enable-checking=release --enable-threads=posix --disable-sjlj-exceptions --disable-libunwind-exceptions --disable-serial-configure --disable-bootstrap --enable-host-shared --enable-plugin --disable-default-ssp --disable-rpath --disable-libstdcxx-pch --enable-libstdcxx-time=yes --disable-libstdcxx-debug --disable-version-specific-runtime-libs --with-stabs --disable-symvers --enable-languages=c,c++,fortran,lto,objc,obj-c++,d --disable-gold --disable-nls --disable-stage1-checking --disable-win32-registry --disable-multilib --enable-ld --enable-libquadmath --enable-libada --enable-libssp --enable-libstdcxx --enable-lto --enable-fully-dynamic-string --enable-libgomp --enable-graphite --enable-mingw-wildcard --with-mpc=/d/Prog/winlibs64_stage/custombuilt --with-mpfr=/d/Prog/winlibs64_stage/custombuilt --with-gmp=/d/Prog/winlibs64_stage/custombuilt --with-isl=/d/Prog/winlibs64_stage/custombuilt --enable-install-libiberty --enable-__cxa_atexit --without-included-gettext --with-diagnostics-color=auto --with-libiconv --with-system-zlib --with-build-sysroot=/R/winlibs64_stage/_TMP_/gcc-10.2.0/build_mingw/mingw-w64 CFLAGS=-I/d/Prog/winlibs64_stage/custombuilt/include/libdl-win32 --enable-offload-targets=nvptx-none
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 10.2.0 (MinGW-W64 x86_64-posix-seh, built by Brecht Sanders)
```
---

#### 기타 툴 설치 

```sh
$ choco install make cmake grep sed awk -y
```