# Build and install ubase

PREFIX='../build/'

echo "Building and installing ubase..."
git clone https://git.suckless.org/ubase
cd ubase
#make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"                                                               
make PREFIX="$PREFIX" CC="$PREFIX/usr/local/bin/tcc"
make install PREFIX="$PREFIX"
cd ..
