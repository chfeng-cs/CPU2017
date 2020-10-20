//---------------------------------------------------------------------------
//    $Id: mg_transfer_component.cc 18724 2009-04-23 23:06:37Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2009 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------

#include <base/logstream.h>

#include <lac/vector.h>
#include <lac/block_vector.h>
#include <lac/sparse_matrix.h>
#include <lac/block_sparse_matrix.h>
#include <grid/tria.h>
#include <grid/tria_iterator.h>
#include <dofs/dof_tools.h>
#include <fe/fe.h>
#include <multigrid/mg_dof_handler.h>
#include <multigrid/mg_dof_accessor.h>
#include <multigrid/mg_transfer_component.h>
#include <multigrid/mg_transfer_component.templates.h>
#include <multigrid/mg_tools.h>

#include <algorithm>

DEAL_II_NAMESPACE_OPEN



template <int dim, int spacedim>
void MGTransferComponentBase::build_matrices (
  const DoFHandler<dim,spacedim>&,
  const MGDoFHandler<dim,spacedim>& mg_dof)
{
				   // Fill target component with
				   // standard values (identity) if it
				   // is empty
  if (target_component.size() == 0)
    {
      target_component.resize(mg_dof.get_fe().n_components());
      for (unsigned int i=0;i<target_component.size();++i)
	target_component[i] = i;
    } else {
				       // otherwise, check it for consistency
      Assert (target_component.size() == mg_dof.get_fe().n_components(),
	      ExcDimensionMismatch(target_component.size(),
				   mg_dof.get_fe().n_components()));
      
      for (unsigned int i=0;i<target_component.size();++i)
	{
	  Assert(i<target_component.size(),
		 ExcIndexRange(i,0,target_component.size()));
	}
    }
				   // Do the same for the multilevel
				   // components. These may be
				   // different.
  if (mg_target_component.size() == 0)
    {
      mg_target_component.resize(mg_dof.get_fe().n_components());
      for (unsigned int i=0;i<mg_target_component.size();++i)
	mg_target_component[i] = target_component[i];
    } else {
      Assert (mg_target_component.size() == mg_dof.get_fe().n_components(),
	      ExcDimensionMismatch(mg_target_component.size(),
				   mg_dof.get_fe().n_components()));
      
      for (unsigned int i=0;i<mg_target_component.size();++i)
	{
	  Assert(i<mg_target_component.size(),
		 ExcIndexRange(i,0,mg_target_component.size()));
	}
    }
  
  const FiniteElement<dim>& fe = mg_dof.get_fe();

				   // Effective number of components
				   // is the maximum entry in
				   // mg_target_component. This
				   // assumes that the values in that
				   // vector don't have holes.
  const unsigned int n_components  =
    *std::max_element(mg_target_component.begin(), mg_target_component.end()) + 1;
  const unsigned int dofs_per_cell = fe.dofs_per_cell;
  const unsigned int n_levels      = mg_dof.get_tria().n_levels();
  
  Assert (mg_selected.size() == fe.n_components(),
	  ExcDimensionMismatch(mg_selected.size(), fe.n_components()));
  
				   // Compute the lengths of all blocks
  sizes.resize(n_levels);
  MGTools::count_dofs_per_component(mg_dof, sizes, true, mg_target_component);

				   // Fill some index vectors
				   // for later use.
  mg_component_start = sizes;
				   // Compute start indices from sizes
  for (unsigned int l=0;l<mg_component_start.size();++l)
    {
      unsigned int k=0;
      for (unsigned int i=0;i<mg_component_start[l].size();++i)
	{
	  const unsigned int t=mg_component_start[l][i];
	  mg_component_start[l][i] = k;
	  k += t;
	}
    }

  component_start.resize(*std::max_element (target_component.begin(),
					    target_component.end()) + 1);
  DoFTools::
    count_dofs_per_component (static_cast<const DoFHandler<dim,spacedim>&>(mg_dof),
                              component_start, true, target_component);

  unsigned int k=0;
  for (unsigned int i=0;i<component_start.size();++i)
    {
      const unsigned int t=component_start[i];
      component_start[i] = k;
      k += t;
    }

				   // Build index vectors for
				   // copy_to_mg and
				   // copy_from_mg. These vectors must
				   // be prebuilt, since the
				   // get_dof_indices functions are
				   // too slow

  copy_to_and_from_indices.resize(n_levels);
  
// Building the prolongation matrices starts here!
  
				   // reset the size of the array of
				   // matrices. call resize(0) first,
				   // in order to delete all elements
				   // and clear their memory. then
				   // repopulate these arrays
				   //
				   // note that on resize(0), the
				   // shared_ptr class takes care of
				   // deleting the object it points to
				   // by itself
  prolongation_matrices.resize (0);
  prolongation_sparsities.resize (0);

  for (unsigned int i=0; i<n_levels-1; ++i)
    {
      prolongation_sparsities
	.push_back (std_cxx1x::shared_ptr<BlockSparsityPattern> (new BlockSparsityPattern));
      prolongation_matrices
	.push_back (std_cxx1x::shared_ptr<BlockSparseMatrix<double> > (new BlockSparseMatrix<double>));
    }

				   // two fields which will store the
				   // indices of the multigrid dofs
				   // for a cell and one of its children
  std::vector<unsigned int> dof_indices_parent (dofs_per_cell);
  std::vector<unsigned int> dof_indices_child (dofs_per_cell);
  
				   // for each level: first build the
				   // sparsity pattern of the matrices
				   // and then build the matrices
				   // themselves. note that we only
				   // need to take care of cells on
				   // the coarser level which have
				   // children
  for (unsigned int level=0; level<n_levels-1; ++level)
    {
				       // reset the dimension of the
				       // structure.  note that for
				       // the number of entries per
				       // row, the number of parent
				       // dofs coupling to a child dof
				       // is necessary. this, is the
				       // number of degrees of freedom
				       // per cell
      prolongation_sparsities[level]->reinit (n_components, n_components);
      for (unsigned int i=0; i<n_components; ++i)
	for (unsigned int j=0; j<n_components; ++j)
	  if (i==j)
	    prolongation_sparsities[level]->block(i,j)
	      .reinit(sizes[level+1][i],
		      sizes[level][j],
		      dofs_per_cell+1, false);
	  else
	    prolongation_sparsities[level]->block(i,j)
	      .reinit(sizes[level+1][i],
		      sizes[level][j],
		      0, false);

      prolongation_sparsities[level]->collect_sizes();
      
      for (typename MGDoFHandler<dim,spacedim>::cell_iterator cell=mg_dof.begin(level);
	   cell != mg_dof.end(level); ++cell)
	if (cell->has_children())
	  {
	    cell->get_mg_dof_indices (dof_indices_parent);

	    for (unsigned int child=0; child<cell->n_children(); ++child)
	      {
						 // set an alias to the
						 // prolongation matrix for
						 // this child
		const FullMatrix<double> &prolongation
		  = mg_dof.get_fe().get_prolongation_matrix (child, cell->refinement_case());
	    
		cell->child(child)->get_mg_dof_indices (dof_indices_child);

						 // now tag the entries in the
						 // matrix which will be used
						 // for this pair of parent/child
		for (unsigned int i=0; i<dofs_per_cell; ++i)
		  for (unsigned int j=0; j<dofs_per_cell; ++j)
		    if (prolongation(i,j) != 0)
		      {
			const unsigned int icomp
			  = fe.system_to_component_index(i).first;
			const unsigned int jcomp
			  = fe.system_to_component_index(j).first;
			if ((icomp==jcomp) && mg_selected[mg_target_component[icomp]])
			  prolongation_sparsities[level]->add(dof_indices_child[i],
							      dof_indices_parent[j]);
		      };
	      };
	  };
      prolongation_sparsities[level]->compress ();

      prolongation_matrices[level]->reinit (*prolongation_sparsities[level]);
				       // now actually build the matrices
      for (typename MGDoFHandler<dim,spacedim>::cell_iterator cell=mg_dof.begin(level);
	   cell != mg_dof.end(level); ++cell)
	if (cell->has_children())
	  {
	    cell->get_mg_dof_indices (dof_indices_parent);

	    for (unsigned int child=0; child<cell->n_children(); ++child)
	      {
						 // set an alias to the
						 // prolongation matrix for
						 // this child
		const FullMatrix<double> &prolongation
		  = mg_dof.get_fe().get_prolongation_matrix (child, cell->refinement_case());
	    
		cell->child(child)->get_mg_dof_indices (dof_indices_child);

						 // now set the entries in the
						 // matrix
		for (unsigned int i=0; i<dofs_per_cell; ++i)
		  for (unsigned int j=0; j<dofs_per_cell; ++j)
		    if (prolongation(i,j) != 0)
		      {
			const unsigned int icomp = fe.system_to_component_index(i).first;
			const unsigned int jcomp = fe.system_to_component_index(j).first;
			if ((icomp==jcomp) && mg_selected[mg_target_component[icomp]])
			  prolongation_matrices[level]->set(dof_indices_child[i],
							    dof_indices_parent[j],
							    prolongation(i,j));
		      }
	      }
	  }
    }
}


