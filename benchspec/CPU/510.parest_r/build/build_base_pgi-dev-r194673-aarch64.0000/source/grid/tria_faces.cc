//---------------------------------------------------------------------------
//    $Id: tria_faces.cc 14038 2006-10-23 02:46:34Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2006 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------

#include <base/memory_consumption.h>
#include <grid/tria_faces.h>

DEAL_II_NAMESPACE_OPEN


namespace internal
{
  namespace Triangulation
  {

#if deal_II_dimension == 1

    unsigned int
    TriaFaces<1>::memory_consumption () const
    {
      return 0;
    }

#endif

#if deal_II_dimension == 2

    unsigned int
    TriaFaces<2>::memory_consumption () const
    {
      return MemoryConsumption::memory_consumption (lines);
    }

#endif

#if deal_II_dimension == 3

    unsigned int
    TriaFaces<3>::memory_consumption () const
    {
      return (MemoryConsumption::memory_consumption (quads) +
	      MemoryConsumption::memory_consumption (lines) );
    }

#endif

  }
}

DEAL_II_NAMESPACE_CLOSE

