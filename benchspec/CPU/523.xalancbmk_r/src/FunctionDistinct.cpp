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
#include "xalanc/XalanExtensions/FunctionDistinct.hpp"



#include <xalanc/Include/XalanSet.hpp>

#include <xalanc/Include/XalanMemMgrHelper.hpp>


#include <xalanc/XalanDOM/XalanDOMString.hpp>



#include <xalanc/PlatformSupport/XalanMessageLoader.hpp>
#include <xalanc/PlatformSupport/DOMStringHelper.hpp>



#include <xalanc/DOMSupport/DOMServices.hpp>



#include <xalanc/XPath/XPathExecutionContext.hpp>
#include <xalanc/XPath/XObjectFactory.hpp>


XALAN_CPP_NAMESPACE_BEGIN



FunctionDistinct::FunctionDistinct()
{
}



FunctionDistinct::~FunctionDistinct()
{
}



XObjectPtr
FunctionDistinct::execute(
            XPathExecutionContext&          executionContext,
            XalanNode*                      context,
            const XObjectArgVectorType&     args,
            const LocatorType*              locator) const
{
    if (args.size() != 1)
    {
        XPathExecutionContext::GetAndReleaseCachedString    theGuard(executionContext);

        executionContext.error(getError(theGuard.get()), context, locator);
    }

    assert(args[0].null() == false);

    const NodeRefListBase&  nodeset = args[0]->nodeset();

    typedef XPathExecutionContext::BorrowReturnMutableNodeRefList   BorrowReturnMutableNodeRefList;

    BorrowReturnMutableNodeRefList  theResult(executionContext);

    const NodeRefListBase::size_type    theLength = nodeset.getLength();

    if (theLength == 1)
    {
        theResult->addNode(nodeset.item(0));
    }
    else if (theLength > 1)
    {
        typedef XPathExecutionContext::GetAndReleaseCachedString    GetAndReleaseCachedString;

        GetAndReleaseCachedString   theGuard(executionContext);

        XalanDOMString&             theCachedString = theGuard.get();


        typedef XalanSet<XalanDOMString>                    SetType;

        SetType     theStrings(executionContext.getMemoryManager());

        // Check to make sure each node has a unique
        // string value.
        for (NodeRefListBase::size_type i = 0; i < theLength; ++i)
        {
            XalanNode* const    theNode = nodeset.item(i);
            assert(theNode != 0);

            DOMServices::getNodeData(*theNode, theCachedString);

            if (theStrings.find(theCachedString) == theStrings.end())
            {
                theResult->addNodeInDocOrder(theNode, executionContext);

                theStrings.insert(theCachedString);
            }


            clear(theCachedString);
        }
    }

    theResult->setDocumentOrder();

    return executionContext.getXObjectFactory().createNodeSet(theResult);
}



#if defined(XALAN_NO_COVARIANT_RETURN_TYPE)
Function*
#else
FunctionDistinct*
#endif
FunctionDistinct::clone(MemoryManagerType&  theManager) const
{
    return XalanCopyConstruct(theManager, *this);
}



const XalanDOMString&
FunctionDistinct::getError(XalanDOMString&  theResult) const
{

    return XalanMessageLoader::getMessage(
                theResult,
                XalanMessages::FunctionAcceptsOneArgument_1Param,
                "distinct");
}



XALAN_CPP_NAMESPACE_END
