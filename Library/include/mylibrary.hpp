#pragma once

//namespace nslevel1 {

#ifdef _WIN32
#   ifndef MYLIBRARY_HEADERONLY
#      ifdef MYLIBRARY_EXPORT
#          define MYLIBRARY_API __declspec(dllexport)
#      else
#          define MYLIBRARY_API __declspec(dllimport)
#      endif
#   else
#      define MYLIBRARY_API
#   endif
#endif

class MYLIBRARY_API MyClass {
public:
    void hello();
};

auto my_free_func(int arg1) -> int;

// inline implementations

//} // nslevel1