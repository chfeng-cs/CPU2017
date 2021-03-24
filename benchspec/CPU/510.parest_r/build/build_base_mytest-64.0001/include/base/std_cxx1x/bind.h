//---------------------------------------------------------------------------
//    $Id: bind.h 18724 2009-04-23 23:06:37Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2009, 2014 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__std_cxx1x_bind_h
#define __deal2__std_cxx1x_bind_h


#include <base/config.h>

#ifdef DEAL_II_CAN_USE_CXX1X

#  include <functional>

DEAL_II_NAMESPACE_OPEN
// in boost, the placeholders _1, _2, ... are in the global namespace. in
// C++0x, they are in namespace std::placeholders, which makes them awkward to
// use. import them into the deal.II namespace
using namespace std::placeholders;
DEAL_II_NAMESPACE_CLOSE

#else

#include <boost/bind.hpp>

DEAL_II_NAMESPACE_OPEN
namespace std_cxx1x
{
  using boost::bind;
  using boost::ref;
  using boost::cref;
  using boost::reference_wrapper;
}
DEAL_II_NAMESPACE_CLOSE

#endif

#endif
