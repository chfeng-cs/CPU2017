//---------------------------------------------------------------------------
//    $Id: mapping_q1_eulerian.h 18473 2009-03-10 14:53:36Z kronbichler $
//    Version: $Name$
//
//    Copyright (C) 2001, 2002, 2003, 2004, 2005, 2006, 2008, 2009 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__mapping_q1_eulerian_h
#define __deal2__mapping_q1_eulerian_h

#include <base/config.h>
#include <base/smartpointer.h>
#include <fe/mapping_q1.h> 

DEAL_II_NAMESPACE_OPEN

/*!@addtogroup mapping */
/*@{*/

/**
 * Eulerian mapping of general unit cells by d-linear shape
 * functions. Each cell is thus shifted in space by values given to
 * the mapping through a finite element field.
 *
 * <h3>Usage</h3> 
 *
 * The constructor of this class takes two arguments: a reference to
 * the vector that defines the mapping from the reference
 * configuration to the current configuration and a reference to the
 * DoFHandler. The vector should then represent a (flattened out
 * version of a) vector valued field defined at nodes defined by the 
 * the DoFHandler, where the number of components of the vector
 * field equals the number of space dimensions. Thus, the 
 * DoFHandler shall operate on a finite element that has as many 
 * components as space dimensions. As an additional requirement, we 
 * impose that it have as many degree of freedom per vertex as there
 * are space dimensions; since this object only evaluates the finite 
 * element field at the vertices, the values
 * of all other degrees of freedom (not associated to vertices) are
 * ignored. These requirements are met if the finite element which the
 * given DoFHandler operates on is constructed as a system
 * element (FESystem) from @p dim continuous FE_Q()
 * objects.
 *
 * In many cases, the shift vector will also be the solution vector of
 * the problem under investigation. If this is not the case (i.e. the
 * number of components of the solution variable is not equal to the
 * space dimension, e.g. for scalar problems in <tt>dim>1</tt> where the
 * Eulerian coordinates only give a background field) or for coupled
 * problems where more variables are computed than just the flow
 * field), then a different DoFHandler has to be set up on the
 * given triangulation, and the shift vector has then to be associated
 * to it.
 *
 * An example is shown below:
 * @verbatim
 *    FESystem<dim> fe(FE_Q<dim>(1), dim);
 *    DoFHandler<dim> flowfield_dof_handler(triangulation);
 *    flowfield_dof_handler.distribute_dofs(fe);
 *    Vector<double> map_points(flowfield_dof_handler.n_dofs());
 *    MappingQ1Eulerian<dim> mymapping(map_points, flowfield_dof_handler);
 * @endverbatim
 *
 * Note that since the vector of shift values and the dof handler are
 * only associated to this object at construction time, you have to
 * make sure that whenever you use this object, the given objects
 * still represent valid data.
 *
 * To enable the use of the MappingQ1Eulerian class also in the context
 * of parallel codes using the PETSc wrapper classes, the type of
 * the vector can be specified as template parameter <tt>EulerVectorType</tt>
 * Not specifying this template argument in applications using the PETSc
 * vector classes leads to the construction of a copy of the vector
 * which is not acccessible afterwards!
 * 
 * For more information about the <tt>spacedim</tt> template parameter
 * check the documentation of FiniteElement or the one of
 * Triangulation.
 *
 * @author Michael Stadler, 2001
 */
template <int dim, class EulerVectorType = Vector<double>, int spacedim=dim >
class MappingQ1Eulerian : public MappingQ1<dim,spacedim>
{
  public:

				     /**
				      * Constructor. It takes a
				      * <tt>Vector<double> &</tt> as its
				      * first argument to specify the
				      * transformation of the whole
				      * problem from the reference to
				      * the current configuration.
				      * The organization of the
				      * elements in the @p Vector
				      * must follow the concept how
				      * deal.II stores solutions that
				      * are associated to a
				      * triangulation.  This is
				      * automatically the case if the
				      * @p Vector represents the
				      * solution of the previous step
				      * of a nonlinear problem.
				      * Alternatively, the @p Vector
				      * can be initialized by
				      * <tt>DoFAccessor::set_dof_values()</tt>.
				      */
    MappingQ1Eulerian (const EulerVectorType  &euler_transform_vectors,
                       const DoFHandler<dim> &shiftmap_dof_handler);
    
                                     /**
                                      * Return a pointer to a copy of the
                                      * present object. The caller of this
                                      * copy then assumes ownership of it.
                                      */
    virtual
    Mapping<dim,spacedim> * clone () const;

    
				     /**
				      * Exception
				      */
    DeclException0 (ExcWrongNoOfComponents);
    
				     /**
				      * Exception.
				      */
    DeclException2 (ExcWrongVectorSize,
		    int, int,
		    << "Vector has wrong size " << arg1
		    << ", expected size " << arg2);

				     /**
				      * Exception.
				      */
    DeclException0 (ExcInactiveCell);



  protected:
				     /**
				      * Implementation of the interface in
				      * MappingQ1. Overrides the function in
				      * the base class, since we cannot use
				      * any cell similarity for this class.
				      */
    virtual void
    fill_fe_values (const typename Triangulation<dim,spacedim>::cell_iterator &cell,
		    const Quadrature<dim>                                     &quadrature,
		    typename Mapping<dim,spacedim>::InternalDataBase          &mapping_data,
		    typename std::vector<Point<spacedim> >                    &quadrature_points,
		    std::vector<double>                                       &JxW_values,
		    std::vector<Tensor<2,spacedim> >                          &jacobians,
		    std::vector<Tensor<3,spacedim> >                          &jacobian_grads,
		    std::vector<Tensor<2,spacedim> >                          &inverse_jacobians,
		    std::vector<Point<spacedim> >                             &cell_normal_vectors,
		    enum CellSimilarity::Similarity                           &cell_similarity) const;

				     /**
				      * Reference to the vector of
				      * shifts.
				      */
    const EulerVectorType &euler_transform_vectors;
    
                                     /**
				      * Pointer to the DoFHandler to
				      * which the mapping vector is
				      * associated.
				      */
    const SmartPointer<const DoFHandler<dim> > shiftmap_dof_handler;
    

  private:    
				     /**
				      * Computes the support points of
				      * the mapping. For
				      * @p MappingQ1Eulerian these
				      * are the vertices.
				      */
    virtual void compute_mapping_support_points(
      const typename Triangulation<dim>::cell_iterator &cell,
      std::vector<Point<dim> > &a) const;
    
};

/*@}*/

DEAL_II_NAMESPACE_CLOSE

#endif
