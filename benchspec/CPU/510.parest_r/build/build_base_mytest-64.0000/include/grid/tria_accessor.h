//---------------------------------------------------------------------------
//    $Id: tria_accessor.h 18043 2008-12-29 22:11:48Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__tria_accessor_h
#define __deal2__tria_accessor_h


#include <base/config.h>
#include <base/exceptions.h>
#include <base/geometry_info.h>
#include <grid/tria_iterator_base.h>
#include <grid/tria_iterator_selector.h>


#if defined(SPEC)
# include <utility>
#else
namespace std
{
  template<class T1, class T2>
  struct pair;
}
#endif

DEAL_II_NAMESPACE_OPEN

template <int dim> class Point;

template <int dim, int spacedim> class Triangulation;
template <typename Accessor> class TriaRawIterator;
template <typename Accessor> class TriaIterator;
template <typename Accessor> class TriaActiveIterator;


namespace internal
{
  namespace Triangulation
  {
    template <int dim> class TriaObject;
    template <typename G> class TriaObjects;
    struct Implementation;
  }

  namespace TriaAccessor
  {
    struct Implementation;
  }
}
template <int celldim, int dim, int spacedim>	class TriaAccessor;
template <int dim, int spacedim>		class TriaAccessor<0, dim, spacedim>;

// note: the file tria_accessor.templates.h is included at the end of
// this file.  this includes a lot of templates. originally, this was
// only done in debug mode, but led to cyclic reduction problems and
// so is now on by default.


/**
 * A namespace that contains exception classes used by the accessor classes.
 */
namespace TriaAccessorExceptions
{
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcCellNotUsed);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcCellNotActive);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException1 (ExcInvalidNeighbor,
		  int,
		  << "Neighbor indices must be between 0 and 2^dim-1, but "
		  << "yours was " << arg1);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcCellHasNoChildren);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcUnusedCellAsChild);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException1 (ExcCantSetChildren,
		  int,
		  << "You can only set the child index if the cell has no "
		  << "children, or clear it. The given "
		  << "index was " << arg1 << " (-1 means: clear children)");
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcUnusedCellAsNeighbor);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcUncaughtCase);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcDereferenceInvalidObject);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcCantCompareIterators);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcNeighborIsCoarser);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcNeighborIsNotCoarser);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException0 (ExcFacesHaveNoLevel);
				   /**
				    * @ingroup Exceptions
				    */
  DeclException1 (ExcSetOnlyEvenChildren,
		  int,
		  << "You can only set the child index of an even numbered child."
		  << "The number of the child given was " << arg1 << ".");    
}


/**
 * A base class for the accessor classes used by TriaRawIterator and
 * derived classes.
 *
 * This class offers only the basic functionality required by the
 * iterators (stores the necessary data members, offers comparison
 * operators and the like), but has no functionality to actually
 * dereference data. This is done in the derived classes.
 *
 * This template is used for faces and edges, which have no level in
 * the triangulation hierarchy associated with them. There exists a
 * partial specialization of the current class template where
 * <tt>structdim</tt> (the dimensionality of the object represented,
 * for example 1 for a line) equals <tt>dim</tt> (the dimensionality
 * of the space the object lives in, for example 3 if we solve
 * three-dimensional problems).
 *
 * Some internals of this class are discussed in @ref IteratorAccessorInternals .
 *
 * @ingroup grid
 * @ingroup Accessors
 * @author Wolfgang Bangerth, 1998
 */
template <int structdim, int dim, int spacedim=dim>
class TriaAccessorBase
{
  protected:
				     /**
				      * Declare the data type that
				      * this accessor class expects to
				      * get passed from the iterator
				      * classes. Since the pure
				      * triangulation iterators need
				      * no additional data, this data
				      * type is @p void.
				      */
    typedef void AccessorData;

				     /**
				      *  Constructor. Protected, thus
				      *  only callable from friend
				      *  classes.
				      */
    TriaAccessorBase (const Triangulation<dim,spacedim> *parent =  0,
		      const int                 level  = -1,
		      const int                 index  = -1,
		      const AccessorData       *       =  0);

				     /**
				      *  Copy operator. Since this is
				      *  only called from iterators,
				      *  do not return anything, since
				      *  the iterator will return
				      *  itself.
				      *
				      *  This method is protected,
				      *  since it is only to be called
				      *  from the iterator class.
				      */
    void copy_from (const TriaAccessorBase &);

				     /**
				      *  Copy operator. This is normally
				      *  used in a context like
				      *  <tt>iterator a,b;  *a=*b;</tt>. Since
				      *  the meaning is to copy the object
				      *  pointed to by @p b to the object
				      *  pointed to by @p a and since
				      *  accessors are not real but
				      *  virtual objects, this operation
				      *  is not useful for iterators on
				      *  triangulations. We declare this
				      *  function here private, thus it may
				      *  not be used from outside.
				      *  Furthermore it is not implemented
				      *  and will give a linker error if
				      *  used anyway.
				      */
    void operator = (const TriaAccessorBase *);
    
				     /**
				      *  Same as above.
				      */
    TriaAccessorBase & operator = (const TriaAccessorBase &);

				     /**
				      *  Compare for equality.            
				      */
    bool operator == (const TriaAccessorBase &) const;
	
				     /**
				      * Compare for inequality.
				      */
    bool operator != (const TriaAccessorBase &) const;

				     /**
				      * @name Advancement of iterators
				      */
				     /**
				      * @{
				      */
				     /**
				      *  This operator advances the
				      *  iterator to the next element.
				      *
				      *  For @p dim=1 only:
				      *  The next element is next on
				      *  this level if there are
				      *  more. If the present element
				      *  is the last on this level,
				      *  the first on the next level
				      *  is accessed.
				      */
    void operator ++ ();

    				     /**
				      *  This operator moves the
				      *  iterator to the previous
				      *  element.
				      *
				      *  For @p dim=1 only:
				      *  The previous element is
				      *  previous on this level if
				      *  <tt>index>0</tt>. If the present
				      *  element is the first on this
				      *  level, the last on the
				      *  previous level is accessed.
				      */
    void operator -- ();
				     /**
				      * @}
				      */
    
				     /**
				      * Access to the other objects of
				      * a Triangulation with same
				      * dimension.
				      */
    internal::Triangulation::TriaObjects<internal::Triangulation::TriaObject<structdim> > &
    objects () const;
    
  public:
				     /**
				      * Data type to be used for passing
				      * parameters from iterators to the
				      * accessor classes in a unified
				      * way, no matter what the type of
				      * number of these parameters is.
				      */
    typedef void * LocalData;
    
				     /**
				      * @name Iterator address and state
				      */
				     /**
				      * @{
				      */

				     /**
				      *  Return the level the element
				      *  pointed to belongs to.
				      *  This is only valid for cells.
				      */
    static int level ();
    
				     /**
				      *  Return the index of the
				      *  element presently pointed to
				      *  on the present level.
				      */
    int index () const;
    
				     /**
				      *  Return the state of the
				      *  iterator.  For the different
				      *  states an accessor can be in,
				      *  refer to the
				      *  TriaRawIterator
				      *  documentation.
				      */
    IteratorState::IteratorStates state () const;

				     /**
				      * Return a pointer to the
				      * triangulation which the object
				      * pointed to by this class
				      * belongs to.
				      */
    const Triangulation<dim,spacedim> & get_triangulation () const;
    
				     /**
				      * @}
				      */
  protected:

				     /**
				      *  Used to store the index of
				      *  the element presently pointed
				      *  to on the level presentl
				      *  used.
				      */
    int present_index;
    
				     /**
				      *  Pointer to the triangulation
				      *  which we act on.
				      */
    const Triangulation<dim,spacedim> *tria;
    
  private:
    
				     /**
				      *  Space dimension of the Accessor
				      */  
    static const unsigned int space_dimension = spacedim; 

