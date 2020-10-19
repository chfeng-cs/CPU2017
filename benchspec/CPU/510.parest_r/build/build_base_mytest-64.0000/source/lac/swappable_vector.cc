//---------------------------------------------------------------------------
//    $Id: swappable_vector.cc 14038 2006-10-23 02:46:34Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2000, 2001, 2002, 2005, 2006 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <lac/swappable_vector.templates.h>

DEAL_II_NAMESPACE_OPEN

// explicit instantiations
template class SwappableVector<double>;
template class SwappableVector<float>;

DEAL_II_NAMESPACE_CLOSE
