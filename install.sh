#!/bin/bash

#Goals of the installer
# 1. build and Install musl in a user directory tree
# 2. build and Install suckless sbase, ubase (in our build tree)
# 3. Build and install one true awk (requires gnu bison)
# 4. Build and Install mksh
# 5. Build and install mg
# 6. build a custom 'more' pager.
# Vanity tweeks, ricing!
# 7. if rooted Backup your os-release, and install new pirate release to spoof the distro
## 7.1. (pending) if no root, hack neofetch/uname.
# 8. if rooted (sudo), disable MOTD, and install new pirate motd
# X. copy scripts into bin/

#build errrors (farbfeld) (whereis png?)

mkdir ./build

# Set the prefix directory
# each build directory will download to the root of the project
# and after you cd into the project to build, the prefix will be ../build
PREFIX='../build' #/opt/suckless

# Set the dependencies
DEPS=(gcc binutils bison)

# Check if dependencies are installed
#for dep in "${DEPS[@]}"; do
#  if! command -v "$dep" &> /dev/null; then
#    echo "Error: $dep is not installed. Please install it before proceeding."
#    exit 1
#  fi
#done

# Build and install musl libc
echo "Building and installing musl libc..."
git clone git://git.musl-libc.org/musl
cd musl
./configure --prefix="$PREFIX" --enable-static
make
make install
cd ..


# getting tcc                                                                                                  
echo 'building and installing tcc'
wget https://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27.tar.bz2
tar -xvjf tcc-0.9.27.tar.bz2
cd tcc-0.9.27
./configure --config-musl
make
DESTDIR='../build/' make install
ln -s $PREFIX/usr/local/bin/tcc $PREFIX/bin/tcc #for a single PATH
cd ..

# Build and install sbase
echo "Building and installing sbase..."
git clone https://git.suckless.org/sbase
cd sbase
#make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"
PREFIX="$PREFIX" CC="$PREFIX/usr/local/bin/tcc"
make install PREFIX="$PREFIX"
cd ..

# Build and install ubase
echo "Building and installing ubase..."
git clone https://git.suckless.org/ubase
cd ubase
#make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"
make PREFIX="$PREFIX" CC="$PREFIX/usr/local/bin/tcc"
make install PREFIX="$PREFIX"
cd ..

# Build and install one true awk
echo "Building and installing one true awk..."
git clone https://github.com/onetrueawk/awk
cd awk
./configure --prefix="$PREFIX" --with-gnu-ld
make
#make install
cp a.out ../build/bin/awk
cp awk.1 ../build/share/man/man1/
cd ..

# Install mksh
#echo "Installing mksh..."
#git clone https://github.com/MirBSD/mksh
#cd mksh
#chmod +x Build.sh
#make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"
#make install PREFIX="$PREFIX"
#PREFIX="$PREFIX" ./Build.sh

##Installing the shell:
#mkdir -p ../build/etc
#install -c -s -g bin -m 555 mksh ../build/bin/mksh
#grep -x /bin/mksh ../build/etc/shells >/dev/null || echo /bin/mksh >> ../build/etc/shells
##Installing the manual:
# install -c -o root -g bin -m 444 FAQ.htm /usr/share/doc/mksh/
#mkdir -p "$PREFIX/share/docs/mksh"
#install FAQ.htm "$PREFIX/usr/share/doc/mksh"
##plus either
#install -c -o root -g bin -m 444 lksh.1 mksh.1 "$PREFIX/usr/share/man/man1/"

#Run the regression test suite: ./test.sh
#Please also read the sample file dot.mkshrc and the fine manual.
#cd ..

# Install mksh                                                                                                 
PREFIX="../build"

echo "Installing mksh..."
git clone https://github.com/MirBSD/mksh
cd mksh
chmod +x Build.sh

PREFIX="$PREFIX" ./Build.sh

##Installing the shell:

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/etc
mkdir -p $PREFIX/usr/share/docs/mksh
mkdir -p $PREFIX/usr/share/man/man1

install mksh $PREFIX/bin/mksh
chmod +x $PREFIX/bin/mksh
grep -x /bin/mksh ../build/etc/shells >/dev/null || echo /bin/mksh >> ../build/etc/shells
##Installing the manual:
# install -c -o root -g bin -m 444 FAQ.htm /usr/share/doc/mksh/

mkdir -p "$PREFIX/usr/share/doc/mksh"
install	FAQ.htm	"$PREFIX/usr/share/doc/mksh"
##plus either                                                                                                 
install lksh.1 mksh.1 "$PREFIX/usr/share/man/man1/"
cd ..

# Build and install mg
echo "Building and installing mg..."
git clone https://github.com/troglobit/mg
cd mg
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc -static"
make install PREFIX="$PREFIX"
cd .. #go back to install root

# build ant install farbfeld
echo "building farbfeld, and converters"
git clone https://git.suckless.org/farbfeld
cd farbfeld
#make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc -static"
make #we need to figure out how to get png support but for now make will do.
make install PREFIX="$PREFIX"
cd ..

#try https://github.com/kyx0r/nextvi
#echo "Building traditional vi (heirloom-ex-vi)..."
#git clone https://github.com/n-t-roff/heirloom-ex-vi.git
#cd heirloom-ex-vi
#make CC="$PREFIX/bin/musl-gcc"
#cp ex vi view "$PREFIX/bin/"
#cd ..

echo "building termbox"
git clone https://github.com/termbox/termbox2
cd termbox2
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc -static"
cd ..

# #############apps #########################
echo "building lessismore, custom pager"
cd apps/lessismore
make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc -static"
make install PREFIX="$PREFIX"
cd ../

echo "building ffpirate gaph tools"
cd ffpirateview/
cd make
echo "installing all to userbase - ~/.local/bin/"
make install
echo "done"
cd ../../

mkdir -p "$PREFIX/etc"

# Configure the shell to use the Suckless tools
echo "Configuring the shell to use the Suckless tools..."
cp configs/* "$PREFIX/etc/"
#echo "export PATH=\"$PREFIX/bin:\$PATH\"" > "$PREFIX/etc/mkshrc"

#copy scripts (like startx) into bin
# these are mainly hacks, to help a sane environment
cp scripts/* $PREFIX/bin/

echo 'vanity scripts - hijack motd'
sudo chmod -x /etc/update-motd.d/
sudo cp os-release/motd /etc/motd

echo 'changing os-release'
mkdir -p rollback
cp /etc/os-release ./rollback/
sudo cp os-release/os-release.pirate /etc/os-release

echo "✅ PirateOS installed."
echo "➡️  (todo)To activate the environment, run: source pirate.sh"
echo "➡️  (todo)To revert, run: source unpirate.sh"

