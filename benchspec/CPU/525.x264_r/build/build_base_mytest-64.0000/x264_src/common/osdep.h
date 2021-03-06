/*****************************************************************************
 * osdep.h: h264 encoder
 *****************************************************************************
 * Copyright (C) 2007-2008 x264 project
 *
 * Authors: Loren Merritt <lorenm@u.washington.edu>
 *          Laurent Aimar <fenrir@via.ecp.fr>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02111, USA.
 *****************************************************************************/

#ifndef X264_OSDEP_H
#define X264_OSDEP_H

#if !defined(SPEC_NO_AUTO_BYTEORDER) && (SPEC_AUTO_BYTEORDER == 0x4321 || SPEC_AUTO_BYTEORDER == 0x87654321)
# undef WORDS_BIGENDIAN
# define WORDS_BIGENDIAN
#endif

#if !defined(SPEC) || !defined(_LARGEFILE_SOURCE)
#define _LARGEFILE_SOURCE 1
#endif
#if !defined(SPEC) || !defined(_FILE_OFFSET_BITS)
#define _FILE_OFFSET_BITS 64
#endif
#include <stdio.h>
#include <sys/stat.h>

#include "config.h"

#if defined(SPEC_NEED_STDINT)
#include <pstdint.h>
#else
#ifdef HAVE_STDINT_H
#include <stdint.h>
#else
#include <inttypes.h>
#endif
#endif

#ifndef HAVE_LOG2F
#define log2f(x) (logf(x)/0.693147180559945f)
#define log2(x) (log(x)/0.693147180559945)
#endif

#if defined(SPEC_WINDOWS) || defined(_WIN32)
#include <io.h>    // _setmode()
#include <fcntl.h> // _O_BINARY
#endif

#if (defined(SYS_OPENBSD) && !defined(isfinite)) || defined(SYS_SunOS)
#define isfinite finite
#endif
#if defined(SPEC_WINDOWS) || defined(_WIN32)
#define rename(src,dst) (unlink(dst), rename(src,dst)) // POSIX says that rename() removes the destination, but win32 doesn't.
#ifndef strtok_r
#define strtok_r(str,delim,save) strtok(str,delim)
#endif

#endif


#if defined(SPEC) && defined(SPEC_WINDOWS) && !defined(SPEC_WINDOWS_MSVS2013)

#define strcasecmp  stricmp
#define strncasecmp  strnicmp
#define round(x) ((x-floor(x))>0.5 ? ceil(x) : floor(x))
#define isfinite _finite
#define snprintf _snprintf

#endif

#if defined(SPEC) && !defined(S_ISREG)
#   ifdef S_IFREG
#       define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#   else
#       define S_ISREG(m) 0
#   endif
#endif

#if !defined(PRId64)
# define PRId64 "ll" "d"
#endif
#if !defined(PRId32)
# define PRId32 "d"
#endif
#if !defined(PRIu64)
# define PRIu64 "ll" "u"
#endif
#if !defined(PRIu32)
# define PRIu32 "u"
#endif
#if !defined(SCNu64)
# define SCNu64 "ll" "u"
#endif
#if !defined(SCNu32)
# define SCNu32 "u"
#endif
#if !defined(PRIx64)
# define PRIx64 "ll" "x"
#endif
#if !defined(PRIx32)
# define PRIx32 "x"
#endif

#if !defined(SPEC_WINDOWS)
#define DECLARE_ALIGNED( var, n ) var __attribute__((aligned(n)))
#else
#define DECLARE_ALIGNED( var, n ) var
#endif /* SPEC_WINDOWS */
#define ALIGNED_16( var ) DECLARE_ALIGNED( var, 16 )
#define ALIGNED_8( var )  DECLARE_ALIGNED( var, 8 )
#define ALIGNED_4( var )  DECLARE_ALIGNED( var, 4 )