    static const unsigned int dimension = dim;

    static const unsigned int structure_dimension = structdim;

    template <typename Accessor> friend class TriaRawIterator;
    template <typename Accessor> friend class TriaIterator;
    template <typename Accessor> friend class TriaActiveIterator;
};



/**
 * A base class for the accessor classes used by TriaRawIterator and
 * derived classes.
 *
 * This class offers only the basic functionality required by the
 * iterators (stores the necessary data members, offers comparison
 * operators and the like), but has no functionality to actually
 * dereference data. This is done in the derived classes.
 *
 * This template is a partial specialization of the general template
 * used for cells only, i.e. for the case where <tt>structdim</tt>
 * (the dimensionality of the object represented, for example 1 for a
 * line) equals <tt>dim</tt> (the dimensionality of the triangulation
 * the object lives in, for example 2 if we solve problems on a
 * two-dimensional manifold -- whether this manifold is itself the
 * space $R^2$ or embedded in a higher-dimensional space whose
 * dimensionality is determined by the <code>spacedim</code> template
 * argument). The reason for using a partial specialization rather
 * than the general template is that cells have a level in the
 * triangulation hierarchy associated with them, whereas faces and
 * edges do not.
 *
 * Some internals of this class are discussed in @ref IteratorAccessorInternals .
 *
 * @ingroup grid
 * @ingroup Accessors
 * @author Wolfgang Bangerth, 1998
 */
template <int dim, int spacedim>
class TriaAccessorBase<dim,dim,spacedim>
{
  protected:
				     /**
				      * Declare the data type that
				      * this accessor class expects to
				      * get passed from the iterator
				      * classes. Since the pure
				      * triangulation iterators need
				      * no additional data, this data
				      * type is @p void.
				      */
    typedef void AccessorData;

				     /**
				      *  Constructor. Protected, thus
				      *  only callable from friend
				      *  classes.
				      */
    TriaAccessorBase (const Triangulation<dim,spacedim> *parent =  0,
		      const int                 level  = -1,
		      const int                 index  = -1,
		      const AccessorData       *       =  0);

				     /**
				      *  Copy operator. Since this is
				      *  only called from iterators,
				      *  do not return anything, since
				      *  the iterator will return
				      *  itself.
				      *
				      *  This method is protected,
				      *  since it is only to be called
				      *  from the iterator class.
				      */
    void copy_from (const TriaAccessorBase &);

				     /**
				      *  Copy operator. This is normally
				      *  used in a context like
				      *  <tt>iterator a,b;  *a=*b;</tt>. Since
				      *  the meaning is to copy the object
				      *  pointed to by @p b to the object
				      *  pointed to by @p a and since
				      *  accessors are not real but
				      *  virtual objects, this operation
				      *  is not useful for iterators on
				      *  triangulations. We declare this
				      *  function here private, thus it may
				      *  not be used from outside.
				      *  Furthermore it is not implemented
				      *  and will give a linker error if
				      *  used anyway.
				      */
    void operator = (const TriaAccessorBase *);
        
				     /**
				      *  Same as above.
				      */
    TriaAccessorBase & operator = (const TriaAccessorBase &);

				     /**
				      * @name Advancement of iterators
				      */
				     /**
				      * @{
				      */
    
				     /**
				      *  This operator advances the
				      *  iterator to the next element.
				      *
				      *  For cells only:
				      *  The next element is next on
				      *  this level if there are
				      *  more. If the present element
				      *  is the last on this level,
				      *  the first on the next level
				      *  is accessed.
				      */
    void operator ++ ();

    				     /**
				      *  This operator moves the
				      *  iterator to the previous
				      *  element.
				      *
				      *  For cells only:
				      *  The previous element is
				      *  previous on this level if
				      *  <tt>index>0</tt>. If the present
				      *  element is the first on this
				      *  level, the last on the
				      *  previous level is accessed.
				      */
    void operator -- ();

				     /**
				      * Access to the other objects of
				      * a Triangulation with same
				      * dimension.
				      */
    internal::Triangulation::TriaObjects<internal::Triangulation::TriaObject<dim> > &
    objects () const;

  protected:
    
				     /**
				      *  Compare for equality.            
				      */
    bool operator == (const TriaAccessorBase &) const;
	
				     /**
				      * Compare for inequality.
				      */
    bool operator != (const TriaAccessorBase &) const;

  public:
				     /**
				      * Data type to be used for passing
				      * parameters from iterators to the
				      * accessor classes in a unified
				      * way, no matter what the type of
				      * number of these parameters is.
				      */
    typedef void * LocalData;
    
				     /** @name Iterator address and state
				      */
				     /**
				      * @{
				      */
				     /**
				      *  Return the level the element
				      *  pointed to belongs to.
				      *  This is only valid for cells.
				      */
    int level () const;
    
				     /**
				      *  Return the index of the
				      *  element presently pointed to
				      *  on the present level.
				      */
    int index () const;
    
				     /**
				      *  Return the state of the
				      *  iterator.  For the different
				      *  states an accessor can be in,
				      *  refer to the
				      *  TriaRawIterator
				      *  documentation.
				      */
    IteratorState::IteratorStates state () const;

				     /**
				      * Return a pointer to the
				      * triangulation which the object
				      * pointed to by this class
				      * belongs to.
				      */
    const Triangulation<dim,spacedim> & get_triangulation () const;
    
				     /**
				      * @}
				      */
  protected:
				     /**
				      *  Used to store the level
				      *  presently pointed to. For
				      *  faces this should always be
				      *  0.
				      */
    int present_level;
    
				     /**
				      *  Used to store the index of
				      *  the element presently pointed
				      *  to on the level presentl
				      *  used.
				      */
    int present_index;
    
				     /**
				      *  Pointer to the triangulation
				      *  which we act on.
				      */
    const Triangulation<dim,spacedim> *tria;

				     /**
				      *  Space dimension of the Accessor
				      */  
    static const unsigned int space_dimension = spacedim; 

    static const unsigned int dimension = dim;

    static const unsigned int structure_dimension = dim;

  private:
    
    template <typename Accessor> friend class TriaRawIterator;
    template <typename Accessor> friend class TriaIterator;
    template <typename Accessor> friend class TriaActiveIterator;

    template <int, int, int> friend class TriaAccessor;
};


/**
 * A class that represents accessor objects to iterators that don't
 * make sense such as quad iterators in on 1d meshes.  This class can
 * not be used to create objects (it will in fact throw an exception
 * if this should ever be attempted but it sometimes allows code to be
 * written in a simpler way in a dimension independent way. For
 * example, it allows to write code that works on quad iterators that
 * is dimension independent because quad iterators (with the current
 * class) exist and are syntactically correct. You can not expect,
 * however, to ever generate one of these iterators, meaning you need
 * to expect to wrap the code block in which you use quad iterators
 * into something like <code>if (dim@>1)</code> -- which makes eminent
 * sense anyway.
 *
 * This class provides the minimal interface necessary for Accessor
 * classes to interact with Iterator classes. However, this is only
 * for syntactic correctness, none of the functions do anything but
 * generate errors.
 *
 * @author Wolfgang Bangerth, 2008
 */
template <int structdim, int dim, int spacedim=dim>
class InvalidAccessor :  public TriaAccessorBase<structdim,dim,spacedim>
{
  public:
				     /**
				      * Propagate typedef from
				      * base class to this class.
				      */
    typedef typename TriaAccessorBase<structdim,dim,spacedim>::AccessorData AccessorData;

				     /**
				      * Constructor.  This class is
				      * used for iterators that make
				      * sense in a given dimension,
				      * for example quads for 1d
				      * meshes. Consequently, while
				      * the creation of such objects
				      * is syntactically valid, they
				      * make no semantic sense, and we
				      * generate an exception when
				      * such an object is actually
				      * generated.
				      */
    InvalidAccessor (const Triangulation<dim,spacedim> *parent     =  0,
		     const int                 level      = -1,
		     const int                 index      = -1,
		     const AccessorData       *local_data =  0);
    
