//---------------------------------------------------------------------------
//    $Id: quadrature.h 15613 2007-12-27 19:53:51Z kanschat $
//    Version: $Name$
//
//    Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__quadrature_h
#define __deal2__quadrature_h


#include <base/config.h>
#include <base/point.h>
#include <base/subscriptor.h>
#include <vector>

DEAL_II_NAMESPACE_OPEN

/*!@addtogroup Quadrature */
/*@{*/

/**
 * Base class for quadrature formul� in arbitrary dimensions. This class
 * stores quadrature points and weights on the unit line [0,1], unit
 * square [0,1]x[0,1], etc.
 *
 * There are a number of derived classes, denoting concrete
 * integration formul�. Their names names prefixed by
 * <tt>Q</tt>. Refer to the list of derived classes for more details.
 *
 * The schemes for higher dimensions are tensor products of the
 * one-dimansional formul�. Therefore, a three-dimensional 5-point
 * Gauss formula has 125 quadrature points.
 *
 * <h3>Mathematical background</h3>
 *
 * For each quadrature formula we denote by <tt>m</tt>, the maximal
 * degree of polynomials integrated exactly. This number is given in
 * the documentation of each formula. The order of the integration
 * error is <tt>m+1</tt>, that is, the error is the size of the cell
 * two the <tt>m+1</tt> by the Bramble-Hilbert Lemma. The number
 * <tt>m</tt> is to be found in the documentation of each concrete
 * formula. For the optimal formul� QGauss we have $m = 2N-1$, where
 * N is the constructor parameter to QGauss. The tensor product
 * formul� are exact on tensor product polynomials of degree
 * <tt>m</tt> in each space direction, but they are still only of
 * <tt>m+1</tt>st order.
 *
 * <h3>Implementation details</h3>
 *
 * Most integration formul� in more than one space dimension are
 * tensor products of quadrature formul� in one space dimension, or
 * more generally the tensor product of a formula in <tt>(dim-1)</tt>
 * dimensions and one in one dimension. There is a special constructor
 * to generate a quadrature formula from two others.  For example, the
 * QGauss@<dim@> formul� include <i>N<sup>dim</sup></i> quadrature
 * points in <tt>dim</tt> dimensions, where N is the constructor
 * parameter of QGauss.
 *
 * For some programs it is necessary to have a quadrature object for
 * faces.  These programs fail to link if compiled for only one space
 * dimension, since there quadrature rules for faces just don't make
 * no sense. In order to allow these programs to be linked anyway, for
 * class Quadrature@<0@> all functions are provided in the
 * <tt>quadrature.cc</tt> file, but they will throw exceptions if actually
 * called. The only function which is allowed to be called is the
 * constructor taking one integer, which in this case ignores its
 * parameter, and of course the destructor. Besides this, it is
 * necessary to provide a class Point@<0@> to make the compiler
 * happy. This class also does nothing.
 *
 * @note Instantiations for this template are provided for dimensions 1, 2,
 * and 3 (see the section on @ref Instantiations in the manual).
 *
 * @author Wolfgang Bangerth, Guido Kanschat, 1998, 1999, 2000, 2005
 */
template <int dim>
class Quadrature : public Subscriptor
{
  public:
				     /**
				      * Define a typedef for a
				      * quadrature that acts on an
				      * object of one dimension
				      * less. For cells, this would
				      * then be a face quadrature.
				      */
    typedef Quadrature<dim-1> SubQuadrature;
    
				     /**
				      * @deprecated Use size()
				      * instead.
				      *
				      * Number of quadrature points.
				      *
				      * @warning After introduction of
				      * the assignment operator, this
				      * number is not constant anymore
				      * and erroneous assignment can
				      * compromise integrity of the
				      * Quadrature object. Since
				      * direct data access should be
				      * considered a design flaw
				      * anyway, it is strongly
				      * suggested to use size()
				      * instead.
				      */
    unsigned int n_quadrature_points;

