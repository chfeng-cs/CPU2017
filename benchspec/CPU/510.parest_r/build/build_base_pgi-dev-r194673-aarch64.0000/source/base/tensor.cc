//---------------------------------------------------------------------------
//    $Id: tensor.cc 14038 2006-10-23 02:46:34Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 1999, 2000, 2001, 2002, 2003, 2005, 2006 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <base/tensor.h>
#include <cmath>
#include <lac/vector.h>

DEAL_II_NAMESPACE_OPEN


// storage for static variables
template <int dim>
const unsigned int Tensor<1,dim>::dimension;

template <int rank, int dim>
const unsigned int Tensor<rank,dim>::dimension;


template <int dim>
void
Tensor<1,dim>::unroll (Vector<double> &result) const
{
  Assert (result.size()==dim,
          ExcDimensionMismatch(dim, result.size()));

  unsigned index = 0;
  unroll_recursion (result,index);
}



template <int rank_, int dim>
void
Tensor<rank_, dim>::unroll (Vector<double> &result) const
{
  Assert(result.size()==std::pow(static_cast<double>(dim),rank_),
	 ExcDimensionMismatch(static_cast<unsigned int>(std::pow(static_cast<double>(dim),rank_)),
                              result.size()));

  unsigned index = 0;
  unroll_recursion (result, index);
}



template <int rank_, int dim>
void
Tensor<rank_, dim>::unroll_recursion (Vector<double> &result,
                                      unsigned int   &index) const
{
  for (unsigned i=0; i<dim; ++i)
    {
      operator[](i).unroll_recursion(result, index);
    }    
}



template<int dim>
void
Tensor<1,dim>::unroll_recursion (Vector<double> &result,
                                 unsigned int   &index) const
{
  for (unsigned i=0; i<dim; ++i)
    result(index++) = operator[](i);  
}


template class Tensor<1, 1>;
template class Tensor<1, 2>;
template class Tensor<1, 3>;
template class Tensor<2, 1>;
template class Tensor<2, 2>;
template class Tensor<2, 3>;
template class Tensor<3, 1>;
template class Tensor<3, 2>;
template class Tensor<3, 3>;
template class Tensor<4, 1>;
template class Tensor<4, 2>;
template class Tensor<4, 3>;

DEAL_II_NAMESPACE_CLOSE
