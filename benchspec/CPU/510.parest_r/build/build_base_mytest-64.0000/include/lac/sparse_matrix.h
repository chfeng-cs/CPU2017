//---------------------------------------------------------------------------
//    $Id: sparse_matrix.h 18675 2009-04-21 13:44:29Z bangerth $
//    Version: $Name:  $
//
//    Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2009, 2010, 2014 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__sparse_matrix_h
#define __deal2__sparse_matrix_h


#include <base/config.h>
#include <base/subscriptor.h>
#include <base/smartpointer.h>
#include <lac/sparsity_pattern.h>
#include <lac/identity_matrix.h>
#include <lac/exceptions.h>

DEAL_II_NAMESPACE_OPEN

template<typename number> class Vector;
template<typename number> class FullMatrix;

/*! @addtogroup Matrix1
 *@{
 */

namespace internals
{
  namespace SparseMatrixIterators
  {
                                     // forward declaration
    template <typename number, bool Constness>
    class Iterator;

                                     /**
                                      * General template for sparse matrix
                                      * accessors. The first template argument
                                      * denotes the underlying numeric type,
                                      * the second the constness of the
                                      * matrix.
                                      *
                                      * The general template is not
                                      * implemented, only the specializations
                                      * for the two possible values of the
                                      * second template argument.
                                      */
    template <typename number, bool Constness>
    class Accessor;


                                     /**
                                      * Accessor class for constant matrices,
                                      * used in the const_iterators. This
                                      * class builds on the accessor classes
                                      * used for sparsity patterns to loop
                                      * over all nonzero entries, and only
                                      * adds the accessor functions to gain
                                      * access to the actual value stored at a
                                      * certain location.
                                      */
    template <typename number>
    class Accessor<number,true> : public SparsityPatternIterators::Accessor
    {
      public:
                                         /**
                                          * Typedef for the type (including
                                          * constness) of the matrix to be
                                          * used here.
                                          */
        typedef const SparseMatrix<number> MatrixType;

                                         /**
                                          * Constructor.
                                          */
        Accessor (MatrixType         *matrix,
                  const unsigned int  row,
                  const unsigned int  index);

                                         /**
                                          * Constructor. Construct the end
                                          * accessor for the given matrix.
                                          */
        Accessor (MatrixType         *matrix);

                                         /**
                                          * Copy constructor to get from a
                                          * non-const accessor to a const
                                          * accessor.
                                          */
        Accessor (const internals::SparseMatrixIterators::Accessor<number,false> &a);

                                         /**
                                          * Value of this matrix entry.
                                          */
        number value() const;

                                         /**
                                          * Return a reference to the matrix
                                          * into which this accessor
                                          * points. Note that in the present
                                          * case, this is a constant
                                          * reference.
                                          */
        const SparseMatrix<number> & get_matrix () const;

      private:
                                         /**
                                          * Pointer to the matrix we use.
                                          */
        MatrixType *matrix;

					 /**
					  * Make the advance function of the
					  * base class available.
					  */
	using SparsityPatternIterators::Accessor::advance;

					 /**
					  * Make iterator class a friend.
					  */
	template <typename, bool>
	friend class Iterator;
    };
    

                                     /**
                                      * Accessor class for non-constant
                                      * matrices, used in the iterators. This
                                      * class builds on the accessor classes
                                      * used for sparsity patterns to loop
                                      * over all nonzero entries, and only
                                      * adds the accessor functions to gain
                                      * access to the actual value stored at a
                                      * certain location.
                                      */
    template <typename number>
    class Accessor<number,false> : public SparsityPatternIterators::Accessor
    {
      private:
                                         /**
                                          * Reference class. This is what the
                                          * accessor class returns when you
                                          * call the value() function. The
                                          * reference acts just as if it were
                                          * a reference to the actual value of
                                          * a matrix entry, i.e. you can read
                                          * and write it, you can add and
                                          * multiply to it, etc, but since the
                                          * matrix does not give away the
                                          * address of this matrix entry, we
                                          * have to go through functions to do
                                          * all this.
                                          *
                                          * The constructor takes a pointer to
                                          * an accessor object that describes
                                          * which element of the matrix it
                                          * points to. This creates an
                                          * ambiguity when one writes code
                                          * like iterator->value()=0 (instead
                                          * of iterator->value()=0.0), since
                                          * the right hand side is an integer
                                          * that can both be converted to a
                                          * <tt>number</tt> (i.e., most
                                          * commonly a double) or to another
                                          * object of type
                                          * <tt>Reference</tt>. The compiler
                                          * then complains about not knowing
                                          * which conversion to take.
                                          *
                                          * For some reason, adding another
                                          * overload operator=(int) doesn't
                                          * seem to cure the problem. We avoid
                                          * it, however, by adding a second,
                                          * dummy argument to the Reference
                                          * constructor, that is unused, but
                                          * makes sure there is no second
                                          * matching conversion sequence using
                                          * a one-argument right hand side.
                                          *
                                          * The testcase oliver_01 checks that
                                          * this actually works as intended.
                                          */
        class Reference 
        {
          public:
                                             /**
                                              * Constructor. For the second
                                              * argument, see the general
                                              * class documentation.
                                              */
            Reference (const Accessor *accessor,
                       const bool)
			    :
			    accessor (accessor)
	      {}

                                             /**
                                              * Conversion operator to the
                                              * data type of the matrix.
                                              */
            operator number () const;

                                             /**
                                              * Set the element of the matrix
                                              * we presently point to to @p n.
                                              */
            const Reference & operator = (const number n) const;

                                             /**
                                              * Add @p n to the element of the
                                              * matrix we presently point to.
                                              */
            const Reference & operator += (const number n) const;
            
                                             /**
                                              * Subtract @p n from the element
                                              * of the matrix we presently
                                              * point to.
                                              */
            const Reference & operator -= (const number n) const;
            
                                             /**
                                              * Multiply the element of the
                                              * matrix we presently point to
                                              * by @p n.
                                              */
            const Reference & operator *= (const number n) const;
            
                                             /**
                                              * Divide the element of the
                                              * matrix we presently point to
                                              * by @p n.
                                              */
            const Reference & operator /= (const number n) const;
            
          private:
                                             /**
                                              * Pointer to the accessor that
                                              * denotes which element we
                                              * presently point to.
                                              */
            const Accessor *accessor;
        };

      public:
                                         /**
                                          * Typedef for the type (including
                                          * constness) of the matrix to be
                                          * used here.
                                          */
        typedef SparseMatrix<number> MatrixType;

                                         /**
                                          * Constructor.
                                          */
        Accessor (MatrixType         *matrix,
                  const unsigned int  row,
                  const unsigned int  index);
        
                                         /**
                                          * Constructor. Construct the end
                                          * accessor for the given matrix.
                                          */
        Accessor (MatrixType         *matrix);

                                         /**
                                          * Value of this matrix entry,
                                          * returned as a read- and writable
                                          * reference.
                                          */
        Reference value() const;
        
                                         /**
                                          * Return a reference to the matrix
                                          * into which this accessor
                                          * points. Note that in the present
                                          * case, this is a non-constant
                                          * reference.
                                          */
        MatrixType & get_matrix () const;

      private:
                                         /**
                                          * Pointer to the matrix we use.
                                          */
        MatrixType *matrix;

					 /**
					  * Make the advance function of the
					  * base class available.
					  */
	using SparsityPatternIterators::Accessor::advance;

					 /**
					  * Make iterator class a friend.
					  */
	template <typename, bool>
	friend class Iterator;
	
                                         /**
                                          * Make the inner reference class a
                                          * friend if the compiler has a bug
                                          * and requires this.
                                          */
#ifdef DEAL_II_NESTED_CLASS_FRIEND_BUG
        friend class Reference;
#endif
    };
    


                                     /**
				      * STL conforming iterator for constant
				      * and non-constant matrices.
				      *
				      * The first template argument
                                      * denotes the underlying numeric type,
                                      * the second the constness of the
                                      * matrix.
                                      *
                                      * Since there is a specialization of
                                      * this class for
                                      * <tt>Constness=false</tt>, this class
                                      * is for iterators to constant matrices.
				      */
    template <typename number, bool Constness>
    class Iterator
    {
      public:
                                         /**
                                          * Typedef for the matrix type
                                          * (including constness) we are to
                                          * operate on.
                                          */
        typedef
        typename Accessor<number,Constness>::MatrixType
        MatrixType;

                                         /**
                                          * Constructor. Create an iterator
                                          * into the matrix @p matrix for the
                                          * given row and the index within it.
                                          */ 
	Iterator (MatrixType        *matrix,
                  const unsigned int row,
                  const unsigned int index);

                                         /**
                                          * Constructor. Create the end
                                          * iterator for the given matrix.
                                          */
        Iterator (MatrixType *matrix);
        
                                         /**
                                          * Conversion constructor to get from
                                          * a non-const iterator to a const
                                          * iterator.
                                          */
        Iterator (const internals::SparseMatrixIterators::Iterator<number,false> &i);
        
                                         /**
                                          * Prefix increment.
                                          */
	Iterator & operator++ ();

