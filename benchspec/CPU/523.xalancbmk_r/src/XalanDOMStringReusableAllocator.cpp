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

// Class header file.
#include "xalanc/PlatformSupport/XalanDOMStringReusableAllocator.hpp"



XALAN_CPP_NAMESPACE_BEGIN



XalanDOMStringReusableAllocator::XalanDOMStringReusableAllocator(
            MemoryManagerType&  theManager,
            size_type           theBlockCount) :
	m_allocator(theManager, theBlockCount)
{
}



XalanDOMStringReusableAllocator::~XalanDOMStringReusableAllocator()
{
}



XalanDOMStringReusableAllocator::data_type&
XalanDOMStringReusableAllocator::create()
{
	data_type* const	theBlock = m_allocator.allocateBlock();
	assert(theBlock != 0);

	data_type* const	theResult = new(theBlock) data_type(getMemoryManager());

	m_allocator.commitAllocation(theBlock);

	return *theResult;
}



XalanDOMStringReusableAllocator::data_type&
XalanDOMStringReusableAllocator::create(
			const char*				theString,
			data_type_size_type		theCount)
{
	data_type* const	theBlock = m_allocator.allocateBlock();
	assert(theBlock != 0);

	data_type* const	theResult = new(theBlock) data_type(theString, getMemoryManager(), theCount);

	m_allocator.commitAllocation(theBlock);

	return *theResult;
}



XalanDOMStringReusableAllocator::data_type&
XalanDOMStringReusableAllocator::create(
			const data_type&		theSource,
			data_type_size_type		theStartPosition,
			data_type_size_type		theCount)
{
	data_type* const	theBlock = m_allocator.allocateBlock();
	assert(theBlock != 0);

	data_type* const	theResult = new(theBlock) data_type(theSource, getMemoryManager(), theStartPosition, theCount);

	m_allocator.commitAllocation(theBlock);

	return *theResult;
}



XalanDOMStringReusableAllocator::data_type&
XalanDOMStringReusableAllocator::create(
			const XalanDOMChar*		theString,
			data_type_size_type		theCount)
{
	data_type* const	theBlock = m_allocator.allocateBlock();
	assert(theBlock != 0);

	data_type* const	theResult = new(theBlock) data_type(theString, getMemoryManager(), theCount);

	m_allocator.commitAllocation(theBlock);

	return *theResult;
}



XalanDOMStringReusableAllocator::data_type&
XalanDOMStringReusableAllocator::create(
			data_type_size_type		theCount,
			XalanDOMChar			theChar)
{
	data_type* const	theBlock = m_allocator.allocateBlock();
	assert(theBlock != 0);

	data_type* const	theResult = new(theBlock) data_type(theCount, theChar, getMemoryManager());

	m_allocator.commitAllocation(theBlock);

	return *theResult;
}



XALAN_CPP_NAMESPACE_END
