#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <stdlib.h>


typedef int (*fptr)(int, int);


int main(){

    char my_inpu[32];
    char my_oper[64];
    int a,b;
    while(scanf("%s %d %d", my_inpu, &a, &b)){

    snprintf(my_oper, sizeof(my_oper), "./lib%s.so", my_inpu);    

    void* handle = dlopen(my_oper, RTLD_LAZY); // bringing the library into memory
   
   //from here also correct
    fptr func = (fptr)dlsym(handle, my_inpu);                 // getting a pointer to the add function
    int result = func(a, b);
    printf("%d\n", result);

    dlclose(handle);
}

    return 0;
}
