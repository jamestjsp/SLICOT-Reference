# This file can be included to get a list of all SLICOT sources
# without having to re-list them in multiple places

# Main SLICOT Routines
set(SLICOT_CORE_SOURCES
    AB01MD.f AB01ND.f AB01OD.f AB04MD.f AB05MD.f AB05ND.f AB05OD.f
    AB05PD.f AB05QD.f AB05RD.f AB05SD.f AB07MD.f AB07ND.f AB08MD.f
    AB08MZ.f AB08ND.f AB08NW.f AB08NX.f AB08NY.f AB08NZ.f AB09AD.f
    # ... add more source files as needed
)

# Auxiliary SLICOT Routines
set(SLICOT_AUX_SOURCES
    MA01AD.f MA01BD.f MA01BZ.f MA01CD.f MA01DD.f MA01DZ.f MA02AD.f
    MA02AZ.f MA02BD.f MA02BZ.f MA02CD.f MA02CZ.f MA02DD.f MA02ED.f
    # ... add more source files as needed
)

# All SLICOT sources
set(SLICOT_ALL_SOURCES ${SLICOT_CORE_SOURCES} ${SLICOT_AUX_SOURCES})
