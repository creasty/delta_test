#include <stdio.h>
#include <stdbool.h>

#include "delta_test_native.h"

static VALUE mDeltaTest;
static VALUE mProfiler;

static dt_profiler_t *profile;


/*=== Helpers
==============================================================================================*/
/*  Event hook
-----------------------------------------------*/
static void
dt_profiler_event_hook(rb_event_flag_t event, VALUE data, VALUE self, ID mid, VALUE klass)
{
    if (self == mDeltaTest || klass == mProfiler) {
        return;
    }

    st_insert(profile->file_table, (st_data_t)rb_sourcefile(), Qtrue);
}

static void
dt_profiler_install_hook(VALUE self)
{
    rb_add_event_hook(dt_profiler_event_hook, RUBY_EVENT_CALL, self);
}

static void
dt_profiler_uninstall_hook()
{
    rb_remove_event_hook(dt_profiler_event_hook);
}


/*=== Initialize
==============================================================================================*/
static void
dt_profiler_init()
{
    profile = (dt_profiler_t *)malloc(sizeof(dt_profiler_t));

    profile->running    = Qfalse;
    profile->file_table = st_init_strtable();
}


/*=== Class methods
==============================================================================================*/
/**
 * .clean! -> self
 *
 * Uninstalls event hook
 */
static VALUE
dt_profiler_clean(VALUE self)
{
    st_clear(profile->file_table);

    profile->running = Qfalse;
    dt_profiler_uninstall_hook();

    return self;
}

/**
 * .start! -> self
 *
 * Starts recording profile data
 */
static VALUE
dt_profiler_start(VALUE self)
{
    st_clear(profile->file_table);

    if (profile->running == Qfalse) {
        profile->running = Qtrue;
        dt_profiler_install_hook(self);
    }

    return self;
}

/**
 * .stop! -> self
 *
 * Stops collecting profile data
 */
static VALUE
dt_profiler_stop(VALUE self)
{
    if (profile->running == Qtrue) {
        dt_profiler_uninstall_hook();
        profile->running = Qfalse;
    }

    return self;
}

/**
 * .running? -> Boolean
 *
 * Returns whether a profile is currently running
 */
static VALUE
dt_profiler_running(VALUE self)
{
    return profile->running;
}

/**
 * .last_result -> Array
 *
 * Returns an array of source files
 */
static int
dt_profiler_last_result_collect(st_data_t key, st_data_t value, st_data_t result)
{
    rb_ary_push((VALUE)result, rb_str_new2((const char *)key));

    return ST_CONTINUE;
}

static VALUE
dt_profiler_last_result(VALUE self)
{
    if (profile->running) {
        return Qnil;
    }

    VALUE result = rb_ary_new();
    st_foreach(profile->file_table, dt_profiler_last_result_collect, result);
    rb_gc_mark(result);

    return result;
}


/*=== Define
==============================================================================================*/
void Init_delta_test_native()
{
    mDeltaTest = rb_define_module("DeltaTest");
    mProfiler = rb_define_module_under(mDeltaTest, "Profiler");

    dt_profiler_init();

    rb_define_singleton_method(mProfiler, "clean!", dt_profiler_clean, 0);
    rb_define_singleton_method(mProfiler, "start!", dt_profiler_start, 0);
    rb_define_singleton_method(mProfiler, "stop!", dt_profiler_stop, 0);
    rb_define_singleton_method(mProfiler, "running?", dt_profiler_running, 0);
    rb_define_singleton_method(mProfiler, "last_result", dt_profiler_last_result, 0);
}
