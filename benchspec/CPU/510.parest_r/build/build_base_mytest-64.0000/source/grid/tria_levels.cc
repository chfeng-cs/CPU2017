//---------------------------------------------------------------------------
//    $Id: tria_levels.cc 16430 2008-07-08 15:25:01Z hartmann $
//    Version: $Name$
//
//    Copyright (C) 2006, 2007 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <base/memory_consumption.h>
#include <grid/tria_levels.h>

DEAL_II_NAMESPACE_OPEN


namespace internal
{
  namespace Triangulation
  {
    template <int dim>
    void
    TriaLevel<dim>::reserve_space (const unsigned int total_cells,
				   const unsigned int dimension)
    {
                                       // we need space for total_cells
                                       // cells. Maybe we have more already
                                       // with those cells which are unused,
                                       // so only allocate new space if needed.
                                       //
                                       // note that all arrays should have equal
                                       // sizes (checked by @p{monitor_memory}
      if (total_cells > refine_flags.size()) 
        {
          refine_flags.reserve (total_cells);
          refine_flags.insert (refine_flags.end(),
                               total_cells - refine_flags.size(),
                               RefinementCase<dim>::no_refinement);
      
          coarsen_flags.reserve (total_cells);
          coarsen_flags.insert (coarsen_flags.end(),
                                total_cells - coarsen_flags.size(),
                                false);
      
          subdomain_ids.reserve (total_cells);
          subdomain_ids.insert (subdomain_ids.end(),
                                total_cells - subdomain_ids.size(),
                                0);
      
          neighbors.reserve (total_cells*(2*dimension));
          neighbors.insert (neighbors.end(),
                            total_cells*(2*dimension) - neighbors.size(),
                            std::make_pair(-1,-1));
        };
    }


    template <int dim>
    void
    TriaLevel<dim>::monitor_memory (const unsigned int true_dimension) const
    {
                                       // check that we have not allocated
                                       // too much memory. note that bool
                                       // vectors allocate their memory in
                                       // chunks of whole integers, so
                                       // they may over-allocate by up to
                                       // as many elements as an integer
                                       // has bits
      Assert (refine_flags.size() <=
	      refine_flags.capacity()  + DEAL_II_MIN_VECTOR_CAPACITY,
              ExcMemoryWasted ("refine_flags",
                               refine_flags.size(), refine_flags.capacity()));
      Assert (coarsen_flags.size() <= coarsen_flags.capacity() + sizeof(int)*8 ||
              coarsen_flags.size()<DEAL_II_MIN_BOOL_VECTOR_CAPACITY,
              ExcMemoryWasted ("coarsen_flags",
                               coarsen_flags.size(), coarsen_flags.capacity()));
      Assert (neighbors.size() <=
	      neighbors.capacity() + DEAL_II_MIN_VECTOR_CAPACITY,
              ExcMemoryWasted ("neighbors",
                               neighbors.size(), neighbors.capacity()));
      Assert (subdomain_ids.size() <=
	      subdomain_ids.capacity() + DEAL_II_MIN_VECTOR_CAPACITY,
              ExcMemoryWasted ("subdomain_ids",
                               subdomain_ids.size(), subdomain_ids.capacity()));
      Assert (2*true_dimension*refine_flags.size() == neighbors.size(),
              ExcMemoryInexact (refine_flags.size(), neighbors.size()));
      Assert (2*true_dimension*coarsen_flags.size() == neighbors.size(),
              ExcMemoryInexact (coarsen_flags.size(), neighbors.size()));
    }


    template <int dim>
    unsigned int
    TriaLevel<dim>::memory_consumption () const
    {
      return (MemoryConsumption::memory_consumption (coarsen_flags) +
              MemoryConsumption::memory_consumption (neighbors) +
              MemoryConsumption::memory_consumption (cells) +
              MemoryConsumption::memory_consumption (refine_flags));
    }

// This specialization should be only temporary, until the TriaObjects
// classes are straightened out.
    
#if deal_II_dimension == 3
    void
    TriaLevel<3>::reserve_space (const unsigned int total_cells,
				 const unsigned int dimension)
    {
                                       // we need space for total_cells
                                       // cells. Maybe we have more already
                                       // with those cells which are unused,
                                       // so only allocate new space if needed.
                                       //
                                       // note that all arrays should have equal
                                       // sizes (checked by @p{monitor_memory}
      if (total_cells > refine_flags.size()) 
        {
          refine_flags.reserve (total_cells);
          refine_flags.insert (refine_flags.end(),
                               total_cells - refine_flags.size(),
                               RefinementCase<3>::no_refinement);
      
          coarsen_flags.reserve (total_cells);
          coarsen_flags.insert (coarsen_flags.end(),
                                total_cells - coarsen_flags.size(),
                                false);
      
          subdomain_ids.reserve (total_cells);
          subdomain_ids.insert (subdomain_ids.end(),
                                total_cells - subdomain_ids.size(),
                                0);
      
          neighbors.reserve (total_cells*(2*dimension));
          neighbors.insert (neighbors.end(),
                            total_cells*(2*dimension) - neighbors.size(),
                            std::make_pair(-1,-1));
        };
    }


    void
    TriaLevel<3>::monitor_memory (const unsigned int true_dimension) const
    {
                                       // check that we have not allocated
                                       // too much memory. note that bool
                                       // vectors allocate their memory in
                                       // chunks of whole integers, so
                                       // they may over-allocate by up to
                                       // as many elements as an integer
                                       // has bits
      Assert (refine_flags.size() <=
	      refine_flags.capacity() + DEAL_II_MIN_VECTOR_CAPACITY,
              ExcMemoryWasted ("refine_flags",
                               refine_flags.size(), refine_flags.capacity()));
      Assert (coarsen_flags.size() <= coarsen_flags.capacity() + sizeof(int)*8 ||
              coarsen_flags.size()<DEAL_II_MIN_BOOL_VECTOR_CAPACITY,
              ExcMemoryWasted ("coarsen_flags",
                               coarsen_flags.size(), coarsen_flags.capacity()));
      Assert (neighbors.size() <=
	      neighbors.capacity() + DEAL_II_MIN_VECTOR_CAPACITY,
              ExcMemoryWasted ("neighbors",
                               neighbors.size(), neighbors.capacity()));
      Assert (subdomain_ids.size () <=
	      subdomain_ids.capacity() + DEAL_II_MIN_VECTOR_CAPACITY,
              ExcMemoryWasted ("subdomain_ids",
                               subdomain_ids.size(), subdomain_ids.capacity()));
      Assert (2*true_dimension*refine_flags.size() == neighbors.size(),
              ExcMemoryInexact (refine_flags.size(), neighbors.size()));
      Assert (2*true_dimension*coarsen_flags.size() == neighbors.size(),
              ExcMemoryInexact (coarsen_flags.size(), neighbors.size()));
    }


    unsigned int
    TriaLevel<3>::memory_consumption () const
    {
      return (MemoryConsumption::memory_consumption (coarsen_flags) +
              MemoryConsumption::memory_consumption (neighbors) +
              MemoryConsumption::memory_consumption (cells) +
              MemoryConsumption::memory_consumption (refine_flags));
    }

#endif
    
  }
}

#if deal_II_dimension != 3
template class internal::Triangulation::TriaLevel<deal_II_dimension>;
#endif


DEAL_II_NAMESPACE_CLOSE

