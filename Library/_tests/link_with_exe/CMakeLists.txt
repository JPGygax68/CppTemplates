cmake_minimum_required(VERSION 3.0)

add_executable(main main.cpp)

find_package(NSMyPackage REQUIRED)
target_link_libraries(NSMyPackage PRIVATE NSMyPackage) 