				     /**
				      * Copy constructor.  This class
				      * is used for iterators that
				      * make sense in a given
				      * dimension, for example quads
				      * for 1d meshes. Consequently,
				      * while the creation of such
				      * objects is syntactically
				      * valid, they make no semantic
				      * sense, and we generate an
				      * exception when such an object
				      * is actually generated.
				      */
    InvalidAccessor (const InvalidAccessor &);

				     /**
				      * Conversion from other
				      * accessors to the current
				      * invalid one. This of course
				      * also leads to a run-time
				      * error.
				      */
    template <typename OtherAccessor>
    InvalidAccessor (const OtherAccessor &);
    
				     /**
				      * Dummy copy operation.
				      */
    void copy_from (const InvalidAccessor &);

				     /**
				      * Dummy comparison operators.
				      */
    bool operator == (const InvalidAccessor &) const;
    bool operator != (const InvalidAccessor &) const;

				     /**
				      * Dummy operators to make things
				      * compile. Does nothing.
				      */
    void operator ++ () const;
    void operator -- () const;
    
				     /**
				      * Dummy function representing
				      * whether the accessor points to
				      * a used or an unused object.
				      */
    bool used () const;

				     /**
				      * Dummy function representing
				      * whether the accessor points to
				      * an object that has children.
				      */
    bool has_children () const;
};



/**
 * A class that provides access to objects in a triangulation such as
 * its vertices, sub-objects, children, geometric information, etc.
 * This class represents objects of dimension <code>structdim</code>
 * (i.e. 1 for lines, 2 for quads, 3 for hexes) in a triangulation of
 * dimensionality <code>dim</code> (i.e. 1 for a triangulation of
 * lines, 2 for a triangulation of quads, and 3 for a triangulation of
 * hexes) that is embedded in a space of dimensionality
 * <code>spacedim</code> (for <code>spacedim==dim</code> the
 * triangulation represents a domain in $R^{dim}$, for
 * <code>spacedim@>dim</code> the triangulation is of a manifold
 * embedded in a higher dimensional space).
 *
 * @author Wolfgang Bangerth and others, 1998, 2000, 2008
 */
template <int structdim, int dim, int spacedim>
class TriaAccessor : public TriaAccessorBase<structdim, dim, spacedim>
{
  public:
				     /**
				      * Propagate typedef from
				      * base class to this class.
				      */
    typedef
    typename TriaAccessorBase<structdim,dim,spacedim>::AccessorData
    AccessorData;

				     /**
				      *  Constructor.
				      */
    TriaAccessor (const Triangulation<dim,spacedim> *parent     =  0,
		  const int                 level      = -1,
		  const int                 index      = -1,
		  const AccessorData       *local_data =  0);

				     /**
				      * Conversion constructor. This
				      * constructor exists to make certain
				      * constructs simpler to write in
				      * dimension independent code. For
				      * example, it allows assigning a face
				      * iterator to a line iterator, an
				      * operation that is useful in 2d but
				      * doesn't make any sense in 3d. The
				      * constructor here exists for the
				      * purpose of making the code conform to
				      * C++ but it will unconditionally abort;
				      * in other words, assigning a face
				      * iterator to a line iterator is better
				      * put into an if-statement that checks
				      * that the dimension is two, and assign
				      * to a quad iterator in 3d (an operator
				      * that, without this constructor would
				      * be illegal if we happen to compile for
				      * 2d).
				      */
    template <int structdim2, int dim2, int spacedim2>
    TriaAccessor (const InvalidAccessor<structdim2,dim2,spacedim2> &);

				     /**
				      * Another conversion operator
				      * between objects that don't
				      * make sense, just like the
				      * previous one.
				      */
    template <int structdim2, int dim2, int spacedim2>
    TriaAccessor (const TriaAccessor<structdim2,dim2,spacedim2> &);
    
				     /**
				      *  Test for the element being
				      *  used or not.  The return
				      *  value is @p true for all
				      *  iterators that are either
				      *  normal iterators or active
				      *  iterators, only raw iterators
				      *  can return @p false. Since
				      *  raw iterators are only used
				      *  in the interiors of the
				      *  library, you will not usually
				      *  need this function.
				      */
    bool used () const;


				     /**
				      *  @name Accessing sub-objects
				      */
				     /**
				      * @{
				      */
    
				     /**
				      *  Return the global index of i-th
				      *  vertex of the current object. The
				      *  convention regarding the numbering of
				      *  vertices is laid down in the
				      *  documentation of the GeometryInfo
				      *  class.
				      *
				      *  Note that the returned value is only
				      *  the index of the geometrical
				      *  vertex. It has nothing to do with
				      *  possible degrees of freedom
				      *  associated with it. For this, see the
				      *  @p DoFAccessor::vertex_dof_index
				      *  functions.
				      */ 
    unsigned int vertex_index (const unsigned int i) const;

				     /**
				      *  Return a reference to the
				      *  @p ith vertex.
				      */
    Point<spacedim> & vertex (const unsigned int i) const;

				     /**
				      * Pointer to the @p ith line
				      * bounding this object.
				      */
    typename internal::Triangulation::Iterators<dim,spacedim>::line_iterator
    line (const unsigned int i) const;

				     /**
				      * Line index of the @p ith
				      * line bounding this object.
				      *
				      * Implemented only for
				      * <tt>structdim>1</tt>,
				      * otherwise an exception
				      * generated.
				      */
    unsigned int line_index (const unsigned int i) const;
    
    				     /**
				      * Pointer to the @p ith quad
				      * bounding this object.
				      */
    typename internal::Triangulation::Iterators<dim,spacedim>::quad_iterator
    quad (const unsigned int i) const;

				     /**
				      * Quad index of the @p ith
				      * quad bounding this object.
				      *
				      * Implemented only for
				      * <tt>structdim>2</tt>,
				      * otherwise an exception
				      * generated.
				      */
    unsigned int quad_index (const unsigned int i) const;
				     /**
				      * @}
				      */

				     /**
				      *  @name Orientation of sub-objects
				      */
				     /**
				      * @{
				      */

                                     /**
                                      * Return whether the face with
                                      * index @p face has its normal
                                      * pointing in the standard
                                      * direction (@p true) or
                                      * whether it is the opposite
                                      * (@p false). Which is the
                                      * standard direction is
                                      * documented with the
                                      * GeometryInfo class. In
                                      * 1d and 2d, this is always
                                      * @p true, but in 3d it may be
                                      * different, see the respective
                                      * discussion in the
                                      * documentation of the
                                      * GeometryInfo class.
                                      *
                                      * This function is really only
                                      * for internal use in the
                                      * library unless you absolutely
                                      * know what this is all about.
                                      */
    bool face_orientation (const unsigned int face) const;

                                     /**
                                      * Return whether the face with index @p
                                      * face is rotated by 180 degrees (@p true)
                                      * or or not (@p false). In 1d and 2d, this
                                      * is always @p false, but in 3d it may be
                                      * different, see the respective discussion
                                      * in the documentation of the
                                      * GeometryInfo class.
                                      *
                                      * This function is really only
                                      * for internal use in the
                                      * library unless you absolutely
                                      * know what this is all about.
                                      */
    bool face_flip (const unsigned int face) const;

                                     /**
                                      * Return whether the face with index @p
                                      * face is rotated by 90 degrees (@p true)
                                      * or or not (@p false). In 1d and 2d, this
                                      * is always @p false, but in 3d it may be
                                      * different, see the respective discussion
                                      * in the documentation of the
                                      * GeometryInfo class.
                                      *
                                      * This function is really only
                                      * for internal use in the
                                      * library unless you absolutely
                                      * know what this is all about.
                                      */
    bool face_rotation (const unsigned int face) const;

