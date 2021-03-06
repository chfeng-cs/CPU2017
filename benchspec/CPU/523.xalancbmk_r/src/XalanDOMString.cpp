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

#include "xalanc/XalanDOM/XalanDOMString.hpp"

#if defined(SPEC)
#include <cstring>
#include <cassert>
#include <cstdlib>
#else
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#endif

#include <xalanc/Include/XalanMemMngArrayAllocate.hpp>

XALAN_CPP_NAMESPACE_BEGIN



const XalanDOMChar	XalanDOMString::s_empty = 0;

#if defined(XALAN_INLINE_INITIALIZATION) && !defined(XALAN_INLINE_INITIALIZATION_IS_DEFINITION_BUG)
const XalanDOMString::size_type     XalanDOMString::npos;
#endif
 


XalanDOMString::XalanDOMString(MemoryManagerType&  theManager) :
	m_data(theManager),
	m_size(0)
{
}



XalanDOMString::XalanDOMString(
			const XalanDOMString&	theSource,
            MemoryManagerType&      theManager,
			size_type				theStartPosition,
			size_type				theCount) :
	m_data(theManager),
	m_size(0)
{
	if (theSource.length() != 0)
	{
		append(theSource, theStartPosition, theCount);
	}
}



XalanDOMString::XalanDOMString(
			const XalanDOMChar*		theString,
            MemoryManagerType&      theManager,
			size_type				theCount) :
	m_data(theManager),
	m_size(0)
{
	assert(theString != 0);

	if (*theString != 0)
	{
		append(theString, theCount);
	}
}



XalanDOMString::XalanDOMString(
			const char*		    theString,
            MemoryManagerType&  theManager,
			size_type		    theCount) :
	m_data(theManager),
	m_size(0)
{
	assert(theString != 0);

	if (*theString != 0)
	{
		append(theString, theCount);
	}

	invariants();
}

XalanDOMString*
XalanDOMString::clone(MemoryManagerType&  theManager)
{
        typedef XalanDOMString ThisType;
        
        XalanMemMgrAutoPtr<ThisType, false> theGuard( theManager , (ThisType*)theManager.allocate(sizeof(ThisType)));

        ThisType* theResult = theGuard.get();

        new (theResult) ThisType(*this, theManager);

        theGuard.release();

        return theResult;
}

XalanDOMString::XalanDOMString(
			size_type		    theCount,
			XalanDOMChar	    theChar,
            MemoryManagerType&  theManager) :
	m_data(theManager),
	m_size(0)
{
	if (theCount != 0)
	{
		XalanDOMCharVectorType(theCount + 1, theChar, theManager).swap(m_data);

		// Null-terminate it...
		m_data.back() = 0;

		m_size = theCount;
	}

	invariants();
}



void
XalanDOMString::resize(
			size_type		theCount,
			XalanDOMChar	theChar)
{
	invariants();

	const size_type		theOldSize = size();

	if (theCount != theOldSize)
	{
		if (theOldSize == 0)
		{
			// If the string is of 0 length, resize but add an
			// extra byte for the terminating byte.
			m_data.resize(theCount + 1, theChar);
		}
		else
		{
			// If the string is not of 0 length, resize but
			// put a copy of theChar where the terminating
			// byte used to be.
			m_data.resize(theCount + 1, theChar);
		}

		m_size = theCount;

		// Terminate...
		m_data.back() = 0;
	}

	invariants();
}



void
XalanDOMString::erase(
			size_type	theStartPosition,
			size_type	theCount)
{
	invariants();

	const size_type		theActualCount =
			theCount == size_type(npos) ? length() - theStartPosition : theCount;

	if (theStartPosition == 0 && theCount >= size())
	{
		m_data.erase(m_data.begin(), m_data.end());

		m_size = 0;
	}
	else
	{
		const iterator		i = getIteratorForPosition(theStartPosition);

		m_data.erase(i, i + (theActualCount));

		const size_type		theNewSize = size_type(m_data.size());
        assert(size_type(m_data.size()) == theNewSize);

		if (theNewSize < 2)
		{
			m_size = 0;
		}
		else
		{
			m_size = theNewSize - 1;
		}
	}

	invariants();
}



