# lang - TBD in-progress compiler

progress so far:



download with:

``git clone https://github.com/Connor-GH/lang``

``cd lang``

compile with:

``make`` for a best-effort build (defaults to gdc)


``make CC={gcc,clang} DCC={dmd,gdc,ldc} DFLAGS="..." CFLAGS="..." CXXFLAGS="..."``
for a more specific build

# Mandatory Dependencies:
- clang/clang++ or gcc/g++
- gdc/dmd/ldc
- gmake