				     /**
				      * Constructor.
				      *
				      * This constructor is marked as
				      * explicit to avoid involuntary
				      * accidents like in
				      * <code>hp::QCollection@<dim@>
				      * q_collection(3)</code> where
				      * <code>hp::QCollection@<dim@>
				      * q_collection(QGauss@<dim@>(3))</code>
				      * was meant.
				      */
    explicit Quadrature (const unsigned int n_quadrature_points = 0);

				     /**
				      * Build this quadrature formula
				      * as the tensor product of a
				      * formula in a dimension one
				      * less than the present and a
				      * formula in one dimension.
				      *
				      * <tt>SubQuadrature<dim>::type</tt>
				      * expands to
				      * <tt>Quadrature<dim-1></tt>.
				      */
    Quadrature (const SubQuadrature &,
		const Quadrature<1> &);
    
				     /**
				      * Build this quadrature formula
				      * as the <tt>dim</tt>-fold
				      * tensor product of a formula in
				      * one dimension.
				      *
				      * Assuming that the points in
				      * the one-dimensional rule are in
				      * ascending order, the points of
				      * the resulting rule are ordered
				      * lexicographically with
				      * <i>x</i> running fastest.
				      *
				      * In order to avoid a conflict
				      * with the copy constructor in
				      * 1d, we let the argument be a
				      * 0d quadrature formula for
				      * dim==1, and a 1d quadrature
				      * formula for all other space
				      * dimensions.
				      */
    explicit Quadrature (const Quadrature<dim != 1 ? 1 : 0> &quadrature_1d);

                                     /**
                                      * Copy constructor.
                                      */
    Quadrature (const Quadrature<dim> &q);
    
				     /**
				      * Construct a quadrature formula
				      * from given vectors of
				      * quadrature points (which
				      * should really be in the unit
				      * cell) and the corresponding
				      * weights. You will want to have
				      * the weights sum up to one, but
				      * this is not checked.
				      */
    Quadrature (const std::vector<Point<dim> > &points,
		const std::vector<double>      &weights);

				     /**
				      * Construct a dummy quadrature
				      * formula from a list of points,
				      * with weights set to
				      * infinity. The resulting object
				      * is therefore not meant to
				      * actually perform integrations,
				      * but rather to be used with
				      * FEValues objects in
				      * order to find the position of
				      * some points (the quadrature
				      * points in this object) on the
				      * transformed cell in real
				      * space.
				      */
    Quadrature (const std::vector<Point<dim> > &points);

				     /**
				      * Constructor for a one-point
				      * quadrature. Sets the weight of
				      * this point to one.
				      */
    Quadrature (const Point<dim> &point);

				     /**
				      * Assignment operator. Copies
				      * contents of #weights and
				      * #quadrature_points as well as
				      * size.
				      */
    Quadrature& operator = (const Quadrature<dim>&);
    
				     /**
				      * Virtual destructor.
				      */
    virtual ~Quadrature ();

				     /**
				      * Number of quadrature points.
				      */
    unsigned int size () const;
    
				     /**
				      * Return the <tt>i</tt>th quadrature
				      * point.
				      */
    const Point<dim> & point (const unsigned int i) const;

				     /**
				      * Return a reference to the
				      * whole array of quadrature
				      * points.
				      */
    const std::vector<Point<dim> > & get_points () const;
    
				     /**
				      * Return the weight of the <tt>i</tt>th
				      * quadrature point.
				      */
    double weight (const unsigned int i) const;

				     /**
				      * Return a reference to the whole array
				      * of weights.
				      */
    const std::vector<double> & get_weights () const;

    				     /**
				      * Determine an estimate for
				      * the memory consumption (in
				      * bytes) of this
				      * object.
				      */
    unsigned int memory_consumption () const;

  protected:
				     /**
				      * List of quadrature points. To
				      * be filled by the constructors
				      * of derived classes.
				      */
    std::vector<Point<dim> > quadrature_points;

				     /**
				      * List of weights of the
				      * quadrature points.  To be
				      * filled by the constructors of
				      * derived classes.
				      */
    std::vector<double>      weights;
};


/**
 * Quadrature formula implementing anisotropic distributions of
 * quadrature points on the reference cell. To this end, the tensor
 * product of <tt>dim</tt> one-dimensional quadrature formulas is
 * generated.
 *
 * @note Each constructor can only be used in the dimension matching
 * the number of arguments.
 *
 * @author Guido Kanschat, 2005
 */
