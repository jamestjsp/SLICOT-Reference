# CMakeLists.txt for SLICOT auxiliary routines (src_aux)
include(GNUInstallDirs) # Ensure install paths are available

# Get all Fortran source files in the directory
file(GLOB SLICOT_AUX_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.f")

# Create the auxiliary library as an OBJECT library
add_library(lpkaux OBJECT ${SLICOT_AUX_SOURCES})

# Set library properties
set_target_properties(lpkaux PROPERTIES
    POSITION_INDEPENDENT_CODE ON # Good practice even for object libraries
)
# Output name is not relevant for OBJECT libraries

# Add include directories if needed
# target_include_directories(lpkaux PUBLIC ...)

# Special flag for gfortran
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    target_compile_options(lpkaux INTERFACE -fallow-argument-mismatch) # Use INTERFACE for object libs
    # target_compile_options(lpkaux INTERFACE -fno-underscoring)
endif()

# No installation needed for OBJECT libraries usually
# install(TARGETS lpkaux ...) # Remove or keep commented out
