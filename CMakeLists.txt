cmake_minimum_required(VERSION 3.15)

# Project definition
project(SLICOT VERSION 5.9.0 LANGUAGES Fortran)

# Options
option(SLICOT_BUILD_SHARED_LIBS "Build shared libraries" OFF) # Default to static
option(SLICOT_BUILD_EXAMPLES "Build the SLICOT example programs and tests" OFF)
option(SLICOT_USE_ILP64 "Build with 64-bit integers (ILP64)" OFF) # Add ILP64 option

# Setup build properties
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Set library type based on option
if(SLICOT_BUILD_SHARED_LIBS)
    set(BUILD_SHARED_LIBS ON)
else()
    set(BUILD_SHARED_LIBS OFF)
endif()

# Add ILP64 flags if requested
if(SLICOT_USE_ILP64)
  message(STATUS "ILP64 build requested.")
  if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    set(ILP64_FLAGS "-fdefault-integer-8")
    message(STATUS "Using gfortran ILP64 flag: ${ILP64_FLAGS}")
  elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel" OR CMAKE_Fortran_COMPILER_ID MATCHES "IntelLLVM")
    set(ILP64_FLAGS "-i8")
    message(STATUS "Using Intel Fortran ILP64 flag: ${ILP64_FLAGS}")
  else()
    message(WARNING "ILP64 requested, but compiler flags are unknown for ${CMAKE_Fortran_COMPILER_ID}. Manual configuration may be required.")
    set(ILP64_FLAGS "")
  endif()
  # Add flags globally - apply to slicot and examples
  add_compile_options(${ILP64_FLAGS})
endif()

# Include standard modules
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(CTest)

# Find BLAS and LAPACK - BLA_VENDOR might be set by presets
# Default to searching all vendors if not set
if(NOT DEFINED BLA_VENDOR)
  set(BLA_VENDOR "All")
endif()
message(STATUS "Searching for BLAS/LAPACK vendor: ${BLA_VENDOR}")
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

# Check for specific functions in LAPACK we need
include(CheckFortranFunctionExists)
set(CMAKE_REQUIRED_LIBRARIES ${LAPACK_LIBRARIES} ${BLAS_LIBRARIES})
check_fortran_function_exists(dgegs_ HAVE_DGEGS)

if(NOT HAVE_DGEGS)
    message(STATUS "dgegs_ function not found in LAPACK - will use compatibility wrapper")
endif()

# Compilation settings
if (CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fallow-argument-mismatch")
endif()

# Add subdirectories
add_subdirectory(src_aux)
add_subdirectory(src)

# Only build examples if requested
if(SLICOT_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Conditionally enable testing
if(SLICOT_BUILD_EXAMPLES)
    enable_testing()
endif()

# Install the export targets
install(EXPORT SLICOTTargets
    FILE SLICOTTargets.cmake
    NAMESPACE SLICOT::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SLICOT)

# Create and install the config file
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/SLICOTConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/SLICOTConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SLICOT)

# Create and install the version file
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/SLICOTConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion)

# Install the config files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/SLICOTConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/SLICOTConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SLICOT)

# Conditionally install example documentation
if(SLICOT_BUILD_EXAMPLES)
    # The actual installation command is inside examples/CMakeLists.txt
    # but we might want to mention the component here if needed.
    # install(DIRECTORY examples/ DESTINATION ${CMAKE_INSTALL_DOCDIR}/examples ...)
endif()

message(STATUS "  Build Examples: ${SLICOT_BUILD_EXAMPLES}")