                                     /**
                                      * Return whether the line with index @p
                                      * line is oriented in standard
                                      * direction. @p true indicates, that the
                                      * line is oriented from vertex 0 to vertex
                                      * 1, whereas it is the other way around
                                      * otherwise. In 1d and 2d, this is always
                                      * @p true, but in 3d it may be different,
                                      * see the respective discussion in the
                                      * documentation of the 
                                      * GeometryInfo classe.
                                      *
                                      * This function is really only
                                      * for internal use in the
                                      * library unless you absolutely
                                      * know what this is all about.
                                      */
    bool line_orientation (const unsigned int line) const;
				     /**
				      * @}
				      */
    
				     /**
				      *  @name Accessing children
				      */
				     /**
				      * @{
				      */

				     /**
				      *  Test whether the object has
				      *  children.
				      */
    bool has_children () const;

				     /**
				      * Return the number of immediate
				      * children of this object. The
				      * number of children of an
				      * unrefined cell is zero.
				      */
    unsigned int n_children() const;

				     /**
				      * Compute and return the number
				      * of active descendants of this
				      * objects. For example, if all
				      * of the eight children of a hex
				      * are further refined
				      * isotropically exactly once,
				      * the returned number will be
				      * 64, not 80.
				      *
				      * If the present cell is not
				      * refined, one is returned.
				      *
				      * If one considers a triangulation as a
				      * forest where the root of each tree are
				      * the coarse mesh cells and nodes have
				      * descendents (the children of a cell),
				      * then this function returns the number
				      * of terminal nodes in the sub-tree
				      * originating from the current object;
				      * consequently, if the current object is
				      * not further refined, the answer is
				      * one.
				      */
    unsigned int number_of_children () const;

				     /**
				      * Return the number of times
				      * that this object is
				      * refined. Note that not all its
				      * children are refined that
				      * often (which is why we prepend
				      * @p max_), the returned number
				      * is rather the maximum number
				      * of refinement in any branch of
				      * children of this object.
				      *
				      * For example, if this object is
				      * refined, and one of its children is
				      * refined exactly one more time, then
				      * <tt>max_refinement_depth</tt> should
				      * return 2.
				      *
				      * If this object is not refined (i.e. it
				      * is active), then the return value is
				      * zero.
				      */
    unsigned int max_refinement_depth () const;
    
				     /**
				      *  Return an iterator to the @p ith
				      *  child.
				      */
    TriaIterator<TriaAccessor<structdim,dim,spacedim> >
    child (const unsigned int i) const;

				     /**
				      *  Return an iterator to that object
				      *  that is identical to the ith child
				      *  for isotropic refinement. If the
				      *  current object is refined
				      *  isotropically, then the returned
				      *  object is the ith child. If the
				      *  current object is refined
				      *  anisotropically, the returned child
				      *  may in fact be a grandchild of the
				      *  object, or may not exist at all (in
				      *  which case an exception is
				      *  generated).
				      */
    TriaIterator<TriaAccessor<structdim,dim,spacedim> >
    isotropic_child (const unsigned int i) const;

				     /**
				      * Return the RefinementCase
				      * of this cell.
				      */
    RefinementCase<structdim> refinement_case() const;

				     /**
				      *  Index of the @p ith child.
				      *  The level of the child is one
				      *  higher than that of the
				      *  present cell, if the children
				      *  of a cell are accessed. The
				      *  children of faces have no level.
				      *  If the child does not exist, -1
				      *  is returned.
				      */
    int child_index (const unsigned int i) const;

				     /**
				      *  Index of the @p ith isotropic child.
				      *  See the isotropic_child() function
				      *  for a definition of this concept.  If
				      *  the child does not exist, -1 is
				      *  returned.
				      */
    int isotropic_child_index (const unsigned int i) const;    
				     /**
				      * @}
				      */

				     /**
				      *  @name Dealing with boundary indicators
				      */
				     /**
				      * @{
				      */
    
				     /**
				      * Boundary indicator of this
				      * object.
				      *
				      * If the return value is the special
				      * value 255, then this object is in the
				      * interior of the domain.
				      */
    unsigned char boundary_indicator () const;

				     /**
				      * Set the boundary indicator.
				      * The same applies as for the
				      * <tt>boundary_indicator()</tt>
				      * function.
				      *
				      * Note that it only sets the
				      * boundary object of the current
				      * object itself, not the
				      * indicators of the ones that
				      * bound it. For example, in 3d,
				      * if this function is called on
				      * a face, then the boundary
				      * indicator of the 4 edges that
				      * bound the face remain
				      * unchanged. If you want to set
				      * the boundary indicators of
				      * face and edges at the same
				      * time, use the
				      * set_all_boundary_indicators()
				      * function.
				      *
				      * @warning You should never set the
				      * boundary indicator of an interior face
				      * (a face not at the boundary of the
				      * domain), or set set the boundary
				      * indicator of an exterior face to 255
				      * (this value is reserved for another
				      * purpose). Algorithms may not work or
				      * produce very confusing results if
				      * boundary cells have a boundary
				      * indicator of 255 or if interior cells
				      * have boundary indicators other than
				      * 255. Unfortunately, the current object
				      * has no means of finding out whether it
				      * really is at the boundary of the
				      * domain and so cannot determine whether
				      * the value you are trying to set makes
				      * sense under the current circumstances.
				      */
    void set_boundary_indicator (const unsigned char) const;

				     /**
				      * Do as set_boundary_indicator()
				      * but also set the boundary
				      * indicators of the objects that
				      * bound the current object. For
				      * example, in 3d, if
				      * set_boundary_indicator() is
				      * called on a face, then the
				      * boundary indicator of the 4
				      * edges that bound the face
				      * remain unchanged. On the other
				      * hand, the boundary indicators
				      * of face and edges are all set
				      * at the same time using the
				      * current function.
				      */
    void set_all_boundary_indicators (const unsigned char) const;
    
				     /**
				      * Return whether this object is at the
				      * boundary. Obviously, the use of this
				      * function is only possible for
				      * <tt>dim@>structdim</tt>; however, for
				      * <tt>dim==celldim</tt>, an object is a
				      * cell and the CellAccessor class offers
				      * another possibility to determine
				      * whether a cell is at the boundary or
				      * not.
				      */
    bool at_boundary () const;

				     /**
				      * @}
				      */
    

				     /**
				      * @name User data
				      */
				     /**
				      * @{
				      */
    				     /**
				      *  Read the user flag.
				      */
    bool user_flag_set () const;

				     /**
				      *  Set the user flag.
				      */
    void set_user_flag () const;

				     /**
				      *  Clear the user flag.
				      */
    void clear_user_flag () const;

				     /**
				      *  Set the user flag for this
				      * and all descendants.
				      */
    void recursively_set_user_flag () const;

    				     /**
				      *  Clear the user flag for this
				      * and all descendants. 
				      */
    void recursively_clear_user_flag () const;

				     /**
				      * Reset the user data to zero,
				      * independent if pointer or index.
				      */
    void clear_user_data () const;
    
				     /**
				      * Set the user pointer
				      * to @p p.
				      */
    void set_user_pointer (void *p) const;

				     /**
				      * Reset the user pointer
				      * to a @p NULL pointer.
				      */
    void clear_user_pointer () const;
    
				     /**
				      * Access the value of the user
				      * pointer. It is in the
				      * responsibility of the user to
				      * make sure that the pointer
				      * points to something
				      * useful. You should use the new
				      * style cast operator to
				      * maintain a minimum of
				      * typesafety, e.g.
				      * <tt>A *a=static_cast<A*>(cell->user_pointer());</tt>.
				      */
    void * user_pointer () const;

