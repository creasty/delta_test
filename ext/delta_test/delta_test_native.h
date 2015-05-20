#ifndef __DELTA_TEST_NATIVE_H_LOADED__
#define __DELTA_TEST_NATIVE_H_LOADED__

#include <ruby.h>
#include <stdio.h>

#if RUBY_VERSION < 192
#error un-supported ruby version. Please upgrade to 1.9.3 or higher.
#endif

extern VALUE mDeltaTest;
extern VALUE mProfiler;

typedef struct _dt_profiler_list_t {
    const char *file_path;
    struct _dt_profiler_list_t *next;
} dt_profiler_list_t;

typedef struct {
    VALUE running;
    dt_profiler_list_t *list_head;
    dt_profiler_list_t *list_tail;
} dt_profiler_t;

#endif // __DELTA_TEST_NATIVE_H_LOADED__