                                         /**
                                          * Postfix increment.
                                          */
	Iterator operator++ (int);

                                         /**
                                          * Dereferencing operator.
                                          */
	const Accessor<number,Constness> & operator* () const;

                                         /**
                                          * Dereferencing operator.
                                          */
	const Accessor<number,Constness> * operator-> () const;

                                         /**
                                          * Comparison. True, if
                                          * both iterators point to
                                          * the same matrix
                                          * position.
                                          */
	bool operator == (const Iterator &) const;

                                         /**
                                          * Inverse of <tt>==</tt>.
                                          */
	bool operator != (const Iterator &) const;

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
	bool operator < (const Iterator &) const;

                                         /**
                                          * Comparison operator. Works in the
                                          * same way as above operator, just
                                          * the other way round.
                                          */
	bool operator > (const Iterator &) const;
        
      private:
                                         /**
                                          * Store an object of the
                                          * accessor class.
                                          */
        Accessor<number,Constness> accessor;
    };
    
  }
}


//TODO: Add multithreading to the other vmult functions.

/**
 * Sparse matrix. This class implements the function to store values
 * in the locations of a sparse matrix denoted by a
 * SparsityPattern. The separation of sparsity pattern and values is
 * done since one can store data elements of different type in these
 * locations without the SparsityPattern having to know this, and more
 * importantly one can associate more than one matrix with the same
 * sparsity pattern.
 *
 * @note Instantiations for this template are provided for <tt>@<float@> and
 * @<double@></tt>; others can be generated in application programs (see the
 * section on @ref Instantiations in the manual).
 *
 * @author Essentially everyone who has ever worked on deal.II, 1994-2007
 */
template <typename number>
class SparseMatrix : public virtual Subscriptor
{
  public:
				     /**
				      * Type of matrix entries. In analogy to
				      * the STL container classes.
				      */
    typedef number value_type;

				     /**
				      * Declare a type that has holds
				      * real-valued numbers with the
				      * same precision as the template
				      * argument to this class. If the
				      * template argument of this
				      * class is a real data type,
				      * then real_type equals the
				      * template argument. If the
				      * template argument is a
				      * std::complex type then
				      * real_type equals the type
				      * underlying the complex
				      * numbers.
				      *
				      * This typedef is used to
				      * represent the return type of
				      * norms.
				      */
    typedef typename numbers::NumberTraits<number>::real_type real_type;
    
                                     /**
                                      * Typedef of an STL conforming iterator
                                      * class walking over all the nonzero
                                      * entries of this matrix. This iterator
                                      * cannot change the values of the
                                      * matrix.
                                      */
    typedef
    internals::SparseMatrixIterators::Iterator<number,true>
    const_iterator;

                                     /**
                                      * Typedef of an STL conforming iterator
                                      * class walking over all the nonzero
                                      * entries of this matrix. This iterator
                                      * @em can change the values of the
                                      * matrix, but of course can't change the
                                      * sparsity pattern as this is fixed once
                                      * a sparse matrix is attached to it.
                                      */
    typedef
    internals::SparseMatrixIterators::Iterator<number,false>
    iterator;

                                     /**
                                      * A structure that describes some of the
                                      * traits of this class in terms of its
                                      * run-time behavior. Some other classes
                                      * (such as the block matrix classes)
                                      * that take one or other of the matrix
                                      * classes as its template parameters can
                                      * tune their behavior based on the
                                      * variables in this class.
                                      */
    struct Traits
    {
                                         /**
                                          * It is safe to elide additions of
                                          * zeros to individual elements of
                                          * this matrix.
                                          */
        static const bool zero_addition_can_be_elided = true;
    };
    
/**
 * @name Constructors and initalization.
 */
//@{
				     /**
				      * Constructor; initializes the matrix to
				      * be empty, without any structure, i.e.
				      * the matrix is not usable at all. This
				      * constructor is therefore only useful
				      * for matrices which are members of a
				      * class. All other matrices should be
				      * created at a point in the data flow
				      * where all necessary information is
				      * available.
				      *
				      * You have to initialize
				      * the matrix before usage with
				      * reinit(const SparsityPattern&).
				      */
    SparseMatrix ();

				     /**
				      * Copy constructor. This constructor is
				      * only allowed to be called if the matrix
				      * to be copied is empty. This is for the
				      * same reason as for the
				      * SparsityPattern, see there for the
				      * details.
				      *
				      * If you really want to copy a whole
				      * matrix, you can do so by using the
				      * copy_from() function.
				      */
    SparseMatrix (const SparseMatrix &);

				     /**
				      * Constructor. Takes the given
				      * matrix sparsity structure to
				      * represent the sparsity pattern
				      * of this matrix. You can change
				      * the sparsity pattern later on
				      * by calling the reinit(const
				      * SparsityPattern&) function.
				      *
				      * You have to make sure that the
				      * lifetime of the sparsity
				      * structure is at least as long
				      * as that of this matrix or as
				      * long as reinit(const
				      * SparsityPattern&) is not
				      * called with a new sparsity
				      * pattern.
				      *
				      * The constructor is marked
				      * explicit so as to disallow
				      * that someone passes a sparsity
				      * pattern in place of a sparse
				      * matrix to some function, where
				      * an empty matrix would be
				      * generated then.
				      */
    explicit SparseMatrix (const SparsityPattern &sparsity);

				     /**
				      * Copy constructor: initialize
				      * the matrix with the identity
				      * matrix. This constructor will
				      * throw an exception if the
				      * sizes of the sparsity pattern
				      * and the identity matrix do not
				      * coincide, or if the sparsity
				      * pattern does not provide for
				      * nonzero entries on the entire
				      * diagonal.
				      */
    SparseMatrix (const SparsityPattern &sparsity,
		  const IdentityMatrix  &id);
    
				     /**
				      * Destructor. Free all memory, but do not
				      * release the memory of the sparsity
				      * structure.
				      */
    virtual ~SparseMatrix ();

				     /** 
				      * Copy operator. Since copying
				      * entire sparse matrices is a
				      * very expensive operation, we
				      * disallow doing so except for
				      * the special case of empty
				      * matrices of size zero. This
				      * doesn't seem particularly
				      * useful, but is exactly what
				      * one needs if one wanted to
				      * have a
				      * <code>std::vector@<SparseMatrix@<double@>
				      * @></code>: in that case, one
				      * can create a vector (which
				      * needs the ability to copy
				      * objects) of empty matrices
				      * that are then later filled
				      * with something useful.
				      */
    SparseMatrix<number>& operator = (const SparseMatrix<number> &);

				     /**
				      * Copy operator: initialize
				      * the matrix with the identity
				      * matrix. This operator will
				      * throw an exception if the
				      * sizes of the sparsity pattern
				      * and the identity matrix do not
				      * coincide, or if the sparsity
				      * pattern does not provide for
				      * nonzero entries on the entire
				      * diagonal.
				      */
    SparseMatrix<number> &
    operator= (const IdentityMatrix  &id);
    
                                     /**
                                      * This operator assigns a scalar to
                                      * a matrix. Since this does usually
                                      * not make much sense (should we set
                                      * all matrix entries to this value?
                                      * Only the nonzero entries of the
                                      * sparsity pattern?), this operation
                                      * is only allowed if the actual
                                      * value to be assigned is zero. This
                                      * operator only exists to allow for
                                      * the obvious notation
                                      * <tt>matrix=0</tt>, which sets all
                                      * elements of the matrix to zero,
                                      * but keep the sparsity pattern
                                      * previously used.
                                      */
    SparseMatrix & operator = (const double d);

				     /**
				      * Reinitialize the sparse matrix
				      * with the given sparsity
				      * pattern. The latter tells the
				      * matrix how many nonzero
				      * elements there need to be
				      * reserved.
				      *
				      * Regarding memory allocation,
				      * the same applies as said
				      * above.
				      *
				      * You have to make sure that the
				      * lifetime of the sparsity
				      * structure is at least as long
				      * as that of this matrix or as
				      * long as reinit(const
				      * SparsityPattern &) is not
				      * called with a new sparsity
				      * structure.
				      *
				      * The elements of the matrix are
				      * set to zero by this function.
				      */
    virtual void reinit (const SparsityPattern &sparsity);

				     /**
				      * Release all memory and return
				      * to a state just like after
				      * having called the default
				      * constructor. It also forgets
				      * the sparsity pattern it was
				      * previously tied to.
				      */
    virtual void clear ();
//@}    
/**
 * @name Information on the matrix
 */
//@{
				     /**
				      * Return whether the object is
				      * empty. It is empty if either
				      * both dimensions are zero or no
				      * SparsityPattern is
				      * associated.
				      */
    bool empty () const;

				     /**
				      * Return the dimension of the
				      * image space.  To remember: the
				      * matrix is of dimension
				      * $m \times n$.
				      */
    unsigned int m () const;
    
				     /**
				      * Return the dimension of the
				      * range space.  To remember: the
				      * matrix is of dimension
				      * $m \times n$.
				      */
    unsigned int n () const;

