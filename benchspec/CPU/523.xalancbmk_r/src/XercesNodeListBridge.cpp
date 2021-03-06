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


#if defined(XALAN_BUILD_DEPRECATED_DOM_BRIDGE)


#include "XercesNodeListBridge.hpp"



#include <cassert>



#include "XercesBridgeNavigator.hpp"



XALAN_CPP_NAMESPACE_BEGIN



XercesNodeListBridge::XercesNodeListBridge(
			const DOM_NodeListType&			theXercesNodeList,
			const XercesBridgeNavigator&	theNavigator) :
	XalanNodeList(),
	m_xercesNodeList(theXercesNodeList),
	m_navigator(theNavigator)
{
}



XercesNodeListBridge::~XercesNodeListBridge()
{
}



XercesNodeListBridge::XercesNodeListBridge(const XercesNodeListBridge&	theSource) :
	XalanNodeList(theSource),
	m_xercesNodeList(theSource.m_xercesNodeList),
	m_navigator(theSource.m_navigator)
{
}



XalanNode*
XercesNodeListBridge::item(unsigned int	index) const
{
	return m_navigator.mapNode(m_xercesNodeList.item(index));
}



unsigned int
XercesNodeListBridge::getLength() const
{
	return m_xercesNodeList.getLength();
}



XALAN_CPP_NAMESPACE_END


#endif //XALAN_BUILD_DEPRECATED_DOM_BRIDGE 


