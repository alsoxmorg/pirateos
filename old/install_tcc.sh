# getting tcc                                                                                                  
echo 'building and installing tcc'
wget https://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27.tar.bz2
tar -xvjf tcc-0.9.27.tar.bz2
cd tcc-0.9.27
./configure --config-musl
make
DESTDIR='../build/' make install
cd ..