				     /**
				      * Set the user pointer of this
				      * object and all its children to
				      * the given value. This is
				      * useful for example if all
				      * cells of a certain subdomain,
				      * or all faces of a certain part
				      * of the boundary should have
				      * user pointers pointing to
				      * objects describing this part
				      * of the domain or boundary.
				      *
				      * Note that the user pointer is
				      * not inherited under mesh
				      * refinement, so after mesh
				      * refinement there might be
				      * cells or faces that don't have
				      * user pointers pointing to the
				      * describing object. In this
				      * case, simply loop over all the
				      * elements of the coarsest level
				      * that has this information, and
				      * use this function to
				      * recursively set the user
				      * pointer of all finer levels of
				      * the triangulation.
				      */
    void recursively_set_user_pointer (void *p) const;
    
				     /**
				      * Clear the user pointer of this
				      * object and all of its
				      * descendants. The same holds as
				      * said for the
				      * recursively_set_user_pointer()
				      * function.
				      */
    void recursively_clear_user_pointer () const;
    
				     /**
				      * Set the user index
				      * to @p p.
				      */
    void set_user_index (const unsigned int p) const;
    
				     /**
				      * Reset the user index to 0.
				      */
    void clear_user_index () const;
    
				     /**
				      * Access the value of the user
				      * index.
				      */
    unsigned int user_index () const;

				     /**
				      * Set the user index of this
				      * object and all its children.
				      *
				      * Note that the user index is
				      * not inherited under mesh
				      * refinement, so after mesh
				      * refinement there might be
				      * cells or faces that don't have
				      * the expected user indices. In
				      * this case, simply loop over
				      * all the elements of the
				      * coarsest level that has this
				      * information, and use this
				      * function to recursively set
				      * the user index of all finer
				      * levels of the triangulation.
				      */
    void recursively_set_user_index (const unsigned int p) const;

				     /**
				      * Clear the user index of this
				      * object and all of its
				      * descendants. The same holds as
				      * said for the
				      * recursively_set_user_index()
				      * function.
				      */
    void recursively_clear_user_index () const;
				     /**
				      * @}
				      */
    
				     /**
				      * @name Geometric information about an object
				      */
				     /**
				      * @{
				      */

				     /**
				      * Diameter of the object.
				      *
				      * The diameter of an object is computed
				      * to be the largest diagonal. This is
				      * not necessarily the true diameter for
				      * objects that may use higher order
				      * mappings, but completely sufficient
				      * for most computations.
				      */
    double diameter () const;

    				     /**
				      * Center of the object. The center of an
				      * object is defined to be the average of
				      * the locations of the vertices, which
				      * is also where the (dim-)linear mapping
				      * places the midpoint of the unit cell
				      * in real space.  However, this may not
				      * be the barycenter of the object and it
				      * may also not be the true center of an
				      * object if higher order mappings are
				      * used.
				      */
    Point<spacedim> center () const;

				     /**
				      * Barycenter of the object.
				      */
    Point<spacedim> barycenter () const;

				     /**
				      * Volume of the object.  Here, the
				      * volume is defined to be confined by
				      * the (dim-)linear mapping of the unit
				      * cell.  No information about the actual
				      * geometric boundary of the domain is
				      * used.
				      */
    double measure () const;
				     /**
				      * @}
				      */
    
    
  private:
				     /**
				      *  Copy the data of the given
				      *  object into the internal data
				      *  structures of a
				      *  triangulation.
				      */
    void set (const internal::Triangulation::TriaObject<structdim> &o) const;
    
                                     /**
                                      * Set the flag indicating, what
                                      * <code>line_orientation()</code> will
                                      * return.
				      *
				      * It is only possible to set the
				      * line_orientation of faces in 3d
				      * (i.e. <code>celldim==2 &&
				      * dim==3</code>).
                                      */
    void set_line_orientation (const unsigned int line,
                               const bool         orientation) const;
    
                                     /**
                                      * Set whether the quad with
                                      * index @p face has its normal
                                      * pointing in the standard
                                      * direction (@p true) or
                                      * whether it is the opposite
                                      * (@p false). Which is the
                                      * standard direction is
                                      * documented with the
                                      * GeometryInfo class.
                                      *
                                      * This function is only for
                                      * internal use in the
                                      * library. Setting this flag to
                                      * any other value than the one
                                      * that the triangulation has
                                      * already set is bound to bring
                                      * you desaster.
                                      */
    void set_face_orientation (const unsigned int face,
                               const bool         orientation) const;

				     /**
                                      * Set the flag indicating, what
                                      * <code>face_flip()</code> will
                                      * return.
				      *
				      * It is only possible to set the
				      * face_orientation of cells in 3d
				      * (i.e. <code>celldim==3 &&
				      * dim==3</code>).
                                      */
    void set_face_flip (const unsigned int face,
			const bool         flip) const;

				     /**
                                      * Set the flag indicating, what
                                      * <code>face_rotation()</code> will
                                      * return.
				      *
				      * It is only possible to set the
				      * face_orientation of cells in 3d
				      * (i.e. <code>celldim==3 &&
				      * dim==3</code>).
                                      */
    void set_face_rotation (const unsigned int face,
			    const bool         rotation) const;
    
				     /**
				      *  Set the @p used flag. Only
				      *  for internal use in the
				      *  library.
				      */
    void set_used_flag () const;

				     /**
				      *  Clear the @p used flag. Only
				      *  for internal use in the
				      *  library.
				      */
    void clear_used_flag () const;

				     /**
				      * Set the @p RefinementCase<dim> this
				      * TriaObject is refined with.
				      * Not defined for
				      * <tt>celldim=1</tt> as lines
				      * are always refined resulting
				      * in 2 children lines (isotropic
				      * refinement).
				      *
				      * You should know quite exactly
				      * what you are doing if you
				      * touch this function. It is
				      * exclusively for internal use
				      * in the library.
				      */
    void set_refinement_case (const RefinementCase<structdim> &ref_case) const;

				     /**
				      * Clear the RefinementCase<dim> of
				      * this TriaObject, i.e. reset it
				      * to RefinementCase<dim>::no_refinement.
				      *
				      * You should know quite exactly
				      * what you are doing if you
				      * touch this function. It is
				      * exclusively for internal use
				      * in the library.
				      */
    void clear_refinement_case () const;

				     /**
				      *  Set the index of the ith
				      *  child. Since the children
				      *  come at least in pairs, we
				      *  need to store the index of
				      *  only every second child,
				      *  i.e. of the even numbered
				      *  children. Make sure, that the
				      *  index of child i=0 is set
				      *  first. Calling this function
				      *  for odd numbered children is
				      *  not allowed.
				      */
    void set_children (const unsigned int i, const int index) const;
	
				     /**
				      *  Clear the child field,
				      *  i.e. set it to a value which
				      *  indicates that this cell has
				      *  no children.
				      */
    void clear_children () const;    

  private:
    				     /**
				      *  Copy operator. This is normally used
				      *  in a context like <tt>iterator a,b;
				      *  *a=*b;</tt>. Presumably, the intent
				      *  here is to copy the object pointed to
				      *  by @p b to the object pointed to by
				      *  @p a. However, the result of
				      *  dereferencing an iterator is not an
				      *  object but an accessor; consequently,
				      *  this operation is not useful for
				      *  iterators on triangulations. We
				      *  declare this function here private,
				      *  thus it may not be used from outside.
				      *  Furthermore it is not implemented and
				      *  will give a linker error if used
				      *  anyway.
				      */
    void operator = (const TriaAccessor &);
    
    template <int, int> friend class Triangulation;

    friend class internal::Triangulation::Implementation;
    friend class internal::TriaAccessor::Implementation;
};






/**
 * Closure class to stop induction of classes. Should never be called
 * and thus produces an error when created.
 *
 * @ingroup grid
 */
template<int dim, int spacedim>
class TriaAccessor<0, dim, spacedim> : public TriaAccessorBase<0,dim, spacedim>
{
  public:
				     /**
				      * Propagate typedef from
				      * base class to this class.
				      */
    typedef typename TriaAccessorBase<0,dim,spacedim>::AccessorData AccessorData;

