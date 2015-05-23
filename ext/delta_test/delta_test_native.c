#include "delta_test_native.h"
#include <assert.h>

VALUE mDeltaTest;
VALUE mProfiler;

static dt_profiler_t *profile;
static VALUE profile_obj;


/*=== Helpers
==============================================================================================*/
/*  List
-----------------------------------------------*/
static dt_profiler_list_t *
dt_profiler_list_create()
{
    dt_profiler_list_t *list = (dt_profiler_list_t *)malloc(sizeof(dt_profiler_list_t));

    list->file_path = NULL;
    list->next      = NULL;

    return list;
}

static void
dt_profiler_list_add(const char *file_path)
{
    dt_profiler_list_t *list = NULL;

    if (profile->list_tail) {
        if (!profile->list_tail->file_path) {
          list = profile->list_tail;
          profile->list_head = list;
        } else if (profile->list_tail->next) {
            list = profile->list_tail->next;
        } else {
            list = dt_profiler_list_create();
            profile->list_tail->next = list;
        }
    } else {
        list = dt_profiler_list_create();
        profile->list_head = list;
    }

    profile->list_tail = list;

    list->file_path = file_path;
}

static void
dt_profiler_list_clean(bool is_free_list)
{
    dt_profiler_list_t *tmp;
    dt_profiler_list_t *list = profile->list_head;

    if (is_free_list) {
        profile->list_head = NULL;
        profile->list_tail = NULL;

        while (list) {
            tmp = list->next;
            list->next = NULL;
            free(list);
            list = tmp;
        }
    } else {
        profile->list_tail = profile->list_head;

        while (list) {
            list->file_path = NULL;
            list = list->next;
        }
    }
}


/*  Event hook
-----------------------------------------------*/
static void
dt_profiler_event_hook(rb_event_flag_t event, VALUE data, VALUE self, ID mid, VALUE klass)
{
    if (self == mDeltaTest || klass == mProfiler) {
        return;
    }

    dt_profiler_list_add(rb_sourcefile());
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

    profile->running   = Qfalse;

    profile->list_head = NULL;
    profile->list_tail = NULL;
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
    profile->running = Qfalse;
    dt_profiler_list_clean(false);
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
    dt_profiler_list_clean(false);

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
static VALUE
dt_profiler_last_result(VALUE self)
{
    dt_profiler_list_t *list = profile->list_head;

    if (profile->running) {
        return Qnil;
    }

    VALUE result = rb_ary_new();
    rb_gc_mark(result);

    while (list && list->file_path) {
        rb_ary_push(result, rb_str_new2(list->file_path));
        list = list->next;
    }

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
