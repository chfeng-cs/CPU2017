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
// Class header file...
#include "xalanc/XPath/XalanQName.hpp"



#include <xalanc/Include/STLHelper.hpp>



#include <xalanc/PlatformSupport/DOMStringHelper.hpp>
#include <xalanc/PlatformSupport/XalanMessageLoader.hpp>
#include <xalanc/PlatformSupport/XalanUnicode.hpp>



#include <xalanc/DOMSupport/DOMServices.hpp>



XALAN_CPP_NAMESPACE_BEGIN




const XalanDOMString    XalanQName::s_emptyString(XalanMemMgrs::getDummyMemMgr());



XalanQName::PrefixResolverProxy::PrefixResolverProxy(
            const NamespacesStackType&  theStack,
            const XalanDOMString&       theURI) :
    m_stack(theStack),
    m_uri(theURI)
{
}



XalanQName::PrefixResolverProxy::~PrefixResolverProxy()
{
}



const XalanDOMString*
XalanQName::PrefixResolverProxy::getNamespaceForPrefix(const XalanDOMString&    prefix) const
{
    return XalanQName::getNamespaceForPrefix(m_stack, prefix);
}



const XalanDOMString&
XalanQName::PrefixResolverProxy::getURI() const
{
    return m_uri;
}



const XalanDOMString*
XalanQName::getNamespaceForPrefix(
            const NamespaceVectorType&  namespaces,
            const XalanDOMChar*         prefix)
{
    assert( prefix != 0 );

    const XalanDOMString*   nsURI = 0;

    if(prefix == DOMServices::s_XMLString)
    {
        nsURI = &DOMServices::s_XMLNamespaceURI;
    }
    else if (prefix == DOMServices::s_XMLNamespace)
    {
        nsURI = &DOMServices::s_XMLNamespacePrefixURI;
    }
    else
    {
        const NamespaceVectorType::size_type    theSize = namespaces.size();

        for(NamespaceVectorType::size_type j = theSize; j > 0; --j)
        {
            const NameSpace&    ns = namespaces[j - 1];

            const XalanDOMString&   thisPrefix = ns.getPrefix();

            if(prefix == thisPrefix)
            {
                nsURI = &ns.getURI();

                break;
            }
        }
    }

    return nsURI;
}


const XalanDOMString*
XalanQName::getNamespaceForPrefix(
            const NamespaceVectorType&  namespaces,
            const XalanDOMString&       prefix)
{
    const XalanDOMString*   nsURI = 0;

    if(prefix == DOMServices::s_XMLString)
    {
        nsURI = &DOMServices::s_XMLNamespaceURI;
    }
    else if (prefix == DOMServices::s_XMLNamespace)
    {
        nsURI = &DOMServices::s_XMLNamespacePrefixURI;
    }
    else
    {
        const NamespaceVectorType::size_type    theSize = namespaces.size();

        for(NamespaceVectorType::size_type j = theSize; j > 0; --j)
        {
            const NameSpace&    ns = namespaces[j - 1];

            const XalanDOMString&   thisPrefix = ns.getPrefix();

            if(prefix == thisPrefix)
            {
                nsURI = &ns.getURI();

                break;
            }
        }
    }

    return nsURI;
}

const XalanDOMString*
XalanQName::getNamespaceForPrefix(
            const NamespacesStackType&  nsStack,
            const XalanDOMString&       prefix)
{
    return getNamespaceForPrefix(nsStack.begin(), nsStack.end(), prefix);
}

const XalanDOMString*
XalanQName::getNamespaceForPrefix(
            const NamespacesStackType&  nsStack,
            const XalanDOMChar*         prefix)
{
    return getNamespaceForPrefix(nsStack.begin(), nsStack.end(), prefix);
}

const XalanDOMString*
XalanQName::getNamespaceForPrefix(
            NamespacesStackType::const_iterator     theBegin,
            NamespacesStackType::const_iterator     theEnd,
            const XalanDOMChar*                     prefix)
{
    const XalanDOMString*   nsURI = 0;

    if (theBegin != theEnd)
    {
        do
        {   
            --theEnd;

            nsURI = getNamespaceForPrefix((*theEnd), prefix);

            if (nsURI != 0)
            {
                break;
            }
        } while(theBegin != theEnd);
    }

    return nsURI;
}

const XalanDOMString*
XalanQName::getNamespaceForPrefix(
            NamespacesStackType::const_iterator     theBegin,
            NamespacesStackType::const_iterator     theEnd,
            const XalanDOMString&                   prefix)
{
    const XalanDOMString*   nsURI = 0;

    if (theBegin != theEnd)
    {
        do
        {
            nsURI = getNamespaceForPrefix(*(--theEnd), prefix);

            if (nsURI != 0)
            {
                break;
            }
        } while(theBegin != theEnd);
    }

    return nsURI;
}



const XalanDOMString*
XalanQName::getPrefixForNamespace(
            const NamespaceVectorType&  namespaces,
            const XalanDOMString&       uri)
{
    const XalanDOMString*   thePrefix = 0;

    const NamespaceVectorType::size_type    theSize = namespaces.size();

    for(NamespaceVectorType::size_type j = theSize; j > 0; --j)
    {
        const NameSpace&        ns = namespaces[j - 1];
        const XalanDOMString&   thisURI = ns.getURI();

        if(uri == thisURI)
        {
            thePrefix = &ns.getPrefix();

            break;
        }
    }

    return thePrefix;
}       



