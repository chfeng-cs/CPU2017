/*
 * Copyright 2001-2002,2004 The Apache Software Foundation.
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
 * $Id: DOMException.cpp 176026 2004-09-08 13:57:07Z peiyongz $
 */

#include <xercesc/dom/DOMImplementation.hpp>
#include <xercesc/util/XMLString.hpp>
#include <xercesc/framework/MemoryManager.hpp>

#include "xercesc/dom/DOMException.hpp"

XERCES_CPP_NAMESPACE_BEGIN

// ---------------------------------------------------------------------------
//  Destructor and Constructor
// ---------------------------------------------------------------------------
DOMException::~DOMException()
{
    if (msg && fMsgOwned)
        fMemoryManager->deallocate((void*)msg);
}

DOMException::DOMException()
:code((ExceptionCode) 0)
,msg(0)
,fMemoryManager(0)
,fMsgOwned(false)
{      
}

DOMException::DOMException(      short                 exCode
                         , const XMLCh*                message
                         ,       MemoryManager* const  memoryManager)
:code((ExceptionCode) exCode)
,msg(message)
,fMemoryManager(memoryManager)
,fMsgOwned(false)
{  
    if (!message)
    {
        const unsigned int msgSize = 2047;
        XMLCh errText[msgSize + 1];
        fMsgOwned = true;

        // load the text
        msg = XMLString::replicate
             ( 
              DOMImplementation::loadDOMExceptionMsg(code, errText, msgSize) ? errText : XMLUni::fgDefErrMsg
            , fMemoryManager
             );

    }
}

DOMException::DOMException(const DOMException &other)
:code(other.code)
,msg(0)
,fMemoryManager(other.fMemoryManager)
,fMsgOwned(other.fMsgOwned)
{
    msg = other.fMsgOwned? XMLString::replicate(other.msg, other.fMemoryManager) : other.msg;
}

XERCES_CPP_NAMESPACE_END