				     /**
				      * Constructor. Should never be
				      * called and thus produces an
				      * error.
				      */
    TriaAccessor (const Triangulation<dim,spacedim> *parent     =  0,
		  const int                 level      = -1,
		  const int                 index      = -1,
		  const AccessorData       *local_data =  0)
                    :
		    TriaAccessorBase<0,dim, spacedim> (parent, level, index, local_data)
      {
	Assert (false, ExcInternalError());
      }

				     /**
				      * Constructor. Should never be
				      * called and thus produces an
				      * error.
				      */
    template <int structdim2, int dim2, int spacedim2>
    TriaAccessor (const TriaAccessor<structdim2,dim2,spacedim2> &)
      {
	Assert (false, ExcInternalError());
      }

				     /**
				      * Constructor. Should never be
				      * called and thus produces an
				      * error.
				      */
    template <int structdim2, int dim2, int spacedim2>
    TriaAccessor (const InvalidAccessor<structdim2,dim2,spacedim2> &)
      {
	Assert (false, ExcInternalError());
      }
    
				     /**
    				      * Boundary indicator of this
				      * object.
				      */
    unsigned char boundary_indicator () const
      {
	Assert (false, ExcInternalError());
	return 0;
      }

				     /**
				      * Whether this object is used.
				      */
    bool used () const
      {
	Assert (false, ExcInternalError());
	return false;
      }

				     /**
				      * Produce a dummy child object.
				      */
    TriaIterator<InvalidAccessor<0,dim,spacedim> >
    child (const unsigned int) const
      {
	Assert (false, ExcInternalError());
	return TriaIterator<InvalidAccessor<0,dim,spacedim> >();
      }
};




/**
 * This class allows access to a cell: a line in one dimension, a quad
 * in two dimension, etc.
 *
 * The following refers to any dimension:
 * 
 * This class allows access to a <tt>cell</tt>, which is a line in 1D
 * and a quad in 2D. Cells have more functionality than lines or quads
 * by themselves, for example they can be flagged for refinement, they
 * have neighbors, they have the possibility to check whether they are
 * at the boundary etc. This class offers access to all this data.
 *
 * @ingroup grid
 * @ingroup Accessors
 * @author Wolfgang Bangerth, 1998, 1999, 2000
 */
template <int dim, int spacedim=dim>
class CellAccessor :  public TriaAccessor<dim,dim,spacedim>
{
  public:
				     /**
				      * Propagate the AccessorData type
				      * into the present class.
				      */
    typedef typename TriaAccessor<dim,dim,spacedim>::AccessorData AccessorData;
    
				     /**
				      *  @name Constructors
				      */
				     /**
				      * @{
				      */

				     /**
				      *  Constructor.
				      */
    CellAccessor (const Triangulation<dim,spacedim> *parent     =  0,
		  const int                 level      = -1,
		  const int                 index      = -1,
		  const AccessorData       *local_data =  0);

				     /**
				      * Copy constructor.
				      */
    CellAccessor (const CellAccessor &cell_accessor);

				     /**
				      * Conversion constructor. This
				      * constructor exists to make certain
				      * constructs simpler to write in
				      * dimension independent code. For
				      * example, it allows assigning a face
				      * iterator to a line iterator, an
				      * operation that is useful in 2d but
				      * doesn't make any sense in 3d. The
				      * constructor here exists for the
				      * purpose of making the code conform to
				      * C++ but it will unconditionally abort;
				      * in other words, assigning a face
				      * iterator to a line iterator is better
				      * put into an if-statement that checks
				      * that the dimension is two, and assign
				      * to a quad iterator in 3d (an operator
				      * that, without this constructor would
				      * be illegal if we happen to compile for
				      * 2d).
				      */
    template <int structdim2, int dim2, int spacedim2>
    CellAccessor (const InvalidAccessor<structdim2,dim2,spacedim2> &);

				     /**
				      * Another conversion operator
				      * between objects that don't
				      * make sense, just like the
				      * previous one.
				      */
    template <int structdim2, int dim2, int spacedim2>
    CellAccessor (const TriaAccessor<structdim2,dim2,spacedim2> &);

				     /**
				      * @}
				      */
    
				     /**
				      *  @name Accessing sub-objects and neighbors
				      */
				     /**
				      * @{
				      */

				     /**
				      *  Return a pointer to the
				      *  @p ith child. Overloaded
				      *  version which returns a more
				      *  reasonable iterator class.
				      */
    TriaIterator<CellAccessor<dim, spacedim> >
    child (const unsigned int i) const;

				     /**
				      * Return an iterator to the
				      * @p ith face of this cell.
				      *
				      * This function is not
				      * implemented in 1D, and maps to
				      * QuadAccessor::line in 2D.
				      */
    TriaIterator<TriaAccessor<dim-1,dim,spacedim> >
    face (const unsigned int i) const;

				     /**
				      * Return the (global) index of the
				      * @p ith face of this cell.
				      *
				      * This function is not
				      * implemented in 1D, and maps to
				      * line_index in 2D and quad_index
				      * in 3D.
				      */
    unsigned int
    face_index (const unsigned int i) const;

                                     /**
                                      * Return an iterator to that
                                      * cell that neighbors the
                                      * present cell on the given face
                                      * and subface number.
                                      *
                                      * To succeed, the present cell
                                      * must not be further refined,
                                      * and the neighbor on the given
                                      * face must be further refined
                                      * exactly once; the returned
                                      * cell is then a child of that
                                      * neighbor.
                                      *
                                      * The function may not be called
                                      * in 1d, since there we have no
                                      * subfaces.  The implementation
                                      * of this function is rather
                                      * straightforward in 2d, by
                                      * first determining which face
                                      * of the neighbor cell the
                                      * present cell is bordering on
                                      * (this is what the
                                      * @p neighbor_of_neighbor
                                      * function does), and then
                                      * asking
                                      * @p GeometryInfo::child_cell_on_subface
                                      * for the index of the
                                      * child.
                                      *
                                      * However, the situation is more
                                      * complicated in 3d, since there faces may
                                      * have more than one orientation, and we
                                      * have to use @p face_orientation, @p
                                      * face_flip and @p face_rotation for both
                                      * this and the neighbor cell to figure out
                                      * which cell we want to have.
                                      *
                                      * This can lead to surprising
                                      * results: if we are sitting on
                                      * a cell and are asking for a
                                      * cell behind subface
                                      * <tt>sf</tt>, then this means
                                      * that we are considering the
                                      * subface for the face in the
                                      * natural direction for the
                                      * present cell. However, if the
                                      * face as seen from this cell
                                      * has
                                      * <tt>face_orientation()==false</tt>,
                                      * then the child of the face
                                      * that separates the present
                                      * cell from the neighboring
                                      * cell's child is not
                                      * necessarily the @p sf-th child
                                      * of the face of this cell. This
                                      * is so because the @p
                                      * subface_no on a cell corresponds to the
                                      * subface with respect to the
                                      * intrinsic ordering of the
                                      * present cell, whereas children
                                      * of face iterators are computed
                                      * with respect to the intrinsic
                                      * ordering of faces; these two
                                      * orderings are only identical
                                      * if the face orientation is @p
                                      * true, and reversed otherwise.
				      *
				      * Similarly, effects of
				      * <tt>face_flip()==true</tt> and
				      * <tt>face_rotation()==true()</tt>, both
				      * of which indicate a non-standard face
				      * have to be considered.
                                      *
                                      * Fortunately, this is only very rarely of
                                      * concern, since usually one simply wishes
                                      * to loop over all finer neighbors at a
                                      * given face of an active cell. Only in
                                      * the process of refinement of a
                                      * Triangulation we want to set neighbor
                                      * information for both our child cells and
                                      * the neighbor's children. Since we can
                                      * respect orientation of faces from our
                                      * current cell in that case, we do NOT
                                      * respect face_orientation, face_flip and
                                      * face_rotation of the present cell within
                                      * this function, i.e. the returned
                                      * neighbor's child is behind subface @p
                                      * subface concerning the intrinsic
                                      * ordering of the given face.
                                      */
    TriaIterator<CellAccessor<dim, spacedim> >
    neighbor_child_on_subface (const unsigned int face_no,
                               const unsigned int subface_no) const;
    
