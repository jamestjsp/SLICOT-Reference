# SLICOT Installation Guide

This guide describes how to build and install the SLICOT library using CMake and CMake Presets.

## Prerequisites

*   **CMake:** Version 3.15 or later.
*   **C/C++ Compiler:** A C++11 compatible compiler (e.g., GCC via MinGW-w64 on Windows, GCC on Linux, Clang on macOS).
*   **Fortran Compiler:** A Fortran compiler compatible with your C/C++ compiler (e.g., `gfortran` via MinGW-w64 on Windows, `gfortran` on Linux/macOS).
*   **BLAS and LAPACK:** Implementations of BLAS and LAPACK libraries. CMake will attempt to find these automatically. Common sources include:
    *   Intel MKL (Can be used with GCC/gfortran, ensure correct linking flags)
    *   OpenBLAS
    *   System-provided libraries (e.g., via `apt`, `yum`, `brew`, MSYS2/MinGW packages)
    *   Netlib reference implementations (requires compilation).
*   **Build Tool:** A build tool supported by CMake (e.g., Ninja, Make). Ninja is recommended for faster builds and is the default in the provided presets.

## Building with CMake Presets (Recommended)

This project uses CMake Presets (`CMakePresets.json`) to simplify configuration and building across different platforms and compilers.

1.  **Choose a Preset:** Open the project in a CMake-aware IDE (like VS Code with CMake Tools, CLion) or use the command line. Ensure your chosen compiler toolchain (e.g., MinGW-w64 with gcc/g++/gfortran) is in your system's PATH. The available presets define common configurations:
    *   `windows-x64-debug` / `windows-x64-release` (Uses MinGW/Ninja by default)
    *   `linux-x64-debug` / `linux-x64-release` (Uses GCC/Ninja by default)
    *   `macos-x64-debug` / `macos-x64-release` (Uses Clang/gfortran/Ninja by default)

2.  **Configure:**
    *   **IDE:** Select the desired Configure Preset (e.g., `windows-x64-debug`). The IDE should run CMake automatically.
    *   **Command Line:**
        ```bash
        # Example for Windows Debug (ensure MinGW compilers are in PATH)
        cmake --preset windows-x64-debug

        # Example for Linux Debug
        # cmake --preset linux-x64-debug
        ```
        Replace `windows-x64-debug` with your chosen preset name.

3.  **Build:**
    *   **IDE:** Select the corresponding Build Preset (e.g., `Build Windows x64 Debug (MinGW)`) or build the default target.
    *   **Command Line:**
        ```bash
        # Example for Windows Debug build
        cmake --build --preset windows-x64-debug-build

        # Example for Linux Debug build
        # cmake --build --preset linux-x64-debug-build
        ```
        Use the build preset name corresponding to your configure preset (usually adding `-build`).

4.  **Install (Optional but Recommended):** The build process creates library files in the build directory. To install them to the location specified by `CMAKE_INSTALL_PREFIX` in the preset (defaults to `./install/<preset-name>`), run the install step:
    *   **IDE:** Build the `INSTALL` target.
    *   **Command Line:**
        ```bash
        # Example for Windows Debug install
        cmake --install build/windows-x64-debug --config Debug

        # Example for Linux Debug install
        # cmake --install build/linux-x64-debug --config Debug
        ```
        Or using the build preset:
        ```bash
        # Example for Windows Debug install using build preset
        cmake --build --preset windows-x64-debug-build --target install
        ```

5.  **Run Tests:**
    *   **IDE:** Run tests using the IDE's test runner, selecting the appropriate Test Preset (e.g., `Test Windows x64 Debug (MinGW)`).
    *   **Command Line (from build directory):**
        ```bash
        # Example for Windows Debug test
        # Navigate to the build directory first
        cd build/windows-x64-debug
        ctest -C Debug --output-on-failure
        cd ../..

        # Example for Linux Debug test
        # cd build/linux-x64-debug
        # ctest -C Debug --output-on-failure
        # cd ../..
        ```
        Or using the test preset:
        ```bash
        # Example for Windows Debug test using test preset
        ctest --preset windows-x64-debug-test

        # Example for Linux Debug test using test preset
        # ctest --preset linux-x64-debug-test
        ```

## Customization (CMakeUserPresets.json)

If you need to specify a different compiler path (if not in PATH), add custom compiler flags, or change other cache variables, create a `CMakeUserPresets.json` file in the project root directory. This file allows you to inherit from the base presets in `CMakePresets.json` and override specific settings without modifying the original file. See the provided `CMakeUserPresets.json` for examples.

## CMake Options

You can customize the build by setting CMake options during the configure step (e.g., using `-D<OPTION_NAME>=<VALUE>` on the command line or through IDE settings).

*   **`CMAKE_INSTALL_PREFIX`**: Specifies the directory where the library and documentation will be installed. Defaults are set in the presets (`install/<preset-name>`).
*   **`CMAKE_BUILD_TYPE`**: Specifies the build configuration (e.g., `Debug`, `Release`). Set by the presets.
*   **`CMAKE_C_COMPILER`**, **`CMAKE_CXX_COMPILER`**, **`CMAKE_Fortran_COMPILER`**: Specify the paths to the compilers. Defaults are set in the presets, but can be overridden (e.g., in `CMakeUserPresets.json`).
*   **`SLICOT_BUILD_EXAMPLES`**: Build the example programs and enable tests. Defaults to `OFF`. Set to `ON` to build and test the examples.
    ```bash
    # Example: Configure with examples enabled
    cmake --preset windows-x64-debug -DSLICOT_BUILD_EXAMPLES=ON
    ```
*   **`BUILD_SHARED_LIBS`**: Build SLICOT as a shared library (`.dll`, `.so`, `.dylib`) instead of a static library (`.lib`, `.a`). Defaults to `OFF`.

## Finding BLAS/LAPACK

CMake uses `find_package(BLAS)` and `find_package(LAPACK)` to locate these libraries. Ensure they are installed and discoverable by CMake.
*   On **Windows with MinGW**, you can install libraries like OpenBLAS via MSYS2/MinGW packages (e.g., `pacman -S mingw-w64-x86_64-openblas`). Alternatively, you can use a package manager like [vcpkg](https://vcpkg.io/) to install `openblas` or `mkl` and integrate it with CMake by setting the `CMAKE_TOOLCHAIN_FILE` variable during configuration (e.g., `-DCMAKE_TOOLCHAIN_FILE=[path/to/vcpkg]/scripts/buildsystems/vcpkg.cmake`). You can also download pre-built binaries and set environment variables like `OpenBLAS_HOME`.
*   On **Linux**, use your system package manager (e.g., `sudo apt install libopenblas-dev liblapack-dev` or `sudo yum install openblas-devel lapack-devel`).
*   On **macOS**, use Homebrew (e.g., `brew install openblas lapack`).

You might need to set environment variables (`MKLROOT`, `OpenBLAS_HOME`) or CMake variables (`-DBLAS_LIBRARIES=...`, `-DLAPACK_LIBRARIES=...`, `-DCMAKE_PREFIX_PATH=...`) if CMake cannot find the libraries automatically, especially if they are installed in non-standard locations.

## Using the Installed Library

After installation, you can use the SLICOT library in other CMake projects:

```cmake
find_package(SLICOT REQUIRED)

# ... later ...
target_link_libraries(your_target PRIVATE SLICOT::slicot)
```

Make sure the `CMAKE_PREFIX_PATH` includes the SLICOT installation directory (`install/<preset-name>`) when configuring your project.

