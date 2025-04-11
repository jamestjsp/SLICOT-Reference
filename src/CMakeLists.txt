# CMakeLists.txt for SLICOT main sources (src)

# Get all Fortran source files in the directory
file(GLOB SLICOT_SOURCES "*.f")

# Create the slicot library
add_library(slicot ${SLICOT_SOURCES})

# Set library properties
set_target_properties(slicot PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    POSITION_INDEPENDENT_CODE ON
    OUTPUT_NAME "slicot")

# Add include directories if needed
# target_include_directories(slicot PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# Special flag for gfortran to handle function name mangling
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    target_compile_options(slicot PRIVATE -fallow-argument-mismatch)
    # Add case-insensitive name mangling if needed
    # target_compile_options(slicot PRIVATE -fno-underscoring)
endif()

# Link with BLAS, LAPACK, and the auxiliary library
target_link_libraries(slicot 
    PUBLIC 
        ${LAPACK_LIBRARIES}
        ${BLAS_LIBRARIES}
    PRIVATE 
        lpkaux)

# Make sure lpkaux is built first
add_dependencies(slicot lpkaux)

# Install the library, but don't export it (export is done in main CMakeLists.txt)
if(SLICOT_INSTALL)
    install(TARGETS slicot
            EXPORT SLICOTTargets  # This is fine, as long as the export itself is only installed once
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