				     /**
				      * Return the number of nonzero
				      * elements of this
				      * matrix. Actually, it returns
				      * the number of entries in the
				      * sparsity pattern; if any of
				      * the entries should happen to
				      * be zero, it is counted anyway.
				      */
    unsigned int n_nonzero_elements () const;

				     /**
				      * Return the number of actually
				      * nonzero elements of this matrix. It
				      * is possible to specify the parameter
				      * <tt>threshold</tt> in order to count
				      * only the elements that have absolute
				      * value greater than the threshold.
				      *
				      * Note, that this function does (in
				      * contrary to n_nonzero_elements())
				      * not count all entries of the
				      * sparsity pattern but only the ones
				      * that are nonzero (or whose absolute
				      * value is greater than threshold).
				      */
    unsigned int n_actually_nonzero_elements (const double threshold = 0.) const;
    
				     /**
				      * Return a (constant) reference
				      * to the underlying sparsity
				      * pattern of this matrix.
				      *
				      * Though the return value is
				      * declared <tt>const</tt>, you
				      * should be aware that it may
				      * change if you call any
				      * nonconstant function of
				      * objects which operate on it.
				      */
    const SparsityPattern & get_sparsity_pattern () const;

				     /**
				      * Determine an estimate for the
				      * memory consumption (in bytes)
				      * of this object. See
				      * MemoryConsumption.
				      */
    unsigned int memory_consumption () const;
    
//@}
/**
 * @name Modifying entries
 */
//@{
				     /**
				      * Set the element (<i>i,j</i>)
				      * to <tt>value</tt>. Throws an
				      * error if the entry does not
				      * exist or if <tt>value</tt> is
				      * not a finite number. Still, it
				      * is allowed to store zero
				      * values in non-existent fields.
				      */
    void set (const unsigned int i,
              const unsigned int j,
	      const number value);

                                       /**
                                        * Set all elements given in a
                                        * FullMatrix into the sparse matrix
                                        * locations given by
                                        * <tt>indices</tt>. In other words,
                                        * this function writes the elements
                                        * in <tt>full_matrix</tt> into the
                                        * calling matrix, using the
                                        * local-to-global indexing specified
                                        * by <tt>indices</tt> for both the
                                        * rows and the columns of the
                                        * matrix. This function assumes a
                                        * quadratic sparse matrix and a
                                        * quadratic full_matrix, the usual
                                        * situation in FE calculations.
					*
					* The optional parameter
					* <tt>elide_zero_values</tt> can be
					* used to specify whether zero
					* values should be set anyway or
					* they should be filtered away (and
					* not change the previous content in
					* the respective element if it
					* exists). The default value is
					* <tt>false</tt>, i.e., even zero
					* values are treated.
					*/
    template <typename number2>
    void set (const std::vector<unsigned int> &indices,
	      const FullMatrix<number2>       &full_matrix,
	      const bool                       elide_zero_values = false);

                                       /**
                                        * Same function as before, but now
                                        * including the possibility to use
                                        * rectangular full_matrices and
                                        * different local-to-global indexing
                                        * on rows and columns, respectively.
					*/
    template <typename number2>
    void set (const std::vector<unsigned int> &row_indices,
	      const std::vector<unsigned int> &col_indices,
	      const FullMatrix<number2>       &full_matrix,
	      const bool                       elide_zero_values = false);

                                       /**
                                        * Set several elements in the
                                        * specified row of the matrix with
                                        * column indices as given by
                                        * <tt>col_indices</tt> to the
                                        * respective value.
					*
					* The optional parameter
					* <tt>elide_zero_values</tt> can be
					* used to specify whether zero
					* values should be set anyway or
					* they should be filtered away (and
					* not change the previous content in
					* the respective element if it
					* exists). The default value is
					* <tt>false</tt>, i.e., even zero
					* values are treated.
					*/
    template <typename number2>
    void set (const unsigned int               row,
	      const std::vector<unsigned int> &col_indices,
	      const std::vector<number2>      &values,
	      const bool                       elide_zero_values = false);

                                       /**
                                        * Set several elements to values
                                        * given by <tt>values</tt> in a
                                        * given row in columns given by
                                        * col_indices into the sparse
                                        * matrix.
					*
					* The optional parameter
					* <tt>elide_zero_values</tt> can be
					* used to specify whether zero
					* values should be inserted anyway
					* or they should be filtered
					* away. The default value is
					* <tt>false</tt>, i.e., even zero
					* values are inserted/replaced.
					*/
    template <typename number2>
    void set (const unsigned int  row,
	      const unsigned int  n_cols,
	      const unsigned int *col_indices,
	      const number2      *values,
	      const bool          elide_zero_values = false);

				     /**
				      * Add <tt>value</tt> to the
				      * element (<i>i,j</i>).  Throws
				      * an error if the entry does not
				      * exist or if <tt>value</tt> is
				      * not a finite number. Still, it
				      * is allowed to store zero
				      * values in non-existent fields.
				      */
    void add (const unsigned int i,
              const unsigned int j,
	      const number value);

                                       /**
                                        * Add all elements given in a
                                        * FullMatrix<double> into sparse
                                        * matrix locations given by
                                        * <tt>indices</tt>. In other words,
                                        * this function adds the elements in
                                        * <tt>full_matrix</tt> to the
                                        * respective entries in calling
                                        * matrix, using the local-to-global
                                        * indexing specified by
                                        * <tt>indices</tt> for both the rows
                                        * and the columns of the
                                        * matrix. This function assumes a
                                        * quadratic sparse matrix and a
                                        * quadratic full_matrix, the usual
                                        * situation in FE calculations.
					*
					* The optional parameter
					* <tt>elide_zero_values</tt> can be
					* used to specify whether zero
					* values should be added anyway or
					* these should be filtered away and
					* only non-zero data is added. The
					* default value is <tt>true</tt>,
					* i.e., zero values won't be added
					* into the matrix.
					*/
    template <typename number2>
    void add (const std::vector<unsigned int> &indices,
	      const FullMatrix<number2>       &full_matrix,
	      const bool                       elide_zero_values = true);

                                       /**
                                        * Same function as before, but now
                                        * including the possibility to use
                                        * rectangular full_matrices and
                                        * different local-to-global indexing
                                        * on rows and columns, respectively.
					*/
    template <typename number2>
    void add (const std::vector<unsigned int> &row_indices,
	      const std::vector<unsigned int> &col_indices,
	      const FullMatrix<number2>       &full_matrix,
	      const bool                       elide_zero_values = true);

                                       /**
                                        * Set several elements in the
                                        * specified row of the matrix with
                                        * column indices as given by
                                        * <tt>col_indices</tt> to the
                                        * respective value.
					*
					* The optional parameter
					* <tt>elide_zero_values</tt> can be
					* used to specify whether zero
					* values should be added anyway or
					* these should be filtered away and
					* only non-zero data is added. The
					* default value is <tt>true</tt>,
					* i.e., zero values won't be added
					* into the matrix.
					*/
    template <typename number2>
    void add (const unsigned int               row,
	      const std::vector<unsigned int> &col_indices,
	      const std::vector<number2>      &values,
	      const bool                       elide_zero_values = true);

                                       /**
                                        * Add an array of values given by
                                        * <tt>values</tt> in the given
                                        * global matrix row at columns
                                        * specified by col_indices in the
                                        * sparse matrix.
					*
					* The optional parameter
					* <tt>elide_zero_values</tt> can be
					* used to specify whether zero
					* values should be added anyway or
					* these should be filtered away and
					* only non-zero data is added. The
					* default value is <tt>true</tt>,
					* i.e., zero values won't be added
					* into the matrix.
					*/
    template <typename number2>
    void add (const unsigned int  row,
	      const unsigned int  n_cols,
	      const unsigned int *col_indices,
	      const number2      *values,
	      const bool          elide_zero_values = true,
	      const bool          col_indices_are_sorted = false);

				     /**
				      * Multiply the entire matrix by a
				      * fixed factor.
				      */
    SparseMatrix & operator *= (const number factor);
    
				     /**
				      * Divide the entire matrix by a
				      * fixed factor.
				      */
    SparseMatrix & operator /= (const number factor);
    
				     /**
				      * Symmetrize the matrix by
				      * forming the mean value between
				      * the existing matrix and its
				      * transpose, $A = \frac 12(A+A^T)$.
				      *
				      * This operation assumes that
				      * the underlying sparsity
				      * pattern represents a symmetric
				      * object. If this is not the
				      * case, then the result of this
				      * operation will not be a
				      * symmetric matrix, since it
				      * only explicitly symmetrizes
				      * by looping over the lower left
				      * triangular part for efficiency
				      * reasons; if there are entries
				      * in the upper right triangle,
				      * then these elements are missed
				      * in the
				      * symmetrization. Symmetrization
				      * of the sparsity pattern can be
				      * obtain by
				      * SparsityPattern::symmetrize().
				      */
    void symmetrize ();
    
