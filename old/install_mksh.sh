# Install mksh                                                                                                 
PREFIX="../build"

echo "Installing mksh..."
git clone https://github.com/MirBSD/mksh
cd mksh
chmod +x Build.sh
#make PREFIX="$PREFIX" CC="$PREFIX/bin/musl-gcc"                                                               
#make install PREFIX="$PREFIX"                                                                                 
PREFIX="$PREFIX" ./Build.sh

##Installing the shell:

mkdir -p ../build/bin
mkdir -p ../build/etc
mkdir -p ../build/usr/share/docs/mksh
mkdir -p ../build/usr/share/man/man1

install mksh ../build/bin/mksh
chmod +x $PREFIX/bin/mksh

grep -x /bin/mksh ../build/etc/shells >/dev/null || echo /bin/mksh >> ../build/etc/shells
##Installing the manual:
# install -c -o root -g bin -m 444 FAQ.htm /usr/share/doc/mksh/

mkdir -p "$PREFIX/usr/share/doc/mksh"
install	FAQ.htm	"$PREFIX/usr/share/doc/mksh"
##plus either                                                                                                  
install lksh.1 mksh.1 "$PREFIX/usr/share/man/man1/"