XalanDOMString&
XalanDOMString::assign(
			const XalanDOMString&	theSource,
			size_type				thePosition,
			size_type				theCount)
{
	invariants();

	assert(thePosition < theSource.size() && thePosition + theCount <= theSource.size());

	if (&theSource != this)
	{
		erase();

		append(theSource, thePosition, theCount);
	}
	else
	{
		if (thePosition == 0)
		{
			// See if we're being asked to
			// assign everything to ourself,
			// which is a noop...
			if (theCount != m_size)
			{
				// We're being asked to truncate...
				resize(theCount);
			}
		}
		else
		{
			// Yuck.  We have to move data...
#if defined(XALAN_STRICT_ANSI_HEADERS)
			std::memmove(&*begin(), &*begin() + thePosition, theCount * sizeof(XalanDOMChar));
#else
			memmove(&*begin(), &*begin() + thePosition, theCount * sizeof(XalanDOMChar));
#endif

			resize(theCount);
		}
	}

	invariants();

	return *this;
}



XalanDOMString&
XalanDOMString::assign(
		    iterator	theFirstPosition,
		    iterator	theLastPosition)
{
	invariants();

	m_data.reserve(theLastPosition - theFirstPosition + 1);

	m_data.assign(theFirstPosition, theLastPosition);

	m_data.push_back(XalanDOMChar(0));

	m_size = size_type(m_data.size()) - 1;
    assert(m_data.size() - 1 == m_size);

	invariants();

	return *this;
}



XalanDOMString&
XalanDOMString::append(
			const XalanDOMChar*		theString,
			size_type				theCount)
{
	const size_type		theLength =
			theCount == size_type(npos) ? length(theString) : theCount;

	if (theLength != 0)
	{
		if (m_data.empty() == true)
		{
			m_data.reserve(theLength + 1);

			m_data.insert(m_data.end(), theString, theString + theLength);

			m_data.push_back(0);

			m_size = theLength;

			assert(length() == theLength);
		}
		else
		{
			m_data.insert(getBackInsertIterator(), theString, theString + theLength);

			m_size += theCount;
		}
	}

	invariants();

	return *this;
}



static inline void
doTranscode(
			const char*					theString,
			XalanDOMString::size_type	theCount,
			XalanDOMCharVectorType&		theVector,
			bool						fTerminate)
{
	assert(theString != 0);

	if (theCount == XalanDOMString::size_type(XalanDOMString::npos))
	{
		if (TranscodeFromLocalCodePage(theString, theVector, fTerminate) == false)
		{
			throw XalanDOMString::TranscodingError();
		}
	}
	else
	{
		if (TranscodeFromLocalCodePage(theString, theCount, theVector, fTerminate) == false)
		{
			throw XalanDOMString::TranscodingError();
		}
	}
}



XalanDOMString&
XalanDOMString::append(
			const char*		theString,
			size_type		theCount)
{
	invariants();

	const size_type		theLength =
			theCount == size_type(npos) ? length(theString) : theCount;

	if (theLength != 0)
	{
		if (empty() == true)
		{
			doTranscode(theString, theLength, m_data, true);
		}
		else
		{
			XalanDOMCharVectorType	theTempVector(getMemoryManager());

			doTranscode(theString, theLength, theTempVector, false);

			append(&*theTempVector.begin(), size_type(theTempVector.size()));
		}

		m_size = size_type(m_data.size()) - 1;
        assert(m_data.size() - 1 == m_size);
	}

	invariants();

	return *this;
}


