//---------------------------------------------------------------------------
//    $Id: intergrid_map.cc 17866 2008-12-05 22:27:44Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <base/memory_consumption.h>
#include <base/smartpointer.h>
#include <grid/tria.h>
#include <dofs/dof_handler.h>
#include <fe/fe.h>
#include <grid/tria_accessor.h>
#include <dofs/dof_accessor.h>
#include <grid/tria_iterator.h>
#include <grid/intergrid_map.h>

#include <multigrid/mg_dof_handler.h>
#include <multigrid/mg_dof_accessor.h>

DEAL_II_NAMESPACE_OPEN


namespace
{
// helper function to aquire the number of levels within a grid
  template <class GridClass>
  unsigned int
  get_n_levels (const GridClass &grid)
  {
				     // all objects we deal with are able
				     // to deliver a pointer to the
				     // underlying triangulation.
				     //
				     // for the triangulation as GridClass
				     // of this object, there is a
				     // specialization of this function
    return grid.get_tria().n_levels();
  }


// specialization for grid==tria
  template <int dim>
  unsigned int
  get_n_levels (const Triangulation<dim> &grid)
  {
				     // if GridClass==Triangulation, then
				     // we can ask directly.
    return grid.n_levels();
  }
}


template <class GridClass>
InterGridMap<GridClass>::InterGridMap ()
		:
		source_grid(0, typeid(*this).name()),
		destination_grid(0, typeid(*this).name())
{}




template <class GridClass>
void InterGridMap<GridClass>::make_mapping (const GridClass &source_grid,
					    const GridClass &destination_grid) 
{
				   // first delete all contents
  clear ();

				   // next store pointers to grids
  this->source_grid      = &source_grid;
  this->destination_grid = &destination_grid;

				   // then set up the containers from
				   // scratch and fill them with end-iterators
  const unsigned int n_levels = get_n_levels(source_grid);
  mapping.resize (n_levels);
  for (unsigned int level=0; level<n_levels; ++level)
    {
				       // first find out about the highest
				       // index used on this level. We could
				       // in principle ask the triangulation
				       // about this, but we would have to
				       // know the underlying data structure
				       // for this and we would like to
				       // avoid such knowledge here
      unsigned int n_cells = 0;
      cell_iterator cell = source_grid.begin(level),
		    endc = source_grid.end(level);
      for (; cell!=endc; ++cell)
	if (static_cast<unsigned int>(cell->index()) > n_cells)
	  n_cells = cell->index();

				       // note: n_cells is now the largest
				       // zero-based index, but we need the
				       // number of cells, which is one larger
      mapping[level].resize (n_cells+1, destination_grid.end());
    };

				   // now make up the mapping
				   // loop over all cells and set the user
				   // pointers as well as the contents of
				   // the two arrays. note that the function
				   // takes a *reference* to the int and
				   // this may change it
  cell_iterator src_cell = source_grid.begin(0),
		dst_cell = destination_grid.begin(0),
		endc     = source_grid.end(0);
  for (; src_cell!=endc; ++src_cell, ++dst_cell)
    set_mapping (src_cell, dst_cell);

				   // little assertion that the two grids
				   // are indeed related:
  Assert (dst_cell == destination_grid.end(0),
	  ExcIncompatibleGrids ());
}



template <class GridClass>
void
InterGridMap<GridClass>::set_mapping (const cell_iterator &src_cell,
				      const cell_iterator &dst_cell)
{
				   // first set the map for this cell
  mapping[src_cell->level()][src_cell->index()] = dst_cell;

				   // if both cells have children, we may
				   // recurse further into the hierarchy
  if (src_cell->has_children() && dst_cell->has_children())
    {
      Assert(src_cell->n_children()==
	     GeometryInfo<GridClass::dimension>::max_children_per_cell,
	     ExcNotImplemented());
      Assert(dst_cell->n_children()==
	     GeometryInfo<GridClass::dimension>::max_children_per_cell,
	     ExcNotImplemented());
      Assert(src_cell->refinement_case()==dst_cell->refinement_case(),
	     ExcNotImplemented());
      for (unsigned int c=0; c<GeometryInfo<GridClass::dimension>::max_children_per_cell; ++c)
	set_mapping (src_cell->child(c),
		     dst_cell->child(c));
    }
  else
    if (src_cell->has_children() &&
	!dst_cell->has_children())
				       // src grid is more refined here.
				       // set entries for all children
				       // of this cell to the one
				       // dst_cell
      for (unsigned int c=0; c<src_cell->n_children(); ++c)
	set_entries_to_cell (src_cell->child(c),
			     dst_cell);
				   // else (no cell is refined or
				   // dst_cell is refined): no pointers
				   // to be set
}



template <class GridClass>
void
InterGridMap<GridClass>::set_entries_to_cell (const cell_iterator &src_cell,
					      const cell_iterator &dst_cell)
{
  				   // first set the map for this cell
  mapping[src_cell->level()][src_cell->index()] = dst_cell;

				   // then do so for the children as well
				   // if there are any
  if (src_cell->has_children())
    for (unsigned int c=0; c<src_cell->n_children(); ++c)
      set_entries_to_cell (src_cell->child(c),
			   dst_cell);
}


template <class GridClass>
typename InterGridMap<GridClass>::cell_iterator
InterGridMap<GridClass>::operator [] (const cell_iterator &source_cell) const
{
  Assert (source_cell.state() == IteratorState::valid,
	  ExcInvalidKey (source_cell));
  Assert (source_cell->level() <= static_cast<int>(mapping.size()),
	  ExcInvalidKey (source_cell));
  Assert (source_cell->index() <= static_cast<int>(mapping[source_cell->level()].size()),
	  ExcInvalidKey (source_cell));

  return mapping[source_cell->level()][source_cell->index()];
}



template <class GridClass>
void InterGridMap<GridClass>::clear () 
{
  mapping.clear ();
  source_grid      = 0;
  destination_grid = 0;
}



template <class GridClass>
const GridClass &
InterGridMap<GridClass>::get_source_grid () const
{
  return *source_grid;
}



template <class GridClass>
const GridClass &
InterGridMap<GridClass>::get_destination_grid () const
{
  return *destination_grid;
}



template <class GridClass>
unsigned int
InterGridMap<GridClass>::memory_consumption () const
{
  return (MemoryConsumption::memory_consumption (mapping) +
	  MemoryConsumption::memory_consumption (source_grid) +
	  MemoryConsumption::memory_consumption (destination_grid));
}


  
// explicit instantiations
#include "../grid/intergrid_map.inst"

DEAL_II_NAMESPACE_CLOSE

