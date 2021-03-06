//---------------------------------------------------------------------------
//    $Id: mg_dof_iterator_selector.h 17866 2008-12-05 22:27:44Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__mg_dof_iterator_selector_h
#define __deal2__mg_dof_iterator_selector_h


#include <base/config.h>


DEAL_II_NAMESPACE_OPEN

template <int celldim, int dim, int spacedim> class MGDoFAccessor;
template <int dim, int spacedim> class MGDoFCellAccessor;
template <int, int, int> class InvalidAccessor;

template <typename Accessor> class TriaRawIterator;
template <typename Accessor> class TriaIterator;
template <typename Accessor> class TriaActiveIterator;


namespace internal
{
  namespace MGDoFHandler
  {
/*!@addtogroup mg */
/*@{*/

    template <int dim, int spacedim>
    class Iterators;


/**
 * Iterators for MGDofHandler in one dimension. See the @ref Iterators module
 * for more information.
 */
    template <int spacedim>
    class Iterators<1,spacedim>
    {
      public:
        typedef TriaRawIterator<dealii::MGDoFCellAccessor<1,spacedim> >    raw_line_iterator;
        typedef TriaIterator<dealii::MGDoFCellAccessor<1,spacedim> >       line_iterator;
        typedef TriaActiveIterator<dealii::MGDoFCellAccessor<1,spacedim> > active_line_iterator;

        typedef TriaRawIterator   <dealii::InvalidAccessor<2,1,spacedim> > raw_quad_iterator;
        typedef TriaIterator      <dealii::InvalidAccessor<2,1,spacedim> > quad_iterator;
        typedef TriaActiveIterator<dealii::InvalidAccessor<2,1,spacedim> > active_quad_iterator;

        typedef TriaRawIterator   <dealii::InvalidAccessor<3,1,spacedim> > raw_hex_iterator;
        typedef TriaIterator      <dealii::InvalidAccessor<3,1,spacedim> > hex_iterator;
        typedef TriaActiveIterator<dealii::InvalidAccessor<3,1,spacedim> > active_hex_iterator;

        typedef raw_line_iterator    raw_cell_iterator;
        typedef line_iterator        cell_iterator;
        typedef active_line_iterator active_cell_iterator;

        typedef TriaRawIterator   <dealii::InvalidAccessor<0,1,spacedim> > raw_face_iterator;
        typedef TriaIterator      <dealii::InvalidAccessor<0,1,spacedim> > face_iterator;
        typedef TriaActiveIterator<dealii::InvalidAccessor<0,1,spacedim> > active_face_iterator;
    };



/**
 * Iterators for MGDofHandler in two dimensions. See the @ref Iterators module
 * for more information.
 */
    template <int spacedim>
    class Iterators<2,spacedim>
    {
      public:
        typedef TriaRawIterator<dealii::MGDoFAccessor<1,2,spacedim> >    raw_line_iterator;
        typedef TriaIterator<dealii::MGDoFAccessor<1,2,spacedim> >       line_iterator;
        typedef TriaActiveIterator<dealii::MGDoFAccessor<1,2,spacedim> > active_line_iterator;
    
        typedef TriaRawIterator<dealii::MGDoFCellAccessor<2,spacedim> >         raw_quad_iterator;
        typedef TriaIterator<dealii::MGDoFCellAccessor<2,spacedim> >            quad_iterator;
        typedef TriaActiveIterator<dealii::MGDoFCellAccessor<2,spacedim> >      active_quad_iterator;

        typedef TriaRawIterator   <dealii::InvalidAccessor<3,2,spacedim> > raw_hex_iterator;
        typedef TriaIterator      <dealii::InvalidAccessor<3,2,spacedim> > hex_iterator;
        typedef TriaActiveIterator<dealii::InvalidAccessor<3,2,spacedim> > active_hex_iterator;

        typedef raw_quad_iterator    raw_cell_iterator;
        typedef quad_iterator        cell_iterator;
        typedef active_quad_iterator active_cell_iterator;

        typedef raw_line_iterator    raw_face_iterator;
        typedef line_iterator        face_iterator;
        typedef active_line_iterator active_face_iterator;    
    };



/**
 * Iterators for MGDofHandler in three dimensions. See the @ref Iterators module
 * for more information.
 */
    template <int spacedim>
    class Iterators<3,spacedim>
    {
      public:
        typedef TriaRawIterator<dealii::MGDoFAccessor<1,3,spacedim> >    raw_line_iterator;
        typedef TriaIterator<dealii::MGDoFAccessor<1,3,spacedim> >       line_iterator;
        typedef TriaActiveIterator<dealii::MGDoFAccessor<1,3,spacedim> > active_line_iterator;

        typedef TriaRawIterator<dealii::MGDoFAccessor<2,3,spacedim> >    raw_quad_iterator;
        typedef TriaIterator<dealii::MGDoFAccessor<2,3,spacedim> >       quad_iterator;
        typedef TriaActiveIterator<dealii::MGDoFAccessor<2,3,spacedim> > active_quad_iterator;

        typedef TriaRawIterator<dealii::MGDoFCellAccessor<3,spacedim> >        raw_hex_iterator;
        typedef TriaIterator<dealii::MGDoFCellAccessor<3,spacedim> >           hex_iterator;
        typedef TriaActiveIterator<dealii::MGDoFCellAccessor<3,spacedim> >     active_hex_iterator;

        typedef raw_hex_iterator    raw_cell_iterator;
        typedef hex_iterator        cell_iterator;
        typedef active_hex_iterator active_cell_iterator;

        typedef raw_quad_iterator    raw_face_iterator;
        typedef quad_iterator        face_iterator;
        typedef active_quad_iterator active_face_iterator;    
    };
  }
}


DEAL_II_NAMESPACE_CLOSE

#endif
/*----------------------------   mg_dof_iterator_selector.h     ---------------------------*/
