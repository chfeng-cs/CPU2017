//---------------------------------------------------------------------------
//    $Id: data_postprocessor.cc 15314 2007-10-14 05:25:26Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2007 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#include <numerics/data_postprocessor.h>

DEAL_II_NAMESPACE_OPEN


template <int dim>
DataPostprocessor<dim>::~DataPostprocessor()
{}



template <int dim>
void
DataPostprocessor<dim>::
compute_derived_quantities_scalar (const std::vector<double>         &/*uh*/,
				   const std::vector<Tensor<1,dim> > &/*duh*/,
				   const std::vector<Tensor<2,dim> > &/*dduh*/,
				   const std::vector<Point<dim> >    &/*normals*/,
				   std::vector<Vector<double> >      &computed_quantities) const
{
  computed_quantities.clear();
  AssertThrow(false,ExcPureFunctionCalled());
}



template <int dim>
void
DataPostprocessor<dim>::
compute_derived_quantities_vector (const std::vector<Vector<double> >              &/*uh*/,
				   const std::vector<std::vector<Tensor<1,dim> > > &/*duh*/,
				   const std::vector<std::vector<Tensor<2,dim> > > &/*dduh*/,
				   const std::vector<Point<dim> >                  &/*normals*/,
				   std::vector<Vector<double> >                    &computed_quantities) const
{
  computed_quantities.clear();
  AssertThrow(false,ExcPureFunctionCalled());
}



template <int dim>
std::vector<DataComponentInterpretation::DataComponentInterpretation>
DataPostprocessor<dim>::get_data_component_interpretation () const
{
				   // default implementation assumes that all
				   // components are independent scalars
  return
    std::vector<DataComponentInterpretation::DataComponentInterpretation>
    (n_output_variables(),
     DataComponentInterpretation::component_is_scalar);
}



// explicit instantiation
template class DataPostprocessor<deal_II_dimension>;

DEAL_II_NAMESPACE_CLOSE