template <typename number>
template <int dim, int spacedim>
void MGTransferSelect<number>::build_matrices (
  const DoFHandler<dim,spacedim> &dof,
  const MGDoFHandler<dim,spacedim> &mg_dof,
  unsigned int select,
  unsigned int mg_select,
  const std::vector<unsigned int>& t_component,
  const std::vector<unsigned int>& mg_t_component)
{
  const FiniteElement<dim>& fe = mg_dof.get_fe();
  unsigned int ncomp = mg_dof.get_fe().n_components();
  
  target_component = t_component;
  mg_target_component = mg_t_component;
  
  selected_component = select;
  mg_selected_component = mg_select;
  selected.resize(ncomp, false);
  selected[select] = true;
  mg_selected.resize(ncomp, false);
  mg_selected[mg_select] = true;
				   // If components are renumbered,
				   // find the first original
				   // component corresponding to the
				   // target component.
  for (unsigned int i=0;i<target_component.size();++i)
    {
      if (target_component[i] == select)
	{
	  selected_component = i;
	  break;
	}
    }
    
  for (unsigned int i=0;i<mg_target_component.size();++i)
    {
      if (mg_target_component[i] == mg_select)
	{
	  mg_selected_component = i;
	  break;
	}
    }    
  MGTransferComponentBase::build_matrices (dof, mg_dof);
  
  std::vector<unsigned int> global_dof_indices (fe.dofs_per_cell);
  std::vector<unsigned int> level_dof_indices  (fe.dofs_per_cell);
  for (int level=dof.get_tria().n_levels()-1; level>=0; --level)
    {
      typename MGDoFHandler<dim,spacedim>::active_cell_iterator
	level_cell = mg_dof.begin_active(level);
      const typename MGDoFHandler<dim,spacedim>::active_cell_iterator
	level_end  = mg_dof.end_active(level);
      
				       // Compute coarse level right hand side
				       // by restricting from fine level.
      for (; level_cell!=level_end; ++level_cell)
	{
	  DoFAccessor<dim, DoFHandler<dim,spacedim> >& global_cell = *level_cell;
					   // get the dof numbers of
					   // this cell for the global
					   // and the level-wise
					   // numbering
	  global_cell.get_dof_indices(global_dof_indices);
	  level_cell->get_mg_dof_indices (level_dof_indices);
	  
	  for (unsigned int i=0; i<fe.dofs_per_cell; ++i)
	    {
	      const unsigned int component
		= mg_target_component[fe.system_to_component_index(i).first];
	      if (mg_selected[component])
		{
		  const unsigned int level_start
		    = mg_component_start[level][component];
		  copy_to_and_from_indices[level].insert(
		    std::make_pair(global_dof_indices[i]
				   - component_start[selected_component],
				   level_dof_indices[i]-level_start));
		}
	    }
	}
    }
}



