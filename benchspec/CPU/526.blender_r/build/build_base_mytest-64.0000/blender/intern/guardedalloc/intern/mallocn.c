/*
 * ***** BEGIN GPL LICENSE BLOCK *****
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * Contributor(s): Brecht Van Lommel
 *                 Campbell Barton
 *
 * ***** END GPL LICENSE BLOCK *****
 */

/** \file guardedalloc/intern/mallocn.c
 *  \ingroup MEM
 *
 * Guarded memory allocation, and boundary-write detection.
 */

#include "MEM_guardedalloc.h"

/* to ensure strict conversions */
#include "../../source/blender/blenlib/BLI_strict_flags.h"

#include <assert.h>

#include "mallocn_intern.h"

size_t (*MEM_allocN_len)(const void *vmemh) = MEM_lockfree_allocN_len;
void (*MEM_freeN)(void *vmemh) = MEM_lockfree_freeN;
void *(*MEM_dupallocN)(const void *vmemh) = MEM_lockfree_dupallocN;
void *(*MEM_reallocN_id)(void *vmemh, size_t len, const char *str) = MEM_lockfree_reallocN_id;
void *(*MEM_recallocN_id)(void *vmemh, size_t len, const char *str) = MEM_lockfree_recallocN_id;
void *(*MEM_callocN)(size_t len, const char *str) = MEM_lockfree_callocN;
void *(*MEM_mallocN)(size_t len, const char *str) = MEM_lockfree_mallocN;
void *(*MEM_mallocN_aligned)(size_t len, size_t alignment, const char *str) = MEM_lockfree_mallocN_aligned;
void *(*MEM_mapallocN)(size_t len, const char *str) = MEM_lockfree_mapallocN;
void (*MEM_printmemlist_pydict)(void) = MEM_lockfree_printmemlist_pydict;
void (*MEM_printmemlist)(void) = MEM_lockfree_printmemlist;
void (*MEM_callbackmemlist)(void (*func)(void *)) = MEM_lockfree_callbackmemlist;
void (*MEM_printmemlist_stats)(void) = MEM_lockfree_printmemlist_stats;
void (*MEM_set_error_callback)(void (*func)(const char *)) = MEM_lockfree_set_error_callback;
bool (*MEM_check_memory_integrity)(void) = MEM_lockfree_check_memory_integrity;
void (*MEM_set_lock_callback)(void (*lock)(void), void (*unlock)(void)) = MEM_lockfree_set_lock_callback;
void (*MEM_set_memory_debug)(void) = MEM_lockfree_set_memory_debug;
size_t (*MEM_get_memory_in_use)(void) = MEM_lockfree_get_memory_in_use;
size_t (*MEM_get_mapped_memory_in_use)(void) = MEM_lockfree_get_mapped_memory_in_use;
unsigned int (*MEM_get_memory_blocks_in_use)(void) = MEM_lockfree_get_memory_blocks_in_use;
void (*MEM_reset_peak_memory)(void) = MEM_lockfree_reset_peak_memory;
size_t (*MEM_get_peak_memory)(void) = MEM_lockfree_get_peak_memory;

#ifndef NDEBUG
const char *(*MEM_name_ptr)(void *vmemh) = MEM_lockfree_name_ptr;
#endif

void *aligned_malloc(size_t size, size_t alignment)
{
#if defined(SPEC)
       void* orig;
       void* data;
       if(alignment < 1) return 0;
/* power of 2 assertion made by callers in blender source */
/* overallocate */
       orig = malloc(size + alignment + sizeof(void*));
/* pad for original pointer storage */
       data = (void*)( ((uintptr_t)orig + sizeof(void*)) );
/* align */
       data = (void*)( ((uintptr_t)data + (uintptr_t)alignment - 1) & ~(uintptr_t)(alignment - 1));
/* store the original pointer */
       *(void**)((uintptr_t)data - sizeof(void*)) = orig;

       return data;

#else /* !SPEC */
#ifdef _WIN32
	return _aligned_malloc(size, alignment);
#elif defined(__APPLE__)
	/* On Mac OS X, both the heap and the stack are guaranteed 16-byte aligned so
	 * they work natively with SSE types with no further work.
	 */
	assert(alignment == 16);
	(void)alignment;
	return malloc(size);
#elif defined(__FreeBSD__) || defined(__NetBSD__)
	void *result;

	if (posix_memalign(&result, alignment, size)) {
		/* non-zero means allocation error
		 * either no allocation or bad alignment value
		 */
		return NULL;
	}
	return result;
#else  /* This is for Linux. */
	return memalign(alignment, size);
#endif
#endif /* !SPEC */
}

void aligned_free(void *ptr)
{
#if defined(SPEC)
/* free the saved original pointer */
       free(*(void**)((uintptr_t)ptr - sizeof(void*)));
#else
#ifdef _WIN32
	_aligned_free(ptr);
#else
	free(ptr);
#endif
#endif
}

void MEM_use_guarded_allocator(void)
{
	MEM_allocN_len = MEM_guarded_allocN_len;
	MEM_freeN = MEM_guarded_freeN;
	MEM_dupallocN = MEM_guarded_dupallocN;
	MEM_reallocN_id = MEM_guarded_reallocN_id;
	MEM_recallocN_id = MEM_guarded_recallocN_id;
	MEM_callocN = MEM_guarded_callocN;
	MEM_mallocN = MEM_guarded_mallocN;
	MEM_mallocN_aligned = MEM_guarded_mallocN_aligned;
	MEM_mapallocN = MEM_guarded_mapallocN;
	MEM_printmemlist_pydict = MEM_guarded_printmemlist_pydict;
	MEM_printmemlist = MEM_guarded_printmemlist;
	MEM_callbackmemlist = MEM_guarded_callbackmemlist;
	MEM_printmemlist_stats = MEM_guarded_printmemlist_stats;
	MEM_set_error_callback = MEM_guarded_set_error_callback;
	MEM_check_memory_integrity = MEM_guarded_check_memory_integrity;
	MEM_set_lock_callback = MEM_guarded_set_lock_callback;
	MEM_set_memory_debug = MEM_guarded_set_memory_debug;
	MEM_get_memory_in_use = MEM_guarded_get_memory_in_use;
	MEM_get_mapped_memory_in_use = MEM_guarded_get_mapped_memory_in_use;
	MEM_get_memory_blocks_in_use = MEM_guarded_get_memory_blocks_in_use;
	MEM_reset_peak_memory = MEM_guarded_reset_peak_memory;
	MEM_get_peak_memory = MEM_guarded_get_peak_memory;

#ifndef NDEBUG
	MEM_name_ptr = MEM_guarded_name_ptr;
#endif
}
