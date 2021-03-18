//---------------------------------------------------------------------------
//    $Id: data_out_rotation.cc 17390 2008-10-29 02:20:03Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <base/quadrature_lib.h>
#include <base/thread_management.h>
#include <lac/vector.h>
#include <lac/block_vector.h>
#include <grid/tria.h>
#include <dofs/dof_handler.h>
#include <dofs/dof_accessor.h>
#include <grid/tria_iterator.h>
#include <fe/fe.h>
#include <fe/fe_values.h>
#include <hp/fe_values.h>
#include <fe/mapping_q1.h>
#include <numerics/data_out_rotation.h>

#include <cmath>

DEAL_II_NAMESPACE_OPEN


//TODO: Update documentation
//TODO: Unify code for dimensions


//TODO: build_some_patches isn't going to work if first_cell/next_cell
//don't iterate over all cells and if cell data is requested. in that
//case, we need to calculate cell_number as in the DataOut class

// Not implemented for 3D

#if deal_II_dimension < 3
template <int dim, class DH>
void DataOutRotation<dim,DH>::build_some_patches (internal::DataOut::ParallelData<DH::dimension, DH::dimension> &data)
{
  QTrapez<1>     q_trapez;
  QIterated<DH::dimension> patch_points (q_trapez, data.n_subdivisions);

				   // create collection objects from
				   // single quadratures,
				   // and finite elements. if we have
				   // an hp DoFHandler,
				   // dof_handler.get_fe() returns a
				   // collection of which we do a
				   // shallow copy instead
                                   //
				   // since most output formats can't
				   // handle cells that are not
				   // transformed using a Q1 mapping,
				   // we don't support anything else
				   // as well
  const hp::QCollection<DH::dimension>       q_collection (patch_points);
  const hp::FECollection<DH::dimension>      fe_collection(this->dofs->get_fe());
  
  UpdateFlags update_flags=update_values | update_quadrature_points;
  for (unsigned int i=0; i<this->dof_data.size(); ++i)
    if (this->dof_data[i]->postprocessor)
      update_flags |= this->dof_data[i]->postprocessor->get_needed_update_flags();
				   // perhaps update_normal_vectors is present,
				   // which would only be useful on faces, but
				   // we may not use it here.
  Assert (!(update_flags & update_normal_vectors),
	  ExcMessage("The update of normal vectors may not be requested for evaluation of data on cells via DataPostprocessor."));
  
  hp::FEValues<DH::dimension> x_fe_patch_values (fe_collection, q_collection,
						 update_flags);

  const unsigned int n_patches_per_circle = data.n_patches_per_circle;

				   // another abbreviation denoting
				   // the number of q_points in each
				   // direction
  const unsigned int n_points = data.n_subdivisions+1;
  
				   // set up an array that holds the
				   // directions in the plane of
				   // rotation in which we will put
				   // points in the whole domain (not
				   // the rotationally reduced one in
				   // which the computation took
				   // place. for simplicity add the
				   // initial direction at the end
				   // again
  std::vector<Point<DH::dimension+1> > angle_directions (n_patches_per_circle+1);
  for (unsigned int i=0; i<=n_patches_per_circle; ++i)
    {
      angle_directions[i][DH::dimension-1] = std::cos(2*numbers::PI *
						      i/n_patches_per_circle);
      angle_directions[i][DH::dimension] = std::sin(2*numbers::PI *
						    i/n_patches_per_circle);
    };
  
  
  unsigned int cell_number = 0;
  typename std::vector< dealii::DataOutBase::Patch<DH::dimension+1> >::iterator
    patch = this->patches.begin();
  cell_iterator cell=first_cell();

				   // get first cell in this thread
  for (unsigned int i=0; (i<data.this_thread)&&(cell != this->dofs->end()); ++i)
    {
      std::advance (patch, n_patches_per_circle);
      ++cell_number;
      cell=next_cell(cell);
    }

  				   // now loop over all cells and
				   // actually create the patches
  for (; cell != this->dofs->end(); )
    {
      for (unsigned int angle=0; angle<n_patches_per_circle; ++angle, ++patch)
	{
	  Assert (patch != this->patches.end(), ExcInternalError());
	  

					   // first compute the
					   // vertices of the
					   // patch. note that they
					   // will have to be computed
					   // from the vertices of the
					   // cell, which has one
					   // dimension less, however.
	  switch (DH::dimension)
	    {
	      case 1:
	      {
		const double r1 = cell->vertex(0)(0),
			     r2 = cell->vertex(1)(0);
		Assert (r1 >= 0, ExcRadialVariableHasNegativeValues(r1));	
		Assert (r2 >= 0, ExcRadialVariableHasNegativeValues(r2));
		
		patch->vertices[0] = r1*angle_directions[angle];
		patch->vertices[1] = r2*angle_directions[angle];
		patch->vertices[2] = r1*angle_directions[angle+1];
		patch->vertices[3] = r2*angle_directions[angle+1];

		break;
	      };
	       
	      case 2:
	      {
		for (unsigned int vertex=0;
		     vertex<GeometryInfo<DH::dimension>::vertices_per_cell;
		     ++vertex)
		  {
		    const Point<DH::dimension> v = cell->vertex(vertex);
		    
						     // make sure that the
						     // radial variable does
						     // attain negative
						     // values
		    Assert (v(0) >= 0, ExcRadialVariableHasNegativeValues(v(0)));
		    
						     // now set the vertices
						     // of the patch
		    patch->vertices[vertex] = v(0) * angle_directions[angle];
		    patch->vertices[vertex][0] = v(1);
		    
		    patch->vertices[vertex+GeometryInfo<DH::dimension>::vertices_per_cell]
		      = v(0) * angle_directions[angle+1];
		    patch->vertices[vertex+GeometryInfo<DH::dimension>::vertices_per_cell][0]
		      = v(1);
		  };
		
		break;
	      };

	      default:
		    Assert (false, ExcNotImplemented());
	    };
	  
	  unsigned int offset=0;
	       
					   // then fill in data
	  if (data.n_datasets > 0)
	    {
	      x_fe_patch_values.reinit (cell);
              const FEValues<DH::dimension> &fe_patch_values
                = x_fe_patch_values.get_present_fe_values ();

					       // first fill dof_data
	      for (unsigned int dataset=0; dataset<this->dof_data.size(); ++dataset)
		{
		  const DataPostprocessor<dim> *postprocessor=this->dof_data[dataset]->postprocessor;
		  if (postprocessor != 0)
		    {
						       // we have to postprocess the
						       // data, so determine, which
						       // fields have to be updated
		      const UpdateFlags update_flags=postprocessor->get_needed_update_flags();

		      if (data.n_components == 1)
			{
							   // at each point there is
							   // only one component of
							   // value, gradient etc.
			  if (update_flags & update_values)
			    this->dof_data[dataset]->get_function_values (fe_patch_values,
									  data.patch_values);
			  if (update_flags & update_gradients)
			    this->dof_data[dataset]->get_function_gradients (fe_patch_values,
									     data.patch_gradients);
			  if (update_flags & update_hessians)
			    this->dof_data[dataset]->get_function_hessians (fe_patch_values,
									    data.patch_hessians);
			  postprocessor->
			    compute_derived_quantities_scalar(data.patch_values,
							      data.patch_gradients,
							      data.patch_hessians,
							      data.dummy_normals,
							      data.postprocessed_values[dataset]);
			}
		      else
			{
							   // at each point there is
							   // a vector valued
							   // function and its
							   // derivative...
			  if (update_flags & update_values)
			    this->dof_data[dataset]->get_function_values (fe_patch_values,
									  data.patch_values_system);
			  if (update_flags & update_gradients)
			    this->dof_data[dataset]->get_function_gradients (fe_patch_values,
									     data.patch_gradients_system);
			  if (update_flags & update_hessians)
			    this->dof_data[dataset]->get_function_hessians (fe_patch_values,
									    data.patch_hessians_system);
			  postprocessor->
			    compute_derived_quantities_vector(data.patch_values_system,
							      data.patch_gradients_system,
							      data.patch_hessians_system,
							      data.dummy_normals,
							      data.postprocessed_values[dataset]);
			}
		      
		      for (unsigned int component=0;
			   component<this->dof_data[dataset]->n_output_variables;
			   ++component)
			{
			  switch (DH::dimension)
			    {
			      case 1:
				    for (unsigned int x=0; x<n_points; ++x)
				      for (unsigned int y=0; y<n_points; ++y)
					patch->data(offset+component,
						    x*n_points + y)
					  = data.postprocessed_values[dataset][x](component);
				    break;
				      
			      case 2:
				    for (unsigned int x=0; x<n_points; ++x)
				      for (unsigned int y=0; y<n_points; ++y)
					for (unsigned int z=0; z<n_points; ++z)
					  patch->data(offset+component,
						      x*n_points*n_points +
						      y*n_points +
						      z)
					    = data.postprocessed_values[dataset][x*n_points+z](component);
				    break;
				      
			      default:
				    Assert (false, ExcNotImplemented());
			    }
			}
		    }
		  else
		    if (data.n_components == 1)
		      {
			this->dof_data[dataset]->get_function_values (fe_patch_values,
								      data.patch_values);
			
			switch (DH::dimension)
			  {
			    case 1:
				  for (unsigned int x=0; x<n_points; ++x)
				    for (unsigned int y=0; y<n_points; ++y)
				      patch->data(offset,
						  x*n_points + y)
					= data.patch_values[x];
				  break;
				  
			    case 2:
				  for (unsigned int x=0; x<n_points; ++x)
				    for (unsigned int y=0; y<n_points; ++y)
				      for (unsigned int z=0; z<n_points; ++z)
					patch->data(offset,
						    x*n_points*n_points +
						    y +
						    z*n_points)
					  = data.patch_values[x*n_points+z];
				  break;
				  
			    default:
				  Assert (false, ExcNotImplemented());
			  }
		      }
		    else
						       // system of components
		      {
			this->dof_data[dataset]->get_function_values (fe_patch_values,
								      data.patch_values_system);
			
			for (unsigned int component=0; component<data.n_components;
			     ++component)
			  {
			    switch (DH::dimension)
			      {
				case 1:
				      for (unsigned int x=0; x<n_points; ++x)
					for (unsigned int y=0; y<n_points; ++y)
					  patch->data(offset+component,
						      x*n_points + y)
					    = data.patch_values_system[x](component);
				      break;
				      
				case 2:
				      for (unsigned int x=0; x<n_points; ++x)
					for (unsigned int y=0; y<n_points; ++y)
					  for (unsigned int z=0; z<n_points; ++z)
					    patch->data(offset+component,
							x*n_points*n_points +
							y*n_points +
							z)
					      = data.patch_values_system[x*n_points+z](component);
				      break;
				      
				default:
				      Assert (false, ExcNotImplemented());
			      }
			  }
		      }
		  offset+=this->dof_data[dataset]->n_output_variables;
		}
		  
					       // then do the cell data
	      for (unsigned int dataset=0; dataset<this->cell_data.size(); ++dataset)
		{
		  const double value
                    = this->cell_data[dataset]->get_cell_data_value (cell_number);
		  switch (DH::dimension)
		    {
		      case 1:
			    for (unsigned int x=0; x<n_points; ++x)
			      for (unsigned int y=0; y<n_points; ++y)
				patch->data(dataset+offset,
					    x*n_points +
					    y)
				  = value;
			    break;
			    
		      case 2:
			    for (unsigned int x=0; x<n_points; ++x)
			      for (unsigned int y=0; y<n_points; ++y)
				for (unsigned int z=0; z<n_points; ++z)
				  patch->data(dataset+offset,
					      x*n_points*n_points +
					      y*n_points +
					      z)
				    = value;
			    break;

		      default:
			    Assert (false, ExcNotImplemented());
		    }
		}
	    }
	}
      
				       // next cell (patch) in this
				       // thread. note that we have
				       // already advanced the patches
				       // for the present cell,
				       // i.e. we only have to skip
				       // the cells belonging to other
				       // threads, not the ones
				       // belonging to this thread.
      const int skip_threads = static_cast<signed int>(data.n_threads)-1;
      for (int i=0; (i<skip_threads) && (cell != this->dofs->end()); ++i)
	std::advance (patch, n_patches_per_circle);

				       // however, cell and cell
				       // number have not yet been
				       // increased
      for (unsigned int i=0; (i<data.n_threads) && (cell != this->dofs->end()); ++i)
	{
	  ++cell_number;
	  cell=next_cell(cell);
	}
    }
}



