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
#include "xalanc/XSLT/ElemForwardCompatible.hpp"



#include <cassert>



#include <xercesc/sax/AttributeList.hpp>



#include <xalanc/PlatformSupport/DOMStringHelper.hpp>
#include <xalanc/PlatformSupport/XalanMessageLoader.hpp>



#include "xalanc/XSLT/Constants.hpp"
#include "xalanc/XSLT/StylesheetConstructionContext.hpp"
#include "xalanc/XSLT/StylesheetExecutionContext.hpp"



XALAN_CPP_NAMESPACE_BEGIN



ElemForwardCompatible::ElemForwardCompatible(
            StylesheetConstructionContext&  constructionContext,
            Stylesheet&                     stylesheetTree,
            const XalanDOMChar*             name,
            const AttributeListType&        atts,
            int                             lineNumber,
            int                             columnNumber) :
    ElemTemplateElement(
        constructionContext,
        stylesheetTree,
        lineNumber,
        columnNumber,
        StylesheetConstructionContext::ELEMNAME_FORWARD_COMPATIBLE),
    m_elementName(constructionContext.getPooledString(name))
{
    const unsigned int  nAttrs = atts.getLength();

    for(unsigned int i = 0; i < nAttrs; i++)
    {
        const XalanDOMChar* const   aname = atts.getName(i);

        if (isAttrOK(
                aname,
                atts,
                i,
                constructionContext) == false &&
            processSpaceAttr(
                m_elementName.c_str(),
                aname, 
                atts,
                i,
                constructionContext) == false)
        {
            error(
                constructionContext,
                XalanMessages::ElementHasIllegalAttribute_2Param,
                m_elementName.c_str(),
                aname);
        }
    }
}



ElemForwardCompatible*
ElemForwardCompatible::    create(
            MemoryManagerType&              theManager,
            StylesheetConstructionContext&  constructionContext,
            Stylesheet&                     stylesheetTree,
            const XalanDOMChar*             name,
            const AttributeListType&        atts,
            int                             lineNumber,
            int                             columnNumber)
{
    typedef ElemForwardCompatible ThisType;

    XalanMemMgrAutoPtr<ThisType, false> theGuard( theManager , (ThisType*)theManager.allocate(sizeof(ThisType)));

    ThisType* theResult = theGuard.get();

    new (theResult) ThisType(constructionContext,
        stylesheetTree,
        name,
        atts,
        lineNumber,
        columnNumber);

   theGuard.release();

    return theResult;
}



const XalanDOMString&
ElemForwardCompatible::getElementName() const
{
    return m_elementName;
}



ElemForwardCompatible::~ElemForwardCompatible()
{
}


#if !defined(XALAN_RECURSIVE_STYLESHEET_EXECUTION)
const ElemTemplateElement*
ElemForwardCompatible::startElement(StylesheetExecutionContext& executionContext) const
{
    return getFirstChildElemToExecute(executionContext);

}
    


bool
ElemForwardCompatible::executeChildElement(
            StylesheetExecutionContext& /*executionContext*/,
            const ElemTemplateElement*  element) const
{
    return element->getXSLToken() == StylesheetConstructionContext::ELEMNAME_FALLBACK;
}
#endif



#if defined(XALAN_RECURSIVE_STYLESHEET_EXECUTION)
void
ElemForwardCompatible::execute(StylesheetExecutionContext&      executionContext) const
{
    ElemTemplateElement::execute(executionContext);

    for (const ElemTemplateElement* child = getFirstChildElem(); child != 0; child = child->getNextSiblingElem())
    {
        if(child->getXSLToken() == StylesheetConstructionContext::ELEMNAME_FALLBACK)
        {
            child->execute(executionContext);
        }
    }
}
#endif



XALAN_CPP_NAMESPACE_END