XalanDOMString&
XalanDOMString::append(
			size_type		theCount,
			XalanDOMChar	theChar)
{
	invariants();

	if (m_data.empty() == true)
	{
		m_data.insert(m_data.end(), theCount + 1, theChar);

		m_data.back() = 0;

		m_size = theCount;

		assert(length() == theCount);
	}
	else
	{
		m_data.insert(getBackInsertIterator(), theCount, theChar);

		m_size += theCount;
	}

	invariants();

	return *this;
}



XalanDOMString&
XalanDOMString::insert(
			size_type				thePosition,
			const XalanDOMChar*		theString,
			size_type				theCount)
{
	invariants();

	if (m_data.empty() == true)
	{
		assert(thePosition == 0);

		append(theString, theCount);

		assert(length() == theCount);
	}
	else
	{
		m_data.insert(getIteratorForPosition(thePosition), theString, theString + theCount);

		m_size += theCount;
	}

	invariants();

	return *this;
}



XalanDOMString&
XalanDOMString::insert(
			size_type		thePosition,
			size_type		theCount,
			XalanDOMChar	theChar)
{
	invariants();

	if (m_data.empty() == true)
	{
		assert(thePosition == 0);

		assign(theCount, theChar);
	}
	else
	{
		m_data.insert(getIteratorForPosition(thePosition), theCount, theChar);

		m_size += theCount;
	}

	invariants();

	return *this;
}



XalanDOMString::iterator
XalanDOMString::insert(
			iterator		thePosition,
			XalanDOMChar	theChar)
{
	invariants();

	if (m_data.empty() == true)
	{
		assert(thePosition == m_data.end() || thePosition == m_data.begin());

		assign(1, theChar);

		assert(length() == 1);

        thePosition = m_data.begin();
	}
	else
	{
		thePosition = m_data.insert(thePosition, theChar);

		++m_size;
	}

    assert(*thePosition == theChar);

	invariants();

	return thePosition;
}



void
XalanDOMString::insert(
			iterator		thePosition,
			size_type		theCount,
			XalanDOMChar	theChar)
{
	invariants();

	if (m_data.empty() == true)
	{
		assert(thePosition == m_data.end() || thePosition == m_data.begin());

		assign(theCount, theChar);

		assert(length() == theCount);
	} 
	else
	{
		m_data.insert(thePosition, theCount, theChar);

		m_size += theCount;
	}

	invariants();
}



void
XalanDOMString::insert(
		iterator		theInsertPosition,
		iterator	theFirstPosition,
		iterator	theLastPosition)
{
	invariants();

	if (m_data.empty() == true)
	{
		assert(theInsertPosition == m_data.end() || theInsertPosition == m_data.begin());

		assign(theFirstPosition, theLastPosition);
	}
	else
	{
		m_data.insert(theInsertPosition, theFirstPosition, theLastPosition);

		m_size = size_type(m_data.size()) - 1;

		assert(m_size == m_data.size() - 1);
	}

	invariants();
}



template <class Type, class SizeType>
int
doCompare(
			const Type*		theLHS,
			SizeType		theLHSLength,
			const Type*		theRHS,
			SizeType		theRHSLength)
{
	int					theResult = 0;

	if (theLHSLength != 0 || theRHSLength != 0)
	{
		Type		theLHSChar = Type(0);
		Type		theRHSChar = Type(0);

		SizeType	i = 0;

		for(; i < theLHSLength && i < theRHSLength; i++)
		{
			theLHSChar = theLHS[i];
			theRHSChar = theRHS[i];

			if (theLHSChar != theRHSChar)
			{
				break;
			}
		}

		if (i == theLHSLength)
		{
			// We reached the end of theLHS...
			if (i != theRHSLength)
			{
				// but not the end of theRHS.
				theResult = -1;
			}
		}
		else if (i == theRHSLength)
		{
			// We reached the end of theRHS string...
			if (i != theLHSLength)
			{
				// but not the end of theLHS string.
				theResult = 1;
			}
		}
		else
		{
			// We didn't reach the end of _either_ string, so
			// return the difference between the two characters
			// that caused the problem.
			theResult = theLHSChar - theRHSChar;
		}
	}

	return theResult;
}