				     /**
				      * Copy the given matrix to this
				      * one.  The operation throws an
				      * error if the sparsity patterns
				      * of the two involved matrices
				      * do not point to the same
				      * object, since in this case the
				      * copy operation is
				      * cheaper. Since this operation
				      * is notheless not for free, we
				      * do not make it available
				      * through <tt>operator =</tt>,
				      * since this may lead to
				      * unwanted usage, e.g. in copy
				      * arguments to functions, which
				      * should really be arguments by
				      * reference.
				      *
				      * The source matrix may be a matrix
				      * of arbitrary type, as long as its
				      * data type is convertible to the
				      * data type of this matrix.
				      *
				      * The function returns a reference to
				      * <tt>*this</tt>.
				      */
    template <typename somenumber>
    SparseMatrix<number> &
    copy_from (const SparseMatrix<somenumber> &source);

				     /**
				      * This function is complete
				      * analogous to the
				      * SparsityPattern::copy_from()
				      * function in that it allows to
				      * initialize a whole matrix in
				      * one step. See there for more
				      * information on argument types
				      * and their meaning. You can
				      * also find a small example on
				      * how to use this function
				      * there.
				      *
				      * The only difference to the
				      * cited function is that the
				      * objects which the inner
				      * iterator points to need to be
				      * of type <tt>std::pair<unsigned
				      * int, value</tt>, where
				      * <tt>value</tt> needs to be
				      * convertible to the element
				      * type of this class, as
				      * specified by the
				      * <tt>number</tt> template
				      * argument.
				      *
				      * Previous content of the matrix
				      * is overwritten. Note that the
				      * entries specified by the input
				      * parameters need not
				      * necessarily cover all elements
				      * of the matrix. Elements not
				      * covered remain untouched.
				      */
    template <typename ForwardIterator>
    void copy_from (const ForwardIterator begin,
		    const ForwardIterator end);    

				     /**
				      * Copy the nonzero entries of a
				      * full matrix into this
				      * object. Previous content is
				      * deleted. Note that the
				      * underlying sparsity pattern
				      * must be appropriate to hold
				      * the nonzero entries of the
				      * full matrix.
				      */
    template <typename somenumber>
    void copy_from (const FullMatrix<somenumber> &matrix);
    
				     /**
				      * Add <tt>matrix</tt> scaled by
				      * <tt>factor</tt> to this matrix,
				      * i.e. the matrix <tt>factor*matrix</tt>
				      * is added to <tt>this</tt>. This
				      * function throws an error if the
				      * sparsity patterns of the two involved
				      * matrices do not point to the same
				      * object, since in this case the
				      * operation is cheaper.
				      *
				      * The source matrix may be a sparse
				      * matrix over an arbitrary underlying
				      * scalar type, as long as its data type
				      * is convertible to the data type of
				      * this matrix.
				      */
    template <typename somenumber>
    void add (const number factor,
	      const SparseMatrix<somenumber> &matrix);    
    
//@}
/**
 * @name Entry Access
 */
//@{
    
				     /**
				      * Return the value of the entry
				      * (<i>i,j</i>).  This may be an
				      * expensive operation and you
				      * should always take care where
				      * to call this function.  In
				      * order to avoid abuse, this
				      * function throws an exception
				      * if the required element does
				      * not exist in the matrix.
				      *
				      * In case you want a function
				      * that returns zero instead (for
				      * entries that are not in the
				      * sparsity pattern of the
				      * matrix), use the el()
				      * function.
				      *
				      * If you are looping over all elements,
				      * consider using one of the iterator
				      * classes instead, since they are
				      * tailored better to a sparse matrix
				      * structure.
				      */
    number operator () (const unsigned int i,
			const unsigned int j) const;

				     /**
				      * This function is mostly like
				      * operator()() in that it
				      * returns the value of the
				      * matrix entry (<i>i,j</i>). The
				      * only difference is that if
				      * this entry does not exist in
				      * the sparsity pattern, then
				      * instead of raising an
				      * exception, zero is
				      * returned. While this may be
				      * convenient in some cases, note
				      * that it is simple to write
				      * algorithms that are slow
				      * compared to an optimal
				      * solution, since the sparsity
				      * of the matrix is not used.
				      *
				      * If you are looping over all elements,
				      * consider using one of the iterator
				      * classes instead, since they are
				      * tailored better to a sparse matrix
				      * structure.
				      */
    number el (const unsigned int i,
	       const unsigned int j) const;

				     /**
				      * Return the main diagonal
				      * element in the <i>i</i>th
				      * row. This function throws an
				      * error if the matrix is not
				      * quadratic (see
				      * SparsityPattern::optimize_diagonal()).
				      *
				      * This function is considerably
				      * faster than the operator()(),
				      * since for quadratic matrices, the
				      * diagonal entry may be the
				      * first to be stored in each row
				      * and access therefore does not
				      * involve searching for the
				      * right column number.
				      */
    number diag_element (const unsigned int i) const;

				     /**
				      * Same as above, but return a
				      * writeable reference. You're
				      * sure you know what you do?
				      */
    number & diag_element (const unsigned int i);

				     /**
				      * Access to values in internal
				      * mode.  Returns the value of
				      * the <tt>index</tt>th entry in
				      * <tt>row</tt>. Here,
				      * <tt>index</tt> refers to the
				      * internal representation of the
				      * matrix, not the column. Be
				      * sure to understand what you
				      * are doing here.
				      *
				      * @deprecated Use iterator or
				      * const_iterator instead!
				      */
    number raw_entry (const unsigned int row,
		      const unsigned int index) const;
    
    				     /**
				      * @internal @deprecated Use iterator or
				      * const_iterator instead!
				      *
				      * This is for hackers. Get
				      * access to the <i>i</i>th element of
				      * this matrix. The elements are
				      * stored in a consecutive way,
				      * refer to the SparsityPattern
				      * class for more details.
				      *
				      * You should use this interface
				      * very carefully and only if you
				      * are absolutely sure to know
				      * what you do. You should also
				      * note that the structure of
				      * these arrays may change over
				      * time.  If you change the
				      * layout yourself, you should
				      * also rename this function to
				      * avoid programs relying on
				      * outdated information!
				      */
    number global_entry (const unsigned int i) const;

				     /**
				      * @internal @deprecated Use iterator or
				      * const_iterator instead!
				      *
				      * Same as above, but with write
				      * access.  You certainly know
				      * what you do?
				      */
    number & global_entry (const unsigned int i);

//@}
/**
 * @name Matrix vector multiplications
 */
//@{
				     /**
				      * Matrix-vector multiplication:
				      * let <i>dst = M*src</i> with
				      * <i>M</i> being this matrix.
                                      *
				      * Note that while this function can
				      * operate on all vectors that offer
				      * iterator classes, it is only really
				      * effective for objects of type @ref
				      * Vector. For all classes for which
				      * iterating over elements, or random
				      * member access is expensive, this
				      * function is not efficient. In
				      * particular, if you want to multiply
				      * with BlockVector objects, you should
				      * consider using a BlockSparseMatrix as
				      * well.
				      * 
                                      * Source and destination must
                                      * not be the same vector.
				      */
    template <class OutVector, class InVector>
    void vmult (OutVector& dst,
		const InVector& src) const;
    
				     /**
				      * Matrix-vector multiplication:
				      * let <i>dst = M<sup>T</sup>*src</i> with
				      * <i>M</i> being this
				      * matrix. This function does the
				      * same as vmult() but takes
				      * the transposed matrix.
                                      *
				      * Note that while this function can
				      * operate on all vectors that offer
				      * iterator classes, it is only really
				      * effective for objects of type @ref
				      * Vector. For all classes for which
				      * iterating over elements, or random
				      * member access is expensive, this
				      * function is not efficient. In
				      * particular, if you want to multiply
				      * with BlockVector objects, you should
				      * consider using a BlockSparseMatrix as
				      * well.
				      * 
                                      * Source and destination must
                                      * not be the same vector.
				      */
    template <class OutVector, class InVector>
    void Tvmult (OutVector& dst,
		 const InVector& src) const;
  
				     /**
				      * Adding Matrix-vector
				      * multiplication. Add
				      * <i>M*src</i> on <i>dst</i>
				      * with <i>M</i> being this
				      * matrix.
                                      *
				      * Note that while this function can
				      * operate on all vectors that offer
				      * iterator classes, it is only really
				      * effective for objects of type @ref
				      * Vector. For all classes for which
				      * iterating over elements, or random
				      * member access is expensive, this
				      * function is not efficient. In
				      * particular, if you want to multiply
				      * with BlockVector objects, you should
				      * consider using a BlockSparseMatrix as
				      * well.
				      * 
                                      * Source and destination must
                                      * not be the same vector.
				      */
    template <class OutVector, class InVector>
    void vmult_add (OutVector& dst,
		    const InVector& src) const;
    
				     /**
				      * Adding Matrix-vector
				      * multiplication. Add
				      * <i>M<sup>T</sup>*src</i> to
				      * <i>dst</i> with <i>M</i> being
				      * this matrix. This function
				      * does the same as vmult_add()
				      * but takes the transposed
				      * matrix.
                                      *
				      * Note that while this function can
				      * operate on all vectors that offer
				      * iterator classes, it is only really
				      * effective for objects of type @ref
				      * Vector. For all classes for which
				      * iterating over elements, or random
				      * member access is expensive, this
				      * function is not efficient. In
				      * particular, if you want to multiply
				      * with BlockVector objects, you should
				      * consider using a BlockSparseMatrix as
				      * well.
				      * 
                                      * Source and destination must
                                      * not be the same vector.
				      */
    template <class OutVector, class InVector>
    void Tvmult_add (OutVector& dst,
		     const InVector& src) const;
  
