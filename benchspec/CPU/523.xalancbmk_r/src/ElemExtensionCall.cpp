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
#include "xalanc/XSLT/ElemExtensionCall.hpp"



#include <xalanc/PlatformSupport/XalanMessageLoader.hpp>



#include "xalanc/XSLT/Constants.hpp"
#include "xalanc/XSLT/Stylesheet.hpp"
#include "xalanc/XSLT/StylesheetConstructionContext.hpp"
#include "xalanc/XSLT/StylesheetExecutionContext.hpp"



XALAN_CPP_NAMESPACE_BEGIN



ElemExtensionCall::ElemExtensionCall(
            StylesheetConstructionContext&  constructionContext,
            Stylesheet&                     stylesheetTree,
            const XalanDOMChar*             name,
            const AttributeListType&        atts,
            int                             lineNumber,
            int                             columnNumber,
            ExtensionNSHandler&             ns) :
    ElemLiteralResult(constructionContext,
        stylesheetTree,
        name,
        atts,
        lineNumber,
        columnNumber,
        StylesheetConstructionContext::ELEMNAME_EXTENSION_CALL),
    m_qname(
        constructionContext.createXalanQName(
            name,
            getStylesheet().getNamespaces(),
            getLocator())),
    m_nsh(ns)
{
    assert(m_qname != 0);
}



ElemExtensionCall*
ElemExtensionCall::create(
            MemoryManagerType&              theManager,
            StylesheetConstructionContext&  constructionContext,
            Stylesheet&                     stylesheetTree,
            const XalanDOMChar*             name,
            const AttributeListType&        atts,
            int                             lineNumber,
            int                             columnNumber,
            ExtensionNSHandler&             ns)
{
    typedef ElemExtensionCall ThisType;

    XalanMemMgrAutoPtr<ThisType, false> theGuard( theManager , (ThisType*)theManager.allocate(sizeof(ThisType)));

    ThisType* theResult = theGuard.get();

    new (theResult) ThisType(constructionContext,
                            stylesheetTree,
                            name,
                            atts,
                            lineNumber,
                            columnNumber,
                            ns);

   theGuard.release();

    return theResult;
}



#if !defined(XALAN_RECURSIVE_STYLESHEET_EXECUTION)
const ElemTemplateElement*
ElemExtensionCall::startElement(StylesheetExecutionContext& executionContext) const
{
    ElemTemplateElement::startElement(executionContext);

    warn(
        executionContext,
        XalanMessages::XalanHandleExtensions);

    return ElemTemplateElement::getFirstChildElemToExecute(executionContext);
}



void 
ElemExtensionCall::endElement(StylesheetExecutionContext&   /*executionContext*/) const
{
}



bool
ElemExtensionCall::executeChildElement(
                    StylesheetExecutionContext& /*executionContext*/,
                    const ElemTemplateElement*  element) const
{
    return  element->getXSLToken() == StylesheetConstructionContext::ELEMNAME_FALLBACK;
}
#endif



#if defined(XALAN_RECURSIVE_STYLESHEET_EXECUTION)
void
ElemExtensionCall::execute(StylesheetExecutionContext&  executionContext) const
{
    ElemTemplateElement::execute(executionContext);

    warn(
        executionContext,
        XalanMessages::XalanHandleExtensions);

    for (const ElemTemplateElement* child = getFirstChildElem(); child != 0; child = child->getNextSiblingElem())
    {
        if(child->getXSLToken() == StylesheetConstructionContext::ELEMNAME_FALLBACK)
        {
            child->execute(executionContext);
        }
    }
}
#endif


bool
ElemExtensionCall::elementAvailable(StylesheetExecutionContext&     executionContext) const
{
    return executionContext.elementAvailable(*m_qname);
}



XALAN_CPP_NAMESPACE_END
