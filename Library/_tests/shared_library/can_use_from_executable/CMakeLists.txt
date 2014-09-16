cmake_minimum_required(VERSION 3.0)

add_executable(main main.cpp)

find_package(ORGMyLibrary REQUIRED)
target_link_libraries(main PUBLIC NSLevel1::NSLevel2::MyLibrary) 