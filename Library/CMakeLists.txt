# Adapted from https://github.com/ComicSansMS/libstratcom/blob/master/CMakeLists.txt
cmake_minimum_required(VERSION 3.0)

# Project name
project(libMyOrg_MyLibrary)

# Version (semantic: major, minor, patch-level)
set(VERSION_MAJOR 0)
set(VERSION_MINOR 0)
set(VERSION_PATCH 1)

# Namespace (container for include files, added to include directory; e.g. "nslevel1/nslevel2")
set(NAMESPACE NSLevel1::NSLevel2)

# Library type: options are "shared", "static" and "header-only"
#set(LIBRARY_TYPE "header-only")

# Source & header files
set(SOURCE_FILES mylibrary.cpp)
set(HEADER_FILES mylibrary.hpp)

# Special: embeddable files
#set(EMBEDDABLE_FILES "text.txt" "shader.glsl")

# Required packages
#set(REQUIRED_PACKAGES GLEW)

# Subdirectory (below "include") for header files (will be derived from namespace if not specified)
#set(HEADERS_SUBDIRECTORY "nslevel1/nslevel2")

# Testsuite
#set(TESTSUITE_FILES part1.cpp part2.cpp)



#----------------------------------------------------------------------
# ONLY EDIT PAST THIS POINT IF CUSTOM CONFIGURATION IS NEEDED
#----------------------------------------------------------------------

