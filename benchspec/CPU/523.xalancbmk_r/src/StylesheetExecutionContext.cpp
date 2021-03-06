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

#include "xalanc/XSLT/StylesheetExecutionContext.hpp"



#include <xalanc/XMLSupport/FormatterToText.hpp>



#include "xalanc/XSLT/ElemTemplateElement.hpp"



XALAN_CPP_NAMESPACE_BEGIN



StylesheetExecutionContext::StylesheetExecutionContext(MemoryManagerType& m_memoryManager, XObjectFactory*	theXObjectFactory) :
	XPathExecutionContext(m_memoryManager, theXObjectFactory)
{
}



StylesheetExecutionContext::~StylesheetExecutionContext()
{
}


#if defined(XALAN_RECURSIVE_STYLESHEET_EXECUTION)
void
StylesheetExecutionContext::ParamsPushPop::doPush(
			const ElemTemplateElement&		xslCallTemplateElement,
			int								savedStackFrameIndex)
{
	if (xslCallTemplateElement.hasParams() == true)
	{
		getExecutionContext().pushCurrentStackFrameIndex(savedStackFrameIndex);

		getExecutionContext().pushParams(xslCallTemplateElement);
	}
}



void
StylesheetExecutionContext::ParamsPushPop::doPush(const ElemTemplateElement&	xslCallTemplateElement)
{
	if (xslCallTemplateElement.hasParams() == true)
	{
		getExecutionContext().pushParams(xslCallTemplateElement);
	}
}



StylesheetExecutionContext::BorrowReturnFormatterToText::BorrowReturnFormatterToText(
			StylesheetExecutionContext&		executionContext,
			Writer&							writer,
			bool							normalizeLinefeed,
			bool							handleIgnorableWhitespace)  :
	m_executionContext(executionContext),
	m_formatter(executionContext.borrowFormatterToText())
{
	assert(m_formatter != 0);

	m_formatter->setNormalizeLinefeed(normalizeLinefeed);
	m_formatter->setHandleIgnorableWhitespace(handleIgnorableWhitespace);
	m_formatter->clearEncoding();
	m_formatter->setWriter(&writer);
}
#endif



XALAN_CPP_NAMESPACE_END