#else

template <int dim, class DH>
void DataOutRotation<dim,DH>::build_some_patches (internal::DataOut::ParallelData<DH::dimension, DH::dimension> &)
{
				   // would this function make any
				   // sense after all? who would want
				   // to output/compute in four space
				   // dimensions?
  Assert (false, ExcNotImplemented());
}

#endif



template <int dim, class DH>
void DataOutRotation<dim,DH>::build_patches (
  const unsigned int n_patches_per_circle,
  const unsigned int nnnn_subdivisions,
  const unsigned int n_threads_) 
{
				   // Check consistency of redundant
				   // template parameter
  Assert (dim==DH::dimension, ExcDimensionMismatch(dim, DH::dimension));
  
  unsigned int n_subdivisions = (nnnn_subdivisions != 0)
				? nnnn_subdivisions
				: this->default_subdivisions;
  
  Assert (n_subdivisions >= 1,
	  ExcInvalidNumberOfSubdivisions(n_subdivisions));

  typedef DataOut_DoFData<DH,DH::dimension+1> BaseClass;
  Assert (this->dofs != 0, typename BaseClass::ExcNoDoFHandlerSelected());

  Assert (!DEAL_II_USE_MT || (n_threads_ >= 1),
	  ExcMessage ("Must run with at least one thread!"));
  const unsigned int n_threads = (DEAL_II_USE_MT ? n_threads_ : 1);

				   // before we start the loop:
				   // create a quadrature rule that
				   // actually has the points on this
				   // patch
  QTrapez<1>     q_trapez;
  QIterated<DH::dimension> patch_points (q_trapez, n_subdivisions);

  const unsigned int n_q_points     = patch_points.n_quadrature_points;
  const unsigned int n_components   = this->dofs->get_fe().n_components();
  unsigned int n_datasets=this->cell_data.size();
  for (unsigned int i=0; i<this->dof_data.size(); ++i)
    n_datasets+= this->dof_data[i]->n_output_variables;
  
				   // clear the patches array
  if (true)
    {
      std::vector< dealii::DataOutBase::Patch<DH::dimension+1> > dummy;
      this->patches.swap (dummy);
    };
  
				   // first count the cells we want to
				   // create patches of and make sure
				   // there is enough memory for that
  unsigned int n_patches = 0;
  for (cell_iterator cell=first_cell(); cell != this->dofs->end();
       cell = next_cell(cell))
    ++n_patches;
				   // then also take into account that
				   // we want more than one patch to
				   // come out of every cell, as they
				   // are repeated around the axis of
				   // rotation
  n_patches *= n_patches_per_circle;

  std::vector<internal::DataOut::ParallelData<DH::dimension, DH::dimension> > thread_data(n_threads);

				   // init data for the threads
  for (unsigned int i=0;i<n_threads;++i)
    {
      thread_data[i].n_threads            = n_threads;
      thread_data[i].this_thread          = i;
      thread_data[i].n_components         = n_components;
      thread_data[i].n_datasets           = n_datasets;
      thread_data[i].n_patches_per_circle = n_patches_per_circle;
      thread_data[i].n_subdivisions       = n_subdivisions;
      thread_data[i].patch_values.resize (n_q_points);
      thread_data[i].patch_values_system.resize (n_q_points);
      thread_data[i].patch_gradients.resize (n_q_points);
      thread_data[i].patch_gradients_system.resize (n_q_points);
      thread_data[i].patch_hessians.resize (n_q_points);
      thread_data[i].patch_hessians_system.resize (n_q_points);
      thread_data[i].dummy_normals.clear();
      thread_data[i].postprocessed_values.resize(this->dof_data.size());
      
      for (unsigned int k=0; k<n_q_points; ++k)
	{
	  thread_data[i].patch_values_system[k].reinit(n_components);
	  thread_data[i].patch_gradients_system[k].resize(n_components);
	  thread_data[i].patch_hessians_system[k].resize(n_components);
	}

      for (unsigned int dataset=0; dataset<this->dof_data.size(); ++dataset)
	if (this->dof_data[dataset]->postprocessor)
	  thread_data[i].postprocessed_values[dataset].resize(n_q_points,Vector<double>(this->dof_data[dataset]->n_output_variables));
    }

				   // create the patches with default
				   // values. note that the evaluation
				   // points on the cell have to be
				   // repeated in angular direction
  dealii::DataOutBase::Patch<DH::dimension+1>  default_patch;
  default_patch.n_subdivisions = n_subdivisions;
  default_patch.data.reinit (n_datasets,
			     n_q_points * (n_subdivisions+1));
  this->patches.insert (this->patches.end(), n_patches, default_patch);

  if (DEAL_II_USE_MT)
    {
      void (DataOutRotation<dim,DH>::*p) (internal::DataOut::ParallelData<DH::dimension, DH::dimension> &)
        = &DataOutRotation<dim,DH>::build_some_patches;

      Threads::ThreadGroup<> threads;
      for (unsigned int l=0;l<n_threads;++l)
        threads += Threads::spawn (*this, p) (thread_data[l]);
      threads.join_all();
    }
  else
                                     // just one thread
    build_some_patches(thread_data[0]);
}



template <int dim, class DH>
typename DataOutRotation<dim,DH>::cell_iterator
DataOutRotation<dim,DH>::first_cell () 
{
  return this->dofs->begin_active ();
}


template <int dim, class DH>
typename DataOutRotation<dim,DH>::cell_iterator
DataOutRotation<dim,DH>::next_cell (const cell_iterator &cell) 
{
				   // convert the iterator to an
				   // active_iterator and advance
				   // this to the next active cell
  typename DH::active_cell_iterator active_cell = cell;
  ++active_cell;
  return active_cell;
}


// explicit instantiations
template class DataOutRotation<deal_II_dimension, DoFHandler<deal_II_dimension> >;

DEAL_II_NAMESPACE_CLOSE
