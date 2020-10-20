//---------------------------------------------------------------------------
//    $Id: data_out_rotation.h 17390 2008-10-29 02:20:03Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__data_out_rotation_h
#define __deal2__data_out_rotation_h


#include <base/config.h>
#include <numerics/data_out.h>

#include <string>
#include <vector>

DEAL_II_NAMESPACE_OPEN


/**
 * This class generates output in the full domain of computations that
 * were done using rotational symmetry of domain and solution. In
 * particular, if a computation of a three dimensional problem with
 * rotational symmetry around the @p z-axis (i.e. in the
 * @p r-z-plane) was done, then this class can be used to generate
 * the output in the original @p x-y-z space. In order to do so, it
 * generates from each cell in the computational mesh a cell in the
 * space with dimension one greater than that of the DoFHandler
 * object. The resulting output will then consist of hexahedra forming
 * an object that has rotational symmetry around the z-axis. As most
 * graphical programs can not represent ring-like structures, the
 * angular (rotation) variable is discretized into a finite number of
 * intervals as well; the number of these intervals must be given to
 * the @p build_patches function. It is noted, however, that while
 * this function generates nice pictures of the whole domain, it often
 * produces <em>very</em> large output files.
 *
 *
 * <h3>Interface</h3>
 *
 * The interface of this class is copied from the DataOut
 * class. Furthermore, they share the common parent class
 * DataOut_DoFData(). See the reference of these two classes for a
 * discussion of the interface and how to extend it by deriving
 * further classes from this class.
 *
 *
 * <h3>Details for 1d computations</h3>
 *
 * The one coordinate in the triangulation used by the
 * DoFHandler object passed to this class is taken as the radial
 * variable, and the output will then be either a circle or a ring
 * domain. It is in the user's responsibility to assure that the
 * radial coordinate only attains non-negative values.
 *
 *
 * <h3>Details for 2d computations</h3>
 *
 * We consider the computation (represented by the DoFHandler
 * object that is attached to this class) to have happened in the
 * @p r-z-plane, where @p r is the radial variable and @p z denotes
 * the axis of revolution around which the solution is symmetric. The
 * output is in @p x-y-z space, where the radial dependence is
 * transformed to the @p x-y plane. At present, it is not possible to
 * exchange the meaning of the first and second variable of the plane
 * in which the simulation was made, i.e. generate output from a
 * simulation where the first variable denoted the symmetry axis, and
 * the second denoted the radial variable. You have to take that into
 * account when first programming your application.
 *
 * It is in the responsibility of the user to make sure that the
 * radial variable attains only non-negative values.
 *
 * @ingroup output
 * @author Wolfgang Bangerth, 2000
 */
template <int dim, class DH=DoFHandler<dim> >
class DataOutRotation : public DataOut_DoFData<DH,DH::dimension+1>
{
  public:
				     /**
				      * Typedef to the iterator type
				      * of the dof handler class under
				      * consideration.
				      */
    typedef typename DataOut_DoFData<DH,DH::dimension+1>::cell_iterator cell_iterator;

                                     /**
				      * This is the central function
				      * of this class since it builds
				      * the list of patches to be
				      * written by the low-level
				      * functions of the base
				      * class. See the general
				      * documentation of this class
				      * for further information.
				      *
				      * In addition to the same
				      * parameters as found in the
				      * respective function of the
				      * DataOut class, the first
				      * parameter denotes into how
				      * many intervals the angular
				      * (rotation) variable is to be
				      * subdivided.
				      *
				      * The function supports
				      * multithreading, if deal.II is
				      * compiled in multithreading
				      * mode. The default number of
				      * threads to be used to build
				      * the patches is set to
				      * <tt>multithread_info.n_default_threads</tt>.
				      */
    virtual void build_patches (const unsigned int n_patches_per_circle,
				const unsigned int n_subdivisions = 0,
				const unsigned int n_threads      = multithread_info.n_default_threads);

				     /**
				      * Return the first cell which we
				      * want output for. The default
				      * implementation returns the
				      * first \ref GlossActive "active cell",
				      * but you might want to
				      * return other cells in a
				      * derived class.
				      */
    virtual cell_iterator first_cell ();
    
				     /**
				      * Return the next cell after @p cell which
				      * we want output for.
				      * If there are no more cells,
				      * <tt>dofs->end()</tt> shall be returned.
				      *
				      * The default
				      * implementation returns the next
				      * active cell, but you might want
				      * to return other cells in a derived
				      * class. Note that the default
				      * implementation assumes that
				      * the given @p cell is active, which
				      * is guaranteed as long as @p first_cell
				      * is also used from the default
				      * implementation. Overloading only one
				      * of the two functions might not be
				      * a good idea.
				      */
    virtual cell_iterator next_cell (const cell_iterator &cell);

				     /**
				      * Exception
				      */
    DeclException1 (ExcInvalidNumberOfSubdivisions,
		    int,
		    << "The number of subdivisions per patch, " << arg1
		    << ", is not valid.");
				     /**
				      * Exception
				      */
    DeclException1 (ExcRadialVariableHasNegativeValues,
		    double,
		    << "The radial variable attains a negative value of " << arg1);
    
  private:
				     /**
				      * Builds every @p n_threads's
				      * patch. This function may be
				      * called in parallel.
				      * If multithreading is not
				      * used, the function is called
				      * once and generates all patches.
				      */
    void build_some_patches (internal::DataOut::ParallelData<DH::dimension, DH::dimension> &data);
};


DEAL_II_NAMESPACE_CLOSE

#endif