				     /**
				      *  Return a pointer to the
				      *  @p ith neighbor.  If the
				      *  neighbor does not exist, an
				      *  invalid iterator is returned.
				      *  
				      *  <b>Note</b> (cf. TriaLevel<0>):
				      *  The neighbor of a cell has at most the
				      *  same level as this cell, i.e. it may
				      *  or may not be refined.
				      */
    TriaIterator<CellAccessor<dim, spacedim>  >
    neighbor (const unsigned int i) const;

				     /**
				      *  Return the index of the
				      *  @p ith neighbor.  If the
				      *  neighbor does not exist, its
				      *  index is -1.
				      */
    int neighbor_index (const unsigned int i) const;

    				     /**
				      *  Return the level of the
				      *  @p ith neighbor.  If the
				      *  neighbor does not exist, its
				      *  level is -1.
				      */
    int neighbor_level (const unsigned int i) const;

				     /**
				      * Return the how-many'th
				      * neighbor this cell is of
				      * <tt>cell->neighbor(neighbor)</tt>,
				      * i.e. return the @p face_no
				      * such that
				      * <tt>cell->neighbor(neighbor)->neighbor(face_no)==cell</tt>. This
				      * function is the right one if
				      * you want to know how to get
				      * back from a neighbor to the
				      * present cell.
				      *
				      * Note that this operation is
				      * only useful if the neighbor is
				      * not coarser than the present
				      * cell. If the neighbor is
				      * coarser this function throws
				      * an exception. Use the @p
				      * neighbor_of_coarser_neighbor
				      * function in that case.
				      */
    unsigned int neighbor_of_neighbor (const unsigned int neighbor) const;

				     /**
				      * Return, whether the neighbor
				      * is coarser then the present
				      * cell. This is important in
				      * case of ansiotropic
				      * refinement where this
				      * information does not depend on
				      * the levels of the cells.
				      *
				      * Note, that in an anisotropic
				      * setting, a cell can only be
				      * coarser than another one at a
				      * given face, not on a general
				      * basis. The face of the finer
				      * cell is contained in the
				      * corresponding face of the
				      * coarser cell, the finer face
				      * is either a child or a
				      * grandchild of the coarser
				      * face.
				      */
    bool neighbor_is_coarser (const unsigned int neighbor) const;
    
				     /**
				      * This function is a generalization of the
				      * @p neighbor_of_neighbor function for the
				      * case of a coarser neighbor. It returns a
				      * pair of numbers, face_no and subface_no,
				      * with the following property, if the
				      * neighbor is not refined:
				      * <tt>cell->neighbor(neighbor)->neighbor_child_on_subface(face_no,subface_no)==cell</tt>.
				      * In 3D, a coarser neighbor can still be
				      * refined. In that case subface_no denotes the child index of the neighbors face that relates to our face:
				      * <tt>cell->neighbor(neighbor)->face(face_no)->child(subface_no)==cell->face(neighbor)</tt>.
				      * This case in 3d and how it can happen
				      * is discussed in the introduction of the
				      * @ref step_30 "step-30" tutorial program.
				      *
				      * This function is impossible
				      * for <tt>dim==1</tt>.
				      */
    std::pair<unsigned int, unsigned int>
    neighbor_of_coarser_neighbor (const unsigned int neighbor) const;
    
				     /**
				      * This function is a generalization of the
				      * @p neighbor_of_neighbor and the @p
				      * neighbor_of_coarser_neighbor
				      * functions. It checks whether the
				      * neighbor is coarser or not and calls the
				      * respective function. In both cases, only
				      * the face_no is returned.
				      */
    unsigned int neighbor_face_no (const unsigned int neighbor) const;
    
				     /**
				      * @}
				      */

				     /**
				      *  @name Dealing with boundary indicators
				      */
				     /**
				      * @{
				      */

				     /**
				      *  Return whether the @p ith
				      *  vertex or face (depending on
				      *  the dimension) is part of the
				      *  boundary. This is true, if
				      *  the @p ith neighbor does not
				      *  exist.
				      */
    bool at_boundary (const unsigned int i) const;

				     /**
				      *  Return whether the cell is at
				      *  the boundary. Being at the
				      *  boundary is defined by one
				      *  face being on the
				      *  boundary. Note that this does
				      *  not catch cases where only one
				      *  vertex of a quad or of a hex
				      *  is at the boundary, or where
				      *  only one line of a hex is at
				      *  the boundary while the
				      *  interiors of all faces are in
				      *  the interior of the
				      *  domain. For the latter case,
				      *  the @p has_boundary_lines
				      *  function is the right one to
				      *  ask.
				      */
    bool at_boundary () const;

				     /**
				      * This is a slight variation to
				      * the @p at_boundary function:
				      * for 1 and 2 dimensions,
				      * it is equivalent, for three
				      * dimensions it returns
				      * whether at least one of the 12
				      * lines of the hexahedron is at
				      * a boundary. This, of course,
				      * includes the case where a
				      * whole face is at the boundary,
				      * but also some other cases.
				      */
    bool has_boundary_lines () const;
				     /**
				      * @}
				      */

				     /**
				      *  @name Dealing with refinement indicators
				      */
				     /**
				      * @{
				      */

				     /**
				      *  Return the @p
				      *  RefinementCase<dim> this cell
				      *  was flagged to be refined
				      *  with.
				      */
    RefinementCase<dim> refine_flag_set () const;

				     /**
				      *  Flag the cell pointed to for
				      *  refinement. This function is
				      *  only allowed for active
				      *  cells.
				      */
    void set_refine_flag (const RefinementCase<dim> ref_case = RefinementCase<dim>::isotropic_refinement) const;

				     /**
				      *  Clear the refinement flag.
				      */
    void clear_refine_flag () const;

				     /**
				      *  Modify the refinement flag of the cell
				      *  to ensure (at least) the given
				      *  refinement case @p face_refinement_case at
				      *  face <tt>face_no</tt>, taking into
				      *  account orientation, flip and rotation
				      *  of the face. Return, whether the
				      *  refinement flag had to be
				      *  modified. This function is only allowed
				      *  for active cells.
				      */
    bool flag_for_face_refinement (const unsigned int face_no,
				   const RefinementCase<dim-1> &face_refinement_case=RefinementCase<dim-1>::isotropic_refinement) const;

				     /**
				      *  Modify the refinement flag of the cell
				      *  to ensure that line <tt>face_no</tt>
				      *  will be refined. Return, whether the
				      *  refinement flag had to be
				      *  modified. This function is only allowed
				      *  for active cells.
				      */
    bool flag_for_line_refinement (const unsigned int line_no) const;

				     /**
				      * Return the SubfaceCase of face
				      * <tt>face_no</tt>. Note that this is not
				      * identical to asking
				      * <tt>cell->face(face_no)->refinement_case()</tt>
				      * since the latter returns a RefinementCase<dim-1>
				      * and thus only considers one
				      * (anisotropic) refinement, whereas this
				      * function considers the complete
				      * refinement situation including possible
				      * refinement of the face's children. This
				      * function may only be called for active
				      * cells in 2d and 3d.
				      */
    internal::SubfaceCase<dim> subface_case(const unsigned int face_no) const;
    
				     /**
				      *  Return whether the coarsen flag
				      *  is set or not.
				      */
    bool coarsen_flag_set () const;

				     /**
				      *  Flag the cell pointed to for
				      *  coarsening. This function is
				      *  only allowed for active
				      *  cells.
				      */
    void set_coarsen_flag () const;

