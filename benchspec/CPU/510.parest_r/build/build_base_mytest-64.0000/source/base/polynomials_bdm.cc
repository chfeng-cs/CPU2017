//---------------------------------------------------------------------------
//    $Id: polynomials_bdm.cc 15623 2008-01-17 17:37:37Z kanschat $
//    Version: $Name$
//
//    Copyright (C) 2004, 2005, 2006, 2007, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------

#include <base/polynomials_bdm.h>
#include <base/quadrature_lib.h>
#include <iostream>
#include <iomanip>

DEAL_II_NAMESPACE_OPEN


template <int dim>
PolynomialsBDM<dim>::PolynomialsBDM (const unsigned int k)
		:
		polynomial_space (Polynomials::Legendre::generate_complete_basis(k)),
		monomials(1),
		n_pols(compute_n_pols(k)),
		p_values(polynomial_space.n()),
		p_grads(polynomial_space.n()),
		p_grad_grads(polynomial_space.n())
{
  Assert (dim == 2, ExcNotImplemented());
  monomials[0] = Polynomials::Monomial<double> (k+1);
}



template <int dim>
void
PolynomialsBDM<dim>::compute (const Point<dim>            &unit_point,
			      std::vector<Tensor<1,dim> > &values,
			      std::vector<Tensor<2,dim> > &grads,
			      std::vector<Tensor<3,dim> > &grad_grads) const
{
  Assert(values.size()==n_pols || values.size()==0,
	 ExcDimensionMismatch(values.size(), n_pols));
  Assert(grads.size()==n_pols|| grads.size()==0,
	 ExcDimensionMismatch(grads.size(), n_pols));
  Assert(grad_grads.size()==n_pols|| grad_grads.size()==0,
	 ExcDimensionMismatch(grad_grads.size(), n_pols));

  const unsigned int n_sub = polynomial_space.n();
  p_values.resize((values.size() == 0) ? 0 : n_sub);
  p_grads.resize((grads.size() == 0) ? 0 : n_sub);
  p_grad_grads.resize((grad_grads.size() == 0) ? 0 : n_sub);

				   // Compute values of complete space
				   // and insert into tensors.  Result
				   // will have first all polynomials
				   // in the x-component, then y and
				   // z.
  polynomial_space.compute (unit_point, p_values, p_grads, p_grad_grads);

  std::fill(values.begin(), values.end(), Tensor<1,dim>());
  for (unsigned int i=0;i<p_values.size();++i)
    {
      for (unsigned int j=0;j<dim;++j)
	{
	  values[i+j*n_sub][j] = p_values[i];
	}
      
    }

				   // Let's hope this is not the transpose
  std::fill(grads.begin(), grads.end(), Tensor<2,dim>());
  for (unsigned int i=0;i<p_grads.size();++i)
    {
      for (unsigned int j=0;j<dim;++j)
	grads[i+j*n_sub][j] = p_grads[i];
    }

				   // Let's hope this is not the transpose
  std::fill(grad_grads.begin(), grad_grads.end(), Tensor<3,dim>());
  for (unsigned int i=0;i<p_grad_grads.size();++i)
    {
      for (unsigned int j=0;j<dim;++j)
	grad_grads[i+j*n_sub][j] = p_grad_grads[i];
    }

				   // This is the first polynomial not
				   // covered by the P_k subspace
  const unsigned int start = dim*n_sub;

				   // Store values of auxiliary
				   // polynomials and their
				   // derivatives
  std::vector<double> monoval0(3);
  std::vector<double> monoval1(3);

  monomials[0].value(unit_point(0), monoval0);
  monomials[0].value(unit_point(1), monoval1);
  if (values.size() != 0)
    {
      values[start][0] = monoval0[0];
      values[start][1] = -unit_point(1) * monoval0[1];
      values[start+1][0] = -unit_point(0) * monoval1[1];
      values[start+1][1] = monoval1[0];
    }
  if (grads.size() != 0)
    {
      grads[start][0][0] = monoval0[1];
      grads[start][0][1] = 0.;
      grads[start][1][0] = -unit_point(1) * monoval0[2];
      grads[start][1][1] = -monoval0[1];
      grads[start+1][0][0] = -monoval1[1];
      grads[start+1][0][1] = -unit_point(0) * monoval1[2];
      grads[start+1][1][0] = 0.;
      grads[start+1][1][1] = monoval1[1];
    }
  if (grad_grads.size() != 0)
    {
      Assert(false,ExcNotImplemented());
    }
}


/*
template <int dim>
void
PolynomialsBDM<dim>::compute_node_matrix (Table<2,double>& A) const
{
  std::vector<Polynomial<double> > moment_weight(2);
  for (unsigned int i=0;i<moment_weight.size();++i)
    moment_weight[i] = Monomial<double>(i);

  QGauss<dim-1> qface(polynomial_space.degree()+1);

  std::vector<Tensor<1,dim> > values(n());
  std::vector<Tensor<2,dim> > grads;
  std::vector<Tensor<3,dim> > grad_grads;
  values.resize(n());

  for (unsigned int face=0;face<2*dim;++face)
    {
      double orientation = 1.;
      if ((face==0) || (face==3))
	orientation = -1.;
      
      for (unsigned int k=0;k<qface.size();++k)
	{
	  const double w = qface.weight(k) * orientation;
	  const double x = qface.point(k)(0);
	  Point<dim> p;
	  switch (face)
	    {
	      case 2:
		p(1) = 1.;
	      case 0:
		p(0) = x;
		break;
	      case 1:
		p(0) = 1.;
	      case 3:
		p(1) = x;
		break;	      
	    }
//	std::cerr << p
//		  << '\t' << moment_weight[0].value(x)
//		  << '\t' << moment_weight[1].value(x)
//	  ;
	  
	  compute (p, values, grads, grad_grads);
	  
	  for (unsigned int i=0;i<n();++i)
	    {
//	    std::cerr << '\t' << std::setw(6) << values[i][1-face%2];
					       // Integrate normal component.
					       // This is easy on the unit square
	      for (unsigned int j=0;j<moment_weight.size();++j)
		A(moment_weight.size()*face+j,i)
		  += w * values[i][1-face%2] * moment_weight[j].value(x);
	    }
//	std::cerr << std::endl;
	}
    }
  
				   // Volume integrals are missing
				   //
				   // This degree is one larger
  Assert (polynomial_space.degree() <= 2,
	  ExcNotImplemented());
}
*/

template <int dim>
unsigned int
PolynomialsBDM<dim>::compute_n_pols(unsigned int k)
{
  if (dim == 1) return k+1;
  if (dim == 2) return (k+1)*(k+2)+2;
  if (dim == 3) return ((k+1)*(k+2)*(k+3))/2+3*(k+1);
  Assert(false, ExcNotImplemented());
  return 0;
}


template class PolynomialsBDM<1>;
template class PolynomialsBDM<2>;
template class PolynomialsBDM<3>;


DEAL_II_NAMESPACE_CLOSE
