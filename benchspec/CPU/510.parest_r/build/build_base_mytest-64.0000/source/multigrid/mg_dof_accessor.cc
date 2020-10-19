//---------------------------------------------------------------------------
//    $Id: mg_dof_accessor.cc 18097 2009-01-06 04:49:31Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2010, 2013 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <grid/tria_iterator_base.h>
#include <dofs/dof_levels.h>
#include <multigrid/mg_dof_accessor.h>
#include <multigrid/mg_dof_handler.h>
#include <grid/tria_iterator.h>
#include <grid/tria_iterator.templates.h>
#include <fe/fe.h>

#include <lac/vector.h>
#include <lac/full_matrix.h>
#include <lac/sparse_matrix.h>

DEAL_II_NAMESPACE_OPEN


//TODO:[GK] Inline simple functions

/* ------------------------ MGDoFAccessor --------------------------- */


template <int structdim, int dim, int spacedim>
MGDoFAccessor<structdim, dim, spacedim>::MGDoFAccessor ()
		:
		BaseClass (0, -1, -1, 0)
{
  Assert (false, ExcInvalidObject());
}



template <int structdim, int dim, int spacedim>
MGDoFAccessor<structdim, dim, spacedim>::MGDoFAccessor (const Triangulation<dim,spacedim> *tria,
					      const int                 level,
					      const int                 index,
					      const AccessorData       *local_data)
		:
		BaseClass (tria, level, index, local_data),
		mg_dof_handler (const_cast<MGDoFHandler<dim,spacedim>*>(local_data))
{}



template <int structdim, int dim, int spacedim>
void
MGDoFAccessor<structdim, dim, spacedim>::set_mg_dof_handler (MGDoFHandler<dim,spacedim> *dh)
{
  typedef DoFAccessor<dim,DoFHandler<dim> > BaseClass;
  Assert (dh != 0, typename BaseClass::ExcInvalidObject());
  mg_dof_handler = dh;
}



template <int structdim, int dim, int spacedim>
MGDoFAccessor<structdim, dim, spacedim> &
MGDoFAccessor<structdim, dim, spacedim>::operator = (const MGDoFAccessor &da)
{
  BaseClass::operator= (*this);
  
  this->set_dof_handler (da.mg_dof_handler);
  return *this;
}



