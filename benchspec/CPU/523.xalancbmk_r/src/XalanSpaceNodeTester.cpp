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

#include "xalanc/XSLT/XalanSpaceNodeTester.hpp"



#include "xalanc/PlatformSupport/DOMStringHelper.hpp"
#include "xalanc/PlatformSupport/XalanMessageLoader.hpp"



#include "xalanc/XSLT/Constants.hpp"
#include "xalanc/XSLT/StylesheetConstructionContext.hpp"



XALAN_CPP_NAMESPACE_BEGIN



XalanSpaceNodeTester::XalanSpaceNodeTester() :
    NodeTester(),
    m_matchScore(XPath::eMatchScoreNone),
	m_type(ePreserve)
{
}



XalanSpaceNodeTester::XalanSpaceNodeTester(const XalanSpaceNodeTester&	theSource) :
    NodeTester(theSource),
    m_matchScore(theSource.m_matchScore),
	m_type(theSource.m_type)
{
}
    



XalanSpaceNodeTester::XalanSpaceNodeTester(
			eType							theType,
            StylesheetConstructionContext&  theConstructionContext,
            const XalanDOMString&           theNameTest,
            const PrefixResolver&           thePrefixResolver,
            const LocatorType*              theLocator) :
    NodeTester(),
    m_matchScore(XPath::eMatchScoreNone),
	m_type(theType)
{
	m_matchScore = initialize(
		theConstructionContext,
		theNameTest,
		thePrefixResolver,
		theLocator);

    assert(m_matchScore != XPath::eMatchScoreNone);
}
    


XalanSpaceNodeTester::~XalanSpaceNodeTester()
{
}
    


XALAN_CPP_NAMESPACE_END
