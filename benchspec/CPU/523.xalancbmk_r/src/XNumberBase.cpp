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
// Class header file.
#include "xalanc/XPath/XNumberBase.hpp"



#include <xalanc/PlatformSupport/DoubleSupport.hpp>



#include "xalanc/XPath/XObjectTypeCallback.hpp"



XALAN_CPP_NAMESPACE_BEGIN



XNumberBase::XNumberBase() :
	XObject(eTypeNumber)
{
}



XNumberBase::XNumberBase(const XNumberBase&		source) :
	XObject(source)
{
}



XNumberBase::~XNumberBase()
{
}



const XalanDOMString&
XNumberBase::getTypeString() const
{
	return s_numberString;
}



bool
XNumberBase::boolean() const
{
	return XObject::boolean(num());
}



void
XNumberBase::ProcessXObjectTypeCallback(XObjectTypeCallback&	theCallbackObject)
{
	theCallbackObject.Number(*this, num());
}



void
XNumberBase::ProcessXObjectTypeCallback(XObjectTypeCallback&	theCallbackObject) const
{
	theCallbackObject.Number(*this, num());
}



XALAN_CPP_NAMESPACE_END