template <int structdim,int dim, int spacedim>
unsigned int
MGDoFAccessor<structdim, dim, spacedim>::mg_vertex_dof_index (const int level,
						    const unsigned int vertex,
						    const unsigned int i) const
{
  Assert (this->dof_handler != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (this->mg_dof_handler != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (&this->dof_handler->get_fe() != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (vertex<GeometryInfo<structdim>::vertices_per_cell,
	  ExcIndexRange (i,0,GeometryInfo<structdim>::vertices_per_cell));
  Assert (i<this->dof_handler->get_fe().dofs_per_vertex,
	  ExcIndexRange (i, 0, this->dof_handler->get_fe().dofs_per_vertex));

  return (this->mg_dof_handler->mg_vertex_dofs[this->vertex_index(vertex)]
	  .get_index (level, i, this->dof_handler->get_fe().dofs_per_vertex));
}


template <int structdim, int dim, int spacedim>
void
MGDoFAccessor<structdim, dim, spacedim>::set_mg_vertex_dof_index (const int level,
							const unsigned int vertex,
							const unsigned int i,
							const unsigned int index) const
{
  Assert (this->dof_handler != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (this->mg_dof_handler != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (&this->dof_handler->get_fe() != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (vertex<GeometryInfo<structdim>::vertices_per_cell,
	  ExcIndexRange (i,0,GeometryInfo<structdim>::vertices_per_cell));
  Assert (i<this->dof_handler->get_fe().dofs_per_vertex,
	  ExcIndexRange (i, 0, this->dof_handler->get_fe().dofs_per_vertex));

  this->mg_dof_handler->mg_vertex_dofs[this->vertex_index(vertex)]
    .set_index (level, i, this->dof_handler->get_fe().dofs_per_vertex, index);
}



template <int structdim, int dim, int spacedim>
unsigned int
MGDoFAccessor<structdim, dim, spacedim>::mg_dof_index (const int level,
					     const unsigned int i) const
{
  return this->mg_dof_handler
    ->template get_dof_index<structdim>(level,
					this->present_index,
					0,
					i);
}


template <int structdim, int dim, int spacedim>
void MGDoFAccessor<structdim, dim, spacedim>::set_mg_dof_index (const int level,
						      const unsigned int i,
						      const unsigned int index) const
{
  this->mg_dof_handler
    ->template set_dof_index<structdim>(level,
					this->present_index,
					0,
					i,
					index);
}



template <int structdim, int dim, int spacedim>
TriaIterator<MGDoFAccessor<structdim,dim,spacedim> >
MGDoFAccessor<structdim, dim, spacedim>::child (const unsigned int i) const
{
  const TriaIterator<MGDoFAccessor<structdim,dim,spacedim> >
    q (this->tria,
       (structdim == dim ?
	this->level() + 1 :
	0),
       this->child_index (i),
       this->mg_dof_handler);
  
				   // make sure that we either created
				   // a past-the-end iterator or one
				   // pointing to a used cell
  Assert ((q.state() == IteratorState::past_the_end)
	  ||
	  q->used(),
	  TriaAccessorExceptions::ExcUnusedCellAsChild());

  return q;
}



template <int structdim, int dim, int spacedim>
void
MGDoFAccessor<structdim, dim, spacedim>::copy_from (const MGDoFAccessor &a)
{
  DoFAccessor<structdim, DoFHandler<dim> >::copy_from (a);
  this->set_mg_dof_handler (a.mg_dof_handler);
}



template <int structdim, int dim, int spacedim>
typename internal::MGDoFHandler::Iterators<dim,spacedim>::line_iterator
MGDoFAccessor<structdim,dim,spacedim>::line (const unsigned int i) const
{
  Assert (structdim > 1, ExcImpossibleInDim(structdim));
				   // checking of 'i' happens in
				   // line_index(i)
  
  return typename internal::MGDoFHandler::Iterators<dim,spacedim>::line_iterator
    (
      this->tria,
      0,  // only sub-objects are allowed, which have no level
      this->line_index(i),
      this->mg_dof_handler
    );
}


template <int structdim, int dim, int spacedim>
typename internal::MGDoFHandler::Iterators<dim,spacedim>::quad_iterator
MGDoFAccessor<structdim,dim,spacedim>::quad (const unsigned int i) const
{
  Assert (structdim > 2, ExcImpossibleInDim(structdim));
				   // checking of 'i' happens in
				   // quad_index(i)

  return typename internal::MGDoFHandler::Iterators<dim,spacedim>::quad_iterator
    (
      this->tria,
      0,  // only sub-objects are allowed, which have no level
      this->quad_index (i),
      this->mg_dof_handler
    );
}



namespace internal
{
  namespace MGDoFAccessor
  {
    template <int dim, int spacedim>
    void
    get_mg_dof_indices (const dealii::MGDoFAccessor<1, dim, spacedim> &accessor,
			const int level,
			std::vector<unsigned int> &dof_indices)
    {
      const unsigned int dofs_per_vertex = accessor.get_dof_handler().get_fe().dofs_per_vertex,
			 dofs_per_line   = accessor.get_dof_handler().get_fe().dofs_per_line;
      std::vector<unsigned int>::iterator next = dof_indices.begin();
      for (unsigned int vertex=0; vertex<2; ++vertex)
	for (unsigned int d=0; d<dofs_per_vertex; ++d)
	  *next++ = accessor.mg_vertex_dof_index(level,vertex,d);
      for (unsigned int d=0; d<dofs_per_line; ++d)
	*next++ = accessor.mg_dof_index(level,d);
  
      Assert (next == dof_indices.end(),
	      ExcInternalError());
    }


    template <int dim, int spacedim, typename number>
    void
    get_mg_dof_values (const dealii::MGDoFAccessor<1, dim, spacedim> &accessor,
		       const int level,
		       const Vector<number> &values,
		       Vector<number>       &dof_values)
    {
      const unsigned int dofs_per_vertex = accessor.get_dof_handler().get_fe().dofs_per_vertex,
			 dofs_per_line   = accessor.get_dof_handler().get_fe().dofs_per_line;
      typename Vector<number>::iterator next_dof_value=dof_values.begin();
      for (unsigned int vertex=0; vertex<2; ++vertex)
	for (unsigned int d=0; d<dofs_per_vertex; ++d)
	  *next_dof_value++ = values(accessor.mg_vertex_dof_index(level,vertex,d));
      for (unsigned int d=0; d<dofs_per_line; ++d)
	*next_dof_value++ = values(accessor.mg_dof_index(level,d));
  
      Assert (next_dof_value == dof_values.end(),
	      ExcInternalError());
    }




    template <int dim, int spacedim>
    void
    get_mg_dof_indices (const dealii::MGDoFAccessor<2, dim, spacedim> &accessor,
			const int level,
			std::vector<unsigned int> &dof_indices)
    {
      const unsigned int dofs_per_vertex = accessor.get_dof_handler().get_fe().dofs_per_vertex,
			 dofs_per_line   = accessor.get_dof_handler().get_fe().dofs_per_line,
			 dofs_per_quad   = accessor.get_dof_handler().get_fe().dofs_per_quad;
      std::vector<unsigned int>::iterator next = dof_indices.begin();
      for (unsigned int vertex=0; vertex<4; ++vertex)
	for (unsigned int d=0; d<dofs_per_vertex; ++d)
	  *next++ = accessor.mg_vertex_dof_index(level,vertex,d);
      for (unsigned int line=0; line<4; ++line)
	for (unsigned int d=0; d<dofs_per_line; ++d)
	  *next++ = accessor.line(line)->mg_dof_index(level,d);
      for (unsigned int d=0; d<dofs_per_quad; ++d)
	*next++ = accessor.mg_dof_index(level,d);
  
      Assert (next == dof_indices.end(),
	      ExcInternalError());
    }


    template <int dim, int spacedim, typename number>
    void
    get_mg_dof_values (const dealii::MGDoFAccessor<2, dim, spacedim> &accessor,
		       const int level,
		       const Vector<number> &values,
		       Vector<number>       &dof_values)
    {
      const unsigned int dofs_per_vertex = accessor.get_dof_handler().get_fe().dofs_per_vertex,
			 dofs_per_line   = accessor.get_dof_handler().get_fe().dofs_per_line,
			 dofs_per_quad   = accessor.get_dof_handler().get_fe().dofs_per_quad;
      typename Vector<number>::iterator next_dof_value=dof_values.begin();
      for (unsigned int vertex=0; vertex<4; ++vertex)
	for (unsigned int d=0; d<dofs_per_vertex; ++d)
	  *next_dof_value++ = values(accessor.mg_vertex_dof_index(level,vertex,d));
      for (unsigned int line=0; line<4; ++line)
	for (unsigned int d=0; d<dofs_per_line; ++d)
	  *next_dof_value++ = values(accessor.line(line)->mg_dof_index(level,d));
      for (unsigned int d=0; d<dofs_per_quad; ++d)
	*next_dof_value++ = values(accessor.mg_dof_index(level,d));
  
      Assert (next_dof_value == dof_values.end(),
	      ExcInternalError());
    }


    template <int dim, int spacedim>
    void
    get_mg_dof_indices (const dealii::MGDoFAccessor<3, dim, spacedim> &accessor,
			const int level,
			std::vector<unsigned int> &dof_indices)
    {
      const unsigned int dofs_per_vertex = accessor.get_dof_handler().get_fe().dofs_per_vertex,
			 dofs_per_line   = accessor.get_dof_handler().get_fe().dofs_per_line,
			 dofs_per_quad   = accessor.get_dof_handler().get_fe().dofs_per_quad,
			 dofs_per_hex    = accessor.get_dof_handler().get_fe().dofs_per_hex;
      std::vector<unsigned int>::iterator next = dof_indices.begin();
      for (unsigned int vertex=0; vertex<8; ++vertex)
	for (unsigned int d=0; d<dofs_per_vertex; ++d)
	  *next++ = accessor.mg_vertex_dof_index(level,vertex,d);
      for (unsigned int line=0; line<12; ++line)
	for (unsigned int d=0; d<dofs_per_line; ++d)
	  *next++ = accessor.line(line)->mg_dof_index(level,d);
      for (unsigned int quad=0; quad<6; ++quad)
	for (unsigned int d=0; d<dofs_per_quad; ++d)
	  *next++ = accessor.quad(quad)->mg_dof_index(level,d);
      for (unsigned int d=0; d<dofs_per_hex; ++d)
	*next++ = accessor.mg_dof_index(level,d);
  
      Assert (next == dof_indices.end(),
	      ExcInternalError());
    }


    template <int dim, int spacedim, typename number>
    void
    get_mg_dof_values (const dealii::MGDoFAccessor<3, dim, spacedim> &accessor,
		       const int level,
		       const Vector<number> &values,
		       Vector<number>       &dof_values)
    {
      const unsigned int dofs_per_vertex = accessor.get_dof_handler().get_fe().dofs_per_vertex,
			 dofs_per_line   = accessor.get_dof_handler().get_fe().dofs_per_line,
			 dofs_per_quad   = accessor.get_dof_handler().get_fe().dofs_per_quad,
			 dofs_per_hex    = accessor.get_dof_handler().get_fe().dofs_per_hex;
      typename Vector<number>::iterator next_dof_value=dof_values.begin();
      for (unsigned int vertex=0; vertex<8; ++vertex)
	for (unsigned int d=0; d<dofs_per_vertex; ++d)
	  *next_dof_value++ = values(accessor.mg_vertex_dof_index(level,vertex,d));
      for (unsigned int line=0; line<12; ++line)
	for (unsigned int d=0; d<dofs_per_line; ++d)
	  *next_dof_value++ = values(accessor.line(line)->mg_dof_index(level,d));
      for (unsigned int quad=0; quad<6; ++quad)
	for (unsigned int d=0; d<dofs_per_quad; ++d)
	  *next_dof_value++ = values(accessor.quad(quad)->mg_dof_index(level,d));
      for (unsigned int d=0; d<dofs_per_hex; ++d)
	*next_dof_value++ = values(accessor.dof_index(d));
  
      Assert (next_dof_value == dof_values.end(),
	      ExcInternalError());
    }
  }
}



template <int structdim, int dim, int spacedim>
void
MGDoFAccessor<structdim, dim, spacedim>::
get_mg_dof_indices (const int level,
		    std::vector<unsigned int> &dof_indices) const
{
  Assert (this->dof_handler != 0,
	  ExcInvalidObject());
  Assert (this->mg_dof_handler != 0,
	  ExcInvalidObject());
  Assert (&this->dof_handler->get_fe() != 0,
	  ExcInvalidObject());
  switch (structdim)
    {
      case 1:
	    Assert (dof_indices.size() ==
		    (2*this->dof_handler->get_fe().dofs_per_vertex +
		     this->dof_handler->get_fe().dofs_per_line),
		    typename BaseClass::ExcVectorDoesNotMatch());
	    break;
      case 2:
	    Assert (dof_indices.size() ==
		    (4*this->dof_handler->get_fe().dofs_per_vertex +
		     4*this->dof_handler->get_fe().dofs_per_line +
		     this->dof_handler->get_fe().dofs_per_quad),
		    typename BaseClass::ExcVectorDoesNotMatch());
	    break;
      case 3:
	    Assert (dof_indices.size() ==
		    (8*this->dof_handler->get_fe().dofs_per_vertex +
		     12*this->dof_handler->get_fe().dofs_per_line +
		     6*this->dof_handler->get_fe().dofs_per_quad +
		     this->dof_handler->get_fe().dofs_per_hex),
		    typename BaseClass::ExcVectorDoesNotMatch());

	    break;
      default:
	    Assert (false, ExcNotImplemented());
    }

  internal::MGDoFAccessor::get_mg_dof_indices (*this, level, dof_indices);
}



template <int structdim, int dim, int spacedim>
template <typename number>
void
MGDoFAccessor<structdim,dim,spacedim>::
get_mg_dof_values (const int level,
		   const Vector<number> &values,
		   Vector<number>       &dof_values) const
{
  Assert (this->dof_handler != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (this->mg_dof_handler != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (&this->dof_handler->get_fe() != 0,
	  typename BaseClass::ExcInvalidObject());
  Assert (dof_values.size() == this->dof_handler->get_fe().dofs_per_cell,
	  typename BaseClass::ExcVectorDoesNotMatch());
  Assert (values.size() == this->mg_dof_handler->n_dofs(level),
	  typename BaseClass::ExcVectorDoesNotMatch());

  internal::MGDoFAccessor::get_mg_dof_values (*this, level, values, dof_values);
}








/*------------------------- Functions: MGDoFCellAccessor -----------------------*/

template <int dim, int spacedim>
MGDoFCellAccessor<dim,spacedim>::MGDoFCellAccessor (const Triangulation<dim,spacedim> *tria,
					   const int                 level,
					   const int                 index,
					   const AccessorData       *local_data)
		:
		MGDoFAccessor<dim, dim, spacedim> (tria,level,index,local_data)
{}


template <int dim, int spacedim>
void
MGDoFCellAccessor<dim,spacedim>::get_mg_dof_indices (std::vector<unsigned int> &dof_indices) const
{
  MGDoFAccessor<dim,dim,spacedim>::get_mg_dof_indices (this->level(), dof_indices);
}


template <int dim, int spacedim>
template <typename number>
void
MGDoFCellAccessor<dim,spacedim>::get_mg_dof_values (const Vector<number> &values,
					   Vector<number>       &dof_values) const
{
  MGDoFAccessor<dim,dim,spacedim>::get_mg_dof_values (this->level(), values, dof_values);
}



template <int dim, int spacedim>
TriaIterator<MGDoFCellAccessor<dim,spacedim> >
MGDoFCellAccessor<dim,spacedim>::neighbor (const unsigned int i) const
{
  TriaIterator<MGDoFCellAccessor<dim,spacedim> > q (this->tria,
					       this->neighbor_level (i),
					       this->neighbor_index (i),
					       this->mg_dof_handler);
  
#ifdef DEBUG
  if (q.state() != IteratorState::past_the_end)
    Assert (q->used(), TriaAccessorExceptions::ExcUnusedCellAsNeighbor());
#endif
  return q;
}


template <int dim, int spacedim>
TriaIterator<MGDoFCellAccessor<dim,spacedim> >
MGDoFCellAccessor<dim,spacedim>::child (const unsigned int i) const
{
  TriaIterator<MGDoFCellAccessor<dim,spacedim> > q (this->tria,
					       this->present_level+1,
					       this->child_index (i),
					       this->mg_dof_handler);
  
#ifdef DEBUG
  if (q.state() != IteratorState::past_the_end)
    Assert (q->used(), TriaAccessorExceptions::ExcUnusedCellAsChild());
#endif
  return q;
}


template <int dim, int spacedim>
typename internal::MGDoFHandler::Iterators<dim,spacedim>::face_iterator
MGDoFCellAccessor<dim,spacedim>::face (const unsigned int i) const
{
  switch (dim)
    {
      case 1:
	    Assert (false, ExcImpossibleInDim(1));
	    return
	      typename internal::MGDoFHandler::Iterators<dim,spacedim>::face_iterator();
      case 2:
	    return this->line(i);
      case 3:
	    return this->quad(i);
      default:
	    Assert (false, ExcNotImplemented());
	    return 
	      typename internal::MGDoFHandler::Iterators<dim,spacedim>::face_iterator();
    }
}



template <int dim, int spacedim>
typename internal::MGDoFHandler::Iterators<dim,spacedim>::cell_iterator
MGDoFCellAccessor<dim,spacedim>::
neighbor_child_on_subface (const unsigned int face,
                           const unsigned int subface) const
{
  const TriaIterator<CellAccessor<dim,spacedim> > q
    = CellAccessor<dim,spacedim>::neighbor_child_on_subface (face, subface);
  return TriaIterator<MGDoFCellAccessor<dim,spacedim> > (this->tria,
						    q->level (),
						    q->index (),
						    this->mg_dof_handler);
}




// explicit instantiations

template
void
MGDoFAccessor<1,deal_II_dimension>::
get_mg_dof_values (const int level,
		   const Vector<double> &values,
		   Vector<double>       &dof_values) const;

template
void
MGDoFAccessor<1,deal_II_dimension>::
get_mg_dof_values (const int level,
		   const Vector<float> &values,
		   Vector<float>       &dof_values) const;


#if deal_II_dimension >= 2

template
void
MGDoFAccessor<2,deal_II_dimension>::
get_mg_dof_values (const int level,
		   const Vector<double> &values,
		   Vector<double>       &dof_values) const;

template
void
MGDoFAccessor<2,deal_II_dimension>::
get_mg_dof_values (const int level,
		   const Vector<float> &values,
		   Vector<float>       &dof_values) const;

#endif


#if deal_II_dimension >= 3

template
void
MGDoFAccessor<3,deal_II_dimension>::
get_mg_dof_values (const int level,
		   const Vector<double> &values,
		   Vector<double>       &dof_values) const;

template
void
MGDoFAccessor<3,deal_II_dimension>::
get_mg_dof_values (const int level,
		   const Vector<float> &values,
		   Vector<float>       &dof_values) const;

#endif
template
void
MGDoFCellAccessor<deal_II_dimension>::
get_mg_dof_values (const Vector<double> &values,
		   Vector<double>       &dof_values) const;

template
void
MGDoFCellAccessor<deal_II_dimension>::
get_mg_dof_values (const Vector<float> &values,
		   Vector<float>       &dof_values) const;



#if deal_II_dimension == 1
template class MGDoFAccessor<1, 1>;

template class MGDoFCellAccessor<1>;

template class TriaRawIterator<MGDoFCellAccessor<1> >;
template class TriaIterator<MGDoFCellAccessor<1> >;
template class TriaActiveIterator<MGDoFCellAccessor<1> >;
#endif

#if deal_II_dimension == 2
template class MGDoFAccessor<1, 2>;
template class MGDoFAccessor<2, 2>;

template class MGDoFCellAccessor<2>;

template class TriaRawIterator   <MGDoFAccessor<1, 2> >;
template class TriaIterator      <MGDoFAccessor<1, 2> >;
template class TriaActiveIterator<MGDoFAccessor<1, 2> >;

template class TriaRawIterator   <MGDoFCellAccessor<2> >;
template class TriaIterator      <MGDoFCellAccessor<2> >;
template class TriaActiveIterator<MGDoFCellAccessor<2> >;
#endif


#if deal_II_dimension == 3
template class MGDoFAccessor<1, 3>;
template class MGDoFAccessor<2, 3>;
template class MGDoFAccessor<3, 3>;

template class MGDoFCellAccessor<3>;

template class TriaRawIterator   <MGDoFAccessor<1, 3> >;
template class TriaIterator      <MGDoFAccessor<1, 3> >;
template class TriaActiveIterator<MGDoFAccessor<1, 3> >;

template class TriaRawIterator   <MGDoFAccessor<2, 3> >;
template class TriaIterator      <MGDoFAccessor<2, 3> >;
template class TriaActiveIterator<MGDoFAccessor<2, 3> >;

template class TriaRawIterator   <MGDoFCellAccessor<3> >;
template class TriaIterator      <MGDoFCellAccessor<3> >;
template class TriaActiveIterator<MGDoFCellAccessor<3> >;
#endif

DEAL_II_NAMESPACE_CLOSE
