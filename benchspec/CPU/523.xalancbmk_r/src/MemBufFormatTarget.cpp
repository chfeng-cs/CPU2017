/*
 * Copyright 1999-2002,2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * $Id: MemBufFormatTarget.cpp 191054 2005-06-17 02:56:35Z jberry $
 */

#include <xercesc/framework/MemBufFormatTarget.hpp>
#include <xercesc/util/XMLString.hpp>
#if defined(SPEC)
#include <cstring>
#else
#include <string.h>
#endif

#if defined(XALAN_STRICT_ANSI_HEADERS)
    using std::memcpy;
#endif

XERCES_CPP_NAMESPACE_BEGIN

MemBufFormatTarget::MemBufFormatTarget( int                  initCapacity
                                      , MemoryManager* const manager)
    : fMemoryManager(manager)
    , fDataBuf(0)
    , fIndex(0)
    , fCapacity(initCapacity)
{
    // Buffer is one larger than capacity, to allow for zero term
    fDataBuf = (XMLByte*) fMemoryManager->allocate
    (
        (fCapacity + 4) * sizeof(XMLByte)
    );//new XMLByte[fCapacity+4];

    // Keep it null terminated
    fDataBuf[0] = XMLByte(0);
}

MemBufFormatTarget::~MemBufFormatTarget()
{
    fMemoryManager->deallocate(fDataBuf);//delete [] fDataBuf;
}

void MemBufFormatTarget::writeChars(const XMLByte* const toWrite
                                  , const unsigned int   count
                                  , XMLFormatter * const)
{

    if (count) {
        insureCapacity(count);
        memcpy(&fDataBuf[fIndex], toWrite, count * sizeof(XMLByte));
        fIndex += count;
    }

}

const XMLByte* MemBufFormatTarget::getRawBuffer() const
{
    fDataBuf[fIndex] = 0;
    fDataBuf[fIndex + 1] = 0;
    fDataBuf[fIndex + 2] = 0;
    fDataBuf[fIndex + 3] = 0;
    return fDataBuf;
}

void MemBufFormatTarget::reset()
{
    fIndex = 0;
    fDataBuf[0] = 0;
    fDataBuf[fIndex + 1] = 0;
    fDataBuf[fIndex + 2] = 0;
    fDataBuf[fIndex + 3] = 0;
}

// ---------------------------------------------------------------------------
//  MemBufFormatTarget: Private helper methods
// ---------------------------------------------------------------------------
void MemBufFormatTarget::insureCapacity(const unsigned int extraNeeded)
{
    // If we can handle it, do nothing yet
    if (fIndex + extraNeeded < fCapacity)
        return;

    // Oops, not enough room. Calc new capacity and allocate new buffer
    const unsigned int newCap = (unsigned int)((fIndex + extraNeeded) * 2);
    XMLByte* newBuf = (XMLByte*) fMemoryManager->allocate
    (
        (newCap+4) * sizeof(XMLByte)
    );//new XMLByte[newCap+4];

    // Copy over the old stuff
    memcpy(newBuf, fDataBuf, fCapacity * sizeof(XMLByte) + 4);

    // Clean up old buffer and store new stuff
    fMemoryManager->deallocate(fDataBuf); //delete [] fDataBuf;
    fDataBuf = newBuf;
    fCapacity = newCap;
}

XERCES_CPP_NAMESPACE_END