int
XalanDOMString::compare(const XalanDOMChar*		theString) const
{
	invariants();

	return doCompare(c_str(), length(), theString, length(theString));
}



int
XalanDOMString::compare(
			size_type				thePosition1,
			size_type				theCount1,
			const XalanDOMChar*		theString,
			size_type				theCount2) const
{
	invariants();

	return doCompare(c_str() + thePosition1, theCount1, theString, theCount2);
}

template<class Type>
void
reset_func(XalanDOMString& obj, MemoryManagerType&    theManager, Type string)
{
    assert( string != 0 );

    XalanDOMString tmpString(string, theManager);

    obj.swap(tmpString);
}

void 
XalanDOMString::reset(MemoryManagerType&    theManager,
                      const char*		    theString)
{
    reset_func(*this, theManager, theString);
}

void 
XalanDOMString::reset(MemoryManagerType&    theManager,
                      const XalanDOMChar*   theString)
{
    reset_func(*this, theManager, theString);
}
void
XalanDOMString::transcode(CharVectorType&	theResult) const
{
	invariants();

	if (TranscodeToLocalCodePage(c_str(), length(), theResult, true) == false)
	{
		throw TranscodingError();
	}
}



static inline XalanDOMString::size_type
length(const XalanDOMChar*	theString)
{
	assert(theString != 0);

	const XalanDOMChar*		theStringPointer = theString;

	while(*theStringPointer != 0)
	{
		theStringPointer++;
	}

	return XalanDOMString::size_type(theStringPointer - theString);
}



bool
XalanDOMString::equals(
			const XalanDOMChar*		theLHS,
			size_type				theLHSLength,
			const XalanDOMChar*		theRHS,
			size_type				theRHSLength)
{
	if (theLHSLength != theRHSLength)
	{
		return false;
	}
	else if (theLHSLength == 0)
	{
		return true;
	}
	else
	{
		const XalanDOMChar* const	theEnd = theLHS + theLHSLength;

		while(*theLHS == *theRHS)
		{
			++theLHS;

			if (theLHS == theEnd)
			{
				return true;
			}
			else
			{
				++theRHS;
			}
		}

		return false;
	}
}



bool
XalanDOMString::equals(
			const XalanDOMString&	theLHS,
			const XalanDOMString&	theRHS)
{
	const XalanDOMString::size_type		theLHSLength = theLHS.size();
	const XalanDOMString::size_type		theRHSLength = theRHS.size();

	if (theLHSLength != theRHSLength)
	{
		return false;
	}
	else
	{
		return equals(theLHS.c_str(), theLHSLength, theRHS.c_str(), theRHSLength);
	}
}



XalanDOMString::size_type
XalanDOMString::length(const XalanDOMChar*	theString)
{
	return XALAN_CPP_NAMESPACE :: length(theString);
}



XalanDOMString::size_type
XalanDOMString::length(const char*	theString)
{
	assert(theString != 0);

#if defined(XALAN_STRICT_ANSI_HEADERS)
	assert(std::strlen(theString) < size_type(npos));

	return size_type(std::strlen(theString));
#else
	assert(strlen(theString) < size_type(npos));

	return size_type(strlen(theString));
#endif

}



XalanDOMString::size_type
XalanDOMString::hash(
			const XalanDOMChar*			theString,
			XalanDOMString::size_type	theLength)
{
	assert(theString != 0);

    size_type	theResult = 0;

	const XalanDOMChar* const	theEnd = theString + theLength;

	while (theString != theEnd)
    {
        theResult += (theResult * 37) + (theResult >> 24) + size_type(*theString);

        ++theString;
    }

	return theResult;
}






XALAN_CPP_NAMESPACE_END



#include <xercesc/util/XMLString.hpp>