// ARM compiliers don't reliably align stack variables
// - EABI requires only 8 byte stack alignment to be maintained
// - gcc can't align stack variables to more even if the stack were to be correctly aligned outside the function
// - armcc can't either, but is nice enough to actually tell you so
// - Apple gcc only maintains 4 byte alignment
// - llvm can align the stack, but only in svn and (unrelated) it exposes bugs in all released GNU binutils...
#if defined(ARCH_ARM) && defined(SYS_MACOSX)
#define ALIGNED_ARRAY_8( type, name, sub1, ... )\
    uint8_t name##_u [sizeof(type sub1 __VA_ARGS__) + 7]; \
    type (*name) __VA_ARGS__ = (void*)((intptr_t)(name##_u+7) & ~7)
#else
#define ALIGNED_ARRAY_8( type, name, sub1, ... )\
    ALIGNED_8( type name sub1 __VA_ARGS__ )
#endif

#ifdef ARCH_ARM
#define ALIGNED_ARRAY_16( type, name, sub1, ... )\
    uint8_t name##_u [sizeof(type sub1 __VA_ARGS__) + 15];\
    type (*name) __VA_ARGS__ = (void*)((intptr_t)(name##_u+15) & ~15)
#else
#define ALIGNED_ARRAY_16( type, name, sub1, ... )\
    ALIGNED_16( type name sub1 __VA_ARGS__ )
#endif

#if !defined(SPEC) && defined(__GNUC__) && (__GNUC__ > 3 || __GNUC__ == 3 && __GNUC_MINOR__ > 0)
#define UNUSED __attribute__((unused))
#define ALWAYS_INLINE __attribute__((always_inline)) inline
#define NOINLINE __attribute__((noinline))
#define MAY_ALIAS __attribute__((may_alias))
#define x264_constant_p(x) __builtin_constant_p(x)
#define x264_nonconstant_p(x) (!__builtin_constant_p(x))
#else
#define UNUSED
#define ALWAYS_INLINE inline
#define NOINLINE
#define MAY_ALIAS
#define x264_constant_p(x) 0
#define x264_nonconstant_p(x) 0
#endif

/* threads */
#if defined(SYS_BEOS)
#include <kernel/OS.h>
#define x264_pthread_t               thread_id
static inline int x264_pthread_create( x264_pthread_t *t, void *a, void *(*f)(void *), void *d )
{
     *t = spawn_thread( f, "", 10, d );
     if( *t < B_NO_ERROR )
         return -1;
     resume_thread( *t );
     return 0;
}
#define x264_pthread_join(t,s)       { long tmp; \
                                       wait_for_thread(t,(s)?(long*)(*(s)):&tmp); }
#ifndef usleep
#define usleep(t)                    snooze(t)
#endif
#define HAVE_PTHREAD 1

#elif defined(HAVE_PTHREAD)
#include <pthread.h>
#define USE_REAL_PTHREAD

#else
#define x264_pthread_t               int
#define x264_pthread_create(t,u,f,d) 0
#define x264_pthread_join(t,s)
#endif //SYS_*

#ifdef USE_REAL_PTHREAD
#define x264_pthread_t               pthread_t
#define x264_pthread_create          pthread_create
#define x264_pthread_join            pthread_join
#define x264_pthread_mutex_t         pthread_mutex_t
#define x264_pthread_mutex_init      pthread_mutex_init
#define x264_pthread_mutex_destroy   pthread_mutex_destroy
#define x264_pthread_mutex_lock      pthread_mutex_lock
#define x264_pthread_mutex_unlock    pthread_mutex_unlock
#define x264_pthread_cond_t          pthread_cond_t
#define x264_pthread_cond_init       pthread_cond_init
#define x264_pthread_cond_destroy    pthread_cond_destroy
#define x264_pthread_cond_broadcast  pthread_cond_broadcast
#define x264_pthread_cond_wait       pthread_cond_wait
#define x264_pthread_attr_t          pthread_attr_t
#define x264_pthread_attr_init       pthread_attr_init
#define x264_pthread_attr_destroy    pthread_attr_destroy
#define X264_PTHREAD_MUTEX_INITIALIZER PTHREAD_MUTEX_INITIALIZER
#else
#define x264_pthread_mutex_t         int
#define x264_pthread_mutex_init(m,f) 0
#define x264_pthread_mutex_destroy(m)
#define x264_pthread_mutex_lock(m)
#define x264_pthread_mutex_unlock(m)
#define x264_pthread_cond_t          int
#define x264_pthread_cond_init(c,f)  0
#define x264_pthread_cond_destroy(c)
#define x264_pthread_cond_broadcast(c)
#define x264_pthread_cond_wait(c,m)
#define x264_pthread_attr_t          int
#define x264_pthread_attr_init(a)    0
#define x264_pthread_attr_destroy(a)
#define X264_PTHREAD_MUTEX_INITIALIZER 0
#endif

#define WORD_SIZE sizeof(void*)

#define asm __asm__

#ifndef SPEC
#if !defined(_WIN64) && !defined(__LP64__)
#if defined(__INTEL_COMPILER)
#define BROKEN_STACK_ALIGNMENT /* define it if stack is not mod16 */
#endif
#endif
#endif

#ifdef WORDS_BIGENDIAN
#define endian_fix(x) (x)
#define endian_fix64(x) (x)
#define endian_fix32(x) (x)
#define endian_fix16(x) (x)
#else
#if defined(__GNUC__) && defined(HAVE_MMX) && !defined(SPEC)
static ALWAYS_INLINE uint32_t endian_fix32( uint32_t x )
{
    asm("bswap %0":"+r"(x));
    return x;
}
#elif defined(__GNUC__) && defined(HAVE_ARMV6) && !defined(SPEC)
static ALWAYS_INLINE uint32_t endian_fix32( uint32_t x )
{
    asm("rev %0, %0":"+r"(x));
    return x;
}
#else
static ALWAYS_INLINE uint32_t endian_fix32( uint32_t x )
{
    return (x<<24) + ((x<<8)&0xff0000) + ((x>>8)&0xff00) + (x>>24);
}
#endif
#if defined(__GNUC__) && defined(ARCH_X86_64) && !defined(SPEC)
static ALWAYS_INLINE uint64_t endian_fix64( uint64_t x )
{
    asm("bswap %0":"+r"(x));
    return x;
}
#else

static ALWAYS_INLINE uint64_t endian_fix64( uint64_t x )
{
    return endian_fix32(x>>32) + ((uint64_t)endian_fix32(x)<<32);
}
#endif
static ALWAYS_INLINE intptr_t endian_fix( intptr_t x )
{
    return WORD_SIZE == 8 ? endian_fix64(x) : endian_fix32(x);
}
static ALWAYS_INLINE uint16_t endian_fix16( uint16_t x )
{
    return (x<<8)|(x>>8);
}
#endif

#if defined(__GNUC__) && (__GNUC__ > 3 || __GNUC__ == 3 && __GNUC_MINOR__ > 3)
#define x264_clz(x) __builtin_clz(x)
#define x264_ctz(x) __builtin_ctz(x)
#else
static int ALWAYS_INLINE x264_clz( uint32_t x )
{
    static uint8_t lut[16] = {4,3,2,2,1,1,1,1,0,0,0,0,0,0,0,0};
    int y, z = (((x >> 16) - 1) >> 27) & 16;
    x >>= z^16;
    z += y = ((x - 0x100) >> 28) & 8;
    x >>= y^8;
    z += y = ((x - 0x10) >> 29) & 4;
    x >>= y^4;
    return z + lut[x];
}

static int ALWAYS_INLINE x264_ctz( uint32_t x )
{
    static uint8_t lut[16] = {4,0,1,0,2,0,1,0,3,0,1,0,2,0,1,0};
    int y, z = (((x & 0xffff) - 1) >> 27) & 16;
    x >>= z;
    z += y = (((x & 0xff) - 1) >> 28) & 8;
    x >>= y;
    z += y = (((x & 0xf) - 1) >> 29) & 4;
    x >>= y;
    return z + lut[x&0xf];
}
#endif

#if defined(__GNUC__) && defined(HAVE_MMX)
/* Don't use __builtin_prefetch; even as recent as 4.3.4, GCC seems incapable of
 * using complex address modes properly unless we use inline asm. */
static ALWAYS_INLINE void x264_prefetch( void *p )
{
    asm volatile( "prefetcht0 %0"::"m"(*(uint8_t*)p) );
}
/* We require that prefetch not fault on invalid reads, so we only enable it on
 * known architectures. */
#elif defined(__GNUC__) && (__GNUC__ > 3 || __GNUC__ == 3 && __GNUC_MINOR__ > 1) &&\
      (defined(ARCH_X86) || defined(ARCH_X86_64) || defined(ARCH_ARM) || defined(ARCH_PPC))
#define x264_prefetch(x) __builtin_prefetch(x)
#else
#define x264_prefetch(x)
#endif

#ifdef USE_REAL_PTHREAD
#ifdef SYS_MINGW
#define x264_lower_thread_priority(p)\
{\
    x264_pthread_t handle = pthread_self();\
    struct sched_param sp;\
    int policy = SCHED_OTHER;\
    pthread_getschedparam( handle, &policy, &sp );\
    sp.sched_priority -= p;\
    pthread_setschedparam( handle, policy, &sp );\
}
#else
#include <unistd.h>
#define x264_lower_thread_priority(p) { UNUSED int nice_ret = nice(p); }
#endif /* USE_REAL_PTHREAD */
#else
#define x264_lower_thread_priority(p)
#endif

static inline uint8_t x264_is_regular_file( FILE *filehandle )
{
#ifdef SPEC
    return 1;
#else
    struct stat file_stat;
    if( fstat( fileno( filehandle ), &file_stat ) )
        return 0;
    return S_ISREG( file_stat.st_mode );
#endif
}

#endif /* X264_OSDEP_H */
