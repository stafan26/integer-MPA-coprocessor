/*
 ============================================================================
 Name        : settings.h
 Author      :
 Version     :
 Copyright   :
 Description : File with useful definitions and settings
 ============================================================================
 */
#ifndef SETTINGS_H_INCLUDED
#define SETTINGS_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define eps0_const 8.85418781762e-12
#define mu0_const  1.2566371e-6
#define c_const    ((float_t)(1.0/sqrt(eps0_const * mu0_const)))
#define pi_const   3.14159265358979323846264338327950288419716939937510
#define float_t double

/** Indexing and unsigned integer variables. */
typedef unsigned int uint_t;
typedef unsigned long ulong_t;
typedef unsigned long long ulonglong_t;
typedef int int_t;
typedef long long_t;
typedef long long longlong_t;

#endif
//============================================================================