XALAN_CPP_NAMESPACE_BEGIN

// The template function should never fail.
// In case of the unconvertable characters we add the substitution char
// and in case of too small result vector we resize it 
template <class SourceType, class TargetType>
void
doXercesTranscode(
            const SourceType*           theSourceString,
            XalanDOMString::size_type   theSourceStringLength,
            bool                        theSourceStringIsNullTerminated,
            XalanVector<TargetType>&    theTargetVector,
            bool                        terminate,
            char                        theSubstitutionChar)
{

	const SourceType*	theRealSourceString = theSourceString;

	XalanDOMString::size_type	theRealSourceStringLength = theSourceStringLength;

	XalanMemMgrAutoPtrArray<SourceType>		theGuard;

	if (theSourceStringIsNullTerminated == true)
	{
		theRealSourceStringLength = XalanDOMString::length(theSourceString);
	}
	else
	{
        typedef XalanMemMngArrayAllocate<SourceType> ArrayAllocateSourceType;

        theGuard.reset( &( theTargetVector.getMemoryManager()), 
                        ArrayAllocateSourceType::allocate(theRealSourceStringLength + 1, theTargetVector.getMemoryManager()),
                        theRealSourceStringLength + 1);

        assert(theGuard.get() != 0);

        for (XalanDOMString::size_type index = 0; index < theRealSourceStringLength; ++index)
        {
            theGuard[index] = theSourceString[index];
        }

        theGuard[theRealSourceStringLength] = SourceType(0);

        theRealSourceString = theGuard.get(); 
    }

    // wild guessing about the size of the result transcoded vector
    theTargetVector.resize(2*(theRealSourceStringLength + 1), TargetType(0));

    assert(theRealSourceString != 0);

    bool			fSuccess = false;

    XALAN_USING_XERCES(XMLString)

    // $$$ ToDo: We should use the Xerces transcoder interface
    // instead of XMLString::transcode(), so we can better control
    // error handling and failures due to inadequate space.

    fSuccess = XMLString::transcode(
        theRealSourceString,
        &*theTargetVector.begin(),
        (unsigned int)(theTargetVector.size() - 1),
        & (theTargetVector.getMemoryManager()));

    if (fSuccess == false)
    {
        // Do the "manual" transcoding. First , clean uo form the previose phase
        theTargetVector.clear();

        //check if there is illegal caracters for the local code page encoding
        SourceType oneCharArray[2];

        oneCharArray[1] = SourceType(0);

        const size_t theOneTranslatedWbCharLen = 10;

        TargetType theOneTranslatedWbChar[theOneTranslatedWbCharLen]; 

        for (size_t i = 0 ; i <= theRealSourceStringLength ; ++i)
        {
            oneCharArray[0] = theRealSourceString[i];

            theOneTranslatedWbChar[0] = TargetType(0);

            fSuccess = XMLString::transcode(
                oneCharArray,
                theOneTranslatedWbChar,
                theOneTranslatedWbCharLen - 1,
                & (theTargetVector.getMemoryManager()));

            if( fSuccess == false )
            {
                theTargetVector.push_back(theSubstitutionChar);
            }
            else
            {
                // append the translated set of characters
                theTargetVector.insert(
                    theTargetVector.end(),
                    theOneTranslatedWbChar,
                    theOneTranslatedWbChar + XalanDOMString::length(theOneTranslatedWbChar));
            }
        }

    }

    if (terminate == false)
	{
		while(theTargetVector.back() == TargetType(0))
		{
			theTargetVector.pop_back();
		}
	}
}

