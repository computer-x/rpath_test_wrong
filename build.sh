# passed when compiling,
# need set LD_LIBRARY_PATH when running.
#gcc main.c -o test -L ./aa -laa

# seem to wrong, cannot compile.
#gcc main.c -o test -Wl,-rpath ./aa -laa

# passed when compiling,
# alse passed when running, because path of lib has been set to exec file.
gcc main.c -o test -L ./aa -Wl,-rpath ./aa -laa

# put libaa.so in ./aa, passed when compilng,
# then put libaa.so in ./aa/tmp, passed when running.
#gcc main.c -o test -L ./aa -Wl,-rpath ./aa/tmp -laa