template <int dim>
class QAnisotropic : public Quadrature<dim>
{
  public:
				     /**
				      * Constructor for a
				      * one-dimensional formula. This
				      * one just copies the given
				      * quadrature rule.
				      */
    QAnisotropic(const Quadrature<1>& qx);
    
				     /**
				      * Constructor for a
				      * two-dimensional formula.
				      */
    QAnisotropic(const Quadrature<1>& qx,
		 const Quadrature<1>& qy);
    
				     /**
				      * Constructor for a
				      * three-dimensional formula.
				      */
    QAnisotropic(const Quadrature<1>& qx,
		 const Quadrature<1>& qy,
		 const Quadrature<1>& qz);
};


/**
 * Quadrature formula constructed by iteration of another quadrature formula in
 * each direction. In more than one space dimension, the resulting quadrature
 * formula is constructed in the usual way by building the tensor product of
 * the respective iterated quadrature formula in one space dimension.
 *
 * In one space dimension, the given base formula is copied and scaled onto
 * a given number of subintervals of length <tt>1/n_copies</tt>. If the quadrature
 * formula uses both end points of the unit interval, then in the interior
 * of the iterated quadrature formula there would be quadrature points which
 * are used twice; we merge them into one with a weight which is the sum
 * of the weights of the left- and the rightmost quadrature point.
 *
 * Since all dimensions higher than one are built up by tensor products of
 * one dimensional and <tt>dim-1</tt> dimensional quadrature formul�, the
 * argument given to the constructor needs to be a quadrature formula in
 * one space dimension, rather than in <tt>dim</tt> dimensions.
 *
 * The aim of this class is to provide a
 * low order formula, where the error constant can be tuned by
 * increasing the number of quadrature points. This is useful in
 * integrating non-differentiable functions on cells.
 *
 * @author Wolfgang Bangerth 1999
 */
template <int dim>
class QIterated : public Quadrature<dim>
{
  public:
				     /**
				      * Constructor. Iterate the given
				      * quadrature formula <tt>n_copies</tt> times in
				      * each direction.
				      */
    QIterated (const Quadrature<1> &base_quadrature,
	       const unsigned int   n_copies);

				     /**
				      * Exception
				      */
    DeclException0 (ExcInvalidQuadratureFormula);
  private:
				     /**
				      * Check whether the given
				      * quadrature formula has quadrature
				      * points at the left and right end points
				      * of the interval.
				      */
    static bool
    uses_both_endpoints (const Quadrature<1> &base_quadrature);
};



/*@}*/

#ifndef DOXYGEN

// ----------------------------------------------------------------------


template<int dim>
inline
unsigned int
Quadrature<dim>::size () const
{
  return weights.size();
}


template <int dim>
inline
const Point<dim> &
Quadrature<dim>::point (const unsigned int i) const
{
  Assert (dim != 0, ExcNotImplemented());
  AssertIndexRange(i, size());
  return quadrature_points[i];
}



template <int dim>
double
Quadrature<dim>::weight (const unsigned int i) const
{
  Assert (dim != 0, ExcNotImplemented());
  AssertIndexRange(i, size());
  return weights[i];
}




/* -------------- declaration of explicit specializations ------------- */

template <>
Quadrature<0>::Quadrature (const unsigned int);
template <>
Quadrature<0>::Quadrature (const Quadrature<0> &);
template <>
Quadrature<0>::Quadrature (const Quadrature<-1> &,
			   const Quadrature<1> &);
template <>
Quadrature<0>::~Quadrature ();

template <>
Quadrature<1>::Quadrature (const Quadrature<0> &,
			   const Quadrature<1> &);

template <>
Quadrature<1>::Quadrature (const Quadrature<0> &);

template <>
const std::vector<Point<0> > & Quadrature<0>::get_points () const;
template <>
const std::vector<double> & Quadrature<0>::get_weights () const;

#endif // DOXYGEN
DEAL_II_NAMESPACE_CLOSE

#endif