template <class SourceType, class TargetType>
bool
doXercesTranscode(
			const SourceType*			theSourceString,
			XalanDOMString::size_type	theSourceStringLength,
			bool						theSourceStringIsNullTerminated,
			XalanVector<TargetType>&	theTargetVector,
			bool						terminate)
{
	const SourceType*	theRealSourceString = theSourceString;

	XalanDOMString::size_type	theRealSourceStringLength = theSourceStringLength;

	XalanMemMgrAutoPtrArray<SourceType>		theGuard;

	if (theSourceStringIsNullTerminated == true)
	{
		theRealSourceStringLength = XalanDOMString::length(theSourceString);
	}
	else
	{
        typedef XalanMemMngArrayAllocate<SourceType> ArrayAllocateSourceType;

        theGuard.reset( &( theTargetVector.getMemoryManager()), 
                        ArrayAllocateSourceType::allocate(theRealSourceStringLength + 1, theTargetVector.getMemoryManager()),
                        theRealSourceStringLength + 1);

		assert(theGuard.get() != 0);

		for (XalanDOMString::size_type index = 0; index < theRealSourceStringLength; ++index)
		{
			theGuard[index] = theSourceString[index];
		}

		theGuard[theRealSourceStringLength] = SourceType(0);

		theRealSourceString = theGuard.get(); 
	}

	// Initially, let's guess the the transcoded string will be of the same
	// length as the UTF-16 string.
	theTargetVector.resize(theRealSourceStringLength + 1, TargetType(0));

	assert(theRealSourceString != 0);

	unsigned int	theAttempts = 0;
	bool			fSuccess = false;

	do
	{
		XALAN_USING_XERCES(XMLString)

		// $$$ ToDo: We should use the Xerces transcoder interface
		// instead of XMLString::transcode(), so we can better control
		// error handling and failures due to inadequate space.
		fSuccess = XMLString::transcode(
					theRealSourceString,
					&*theTargetVector.begin(),
					(unsigned int)(theTargetVector.size() - 1),
                    & (theTargetVector.getMemoryManager()));

		if (fSuccess == false)
		{
			if (theAttempts > 2)
			{
				break;
			}
			else
			{
				++theAttempts;

				theTargetVector.resize(theTargetVector.size() + 10, TargetType(0));
			}
		}
	} while (fSuccess == false);

	if (fSuccess == false)
	{
		theTargetVector.clear();
	}
	else if (terminate == false)
	{
		while(theTargetVector.back() == TargetType(0))
		{
			theTargetVector.pop_back();
		}
	}

	return fSuccess;
}


static void
doTranscodeToLocalCodePage(
			const XalanDOMChar*			theSourceString,
			XalanDOMString::size_type	theSourceStringLength,
			bool						theSourceStringIsNullTerminated,
			CharVectorType&				theTargetVector,
			bool						terminate,
            char                        theSubstitutionChar)
{
    // Short circuit if it's a null pointer, or of length 0.
    if (!theSourceString || (!theSourceString[0]))
    {
		if (terminate == true)
		{
			theTargetVector.resize(1);

			theTargetVector.back() = '\0';
		}
		else
		{
			theTargetVector.clear();
		}
	}
	else
	{
		doXercesTranscode(
					theSourceString,
					theSourceStringLength,
					theSourceStringIsNullTerminated,
					theTargetVector,
					terminate,
                    theSubstitutionChar);
	}
}

static bool
doTranscodeToLocalCodePage(
			const XalanDOMChar*			theSourceString,
			XalanDOMString::size_type	theSourceStringLength,
			bool						theSourceStringIsNullTerminated,
			CharVectorType&				theTargetVector,
			bool						terminate)
{
    // Short circuit if it's a null pointer, or of length 0.
    if (!theSourceString || (!theSourceString[0]))
    {
		if (terminate == true)
		{
			theTargetVector.resize(1);

			theTargetVector.back() = '\0';
		}
		else
		{
			theTargetVector.clear();
		}

        return true;
	}
	else
	{
		return doXercesTranscode(
					theSourceString,
					theSourceStringLength,
					theSourceStringIsNullTerminated,
					theTargetVector,
					terminate);
	}
}