				     /**
				      * Return the square of the norm
				      * of the vector $v$ with respect
				      * to the norm induced by this
				      * matrix,
				      * i.e. $\left(v,Mv\right)$. This
				      * is useful, e.g. in the finite
				      * element context, where the
				      * $L_2$ norm of a function
				      * equals the matrix norm with
				      * respect to the mass matrix of
				      * the vector representing the
				      * nodal values of the finite
				      * element function.
				      *
				      * Obviously, the matrix needs to be
				      * quadratic for this operation, and for
				      * the result to actually be a norm it
				      * also needs to be either real symmetric
				      * or complex hermitian.
				      *
				      * The underlying template types of both
				      * this matrix and the given vector
				      * should either both be real or
				      * complex-valued, but not mixed, for
				      * this function to make sense.
				      */
    template <typename somenumber>
    somenumber matrix_norm_square (const Vector<somenumber> &v) const;

				     /**
				      * Compute the matrix scalar
				      * product $\left(u,Mv\right)$.
				      */
    template <typename somenumber>
    somenumber matrix_scalar_product (const Vector<somenumber> &u,
				      const Vector<somenumber> &v) const;
    
				     /**
				      * Compute the residual of an
				      * equation <i>Mx=b</i>, where
				      * the residual is defined to be
				      * <i>r=b-Mx</i>. Write the
				      * residual into
				      * <tt>dst</tt>. The
				      * <i>l<sub>2</sub></i> norm of
				      * the residual vector is
				      * returned.
                                      *
                                      * Source <i>x</i> and destination
                                      * <i>dst</i> must not be the same
                                      * vector.
				      */
    template <typename somenumber>
    somenumber residual (Vector<somenumber>       &dst,
			 const Vector<somenumber> &x,
			 const Vector<somenumber> &b) const;
    
//@}
/**
 * @name Matrix norms
 */
//@{
    
    				     /**
				      * Return the l1-norm of the matrix, that is
				      * $|M|_1=max_{all columns j}\sum_{all 
				      * rows i} |M_ij|$,
				      * (max. sum of columns).
				      * This is the
				      * natural matrix norm that is compatible
				      * to the l1-norm for vectors, i.e.
				      * $|Mv|_1\leq |M|_1 |v|_1$.
				      * (cf. Haemmerlin-Hoffmann : Numerische Mathematik)
				      */
    real_type l1_norm () const;

    				     /**
				      * Return the linfty-norm of the
				      * matrix, that is
				      * $|M|_infty=max_{all rows i}\sum_{all 
				      * columns j} |M_ij|$,
				      * (max. sum of rows).
				      * This is the
				      * natural matrix norm that is compatible
				      * to the linfty-norm of vectors, i.e.
				      * $|Mv|_infty \leq |M|_infty |v|_infty$.
				      * (cf. Haemmerlin-Hoffmann : Numerische Mathematik)
				      */
    real_type linfty_norm () const;

                                     /**
                                      * Return the frobenius norm of the
                                      * matrix, i.e. the square root of the
                                      * sum of squares of all entries in the
                                      * matrix.
                                      */
    real_type frobenius_norm () const;
//@}
/**
 * @name Preconditioning methods
 */
//@{
    
				     /**
				      * Apply the Jacobi
				      * preconditioner, which
				      * multiplies every element of
				      * the <tt>src</tt> vector by the
				      * inverse of the respective
				      * diagonal element and
				      * multiplies the result with the
				      * relaxation factor <tt>omega</tt>.
				      */
    template <typename somenumber>
    void precondition_Jacobi (Vector<somenumber>       &dst,
			      const Vector<somenumber> &src,
			      const number              omega = 1.) const;

				     /**
				      * Apply SSOR preconditioning to
				      * <tt>src</tt>.
				      */
    template <typename somenumber>
    void precondition_SSOR (Vector<somenumber>             &dst,
			    const Vector<somenumber>       &src,
			    const number                    om = 1.,
			    const std::vector<unsigned int>&pos_right_of_diagonal=std::vector<unsigned int>()) const;

				     /**
				      * Apply SOR preconditioning
				      * matrix to <tt>src</tt>.
				      */
    template <typename somenumber>
    void precondition_SOR (Vector<somenumber>       &dst,
			   const Vector<somenumber> &src,
 			   const number              om = 1.) const;
    
				     /**
				      * Apply transpose SOR
				      * preconditioning matrix to
				      * <tt>src</tt>.
				      */
    template <typename somenumber>
    void precondition_TSOR (Vector<somenumber>       &dst,
			    const Vector<somenumber> &src,
			    const number              om = 1.) const;
    
				     /**
				      * Perform SSOR preconditioning
				      * in-place.  Apply the
				      * preconditioner matrix without
				      * copying to a second vector.
				      * <tt>omega</tt> is the relaxation
				      * parameter.
				      */
    template <typename somenumber>
    void SSOR (Vector<somenumber> &v,
	       const number        omega = 1.) const;

				     /**
				      * Perform an SOR preconditioning
				      * in-place.  <tt>omega</tt> is
				      * the relaxation parameter.
				      */
    template <typename somenumber>
    void SOR (Vector<somenumber> &v,
	      const number        om = 1.) const;

				     /**
				      * Perform a transpose SOR
				      * preconditioning in-place.
				      * <tt>omega</tt> is the
				      * relaxation parameter.
				      */
    template <typename somenumber>
    void TSOR (Vector<somenumber> &v,
	      const number        om = 1.) const;

				     /**
				      * Perform a permuted SOR
				      * preconditioning in-place.
				      *
				      * The standard SOR method is
				      * applied in the order
				      * prescribed by <tt>permutation</tt>,
				      * that is, first the row
				      * <tt>permutation[0]</tt>, then
				      * <tt>permutation[1]</tt> and so
				      * on. For efficiency reasons,
				      * the permutation as well as its
				      * inverse are required.
				      *
				      * <tt>omega</tt> is the
				      * relaxation parameter.
				      */
    template <typename somenumber>
    void PSOR (Vector<somenumber> &v,
	      const std::vector<unsigned int>& permutation,
	      const std::vector<unsigned int>& inverse_permutation,
	      const number        om = 1.) const;

				     /**
				      * Perform a transposed permuted SOR
				      * preconditioning in-place.
				      *
				      * The transposed SOR method is
				      * applied in the order
				      * prescribed by
				      * <tt>permutation</tt>, that is,
				      * first the row
				      * <tt>permutation[m()-1]</tt>,
				      * then
				      * <tt>permutation[m()-2]</tt>
				      * and so on. For efficiency
				      * reasons, the permutation as
				      * well as its inverse are
				      * required.
				      *
				      * <tt>omega</tt> is the
				      * relaxation parameter.
				      */
    template <typename somenumber>
    void TPSOR (Vector<somenumber> &v,
	      const std::vector<unsigned int>& permutation,
	      const std::vector<unsigned int>& inverse_permutation,
	      const number        om = 1.) const;

				     /**
				      * Do one SOR step on <tt>v</tt>.
				      * Performs a direct SOR step
				      * with right hand side
				      * <tt>b</tt>.
				      */
    template <typename somenumber>
    void SOR_step (Vector<somenumber> &v,
		   const Vector<somenumber> &b,
		   const number        om = 1.) const;

				     /**
				      * Do one adjoint SOR step on
				      * <tt>v</tt>.  Performs a direct
				      * TSOR step with right hand side
				      * <tt>b</tt>.
				      */
    template <typename somenumber>
    void TSOR_step (Vector<somenumber> &v,
		    const Vector<somenumber> &b,
		    const number        om = 1.) const;

				     /**
				      * Do one SSOR step on
				      * <tt>v</tt>.  Performs a direct
				      * SSOR step with right hand side
				      * <tt>b</tt> by performing TSOR
				      * after SOR.
				      */
    template <typename somenumber>
    void SSOR_step (Vector<somenumber> &v,
		    const Vector<somenumber> &b,
		    const number        om = 1.) const;
//@}
/**
 * @name Iterators
 */
//@{

				     /**
				      * STL-like iterator with the first entry
				      * of the matrix. This is the version for
				      * constant matrices.
				      */
    const_iterator begin () const;

				     /**
				      * Final iterator. This is the version for
				      * constant matrices.
				      */
    const_iterator end () const;

				     /**
				      * STL-like iterator with the first entry
				      * of the matrix. This is the version for
				      * non-constant matrices.
				      */
    iterator begin ();

				     /**
				      * Final iterator. This is the version for
				      * non-constant matrices.
				      */
    iterator end ();
    
