
set PROJECT=libdispatch
set REPO=https://github.com/apple/swift-corelibs-libdispatch.git
set TAG=

call "%~dp0\common.bat" prepare_project || exit /b 1

set BUILD_DIR="%SRCROOT%\%PROJECT%\build-%ARCH%-%BUILD_TYPE%"
if exist "%BUILD_DIR%" (rmdir /S /Q "%BUILD_DIR%" || exit /b 1)
mkdir "%BUILD_DIR%" || exit /b 1
cd "%BUILD_DIR%" || exit /b 1

echo.
echo ### Running cmake
:: CXX and linker flags below are to produce PDBs for release builds.
:: BlocksRuntime parameters provided to use blocks runtime from libobjc2 with libdispatch-own-blocksruntime.patch.
cmake .. %CMAKE_OPTIONS% ^
  -D BUILD_SHARED_LIBS=YES ^
  -D INSTALL_PRIVATE_HEADERS=YES ^
  -D CMAKE_CXX_FLAGS_RELWITHDEBINFO="/Zi" ^
  -D CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO="/INCREMENTAL:NO /DEBUG /OPT:REF /OPT:ICF" ^
  -D BlocksRuntime_INCLUDE_DIR=%INSTALL_PREFIX%\include ^
  -D BlocksRuntime_LIBRARIES=%INSTALL_PREFIX%\lib\objc.lib ^
  || exit /b 1

echo.
echo ### Building
ninja || exit /b 1

echo.
echo ### Installing
ninja install || exit /b 1

:: Install PDB file
xcopy /Y /F dispatch.pdb "%INSTALL_PREFIX%\lib\"

:: Move DLL from bin to lib directory.
move /Y "%INSTALL_PREFIX%\bin\dispatch.dll" "%INSTALL_PREFIX%\lib\"
