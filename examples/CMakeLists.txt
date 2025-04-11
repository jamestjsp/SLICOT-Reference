# Build SLICOT examples
cmake_minimum_required(VERSION 3.15)
enable_testing()

# Find dependencies
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

# Create a file with all examples
file(GLOB EXAMPLE_SOURCES "*.f")

# Function to create an example program
function(add_slicot_example name)
    # Check if target already exists
    if(TARGET ${name})
        return()
    endif()
    
    # Check if the source file exists
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${name}.f")
        message(STATUS "Source file ${name}.f not found - skipping example")
        return()
    endif()
    
    add_executable(${name} "${CMAKE_CURRENT_SOURCE_DIR}/${name}.f")
    target_link_libraries(${name} PRIVATE slicot ${BLAS_LIBRARIES} ${LAPACK_LIBRARIES})
    set_target_properties(${name} PROPERTIES LINKER_LANGUAGE Fortran)
endfunction()

# Extract test program names from makefile
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/makefile_Unix" MAKEFILE_LINES)

# Find all test targets
set(PROCESSED_TARGETS "")
foreach(LINE ${MAKEFILE_LINES})
    # First, look for the actual executable targets (T*.o: format)
    if(LINE MATCHES "^(T[A-Z0-9]+):\\s+\\1\\.o")
        set(TEST_PROG "${CMAKE_MATCH_1}")
        
        # Skip if we've already processed this target
        list(FIND PROCESSED_TARGETS ${TEST_PROG} TARGET_INDEX)
        if(TARGET_INDEX EQUAL -1)
            list(APPEND PROCESSED_TARGETS ${TEST_PROG})
            
            # Add the test program
            add_slicot_example(${TEST_PROG})
        endif()
    endif()
endforeach()

# Now find the test runs and add tests for them
foreach(LINE ${MAKEFILE_LINES})
    # Look for lines like "AB01MD.exa: AB01MD.dat TAB01MD;"
    if(LINE MATCHES "^([A-Z][A-Z0-9]+)\\.exa:\\s+([A-Z][A-Z0-9]+)\\.dat\\s+(T[A-Z0-9]+);")
        set(TEST_NAME "${CMAKE_MATCH_1}")
        set(DATA_FILE "${CMAKE_MATCH_2}")
        set(EXEC_NAME "${CMAKE_MATCH_3}")
        
        # Only add test if we've successfully built the executable
        if(TARGET ${EXEC_NAME})
            # Create a test that runs the example
            add_test(NAME ${TEST_NAME}_test 
                     COMMAND ${CMAKE_COMMAND} -E env "INPUT_FILE=${DATA_FILE}.dat" "OUTPUT_FILE=${TEST_NAME}.exa"
                             $<TARGET_FILE:${EXEC_NAME}>)
                             
            # Set test properties for input/output
            set_tests_properties(${TEST_NAME}_test PROPERTIES
                ENVIRONMENT "INPUT_FILE=${CMAKE_CURRENT_SOURCE_DIR}/${DATA_FILE}.dat;OUTPUT_FILE=${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME}.exa")
        endif()
    endif()
endforeach()

# Install examples
if(SLICOT_INSTALL)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
            DESTINATION ${CMAKE_INSTALL_DOCDIR}/examples
            FILES_MATCHING PATTERN "*.f" PATTERN "*.dat")
endif()
