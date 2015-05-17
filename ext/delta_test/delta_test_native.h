#ifndef __DELTA_TEST_NATIVE_H_LOADED__
#define __DELTA_TEST_NATIVE_H_LOADED__

#include <ruby.h>
#include <stdio.h>

#if RUBY_VERSION < 192
#error un-supported ruby version. Please upgrade to 1.9.3 or higher.
#endif

extern VALUE mDeltaTest;
extern VALUE cProfiler;

typedef struct {
    VALUE running;
    VALUE result;
} dt_profiler_t;

#endif // __DELTA_TEST_NATIVE_H_LOADED__
