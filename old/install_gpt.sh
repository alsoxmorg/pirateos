#!/bin/bash

# Installer flags
NOROOT=0
DISABLE_RICING=0

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --noroot)
      NOROOT=1
      shift
      ;;
    --disable-ricing)
      DISABLE_RICING=1
      shift
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--noroot] [--disable-ricing]"
      exit 1
      ;;
  esac
done

# Build root directory
mkdir -p ./build
PREFIX="../build"

# Build and install musl libc
echo "Building and installing musl libc..."
git clone git://git.musl-libc.org/musl
cd musl
./configure --prefix="$PREFIX" --enable-static
make
make install
cd ..

# Build and install sbase
echo "Building and installing sbase..."
git clone https://git.suckless.org/sbase
cd sbase
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"
make install PREFIX="$PREFIX"
cd ..

# Build and install ubase
echo "Building and installing ubase..."
git clone https://git.suckless.org/ubase
cd ubase
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"
make install PREFIX="$PREFIX"
cd ..

# Build and install one true awk
echo "Building and installing one true awk..."
git clone https://github.com/onetrueawk/awk
cd awk
./configure --prefix="$PREFIX" --with-gnu-ld
make
cp a.out ../build/bin/awk
cp awk.1 ../build/share/man/man1/
cd ..

# Install mksh
echo "Installing mksh..."
git clone https://github.com/MirBSD/mksh
cd mksh
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"
make install PREFIX="$PREFIX"
cd ..

# Build and install mg
echo "Building and installing mg..."
git clone https://github.com/troglobit/mg
cd mg
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc -static"
make install PREFIX="$PREFIX"
cd ..

# Build and install farbfeld
echo "Building farbfeld, and converters..."
git clone https://git.suckless.org/farbfeld
cd farbfeld
make
make install PREFIX="$PREFIX"
cd ..

# Build termbox2
echo "Building termbox2..."
git clone https://github.com/termbox/termbox2
cd termbox2
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc -static"
cd ..

# Build lessismore pager
echo "Building lessismore, custom pager..."
cd lessismore
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc -static"
make install PREFIX="$PREFIX"
cd ..

# Create config directory
mkdir -p "$PREFIX/etc"
echo "Configuring the shell to use the Suckless tools..."
cp configs/* "$PREFIX/etc/"

# Copy helper scripts
cp scripts/* "$PREFIX/bin/"

# Vanity tweaks (ricing)
if [ "$DISABLE_RICING" -eq 0 ]; then
  echo "\n💅 Applying PirateOS ricing..."

  if [ "$NOROOT" -eq 0 ]; then
    echo '🏴 Hijacking MOTD...'
    sudo chmod -x /etc/update-motd.d/ 2>/dev/null
    sudo cp os-release/motd /etc/motd 2>/dev/null

    echo '🏴 Spoofing os-release...'
    mkdir -p rollback
    cp /etc/os-release ./rollback/
    sudo cp os-release/os-release.pirate /etc/os-release
  else
    echo "⚠️  --noroot set, skipping MOTD and os-release hijack"
    echo "⚓ TODO: Implement userland-based spoof (neofetch/uname wrapper)"
  fi
else
  echo "🎭 --disable-ricing set: skipping all vanity modifications"
fi

echo "\n✅ PirateOS installed."
echo "➡️  To activate the environment, run: source pirate.sh"
echo "➡️  To revert, run: source unpirate.sh"