# Assemble version components into single string
set(PROJECT_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
# Undefine so as not to "bleed" into subproject settings
set(VERSION_MAJOR)
set(VERSION_MINOR)
set(VERSION_PATCH)

# Analyze project name
string(SUBSTRING ${PROJECT_NAME} 0 3 prefix)
if (NOT (prefix STREQUAL "lib"))
  message(WARNING "This is a library project, so its name should begin with \"lib\" by convention")
  set(NAKED_PROJECT_NAME "${PROJECT_NAME}")
else()
  string(SUBSTRING "${PROJECT_NAME}" 3 -1 NAKED_PROJECT_NAME)
endif()

if (LIBRARY_TYPE STREQUAL "header-only" AND SOURCE_FILES)
  message(FATAL_ERROR "Library type is defined as \"header-only\" but SOURCE_FILES is not empty")
endif()
if (NOT (LIBRARY_TYPE STREQUAL "header-only") AND (NOT SOURCE_FILES))
  message(FATAL_ERROR "SOURCE_FILES is empty but library is not \"header-only\"")
endif()

if (NOT LIBRARY_TYPE)
  if (NOT SOURCE_FILES) 
    set(LIBRARY_TYPE "header-only")
  else()
    set(LIBRARY_TYPE "shared")
  endif()
endif()

# Adjust namespace
if (NAMESPACE) 
  if (NOT NAMESPACE MATCHES "::$")
    set(NAMESPACE "${NAMESPACE}::")
  endif()
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

# Compose source file paths
foreach(source ${SOURCE_FILES})
  list(APPEND TARGET_SOURCE_FILES "src/${source}")
endforeach()
set(SOURCE_FILES) # do not pass to subdirs

# Compose header file paths
foreach(header ${HEADER_FILES})
  list(APPEND TARGET_HEADER_FILES "include/${HEADERS_SUBDIRECTORY}/${header}")
endforeach()
set(HEADER_FILES) # do not pass to subdirs

# Special: embeddable files

if (EMBEDDABLE_FILES)

  set(GENERATED ${CMAKE_CURRENT_BINARY_DIR}/generated)
  include_directories(${GENERATED})

  # Find the GPC Bin2C utility
  find_package(GPCBin2C REQUIRED)

  # Generate header files from the embeddables
  # (also create a list of the embeddables as source files for the target)
  # (also create a list of embeddable header files generated from the embeddable files)

  set(TARGET_EMBEDDABLE_FILES)
  set(EMBEDDABLE_HEADER_FILES )
  foreach(embeddable ${EMBEDDABLE_FILES})
      set(header_file "${GENERATED}/${embeddable}.h")
      add_custom_command(
          OUTPUT ${header_file}
          DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/${embeddable}
          COMMAND GPCBin2C --input=${CMAKE_CURRENT_SOURCE_DIR}/src/${embeddable} --output=${header_file}
      )
      set(TARGET_EMBEDDABLE_FILES ${TARGET_EMBEDDABLE_FILES} "src/${embeddable}")
      set(EMBEDDABLE_HEADER_FILES ${EMBEDDABLE_HEADER_FILES} ${header_file})
  endforeach()

  SOURCE_GROUP("Embeddable Files" FILES ${TARGET_EMBEDDABLE_FILES})

endif(EMBEDDABLE_FILES)

# Compute the name of the (main) target
set(TARGET_NAME "${PROJECT_NAME}")  # used to be ${NAKED_PROJECT_NAME}

# Create the (main) target
if (LIBRARY_TYPE STREQUAL "shared")
  add_library(${TARGET_NAME} SHARED ${TARGET_SOURCE_FILES} ${TARGET_HEADER_FILES})
elseif (LIBRARY_TYPE STREQUAL "static")
  add_library(${TARGET_NAME} STATIC ${TARGET_SOURCE_FILES} ${TARGET_HEADER_FILES})
elseif( LIBRARY_TYPE STREQUAL "header-only")
  # TODO: warning if source files defined ?
  add_library(${TARGET_NAME} INTERFACE)
endif()

string(TOUPPER ${TARGET_NAME} TARGET_NAME_PREPROC)
if (LIBRARY_TYPE STREQUAL "header-only")
  target_compile_definitions(${TARGET_NAME} INTERFACE ${TARGET_NAME}_HEADERONLY)
else()
  #target_compile_definitions(${TARGET_NAME} PRIVATE ${TARGET_NAME}_EXPORT)
  if(MSVC)
    target_compile_options(${TARGET_NAME} PRIVATE /W4)
  else()
    target_compile_options(${TARGET_NAME} PRIVATE -pedantic -Wall -std=c++11)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      target_compile_options(${TARGET_NAME} PRIVATE -stdlib=libc++)
    endif()
  endif()
endif()

# Dependencies on external packages

foreach(pkg ${REQUIRED_PACKAGES})
  find_package(${pkg} REQUIRED)
  string(TOUPPER ${pkg} pkg_uc)
  if (NOT ${${pkg_uc}_FOUND})
    message(FATAL_ERROR "Required package not found: ${pkg}")
  endif()
  #message("Required package: ${pkg} \"${${pkg_uc}_FOUND}\" ${${pkg_uc}_LIBRARIES} ${${pkg_uc}_INCLUDE_DIRS}")
  # TODO: handling for PRIVATE, PUBLIC, and INTERFACE linking)
  target_link_libraries(${TARGET_NAME} PUBLIC ${${pkg_uc}_LIBRARIES})
  target_include_directories(${TARGET_NAME} PUBLIC ${${pkg_uc}_INCLUDE_DIRS})
endforeach()

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

if (NOT TESTSUITE_FILES)
    set(TESTSUITE_FILES "test.cpp")
endif()

set(testsuite_filenames "testsuite/test.cpp")
foreach(file ${TESTSUITE_FILES})
    list(APPEND testsuite_filenames "testsuite/${file}")
endforeach()

add_executable(testsuite ${testsuite_filenames})
target_link_libraries(testsuite ${TARGET_NAME})

find_package(Boost) # for some reason, specifying the component (unit_test_framework) won't work
target_include_directories(testsuite PRIVATE ${Boost_INCLUDE_DIRS})
target_link_libraries(testsuite ${Boost_LIBRARIES})

add_test(NAME testsuite COMMAND testsuite CONFIGURATIONS Debug)

#------------------------------------------------
# Installation - specify files to package

install(TARGETS ${TARGET_NAME} EXPORT ${PROJECT_NAME}Targets
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
  ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}Version.cmake
  VERSION ${PACKAGE_VERSION}
  COMPATIBILITY SameMajorVersion
)

# Installation - build tree specific package config files
export(EXPORT ${PROJECT_NAME}Targets FILE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}Targets.cmake")
configure_file(${PROJECT_SOURCE_DIR}/ProjectConfig.cmake.in
  ${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  @ONLY
)

#------------------------------------------------
# Export build tree
#

export(PACKAGE ${PROJECT_NAME})

# Installation - relocatable package config files
configure_package_config_file(${PROJECT_SOURCE_DIR}/ProjectConfig.cmake.in
                              ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PROJECT_NAME}Config.cmake
                              INSTALL_DESTINATION cmake
)

#------------------------------------------------
# Installation (final part)
#

install(EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
    DESTINATION "cmake"
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PROJECT_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/${PROJECT_NAME}Version.cmake
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
  set(${PROJECT_NAME}_DOC_DIR ${PROJECT_BINARY_DIR}/doc)
  configure_file(${PROJECT_SOURCE_DIR}/Doxyfile.in ${${PROJECT_NAME}_DOC_DIR}/Doxyfile @ONLY)
  add_custom_target(doxygen-doc
    COMMAND ${DOXYGEN_EXECUTABLE}
    WORKING_DIRECTORY ${${PROJECT_NAME}_DOC_DIR}
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
