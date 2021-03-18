//-----------------------  mapping_collection.cc  ---------------------------
//    $Id: mapping_collection.cc 18724 2009-04-23 23:06:37Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2003, 2006 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//-----------------------  mapping_collection.cc  ---------------------------

#include <base/memory_consumption.h>
#include <hp/mapping_collection.h>

DEAL_II_NAMESPACE_OPEN


namespace hp
{

  template<int dim, int spacedim>
  MappingCollection<dim,spacedim>::MappingCollection ()
  {}


  
  template<int dim, int spacedim>
  MappingCollection<dim,spacedim>::
  MappingCollection (const Mapping<dim,spacedim> &mapping)
  {
    mappings
      .push_back (std_cxx1x::shared_ptr<const Mapping<dim,spacedim> >(mapping.clone()));
  }



  template<int dim, int spacedim>
  MappingCollection<dim,spacedim>::
  MappingCollection (const MappingCollection<dim,spacedim> &mapping_collection)
                  :
                  Subscriptor (),
                                                   // copy the array
                                                   // of shared
                                                   // pointers. nothing
                                                   // bad should
                                                   // happen -- they
                                                   // simply all point
                                                   // to the same
                                                   // objects, and the
                                                   // last one to die
                                                   // will delete the
                                                   // mappings
                  mappings (mapping_collection.mappings)
  {}
  
  

  template<int dim, int spacedim>
  unsigned int
  MappingCollection<dim,spacedim>::memory_consumption () const
  {
    return (sizeof(*this) +
	    MemoryConsumption::memory_consumption (mappings));
  }

  

  template<int dim, int spacedim>
  void
  MappingCollection<dim,spacedim>::push_back (const Mapping<dim,spacedim> &new_mapping)
  {
    mappings
      .push_back (std_cxx1x::shared_ptr<const Mapping<dim,spacedim> >(new_mapping.clone()));
  }

//---------------------------------------------------------------------------



  template<int dim, int spacedim>
  MappingQ1<dim,spacedim>
  StaticMappingQ1<dim,spacedim>::mapping_q1;
  

  template<int dim, int spacedim>
  MappingCollection<dim,spacedim>
  StaticMappingQ1<dim,spacedim>::mapping_collection
   = MappingCollection<dim,spacedim>(MappingQ1<dim,spacedim>());

// explicit instantiations
  template class MappingCollection<deal_II_dimension>;
  template struct StaticMappingQ1<deal_II_dimension>;

#if deal_II_dimension != 3
  template class MappingCollection<deal_II_dimension,deal_II_dimension+1>;
  template struct StaticMappingQ1<deal_II_dimension,deal_II_dimension+1>;

#endif
  
}

DEAL_II_NAMESPACE_CLOSE
