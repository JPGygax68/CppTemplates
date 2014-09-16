#s/\blibMyLibrary\b/libMyPackage/
#s/set(NAMESPACE [^)]*/set(NAMESPACE GPC\:\:Fonts/
#s/set(HEADER_FILES [^)]*/set(HEADER_FILES mytestlibrary.hpp/
s/set(SOURCE_FILES/#&/
s/#set(LIBRARY_TYPE "header-only"/set(LIBRARY_TYPE "header-only"/
