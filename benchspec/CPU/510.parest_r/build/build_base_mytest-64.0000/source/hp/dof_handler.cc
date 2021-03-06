//----------------------------  hp_dof_handler.cc  ------------------------
//    $Id: dof_handler.cc 18724 2009-04-23 23:06:37Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2003, 2004, 2006, 2007, 2008, 2009 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//----------------------------  hp_dof_handler.cc  ------------------------


#include <base/memory_consumption.h>
#include <hp/dof_handler.h>
#include <hp/dof_objects.h>
#include <hp/dof_levels.h>
#include <hp/dof_faces.h>
#include <dofs/dof_accessor.h>
#include <grid/tria_accessor.h>
#include <grid/tria_iterator.h>
#include <grid/tria_levels.h>
#include <grid/tria.h>
#include <grid/geometry_info.h>
#include <fe/fe.h>

#include <set>
#include <algorithm>
#include <functional>

DEAL_II_NAMESPACE_OPEN

namespace internal
{
  namespace hp
  {
    typedef
      std::vector<std::pair<unsigned int, unsigned int> > DoFIdentities;


				     /**
				      * Make sure that the given @p
				      * identities pointer points to a
				      * valid array. If the pointer is
				      * zero beforehand, create an
				      * entry with the correct
				      * data. If it is nonzero, don't
				      * touch it.
				      *
				      * @p structdim denotes the
				      * dimension of the objects on
				      * which identities are to be
				      * represented, i.e. zero for
				      * vertices, one for lines, etc.
				      */
    template <int structdim, int dim, int spacedim>
    void
    ensure_existence_of_dof_identities (const FiniteElement<dim,spacedim> &fe1,
					const FiniteElement<dim,spacedim> &fe2,
					std_cxx1x::shared_ptr<DoFIdentities> &identities)
    {
				       // see if we need to fill this
				       // entry, or whether it already
				       // exists
      if (identities == 0)
	{
	  switch (structdim)
	    {
	      case 0:
	      {
		identities =
		  std_cxx1x::shared_ptr<DoFIdentities>
		  (new DoFIdentities(fe1.hp_vertex_dof_identities(fe2)));
		break;
	      }
	      
	      case 1:
	      {
		identities =
		  std_cxx1x::shared_ptr<DoFIdentities>
		  (new DoFIdentities(fe1.hp_line_dof_identities(fe2)));
		break;
	      }
	      
	      case 2:
	      {
		identities =
		  std_cxx1x::shared_ptr<DoFIdentities>
		  (new DoFIdentities(fe1.hp_quad_dof_identities(fe2)));
		break;
	      }
	      
	      default:
		    Assert (false, ExcNotImplemented());
	    }

					   // double check whether the
					   // newly created entries
					   // make any sense at all
	  for (unsigned int i=0; i<identities->size(); ++i)
	    {
	      Assert ((*identities)[i].first < fe1.template n_dofs_per_object<structdim>(),
		      ExcInternalError());
	      Assert ((*identities)[i].second < fe2.template n_dofs_per_object<structdim>(),
		      ExcInternalError());
	    }
	}
    }



                                     /**
                                      * For an object, such as a line
                                      * or a quad iterator, determine
                                      * the fe_index of the most
                                      * dominating finite element that
                                      * lives on this object.
                                      */
    template <int dim, int spacedim, typename iterator>
    unsigned int
    get_most_dominating_fe_index (const iterator &object)
    {
      unsigned int dominating_fe_index = 0;
      for (; dominating_fe_index<object->n_active_fe_indices();
           ++dominating_fe_index)
        {
          const FiniteElement<dim, spacedim> &this_fe
            = object->get_fe (object->nth_active_fe_index(dominating_fe_index));
			
          FiniteElementDomination::Domination
            domination = FiniteElementDomination::either_element_can_dominate;
          for (unsigned int other_fe_index=0;
               other_fe_index<object->n_active_fe_indices();
               ++other_fe_index)
            if (other_fe_index != dominating_fe_index)
              {
                const FiniteElement<dim, spacedim>
		  &that_fe
                  = object->get_fe (object->nth_active_fe_index(other_fe_index));
			      
                domination = domination &
                             this_fe.compare_for_face_domination(that_fe);
              }
			
                                           // see if this element is
                                           // able to dominate all the
                                           // other ones, and if so
                                           // take it
          if ((domination == FiniteElementDomination::this_element_dominates)
              ||
              (domination == FiniteElementDomination::either_element_can_dominate))
            break;
        }

                                       // check that we have
                                       // found one such fe
      Assert (dominating_fe_index != object->n_active_fe_indices(),
              ExcNotImplemented());

                                       // return the finite element
                                       // index used on it. note
                                       // that only a single fe can
                                       // be active on such subfaces
      return object->nth_active_fe_index(dominating_fe_index);
    }
  }
}

  

namespace internal
{
  namespace hp
  {
    namespace DoFHandler
    {
				       // access class
				       // dealii::hp::DoFHandler instead of
				       // namespace internal::hp::DoFHandler, etc
      using dealii::hp::DoFHandler;

/**
 * A class with the same purpose as the similarly named class of the
 * Triangulation class. See there for more information.
 */
      struct Implementation
      {
					   /**
					    * Do that part of reserving
					    * space that pertains to
					    * vertices, since this is the
					    * same in all space
					    * dimensions.
					    */
	  template<int dim, int spacedim>
	  static
	  void
	  reserve_space_vertices (DoFHandler<dim,spacedim> &dof_handler)
	    { 
					       // The final step is allocating
					       // memory is to set up vertex dof
					       // information. since vertices
					       // are sequentially numbered,
					       // what we do first is to set up
					       // an array in which we record
					       // whether a vertex is associated
					       // with any of the given fe's, by
					       // setting a bit. in a later
					       // step, we then actually
					       // allocate memory for the
					       // required dofs
	      std::vector<std::vector<bool> >
		vertex_fe_association (dof_handler.finite_elements->size(),
				       std::vector<bool> (dof_handler.tria->n_vertices(), false));
      
	      for (typename DoFHandler<dim,spacedim>::active_cell_iterator
		     cell=dof_handler.begin_active(); cell!=dof_handler.end(); ++cell)
		for (unsigned int v=0; v<GeometryInfo<dim>::vertices_per_cell; ++v)
		  vertex_fe_association[cell->active_fe_index()][cell->vertex_index(v)]
		    = true;
      
					       // in debug mode, make sure
					       // that each vertex is
					       // associated with at least one
					       // fe (note that except for
					       // unused vertices, all
					       // vertices are actually
					       // active)
#ifdef DEBUG
	      for (unsigned int v=0; v<dof_handler.tria->n_vertices(); ++v)
		if (dof_handler.tria->vertex_used(v) == true)
		  {
		    unsigned int fe=0;
		    for (; fe<dof_handler.finite_elements->size(); ++fe)
		      if (vertex_fe_association[fe][v] == true)
			break;
		    Assert (fe != dof_handler.finite_elements->size(), ExcInternalError());
		  }
#endif

					       // next count how much memory
					       // we actually need. for each
					       // vertex, we need one slot per
					       // fe to store the fe_index,
					       // plus dofs_per_vertex for
					       // this fe. in addition, we
					       // need one slot as the end
					       // marker for the
					       // fe_indices. at the same time
					       // already fill the
					       // vertex_dofs_offsets field
	      dof_handler.vertex_dofs_offsets.resize (dof_handler.tria->n_vertices(),
						      numbers::invalid_unsigned_int);
      
	      unsigned int vertex_slots_needed = 0;
	      for (unsigned int v=0; v<dof_handler.tria->n_vertices(); ++v)
		if (dof_handler.tria->vertex_used(v) == true)
		  {
		    dof_handler.vertex_dofs_offsets[v] = vertex_slots_needed;
	    
		    for (unsigned int fe=0; fe<dof_handler.finite_elements->size(); ++fe)
		      if (vertex_fe_association[fe][v] == true)
			vertex_slots_needed += (*dof_handler.finite_elements)[fe].dofs_per_vertex + 1;
		    ++vertex_slots_needed;
		  }

					       // now allocate the space we
					       // have determined we need, and
					       // set up the linked lists for
					       // each of the vertices
	      dof_handler.vertex_dofs.resize (vertex_slots_needed,
					      DoFHandler<dim,spacedim>::invalid_dof_index);
	      for (unsigned int v=0; v<dof_handler.tria->n_vertices(); ++v)
		if (dof_handler.tria->vertex_used(v) == true)
		  {
		    unsigned int pointer = dof_handler.vertex_dofs_offsets[v];
		    for (unsigned int fe=0; fe<dof_handler.finite_elements->size(); ++fe)
		      if (vertex_fe_association[fe][v] == true)
			{
							   // if this vertex
							   // uses this fe,
							   // then set the
							   // fe_index and
							   // move the pointer
							   // ahead
			  dof_handler.vertex_dofs[pointer] = fe;
			  pointer += (*dof_handler.finite_elements)[fe].dofs_per_vertex + 1;
			}
						     // finally place the end
						     // marker
		    dof_handler.vertex_dofs[pointer] = numbers::invalid_unsigned_int;
		  }
	    }

      
    
					   /**
					    * Distribute dofs on the given cell,
					    * with new dofs starting with index
					    * @p next_free_dof. Return the next
					    * unused index number. The finite
					    * element used is the one given to
					    * @p distribute_dofs, which is copied
					    * to @p selected_fe.
					    *
					    * This function is excluded from the
					    * @p distribute_dofs function since
					    * it can not be implemented dimension
					    * independent.
					    */
	  template <int spacedim>
	  static
	  unsigned int
	  distribute_dofs_on_cell (const typename DoFHandler<1,spacedim>::active_cell_iterator &cell,
				   unsigned int          next_free_dof)
	    {
	      const unsigned int dim = 1;
	      
	      const FiniteElement<dim,spacedim> &fe       = cell->get_fe();
	      const unsigned int                 fe_index = cell->active_fe_index ();
    
					       // number dofs on vertices. to do
					       // so, check whether dofs for
					       // this vertex have been
					       // distributed and for the
					       // present fe (only check the
					       // first dof), and if this isn't
					       // the case distribute new ones
					       // there
	      if (fe.dofs_per_vertex > 0)
		for (unsigned int vertex=0; vertex<GeometryInfo<1>::vertices_per_cell; ++vertex)
		  if (cell->vertex_dof_index(vertex, 0, fe_index) ==
		      DoFHandler<dim,spacedim>::invalid_dof_index)
		    for (unsigned int d=0; d<fe.dofs_per_vertex; ++d, ++next_free_dof)
		      cell->set_vertex_dof_index (vertex, d, next_free_dof, fe_index);
    
					       // finally for the line. this one
					       // shouldn't be numbered yet
	      if (fe.dofs_per_line > 0)
		{
		  Assert ((cell->dof_index(0, fe_index) ==
			   DoFHandler<dim,spacedim>::invalid_dof_index),
			  ExcInternalError());
	
		  for (unsigned int d=0; d<fe.dofs_per_line; ++d, ++next_free_dof)
		    cell->set_dof_index (d, next_free_dof, fe_index);
		}

					       // note that this cell has been processed
	      cell->set_user_flag ();
  
	      return next_free_dof;
	    }


	  template <int spacedim>
	  static
	  unsigned int
	  distribute_dofs_on_cell (const typename DoFHandler<2,spacedim>::active_cell_iterator &cell,
				   unsigned int          next_free_dof)
	    {
	      const unsigned int dim = 2;

	      const FiniteElement<dim,spacedim> &fe       = cell->get_fe();
	      const unsigned int                 fe_index = cell->active_fe_index ();
    
					       // number dofs on vertices. to do
					       // so, check whether dofs for
					       // this vertex have been
					       // distributed and for the
					       // present fe (only check the
					       // first dof), and if this isn't
					       // the case distribute new ones
					       // there
	      if (fe.dofs_per_vertex > 0)
		for (unsigned int vertex=0; vertex<GeometryInfo<2>::vertices_per_cell; ++vertex)
		  if (cell->vertex_dof_index(vertex, 0, fe_index) ==
		      DoFHandler<dim,spacedim>::invalid_dof_index)
		    for (unsigned int d=0; d<fe.dofs_per_vertex; ++d, ++next_free_dof)
		      cell->set_vertex_dof_index (vertex, d, next_free_dof, fe_index);
    
					       // next the sides. do the
					       // same as above: check whether
					       // the line is already numbered
					       // for the present fe_index, and
					       // if not do it
	      if (fe.dofs_per_line > 0)
		for (unsigned int l=0; l<GeometryInfo<2>::lines_per_cell; ++l)
		  {
		    typename DoFHandler<dim,spacedim>::line_iterator
		      line = cell->line(l);

		    if (line->dof_index(0,fe_index) ==
			DoFHandler<dim,spacedim>::invalid_dof_index)
		      for (unsigned int d=0; d<fe.dofs_per_line; ++d, ++next_free_dof)
			line->set_dof_index (d, next_free_dof, fe_index);
		  }


					       // finally for the quad. this one
					       // shouldn't be numbered yet
	      if (fe.dofs_per_quad > 0)
		{
		  Assert ((cell->dof_index(0, fe_index) ==
			   DoFHandler<dim,spacedim>::invalid_dof_index),
			  ExcInternalError());
	
		  for (unsigned int d=0; d<fe.dofs_per_quad; ++d, ++next_free_dof)
		    cell->set_dof_index (d, next_free_dof, fe_index);
		}

					       // note that this cell has been processed
	      cell->set_user_flag ();
  
	      return next_free_dof;
	    }


