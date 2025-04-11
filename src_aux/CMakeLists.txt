# CMakeLists.txt for SLICOT auxiliary sources (src_aux)

# Get all Fortran source files in the directory
file(GLOB LPKAUX_SOURCES "*.f")

# Add our LAPACK compatibility file if it exists
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/lapack_compat.f")
    list(APPEND LPKAUX_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/lapack_compat.f")
endif()

# Create the lpkaux library
add_library(lpkaux ${LPKAUX_SOURCES})

# Set library properties
set_target_properties(lpkaux PROPERTIES 
    POSITION_INDEPENDENT_CODE ON)

# Add include directories if needed
# target_include_directories(lpkaux PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# Link with BLAS and LAPACK
target_link_libraries(lpkaux PUBLIC ${LAPACK_LIBRARIES} ${BLAS_LIBRARIES})

# Special flag for gfortran to handle function name mangling
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    target_compile_options(lpkaux PRIVATE -fallow-argument-mismatch)
endif()

# Install the library if needed
if(SLICOT_INSTALL)
    install(TARGETS lpkaux 
            EXPORT SLICOTTargets
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
