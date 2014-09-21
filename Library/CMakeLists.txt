# Adapted from https://github.com/ComicSansMS/libstratcom/blob/master/CMakeLists.txt
cmake_minimum_required(VERSION 3.0)

# Project name
project(libMyLibrary)

# Version (semantic: major, minor, patch-level)
set(VERSION_MAJOR 0)
set(VERSION_MINOR 0)
set(VERSION_PATCH 1)

# Namespace (container for include files, added to include directory; e.g. "nslevel1/nslevel2")
set(NAMESPACE NSLevel1::NSLevel2)

# The "prefix" is a short form of the namespace; it will be prefixed to the package name
# If none is specified, it will be derived from the namespace
#set(PREFIX ORG)

# Library type: default is "shared", other options are "static" and "header-only"
#set(LIBRARY_TYPE "header-only")

# Source & header files
set(SOURCE_FILES mylibrary.cpp)
set(HEADER_FILES mylibrary.hpp)

# Package name
# Default value is PREFIX + project name
#set(PACKAGE_NAME ORGMyLibrary)

# Subdirectory (below "include") for header files (will be derived from namespace if not specified)
#set(HEADERS_SUBDIRECTORY "nslevel1/nslevel2")

# Define this if it can't or shouldn't be derived from the project name
#set(TARGET_NAME MyLibrary)




#----------------------------------------------------------------------
# ONLY EDIT PAST THIS POINT IF CUSTOM CONFIGURATION IS NEEDED
#----------------------------------------------------------------------

# Assemble version components into single string
set(PROJECT_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
# Undefine so as not to pass into subprojects
set(VERSION_MAJOR)
set(VERSION_MINOR)
set(VERSION_PATCH)

# "Naked" project name
string(SUBSTRING ${PROJECT_NAME} 0 3 prefix)
if (prefix STREQUAL "lib")
  string(SUBSTRING "${PROJECT_NAME}" 3 -1 NAKED_PROJECT_NAME)
else()
  set(NAKED_PROJECT_NAME "${PROJECT_NAME}")
endif()

# Adjust namespace
if (NAMESPACE) 
  if (NOT NAMESPACE MATCHES "::$")
    set(NAMESPACE "${NAMESPACE}::")
  endif()
endif()

# Prefix (short form of namespace)
if (NOT PREFIX)
  string(REPLACE "::" "" PREFIX "${NAMESPACE}")
  string(TOUPPER "${PREFIX}" PREFIX)
endif()

# Check that we have a package name, use the project name otherwise
if (NOT PACKAGE_NAME)
  set(PACKAGE_NAME "${PREFIX}${NAKED_PROJECT_NAME}")
endif()

# Derive headers subdirectory from namespace (unless explicitly specified)
if (NOT HEADERS_SUBDIRECTORY)
  string(REPLACE "::" ";" parts ${NAMESPACE}) 
  foreach(part ${parts})
    string(TOLOWER ${part} part)
    list(APPEND headers "${part}")
  endforeach()
  string(REPLACE ";" "/" HEADERS_SUBDIRECTORY "${headers}")
  message(STATUS "Headers subdirectory derived from namespace: ${HEADERS_SUBDIRECTORY}")
endif()

# Assemble source file paths
foreach(source ${SOURCE_FILES})
  list(APPEND TARGET_SOURCE_FILES "src/${source}")
endforeach()
set(SOURCE_FILES) # do not pass to subdirs

# Compose header file paths
foreach(header ${HEADER_FILES})
  list(APPEND TARGET_HEADER_FILES "include/${HEADERS_SUBDIRECTORY}/${header}")
endforeach()
set(HEADER_FILES) # do not pass to subdirs

# Check / compute the name of the (main) target
if (NOT TARGET_NAME)
  set(TARGET_NAME "${NAKED_PROJECT_NAME}")
endif()

# Create the (main) target
if (NOT LIBRARY_TYPE OR (LIBRARY_TYPE STREQUAL "shared"))
  add_library(${TARGET_NAME} SHARED ${TARGET_SOURCE_FILES} ${TARGET_HEADER_FILES})
elseif( LIBRARY_TYPE STREQUAL "header-only")
  # TODO: warning if source files defined ?
  add_library(${TARGET_NAME} INTERFACE)
endif()

set(TARGET_NAME_PREPROC "${PREFIX}${TARGET_NAME}")
string(TOUPPER ${TARGET_NAME_PREPROC} TARGET_NAME_PREPROC)
if (LIBRARY_TYPE STREQUAL "header-only")
  target_compile_definitions(${TARGET_NAME} INTERFACE ${TARGET_NAME_PREPROC}_HEADERONLY)
else()
  target_compile_definitions(${TARGET_NAME} PRIVATE ${TARGET_NAME_PREPROC}_EXPORT)
  if(MSVC)
    target_compile_options(${TARGET_NAME} PRIVATE /W4)
  else()
    target_compile_options(${TARGET_NAME} PRIVATE -pedantic -Wall -std=c++11)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      target_compile_options(${TARGET_NAME} PRIVATE -stdlib=libc++)
    endif()
  endif()
endif()

if (EXAMPLE_EXTERNAL_DEPENDENCY)

  # external dependency - hidapi
  set(HIDAPI_BINARY_DIR ${PROJECT_BINARY_DIR}/hidapi_build)

  find_package(Git REQUIRED)
  include(ExternalProject)
  ExternalProject_Add(hidapi
      GIT_REPOSITORY https://github.com/signal11/hidapi.git
      GIT_TAG hidapi-0.8.0-rc1
      UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/external/hidapi/CMakeLists.txt .
      BINARY_DIR ${HIDAPI_BINARY_DIR}
      INSTALL_COMMAND ""
      LOG_BUILD 1
      LOG_TEST 1
      LOG_INSTALL 1
  )

  source_group(include FILES ${HEADER_FILES})

  add_dependencies(stratcom hidapi)
  if(MSVC)
      target_link_libraries(stratcom LINK_PRIVATE ${HIDAPI_BINARY_DIR}/$<CONFIG>/hidapi.lib setupapi.lib)
  else()
      if(APPLE)
          target_link_libraries(stratcom LINK_PRIVATE ${HIDAPI_BINARY_DIR}/libhidapi.a "-framework IOKit" "-framework CoreFoundation")
      else()
          target_link_libraries(stratcom LINK_PRIVATE ${HIDAPI_BINARY_DIR}/libhidapi.a udev)
      endif()
  endif()
  target_include_directories(stratcom PRIVATE ${HIDAPI_BINARY_DIR}/hidapi)

endif(EXAMPLE_EXTERNAL_DEPENDENCY)

if (LIBRARY_TYPE STREQUAL "header-only")
  target_include_directories(${TARGET_NAME} INTERFACE $<INSTALL_INTERFACE:include> $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>)
else()
  target_include_directories(${TARGET_NAME} PUBLIC $<INSTALL_INTERFACE:include> $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>)
  set_property(TARGET ${TARGET_NAME} PROPERTY VERSION ${PROJECT_VERSION})
  set_property(TARGET ${TARGET_NAME} PROPERTY SOVERSION ${VERSION_MAJOR})
  set_property(TARGET ${TARGET_NAME} PROPERTY DEBUG_POSTFIX d)
endif()

#------------------------------------------------
# Test suite 

# Prerequisites

include(CTest)
#enable_testing()

add_executable(testsuite testsuite/test.cpp)
target_link_libraries(testsuite ${TARGET_NAME})

find_package(Boost) # for some reason, specifying the component (unit_test_framework) won't work
target_include_directories(testsuite PRIVATE ${Boost_INCLUDE_DIRS})
target_link_libraries(testsuite ${Boost_LIBRARIES})

add_test(NAME testsuite COMMAND testsuite CONFIGURATIONS Debug)

#------------------------------------------------
# Installation - specify files to package

install(TARGETS ${TARGET_NAME} EXPORT ${PACKAGE_NAME}Targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  INCLUDES DESTINATION include
)
install(FILES ${TARGET_HEADER_FILES} DESTINATION include/${HEADERS_SUBDIRECTORY})
if(MSVC)
  if (NOT LIBRARY_TYPE STREQUAL "header-only")
    install(FILES $<TARGET_FILE_DIR:${TARGET_NAME}>/${TARGET_NAME}d.pdb DESTINATION bin CONFIGURATIONS Debug)
  endif()
  #install(FILES LICENSE.txt DESTINATION ".")
endif()
include(CmakePackageConfigHelpers)
write_basic_package_version_file(
  ${CMAKE_BINARY_DIR}/cmake/${PACKAGE_NAME}Version.cmake
  VERSION ${PACKAGE_VERSION}
  COMPATIBILITY SameMajorVersion
)

# installation - build tree specific package config files
export(EXPORT ${PACKAGE_NAME}Targets FILE ${CMAKE_BINARY_DIR}/${PACKAGE_NAME}Targets.cmake NAMESPACE ${NAMESPACE})
configure_file(${PROJECT_SOURCE_DIR}/ProjectConfig.cmake.in
  ${CMAKE_BINARY_DIR}/${PACKAGE_NAME}Config.cmake
  @ONLY
)

#------------------------------------------------
# Export build tree
#

export(PACKAGE ${PACKAGE_NAME})

# installation - relocatable package config files
configure_package_config_file(${PROJECT_SOURCE_DIR}/ProjectConfig.cmake.in
                              ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PACKAGE_NAME}Config.cmake
                              INSTALL_DESTINATION cmake
)

