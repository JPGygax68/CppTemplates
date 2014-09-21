#pragma once

//namespace nslevel1 {

#ifdef _WIN32
#   ifndef ORGMYLIBRARY_HEADERONLY
#      ifdef ORGMYLIBRARY_EXPORT
#          define ORGMYLIBRARY_API __declspec(dllexport)
#      else
#          define ORGMYLIBRARY_API __declspec(dllimport)
#      endif
#   else
#      define ORGMYLIBRARY_API
#   endif
#endif

class ORGMYLIBRARY_API MyClass {
public:
    void hello();
};

auto my_free_func(int arg1) -> int;

// inline implementations

//} // nslevel1