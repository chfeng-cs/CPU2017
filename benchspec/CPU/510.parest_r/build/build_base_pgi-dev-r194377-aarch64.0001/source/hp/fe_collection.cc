//----------------------------  fe_collection.cc  ---------------------------
//    $Id: fe_collection.cc 18724 2009-04-23 23:06:37Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2003, 2004, 2006 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//----------------------------  fe_collection.cc  ---------------------------

#include <base/memory_consumption.h>
#include <hp/fe_collection.h>

DEAL_II_NAMESPACE_OPEN

namespace hp
{
  template <int dim, int spacedim>
  FECollection<dim,spacedim>::FECollection ()
  {}
  

  
  template <int dim, int spacedim>
  FECollection<dim,spacedim>::FECollection (const FiniteElement<dim,spacedim> &fe)
  {
    push_back (fe);
  }
  

  
  template <int dim, int spacedim>
  FECollection<dim,spacedim>::
  FECollection (const FECollection<dim,spacedim> &fe_collection)
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
                  finite_elements (fe_collection.finite_elements)
  {}



  template <int dim, int spacedim>
  void FECollection<dim,spacedim>::push_back (const FiniteElement<dim,spacedim> &new_fe)
  {
                                     // check that the new element has the right
                                     // number of components. only check with
                                     // the first element, since all the other
                                     // elements have already passed the test
                                     // against the first element
    if (finite_elements.size() != 0)
      Assert (new_fe.n_components() == finite_elements[0]->n_components(),
              ExcMessage ("All elements inside a collection need to have the "
                          "same number of vector components!"));
  
    finite_elements
      .push_back (std_cxx1x::shared_ptr<const FiniteElement<dim,spacedim> >(new_fe.clone()));
  }



  template <int dim, int spacedim> 
  unsigned int
  FECollection<dim,spacedim>::memory_consumption () const
  {
    unsigned int mem
      = (sizeof(*this) +
         MemoryConsumption::memory_consumption (finite_elements));
    for (unsigned int i=0; i<finite_elements.size(); ++i)
      mem += finite_elements[i]->memory_consumption();

    return mem;
  }


// explicit instantiations
  template class FECollection<deal_II_dimension>;

#if deal_II_dimension != 3
  template class FECollection<deal_II_dimension, deal_II_dimension+1>;
#endif
  
}

DEAL_II_NAMESPACE_CLOSE
