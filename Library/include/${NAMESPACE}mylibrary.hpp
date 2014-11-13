#pragma once

#ifdef _WIN32
#   ifndef MyOrg_MyLibrary_HEADERONLY
#      ifdef MyOrg_MyLibrary_EXPORTS
#          define MYORG_MYLIBRARY_API __declspec(dllexport)
#      else
#          define MYORG_MYLIBRARY_API __declspec(dllimport)
#      endif
#   else
#      define MYORG_MYLIBRARY_API
#   endif
#endif

//namespace nslevel1 {

class MYORG_MYLIBRARY_API MyClass {
public:
    void hello();
};

auto my_free_func(int arg1) -> int;

// inline implementations

//} // nslevel1