const XalanDOMString*
XalanQName::getPrefixForNamespace(
            const NamespacesStackType&  nsStack,
            const XalanDOMString&       uri)
{
    return getPrefixForNamespace(nsStack.begin(), nsStack.end(), uri);
}



const XalanDOMString*
XalanQName::getPrefixForNamespace(
            NamespacesStackType::const_iterator     theBegin,
            NamespacesStackType::const_iterator     theEnd,
            const XalanDOMString&                   uri)
{
    const XalanDOMString*   thePrefix = 0;

    if (theBegin != theEnd)
    {
        do
        {
            thePrefix = getPrefixForNamespace(*(--theEnd), uri);

            if (thePrefix != 0)
            {
                break;
            }
        } while(theBegin != theEnd);
    }

    return thePrefix;
}



bool
XalanQName::isValidNCName(const XalanDOMString&     theNCName)
{
    return isValidNCName(c_wstr(theNCName), length(theNCName));
}



bool
XalanQName::isValidNCName(
            const XalanDOMChar*         theNCName,
            XalanDOMString::size_type   theLength)
{
    assert(theNCName != 0);

    if (theLength == XalanDOMString::npos)
    {
        theLength = length(theNCName);
    }

    if (theLength == 0)
    {
        return false;
    }
    else
    {
        XalanDOMChar    c = theNCName[0];

        if(!(XalanXMLChar::isLetter(c) || c == XalanUnicode::charLowLine))
          return false;

        if(theLength > 1)
        {
            for(XalanDOMString::size_type i = 1; i < theLength; i++)
            {
                c = theNCName[i]; 

                if(!(XalanXMLChar::isLetter(c) ||
                     XalanXMLChar::isDigit(c) ||
                     XalanXMLChar::isExtender(c) ||
                     XalanXMLChar::isCombiningChar(c) ||
                     c == XalanUnicode::charLowLine ||
                     c == XalanUnicode::charHyphenMinus ||
                     c == XalanUnicode::charFullStop))
                {
                    return false;
                }
            }
        }

        return true;
    }
}



bool
XalanQName::isValidQName(const XalanDOMString&  theQName)
{
    return isValidQName(c_wstr(theQName), length(theQName));
}



bool
XalanQName::isValidQName(
            const XalanDOMChar*         theQName,
            XalanDOMString::size_type   theLength)
{
    const XalanDOMString::size_type     theIndex =
        indexOf(theQName, XalanUnicode::charColon);

    if (theIndex == theLength)
    {
        return isValidNCName(theQName, theLength);
    }
    else
    {
        const XalanDOMChar* const   thePrefix = c_wstr(theQName);
        const XalanDOMChar* const   theLocalName = thePrefix + theIndex + 1;

        return XalanQName::isValidNCName(thePrefix, theIndex) &&
               XalanQName::isValidNCName(theLocalName, theLength - theIndex - 1);
    }
}


const XalanDOMChar  XalanQName::InvalidQNameException::m_type[] = 
{   
    XalanUnicode::charLetter_I,
    XalanUnicode::charLetter_n,
    XalanUnicode::charLetter_v,
    XalanUnicode::charLetter_a,
    XalanUnicode::charLetter_l,
    XalanUnicode::charLetter_i,
    XalanUnicode::charLetter_d,
    XalanUnicode::charLetter_Q,
    XalanUnicode::charLetter_N,
    XalanUnicode::charLetter_a,
    XalanUnicode::charLetter_m,
    XalanUnicode::charLetter_e,
    XalanUnicode::charLetter_E,
    XalanUnicode::charLetter_x,
    XalanUnicode::charLetter_c,
    XalanUnicode::charLetter_e,
    XalanUnicode::charLetter_p,
    XalanUnicode::charLetter_t,
    XalanUnicode::charLetter_i,
    XalanUnicode::charLetter_o,
    XalanUnicode::charLetter_n,
    0
};



XalanQName::InvalidQNameException::InvalidQNameException(
            const XalanDOMChar*         theQName,
            XalanDOMString::size_type   theQNameLength,
            const XalanDOMString&       theURI,
            int                         theLineNumber,
            int                         theColumnNumber,
            XalanDOMString&             theResult) :
XSLException(format(theQName, theQNameLength,theResult), theURI, theLineNumber, theColumnNumber, theResult.getMemoryManager())
{
}



XalanQName::InvalidQNameException::InvalidQNameException(
            const LocatorType&          theLocator,
            const XalanDOMChar*         theQName,
            XalanDOMString::size_type   theQNameLength,
            XalanDOMString&             theResult) :
    XSLException(theLocator, format(theQName, theQNameLength, theResult), theResult.getMemoryManager())
{
}



XalanQName::InvalidQNameException::InvalidQNameException(
            const XalanDOMChar*         theQName,
            XalanDOMString::size_type   theQNameLength,
            XalanDOMString&             theResult) :
    XSLException(format(theQName, theQNameLength, theResult), theResult.getMemoryManager())
{
}



XalanQName::InvalidQNameException::~InvalidQNameException()
{
}



const XalanDOMString&
XalanQName::InvalidQNameException::format(
            const XalanDOMChar*         theQName,
            XalanDOMString::size_type   theQNameLength,
            XalanDOMString&             theResult )
{
    theResult.append(theQName, theQNameLength);

    return XalanMessageLoader::getMessage(
                theResult,
                XalanMessages::IsNotValidQName_1Param);
}



XALAN_CPP_NAMESPACE_END
