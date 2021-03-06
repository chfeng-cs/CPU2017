//---------------------------------------------------------------------------
//    $Id: dof_faces.h 17892 2008-12-08 18:45:16Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2006, 2007, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__dof_faces_h
#define __deal2__dof_faces_h


#include <base/config.h>
#include <base/exceptions.h>
#include <dofs/dof_objects.h>
#include <vector>

DEAL_II_NAMESPACE_OPEN

template <int, int> class DoFHandler;
template <int, int> class MGDoFHandler;
  
namespace internal
{
/**
 * A namespace for internal data structures of the DoFHandler group of classes.
 *
 * @ingroup dofs
 */
  namespace DoFHandler
  {

/**    
 *
 * <h4>DoFFaces</h4>
 *
 * These classes are similar to the DoFLevel classes. We here store information
 * that is associated with faces, rather than cells, as this information is independent of
 * the hierachical structure of cells, which are organized in levels. In 2D we store
 * information on degrees of freedom located on lines whereas in 3D we store information on
 * drefrees of freedom located on quads and lines. In 1D we do nothing, as the faces of
 * lines are vertices which are treated seperately.
 *
 * Apart from the DoFObjects object containing the data to store (degree of freedom
 * indices) we do not store any data or provide any functionality. However, we do implement
 * a function to determine an estimate of the memory consumption of the contained
 * DoFObjects object(s).
 *
 * The data contained isn't usually directly accessed. Rather, except for some access from
 * the DoFHandler class, access is usually through the DoFAccessor::set_dof_index() and
 * DoFAccessor::dof_index() functions or similar functions of derived classes that in turn
 * access the member variables using the DoFHandler::get_dof_index() and corresponding
 * setter functions. Knowledge of the actual data format is therefore encapsulated to the
 * present hierarchy of classes as well as the dealii::DoFHandler class.
 *
 * @ingroup dofs
 * @author Tobias Leicht, 2006
 */    
    template<int dim>
    class DoFFaces
    {
					 /**
					  * Make the constructor private to prevent the use
					  * of this template, only the specializations
					  * should be used
					  */
      private:
	DoFFaces();
    };

/**
 * Store the indices of degrees of freedom on faces in 1D. As these would be vertices, which
 * are treted seperately, don't do anything.
 *
 * @ingroup dofs
 * @author Tobias Leicht, 2006
 */
    template<>
    class DoFFaces<1>
    {
      public:
					 /**
                                          * Determine an estimate for the
                                          * memory consumption (in bytes)
                                          * of this object.
                                          */
        unsigned int memory_consumption () const;
    };

/**
 * Store the indices of degrees of freedom on faces in 2D, which are lines.
 *
 * @ingroup dofs
 * @author Tobias Leicht, 2006
 */
    template<>
    class DoFFaces<2>
    {
      public:
					 /**
					  * The object containing the
					  * data of DoFs on lines.
					  */
	internal::DoFHandler::DoFObjects<1> lines;

					 /**
                                          * Determine an estimate for the
                                          * memory consumption (in bytes)
                                          * of this object.
                                          */
        unsigned int memory_consumption () const;
    };

/**
 * Store the indices of degrees of freedom on faces in 3D, which are quads, additionaly also on lines.
 *
 * @ingroup dofs
 * @author Tobias Leicht, 2006
 */
    template<>
    class DoFFaces<3>
    {
      public:
					 /**
					  * The object containing the
					  * data of DoFs on lines.
					  */
	internal::DoFHandler::DoFObjects<1> lines;

					 /**
					  * The object containing the
					  * data of DoFs on quads.
					  */
	internal::DoFHandler::DoFObjects<2> quads;

					 /**
                                          * Determine an estimate for the
                                          * memory consumption (in bytes)
                                          * of this object.
                                          */
        unsigned int memory_consumption () const;
    };

  }
}

DEAL_II_NAMESPACE_CLOSE

#endif