// explicit instantiations

template
void MGTransferSelect<float>::build_matrices<deal_II_dimension>
(const DoFHandler<deal_II_dimension> &d,
 const MGDoFHandler<deal_II_dimension> &,
 unsigned int, unsigned int,
 const std::vector<unsigned int>&,
 const std::vector<unsigned int>&);

template
void MGTransferSelect<double>::build_matrices<deal_II_dimension>
(const DoFHandler<deal_II_dimension> &d,
 const MGDoFHandler<deal_II_dimension> &,
 unsigned int, unsigned int,
 const std::vector<unsigned int>&,
 const std::vector<unsigned int>&);

template void
MGTransferSelect<float>::copy_to_mg (
  const MGDoFHandler<deal_II_dimension>&,
  MGLevelObject<Vector<float> >&,
  const Vector<double>&) const;
template void
MGTransferSelect<float>::copy_to_mg (
  const MGDoFHandler<deal_II_dimension>&,
  MGLevelObject<Vector<float> >&,
  const BlockVector<double>&) const;
template void
MGTransferSelect<float>::copy_from_mg (
  const MGDoFHandler<deal_II_dimension>&,
  Vector<double>&,
  const MGLevelObject<Vector<float> >&) const;
template void
MGTransferSelect<float>::copy_from_mg (
  const MGDoFHandler<deal_II_dimension>&,
  BlockVector<double>&,
  const MGLevelObject<Vector<float> >&) const;
template void
MGTransferSelect<float>::copy_from_mg_add (
  const MGDoFHandler<deal_II_dimension>&,
  Vector<double>&,
  const MGLevelObject<Vector<float> >&) const;
template void
MGTransferSelect<float>::copy_from_mg_add (
  const MGDoFHandler<deal_II_dimension>&,
  BlockVector<double>&,
  const MGLevelObject<Vector<float> >&) const;

template void
MGTransferSelect<double>::copy_to_mg (
  const MGDoFHandler<deal_II_dimension>&,
  MGLevelObject<Vector<double> >&,
  const Vector<double>&) const;
template void
MGTransferSelect<double>::copy_to_mg (
  const MGDoFHandler<deal_II_dimension>&,
  MGLevelObject<Vector<double> >&,
  const BlockVector<double>&) const;
template void
MGTransferSelect<double>::copy_from_mg (
  const MGDoFHandler<deal_II_dimension>&,
  Vector<double>&,
  const MGLevelObject<Vector<double> >&) const;
template void
MGTransferSelect<double>::copy_from_mg (
  const MGDoFHandler<deal_II_dimension>&,
  BlockVector<double>&,
  const MGLevelObject<Vector<double> >&) const;
template void
MGTransferSelect<double>::copy_from_mg_add (
  const MGDoFHandler<deal_II_dimension>&,
  Vector<double>&,
  const MGLevelObject<Vector<double> >&) const;
template void
MGTransferSelect<double>::copy_from_mg_add (
  const MGDoFHandler<deal_II_dimension>&,
  BlockVector<double>&,
  const MGLevelObject<Vector<double> >&) const;

DEAL_II_NAMESPACE_CLOSE
