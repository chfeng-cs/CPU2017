//---------------------------------------------------------------------------
//    $Id: block_vector.cc 15580 2007-12-09 18:54:32Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------

#include <lac/block_vector.templates.h>

DEAL_II_NAMESPACE_OPEN

#include "../lac/block_vector.inst"

// these functions can't be generated by the preprocessor since
// the template arguments need to be different
#ifndef DEAL_II_EXPLICIT_CONSTRUCTOR_BUG    
template BlockVector<double>::BlockVector (const BlockVector<float> &);
template BlockVector<float>::BlockVector (const BlockVector<double> &);

template BlockVector<std::complex<double> >::BlockVector (const BlockVector<std::complex<float> > &);
template BlockVector<std::complex<float> >::BlockVector (const BlockVector<std::complex<double> > &);
#endif

DEAL_II_NAMESPACE_CLOSE