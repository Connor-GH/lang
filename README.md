# lang - TBD in-progress compiler

progress so far:

code parser works:

- ~155000 lines parsed per second (gcc/gdc)

- ~218000 lines parsed per second (ldc2/clang LTO)



WIP/needs work:
- driver parsing - WIP
- syntax tree building - WIP
- syntax extensions (beyond arithmetic; functions, etc) - NEEDSWORK
- codegen - NEEDSWORK
- performance improvements - WIP


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
