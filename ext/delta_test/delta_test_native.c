#include "delta_test_native.h"
#include <assert.h>

#define DEBUG 0

VALUE mDeltaTest;
VALUE cProfiler;


/*=== Helpers
==============================================================================================*/
/*  List
-----------------------------------------------*/
static void
dt_profiler_list_add(dt_profiler_t *profile, const char *file_path)
{
    dt_profiler_list_t *list = (dt_profiler_list_t *)malloc(sizeof(dt_profiler_list_t));

    list->file_path = file_path;
    list->next = NULL;

    if (!profile->list_head) {
        profile->list_head = list;
    }

    if (profile->list_tail) {
        profile->list_tail->next = list;
    }

    profile->list_tail = list;
}

static void
dt_profiler_list_clean(dt_profiler_t *profile)
{
    dt_profiler_list_t *tmp;
    dt_profiler_list_t *list = profile->list_head;

    profile->list_head = NULL;
    profile->list_tail = NULL;

    while (list) {
        tmp = list->next;
        list->next = NULL;
        free(list);
        list = tmp;
    }
}


/*  To struct
-----------------------------------------------*/
static dt_profiler_t*
dt_profiler_get_profile(VALUE self)
{
    // Can't use Data_Get_Struct because that triggers the event hook,
    // ending up in endless recursion.
    return (dt_profiler_t*)RDATA(self)->data;
}


/*  Event hook
-----------------------------------------------*/
static void
dt_profiler_event_hook(rb_event_flag_t event, VALUE data, VALUE self, ID mid, VALUE klass)
{
    // If we don't have a valid method id, try to retrieve one
    if (mid == 0) {
        rb_frame_method_id_and_class(&mid, &klass);
    }

    dt_profiler_t* profile = dt_profiler_get_profile(data);

    // Special case
    if (self == mDeltaTest || klass == cProfiler) {
        return;
    }

    const char* source_file = rb_sourcefile();
    dt_profiler_list_add(profile, source_file);

#if DEBUG
    const char* class_name   = NULL;
    const char* method_name  = rb_id2name(mid);
    unsigned int source_line = rb_sourceline();

    if (klass != 0) {
        klass = (BUILTIN_TYPE(klass) == T_ICLASS ? RBASIC(klass)->klass : klass);
    }

    class_name = rb_class2name(klass);

    printf("%s:%2d  %s#%s\n", source_file, source_line, class_name, method_name);
    fflush(stdout);
#endif
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


/*=== Memory
==============================================================================================*/
static void
dt_profiler_free(dt_profiler_t *profile)
{
    dt_profiler_list_clean(profile);
    xfree(profile);
}

static VALUE
dt_profiler_allocate(VALUE klass)
{
    dt_profiler_t* profile;
    VALUE profile_obj = Data_Make_Struct(klass, dt_profiler_t, 0, dt_profiler_free, profile);

    profile->running = Qfalse;
    profile->list_head = NULL;
    profile->list_tail = NULL;

    return profile_obj;
}


/*=== Class methods
==============================================================================================*/
/**
 * .new -> self
 *
 * Returns a new profiler
 */
static VALUE
dt_profiler_initialize(VALUE self)
{
    return self;
}

/**
 * .clean! -> self
 *
 * Uninstalls event hook
 */
static VALUE
dt_profiler_clean(VALUE self)
{
    dt_profiler_uninstall_hook();
    return self;
}


/*=== Instance methods
==============================================================================================*/
/**
 * #start -> self
 *
 * Starts recording profile data
 */
static VALUE
dt_profiler_start(VALUE self)
{
    dt_profiler_t* profile = dt_profiler_get_profile(self);

    dt_profiler_list_clean(profile);

    if (profile->running == Qfalse) {
        profile->running = Qtrue;
        dt_profiler_install_hook(self);
    }

    return self;
}

/**
 * #stop -> self
 *
 * Stops collecting profile data
 */
static VALUE
dt_profiler_stop(VALUE self)
{
    dt_profiler_t* profile = dt_profiler_get_profile(self);

    if (profile->running == Qtrue) {
        dt_profiler_uninstall_hook();
        profile->running = Qfalse;
    }

    return self;
}

/**
 * #running? -> Boolean
 *
 * Returns whether a profile is currently running
 */
static VALUE
dt_profiler_running(VALUE self)
{
    dt_profiler_t* profile = dt_profiler_get_profile(self);
    return profile->running;
}

/**
 * #result -> Array
 *
 * Returns an array of source files
 */
static VALUE
dt_profiler_result(VALUE self)
{
    dt_profiler_t* profile = dt_profiler_get_profile(self);
    dt_profiler_list_t *list = profile->list_head;

    VALUE result = rb_ary_new();

    if (profile->running) {
        return result;
    }

    while (list) {
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
    cProfiler = rb_define_class_under(mDeltaTest, "Profiler", rb_cObject);

    rb_define_alloc_func(cProfiler, dt_profiler_allocate);

    rb_define_singleton_method(cProfiler, "clean!", dt_profiler_clean, 0);

    rb_define_method(cProfiler, "initialize", dt_profiler_initialize, 0);
    rb_define_method(cProfiler, "start", dt_profiler_start, 0);
    rb_define_method(cProfiler, "stop", dt_profiler_stop, 0);
    rb_define_method(cProfiler, "running?", dt_profiler_running, 0);
    rb_define_method(cProfiler, "result", dt_profiler_result, 0);
}
