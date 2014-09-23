cmake_minimum_required(VERSION 3.0)

add_executable(main main.cpp)

find_package(libMyOrg_MyLibrary REQUIRED)
target_link_libraries(main PUBLIC MyOrg_MyLibrary) 