				     /**
				      * STL-like iterator with the first entry
				      * of row <tt>r</tt>. This is the version
				      * for constant matrices.
				      *
				      * Note that if the given row is empty,
				      * i.e. does not contain any nonzero
				      * entries, then the iterator returned by
				      * this function equals
				      * <tt>end(r)</tt>. Note also that the
				      * iterator may not be dereferencable in
				      * that case.
				      */
    const_iterator begin (const unsigned int r) const;

				     /**
				      * Final iterator of row <tt>r</tt>. It
				      * points to the first element past the
				      * end of line @p r, or past the end of
				      * the entire sparsity pattern. This is
				      * the version for constant matrices.
				      *
				      * Note that the end iterator is not
				      * necessarily dereferencable. This is in
				      * particular the case if it is the end
				      * iterator for the last row of a matrix.
				      */
    const_iterator end (const unsigned int r) const;
    
				     /**
				      * STL-like iterator with the first entry
				      * of row <tt>r</tt>. This is the version
				      * for non-constant matrices.
				      *
				      * Note that if the given row is empty,
				      * i.e. does not contain any nonzero
				      * entries, then the iterator returned by
				      * this function equals
				      * <tt>end(r)</tt>. Note also that the
				      * iterator may not be dereferencable in
				      * that case.
				      */
    iterator begin (const unsigned int r);

				     /**
				      * Final iterator of row <tt>r</tt>. It
				      * points to the first element past the
				      * end of line @p r, or past the end of
				      * the entire sparsity pattern. This is
				      * the version for non-constant matrices.
				      *
				      * Note that the end iterator is not
				      * necessarily dereferencable. This is in
				      * particular the case if it is the end
				      * iterator for the last row of a matrix.
				      */
    iterator end (const unsigned int r);
//@}
/**
 * @name Input/Output
 */
//@{

				     /**
				      * Print the matrix to the given
				      * stream, using the format
				      * <tt>(line,col) value</tt>,
				      * i.e. one nonzero entry of the
				      * matrix per line.
				      */
    void print (std::ostream &out) const;

				     /**
				      * Print the matrix in the usual
				      * format, i.e. as a matrix and
				      * not as a list of nonzero
				      * elements. For better
				      * readability, elements not in
				      * the matrix are displayed as
				      * empty space, while matrix
				      * elements which are explicitly
				      * set to zero are displayed as
				      * such.
				      *
				      * The parameters allow for a
				      * flexible setting of the output
				      * format: <tt>precision</tt> and
				      * <tt>scientific</tt> are used
				      * to determine the number
				      * format, where <tt>scientific =
				      * false</tt> means fixed point
				      * notation.  A zero entry for
				      * <tt>width</tt> makes the
				      * function compute a width, but
				      * it may be changed to a
				      * positive value, if output is
				      * crude.
				      *
				      * Additionally, a character for
				      * an empty value may be
				      * specified.
				      *
				      * Finally, the whole matrix can
				      * be multiplied with a common
				      * denominator to produce more
				      * readable output, even
				      * integers.
				      *
				      * @attention This function may
				      * produce <b>large</b> amounts
				      * of output if applied to a
				      * large matrix!
				      */
    void print_formatted (std::ostream       &out,
			  const unsigned int  precision   = 3,
			  const bool          scientific  = true,
			  const unsigned int  width       = 0,
			  const char         *zero_string = " ",
			  const double        denominator = 1.) const;

				     /**
				      * Print the actual pattern of
				      * the matrix. For each entry
				      * with an absolute value larger
				      * than threshold, a '*' is
				      * printed, a ':' for every value
				      * smaller and a '.' for every
				      * entry not allocated.
				      */
    void print_pattern(std::ostream& out,
		       const double threshold = 0.) const;
    
				     /**
				      * Write the data of this object
				      * en bloc to a file. This is
				      * done in a binary mode, so the
				      * output is neither readable by
				      * humans nor (probably) by other
				      * computers using a different
				      * operating system of number
				      * format.
				      *
				      * The purpose of this function
				      * is that you can swap out
				      * matrices and sparsity pattern
				      * if you are short of memory,
				      * want to communicate between
				      * different programs, or allow
				      * objects to be persistent
				      * across different runs of the
				      * program.
				      */
    void block_write (std::ostream &out) const;

				     /**
				      * Read data that has previously
				      * been written by block_write()
				      * from a file. This is done
				      * using the inverse operations
				      * to the above function, so it
				      * is reasonably fast because the
				      * bitstream is not interpreted
				      * except for a few numbers up
				      * front.
				      *
				      * The object is resized on this
				      * operation, and all previous
				      * contents are lost. Note,
				      * however, that no checks are
				      * performed whether new data and
				      * the underlying SparsityPattern
				      * object fit together. It is
				      * your responsibility to make
				      * sure that the sparsity pattern
				      * and the data to be read match.
				      *
				      * A primitive form of error
				      * checking is performed which
				      * will recognize the bluntest
				      * attempts to interpret some
				      * data as a matrix stored
				      * bitwise to a file that wasn't
				      * actually created that way, but
				      * not more.
				      */
    void block_read (std::istream &in);
//@}
    				     /** @addtogroup Exceptions
				      * @{ */

				     /**
				      * Exception
				      */
    DeclException2 (ExcInvalidIndex,
		    int, int,
		    << "The entry with index <" << arg1 << ',' << arg2
		    << "> does not exist.");
				     /**
				      * Exception
				      */
    DeclException1 (ExcInvalidIndex1,
		    int,
		    << "The index " << arg1 << " is not in the allowed range.");
				     /**
				      * Exception
				      */
    DeclException0 (ExcDifferentSparsityPatterns);
				     /**
				      * Exception
				      */
    DeclException2 (ExcIteratorRange,
		    int, int,
		    << "The iterators denote a range of " << arg1
		    << " elements, but the given number of rows was " << arg2);
                                     /**
                                      * Exception
                                      */
    DeclException0 (ExcSourceEqualsDestination);
				     //@}    
  private:
				     /**
				      * Pointer to the sparsity
				      * pattern used for this
				      * matrix. In order to guarantee
				      * that it is not deleted while
				      * still in use, we subscribe to
				      * it using the SmartPointer
				      * class.
				      */
    SmartPointer<const SparsityPattern> cols;

				     /**
				      * Array of values for all the
				      * nonzero entries. The position
				      * within the matrix, i.e.  the
				      * row and column number for a
				      * given entry can only be
				      * deduced using the sparsity
				      * pattern. The same holds for
				      * the more common operation of
				      * finding an entry by its
				      * coordinates.
				      */
    number *val;

				     /**
				      * Allocated size of #val. This
				      * can be larger than the
				      * actually used part if the size
				      * of the matrix was reduced
				      * somewhen in the past by
				      * associating a sparsity pattern
				      * with a smaller size to this
				      * object, using the reinit()
				      * function.
				      */
    unsigned int max_len;

				     /**
				      * Version of vmult() which only
				      * performs its actions on the
				      * region defined by
				      * <tt>[begin_row,end_row)</tt>. This
				      * function is called by vmult()
				      * in the case of enabled
				      * multithreading.
				      */
    template <class OutVector, class InVector>
    void threaded_vmult (OutVector& dst,
			 const InVector& src,
			 const unsigned int        begin_row,
			 const unsigned int        end_row) const;

				     /**
				      * Version of
				      * matrix_norm_square() which
				      * only performs its actions on
				      * the region defined by
				      * <tt>[begin_row,end_row)</tt>. This
				      * function is called by
				      * matrix_norm_square() in the
				      * case of enabled
				      * multithreading.
				      */
    template <typename somenumber>
    void threaded_matrix_norm_square (const Vector<somenumber> &v,
				      const unsigned int        begin_row,
				      const unsigned int        end_row,
				      somenumber               *partial_sum) const;

    				     /**
				      * Version of
				      * matrix_scalar_product() which
				      * only performs its actions on
				      * the region defined by
				      * <tt>[begin_row,end_row)</tt>. This
				      * function is called by
				      * matrix_scalar_product() in the
				      * case of enabled
				      * multithreading.
				      */
    template <typename somenumber>
    void threaded_matrix_scalar_product (const Vector<somenumber> &u,
					 const Vector<somenumber> &v,
					 const unsigned int        begin_row,
					 const unsigned int        end_row,
					 somenumber               *partial_sum) const;

				     /**
				      * Version of residual() which
				      * only performs its actions on
				      * the region defined by
				      * <tt>[begin_row,end_row)</tt>
				      * (these numbers are the
				      * components of
				      * <tt>interval</tt>). This
				      * function is called by
				      * residual() in the case of
				      * enabled multithreading.
				      */
    template <typename somenumber>
    void threaded_residual (Vector<somenumber>       &dst,
			    const Vector<somenumber> &u,
			    const Vector<somenumber> &b,
			    const std::pair<unsigned int,unsigned int> interval,
			    somenumber               *partial_norm) const;

				     // make all other sparse matrices
				     // friends
    template <typename somenumber> friend class SparseMatrix;
    template <typename somenumber> friend class SparseLUDecomposition;
    template <typename> friend class SparseILU;
};

/*@}*/

#ifndef DOXYGEN
/*---------------------- Inline functions -----------------------------------*/



