//---------------------------------------------------------------------------
//    $Id: data_out_faces.h 17390 2008-10-29 02:20:03Z bangerth $
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
#ifndef __deal2__data_out_faces_h
#define __deal2__data_out_faces_h


#include <base/config.h>
#include <numerics/data_out.h>

#include <string>
#include <vector>

DEAL_II_NAMESPACE_OPEN


/**
 * This class generates output from faces of a triangulation rather
 * than from cells, as do for example the DataOut and
 * DataOut_Rotation() classes. It might be used to generate output
 * only for the surface of the triangulation (this is the default of
 * this class), or for another arbitrary set of faces. The output of
 * this class is a set of patches (as defined by the class
 * DataOutBase::Patch()), one for each face for which output is to
 * be generated. These patches can then be written in several
 * graphical data formats by the functions of the underlying classes.
 *
 * <h3>Interface</h3>
 *
 * The interface of this class is copied from the DataOut
 * class. Furthermore, they share the common parent class
 * DataOut_DoFData. See the reference of these two classes for a
 * discussion of the interface.
 *
 *
 * <h3>Extending this class</h3>
 *
 * The sequence of faces to generate patches from is generated in the
 * same way as in the DataOut class, see there for a description
 * of the respective interface. For obvious reasons, the functions
 * generating the sequence of faces which shall be used to generate
 * output, are called @p first_face and @p next_face in this class,
 * rather than @p first_cell and @p next_cell.
 *
 * Since we need to initialize objects of type FEValues with the
 * faces generated from these functions, it is not sufficient that
 * they only return face iterators. Rather, we need a pair of cell and
 * the number of the face, as the values of finite element fields need
 * not necessarily be unique on a face (think of discontinuous finite
 * elements, where the value of the finite element field depend on the
 * direction from which you approach a face, thus it is necessary to
 * use a pair of cell and face, rather than only a face
 * iterator). Therefore, this class defines a @p typedef which
 * creates a type @p FaceDescriptor that is an abbreviation for a
 * pair of cell iterator and face number. The functions @p first_face
 * and @p next_face operate on objects of this type.
 *
 * Extending this class might, for example, be useful if you only want
 * output from certain portions of the boundary, e.g. as indicated by
 * the boundary indicator of the respective faces. However, it is also
 * conceivable that one generates patches not from boundary faces, but
 * from interior faces that are selected due to other criteria; one
 * application might be to use only those faces where one component of
 * the solution attains a certain value, in order to display the
 * values of other solution components on these faces. Other
 * applications certainly exist, for which the author is not
 * imaginative enough.
 *
 * @ingroup output
 * @author Wolfgang Bangerth, 2000
 */
template <int dim, class DH=DoFHandler<dim> >
class DataOutFaces : public DataOut_DoFData<DH,DH::dimension-1,
					    DH::dimension>
{
  public:
				     /**
				      * Typedef to the iterator type
				      * of the dof handler class under
				      * consideration.
				      */
    typedef typename DataOut_DoFData<DH,DH::dimension-1,
				     DH::dimension>::cell_iterator cell_iterator;

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
				      * The function supports
				      * multithreading, if deal.II is
				      * compiled in multithreading
				      * mode. The default number of
				      * threads to be used to build
				      * the patches is set to
				      * <tt>multithread_info.n_default_threads</tt>.
				      */
    virtual void
    build_patches (const unsigned int n_subdivisions = 0,
		   const unsigned int n_threads      = multithread_info.n_default_threads);

				     /**
				      * Declare a way to describe a
				      * face which we would like to
				      * generate output for. The usual
				      * way would, of course, be to
				      * use an object of type
				      * <tt>DoFHandler<dim>::face_iterator</tt>,
				      * but since we have to describe
				      * faces to objects of type
				      * FEValues, we can only
				      * represent faces by pairs of a
				      * cell and the number of the
				      * face. This pair is here
				      * aliased to a name that is
				      * better to type.
				      */
    typedef typename std::pair<cell_iterator,unsigned int> FaceDescriptor;
    
    
				     /**
				      * Return the first face which we
				      * want output for. The default
				      * implementation returns the
				      * first active face on the
				      * boundary, but you might want
				      * to return another face in a
				      * derived class.
				      */
    virtual FaceDescriptor first_face ();
    
				     /**
				      * Return the next face after
				      * @p face which we want output
				      * for.  If there are no more
				      * face, <tt>dofs->end()</tt> shall be
				      * returned as the first
				      * component of the return value.
				      *
				      * The default implementation
				      * returns the next active face
				      * on the boundary, but you might
				      * want to return other faces in
				      * a derived class. Note that the
				      * default implementation assumes
				      * that the given @p face is
				      * active, which is guaranteed as
				      * long as @p first_face is also
				      * used from the default
				      * implementation. Overloading
				      * only one of the two functions
				      * might not be a good idea.
				      */
    virtual FaceDescriptor next_face (const FaceDescriptor &face);

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
    DeclException0 (ExcCellNotActiveForCellData);
    
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
