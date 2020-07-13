/*
 ============================================================================
Name        : md5sum.h
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : MD5 sum computations
 ============================================================================
 */

//============================================================================
//MD5 sum implementation based on:
//https://stackoverflow.com/questions/1220046/how-to-get-the-md5-hash-of-a-file-in-c
//============================================================================
// Print the MD5 sum as hex-digits.
void print_md5_sum(FILE *outstream, unsigned char* md);
//============================================================================
// Get the size of the file by its file descriptor
unsigned long get_size_by_fd(int fd);
//============================================================================
int md5sum_print(FILE *outstream, char *filename);
//============================================================================