template <typename number>
inline
unsigned int SparseMatrix<number>::m () const
{
  Assert (cols != 0, ExcNotInitialized());
  return cols->rows;
}


template <typename number>
inline
unsigned int SparseMatrix<number>::n () const
{
  Assert (cols != 0, ExcNotInitialized());
  return cols->cols;
}


				        // Inline the set() and add()
				        // functions, since they will be 
                                        // called frequently.
template <typename number>  
inline
void
SparseMatrix<number>::set (const unsigned int i,
			   const unsigned int j,
			   const number       value)
{
  Assert (numbers::is_finite(value),
	  ExcMessage("The given value is not finite but either "
		     "infinite or Not A Number (NaN)"));

  const unsigned int index = cols->operator()(i, j);

				   // it is allowed to set elements of
				   // the matrix that are not part of
				   // the sparsity pattern, if the
				   // value to which we set it is zero
  if (index == SparsityPattern::invalid_entry)
    {
      Assert ((index != SparsityPattern::invalid_entry) ||
	      (value == 0.),
	      ExcInvalidIndex(i, j));
      return;
    }

  val[index] = value;
}



template <typename number>  
template <typename number2>  
inline
void
SparseMatrix<number>::set (const std::vector<unsigned int> &indices,
			   const FullMatrix<number2>       &values,
			   const bool                       elide_zero_values)
{
  Assert (indices.size() == values.m(),
	  ExcDimensionMismatch(indices.size(), values.m()));
  Assert (values.m() == values.n(), ExcNotQuadratic());

  for (unsigned int i=0; i<indices.size(); ++i)
    set (indices[i], indices.size(), &indices[0], &values(i,0),
	 elide_zero_values);
}



template <typename number>  
template <typename number2>  
inline
void
SparseMatrix<number>::set (const std::vector<unsigned int> &row_indices,
			   const std::vector<unsigned int> &col_indices,
			   const FullMatrix<number2>       &values,
			   const bool                       elide_zero_values)
{
  Assert (row_indices.size() == values.m(),
	  ExcDimensionMismatch(row_indices.size(), values.m()));
  Assert (col_indices.size() == values.n(),
	  ExcDimensionMismatch(col_indices.size(), values.n()));

  for (unsigned int i=0; i<row_indices.size(); ++i)
    set (row_indices[i], col_indices.size(), &col_indices[0], &values(i,0),
	 elide_zero_values);
}



template <typename number>  
template <typename number2>  
inline
void
SparseMatrix<number>::set (const unsigned int               row,
			   const std::vector<unsigned int> &col_indices,
			   const std::vector<number2>      &values,
			   const bool                       elide_zero_values)
{
  Assert (col_indices.size() == values.size(),
	  ExcDimensionMismatch(col_indices.size(), values.size()));

  set (row, col_indices.size(), &col_indices[0], &values[0],
       elide_zero_values);
}



template <typename number>  
inline
void
SparseMatrix<number>::add (const unsigned int i,
			   const unsigned int j,
			   const number       value)
{
  Assert (numbers::is_finite(value),
	  ExcMessage("The given value is not finite but either "
		     "infinite or Not A Number (NaN)"));

  if (value == 0)
    return;

  const unsigned int index = cols->operator()(i, j);

				   // it is allowed to add elements to
				   // the matrix that are not part of
				   // the sparsity pattern, if the
				   // value to which we set it is zero
  if (index == SparsityPattern::invalid_entry)
    {
      Assert ((index != SparsityPattern::invalid_entry) ||
	      (value == 0.),
	      ExcInvalidIndex(i, j));
      return;
    }

  val[index] += value;
}



template <typename number>  
template <typename number2>  
inline
void
SparseMatrix<number>::add (const std::vector<unsigned int> &indices,
			   const FullMatrix<number2>       &values,
			   const bool                       elide_zero_values)
{
  Assert (indices.size() == values.m(),
	  ExcDimensionMismatch(indices.size(), values.m()));
  Assert (values.m() == values.n(), ExcNotQuadratic());

  for (unsigned int i=0; i<indices.size(); ++i)
    add (indices[i], indices.size(), &indices[0], &values(i,0),
	 elide_zero_values);
}



template <typename number>  
template <typename number2>  
inline
void
SparseMatrix<number>::add (const std::vector<unsigned int> &row_indices,
			   const std::vector<unsigned int> &col_indices,
			   const FullMatrix<number2>       &values,
			   const bool                       elide_zero_values)
{
  Assert (row_indices.size() == values.m(),
	  ExcDimensionMismatch(row_indices.size(), values.m()));
  Assert (col_indices.size() == values.n(),
	  ExcDimensionMismatch(col_indices.size(), values.n()));

  for (unsigned int i=0; i<row_indices.size(); ++i)
    add (row_indices[i], col_indices.size(), &col_indices[0], &values(i,0),
	 elide_zero_values);
}



template <typename number>  
template <typename number2>  
inline
void
SparseMatrix<number>::add (const unsigned int               row,
			   const std::vector<unsigned int> &col_indices,
			   const std::vector<number2>      &values,
			   const bool                       elide_zero_values)
{
  Assert (col_indices.size() == values.size(),
	  ExcDimensionMismatch(col_indices.size(), values.size()));

  add (row, col_indices.size(), &col_indices[0], &values[0],
       elide_zero_values);
}



template <typename number>
inline
SparseMatrix<number> &
SparseMatrix<number>::operator *= (const number factor)
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());

  number             *val_ptr    = &val[0];
  const number *const end_ptr    = &val[cols->n_nonzero_elements()];

  while (val_ptr != end_ptr)
    *val_ptr++ *= factor;

  return *this;
}



template <typename number>
inline
SparseMatrix<number> &
SparseMatrix<number>::operator /= (const number factor)
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (factor !=0, ExcDivideByZero());

  const number factor_inv = 1. / factor;

  number             *val_ptr    = &val[0];
  const number *const end_ptr    = &val[cols->n_nonzero_elements()];

  while (val_ptr != end_ptr)
    *val_ptr++ *= factor_inv;

  return *this;
}



template <typename number>
inline
number SparseMatrix<number>::operator () (const unsigned int i,
					  const unsigned int j) const
{
  Assert (cols != 0, ExcNotInitialized());
  AssertThrow (cols->operator()(i,j) != SparsityPattern::invalid_entry,
               ExcInvalidIndex(i,j));
  return val[cols->operator()(i,j)];
}



template <typename number>
inline
number SparseMatrix<number>::el (const unsigned int i,
				 const unsigned int j) const
{
  Assert (cols != 0, ExcNotInitialized());
  const unsigned int index = cols->operator()(i,j);

  if (index != SparsityPattern::invalid_entry)
    return val[index];
  else
    return 0;
}



template <typename number>
inline
number SparseMatrix<number>::diag_element (const unsigned int i) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),  ExcNotQuadratic());
  Assert (i<m(), ExcInvalidIndex1(i));
  
				   // Use that the first element in each
				   // row of a quadratic matrix is the main
				   // diagonal
  return val[cols->rowstart[i]];
}



template <typename number>
inline
number & SparseMatrix<number>::diag_element (const unsigned int i)
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),  ExcNotQuadratic());
  Assert (i<m(), ExcInvalidIndex1(i));
  
				   // Use that the first element in each
				   // row of a quadratic matrix is the main
				   // diagonal
  return val[cols->rowstart[i]];
}



template <typename number>
inline
number
SparseMatrix<number>::raw_entry (const unsigned int row,
				 const unsigned int index) const
{
  Assert(row<cols->rows, ExcIndexRange(row,0,cols->rows));
  Assert(index<cols->row_length(row),
	 ExcIndexRange(index,0,cols->row_length(row)));

  return val[cols->rowstart[row]+index];
}



template <typename number>
inline
number SparseMatrix<number>::global_entry (const unsigned int j) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (j < cols->n_nonzero_elements(),
	  ExcIndexRange (j, 0, cols->n_nonzero_elements()));
  
  return val[j];
}



template <typename number>
inline
number & SparseMatrix<number>::global_entry (const unsigned int j)
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (j < cols->n_nonzero_elements(),
	  ExcIndexRange (j, 0, cols->n_nonzero_elements()));

  return val[j];
}



template <typename number>
template <typename ForwardIterator>
void
SparseMatrix<number>::copy_from (const ForwardIterator begin,
				 const ForwardIterator end)
{
  Assert (static_cast<unsigned int>(std::distance (begin, end)) == m(),
	  ExcIteratorRange (std::distance (begin, end), m()));

				   // for use in the inner loop, we
				   // define a typedef to the type of
				   // the inner iterators
  typedef typename std::iterator_traits<ForwardIterator>::value_type::const_iterator inner_iterator;
  unsigned int row=0;
  for (ForwardIterator i=begin; i!=end; ++i, ++row)
    {
      const inner_iterator end_of_row = i->end();
      for (inner_iterator j=i->begin(); j!=end_of_row; ++j)
					 // write entries
	set (row, j->first, j->second);
    };
}


//---------------------------------------------------------------------------


