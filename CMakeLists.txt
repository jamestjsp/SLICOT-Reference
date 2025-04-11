cmake_minimum_required(VERSION 3.15)

# Project definition
project(SLICOT VERSION 5.9.0 LANGUAGES Fortran)

# Options
option(SLICOT_BUILD_SHARED_LIBS "Build shared libraries" ON)
option(SLICOT_BUILD_EXAMPLES "Build examples" ON)
option(SLICOT_INSTALL "Generate installation target" ON)

# Setup build properties
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Use shared libraries if requested
if(SLICOT_BUILD_SHARED_LIBS)
    set(BUILD_SHARED_LIBS ON)
endif()

# Include standard modules
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Find BLAS and LAPACK - be more specific about what we need
set(BLA_VENDOR All)
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

# Install only from here, not from src directory
if(SLICOT_INSTALL)
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
endif()
