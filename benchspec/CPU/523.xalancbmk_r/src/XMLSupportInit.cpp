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

#include "xalanc/XMLSupport/XMLSupportInit.hpp"



#include "xalanc/XMLSupport/XalanXMLSerializerBase.hpp"



XALAN_CPP_NAMESPACE_BEGIN



unsigned long	XMLSupportInit::s_initCounter = 0;



XMLSupportInit::XMLSupportInit(MemoryManagerType& theManager) :
	m_platformSupportInit(theManager),
	m_domSupportInit(theManager)
{
	++s_initCounter;

	if (s_initCounter == 1)
	{
		initialize(theManager);
	}
}



XMLSupportInit::~XMLSupportInit()
{
	--s_initCounter;

	if (s_initCounter == 0)
	{
		terminate();
	}
}



void
XMLSupportInit::initialize(MemoryManagerType& theManager)
{
	XalanXMLSerializerBase::initialize(theManager);
}



void
XMLSupportInit::terminate()
{
    XalanXMLSerializerBase::terminate();
}



XALAN_CPP_NAMESPACE_END
