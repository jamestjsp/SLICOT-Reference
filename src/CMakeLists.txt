# CMakeLists.txt for SLICOT main sources (src)
include(GNUInstallDirs) # Ensure install paths are available

# Get all Fortran source files in the directory
file(GLOB SLICOT_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.f")
# Exclude example drivers if any accidentally placed here (unlikely)
# list(FILTER SLICOT_SOURCES EXCLUDE REGEX "^T.*\\.f$")

# Create the slicot library (without lpkaux objects initially)
add_library(slicot ${SLICOT_SOURCES})

# Set library properties
set_target_properties(slicot PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    POSITION_INDEPENDENT_CODE ON  # Important for shared libraries
    OUTPUT_NAME "slicot") # Keep the base name simple

# Add include directories if needed (e.g., if there were .h files)
# target_include_directories(slicot PUBLIC
#     $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> # Needed if headers are in src
#     $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}> # Where headers will be installed
# )

# Special flag for gfortran to handle function name mangling differences vs other compilers
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    target_compile_options(slicot PRIVATE -fallow-argument-mismatch)
    # Add case-insensitive name mangling if needed (usually not required with modern gfortran)
    # target_compile_options(slicot PRIVATE -fno-underscoring)
endif()

# Link with BLAS and LAPACK
target_link_libraries(slicot
    PUBLIC
        ${LAPACK_LIBRARIES}
        ${BLAS_LIBRARIES}
)

# Conditionally link auxiliary objects if requested by the user option
if(SLICOT_LINK_AUX_WRAPPERS)
    # Check if the lpkaux target exists (it should if src_aux was added)
    if(TARGET lpkaux)
        message(STATUS "Linking slicot library with auxiliary wrappers from lpkaux.")
        target_link_libraries(slicot PRIVATE $<TARGET_OBJECTS:lpkaux>)
    else()
        message(WARNING "SLICOT_LINK_AUX_WRAPPERS is ON but target lpkaux does not exist. Check CMake logic in the root CMakeLists.txt.")
    endif()
endif()

# Install the library targets
install(TARGETS slicot
        EXPORT SLICOTTargets # Add target to the export set defined in parent CMakeLists.txt
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Libraries
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Libraries
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT RuntimeLibraries) # For DLLs on Windows

# Install headers if any (Example - adapt if needed)
# install(FILES ${SLICOT_HEADERS} # Assuming SLICOT_HEADERS variable lists .h files
#         DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/slicot COMPONENT Headers)
