#s/project(lib/project(/
s/#set(LIBRARY_TYPE .*/set(LIBRARY_TYPE "shared")/
#s/set(NAMESPACE [^)]*/set(NAMESPACE GPC\:\:Fonts/
#s/set(HEADER_FILES [^)]*/set(HEADER_FILES mytestlibrary.hpp/
s/#set(PREFIX/set (PREFIX/