namespace internals
{
  namespace SparseMatrixIterators
  {
    template <typename number>
    inline
    Accessor<number,true>::
    Accessor (const MatrixType   *matrix,
              const unsigned int  row,
              const unsigned int  index)
                    :
                    SparsityPatternIterators::Accessor (&matrix->get_sparsity_pattern(),
                                                        row, index),
                    matrix (matrix)
    {}



    template <typename number>
    inline
    Accessor<number,true>::
    Accessor (const MatrixType *matrix)
                    :
                    SparsityPatternIterators::Accessor (&matrix->get_sparsity_pattern()),
                    matrix (matrix)
    {}
    


    template <typename number>
    inline
    Accessor<number,true>::
    Accessor (const internals::SparseMatrixIterators::Accessor<number,false> &a)
                    :
                    SparsityPatternIterators::Accessor (a),
                    matrix (&a.get_matrix())
    {}
    


    template <typename number>
    inline
    number
    Accessor<number, true>::value () const
    {
      return matrix->raw_entry(a_row, a_index);
    }


    
    template <typename number>
    inline
    const SparseMatrix<number> &
    Accessor<number, true>::get_matrix () const
    {
      return *matrix;
    }


    
    template <typename number>
    inline
    Accessor<number, false>::Reference::operator number() const
    {
      return accessor->matrix->raw_entry(accessor->a_row,
                                         accessor->a_index);
    }
    

    
    template <typename number>
    inline
    const typename Accessor<number, false>::Reference &
    Accessor<number, false>::Reference::operator = (const number n) const
    {
//TODO: one could optimize this by not going again through the mapping from row/col index to global index
      accessor->matrix->set (accessor->row(), accessor->column(), n);
      return *this;
    }
    

    
    template <typename number>
    inline
    const typename Accessor<number, false>::Reference &
    Accessor<number, false>::Reference::operator += (const number n) const
    {
//TODO: one could optimize this by not going again through the mapping from row/col index to global index
      accessor->matrix->set (accessor->row(), accessor->column(),
                             static_cast<number>(*this) + n);
      return *this;
    }
    

    
    template <typename number>
    inline
    const typename Accessor<number, false>::Reference &
    Accessor<number, false>::Reference::operator -= (const number n) const
    {
//TODO: one could optimize this by not going again through the mapping from row/col index to global index
      accessor->matrix->set (accessor->row(), accessor->column(),
                             static_cast<number>(*this) - n);
      return *this;
    }



    template <typename number>
    inline
    const typename Accessor<number, false>::Reference &
    Accessor<number, false>::Reference::operator *= (const number n) const
    {
//TODO: one could optimize this by not going again through the mapping from row/col index to global index
      accessor->matrix->set (accessor->row(), accessor->column(),
                             static_cast<number>(*this)*n);
      return *this;
    }
    

    
    template <typename number>
    inline
    const typename Accessor<number, false>::Reference &
    Accessor<number, false>::Reference::operator /= (const number n) const
    {
//TODO: one could optimize this by not going again through the mapping from row/col index to global index
      accessor->matrix->set (accessor->row(), accessor->column(),
                             static_cast<number>(*this)/n);
      return *this;
    }
    

    
    template <typename number>
    inline
    Accessor<number,false>::
    Accessor (MatrixType         *matrix,
              const unsigned int  row,
              const unsigned int  index)
                    :
                    SparsityPatternIterators::Accessor (&matrix->get_sparsity_pattern(),
                                                        row, index),
                    matrix (matrix)
    {}



    template <typename number>
    inline
    Accessor<number,false>::
    Accessor (MatrixType         *matrix)
                    :
                    SparsityPatternIterators::Accessor (&matrix->get_sparsity_pattern()),
                    matrix (matrix)
    {}
    


    template <typename number>
    inline
    typename Accessor<number, false>::Reference
    Accessor<number, false>::value() const
    {
      return Reference(this,true);
    }



          
    template <typename number>
    inline
    typename Accessor<number, false>::MatrixType &
    Accessor<number, false>::get_matrix () const
    {
      return *matrix;
    }


    
    template <typename number, bool Constness>
    inline
    Iterator<number, Constness>::
    Iterator (MatrixType        *matrix,
              const unsigned int r,
              const unsigned int i)
                    :
                    accessor(matrix, r, i)
    {}



    template <typename number, bool Constness>
    inline
    Iterator<number, Constness>::
    Iterator (MatrixType *matrix)
                    :
                    accessor(matrix)
    {}



    template <typename number, bool Constness>
    inline
    Iterator<number, Constness>::
    Iterator (const internals::SparseMatrixIterators::Iterator<number,false> &i)
                    :
                    accessor(*i)
    {}
    
    

    template <typename number, bool Constness>
    inline
    Iterator<number, Constness> &
    Iterator<number,Constness>::operator++ ()
    {
      accessor.advance ();
      return *this;
    }


    template <typename number, bool Constness>
    inline
    Iterator<number,Constness>
    Iterator<number,Constness>::operator++ (int)
    {
      const Iterator iter = *this;
      accessor.advance ();
      return iter;
    }


    template <typename number, bool Constness>
    inline
    const Accessor<number,Constness> &
    Iterator<number,Constness>::operator* () const
    {
      return accessor;
    }


    template <typename number, bool Constness>
    inline
    const Accessor<number,Constness> *
    Iterator<number,Constness>::operator-> () const
    {
      return &accessor;
    }


    template <typename number, bool Constness>
    inline
    bool
    Iterator<number,Constness>::
    operator == (const Iterator& other) const
    {
      return (accessor == other.accessor);
    }


    template <typename number, bool Constness>
    inline
    bool
    Iterator<number,Constness>::
    operator != (const Iterator& other) const
    {
      return ! (*this == other);
    }


    template <typename number, bool Constness>
    inline
    bool
    Iterator<number,Constness>::
    operator < (const Iterator& other) const
    {
      Assert (&accessor.get_matrix() == &other.accessor.get_matrix(),
              ExcInternalError());
      
      return (accessor < other.accessor);
    }


    template <typename number, bool Constness>
    inline
    bool
    Iterator<number,Constness>::
    operator > (const Iterator& other) const
    {
      return (other < *this);
    }
    
  }
}


template <typename number>
inline
typename SparseMatrix<number>::const_iterator
SparseMatrix<number>::begin () const
{
                                   // search for the first line with a nonzero
                                   // number of entries
  for (unsigned int r=0; r<m(); ++r)
    if (cols->row_length(r) > 0)
      return const_iterator(this, r, 0);

                                   // alright, this matrix is completely
                                   // empty. that's strange but ok. simply
                                   // return the end() iterator
  return end();
}


template <typename number>
inline
typename SparseMatrix<number>::const_iterator
SparseMatrix<number>::end () const
{
  return const_iterator(this);
}


template <typename number>
inline
typename SparseMatrix<number>::iterator
SparseMatrix<number>::begin ()
{
                                   // search for the first line with a nonzero
                                   // number of entries
  for (unsigned int r=0; r<m(); ++r)
    if (cols->row_length(r) > 0)
      return iterator(this, r, 0);

                                   // alright, this matrix is completely
                                   // empty. that's strange but ok. simply
                                   // return the end() iterator
  return end();
}


template <typename number>
inline
typename SparseMatrix<number>::iterator
SparseMatrix<number>::end ()
{
  return iterator(this, m(), 0);
}


template <typename number>
inline
typename SparseMatrix<number>::const_iterator
SparseMatrix<number>::begin (const unsigned int r) const
{
  Assert (r<m(), ExcIndexRange(r,0,m()));

  if (cols->row_length(r) > 0)
    return const_iterator(this, r, 0);
  else
    return end (r);
}



template <typename number>
inline
typename SparseMatrix<number>::const_iterator
SparseMatrix<number>::end (const unsigned int r) const
{
  Assert (r<m(), ExcIndexRange(r,0,m()));

                                   // place the iterator on the first entry
                                   // past this line, or at the end of the
                                   // matrix
  for (unsigned int i=r+1; i<m(); ++i)
    if (cols->row_length(i) > 0)
      return const_iterator(this, i, 0);

                                   // if there is no such line, then take the
                                   // end iterator of the matrix
  return end();
}



template <typename number>
inline
typename SparseMatrix<number>::iterator
SparseMatrix<number>::begin (const unsigned int r)
{
  Assert (r<m(), ExcIndexRange(r,0,m()));

  if (cols->row_length(r) > 0)
    return iterator(this, r, 0);
  else
    return end (r);
}



template <typename number>
inline
typename SparseMatrix<number>::iterator
SparseMatrix<number>::end (const unsigned int r)
{
  Assert (r<m(), ExcIndexRange(r,0,m()));

                                   // place the iterator on the first entry
                                   // past this line, or at the end of the
                                   // matrix
  for (unsigned int i=r+1; i<m(); ++i)
    if (cols->row_length(i) > 0)
      return iterator(this, i, 0);

                                   // if there is no such line, then take the
                                   // end iterator of the matrix
  return end();
}

#endif // DOXYGEN


/*----------------------------   sparse_matrix.h     ---------------------------*/

DEAL_II_NAMESPACE_CLOSE

#endif
/*----------------------------   sparse_matrix.h     ---------------------------*/
