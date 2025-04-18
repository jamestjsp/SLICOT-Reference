# List of SLICOT source files
set(SLICOT_SOURCES
    # Core library files
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB01MD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB01ND.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB01OD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB04MD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB05MD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB05ND.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB05OD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB05PD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB05QD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB05RD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB05SD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB07MD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB07ND.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB08MD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AB08ND.f
    # Add more source files as needed
)

# Auxiliary routines
set(SLICOT_AUX_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/MB01PD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/MB01RD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/MB01SD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/MB02OD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/MB03OD.f
    ${CMAKE_CURRENT_SOURCE_DIR}/src/MB03UD.f
    # Add more auxiliary source files as needed
)

# Combine all sources
set(SLICOT_ALL_SOURCES ${SLICOT_SOURCES} ${SLICOT_AUX_SOURCES})
