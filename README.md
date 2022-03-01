# rpath_test

# 第一版测试：rpath对于运行时链接库路径的作用
编译选项中的-L 指定了编译时动态链接库的位置，而-rpath 指定了运行时动态链接库的默认位置。
只要路径指定正确，则编译得到的可执行文件可以直接运行，而不需要在ld.conf和LD_LIBRARY_PATH中设置动态库目录。
程序执行时，rpath的引用优先级高于LD_LIBRARY_PATH高于ld.conf，如果rpath中没有找到库文件，则依次往后查询。
