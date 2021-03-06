//---------------------------------------------------------------------------
//    $Id: shared_ptr.h 18724 2009-04-23 23:06:37Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2009 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__std_cxx1x_shared_ptr_h
#define __deal2__std_cxx1x_shared_ptr_h


#include <base/config.h>

#ifdef DEAL_II_CAN_USE_CXX1X

#  include <memory>

#else

#include <boost/shared_ptr.hpp>

DEAL_II_NAMESPACE_OPEN
namespace std_cxx1x
{
  using boost::shared_ptr;
  using boost::enable_shared_from_this;
}
DEAL_II_NAMESPACE_CLOSE

#endif

#endif