	  template <int spacedim>
	  static
	  unsigned int
	  distribute_dofs_on_cell (const typename DoFHandler<3,spacedim>::active_cell_iterator &cell,
				   unsigned int          next_free_dof)
	    {
	      const unsigned int dim = 3;

	      const FiniteElement<dim,spacedim> &fe       = cell->get_fe();
	      const unsigned int                 fe_index = cell->active_fe_index ();
    
					       // number dofs on vertices. to do
					       // so, check whether dofs for
					       // this vertex have been
					       // distributed and for the
					       // present fe (only check the
					       // first dof), and if this isn't
					       // the case distribute new ones
					       // there
	      if (fe.dofs_per_vertex > 0)
		for (unsigned int vertex=0; vertex<GeometryInfo<3>::vertices_per_cell; ++vertex)
		  if (cell->vertex_dof_index(vertex, 0, fe_index) ==
		      DoFHandler<dim,spacedim>::invalid_dof_index)
		    for (unsigned int d=0; d<fe.dofs_per_vertex; ++d, ++next_free_dof)
		      cell->set_vertex_dof_index (vertex, d, next_free_dof, fe_index);
    
					       // next the four lines. do the
					       // same as above: check whether
					       // the line is already numbered
					       // for the present fe_index, and
					       // if not do it
	      if (fe.dofs_per_line > 0)
		for (unsigned int l=0; l<GeometryInfo<3>::lines_per_cell; ++l)
		  {
		    typename DoFHandler<dim,spacedim>::line_iterator
		      line = cell->line(l);

		    if (line->dof_index(0,fe_index) ==
			DoFHandler<dim,spacedim>::invalid_dof_index)
		      for (unsigned int d=0; d<fe.dofs_per_line; ++d, ++next_free_dof)
			line->set_dof_index (d, next_free_dof, fe_index);
		  }

					       // same for quads
	      if (fe.dofs_per_quad > 0)
		for (unsigned int q=0; q<GeometryInfo<3>::quads_per_cell; ++q)
		  {
		    typename DoFHandler<dim,spacedim>::quad_iterator
		      quad = cell->quad(q);

		    if (quad->dof_index(0,fe_index) ==
			DoFHandler<dim,spacedim>::invalid_dof_index)
		      for (unsigned int d=0; d<fe.dofs_per_quad; ++d, ++next_free_dof)
			quad->set_dof_index (d, next_free_dof, fe_index);
		  }


					       // finally for the hex. this one
					       // shouldn't be numbered yet
	      if (fe.dofs_per_hex > 0)
		{
		  Assert ((cell->dof_index(0, fe_index) ==
			   DoFHandler<dim,spacedim>::invalid_dof_index),
			  ExcInternalError());
	
		  for (unsigned int d=0; d<fe.dofs_per_hex; ++d, ++next_free_dof)
		    cell->set_dof_index (d, next_free_dof, fe_index);
		}

					       // note that this cell has been processed
	      cell->set_user_flag ();
  
	      return next_free_dof;
	    }
      
      
					   /**
					    * Reserve enough space in the 
					    * <tt>levels[]</tt> objects to store the
					    * numbers of the degrees of freedom
					    * needed for the given element. The
					    * given element is that one which
					    * was selected when calling
					    * @p distribute_dofs the last time.
					    */
	  template <int spacedim>
	  static
	  void
	  reserve_space (DoFHandler<1,spacedim> &dof_handler)
	    {
	      const unsigned int dim = 1;

	      typedef DoFHandler<dim,spacedim> BaseClass;
	      
	      Assert (dof_handler.finite_elements != 0,
		      typename BaseClass::ExcNoFESelected());
	      Assert (dof_handler.finite_elements->size() > 0,
		      typename BaseClass::ExcNoFESelected());
	      Assert (dof_handler.tria->n_levels() > 0,
		      typename
		      BaseClass::ExcInvalidTriangulation());
	      Assert (dof_handler.tria->n_levels() == dof_handler.levels.size (),
		      ExcInternalError ());

					       // Release all space except the
					       // active_fe_indices field which
					       // we have to backup before
	      {
		std::vector<std::vector<unsigned int> >
		  active_fe_backup(dof_handler.levels.size ());
		for (unsigned int level = 0; level<dof_handler.levels.size (); ++level)
		  std::swap (dof_handler.levels[level]->active_fe_indices, active_fe_backup[level]);

						 // delete all levels and set them up
						 // newly, since vectors are
						 // troublesome if you want to change
						 // their size
		dof_handler.clear_space ();
  
		for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level) 
		  {
		    dof_handler.levels.push_back (new internal::hp::DoFLevel<dim>);
		    std::swap (active_fe_backup[level],
			       dof_handler.levels[level]->active_fe_indices);
		  }
	      }

					       // LINE (CELL) DOFs
    
					       // count how much space we need
					       // on each level for the cell
					       // dofs and set the
					       // dof_*_offsets
					       // data. initially set the latter
					       // to an invalid index, and only
					       // later set it to something
					       // reasonable for active dof_handler.cells
					       //
					       // note that for dof_handler.cells, the
					       // situation is simpler than for
					       // other (lower dimensional)
					       // objects since exactly one
					       // finite element is used for it
	      for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level) 
		{
		  dof_handler.levels[level]->lines.dof_offsets
		    = std::vector<unsigned int> (dof_handler.tria->n_raw_lines(level),
						 DoFHandler<dim,spacedim>::invalid_dof_index);

		  unsigned int next_free_dof = 0;
		  for (typename DoFHandler<dim,spacedim>::active_cell_iterator
			 cell=dof_handler.begin_active(level);
		       cell!=dof_handler.end_active(level); ++cell)
		    if (!cell->has_children())
		      {
			dof_handler.levels[level]->lines.dof_offsets[cell->index()] = next_free_dof;
			next_free_dof += cell->get_fe().dofs_per_line;
		      }

		  dof_handler.levels[level]->lines.dofs
		    = std::vector<unsigned int> (next_free_dof,
						 DoFHandler<dim,spacedim>::invalid_dof_index);
		}

					       // safety check: make sure that
					       // the number of DoFs we
					       // allocated is actually correct
					       // (above we have also set the
					       // dof_*_offsets field, so
					       // we couldn't use this simpler
					       // algorithm)
#ifdef DEBUG
	      for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level)
		{
		  unsigned int counter = 0;
		  for (typename DoFHandler<dim,spacedim>::cell_iterator
			 cell=dof_handler.begin_active(level);
		       cell!=dof_handler.end_active(level); ++cell)
		    if (!cell->has_children())
		      counter += cell->get_fe().dofs_per_line;
        
		  Assert (dof_handler.levels[level]->lines.dofs.size() == counter,
			  ExcInternalError());
		  Assert (static_cast<unsigned int>
			  (std::count (dof_handler.levels[level]->lines.dof_offsets.begin(),
				       dof_handler.levels[level]->lines.dof_offsets.end(),
				       DoFHandler<dim,spacedim>::invalid_dof_index))
			  ==
			  dof_handler.tria->n_raw_lines(level) - dof_handler.tria->n_active_lines(level),
			  ExcInternalError());
		}
#endif
    
    
					       // VERTEX DOFS
	      reserve_space_vertices (dof_handler);
	    }
      

	  template <int spacedim>
	  static
	  void
	  reserve_space (DoFHandler<2,spacedim> &dof_handler)
	    {
	      const unsigned int dim = 2;

	      typedef DoFHandler<dim,spacedim> BaseClass;
	      
	      Assert (dof_handler.finite_elements != 0,
		      typename BaseClass::ExcNoFESelected());
	      Assert (dof_handler.finite_elements->size() > 0,
		      typename BaseClass::ExcNoFESelected());
	      Assert (dof_handler.tria->n_levels() > 0,
		      typename BaseClass::ExcInvalidTriangulation());
	      Assert (dof_handler.tria->n_levels() == dof_handler.levels.size (),
		      ExcInternalError ());

					       // Release all space except the
					       // active_fe_indices field which
					       // we have to backup before
	      {
		std::vector<std::vector<unsigned int> >
		  active_fe_backup(dof_handler.levels.size ());
		for (unsigned int level = 0; level<dof_handler.levels.size (); ++level)
		  std::swap (dof_handler.levels[level]->active_fe_indices,
			     active_fe_backup[level]);

						 // delete all levels and set them up
						 // newly, since vectors are
						 // troublesome if you want to change
						 // their size
		dof_handler.clear_space ();
  
		for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level) 
		  {
		    dof_handler.levels.push_back (new internal::hp::DoFLevel<dim>);
		    std::swap (active_fe_backup[level],
			       dof_handler.levels[level]->active_fe_indices);
		  }
		dof_handler.faces = new internal::hp::DoFFaces<2>;
	      }

    
					       // QUAD (CELL) DOFs
    
					       // count how much space we need
					       // on each level for the cell
					       // dofs and set the
					       // dof_*_offsets
					       // data. initially set the latter
					       // to an invalid index, and only
					       // later set it to something
					       // reasonable for active dof_handler.cells
					       //
					       // note that for dof_handler.cells, the
					       // situation is simpler than for
					       // other (lower dimensional)
					       // objects since exactly one
					       // finite element is used for it
	      for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level) 
		{
		  dof_handler.levels[level]->quads.dof_offsets
		    = std::vector<unsigned int> (dof_handler.tria->n_raw_quads(level),
						 DoFHandler<dim,spacedim>::invalid_dof_index);

		  unsigned int next_free_dof = 0;
		  for (typename DoFHandler<dim,spacedim>::active_cell_iterator
			 cell=dof_handler.begin_active(level);
		       cell!=dof_handler.end_active(level); ++cell)
		    if (!cell->has_children())
		      {
			dof_handler.levels[level]->quads.dof_offsets[cell->index()] = next_free_dof;
			next_free_dof += cell->get_fe().dofs_per_quad;
		      }

		  dof_handler.levels[level]->quads.dofs
		    = std::vector<unsigned int> (next_free_dof,
						 DoFHandler<dim,spacedim>::invalid_dof_index);
		}

					       // safety check: make sure that
					       // the number of DoFs we
					       // allocated is actually correct
					       // (above we have also set the
					       // dof_*_offsets field, so
					       // we couldn't use this simpler
					       // algorithm)
#ifdef DEBUG
	      for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level)
		{
		  unsigned int counter = 0;
		  for (typename DoFHandler<dim,spacedim>::cell_iterator
			 cell=dof_handler.begin_active(level);
		       cell!=dof_handler.end_active(level); ++cell)
		    if (!cell->has_children())
		      counter += cell->get_fe().dofs_per_quad;
        
		  Assert (dof_handler.levels[level]->quads.dofs.size() == counter,
			  ExcInternalError());
		  Assert (static_cast<unsigned int>
			  (std::count (dof_handler.levels[level]->quads.dof_offsets.begin(),
				       dof_handler.levels[level]->quads.dof_offsets.end(),
				       DoFHandler<dim,spacedim>::invalid_dof_index))
			  ==
			  dof_handler.tria->n_raw_quads(level) - dof_handler.tria->n_active_quads(level),
			  ExcInternalError());
		}