				     /**
				      *  Clear the coarsen flag.
				      */
    void clear_coarsen_flag () const;
				     /**
				      * @}
				      */

				     /**
				      *  @name Dealing with material indicators
				      */
				     /**
				      * @{
				      */
    
				     /**
				      * Return the material id of this
				      * cell.
				      *
				      * For a typical use of this
				      * function, see the @ref step_28
				      * "step-28" tutorial program.
				      */
    unsigned char material_id () const;

				     /**
				      * Set the material id of this
				      * cell.
				      *
				      * For a typical use of this
				      * function, see the @ref step_28
				      * "step-28" tutorial program.
				      */
    void set_material_id (const unsigned char new_material_id) const;

				     /**
				      * Set the material id of this
				      * cell and all its children (and
				      * grand-children, and so on) to
				      * the given value.
				      */
    void recursively_set_material_id (const unsigned char new_material_id) const;
				     /**
				      * @}
				      */

				     /**
				      *  @name Dealing with subdomain indicators
				      */
				     /**
				      * @{
				      */

				     /**
				      * Return the subdomain id of
				      * this cell.
				      */
    unsigned int subdomain_id () const;

				     /**
				      * Set the subdomain id of this
				      * cell.
				      */
    void set_subdomain_id (const unsigned int new_subdomain_id) const;

				     /**
				      * @}
				      */

				     /**
				      *  @name Other functions
				      */
				     /**
				      * @{
				      */

				     /**
				      * Test whether the cell has children
				      * (this is the criterion for activity
				      * of a cell).
				      */
    bool active () const;

				     /**
				      * Test whether the point @p p
				      * is inside this cell. Points on
				      * the boundary are counted as
				      * being inside the cell.
				      *
				      * Note that this function
				      * assumes that the mapping
				      * between unit cell and real
				      * cell is (bi-, tri-)linear,
				      * i.e. that faces in 2d and
				      * edges in 3d are straight
				      * lines. If you have higher
				      * order transformations, results
				      * may be different as to whether
				      * a point is in- or outside the
				      * cell in real space.
				      */
    bool point_inside (const Point<spacedim> &p) const;


				     /**
				      *  Set the neighbor @p i of
				      *  this cell to the cell pointed
				      *  to by @p pointer.
				      *
				      * This function shouldn't really be
				      * public (but needs to for various
				      * reasons in order not to make a long
				      * list of functions friends): it
				      * modifies internal data structures and
				      * may leave things. Do not use it from
				      * application codes.
				      */
    void set_neighbor (const unsigned int i,
		       const TriaIterator<CellAccessor<dim, spacedim> > &pointer) const;
    
				     /**
				      * @}
				      */
    
    
				     /**
				      * @ingroup Exceptions
				      */
    DeclException0 (ExcRefineCellNotActive);
				     /**
				      * @ingroup Exceptions
				      */
    DeclException0 (ExcCellFlaggedForRefinement);
				     /**
				      * @ingroup Exceptions
				      */
    DeclException0 (ExcCellFlaggedForCoarsening);
    
  protected:
    				     /**
				      * This function assumes that the
				      * neighbor is not coarser than
				      * the current cell. In this case
				      * it returns the
				      * neighbor_of_neighbor() value.
				      * If, however, the neighbor is
				      * coarser this function returns
				      * an
				      * <code>invalid_unsigned_int</code>.
				      *
				      * This function is not for
				      * public use. Use the function
				      * neighbor_of_neighbor() instead
				      * which throws an exception if
				      * called for a coarser
				      * neighbor. If neighbor is
				      * indeed coarser (you get to
				      * know this by e.g. the
				      * neighbor_is_coarser()
				      * function) then the
				      * neighbor_of_coarser_neighbor()
				      * function should be call. If
				      * you'd like to know only the
				      * <code>face_no</code> which is
				      * required to get back from the
				      * neighbor to the present cell
				      * then simply use the
				      * neighbor_face_no() function
				      * which can be used for coarser
				      * as well as noncoarser
				      * neighbors.
				      */
    unsigned int neighbor_of_neighbor_internal (const unsigned int neighbor) const;
    
  private:
    
    				     /**
				      *  Copy operator. This is
				      *  normally used in a context
				      *  like <tt>iterator a,b;
				      *  *a=*b;</tt>. Since the meaning is
				      *  to copy the object pointed to
				      *  by @p b to the object
				      *  pointed to by @p a and since
				      *  accessors are not real but
				      *  virtual objects, this
				      *  operation is not useful for
				      *  iterators on
				      *  triangulations. We declare
				      *  this function here private,
				      *  thus it may not be used from
				      *  outside.  Furthermore it is
				      *  not implemented and will give
				      *  a linker error if used
				      *  anyway.
				      */
    void operator = (const CellAccessor<dim, spacedim> &);
};



/* -------------- declaration of explicit
   specializations and general templates ------------- */


template <int structdim, int dim, int spacedim>
template <typename OtherAccessor>
InvalidAccessor<structdim, dim, spacedim>::
InvalidAccessor (const OtherAccessor &)
{
  Assert (false,
	  ExcMessage ("You are attempting an illegal conversion between "
		      "iterator/accessor types. The constructor you call "
		      "only exists to make certain template constructs "
		      "easier to write as dimension independent code but "
		      "the conversion is not valid in the current context."));
}



template <int structdim, int dim, int spacedim>
template <int structdim2, int dim2, int spacedim2>
TriaAccessor<structdim,dim,spacedim>::
TriaAccessor (const InvalidAccessor<structdim2,dim2,spacedim2> &)
{
  Assert (false,
	  ExcMessage ("You are attempting an illegal conversion between "
		      "iterator/accessor types. The constructor you call "
		      "only exists to make certain template constructs "
		      "easier to write as dimension independent code but "
		      "the conversion is not valid in the current context."));
}



template <int dim, int spacedim>
template <int structdim2, int dim2, int spacedim2>
CellAccessor<dim,spacedim>::
CellAccessor (const InvalidAccessor<structdim2,dim2,spacedim2> &)
{
  Assert (false,
	  ExcMessage ("You are attempting an illegal conversion between "
		      "iterator/accessor types. The constructor you call "
		      "only exists to make certain template constructs "
		      "easier to write as dimension independent code but "
		      "the conversion is not valid in the current context."));
}



template <int structdim, int dim, int spacedim>
template <int structdim2, int dim2, int spacedim2>
TriaAccessor<structdim,dim,spacedim>::
TriaAccessor (const TriaAccessor<structdim2,dim2,spacedim2> &)
{
  Assert (false,
	  ExcMessage ("You are attempting an illegal conversion between "
		      "iterator/accessor types. The constructor you call "
		      "only exists to make certain template constructs "
		      "easier to write as dimension independent code but "
		      "the conversion is not valid in the current context."));
}



template <int dim, int spacedim>
template <int structdim2, int dim2, int spacedim2>
CellAccessor<dim,spacedim>::
CellAccessor (const TriaAccessor<structdim2,dim2,spacedim2> &)
{
  Assert (false,
	  ExcMessage ("You are attempting an illegal conversion between "
		      "iterator/accessor types. The constructor you call "
		      "only exists to make certain template constructs "
		      "easier to write as dimension independent code but "
		      "the conversion is not valid in the current context."));
}


#ifndef DOXYGEN

template <> bool CellAccessor<1,1>::point_inside (const Point<1> &p) const;
template <> bool CellAccessor<2,2>::point_inside (const Point<2> &p) const;
template <> bool CellAccessor<3,3>::point_inside (const Point<3> &) const;
template <> bool CellAccessor<1,2>::point_inside (const Point<2> &p) const;
template <> bool CellAccessor<2,3>::point_inside (const Point<3> &p) const;
// -------------------------------------------------------------------

#endif // DOXYGEN

DEAL_II_NAMESPACE_CLOSE

// include more templates in debug and optimized mode
#  include "tria_accessor.templates.h"

#endif
