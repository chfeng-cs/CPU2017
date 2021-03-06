//---------------------------------------------------------------------------
//    $Id: config.cc 15446 2007-11-05 04:05:53Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2006, 2007, 2009 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <base/config.h>
#include <cmath>
#include <limits>
#include <complex>

DEAL_II_NAMESPACE_OPEN

namespace numbers 
{
  bool is_finite (const double x) 
  {
#ifdef DEAL_II_HAVE_ISFINITE
    return std::isfinite (x);
#else
				     // Check against infinities. Note
				     // that if x is a NaN, then both
				     // comparisons will be false
    return ((x >= -std::numeric_limits<double>::max())
	    &&
	    (x <= std::numeric_limits<double>::max()));
#endif
  }



  bool is_finite (const std::complex<double> x) 
  {
					// Check complex numbers for infinity
					// by testing real and imaginary part
    return ( is_finite (x.real()) 
             && 
             is_finite (x.imag()) );
  }



  bool is_finite (const std::complex<float> x) 
  {
					// Check complex numbers for infinity
					// by testing real and imaginary part
    return ( is_finite (x.real()) 
             && 
             is_finite (x.imag()) );
  }



  template <typename number>
  const bool NumberTraits<number>::is_complex;

  template <typename number>
  const bool NumberTraits<std::complex<number> >::is_complex;

// explicit instantiations
  template struct NumberTraits<double>;
  template struct NumberTraits<float>;
    
  template struct NumberTraits<std::complex<double> >;
  template struct NumberTraits<std::complex<float> >;
}

DEAL_II_NAMESPACE_CLOSE