#endif
    
    
					       // LINE DOFS
					       //
					       // same here: count line dofs,
					       // then allocate as much space as
					       // we need and prime the linked
					       // list for lines (see the
					       // description in hp::DoFLevels)
					       // with the indices we will
					       // need. note that our task is
					       // more complicated since two
					       // adjacent dof_handler.cells may have
					       // different active_fe_indices,
					       // in which case we need to
					       // allocate *two* sets of line
					       // dofs for the same line
					       //
					       // the way we do things is that
					       // we loop over all active dof_handler.cells
					       // (these are the ones that have
					       // DoFs only anyway) and all
					       // their dof_handler.faces. We note in the
					       // user flags whether we have
					       // previously visited a face and
					       // if so skip it (consequently,
					       // we have to save and later
					       // restore the line flags)
	      {
		std::vector<bool> saved_line_user_flags;
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .save_user_flags_line (saved_line_user_flags);
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .clear_user_flags_line ();

						 // an array to hold how many
						 // slots (see the hp::DoFLevel
						 // class) we will have to store
						 // on each level
		unsigned int n_line_slots = 0;
    
		for (typename DoFHandler<dim,spacedim>::active_cell_iterator
		       cell=dof_handler.begin_active(); cell!=dof_handler.end(); ++cell)
		  for (unsigned int face=0; face<GeometryInfo<dim>::faces_per_cell; ++face)
		    if (! cell->face(face)->user_flag_set())
		      {
							 // ok, face has not been
							 // visited. so we need to
							 // allocate space for it. let's
							 // see how much we need: we need
							 // one set if a) there is no
							 // neighbor behind this face, or
							 // b) the neighbor is either
							 // coarser or finer than we are,
							 // or c) the neighbor is neither
							 // coarser nor finer, but has
							 // happens to have the same
							 // active_fe_index:
			if (cell->at_boundary(face)
			    ||
			    cell->face(face)->has_children()
			    ||
			    cell->neighbor_is_coarser(face)
			    ||
			    (!cell->at_boundary(face)
			     &&
			     (cell->active_fe_index() == cell->neighbor(face)->active_fe_index())))
							   // ok, one set of
							   // dofs. that makes
							   // one index, 1 times
							   // dofs_per_line
							   // dofs, and one stop
							   // index
			  n_line_slots
			    += (*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_line + 2;

							 // otherwise we do
							 // indeed need two
							 // sets, i.e. two
							 // indices, two sets of
							 // dofs, and one stop
							 // index:
			else
			  n_line_slots
			    += ((*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_line
				+
				(*dof_handler.finite_elements)[cell->neighbor(face)->active_fe_index()]
				.dofs_per_line
				+
				3);
            
							 // mark this face as
							 // visited
			cell->face(face)->set_user_flag ();
		      }

						 // now that we know how many
						 // line dofs we will have to
						 // have on each level, allocate
						 // the memory. note that we
						 // allocate offsets for all
						 // lines, though only the
						 // active ones will have a
						 // non-invalid value later on
		dof_handler.faces->lines.dof_offsets
		  = std::vector<unsigned int> (dof_handler.tria->n_raw_lines(),
					       DoFHandler<dim,spacedim>::invalid_dof_index);
		dof_handler.faces->lines.dofs
		  = std::vector<unsigned int> (n_line_slots,
					       DoFHandler<dim,spacedim>::invalid_dof_index);
      
						 // with the memory now
						 // allocated, loop over the
						 // dof_handler.cells again and prime the
						 // _offset values as well as
						 // the fe_index fields
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .clear_user_flags_line ();

		unsigned int next_free_line_slot = 0;
      
		for (typename DoFHandler<dim,spacedim>::active_cell_iterator
		       cell=dof_handler.begin_active(); cell!=dof_handler.end(); ++cell)
		  for (unsigned int face=0; face<GeometryInfo<dim>::faces_per_cell; ++face)
		    if (! cell->face(face)->user_flag_set())
		      {
							 // same decision tree
							 // as before
			if (cell->at_boundary(face)
			    ||
			    cell->face(face)->has_children()
			    ||
			    cell->neighbor_is_coarser(face)
			    ||
			    (!cell->at_boundary(face)
			     &&
			     (cell->active_fe_index() == cell->neighbor(face)->active_fe_index())))
			  {
			    dof_handler.faces
			      ->lines.dof_offsets[cell->face(face)->index()]
			      = next_free_line_slot;

							     // set first slot
							     // for this line to
							     // active_fe_index
							     // of this face
			    dof_handler.faces
			      ->lines.dofs[next_free_line_slot]
			      = cell->active_fe_index();

							     // the next
							     // dofs_per_line
							     // indices remain
							     // unset for the
							     // moment (i.e. at
							     // invalid_dof_index).
							     // following this
							     // comes the stop
							     // index, which
							     // also is
							     // invalid_dof_index
							     // and therefore
							     // does not have to
							     // be explicitly
							     // set
                  
							     // finally, mark
							     // those slots as
							     // used
			    next_free_line_slot
			      += (*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_line + 2;
			  }
			else
			  {
			    dof_handler.faces
			      ->lines.dof_offsets[cell->face(face)->index()]
			      = next_free_line_slot;

							     // set first slot
							     // for this line to
							     // active_fe_index
							     // of this face
			    dof_handler.faces
			      ->lines.dofs[next_free_line_slot]
			      = cell->active_fe_index();

							     // the next
							     // dofs_per_line
							     // indices remain
							     // unset for the
							     // moment (i.e. at
							     // invalid_dof_index).
							     // 
							     // then comes the
							     // fe_index for the
							     // neighboring
							     // cell:
			    dof_handler.faces
			      ->lines.dofs[next_free_line_slot
					   +
					   (*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_line
					   +
					   1]
			      = cell->neighbor(face)->active_fe_index();
							     // then again a set
							     // of dofs that we
							     // need not set
							     // right now
							     // 
							     // following this
							     // comes the stop
							     // index, which
							     // also is
							     // invalid_dof_index
							     // and therefore
							     // does not have to
							     // be explicitly
							     // set
                  
							     // finally, mark
							     // those slots as
							     // used
			    next_free_line_slot
			      += ((*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_line
				  +
				  (*dof_handler.finite_elements)[cell->neighbor(face)->active_fe_index()]
				  .dofs_per_line
				  +
				  3);
			  }
              
							 // mark this face as
							 // visited
			cell->face(face)->set_user_flag ();
		      }
      
						 // we should have moved the
						 // cursor for each level to the
						 // total number of dofs on that
						 // level. check that
		Assert (next_free_line_slot == n_line_slots,
			ExcInternalError());
      
						 // at the end, restore the user
						 // flags for the lines
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .load_user_flags_line (saved_line_user_flags);
	      }
    

					       // VERTEX DOFS
	      reserve_space_vertices (dof_handler);
	    }
      

	  template <int spacedim>
	  static
	  void
	  reserve_space (DoFHandler<3,spacedim> &dof_handler)
	    {
	      const unsigned int dim = 3;

	      typedef DoFHandler<dim,spacedim> BaseClass;
	      
	      Assert (dof_handler.finite_elements != 0,
		      typename BaseClass::ExcNoFESelected());
	      Assert (dof_handler.finite_elements->size() > 0,
		      typename BaseClass::ExcNoFESelected());
	      Assert (dof_handler.tria->n_levels() > 0,
		      typename BaseClass::ExcInvalidTriangulation());
	      Assert (dof_handler.tria->n_levels() == dof_handler.levels.size (),
		      ExcInternalError ());

					       // Release all space except the
					       // active_fe_indices field which
					       // we have to backup before
	      {
		std::vector<std::vector<unsigned int> >
		  active_fe_backup(dof_handler.levels.size ());
		for (unsigned int level = 0; level<dof_handler.levels.size (); ++level)
		  std::swap (dof_handler.levels[level]->active_fe_indices,
			     active_fe_backup[level]);

						 // delete all levels and set them up
						 // newly, since vectors are
						 // troublesome if you want to change
						 // their size
		dof_handler.clear_space ();
  
		for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level) 
		  {
		    dof_handler.levels.push_back (new internal::hp::DoFLevel<dim>);
		    std::swap (active_fe_backup[level],
			       dof_handler.levels[level]->active_fe_indices);
		  }
		dof_handler.faces = new internal::hp::DoFFaces<3>;
	      }

    
					       // HEX (CELL) DOFs
    
					       // count how much space we need
					       // on each level for the cell
					       // dofs and set the
					       // dof_*_offsets
					       // data. initially set the latter
					       // to an invalid index, and only
					       // later set it to something
					       // reasonable for active dof_handler.cells
					       //
					       // note that for dof_handler.cells, the
					       // situation is simpler than for
					       // other (lower dimensional)
					       // objects since exactly one
					       // finite element is used for it
	      for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level) 
		{
		  dof_handler.levels[level]->hexes.dof_offsets
		    = std::vector<unsigned int> (dof_handler.tria->n_raw_hexs(level),
						 DoFHandler<dim,spacedim>::invalid_dof_index);

		  unsigned int next_free_dof = 0;
		  for (typename DoFHandler<dim,spacedim>::active_cell_iterator
			 cell=dof_handler.begin_active(level);
		       cell!=dof_handler.end_active(level); ++cell)
		    if (!cell->has_children())
		      {
			dof_handler.levels[level]->hexes.dof_offsets[cell->index()] = next_free_dof;
			next_free_dof += cell->get_fe().dofs_per_hex;
		      }

		  dof_handler.levels[level]->hexes.dofs
		    = std::vector<unsigned int> (next_free_dof,
						 DoFHandler<dim,spacedim>::invalid_dof_index);
		}

					       // safety check: make sure that
					       // the number of DoFs we
					       // allocated is actually correct
					       // (above we have also set the
					       // dof_*_offsets field, so
					       // we couldn't use this simpler
					       // algorithm)
#ifdef DEBUG
	      for (unsigned int level=0; level<dof_handler.tria->n_levels(); ++level)
		{
		  unsigned int counter = 0;
		  for (typename DoFHandler<dim,spacedim>::cell_iterator
			 cell=dof_handler.begin_active(level);
		       cell!=dof_handler.end_active(level); ++cell)
		    if (!cell->has_children())
		      counter += cell->get_fe().dofs_per_hex;
        
		  Assert (dof_handler.levels[level]->hexes.dofs.size() == counter,
			  ExcInternalError());
		  Assert (static_cast<unsigned int>
			  (std::count (dof_handler.levels[level]->hexes.dof_offsets.begin(),
				       dof_handler.levels[level]->hexes.dof_offsets.end(),
				       DoFHandler<dim,spacedim>::invalid_dof_index))
			  ==
			  dof_handler.tria->n_raw_hexs(level) - dof_handler.tria->n_active_hexs(level),
			  ExcInternalError());
		}
#endif
    
    
					       // QUAD DOFS
					       //
					       // same here: count quad dofs,
					       // then allocate as much space as
					       // we need and prime the linked
					       // list for quad (see the
					       // description in hp::DoFLevels)
					       // with the indices we will
					       // need. note that our task is
					       // more complicated since two
					       // adjacent dof_handler.cells may have
					       // different active_fe_indices,
					       // in which case we need to
					       // allocate *two* sets of line
					       // dofs for the same line
					       //
					       // the way we do things is that
					       // we loop over all active dof_handler.cells
					       // (these are the ones that have
					       // DoFs only anyway) and all
					       // their dof_handler.faces. We note in the
					       // user flags whether we have
					       // previously visited a face and
					       // if so skip it (consequently,
					       // we have to save and later
					       // restore the line flags)
	      {
		std::vector<bool> saved_quad_user_flags;
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .save_user_flags_quad (saved_quad_user_flags);
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .clear_user_flags_quad ();

						 // examine, how how many
						 // slots (see the hp::DoFLevel
						 // class) we will have to store
		unsigned int n_quad_slots = 0;
    
		for (typename DoFHandler<dim,spacedim>::active_cell_iterator
		       cell=dof_handler.begin_active(); cell!=dof_handler.end(); ++cell)
		  for (unsigned int face=0; face<GeometryInfo<dim>::faces_per_cell; ++face)
		    if (! cell->face(face)->user_flag_set())
		      {
							 // ok, face has not been
							 // visited. so we need to
							 // allocate space for
							 // it. let's see how much
							 // we need: we need one
							 // set if a) there is no
							 // neighbor behind this
							 // face, or b) the
							 // neighbor is not on the
							 // same level or further
							 // refined, or c) the
							 // neighbor is on the
							 // same level, but
							 // happens to have the
							 // same active_fe_index:
			if (cell->at_boundary(face)
			    ||
			    cell->face(face)->has_children()
			    ||
			    cell->neighbor_is_coarser(face)
			    ||
			    (!cell->at_boundary(face)
			     &&
			     (cell->active_fe_index() == cell->neighbor(face)->active_fe_index())))
							   // ok, one set of
							   // dofs. that makes
							   // one index, 1 times
							   // dofs_per_quad
							   // dofs, and one stop
							   // index
			  n_quad_slots
			    += (*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_quad + 2;

							 // otherwise we do
							 // indeed need two
							 // sets, i.e. two
							 // indices, two sets of
							 // dofs, and one stop
							 // index:
			else
			  n_quad_slots
			    += ((*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_quad
				+
				(*dof_handler.finite_elements)[cell->neighbor(face)->active_fe_index()]
				.dofs_per_quad
				+
				3);
            
							 // mark this face as
							 // visited
			cell->face(face)->set_user_flag ();
		      }

						 // now that we know how many
						 // quad dofs we will have to
						 // have,  allocate
						 // the memory. note that we
						 // allocate offsets for all
						 // quads, though only the
						 // active ones will have a
						 // non-invalid value later on
		if (true) 
		  {
		    dof_handler.faces->quads.dof_offsets
		      = std::vector<unsigned int> (dof_handler.tria->n_raw_quads(),
						   DoFHandler<dim,spacedim>::invalid_dof_index);
		    dof_handler.faces->quads.dofs
		      = std::vector<unsigned int> (n_quad_slots,
						   DoFHandler<dim,spacedim>::invalid_dof_index);        
		  }

						 // with the memory now
						 // allocated, loop over the
						 // dof_handler.cells again and prime the
						 // _offset values as well as
						 // the fe_index fields
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .clear_user_flags_quad ();

		unsigned int next_free_quad_slot = 0;
      
		for (typename DoFHandler<dim,spacedim>::active_cell_iterator
		       cell=dof_handler.begin_active(); cell!=dof_handler.end(); ++cell)
		  for (unsigned int face=0; face<GeometryInfo<dim>::faces_per_cell; ++face)
		    if (! cell->face(face)->user_flag_set())
		      {
							 // same decision tree
							 // as before
			if (cell->at_boundary(face)
			    ||
			    cell->face(face)->has_children()
			    ||
			    cell->neighbor_is_coarser(face)
			    ||
			    (!cell->at_boundary(face)
			     &&
			     (cell->active_fe_index() == cell->neighbor(face)->active_fe_index())))
			  {
			    dof_handler.faces
			      ->quads.dof_offsets[cell->face(face)->index()]
			      = next_free_quad_slot;

							     // set first slot
							     // for this quad to
							     // active_fe_index
							     // of this face
			    dof_handler.faces
			      ->quads.dofs[next_free_quad_slot]
			      = cell->active_fe_index();

							     // the next
							     // dofs_per_quad
							     // indices remain
							     // unset for the
							     // moment (i.e. at
							     // invalid_dof_index).
							     // following this
							     // comes the stop
							     // index, which
							     // also is
							     // invalid_dof_index
							     // and therefore
							     // does not have to
							     // be explicitly
							     // set
                  
							     // finally, mark
							     // those slots as
							     // used
			    next_free_quad_slot
			      += (*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_quad + 2;
			  }
			else
			  {
			    dof_handler.faces
			      ->quads.dof_offsets[cell->face(face)->index()]
			      = next_free_quad_slot;

							     // set first slot
							     // for this quad to
							     // active_fe_index
							     // of this face
			    dof_handler.faces
			      ->quads.dofs[next_free_quad_slot]
			      = cell->active_fe_index();

							     // the next
							     // dofs_per_quad
							     // indices remain
							     // unset for the
							     // moment (i.e. at
							     // invalid_dof_index).
							     // 
							     // then comes the
							     // fe_index for the
							     // neighboring
							     // cell:
			    dof_handler.faces
			      ->quads.dofs[next_free_quad_slot
					   +
					   (*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_quad
					   +
					   1]
			      = cell->neighbor(face)->active_fe_index();
							     // then again a set
							     // of dofs that we
							     // need not set
							     // right now
							     // 
							     // following this
							     // comes the stop
							     // index, which
							     // also is
							     // invalid_dof_index
							     // and therefore
							     // does not have to
							     // be explicitly
							     // set
                  
							     // finally, mark
							     // those slots as
							     // used
			    next_free_quad_slot
			      += ((*dof_handler.finite_elements)[cell->active_fe_index()].dofs_per_quad
				  +
				  (*dof_handler.finite_elements)[cell->neighbor(face)->active_fe_index()]
				  .dofs_per_quad
				  +
				  3);
			  }
              
							 // mark this face as
							 // visited
			cell->face(face)->set_user_flag ();
		      }

						 // we should have moved the
						 // cursor to the total number
						 // of dofs. check that
		Assert (next_free_quad_slot == n_quad_slots,
			ExcInternalError());
      
						 // at the end, restore the user
						 // flags for the quads
		const_cast<dealii::Triangulation<dim,spacedim>&>(*dof_handler.tria)
		  .load_user_flags_quad (saved_quad_user_flags);
	      }


					       // LINE DOFS

					       // the situation here is pretty
					       // much like with vertices: there
					       // can be an arbitrary number of
					       // finite elements associated
					       // with each line. 
					       //
					       // the algorithm we use is
					       // somewhat similar to what we do
					       // in reserve_space_vertices()
	      if (true)
		{
						   // what we do first is to set up
						   // an array in which we record
						   // whether a line is associated
						   // with any of the given fe's, by
						   // setting a bit. in a later
						   // step, we then actually
						   // allocate memory for the
						   // required dofs
		  std::vector<std::vector<bool> >
		    line_fe_association (dof_handler.finite_elements->size(),
					 std::vector<bool> (dof_handler.tria->n_raw_lines(),
							    false));
      
		  for (typename DoFHandler<dim,spacedim>::active_cell_iterator
			 cell=dof_handler.begin_active();
		       cell!=dof_handler.end(); ++cell)
		    for (unsigned int l=0; l<GeometryInfo<dim>::lines_per_cell; ++l)
		      line_fe_association[cell->active_fe_index()][cell->line_index(l)]
			= true;

						   // first check which of the
						   // lines is used at all,
						   // i.e. is associated with a
						   // finite element. we do this
						   // since not all lines may
						   // actually be used, in which
						   // case we do not have to
						   // allocate any memory at
						   // all
		  std::vector<bool> line_is_used (dof_handler.tria->n_raw_lines(), false);
		  for (unsigned int line=0; line<dof_handler.tria->n_raw_lines(); ++line)
		    for (unsigned int fe=0; fe<dof_handler.finite_elements->size(); ++fe)
		      if (line_fe_association[fe][line] == true)
			{
			  line_is_used[line] = true;
			  break;
			}
	
						   // next count how much memory
						   // we actually need. for each
						   // line, we need one slot per
						   // fe to store the fe_index,
						   // plus dofs_per_line for
						   // this fe. in addition, we
						   // need one slot as the end
						   // marker for the
						   // fe_indices. at the same
						   // time already fill the
						   // line_dofs_offsets field
		  dof_handler.faces->lines.dof_offsets
		    .resize (dof_handler.tria->n_raw_lines(),
			     numbers::invalid_unsigned_int);
	
		  unsigned int line_slots_needed = 0;
		  for (unsigned int line=0; line<dof_handler.tria->n_raw_lines(); ++line)
		    if (line_is_used[line] == true)
		      {
			dof_handler.faces->lines.dof_offsets[line] = line_slots_needed;
	    
			for (unsigned int fe=0; fe<dof_handler.finite_elements->size(); ++fe)
			  if (line_fe_association[fe][line] == true)
			    line_slots_needed += (*dof_handler.finite_elements)[fe].dofs_per_line + 1;
			++line_slots_needed;
		      }

						   // now allocate the space we
						   // have determined we need, and
						   // set up the linked lists for
						   // each of the lines
		  dof_handler.faces->lines.dofs.resize (line_slots_needed,
							DoFHandler<dim,spacedim>::invalid_dof_index);
		  for (unsigned int line=0; line<dof_handler.tria->n_raw_lines(); ++line)
		    if (line_is_used[line] == true)
		      {
			unsigned int pointer = dof_handler.faces->lines.dof_offsets[line];
			for (unsigned int fe=0; fe<dof_handler.finite_elements->size(); ++fe)
			  if (line_fe_association[fe][line] == true)
			    {
							       // if this line
							       // uses this fe,
							       // then set the
							       // fe_index and
							       // move the
							       // pointer ahead
			      dof_handler.faces->lines.dofs[pointer] = fe;
			      pointer += (*dof_handler.finite_elements)[fe].dofs_per_line + 1;
			    }
							 // finally place the end
							 // marker
			dof_handler.faces->lines.dofs[pointer] = numbers::invalid_unsigned_int;
		      }
		}

    

					       // VERTEX DOFS
	      reserve_space_vertices (dof_handler);
	    }


					   /**
					    * Implement the function of same name
					    * in the mother class.
					    */
	  template <int spacedim>
	  static
	  unsigned int
	  max_couplings_between_dofs (const DoFHandler<1,spacedim> &dof_handler)
	    {
	      return std::min(3*dof_handler.finite_elements->max_dofs_per_vertex() +
			      2*dof_handler.finite_elements->max_dofs_per_line(), dof_handler.n_dofs());
	    }



	  template <int spacedim>
	  static
	  unsigned int
	  max_couplings_between_dofs (const DoFHandler<2,spacedim> &dof_handler)
	    {
					       // get these numbers by drawing pictures
					       // and counting...
					       // example:
					       //   |     |     |
					       // --x-----x--x--X--
					       //   |     |  |  |
					       //   |     x--x--x
					       //   |     |  |  |
					       // --x--x--*--x--x--
					       //   |  |  |     |
					       //   x--x--x     |
					       //   |  |  |     |
					       // --X--x--x-----x--
					       //   |     |     |
					       // x = vertices connected with center vertex *;
					       //   = total of 19
					       // (the X vertices are connected with * if
					       // the vertices adjacent to X are hanging
					       // nodes)
					       // count lines -> 28 (don't forget to count
					       // mother and children separately!)
	      unsigned int max_couplings;
	      switch (dof_handler.tria->max_adjacent_cells())
		{
		  case 4:
			max_couplings=19*dof_handler.finite_elements->max_dofs_per_vertex() +
				      28*dof_handler.finite_elements->max_dofs_per_line() +
				      8*dof_handler.finite_elements->max_dofs_per_quad();
			break;
		  case 5:
			max_couplings=21*dof_handler.finite_elements->max_dofs_per_vertex() +
				      31*dof_handler.finite_elements->max_dofs_per_line() +
				      9*dof_handler.finite_elements->max_dofs_per_quad();
			break;
		  case 6:
			max_couplings=28*dof_handler.finite_elements->max_dofs_per_vertex() +
				      42*dof_handler.finite_elements->max_dofs_per_line() +
				      12*dof_handler.finite_elements->max_dofs_per_quad();
			break;
		  case 7:
			max_couplings=30*dof_handler.finite_elements->max_dofs_per_vertex() +
				      45*dof_handler.finite_elements->max_dofs_per_line() +
				      13*dof_handler.finite_elements->max_dofs_per_quad();
			break;
		  case 8:
			max_couplings=37*dof_handler.finite_elements->max_dofs_per_vertex() +
				      56*dof_handler.finite_elements->max_dofs_per_line() +
				      16*dof_handler.finite_elements->max_dofs_per_quad();
			break;
		  default:
			Assert (false, ExcNotImplemented());
			max_couplings=0;
		};
	      return std::min(max_couplings,dof_handler.n_dofs());
	    }


	  template <int spacedim>
	  static
	  unsigned int
	  max_couplings_between_dofs (const DoFHandler<3,spacedim> &dof_handler)
	    {
//TODO:[?] Invent significantly better estimates than the ones in this function  
					       // doing the same thing here is a rather
					       // complicated thing, compared to the 2d
					       // case, since it is hard to draw pictures
					       // with several refined hexahedra :-) so I
					       // presently only give a coarse estimate
					       // for the case that at most 8 hexes meet
					       // at each vertex
					       //
					       // can anyone give better estimate here?
	      const unsigned int max_adjacent_cells = dof_handler.tria->max_adjacent_cells();

	      unsigned int max_couplings;
	      if (max_adjacent_cells <= 8)
		max_couplings=7*7*7*dof_handler.finite_elements->max_dofs_per_vertex() +
			      7*6*7*3*dof_handler.finite_elements->max_dofs_per_line() +
			      9*4*7*3*dof_handler.finite_elements->max_dofs_per_quad() +
			      27*dof_handler.finite_elements->max_dofs_per_hex();
	      else
		{
		  Assert (false, ExcNotImplemented());
		  max_couplings=0;
		}
  
	      return std::min(max_couplings,dof_handler.n_dofs());
	    }
      };
    }
  }
}


namespace hp
{
  template<int dim, int spacedim>
  const unsigned int DoFHandler<dim,spacedim>::dimension;

  template<int dim, int spacedim>
  const unsigned int DoFHandler<dim,spacedim>::invalid_dof_index;

  template<int dim, int spacedim>
  const unsigned int DoFHandler<dim,spacedim>::default_fe_index;
  


  template<int dim, int spacedim>
  DoFHandler<dim,spacedim>::DoFHandler (const Triangulation<dim,spacedim> &tria)
                  :
                  tria(&tria),
		  faces (NULL),
                  used_dofs (0)
  {
    create_active_fe_table ();
    tria.add_refinement_listener (*this);
  }


  template<int dim, int spacedim>
  DoFHandler<dim,spacedim>::~DoFHandler ()
  {
                                     // unsubscribe as a listener to refinement
                                     // of the underlying triangulation
    tria->remove_refinement_listener (*this);
  
                                     // ...and release allocated memory
    clear ();
  }



/*------------------------ Cell iterator functions ------------------------*/


  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_cell_iterator
  DoFHandler<dim,spacedim>::begin_raw (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      return begin_raw_line (level);
	case 2:
	      return begin_raw_quad (level);
	case 3:
	      return begin_raw_hex (level);
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::cell_iterator
  DoFHandler<dim,spacedim>::begin (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      return begin_line (level);
	case 2:
	      return begin_quad (level);
	case 3:
	      return begin_hex (level);
	default:
	      Assert (false, ExcImpossibleInDim(dim));
	      return cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_cell_iterator
  DoFHandler<dim,spacedim>::begin_active (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      return begin_active_line (level);
	case 2:
	      return begin_active_quad (level);
	case 3:
	      return begin_active_hex (level);
	default:
	      Assert (false, ExcNotImplemented());
	      return active_cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_cell_iterator
  DoFHandler<dim,spacedim>::last_raw () const
  {
    switch (dim)
      {
	case 1:
	      return last_raw_line ();
	case 2:
	      return last_raw_quad ();
	case 3:
	      return last_raw_hex ();
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_cell_iterator
  DoFHandler<dim,spacedim>::last_raw (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      return last_raw_line (level);
	case 2:
	      return last_raw_quad (level);
	case 3:
	      return last_raw_hex (level);
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::cell_iterator
  DoFHandler<dim,spacedim>::last () const
  {
    switch (dim)
      {
	case 1:
	      return last_line ();
	case 2:
	      return last_quad ();
	case 3:
	      return last_hex ();
	default:
	      Assert (false, ExcNotImplemented());
	      return cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::cell_iterator
  DoFHandler<dim,spacedim>::last (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      return last_line (level);
	case 2:
	      return last_quad (level);
	case 3:
	      return last_hex (level);
	default:
	      Assert (false, ExcNotImplemented());
	      return cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_cell_iterator
  DoFHandler<dim,spacedim>::last_active () const
  {
    switch (dim)
      {
	case 1:
	      return last_active_line ();
	case 2:
	      return last_active_quad ();
	case 3:
	      return last_active_hex ();
	default:
	      Assert (false, ExcNotImplemented());
	      return active_cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_cell_iterator
  DoFHandler<dim,spacedim>::last_active (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      return last_active_line (level);
	case 2:
	      return last_active_quad (level);
	case 3:
	      return last_active_hex (level);
	default:
	      Assert (false, ExcNotImplemented());
	      return active_cell_iterator();
      }
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_cell_iterator
  DoFHandler<dim,spacedim>::end () const
  {
    switch (dim)
      {
	case 1:
	      return end_line();
	case 2:
	      return end_quad();
	case 3:
	      return end_hex();
	default:
	      Assert (false, ExcImpossibleInDim(dim));
	      return raw_cell_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_cell_iterator
  DoFHandler<dim, spacedim>::end_raw (const unsigned int level) const
  {
    return (level == tria->n_levels()-1 ?
	    end() :
	    begin_raw (level+1));
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::cell_iterator
  DoFHandler<dim, spacedim>::end (const unsigned int level) const
  {
    return (level == tria->n_levels()-1 ?
	    cell_iterator(end()) :
	    begin (level+1));
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_cell_iterator
  DoFHandler<dim, spacedim>::end_active (const unsigned int level) const
  {
    return (level == tria->n_levels()-1 ?
	    active_cell_iterator(end()) :
	    begin_active (level+1));
  }


/*------------------------ Face iterator functions ------------------------*/


  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_face_iterator
  DoFHandler<dim,spacedim>::begin_raw_face () const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_face_iterator();
	case 2:
	      return begin_raw_line ();
	case 3:
	      return begin_raw_quad ();
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_face_iterator ();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::face_iterator
  DoFHandler<dim,spacedim>::begin_face () const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_face_iterator();
	case 2:
	      return begin_line ();
	case 3:
	      return begin_quad ();
	default:
	      Assert (false, ExcNotImplemented());
	      return face_iterator ();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_face_iterator
  DoFHandler<dim,spacedim>::begin_active_face () const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_face_iterator();
	case 2:
	      return begin_active_line ();
	case 3:
	      return begin_active_quad ();
	default:
	      Assert (false, ExcNotImplemented());
	      return active_face_iterator ();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_face_iterator
  DoFHandler<dim, spacedim>::end_raw_face () const
  {
    return end_face();
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_face_iterator
  DoFHandler<dim,spacedim>::end_face () const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_face_iterator();
	case 2:
	      return end_line ();
	case 3:
	      return end_quad ();
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_face_iterator ();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_face_iterator
  DoFHandler<dim, spacedim>::end_active_face () const
  {
    return active_face_iterator(end_face());
  }





  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_face_iterator
  DoFHandler<dim,spacedim>::last_raw_face () const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_face_iterator();
	case 2:
	      return last_raw_line ();
	case 3:
	      return last_raw_quad ();
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_face_iterator ();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::face_iterator
  DoFHandler<dim,spacedim>::last_face () const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_face_iterator();
	case 2:
	      return last_line ();
	case 3:
	      return last_quad ();
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_face_iterator ();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_face_iterator
  DoFHandler<dim,spacedim>::last_active_face () const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_face_iterator();
	case 2:
	      return last_active_line ();
	case 3:
	      return last_active_quad ();
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_face_iterator ();
      }
  }


/*------------------------ Line iterator functions ------------------------*/



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_line_iterator
  DoFHandler<dim, spacedim>::begin_raw_line (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      Assert (level<tria->n_levels(), ExcInvalidLevel(level));

	      if (tria->n_raw_lines(level) == 0)
		return end_line ();

	      return raw_line_iterator (tria,
					level,
					0,
					this);

	default:
	      Assert (level == 0, ExcFacesHaveNoLevel());
	      return raw_line_iterator (tria,
					0,
					0,
					this);
      }
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::line_iterator
  DoFHandler<dim, spacedim>::begin_line (const unsigned int level) const
  {
				     // level is checked in begin_raw
    raw_line_iterator ri = begin_raw_line (level);
    if (ri.state() != IteratorState::valid)
      return ri;
    while (ri->used() == false)
      if ((++ri).state() != IteratorState::valid)
	return ri;
    return ri;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_line_iterator
  DoFHandler<dim, spacedim>::begin_active_line (const unsigned int level) const
  {
				     // level is checked in begin_raw
    line_iterator i = begin_line (level);
    if (i.state() != IteratorState::valid)
      return i;
    while (i->has_children())
      if ((++i).state() != IteratorState::valid)
	return i;
    return i;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_line_iterator
  DoFHandler<dim, spacedim>::end_line () const
  {
    return raw_line_iterator (tria,
			      -1,
			      -1,
			      this);
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_line_iterator
  DoFHandler<dim, spacedim>::last_raw_line (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      Assert (level<tria->n_levels(), ExcInvalidLevel(level));
	      Assert (tria->n_raw_lines(level) != 0,
		      ExcEmptyLevel (level));

	      return raw_line_iterator (tria,
					level,
					tria->n_raw_lines(level)-1,
					this);

	default:
	      Assert (level == 0, ExcFacesHaveNoLevel());
	      return raw_line_iterator (tria,
					0,
					tria->n_raw_lines()-1,
					this);
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_line_iterator
  DoFHandler<dim, spacedim>::last_raw_line () const
  {
    if (dim == 1)
      return last_raw_line (tria->n_levels()-1);
    else
      return last_raw_line (0);
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::line_iterator
  DoFHandler<dim, spacedim>::last_line (const unsigned int level) const
  {
				     // level is checked in last_raw
    raw_line_iterator ri = last_raw_line(level);
    if (ri->used()==true)
      return ri;
    while ((--ri).state() == IteratorState::valid)
      if (ri->used()==true)
	return ri;
    return ri;
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::line_iterator
  DoFHandler<dim, spacedim>::last_line () const
  {
    if (dim == 1)
      return last_line (tria->n_levels()-1);
    else
      return last_line (0);
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_line_iterator
  DoFHandler<dim, spacedim>::last_active_line (const unsigned int level) const
  {
				     // level is checked in last_raw
    line_iterator i = last_line(level);
    if (i->has_children()==false)
      return i;
    while ((--i).state() == IteratorState::valid)
      if (i->has_children()==false)
	return i;
    return i;
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_line_iterator
  DoFHandler<dim, spacedim>::last_active_line () const
  {
    if (dim == 1)
      return last_active_line (tria->n_levels()-1);
    else
      return last_active_line (0);
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_line_iterator
  DoFHandler<dim, spacedim>::end_raw_line (const unsigned int level) const
  {
    Assert (dim == 1 || level == 0, ExcFacesHaveNoLevel());
    if (dim == 1)
      return (level == tria->n_levels()-1 ?
	      end_line() :
	      begin_raw_line (level+1));
    else
      return end_line();
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::line_iterator
  DoFHandler<dim, spacedim>::end_line (const unsigned int level) const
  {
    Assert (dim == 1 || level == 0, ExcFacesHaveNoLevel());
    if (dim == 1)
      return (level == tria->n_levels()-1 ?
	      line_iterator(end_line()) :
	      begin_line (level+1));
    else
      return line_iterator(end_line());
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_line_iterator
  DoFHandler<dim, spacedim>::end_active_line (const unsigned int level) const
  {
    Assert (dim == 1 || level == 0, ExcFacesHaveNoLevel());
    if (dim == 1)
      return (level == tria->n_levels()-1 ?
	      active_line_iterator(end_line()) :
	      begin_active_line (level+1));
    else
      return active_line_iterator(end_line());
  }



/*------------------------ Quad iterator functions ------------------------*/


  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_quad_iterator
  DoFHandler<dim,spacedim>::begin_raw_quad (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_hex_iterator();
	case 2:
	{
	  Assert (level<tria->n_levels(), ExcInvalidLevel(level));

	  if (tria->n_raw_quads(level) == 0)
	    return end_quad();
  
	  return raw_quad_iterator (tria,
				    level,
				    0,
				    this);
	}

	case 3:
	{
	  Assert (level == 0, ExcFacesHaveNoLevel());

	  return raw_quad_iterator (tria,
				    0,
				    0,
				    this);
	}
      
      
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_hex_iterator();	    
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::quad_iterator
  DoFHandler<dim,spacedim>::begin_quad (const unsigned int level) const
  {
				     // level is checked in begin_raw
    raw_quad_iterator ri = begin_raw_quad (level);
    if (ri.state() != IteratorState::valid)
      return ri;
    while (ri->used() == false)
      if ((++ri).state() != IteratorState::valid)
	return ri;
    return ri;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_quad_iterator
  DoFHandler<dim,spacedim>::begin_active_quad (const unsigned int level) const
  {
				     // level is checked in begin_raw
    quad_iterator i = begin_quad (level);
    if (i.state() != IteratorState::valid)
      return i;
    while (i->has_children())
      if ((++i).state() != IteratorState::valid)
	return i;
    return i;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_quad_iterator
  DoFHandler<dim, spacedim>::end_raw_quad (const unsigned int level) const
  {
    Assert (dim == 2 || level == 0, ExcFacesHaveNoLevel());
    if (dim == 2)
      return (level == tria->n_levels()-1 ?
	      end_quad() :
	      begin_raw_quad (level+1));
    else
      return end_quad();
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::quad_iterator
  DoFHandler<dim, spacedim>::end_quad (const unsigned int level) const
  {
    Assert (dim == 2 || level == 0, ExcFacesHaveNoLevel());
    if (dim == 2)
      return (level == tria->n_levels()-1 ?
	      quad_iterator(end_quad()) :
	      begin_quad (level+1));
    else
      return quad_iterator(end_quad());  
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_quad_iterator
  DoFHandler<dim, spacedim>::end_active_quad (const unsigned int level) const
  {
    Assert(dim == 2 || level == 0, ExcFacesHaveNoLevel());
    if (dim == 2)
      return (level == tria->n_levels()-1 ?
	      active_quad_iterator(end_quad()) :
	      begin_active_quad (level+1));
    else
      return active_quad_iterator(end_quad());
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_quad_iterator
  DoFHandler<dim,spacedim>::end_quad () const
  {
    return raw_quad_iterator (tria,
			      -1,
			      -1,
			      this);
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_quad_iterator
  DoFHandler<dim,spacedim>::last_raw_quad (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_quad_iterator();
	case 2:
	      Assert (level<tria->n_levels(),
		      ExcInvalidLevel(level));
	      Assert (tria->n_raw_quads(level) != 0,
		      ExcEmptyLevel (level));
	      return raw_quad_iterator (tria,
					level,
					tria->n_raw_quads(level)-1,
					this);
	case 3:
	      Assert (level == 0, ExcFacesHaveNoLevel());
	      return raw_quad_iterator (tria,
					0,
					tria->n_raw_quads()-1,
					this);
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_quad_iterator();
      }      
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_quad_iterator
  DoFHandler<dim,spacedim>::last_raw_quad () const
  {
    if (dim == 2)
      return last_raw_quad (tria->n_levels()-1);
    else
      return last_raw_quad (0);
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::quad_iterator
  DoFHandler<dim,spacedim>::last_quad (const unsigned int level) const
  {
				     // level is checked in last_raw
    raw_quad_iterator ri = last_raw_quad(level);
    if (ri->used()==true)
      return ri;
    while ((--ri).state() == IteratorState::valid)
      if (ri->used()==true)
	return ri;
    return ri;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::quad_iterator
  DoFHandler<dim,spacedim>::last_quad () const
  {
    if (dim == 2)
      return last_quad (tria->n_levels()-1);
    else
      return last_quad (0);
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_quad_iterator
  DoFHandler<dim,spacedim>::last_active_quad (const unsigned int level) const
  {
				     // level is checked in last_raw
    quad_iterator i = last_quad(level);
    if (i->has_children()==false)
      return i;
    while ((--i).state() == IteratorState::valid)
      if (i->has_children()==false)
	return i;
    return i;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::active_quad_iterator
  DoFHandler<dim,spacedim>::last_active_quad () const
  {
    if (dim == 2)
      return last_active_quad (tria->n_levels()-1);
    else
      return last_active_quad (0);
  }


/*------------------------ Hex iterator functions ------------------------*/


  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::raw_hex_iterator
  DoFHandler<dim,spacedim>::begin_raw_hex (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	case 2:
	      Assert (false, ExcImpossibleInDim(1));
	      return raw_hex_iterator();
	case 3:
	{
	  Assert (level<tria->n_levels(), ExcInvalidLevel(level));

	  if (tria->n_raw_hexs(level) == 0)
	    return end_hex();
  
	  return raw_hex_iterator (tria,
				   level,
				   0,
				   this);
	}
      
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_hex_iterator();	    
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim,spacedim>::hex_iterator
  DoFHandler<dim,spacedim>::begin_hex (const unsigned int level) const
  {
				     // level is checked in begin_raw
    raw_hex_iterator ri = begin_raw_hex (level);
    if (ri.state() != IteratorState::valid)
      return ri;
    while (ri->used() == false)
      if ((++ri).state() != IteratorState::valid)
	return ri;
    return ri;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_hex_iterator
  DoFHandler<dim, spacedim>::begin_active_hex (const unsigned int level) const
  {
				     // level is checked in begin_raw
    hex_iterator i = begin_hex (level);
    if (i.state() != IteratorState::valid)
      return i;
    while (i->has_children())
      if ((++i).state() != IteratorState::valid)
	return i;
    return i;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_hex_iterator
  DoFHandler<dim, spacedim>::end_raw_hex (const unsigned int level) const
  {
    return (level == tria->n_levels()-1 ?
	    end_hex() :
	    begin_raw_hex (level+1));
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::hex_iterator
  DoFHandler<dim, spacedim>::end_hex (const unsigned int level) const
  {
    return (level == tria->n_levels()-1 ?
	    hex_iterator(end_hex()) :
	    begin_hex (level+1));
  }


  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_hex_iterator
  DoFHandler<dim, spacedim>::end_active_hex (const unsigned int level) const
  {
    return (level == tria->n_levels()-1 ?
	    active_hex_iterator(end_hex()) :
	    begin_active_hex (level+1));
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_hex_iterator
  DoFHandler<dim, spacedim>::end_hex () const
  {
    return raw_hex_iterator (tria,
			     -1,
			     -1,
			     this);
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_hex_iterator
  DoFHandler<dim, spacedim>::last_raw_hex (const unsigned int level) const
  {
    switch (dim)
      {
	case 1:
	case 2:
	      Assert (false, ExcImpossibleInDim(dim));
	      return raw_hex_iterator();

	case 3:
	      Assert (level<tria->n_levels(),
		      ExcInvalidLevel(level));
	      Assert (tria->n_raw_hexs(level) != 0,
		      ExcEmptyLevel (level));

	      return raw_hex_iterator (tria,
				       level,
				       tria->n_raw_hexs(level)-1,
				       this);
	default:
	      Assert (false, ExcNotImplemented());
	      return raw_hex_iterator();
      }
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::raw_hex_iterator
  DoFHandler<dim, spacedim>::last_raw_hex () const
  {
    return last_raw_hex (tria->n_levels()-1);
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::hex_iterator
  DoFHandler<dim, spacedim>::last_hex (const unsigned int level) const
  {
				     // level is checked in last_raw
    raw_hex_iterator ri = last_raw_hex(level);
    if (ri->used()==true)
      return ri;
    while ((--ri).state() == IteratorState::valid)
      if (ri->used()==true)
	return ri;
    return ri;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::hex_iterator
  DoFHandler<dim, spacedim>::last_hex () const
  {
    return last_hex (tria->n_levels()-1);
  }


 
  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_hex_iterator
  DoFHandler<dim, spacedim>::last_active_hex (const unsigned int level) const
  {
				     // level is checked in last_raw
    hex_iterator i = last_hex(level);
    if (i->has_children()==false)
      return i;
    while ((--i).state() == IteratorState::valid)
      if (i->has_children()==false)
	return i;
    return i;
  }



  template <int dim, int spacedim>
  typename DoFHandler<dim, spacedim>::active_hex_iterator
  DoFHandler<dim, spacedim>::last_active_hex () const
  {
    return last_active_hex (tria->n_levels()-1);
  }





//------------------------------------------------------------------


#if deal_II_dimension == 1

  template <>
  unsigned int DoFHandler<1>::n_boundary_dofs () const
  {
    Assert (finite_elements != 0, ExcNoFESelected());

    DoFHandler<1>::cell_iterator cell;
    unsigned int n = 0;
  
                                     // search left-most cell
    cell = this->begin_active();
    while (!cell->at_boundary(0))
      cell = cell->neighbor(0);
    n += cell->get_fe().dofs_per_vertex;
  
                                     // same with right-most cell
    cell = this->begin_active();
    while (!cell->at_boundary(1))
      cell = cell->neighbor(1);
    n += cell->get_fe().dofs_per_vertex;

    return n;
  }



  template <>
  unsigned int DoFHandler<1>::n_boundary_dofs (const FunctionMap &boundary_indicators) const
  {
    Assert (finite_elements != 0, ExcNoFESelected());

                                     // check that only boundary
                                     // indicators 0 and 1 are allowed
                                     // in 1d
    for (FunctionMap::const_iterator i=boundary_indicators.begin();
         i!=boundary_indicators.end(); ++i)
      Assert ((i->first == 0) || (i->first == 1),
              ExcInvalidBoundaryIndicator());
  
    DoFHandler<1>::active_cell_iterator cell;
    unsigned int n = 0;
  
                                     // search left-most cell
    if (boundary_indicators.find (0) != boundary_indicators.end())
      {
        cell = this->begin_active();
        while (!cell->at_boundary(0))
          cell = cell->neighbor(0);
        n += cell->get_fe().dofs_per_vertex;
      }
  
                                     // same with right-most cell
    if (boundary_indicators.find (1) != boundary_indicators.end())
      {
        cell = this->begin_active();
        while (!cell->at_boundary(1))
          cell = cell->neighbor(1);
        n += cell->get_fe().dofs_per_vertex;
      }
  
    return n;
  }



  template <>
  unsigned int DoFHandler<1>::n_boundary_dofs (const std::set<unsigned char> &boundary_indicators) const
  {
    Assert (finite_elements != 0, ExcNoFESelected());

                                     // check that only boundary
                                     // indicators 0 and 1 are allowed
                                     // in 1d
    for (std::set<unsigned char>::const_iterator i=boundary_indicators.begin();
         i!=boundary_indicators.end(); ++i)
      Assert ((*i == 0) || (*i == 1),
              ExcInvalidBoundaryIndicator());
  
    DoFHandler<1>::active_cell_iterator cell;
    unsigned int n = 0;
  
                                     // search left-most cell
    if (boundary_indicators.find (0) != boundary_indicators.end())
      {
        cell = this->begin_active();
        while (!cell->at_boundary(0))
          cell = cell->neighbor(0);
        n += cell->get_fe().dofs_per_vertex;
      }
  
                                     // same with right-most cell
    if (boundary_indicators.find (1) != boundary_indicators.end())
      {
        cell = this->begin_active();
        while (!cell->at_boundary(1))
          cell = cell->neighbor(1);
        n += cell->get_fe().dofs_per_vertex;
      }
  
    return n;
  }


  template <>
  unsigned int DoFHandler<1,2>::n_boundary_dofs () const
  {
    Assert(false,ExcNotImplemented());
    return 0;
  }

  template <>
  unsigned int DoFHandler<1,2>::n_boundary_dofs (const FunctionMap &) const
  {
    Assert(false,ExcNotImplemented());
    return 0;
  }

  template <>
  unsigned int DoFHandler<1,2>::n_boundary_dofs (const std::set<unsigned char> &) const
  {
    Assert(false,ExcNotImplemented());
    return 0;
  }



#endif


  template<int dim, int spacedim>
  unsigned int DoFHandler<dim,spacedim>::n_boundary_dofs () const
  {
    Assert (finite_elements != 0, ExcNoFESelected());

    std::set<int> boundary_dofs;
    std::vector<unsigned int> dofs_on_face;
    dofs_on_face.reserve (this->get_fe ().max_dofs_per_face());

                                     // loop over all faces to check
                                     // whether they are at a
                                     // boundary. note that we need not
                                     // take special care of single
                                     // lines in 3d (using
                                     // @p{cell->has_boundary_lines}),
                                     // since we do not support
                                     // boundaries of dimension dim-2,
                                     // and so every boundary line is
                                     // also part of a boundary face.
    typename DoFHandler<dim,spacedim>::active_cell_iterator cell = this->begin_active (),
                                                   endc = this->end();
    for (; cell!=endc; ++cell)
      for (unsigned int f=0; f<GeometryInfo<dim>::faces_per_cell; ++f)
        if (cell->at_boundary(f))
          {
            const unsigned int dofs_per_face = cell->get_fe().dofs_per_face;
            dofs_on_face.resize (dofs_per_face);
          
            cell->face(f)->get_dof_indices (dofs_on_face,
					    cell->active_fe_index());
            for (unsigned int i=0; i<dofs_per_face; ++i)
              boundary_dofs.insert(dofs_on_face[i]);
          };
    return boundary_dofs.size();  
  }



  template<int dim, int spacedim>
  unsigned int
  DoFHandler<dim,spacedim>::n_boundary_dofs (const FunctionMap &boundary_indicators) const
  {
    Assert (finite_elements != 0, ExcNoFESelected());
    Assert (boundary_indicators.find(255) == boundary_indicators.end(),
            ExcInvalidBoundaryIndicator());
  
                                     // same as above, but with
                                     // additional checks for set of
                                     // boundary indicators
    std::set<int> boundary_dofs;
    std::vector<unsigned int> dofs_on_face;
    dofs_on_face.reserve (this->get_fe ().max_dofs_per_face());

    typename DoFHandler<dim,spacedim>::active_cell_iterator cell = this->begin_active (),
                                                   endc = this->end();
    for (; cell!=endc; ++cell)
      for (unsigned int f=0; f<GeometryInfo<dim>::faces_per_cell; ++f)
        if (cell->at_boundary(f) &&
            (boundary_indicators.find(cell->face(f)->boundary_indicator()) !=
             boundary_indicators.end()))
          {
            const unsigned int dofs_per_face = cell->get_fe().dofs_per_face;
            dofs_on_face.resize (dofs_per_face);
          
            cell->face(f)->get_dof_indices (dofs_on_face,
					    cell->active_fe_index());
            for (unsigned int i=0; i<dofs_per_face; ++i)
              boundary_dofs.insert(dofs_on_face[i]);
          }
    return boundary_dofs.size();
  }



  template<int dim, int spacedim>
  unsigned int
  DoFHandler<dim,spacedim>::n_boundary_dofs (const std::set<unsigned char> &boundary_indicators) const
  {
    Assert (finite_elements != 0, ExcNoFESelected());
    Assert (boundary_indicators.find (255) == boundary_indicators.end(),
            ExcInvalidBoundaryIndicator());

                                     // same as above, but with
                                     // additional checks for set of
                                     // boundary indicators
    std::set<int> boundary_dofs;
    std::vector<unsigned int> dofs_on_face;
    dofs_on_face.reserve (this->get_fe ().max_dofs_per_face());

    typename DoFHandler<dim,spacedim>::active_cell_iterator cell = this->begin_active (),
                                                   endc = this->end();
    for (; cell!=endc; ++cell)
      for (unsigned int f=0; f<GeometryInfo<dim>::faces_per_cell; ++f)
        if (cell->at_boundary(f) &&
            (boundary_indicators.find(cell->face(f)->boundary_indicator()) !=
             boundary_indicators.end()))
          {
            const unsigned int dofs_per_face = cell->get_fe().dofs_per_face;
            dofs_on_face.resize (dofs_per_face);
          
            cell->face(f)->get_dof_indices (dofs_on_face);
            for (unsigned int i=0; i<dofs_per_face; ++i)
              boundary_dofs.insert(dofs_on_face[i]);
          };
    return boundary_dofs.size();
  }


#if deal_II_dimension == 2  
  
  template <>
  unsigned int DoFHandler<2,3>::n_boundary_dofs () const
  {
    Assert(false,ExcNotImplemented());
    return 0;
  }

  template <>
  unsigned int DoFHandler<2,3>::n_boundary_dofs (const FunctionMap &) const
  {
    Assert(false,ExcNotImplemented());
    return 0;
  }

  template <>
  unsigned int DoFHandler<2,3>::n_boundary_dofs (const std::set<unsigned char> &) const
  {
    Assert(false,ExcNotImplemented());
    return 0;
  }

#endif



  template<int dim, int spacedim>
  unsigned int
  DoFHandler<dim,spacedim>::memory_consumption () const
  {
    unsigned int mem = (MemoryConsumption::memory_consumption (tria) +
                        MemoryConsumption::memory_consumption (finite_elements) +
                        MemoryConsumption::memory_consumption (tria) +
                        MemoryConsumption::memory_consumption (levels) +
                        MemoryConsumption::memory_consumption (*faces) +
                        MemoryConsumption::memory_consumption (used_dofs) +
                        MemoryConsumption::memory_consumption (vertex_dofs) +
                        MemoryConsumption::memory_consumption (vertex_dofs_offsets) +
                        MemoryConsumption::memory_consumption (has_children));
    for (unsigned int i=0; i<levels.size(); ++i)
      mem += MemoryConsumption::memory_consumption (*levels[i]);
    mem += MemoryConsumption::memory_consumption (*faces);
  
    return mem;
  }



  template<int dim, int spacedim>
  void
  DoFHandler<dim,spacedim>::
  compute_vertex_dof_identities (std::vector<unsigned int> &new_dof_indices) const
  {
                                     // Note: we may wish to have
                                     // something here similar to what
                                     // we do for lines and quads,
                                     // namely that we only identify
                                     // dofs for any fe towards the
                                     // most dominating one. however,
                                     // it is not clear whether this
                                     // is actually necessary for
                                     // vertices at all, I can't think
                                     // of a finite element that would
                                     // make that necessary...
    Table<2,std_cxx1x::shared_ptr<internal::hp::DoFIdentities> >
      vertex_dof_identities (get_fe().size(),
			     get_fe().size());

				     // loop over all vertices and
				     // see which one we need to
				     // work on
    for (unsigned int vertex_index=0; vertex_index<get_tria().n_vertices();
	 ++vertex_index)
      {
	const unsigned int n_active_fe_indices
	  = internal::DoFAccessor::Implementation::
	  n_active_vertex_fe_indices (*this, vertex_index);
	if (n_active_fe_indices > 1)
	  {
	    const unsigned int
	      first_fe_index
	      = internal::DoFAccessor::Implementation::
	      nth_active_vertex_fe_index (*this, vertex_index, 0);

					     // loop over all the
					     // other FEs with which
					     // we want to identify
					     // the DoF indices of
					     // the first FE of
	    for (unsigned int f=1; f<n_active_fe_indices; ++f)
	      {
		const unsigned int
		  other_fe_index
		  = internal::DoFAccessor::Implementation::
		  nth_active_vertex_fe_index (*this, vertex_index, f);

						 // make sure the
						 // entry in the
						 // equivalence
						 // table exists
		internal::hp::ensure_existence_of_dof_identities<0>
		  (get_fe()[first_fe_index],
		   get_fe()[other_fe_index],
		   vertex_dof_identities[first_fe_index][other_fe_index]);

						 // then loop
						 // through the
						 // identities we
						 // have. first get
						 // the global
						 // numbers of the
						 // dofs we want to
						 // identify and
						 // make sure they
						 // are not yet
						 // constrained to
						 // anything else,
						 // except for to
						 // each other. use
						 // the rule that we
						 // will always
						 // constrain the
						 // dof with the
						 // higher fe
						 // index to the
						 // one with the
						 // lower, to avoid
						 // circular
						 // reasoning.
		internal::hp::DoFIdentities &identities
		  = *vertex_dof_identities[first_fe_index][other_fe_index];
		for (unsigned int i=0; i<identities.size(); ++i)
		  {
		    const unsigned int lower_dof_index
		      = internal::DoFAccessor::Implementation::
		      get_vertex_dof_index (*this,
					    vertex_index,
					    first_fe_index,
					    identities[i].first);
		    const unsigned int higher_dof_index
		      = internal::DoFAccessor::Implementation::
		      get_vertex_dof_index (*this,
					    vertex_index,
					    other_fe_index,
					    identities[i].second);

		    Assert ((new_dof_indices[higher_dof_index] ==
			     numbers::invalid_unsigned_int)
			    ||
			    (new_dof_indices[higher_dof_index] ==
			     lower_dof_index),
			    ExcInternalError());
		      
		    new_dof_indices[higher_dof_index] = lower_dof_index;
		  }
	      }
	  }
      }
  }


#if deal_II_dimension == 1

  template <>
  void
  DoFHandler<1,1>::
  compute_line_dof_identities (std::vector<unsigned int> &) const
  {}

  template <>
  void
  DoFHandler<1,2>::
  compute_line_dof_identities (std::vector<unsigned int> &) const
  {}

#endif

  template<int dim, int spacedim>
  void
  DoFHandler<dim,spacedim>::
  compute_line_dof_identities (std::vector<unsigned int> &new_dof_indices) const
  {
                                     // An implementation of the
                                     // algorithm described in the hp
                                     // paper, including the
                                     // modification mentioned later
                                     // in the "complications in 3-d"
                                     // subsections
                                     //
                                     // as explained there, we do
                                     // something only if there are
                                     // exactly 2 finite elements
                                     // associated with an object. if
                                     // there is only one, then there
                                     // is nothing to do anyway, and
                                     // if there are 3 or more, then
                                     // we can get into trouble. note
                                     // that this only happens for
                                     // lines in 3d and higher, and
                                     // for quads only in 4d and
                                     // higher, so this isn't a
                                     // particularly frequent case
				     //
				     // there is one case, however, that we
				     // would like to handle (see, for
				     // example, the hp/crash_15 testcase): if
				     // we have FESystem(FE_Q(2),FE_DGQ(i))
				     // elements for a bunch of values 'i',
				     // then we should be able to handle this
				     // because we can simply unify *all*
				     // dofs, not only a some. so what we do
				     // is to first treat all pairs of finite
				     // elements that have *identical* dofs,
				     // and then only deal with those that are
				     // not identical of which we can handle
				     // at most 2
    Table<2,std_cxx1x::shared_ptr<internal::hp::DoFIdentities> >
      line_dof_identities (finite_elements->size(),
			   finite_elements->size());
	
    for (line_iterator line=begin_line(); line!=end_line(); ++line)
      {
	unsigned int unique_sets_of_dofs
	  = line->n_active_fe_indices();

					 // do a first loop over all sets of
					 // dofs and do identity
					 // uniquification
	for (unsigned int f=0; f<line->n_active_fe_indices(); ++f)
	  for (unsigned int g=f+1; g<line->n_active_fe_indices(); ++g)
	    {
	      const unsigned int fe_index_1 = line->nth_active_fe_index (f),
				 fe_index_2 = line->nth_active_fe_index (g);
	      
	      if (((*finite_elements)[fe_index_1].dofs_per_line
		   ==
		   (*finite_elements)[fe_index_2].dofs_per_line)
		  &&
		  ((*finite_elements)[fe_index_1].dofs_per_line > 0))
		{
		  internal::hp::ensure_existence_of_dof_identities<1>
		    ((*finite_elements)[fe_index_1],
		     (*finite_elements)[fe_index_2],
		     line_dof_identities[fe_index_1][fe_index_2]);
						   // see if these sets of dofs
						   // are identical. the first
						   // condition for this is that
						   // indeed there are n
						   // identities
		  if (line_dof_identities[fe_index_1][fe_index_2]->size()
		      == 
		      (*finite_elements)[fe_index_1].dofs_per_line)
		    {
		      unsigned int i=0;
		      for (; i<(*finite_elements)[fe_index_1].dofs_per_line; ++i)
			if (((*(line_dof_identities[fe_index_1][fe_index_2]))[i].first != i)
			    &&
			    ((*(line_dof_identities[fe_index_1][fe_index_2]))[i].second != i))
							   // not an identity
			  break;

		      if (i == (*finite_elements)[fe_index_1].dofs_per_line)
			{
							   // the dofs of these
							   // two finite
							   // elements are
							   // identical. as a
							   // safety check,
							   // ensure that none
							   // of the two FEs is
							   // trying to dominate
							   // the other, which
							   // wouldn't make any
							   // sense in this case
			  Assert ((*finite_elements)[fe_index_1].compare_for_face_domination
				  ((*finite_elements)[fe_index_2])
				  ==
				  FiniteElementDomination::either_element_can_dominate,
				  ExcInternalError());
			
			  --unique_sets_of_dofs;

			  for (unsigned int j=0; j<(*finite_elements)[fe_index_1].dofs_per_line; ++j)
			    {
			      const unsigned int master_dof_index
				= line->dof_index (j, fe_index_1);
			      const unsigned int slave_dof_index
				= line->dof_index (j, fe_index_2);

							       // if master dof
							       // was already
							       // constrained,
							       // constrain to
							       // that one,
							       // otherwise
							       // constrain
							       // slave to
							       // master
			      if (new_dof_indices[master_dof_index] !=
				  numbers::invalid_unsigned_int)
				{
				  Assert (new_dof_indices[new_dof_indices[master_dof_index]] ==
					  numbers::invalid_unsigned_int,
					  ExcInternalError());
				
				  new_dof_indices[slave_dof_index]
				    = new_dof_indices[master_dof_index];
				}
			      else
				{
				  Assert ((new_dof_indices[master_dof_index] ==
					   numbers::invalid_unsigned_int)
					  ||
					  (new_dof_indices[slave_dof_index] ==
					   master_dof_index),
					  ExcInternalError());
				
				  new_dof_indices[slave_dof_index] = master_dof_index;
				}
			    } 
			}
		    }
		}
	    }
	
					 // if at this point, there is only
					 // one unique set of dofs left, then
					 // we have taken care of everything
					 // above. if there are two, then we
					 // need to deal with them here. if
					 // there are more, then we punt, as
					 // described in the paper (and
					 // mentioned above)
//TODO: The check for 'dim==2' was inserted by intuition. It fixes
// the previous problems with step-27 in 3D. But an explanation
// for this is still required, and what we do here is not what we
// describe in the paper!.
	if ((unique_sets_of_dofs == 2) && (dim == 2))
	  {
					     // find out which is the
					     // most dominating finite
					     // element of the ones that
					     // are used on this line
	    const unsigned int most_dominating_fe_index
	      = internal::hp::get_most_dominating_fe_index<dim,spacedim> (line);

	    const unsigned int n_active_fe_indices
	      = line->n_active_fe_indices ();

					     // loop over the indices of
					     // all the finite elements
					     // that are not dominating,
					     // and identify their dofs
					     // to the most dominating
					     // one
	    for (unsigned int f=0; f<n_active_fe_indices; ++f)
	      if (line->nth_active_fe_index (f) !=
		  most_dominating_fe_index)
		{
		  const unsigned int
		    other_fe_index = line->nth_active_fe_index (f);

		  internal::hp::ensure_existence_of_dof_identities<1>
		    ((*finite_elements)[most_dominating_fe_index],
		     (*finite_elements)[other_fe_index],
		     line_dof_identities[most_dominating_fe_index][other_fe_index]);

		  internal::hp::DoFIdentities &identities
		    = *line_dof_identities[most_dominating_fe_index][other_fe_index];
		  for (unsigned int i=0; i<identities.size(); ++i)
		    {
		      const unsigned int master_dof_index
			= line->dof_index (identities[i].first, most_dominating_fe_index);
		      const unsigned int slave_dof_index
			= line->dof_index (identities[i].second, other_fe_index);

		      Assert ((new_dof_indices[master_dof_index] ==
			       numbers::invalid_unsigned_int)
			      ||
			      (new_dof_indices[slave_dof_index] ==
			       master_dof_index),
			      ExcInternalError());
		      
		      new_dof_indices[slave_dof_index] = master_dof_index;
		    }
		}
	  }
      }
  }

#if deal_II_dimension == 1

  template <>
  void
  DoFHandler<1>::
  compute_quad_dof_identities (std::vector<unsigned int> &) const
  {}

  template <>
  void
  DoFHandler<1,2>::
  compute_quad_dof_identities (std::vector<unsigned int> &) const
  {}

#endif


#if deal_II_dimension == 2

  template <>
  void
  DoFHandler<2>::
  compute_quad_dof_identities (std::vector<unsigned int> &) const
  {}


  template <>
  void
  DoFHandler<2,3>::
  compute_quad_dof_identities (std::vector<unsigned int> &) const
  {}


#endif

  
  template<int dim, int spacedim>
  void
  DoFHandler<dim,spacedim>::
  compute_quad_dof_identities (std::vector<unsigned int> &new_dof_indices) const
  {
                                     // An implementation of the
                                     // algorithm described in the hp
                                     // paper, including the
                                     // modification mentioned later
                                     // in the "complications in 3-d"
                                     // subsections
                                     //
                                     // as explained there, we do
                                     // something only if there are
                                     // exactly 2 finite elements
                                     // associated with an object. if
                                     // there is only one, then there
                                     // is nothing to do anyway, and
                                     // if there are 3 or more, then
                                     // we can get into trouble. note
                                     // that this only happens for
                                     // lines in 3d and higher, and
                                     // for quads only in 4d and
                                     // higher, so this isn't a
                                     // particularly frequent case
    Table<2,std_cxx1x::shared_ptr<internal::hp::DoFIdentities> >
      quad_dof_identities (finite_elements->size(),
			   finite_elements->size());
	
    for (quad_iterator quad=begin_quad(); quad!=end_quad(); ++quad)
      if (quad->n_active_fe_indices() == 2)
	{
                                           // find out which is the
                                           // most dominating finite
                                           // element of the ones that
                                           // are used on this quad
          const unsigned int most_dominating_fe_index
            = internal::hp::get_most_dominating_fe_index<dim,spacedim> (quad);

	  const unsigned int n_active_fe_indices
	    = quad->n_active_fe_indices ();

                                           // loop over the indices of
                                           // all the finite elements
                                           // that are not dominating,
                                           // and identify their dofs
                                           // to the most dominating
                                           // one
          for (unsigned int f=0; f<n_active_fe_indices; ++f)
            if (quad->nth_active_fe_index (f) !=
                most_dominating_fe_index)
              {
                const unsigned int
                  other_fe_index = quad->nth_active_fe_index (f);

                internal::hp::ensure_existence_of_dof_identities<2>
                  ((*finite_elements)[most_dominating_fe_index],
                   (*finite_elements)[other_fe_index],
                   quad_dof_identities[most_dominating_fe_index][other_fe_index]);

                internal::hp::DoFIdentities &identities
                  = *quad_dof_identities[most_dominating_fe_index][other_fe_index];
                for (unsigned int i=0; i<identities.size(); ++i)
                  {
                    const unsigned int master_dof_index
                      = quad->dof_index (identities[i].first, most_dominating_fe_index);
                    const unsigned int slave_dof_index
                      = quad->dof_index (identities[i].second, other_fe_index);

                    Assert ((new_dof_indices[master_dof_index] ==
                             numbers::invalid_unsigned_int)
                            ||
                            (new_dof_indices[slave_dof_index] ==
                             master_dof_index),
                            ExcInternalError());
		      
                    new_dof_indices[slave_dof_index] = master_dof_index;
		}
	    }
	}
  }
  
  

  
  template<int dim, int spacedim>
  void DoFHandler<dim,spacedim>::distribute_dofs (const hp::FECollection<dim,spacedim> &ff)
  {
    Assert (tria->n_levels() > 0, ExcInvalidTriangulation());

    finite_elements = &ff;

                                     // This call ensures that the
                                     // active_fe_indices vectors are
                                     // initialized correctly.
    create_active_fe_table ();

				     // up front make sure that the fe
				     // collection is large enough to
				     // cover all fe indices presently
				     // in use on the mesh
    for (active_cell_iterator cell = begin_active(); cell != end(); ++cell) 
      Assert (cell->active_fe_index() < finite_elements->size(),
	      ExcInvalidFEIndex (cell->active_fe_index(),
				 finite_elements->size()));


                                     // then allocate space for all
                                     // the other tables
    internal::hp::DoFHandler::Implementation::reserve_space (*this);

                                     // Clear user flags because we will
                                     // need them. But first we save
                                     // them and make sure that we
                                     // restore them later such that at
                                     // the end of this function the
                                     // Triangulation will be in the
                                     // same state as it was at the
                                     // beginning of this function.
    std::vector<bool> user_flags;
    tria->save_user_flags(user_flags);
    const_cast<Triangulation<dim,spacedim> &>(*tria).clear_user_flags ();


				     /////////////////////////////////

				     // Step 1: distribute DoFs on all
				     // active entities
    {
      unsigned int next_free_dof = 0;
      active_cell_iterator cell = begin_active(),
			   endc = end();

      for (; cell != endc; ++cell) 
	next_free_dof
	  = internal::hp::DoFHandler::Implementation::template distribute_dofs_on_cell<spacedim> (cell,
							       next_free_dof);

      used_dofs = next_free_dof;
    }
    

				     /////////////////////////////////
    
				     // Step 2: identify certain dofs
				     // if the finite element tells us
				     // that they should have the same
				     // value. only pertinent for
				     // faces and other
				     // lower-dimensional objects
				     // where elements come together
    std::vector<unsigned int>
      constrained_indices (used_dofs, numbers::invalid_unsigned_int);
    compute_vertex_dof_identities (constrained_indices);
    compute_line_dof_identities (constrained_indices);
    compute_quad_dof_identities (constrained_indices);

				     // loop over all dofs and assign
				     // new numbers to those which are
				     // not constrained
    std::vector<unsigned int>
      new_dof_indices (used_dofs, numbers::invalid_unsigned_int);
    unsigned int next_free_dof = 0;
    for (unsigned int i=0; i<used_dofs; ++i)
      if (constrained_indices[i] == numbers::invalid_unsigned_int)
	{
	  new_dof_indices[i] = next_free_dof;
	  ++next_free_dof;
	}
    
				     // then loop over all those that
				     // are constrained and record the
				     // new dof number for those:
    for (unsigned int i=0; i<used_dofs; ++i)
      if (constrained_indices[i] != numbers::invalid_unsigned_int)
	{
	  Assert (new_dof_indices[constrained_indices[i]] !=
		  numbers::invalid_unsigned_int,
		  ExcInternalError());
	  
	  new_dof_indices[i] = new_dof_indices[constrained_indices[i]];
	}

    for (unsigned int i=0; i<used_dofs; ++i)
      {
	Assert (new_dof_indices[i] != numbers::invalid_unsigned_int,
		ExcInternalError());
	Assert (new_dof_indices[i] < next_free_dof,
		ExcInternalError());
      }
    
				     // finally, do the renumbering
				     // and set the number of actually
				     // used dof indices
    renumber_dofs_internal (new_dof_indices, internal::int2type<dim>());

    used_dofs = next_free_dof;
    
    
                                     // finally restore the user flags
    const_cast<Triangulation<dim,spacedim> &>(*tria).load_user_flags(user_flags);
  }



  template<int dim, int spacedim>
  void DoFHandler<dim,spacedim>::clear ()
  {
                                     // release lock to old fe
    finite_elements = 0;

                                     // release memory
    clear_space ();
  }



  template<int dim, int spacedim>
  void DoFHandler<dim,spacedim>::renumber_dofs (const std::vector<unsigned int> &new_numbers)
  {
    Assert (new_numbers.size() == n_dofs(), ExcRenumberingIncomplete());
#ifdef DEBUG
                                     // assert that the new indices are
                                     // consecutively numbered
    if (true)
      {
        std::vector<unsigned int> tmp(new_numbers);
        std::sort (tmp.begin(), tmp.end());
        std::vector<unsigned int>::const_iterator p = tmp.begin();
        unsigned int                         i = 0;
        for (; p!=tmp.end(); ++p, ++i)
          Assert (*p == i, ExcNewNumbersNotConsecutive(i));
      }
#endif

    renumber_dofs_internal (new_numbers, internal::int2type<dim>());
  }



  template<int dim, int spacedim>
  void
  DoFHandler<dim,spacedim>::
  renumber_dofs_internal (const std::vector<unsigned int> &new_numbers,
			  internal::int2type<0>)
  {
    Assert (new_numbers.size() == n_dofs(), ExcRenumberingIncomplete());

    for (unsigned int vertex_index=0; vertex_index<get_tria().n_vertices();
	 ++vertex_index)
      {
	const unsigned int n_active_fe_indices
	  = internal::DoFAccessor::Implementation::
	  n_active_vertex_fe_indices (*this, vertex_index);

	for (unsigned int f=0; f<n_active_fe_indices; ++f)
	  {
	    const unsigned int fe_index
	      = internal::DoFAccessor::Implementation::
	      nth_active_vertex_fe_index (*this, vertex_index, f);

	    for (unsigned int d=0; d<(*finite_elements)[fe_index].dofs_per_vertex; ++d)
	      {
		const unsigned int vertex_dof_index
		  = internal::DoFAccessor::Implementation::
		  get_vertex_dof_index(*this,
				       vertex_index,
				       fe_index,
				       d);
		internal::DoFAccessor::Implementation::
		  set_vertex_dof_index (*this,
					vertex_index,
					fe_index,
					d,
					new_numbers[vertex_dof_index]);
	      }
	  }
      }
  }



  template<int dim, int spacedim>
  void
  DoFHandler<dim,spacedim>::
  renumber_dofs_internal (const std::vector<unsigned int> &new_numbers,
			  internal::int2type<1>)
  {
    Assert (new_numbers.size() == n_dofs(), ExcRenumberingIncomplete());

    renumber_dofs_internal (new_numbers, internal::int2type<0>());
    
    for (line_iterator line=begin_line(); line!=end_line(); ++line)
      {
	const unsigned int n_active_fe_indices
	  = line->n_active_fe_indices ();

	for (unsigned int f=0; f<n_active_fe_indices; ++f)
	  {
	    const unsigned int fe_index
	      = line->nth_active_fe_index (f);

	    for (unsigned int d=0; d<(*finite_elements)[fe_index].dofs_per_line; ++d)
	      line->set_dof_index (d,
				   new_numbers[line->dof_index(d,fe_index)],
				   fe_index);
	  }
      }
  }


#if deal_II_dimension >= 2

  template<int dim, int spacedim>
  void
  DoFHandler<dim,spacedim>::
  renumber_dofs_internal (const std::vector<unsigned int> &new_numbers,
			  internal::int2type<2>)
  {
    Assert (new_numbers.size() == n_dofs(), ExcRenumberingIncomplete());

    renumber_dofs_internal (new_numbers, internal::int2type<1>());
    
    for (quad_iterator quad=begin_quad(); quad!=end_quad(); ++quad)
      {
	const unsigned int n_active_fe_indices
	  = quad->n_active_fe_indices ();

	for (unsigned int f=0; f<n_active_fe_indices; ++f)
	  {
	    const unsigned int fe_index
	      = quad->nth_active_fe_index (f);

	    for (unsigned int d=0; d<(*finite_elements)[fe_index].dofs_per_quad; ++d)
	      quad->set_dof_index (d,
				   new_numbers[quad->dof_index(d,fe_index)],
				   fe_index);
	  }
      }
  }

#endif

#if deal_II_dimension >= 3

  template<int dim, int spacedim>
  void
  DoFHandler<dim,spacedim>::
  renumber_dofs_internal (const std::vector<unsigned int> &new_numbers,
			  internal::int2type<3>)
  {
    Assert (new_numbers.size() == n_dofs(), ExcRenumberingIncomplete());

    renumber_dofs_internal (new_numbers, internal::int2type<2>());
    
    for (hex_iterator hex=begin_hex(); hex!=end_hex(); ++hex)
      {
	const unsigned int n_active_fe_indices
	  = hex->n_active_fe_indices ();

	for (unsigned int f=0; f<n_active_fe_indices; ++f)
	  {
	    const unsigned int fe_index
	      = hex->nth_active_fe_index (f);

	    for (unsigned int d=0; d<(*finite_elements)[fe_index].dofs_per_hex; ++d)
	      hex->set_dof_index (d,
				  new_numbers[hex->dof_index(d,fe_index)],
				  fe_index);
	  }
      }
  }

#endif


  template <int dim, int spacedim>
  unsigned int
  DoFHandler<dim, spacedim>::max_couplings_between_dofs () const
  {
    Assert (finite_elements != 0, ExcNoFESelected());
    return internal::hp::DoFHandler::Implementation::max_couplings_between_dofs (*this);
  }



  template <int dim, int spacedim>
  unsigned int
  DoFHandler<dim,spacedim>::max_couplings_between_boundary_dofs () const
  {
    Assert (finite_elements != 0, ExcNoFESelected());

    switch (dim)
      {
	case 1:
	      return finite_elements->max_dofs_per_vertex();
	case 2:
	      return (3*finite_elements->max_dofs_per_vertex()
		      +
		      2*finite_elements->max_dofs_per_line());
	case 3:
					       // we need to take refinement of
					       // one boundary face into consideration
					       // here; in fact, this function returns
					       // what #max_coupling_between_dofs<2>
					       // returns
					       //
					       // we assume here, that only four faces
					       // meet at the boundary; this assumption
					       // is not justified and needs to be
					       // fixed some time. fortunately, ommitting
					       // it for now does no harm since the
					       // matrix will cry foul if its requirements
					       // are not satisfied
	      return (19*finite_elements->max_dofs_per_vertex() +
		      28*finite_elements->max_dofs_per_line() +
		      8*finite_elements->max_dofs_per_quad());
	default:
	      Assert (false, ExcNotImplemented());
	      return 0;
      }
  }


  
  template<int dim, int spacedim>
  void DoFHandler<dim,spacedim>::create_active_fe_table ()
  {
                                     // Create sufficiently many
                                     // hp::DoFLevels.
    while (levels.size () < tria->n_levels ())
      levels.push_back (new internal::hp::DoFLevel<dim>);

                                     // then make sure that on each
                                     // level we have the appropriate
                                     // size of active_fe_indices;
                                     // preset them to zero, i.e. the
                                     // default FE
    for (unsigned int level=0; level<levels.size(); ++level)
      {
        if (levels[level]->active_fe_indices.size () == 0)
          levels[level]->active_fe_indices.resize (tria->n_raw_cells(level),
                                                   0);
        else
          {
                                             // Either the
                                             // active_fe_indices have
                                             // size zero because they
                                             // were just created, or
                                             // the correct
                                             // size. Other sizes
                                             // indicate that
                                             // something went wrong.
            Assert (levels[level]->active_fe_indices.size () ==
                    tria->n_raw_cells(level),
                    ExcInternalError ());
          }
      }
  }


  template <int dim, int spacedim>
  void DoFHandler<dim,spacedim>::pre_refinement_notification (const Triangulation<dim,spacedim> &tria)
  {
    create_active_fe_table ();

                                     // Remember if the cells have already
                                     // children. That will make the transfer
                                     // of the active_fe_index to the finer
                                     // levels easier.
    Assert (has_children.size () == 0, ExcInternalError ());
    for (unsigned int i=0; i<levels.size(); ++i)
      {
	const unsigned int cells_on_level = tria.n_raw_cells(i);
	std::vector<bool> *has_children_level =
          new std::vector<bool> (cells_on_level);

                                         // Check for each cell, if it has children.
	std::transform (tria.levels[i]->cells.refinement_cases.begin (),
			tria.levels[i]->cells.refinement_cases.end (),
			has_children_level->begin (),
			std::bind2nd (std::not_equal_to<unsigned char>(),
				      static_cast<unsigned char>(RefinementCase<dim>::no_refinement)));

	has_children.push_back (has_children_level);
      }
  }



#if deal_II_dimension == 1
  template <>
  void DoFHandler<1>::pre_refinement_notification (const Triangulation<1> &tria)
  {
    create_active_fe_table ();

                                     // Remember if the cells have already
                                     // children. That will make the transfer
                                     // of the active_fe_index to the finer
                                     // levels easier.
    Assert (has_children.size () == 0, ExcInternalError ());
    for (unsigned int i=0; i<levels.size(); ++i)
      {
	const unsigned int cells_on_level = tria.n_raw_cells (i);
	std::vector<bool> *has_children_level =
          new std::vector<bool> (cells_on_level);

                                         // Check for each cell, if it has
                                         // children. here we cannot use
                                         // refinement_cases, since it is unused in
                                         // 1d (as there is only one choice
                                         // anyway). use the 'children' vector
                                         // instead
	std::transform (tria.levels[i]->cells.children.begin (),
			tria.levels[i]->cells.children.end (),
			has_children_level->begin (),
			std::bind2nd (std::not_equal_to<int>(), -1));

	has_children.push_back (has_children_level);
      }
  }



  template <>
  void DoFHandler<1,2>::pre_refinement_notification (const Triangulation<1,2> &tria)
  {
    create_active_fe_table ();

                                     // Remember if the cells have already
                                     // children. That will make the transfer
                                     // of the active_fe_index to the finer
                                     // levels easier.
    Assert (has_children.size () == 0, ExcInternalError ());
    for (unsigned int i=0; i<levels.size(); ++i)
      {
	const unsigned int lines_on_level = tria.n_raw_lines(i);
	std::vector<bool> *has_children_level =
          new std::vector<bool> (lines_on_level);

                                         // Check for each cell, if it has children.
	std::transform (tria.levels[i]->cells.children.begin (),
			tria.levels[i]->cells.children.end (),
			has_children_level->begin (),
			std::bind2nd (std::not_equal_to<int>(), -1));

	has_children.push_back (has_children_level);
      }
  }
#endif


  template<int dim, int spacedim>
  void DoFHandler<dim,spacedim>::post_refinement_notification (const Triangulation<dim,spacedim> &tria)
  {
    Assert (has_children.size () == levels.size (), ExcInternalError ());

                                     // In each refinement at most one new
                                     // new level may appear. If that happened
                                     // it is appended to the DoFHandler
                                     // levels.
    if (levels.size () < tria.n_levels ())
      levels.push_back (new internal::hp::DoFLevel<dim>);

                                     // Coarsening can lead to the loss
                                     // of levels. Hence remove them.
    while (levels.size () > tria.n_levels ())
      { 
	delete levels[levels.size ()-1];
	levels.pop_back ();
      }

                                     // Resize active_fe_indices
                                     // vectors. use zero indicator to
                                     // extend
    for (unsigned int i=0; i<levels.size(); ++i)
      levels[i]->active_fe_indices.resize (tria.n_raw_cells(i), 0);

                                     // if a finite element collection
                                     // has already been set, then
                                     // actually try to set
                                     // active_fe_indices for child
                                     // cells of refined cells to the
                                     // active_fe_index of the mother
                                     // cell. if no finite element
                                     // collection has been assigned
                                     // yet, then all indicators are
                                     // zero anyway, and there is no
                                     // point trying to set anything
                                     // (besides, we would trip over
                                     // an assertion in
                                     // set_active_fe_index)
    if (finite_elements != 0)
      {
        cell_iterator cell = begin(),
                      endc = end ();
        for (; cell != endc; ++cell)
          {
                                             // Look if the cell got children during
                                             // refinement
                                             // Note: Although one level is added to
                                             // the DoFHandler levels, when the
                                             // triangulation got one, for the buffer
                                             // has_children this new level is not
                                             // required, because the cells on the
                                             // finest level never have children. Hence
                                             // cell->has_children () will always return
                                             // false on that level, which would cause
                                             // shortcut evaluation of the following
                                             // expression. Thus an index error in
                                             // has_children should never occur.
            if (cell->has_children () &&
                !(*has_children [cell->level ()])[cell->index ()])
              {
                                                 // Set active_fe_index in children to the
                                                 // same value as in the parent cell.
                for (unsigned int i = 0; i < cell->n_children(); ++i)
                  cell->child (i)->set_active_fe_index (cell->active_fe_index ());
              }
          }
      }
    
                                     // Free buffer objects
    std::vector<std::vector<bool> *>::iterator children_level;
    for (children_level = has_children.begin ();
	 children_level != has_children.end ();
	 ++children_level)
      delete (*children_level);
                                     /*
                                       for_each (has_children.begin (),
                                       has_children.end (),
                                       delete());
                                     */
    has_children.clear ();
  }


  template<int dim, int spacedim>
  void DoFHandler<dim,spacedim>::clear_space ()
  {  
    for (unsigned int i=0; i<levels.size(); ++i)
      delete levels[i];
    levels.resize (0);
    delete faces;
    faces = NULL;

    {
      std::vector<unsigned int> tmp;
      std::swap (vertex_dofs, tmp);
    }
    
    {
      std::vector<unsigned int> tmp;
      std::swap (vertex_dofs_offsets, tmp);
    }
  }


/*-------------- Explicit Instantiations -------------------------------*/
  template class DoFHandler<deal_II_dimension>;

#if deal_II_dimension != 3
  template class DoFHandler<deal_II_dimension, deal_II_dimension+1>;
#endif


}

DEAL_II_NAMESPACE_CLOSE