XALAN_DOM_EXPORT_FUNCTION(void)
TranscodeToLocalCodePage(
			const XalanDOMChar*			theSourceString,
			XalanDOMString::size_type	theSourceStringLength,
			CharVectorType&				theTargetVector,
			bool						terminate,
            char                        theSubstitutionChar)
{
	doTranscodeToLocalCodePage(
                            theSourceString, 
                            theSourceStringLength, 
                            false, 
                            theTargetVector, 
                            terminate,
                            theSubstitutionChar);
}



XALAN_DOM_EXPORT_FUNCTION(void)
TranscodeToLocalCodePage(
			const XalanDOMChar*		theSourceString,
			CharVectorType&			theTargetVector,
			bool					terminate,
            char                    theSubstitutionChar)
{
	doTranscodeToLocalCodePage(
                            theSourceString, 
                            0, 
                            true, 
                            theTargetVector, 
                            terminate,
                            theSubstitutionChar);
}

XALAN_DOM_EXPORT_FUNCTION(bool)
TranscodeToLocalCodePage(
			const XalanDOMChar*			theSourceString,
			XalanDOMString::size_type	theSourceStringLength,
			CharVectorType&				theTargetVector,
			bool						terminate)
{
	return doTranscodeToLocalCodePage(theSourceString, theSourceStringLength, false, theTargetVector, terminate);
}



XALAN_DOM_EXPORT_FUNCTION(bool)
TranscodeToLocalCodePage(
			const XalanDOMChar*		theSourceString,
			CharVectorType&			theTargetVector,
			bool					terminate)
{
	return doTranscodeToLocalCodePage(theSourceString, 0, true, theTargetVector, terminate);
}



static bool
doTranscodeFromLocalCodePage(
			const char*					theSourceString,
			XalanDOMString::size_type	theSourceStringLength,
			bool						theSourceStringIsNullTerminated,
			XalanDOMCharVectorType&		theTargetVector,
			bool						terminate)
{
    // Short circuit if it's a null pointer, or of length 0.
    if (!theSourceString || (!theSourceString[0]))
    {
		if (terminate == true)
		{
			theTargetVector.resize(1);

			theTargetVector.back() = '\0';
		}
		else
		{
			theTargetVector.clear();
		}

        return true;
	}
	else
	{
		return doXercesTranscode(
					theSourceString,
					theSourceStringLength,
					theSourceStringIsNullTerminated,
					theTargetVector,
					terminate);
	}
}



XALAN_DOM_EXPORT_FUNCTION(bool)
TranscodeFromLocalCodePage(
			const char*					theSourceString,
			XalanDOMString::size_type	theSourceStringLength,
			XalanDOMCharVectorType&		theTargetVector,
			bool						terminate)
{
	return doTranscodeFromLocalCodePage(theSourceString, theSourceStringLength, false, theTargetVector, terminate);
}



XALAN_DOM_EXPORT_FUNCTION(bool)
TranscodeFromLocalCodePage(
			const char*					theSourceString,
			XalanDOMCharVectorType&		theTargetVector,
			bool						terminate)
{
	return doTranscodeFromLocalCodePage(theSourceString, 0, true, theTargetVector, terminate);
}



XALAN_DOM_EXPORT_FUNCTION(const XalanDOMString&)
TranscodeFromLocalCodePage(const CharVectorType&	theSourceString,
                           XalanDOMString&          result)
{
	if (theSourceString.empty() == true)
	{
        result.erase();

        return result;
	}
	else
	{
		typedef XalanDOMString::size_type		size_type;

		const CharVectorType::size_type		theSize = theSourceString.size();

		if (theSourceString[theSize - 1] == CharVectorType::value_type(0))
		{
			return TranscodeFromLocalCodePage(&*theSourceString.begin(), result , size_type(theSize) - 1);
		}
		else
		{
			return TranscodeFromLocalCodePage(&*theSourceString.begin(), result , size_type(theSize));
		}
	}
}



XALAN_CPP_NAMESPACE_END
