//---------------------------------------------------------------------------
//    $Id: tria_faces.h 15167 2007-09-08 01:38:16Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2006, 2007 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__tria_faces_h
#define __deal2__tria_faces_h

#include <base/config.h>
#include <grid/tria_object.h>
#include <grid/tria_objects.h>

DEAL_II_NAMESPACE_OPEN

namespace internal
{
  namespace Triangulation
  {
/**
 * General template for information belonging to the faces of a triangulation. These classes
 * are similar to the TriaLevel classes. As cells are organised in a hierarchical
 * structure of levels, each triangulation consists of several such TriaLevels. However the
 * faces of a triangulation, lower dimensional objects like lines in 2D or lines and quads
 * in 3D, do not have to be based on such a hierachical structure. In fact we have to
 * organise them in only one object if we want to enable anisotropic refinement. Therefore
 * the TriaFaces classes store the information belonging to the faces of a
 * triangualtion seperately from the TriaLevel classes.
 *
 * This general template is only provided to enable a specialisation below.
 *
 * @ingroup grid
 * @author Tobias Leicht, 2006
 */

    template<int dim>
    class TriaFaces
    {
      private:
					 /**
					  * Make the constructor private so no one can use
					  * this general template. Only the specializations
					  * should be used.
					  */
	TriaFaces();
    };
    
    

/**
 * Faces only have a meaning in <tt>dim@>=1</tt>. In <tt>dim=1</tt> they are vertices,
 * which are handled differently, so only for <tt>dim@>=2</tt> the use of TriaFaces
 * is reasonable, for <tt>dim=1</tt> the class is empty.
 * @ingroup grid
 */
    template<>
    class TriaFaces<1>
    {

      public:
					 /**
                                          * Determine an estimate for the
                                          * memory consumption (in bytes)
                                          * of this object.
					  * Of course this returns 0.
                                          */
        unsigned int memory_consumption () const;
    };

/**
 * In <tt>dim=2</tt> the cells are quads, the faces accordingly are lines. 
 * @ingroup grid
 */
    template<>
    class TriaFaces<2>
    {
      public:
					 /**
					  *  The TriaObject containing the data of lines.
					  */
	TriaObjects<TriaObject<1> > lines;

      public:
					 /**
                                          * Determine an estimate for the
                                          * memory consumption (in bytes)
                                          * of this object.
                                          */
        unsigned int memory_consumption () const;
    };
    
/**
 * In <tt>dim=3</tt> the cells are hexes, the faces accordingly are quads. In
 * addition to that we also have to enable the storage of lines.
 * @ingroup grid
 */	
    template<>
    class TriaFaces<3>
    {
      public:
					 /**
					  *  The TriaObject containing the data of quads.
					  */

	TriaObjectsQuad3D quads;

					 /**
					  *  The TriaObject containing the data of lines.
					  */
        TriaObjects<TriaObject<1> > lines;	    

      public:
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
