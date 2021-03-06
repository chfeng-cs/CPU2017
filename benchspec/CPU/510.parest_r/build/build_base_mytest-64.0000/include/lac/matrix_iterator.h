//---------------------------------------------------------------------------
//    $Id: matrix_iterator.h 14038 2006-10-23 02:46:34Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__matrix_iterator_h
#define __deal2__matrix_iterator_h


#include <base/config.h>
#include <base/exceptions.h>

DEAL_II_NAMESPACE_OPEN

				 /**
				  * STL conforming iterator for constant
				  * and non-constant matrices.
				  *
				  * This iterator is abstracted from
				  * the actual matrix type and can be
				  * used for any matrix having the
				  * required ACCESSOR type.
				  *
				  * @author Guido Kanschat, 2006, based on previous a implementation
				  */
template <class ACCESSOR>
class MatrixIterator
{
  public:
				     /**
				      * Typedef for the matrix type
				      * (including constness) we are to
				      * operate on.
				      */
    typedef typename ACCESSOR::MatrixType MatrixType;
    
				     /**
				      * Constructor. Create an
				      * iterator into the matrix
				      * <tt>matrix</tt> for the given
				      * <tt>row</tt> and the
				      * <tt>index</tt> within it.
				      */ 
    MatrixIterator (MatrixType        *matrix,
		    const unsigned int row = 0,
		    const unsigned int index = 0);

				     /**
				      * Copy from another matrix
				      * iterator. Mostly implemented
				      * to allow initialization of a
				      * constant iterator from a non
				      * constant, this function only
				      * requires that a conversion
				      * from the other iterator's
				      * accessor to this accessor
				      * object is possible.
				      */
    template <class OtherAccessor>
    MatrixIterator(const MatrixIterator<OtherAccessor>& other);
    
				     /**
				      * Prefix increment.
				      */
    MatrixIterator & operator++ ();

				     /**
				      * Postfix increment.
				      */
    MatrixIterator operator++ (int);

				     /**
				      * Dereferencing operator.
				      */
    const ACCESSOR & operator* () const;

				     /**
				      * Dereferencing operator.
				      */
    const ACCESSOR * operator-> () const;

				     /**
				      * Comparison. True, if
				      * both accessors are equal.
				      */
    bool operator == (const MatrixIterator &) const;

				     /**
				      * Inverse of <tt>==</tt>.
				      */
    bool operator != (const MatrixIterator &) const;

				     /**
				      * Comparison operator. Result is
				      * true if either the first row
				      * number is smaller or if the row
				      * numbers are equal and the first
				      * index is smaller.
				      *
				      * This function is only valid if
				      * both iterators point into the same
				      * matrix.
				      */
    bool operator < (const MatrixIterator &) const;

				     /**
				      * Comparison operator. Works in the
				      * same way as above operator, just
				      * the other way round.
				      */
    bool operator > (const MatrixIterator &) const;
        
  private:
				     /**
				      * Store an object of the
				      * accessor class.
				      */
    ACCESSOR accessor;

				     /**
				      * Allow other iterators access
				      * to private data.
				      */
    template <class OtherAccessor> friend class MatrixIterator;
};


//----------------------------------------------------------------------//

template <class ACCESSOR>
inline
MatrixIterator<ACCESSOR>::
MatrixIterator (MatrixType        *matrix,
		const unsigned int r,
		const unsigned int i)
		:
		accessor(matrix, r, i)
{}


template <class ACCESSOR>
template <class OtherAccessor>
inline
MatrixIterator<ACCESSOR>::
MatrixIterator (const MatrixIterator<OtherAccessor>& other)
		:
		accessor(other.accessor)
{}


template <class ACCESSOR>
inline
MatrixIterator<ACCESSOR> &
MatrixIterator<ACCESSOR>::operator++ ()
{
  accessor.advance ();
  return *this;
}


template <class ACCESSOR>
inline
MatrixIterator<ACCESSOR>
MatrixIterator<ACCESSOR>::operator++ (int)
{
  const MatrixIterator iter = *this;
  accessor.advance ();
  return iter;
}


template <class ACCESSOR>
inline
const ACCESSOR &
MatrixIterator<ACCESSOR>::operator* () const
{
  return accessor;
}


template <class ACCESSOR>
inline
const ACCESSOR *
MatrixIterator<ACCESSOR>::operator-> () const
{
  return &accessor;
}


template <class ACCESSOR>
inline
bool
MatrixIterator<ACCESSOR>::
operator == (const MatrixIterator& other) const
{
  return (accessor == other.accessor);
}


template <class ACCESSOR>
inline
bool
MatrixIterator<ACCESSOR>::
operator != (const MatrixIterator& other) const
{
  return ! (*this == other);
}


template <class ACCESSOR>
inline
bool
MatrixIterator<ACCESSOR>::
operator < (const MatrixIterator& other) const
{
  Assert (&accessor.get_matrix() == &other.accessor.get_matrix(),
	  ExcInternalError());
      
  return (accessor < other.accessor);
}


template <class ACCESSOR>
inline
bool
MatrixIterator<ACCESSOR>::
operator > (const MatrixIterator& other) const
{
  return (other < *this);
}

DEAL_II_NAMESPACE_CLOSE

#endif
