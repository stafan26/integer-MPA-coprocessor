/*
 ============================================================================
Name        : md5sum.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : MD5 sum computations
 ============================================================================
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <openssl/md5.h>
#include "md5sum.h"

unsigned char result[MD5_DIGEST_LENGTH];

//============================================================================
//MD5 sum implementation based on:
//https://stackoverflow.com/questions/1220046/how-to-get-the-md5-hash-of-a-file-in-c
//============================================================================
// Print the MD5 sum as hex-digits.
void print_md5_sum(FILE *outstream, unsigned char* md) {
    int i;
    for(i=0; i <MD5_DIGEST_LENGTH; i++) {
            fprintf(outstream, "%02x",md[i]);
    }
}
//============================================================================
// Get the size of the file by its file descriptor
unsigned long get_size_by_fd(int fd) {
    struct stat statbuf;
    if(fstat(fd, &statbuf) < 0) exit(-1);
    return statbuf.st_size;
}
//============================================================================
int md5sum_print(FILE *outstream, char *filename) {
    int file_descript;
    unsigned long file_size;
    char* file_buffer;

    file_descript = open(filename, O_RDONLY);
    if(file_descript < 0) exit(-1);

    file_size = get_size_by_fd(file_descript);

    file_buffer = mmap(0, file_size, PROT_READ, MAP_SHARED, file_descript, 0);
    MD5((unsigned char*) file_buffer, file_size, result);
    munmap(file_buffer, file_size);

    print_md5_sum(outstream, result);

    return 0;
}
//============================================================================
