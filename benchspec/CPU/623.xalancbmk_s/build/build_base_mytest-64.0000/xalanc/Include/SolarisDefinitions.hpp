/*
 * Copyright 1999-2004 The Apache Software Foundation.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#if !defined(SOLARISDEFINITIONS_HEADER_GUARD_1357924680)
#define SOLARISDEFINITIONS_HEADER_GUARD_1357924680



// ---------------------------------------------------------------------------
//  A define in the build for each project is also used to control whether
//  the export keyword is from the project's viewpoint or the client's.
//  These defines provide the platform specific keywords that they need
//  to do this.
// ---------------------------------------------------------------------------
#define XALAN_PLATFORM_EXPORT
#define XALAN_PLATFORM_IMPORT
#define XALAN_PLATFORM_EXPORT_FUNCTION(T) T XALAN_PLATFORM_EXPORT
#define XALAN_PLATFORM_IMPORT_FUNCTION(T) T XALAN_PLATFORM_IMPORT

#define XALAN_HAS_CPP_NAMESPACE
#define XALAN_STRICT_ANSI_HEADERS
#define XALAN_HAS_STD_ITERATORS
#define XALAN_HAS_STD_DISTANCE
#define XALAN_XALANDOMCHAR_USHORT_MISMATCH
#define XALAN_POSIX2_AVAILABLE
#define XALAN_INLINE_INITIALIZATION

#endif	// SOLARISDEFINITIONS_HEADER_GUARD_1357924680
