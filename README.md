# rpath_test

# 第一版测试：rpath对于运行时链接库路径的作用
编译选项中的-L 指定了编译时动态链接库的位置，而-rpath 指定了运行时动态链接库的默认位置。
只要路径指定正确，则编译得到的可执行文件可以直接运行，而不需要在ld.conf和LD_LIBRARY_PATH中设置动态库目录。
程序执行时，rpath的引用优先级高于LD_LIBRARY_PATH高于ld.conf，如果rpath中没有找到库文件，则依次往后查询。

# 第二版测试：rpath对于间接引用时链接路路径的作用
1、在bb中引用aa的函数，并把bb也编译成动态库：
  （1）假如使用 gcc -o libbb.so -shared -fPIC bb.c
      则bb与aa无关，ldd也无法看到bb引用aa的信息，
      这种情况下，最后编译可执行文件的时候，必须指定bb和aa库路径。
  （2）假如使用 gcc -o libbb.so -shared -fPIC bb.c -L ../aa -laa
      则ldd libbb.so,可以看到bb哪些符号引用了aa，但是没有aa的路径的信息，最后编译的时候依然要分别指定bb和aa的路径。  ====>   无效用法
  （3）假如使用 gcc -o libbb.so -shared -fPIC bb.c -L ../aa -Wl,-rpath /home/chenxu1/some_test/rpath_test/aa -laa
      则libbb.so中包含了aa的路径信息，最后编译的时候，只需指定bb的路径。  ========>  正确用法
      ### 注意：要用绝对路径，不要用相对路径！（因为后面继续编译的时候，相对路径大概率不一样）
2、在使用上述（3）编译libbb.so的情况下，编译可执行文件：
  （1）假如使用 gcc main.c -o test -L ./bb -lbb
      则编译可以通过（即不需要指定aa的路径），但是执行时需要指定bb的路径（也不需要指定aa路径）
  （2）假如使用 gcc main.c -o test -L ./bb -Wl,-rpath ./bb -lbb  ======>  正确（不过最好使用绝对路径）
      则执行时不需要额外指定任何路径。

# 第三版测试：rpath-link对于间接引用时链接路径的作用
1、首先在编译libbb.so的时候需要把aa链接进去，即第二版1（2）中的命令，而不是第二版1（1）中的命令，
  如果使用1（1），则libbb.so中没有aa的链接信息，bb和aa无关，最后编译可执行文件的时候，只能分别指定bb和aa的路径；===> rpath-link无用武之地
  如果使用1（2），则libbb.so中有aa的链接信息，只不过aa的路径是未知的。 ====> 此时才需要在后续的编译中使用rpath-link） =======> 正确用法
  （=== 这里收回bb的build.sh中对于第二个命令“make no sense”的注释 2333 ===）
2、一种错误的用法：
  我一开始以为是在编译bb的时候，通过rpath-link将aa路径保存进去，只对后续的编译起作用，而不对执行起作用。但这种理解的错误的
  例如使用 gcc -o libbb.so -shared -fPIC bb.c -L ../aa -Wl,-rpath-link /home/chenxu1/some_test/rpath_test/aa -laa
  这样是无效的。。
3、在libbb.so中链接了aa、但又没有通过-rpath指定aa路径的情况下（并且没有设置aa的LD_LIBRARY_PATH）：
  （1）假如使用 gcc main.c -o test -L ./bb -lbb
      则编译不通过，会报错"libaa.so, needed by ./bb/libbb.so, not found"
  （2）假如使用 gcc main.c -o test -L ./bb -lbb -Wl,-rpath-link /home/chenxu1/some_test/rpath_test/aa  =======>  正确用法
      则编译可以通过，，但是在执行的时候，依然需要指定aa和bb的路径   ======>   这正是rpath-link所要达到的效果。
      