#------------------------------------------------
# Installation (final part)
#

install(EXPORT ${PACKAGE_NAME}Targets
    FILE ${PACKAGE_NAME}Targets.cmake
    DESTINATION "cmake"
)
install(FILES
    ${CMAKE_BINARY_DIR}/cmake/${PACKAGE_NAME}Config.cmake
    ${CMAKE_BINARY_DIR}/cmake/${PACKAGE_NAME}Version.cmake
    DESTINATION "cmake"
)

#------------------------------------------------
# Uninstall target
#

# TODO: find a way to remove directory structure too ?

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

#------------------------------------------------
# documentation
#

find_package(Doxygen)
if(DOXYGEN_FOUND)
  set(${PACKAGE_NAME}_DOC_DIR ${PROJECT_BINARY_DIR}/doc)
  configure_file(${PROJECT_SOURCE_DIR}/Doxyfile.in ${${PACKAGE_NAME}_DOC_DIR}/Doxyfile @ONLY)
  add_custom_target(doxygen-doc
    COMMAND ${DOXYGEN_EXECUTABLE}
    WORKING_DIRECTORY ${${PACKAGE_NAME}_DOC_DIR}
    COMMENT "Building doxygen documentation"
    SOURCES ${PROJECT_SOURCE_DIR}/Doxyfile.in
  )
  source_group("" FILES ${PROJECT_SOURCE_DIR}/Doxyfile.in)
endif()

#-------------------------------------------------
# Example application
#

option(BUILD_EXAMPLE_APPLICATIONS "Check this option to build the sample applications" OFF)
if(BUILD_EXAMPLE_APPLICATIONS)
  add_subdirectory(examples)
  if(WIN32)
    add_custom_command(TARGET stratcom POST_BUILD 
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:stratcom> ${CMAKE_BINARY_DIR}/examples
    )
  endif()
endif()
