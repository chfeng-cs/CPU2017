//---------------------------------------------------------------------------
//    $Id: sparse_matrix.templates.h 18695 2009-04-23 07:18:49Z kronbichler $
//    Version: $Name$
//
//    Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2009 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__sparse_matrix_templates_h
#define __deal2__sparse_matrix_templates_h


//TODO[WB]: the threaded functions can now be converted to return a value, rather than use an additional argument

#include <base/template_constraints.h>
#include <lac/sparse_matrix.h>
#include <lac/vector.h>
#include <lac/full_matrix.h>


// we only need output streams, but older compilers did not provide
// them in a separate include file
#ifdef HAVE_STD_OSTREAM_HEADER
#  include <ostream>
#else
#  include <iostream>
#endif

#include <iomanip>
#include <algorithm>
#include <functional>
#include <cmath>

#include <vector>
#include <numeric>

#include <base/thread_management.h>
#include <base/multithread_info.h>


DEAL_II_NAMESPACE_OPEN


template <typename number>
SparseMatrix<number>::SparseMatrix ()
                :
		cols(0, "SparseMatrix"),
		val(0),
		max_len(0)
{}



template <typename number>
SparseMatrix<number>::SparseMatrix (const SparseMatrix &m)
                :
		Subscriptor (m),
		cols(0, "SparseMatrix"),
		val(0),
		max_len(0)
{
  Assert (m.cols==0, ExcInvalidConstructorCall());
  Assert (m.val==0, ExcInvalidConstructorCall());
  Assert (m.max_len==0, ExcInvalidConstructorCall());
}



template <typename number>
SparseMatrix<number>&
SparseMatrix<number>::operator = (const SparseMatrix<number> &m)
{
  Assert (m.cols==0, ExcInvalidConstructorCall());
  Assert (m.val==0, ExcInvalidConstructorCall());
  Assert (m.max_len==0, ExcInvalidConstructorCall());

  return *this;
}



template <typename number>
SparseMatrix<number>::SparseMatrix (const SparsityPattern &c)
                :
		cols(0, "SparseMatrix"),
		val(0),
		max_len(0)
{
  reinit (c);
}



template <typename number>
SparseMatrix<number>::SparseMatrix (const SparsityPattern &c,
				    const IdentityMatrix  &id)
                :
		cols(0, "SparseMatrix"),
		val(0),
		max_len(0)
{
  Assert (c.n_rows() == id.m(), ExcDimensionMismatch (c.n_rows(), id.m()));
  Assert (c.n_cols() == id.n(), ExcDimensionMismatch (c.n_cols(), id.n()));

  reinit (c);
  for (unsigned int i=0; i<n(); ++i)
    this->set(i,i,1.);
}



template <typename number>
SparseMatrix<number>::~SparseMatrix ()
{
  cols = 0;
  
  if (val != 0)
    delete[] val;
}



template <typename number>
SparseMatrix<number> &
SparseMatrix<number>::operator = (const double d)
{
  Assert (d==0, ExcScalarAssignmentOnlyForZeroValue());
  
  Assert (cols != 0, ExcNotInitialized());
  Assert (cols->compressed || cols->empty(), SparsityPattern::ExcNotCompressed());

  if (val)
    std::fill_n (&val[0], cols->n_nonzero_elements(), 0.);

  return *this;
}



template <typename number>
SparseMatrix<number> &
SparseMatrix<number>::operator= (const IdentityMatrix  &id)
{
  Assert (cols->n_rows() == id.m(),
	  ExcDimensionMismatch (cols->n_rows(), id.m()));
  Assert (cols->n_cols() == id.n(),
	  ExcDimensionMismatch (cols->n_cols(), id.n()));

  *this = 0;
  for (unsigned int i=0; i<n(); ++i)
    this->set(i,i,1.);

  return *this;
}



template <typename number>
void
SparseMatrix<number>::reinit (const SparsityPattern &sparsity)
{
  cols = &sparsity;

  if (cols->empty())
    {
      if (val != 0)
        delete[] val;
      val = 0;
      max_len = 0;
      return;
    }

  const unsigned int N = cols->n_nonzero_elements();
  if (N > max_len || max_len == 0)
    {
      if (val != 0)
        delete[] val;
      val = new number[N];
      max_len = N;
    }

  if (val != 0)
    std::fill_n (&val[0], N, 0);
}



template <typename number>
void
SparseMatrix<number>::clear ()
{
  cols = 0;
  if (val) delete[] val;
  val = 0;
  max_len = 0;
}



template <typename number>
bool
SparseMatrix<number>::empty () const
{
  if (cols == 0)
    return true;
  else
    return cols->empty();
}



template <typename number>
unsigned int
SparseMatrix<number>::n_nonzero_elements () const
{
  Assert (cols != 0, ExcNotInitialized());
  return cols->n_nonzero_elements ();
}



template <typename number>
unsigned int
SparseMatrix<number>::n_actually_nonzero_elements (const double threshold) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (threshold >= 0, ExcMessage ("Negative threshold!"));
  unsigned int nnz = 0;
  for (unsigned int i=0; i<n_nonzero_elements(); ++i)
    if (std::fabs(val[i]) > threshold)
      ++nnz;
  return nnz;
}



template <typename number>
void
SparseMatrix<number>::symmetrize ()
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (cols->rows == cols->cols, ExcNotQuadratic());
  
  const unsigned int n_rows = m();
  for (unsigned int row=0; row<n_rows; ++row)
    {
				       // first skip diagonal entry
      number             *val_ptr = &val[cols->rowstart[row]];
      if (cols->optimize_diagonal())
	  ++val_ptr;
      const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[row]+1];      
      const number       *const val_end_of_row = &val[cols->rowstart[row+1]];

				       // treat lower left triangle
      while ((val_ptr != val_end_of_row) && (*colnum_ptr<row))
	{
					   // compute the mean of this
					   // and the transpose value
	  const number mean_value = (*val_ptr +
				     val[(*cols)(*colnum_ptr,row)]) / 2.0;
					   // set this value and the
					   // transpose one to the
					   // mean
	  *val_ptr = mean_value;
	  set (*colnum_ptr, row, mean_value);

					   // advance pointers
	  ++val_ptr;
	  ++colnum_ptr;
	};
    };
}



template <typename number>
template <typename somenumber>
SparseMatrix<number> &
SparseMatrix<number>::copy_from (const SparseMatrix<somenumber> &matrix)
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols == matrix.cols, ExcDifferentSparsityPatterns());

  std::copy (&matrix.val[0], &matrix.val[cols->n_nonzero_elements()],
	     &val[0]);
  
  return *this;
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::copy_from (const FullMatrix<somenumber> &matrix)
{
				   // first delete previous content
  *this = 0;

				   // then copy old matrix
  for (unsigned int row=0; row<matrix.m(); ++row)
    for (unsigned int col=0; col<matrix.n(); ++col)
      if (matrix(row,col) != 0)
	set (row, col, matrix(row,col));
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::add (const number factor,
			   const SparseMatrix<somenumber> &matrix)
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols == matrix.cols, ExcDifferentSparsityPatterns());

  number             *val_ptr    = &val[0];
  const somenumber   *matrix_ptr = &matrix.val[0];
  const number *const end_ptr    = &val[cols->n_nonzero_elements()];

  while (val_ptr != end_ptr)
    *val_ptr++ += factor * *matrix_ptr++;
}



template <typename number>
template <typename number2>
void
SparseMatrix<number>::add (const unsigned int  row,
			   const unsigned int  n_cols,
			   const unsigned int *col_indices,
			   const number2      *values,
			   const bool          elide_zero_values,
			   const bool          col_indices_are_sorted)
{
  Assert (cols != 0, ExcNotInitialized());

				   // if we have sufficiently many columns
				   // and sorted indices it is faster to
				   // just go through the column indices and
				   // look whether we found one, rather than
				   // doing many binary searches
  if (col_indices_are_sorted == true)
   if (n_cols * 8 > cols->row_length(row))
    {
				   // check whether the given indices are
				   // really sorted
#ifdef DEBUG
      for (unsigned int i=1; i<n_cols; ++i)
	Assert (col_indices[i] > col_indices[i-1], 
		ExcMessage("Indices are not sorted."));
#endif
      if (cols->optimize_diagonal() == true)
	{
	  const unsigned int * this_cols = 
	    &cols->get_column_numbers()[cols->get_rowstart_indices()[row]];
	  number * val_ptr = &val[cols->get_rowstart_indices()[row]];
	  Assert (this_cols[0] == row, ExcInternalError());

				   // find diagonal and add it if found
	  const unsigned int * diag_pos = std::lower_bound (col_indices,
							    col_indices+n_cols,
							    row);
	  const unsigned int diag = diag_pos - col_indices;
	  unsigned int post_diag = diag;
	  if (diag != n_cols && *diag_pos == row)
	    {
	      val_ptr[0] += *(values+(diag_pos-col_indices));
	      ++post_diag;
	    }

				   // add indices before diagonal
	  unsigned int counter = 1;
	  for (unsigned int i=0; i<diag; ++i)
	    {
	      Assert (col_indices[i] >= this_cols[counter], ExcInternalError());

	      while (this_cols[counter] < col_indices[i])
		++counter;

	      Assert (this_cols[counter] == col_indices[i] || values[i] == 0,
		      ExcInvalidIndex(row,col_indices[i]));

	      val_ptr[counter] += values[i];
	    }

				   // add indices after diagonal
	  for (unsigned int i=post_diag; i<n_cols; ++i)
	    {
	      Assert (col_indices[i] >= this_cols[counter], ExcInternalError());

	      while (this_cols[counter] < col_indices[i])
		++counter;

	      Assert (this_cols[counter] == col_indices[i] || values[i] == 0,
		      ExcInvalidIndex(row,col_indices[i]));

	      val_ptr[counter] += values[i];
	    }

	  Assert (counter < cols->row_length(row), ExcInternalError());
	}
      else
	{
	  const unsigned int * this_cols = 
	    &cols->get_column_numbers()[cols->get_rowstart_indices()[row]];
	  number * val_ptr = &val[cols->get_rowstart_indices()[row]];
	  unsigned int counter = 0;
	  for (unsigned int i=0; i<n_cols; ++i)
	    {
	      Assert (col_indices[i] >= this_cols[counter], ExcInternalError());
	      
	      while (this_cols[counter] < col_indices[i])
		++counter;

	      Assert (this_cols[counter] == col_indices[i] || values[i] == 0,
		      ExcInvalidIndex(row,col_indices[i]));

	      val_ptr[counter] += values[i];
	    }
	  Assert (counter < cols->row_length(row), ExcInternalError());
	}
      return;
    }

				   // unsorted case: first, search all the
				   // indices to find out which values we
				   // actually need to add.
  const unsigned int * const my_cols = cols->get_column_numbers();
  unsigned int index = cols->get_rowstart_indices()[row];
  for (unsigned int j=0; j<n_cols; ++j)
    {
      const number value = values[j];
      Assert (numbers::is_finite(value),
	      ExcMessage("The given value is not finite but either "
			 "infinite or Not A Number (NaN)"));

      if (value == 0 && elide_zero_values == true)
	continue;

				   // check whether the next index to add is
				   // the next present index in the sparsity
				   // pattern (otherwise, do a binary
				   // search)
      if (index != cols->get_rowstart_indices()[row+1] &&
	  my_cols[index] == col_indices[j])
	goto add_value;

      index = cols->operator()(row, col_indices[j]);

				   // it is allowed to add elements to
				   // the matrix that are not part of
				   // the sparsity pattern, if the
				   // value we add is zero
      if (index == SparsityPattern::invalid_entry)
	{
	  Assert ((index != SparsityPattern::invalid_entry) ||
		  (value == 0.),
		  ExcInvalidIndex(row,col_indices[j]));
	  continue;
	}

    add_value:
      val[index] += value;
      ++index;
    }
}



template <typename number>
template <typename number2>
void
SparseMatrix<number>::set (const unsigned int  row,
			   const unsigned int  n_cols,
			   const unsigned int *col_indices,
			   const number2      *values,
			   const bool          elide_zero_values)
{
  Assert (cols != 0, ExcNotInitialized());

				   // First, search all the indices to find
				   // out which values we actually need to
				   // set.
  const unsigned int * my_cols = cols->get_column_numbers();
  unsigned int index = cols->get_rowstart_indices()[row];
  for (unsigned int j=0; j<n_cols; ++j)
    {
      const number value = values[j];
      Assert (numbers::is_finite(value),
	      ExcMessage("The given value is not finite but either "
			 "infinite or Not A Number (NaN)"));

      if (value == 0 && elide_zero_values == true)
	continue;

				   // check whether the next index to set is
				   // the next present index in the sparsity
				   // pattern (otherwise, do a binary
				   // search)
      if (index != cols->get_rowstart_indices()[row+1] &&
	  my_cols[index] == col_indices[j])
	goto set_value;

      index = cols->operator()(row, col_indices[j]);

				   // it is allowed to set elements in
				   // the matrix that are not part of
				   // the sparsity pattern, if the
				   // value to which we set it is zero
      if (index == SparsityPattern::invalid_entry)
	{
	  Assert ((index != SparsityPattern::invalid_entry) ||
		  (value == 0.),
		  ExcInvalidIndex(row,col_indices[j]));
	  continue;
	}

    set_value:
      val[index] = value;
      ++index;
    }
}



template <typename number>
template <class OutVector, class InVector>
void
SparseMatrix<number>::vmult (OutVector& dst,
			     const InVector& src) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert(m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));
  Assert(n() == src.size(), ExcDimensionMismatch(n(),src.size()));

  Assert (!PointerComparison::equal(&src, &dst), ExcSourceEqualsDestination());
  
  const unsigned int n_rows = m();

				   // in MT mode: start new threads
				   // only if the matrix is
				   // sufficiently large.  the limit
				   // is mostly artificial
  if (DEAL_II_USE_MT &&
      (multithread_info.n_default_threads > 1) &&
      (n_rows/multithread_info.n_default_threads > 2000))
    {
      const unsigned int n_threads = multithread_info.n_default_threads;

				       // then spawn threads. since
				       // some compilers have trouble
				       // finding out which
				       // 'encapsulate' function to
				       // take of all those possible
				       // ones if we simply drop in
				       // the address of an overloaded
				       // template member function,
				       // make it simpler for the
				       // compiler by giving it the
				       // correct type right away:
      typedef
	void (SparseMatrix<number>::*mem_fun_p)
	(OutVector &,
	 const InVector &,
	 const unsigned int        ,
	 const unsigned int) const;
      const mem_fun_p comp
	= (&SparseMatrix<number>::
           template threaded_vmult<OutVector,InVector>);
      Threads::ThreadGroup<> threads;
      for (unsigned int i=0; i<n_threads; ++i)
	threads += Threads::spawn<void, SparseMatrix<number> > (*this, comp) (dst, src,
                                                 n_rows * i / n_threads,
                                                 n_rows * (i+1) / n_threads);
      threads.join_all();

      return;
    }
  else
    {
				       // if not in MT mode or size<2000
				       // do it in an oldfashioned way
      const number       *val_ptr    = &val[cols->rowstart[0]];
      const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[0]];
      typename OutVector::iterator dst_ptr = dst.begin();
      for (unsigned int row=0; row<n_rows; ++row)
	{
	  typename OutVector::value_type s = 0.;
	  const number *const val_end_of_row = &val[cols->rowstart[row+1]];
	  while (val_ptr != val_end_of_row)
	    s += *val_ptr++ * src(*colnum_ptr++);
	  *dst_ptr++ = s;
	};
    };
}


template <typename number>
template <class OutVector, class InVector>
void
SparseMatrix<number>::threaded_vmult (OutVector       &dst,
				      const InVector &src,
				      const unsigned int        begin_row,
				      const unsigned int        end_row) const
{
				   // this function should not be called
				   // when not in parallel mode.
  Assert (DEAL_II_USE_MT, ExcInternalError());

  const number       *val_ptr    = &val[cols->rowstart[begin_row]];
  const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[begin_row]];
  typename OutVector::iterator dst_ptr = dst.begin() + begin_row;
  for (unsigned int row=begin_row; row<end_row; ++row)
    {
      typename OutVector::value_type s = 0.;
      const number *const val_end_of_row = &val[cols->rowstart[row+1]];
      while (val_ptr != val_end_of_row)
	s += *val_ptr++ * src(*colnum_ptr++);
      *dst_ptr++ = s;
    };
}


template <typename number>
template <class OutVector, class InVector>
void
SparseMatrix<number>::Tvmult (OutVector& dst,
                              const InVector& src) const
{
  Assert (val != 0, ExcNotInitialized());
  Assert (cols != 0, ExcNotInitialized());
  Assert(n() == dst.size(), ExcDimensionMismatch(n(),dst.size()));
  Assert(m() == src.size(), ExcDimensionMismatch(m(),src.size()));

  Assert (!PointerComparison::equal(&src, &dst), ExcSourceEqualsDestination());

  dst = 0;

  for (unsigned int i=0;i<m();i++)
    {
      for (unsigned int j=cols->rowstart[i]; j<cols->rowstart[i+1] ;j++)
	{
	  const unsigned int p = cols->colnums[j];
	  dst(p) += val[j] * src(i);
	}
    }
}


template <typename number>
template <class OutVector, class InVector>
void
SparseMatrix<number>::vmult_add (OutVector& dst,
                                 const InVector& src) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert(m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));
  Assert(n() == src.size(), ExcDimensionMismatch(n(),src.size()));

  Assert (!PointerComparison::equal(&src, &dst), ExcSourceEqualsDestination());

  const unsigned int  n_rows     = m();
  const number       *val_ptr    = &val[cols->rowstart[0]];
  const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[0]];
  typename OutVector::iterator dst_ptr    = dst.begin();
  for (unsigned int row=0; row<n_rows; ++row)
    {
      typename OutVector::value_type s = 0.;
      const number *const val_end_of_row = &val[cols->rowstart[row+1]];
      while (val_ptr != val_end_of_row)
	s += *val_ptr++ * src(*colnum_ptr++);
      *dst_ptr++ += s;
    };
}


template <typename number>
template <class OutVector, class InVector>
void
SparseMatrix<number>::Tvmult_add (OutVector& dst,
                                  const InVector& src) const
{
  Assert (val != 0, ExcNotInitialized());
  Assert (cols != 0, ExcNotInitialized());
  Assert(n() == dst.size(), ExcDimensionMismatch(n(),dst.size()));
  Assert(m() == src.size(), ExcDimensionMismatch(m(),src.size()));

  Assert (!PointerComparison::equal(&src, &dst), ExcSourceEqualsDestination());

  for (unsigned int i=0;i<m();i++)
    for (unsigned int j=cols->rowstart[i]; j<cols->rowstart[i+1] ;j++)
      {
        const unsigned int p = cols->colnums[j];
        dst(p) += val[j] * src(i);
      }
}


template <typename number>
template <typename somenumber>
somenumber
SparseMatrix<number>::matrix_norm_square (const Vector<somenumber>& v) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert(m() == v.size(), ExcDimensionMismatch(m(),v.size()));
  Assert(n() == v.size(), ExcDimensionMismatch(n(),v.size()));

  const unsigned int n_rows = m();

				   // if in MT mode and size sufficiently
				   // large: do it in parallel; the limit
				   // is mostly artificial
  if (DEAL_II_USE_MT &&
      (multithread_info.n_default_threads > 1) &&
      (n_rows/multithread_info.n_default_threads > 2000))
    {
      const unsigned int n_threads = multithread_info.n_default_threads;

				       // space for the norms of
				       // the different parts
      std::vector<somenumber> partial_sums (n_threads, 0);
				       // then spawn threads. since
				       // some compilers have trouble
				       // finding out which
				       // 'encapsulate' function to
				       // take of all those possible
				       // ones if we simply drop in
				       // the address of an overloaded
				       // template member function,
				       // make it simpler for the
				       // compiler by giving it the
				       // correct type right away:
      typedef
	void (SparseMatrix<number>::*mem_fun_p)
	(const Vector<somenumber> &,
	 const unsigned int        ,
	 const unsigned int        ,
	 somenumber               *) const;
      const mem_fun_p comp
	= (&SparseMatrix<number>::
           template threaded_matrix_norm_square<somenumber>);
      Threads::ThreadGroup<> threads;
      for (unsigned int i=0; i<n_threads; ++i)
	threads += Threads::spawn<void, SparseMatrix<number> > (*this, comp)(v,
                                                n_rows * i / n_threads,
                                                n_rows * (i+1) / n_threads,
                                                &partial_sums[i]);

				       // ... and wait until they're finished
      threads.join_all ();
				       // accumulate the partial results
      return std::accumulate (partial_sums.begin(),
			      partial_sums.end(),
			      static_cast<somenumber>(0.));
    }
  else
    {
				       // if not in MT mode or the matrix is
				       // too small: do it one-by-one
      somenumber          sum        = 0.;
      const number       *val_ptr    = &val[cols->rowstart[0]];
      const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[0]];
      for (unsigned int row=0; row<n_rows; ++row)
	{
	  somenumber s = 0.;
	  const number *val_end_of_row = &val[cols->rowstart[row+1]];
	  while (val_ptr != val_end_of_row)
	    s += *val_ptr++ * v(*colnum_ptr++);
	  
	  sum += v(row) * numbers::NumberTraits<somenumber>::conjugate(s);
	}
      
      return sum;
    }
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::
threaded_matrix_norm_square (const Vector<somenumber> &v,
                             const unsigned int        begin_row,
                             const unsigned int        end_row,
                             somenumber               *partial_sum) const
{
				   // this function should not be called
				   // when not in parallel mode.
  Assert (DEAL_II_USE_MT, ExcInternalError());

  somenumber sum = 0.;
  const number       *val_ptr    = &val[cols->rowstart[begin_row]];
  const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[begin_row]];
  for (unsigned int row=begin_row; row<end_row; ++row)
    {
      somenumber s = 0.;
      const number *val_end_of_row = &val[cols->rowstart[row+1]];
      while (val_ptr != val_end_of_row)
	s += *val_ptr++ * v(*colnum_ptr++);

      sum += v(row) * numbers::NumberTraits<somenumber>::conjugate(s);
    }
  
  *partial_sum = sum;
}



template <typename number>
template <typename somenumber>
somenumber
SparseMatrix<number>::matrix_scalar_product (const Vector<somenumber>& u,
					     const Vector<somenumber>& v) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert(m() == u.size(), ExcDimensionMismatch(m(),u.size()));
  Assert(n() == v.size(), ExcDimensionMismatch(n(),v.size()));

  const unsigned int n_rows = m();

				   // if in MT mode and size sufficiently
				   // large: do it in parallel; the limit
				   // is mostly artificial
  if (DEAL_II_USE_MT &&
      (multithread_info.n_default_threads != 1) &&
      (n_rows/multithread_info.n_default_threads > 2000))
    {
      const unsigned int n_threads = multithread_info.n_default_threads;

				       // space for the norms of
				       // the different parts
      std::vector<somenumber> partial_sums (n_threads, 0);
				       // then spawn threads. since
				       // some compilers have trouble
				       // finding out which
				       // 'encapsulate' function to
				       // take of all those possible
				       // ones if we simply drop in
				       // the address of an overloaded
				       // template member function,
				       // make it simpler for the
				       // compiler by giving it the
				       // correct type right away:
      typedef
	void (SparseMatrix<number>::*mem_fun_p)
	(const Vector<somenumber> &,
	 const Vector<somenumber> &,
	 const unsigned int        ,
	 const unsigned int        ,
	 somenumber               *) const;
      const mem_fun_p comp
	= (&SparseMatrix<number>::
           template threaded_matrix_scalar_product<somenumber>);
      Threads::ThreadGroup<> threads;
      for (unsigned int i=0; i<n_threads; ++i)
	threads += Threads::spawn<void, SparseMatrix<number> > (*this, comp)(u, v,
                                                n_rows * i / n_threads,
                                                n_rows * (i+1) / n_threads,
                                                &partial_sums[i]);
  
				       // ... and wait until they're finished
      threads.join_all ();
				       // accumulate the partial results
      return std::accumulate (partial_sums.begin(),
			      partial_sums.end(),
			      static_cast<somenumber>(0.));
    }
  else
    {
				       // if not in MT mode or the matrix is
				       // too small: do it one-by-one
      somenumber          sum        = 0.;
      const number       *val_ptr    = &val[cols->rowstart[0]];
      const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[0]];
      for (unsigned int row=0; row<n_rows; ++row)
	{
	  somenumber s = 0.;
	  const number *val_end_of_row = &val[cols->rowstart[row+1]];
	  while (val_ptr != val_end_of_row)
	    s += *val_ptr++ * v(*colnum_ptr++);
	  
	  sum += u(row) * numbers::NumberTraits<somenumber>::conjugate(s);
	}
      
      return sum;
    }
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::
threaded_matrix_scalar_product (const Vector<somenumber> &u,
                                const Vector<somenumber> &v,
                                const unsigned int        begin_row,
                                const unsigned int        end_row,
                                somenumber               *partial_sum) const
{
				   // this function should not be called
				   // when not in parallel mode.
  Assert (DEAL_II_USE_MT, ExcInternalError());

  somenumber sum = 0.;
  const number       *val_ptr    = &val[cols->rowstart[begin_row]];
  const unsigned int *colnum_ptr = &cols->colnums[cols->rowstart[begin_row]];
  for (unsigned int row=begin_row; row<end_row; ++row)
    {
      somenumber s = 0.;
      const number *val_end_of_row = &val[cols->rowstart[row+1]];
      while (val_ptr != val_end_of_row)
	s += *val_ptr++ * v(*colnum_ptr++);

      sum += u(row) * numbers::NumberTraits<somenumber>::conjugate(s);
    }
  
  *partial_sum = sum;
}





template <typename number>
typename SparseMatrix<number>::real_type
SparseMatrix<number>::l1_norm () const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());

  Vector<real_type> column_sums(n());
  const unsigned int n_rows = m();
  for (unsigned int row=0; row<n_rows; ++row)
    for (unsigned int j=cols->rowstart[row]; j<cols->rowstart[row+1] ; ++j)
      column_sums(cols->colnums[j]) += numbers::NumberTraits<number>::abs(val[j]);

  return column_sums.linfty_norm();
}



template <typename number>
typename SparseMatrix<number>::real_type
SparseMatrix<number>::linfty_norm () const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());

  const number *val_ptr = &val[cols->rowstart[0]];

  real_type max=0;
  const unsigned int n_rows = m();
  for (unsigned int row=0; row<n_rows; ++row)
    {
      real_type sum = 0;
      const number *const val_end_of_row = &val[cols->rowstart[row+1]];
      while (val_ptr != val_end_of_row)
	sum += numbers::NumberTraits<number>::abs(*val_ptr++);
      if (sum > max)
	max = sum;
    }
  return max;
}



template <typename number>
typename SparseMatrix<number>::real_type
SparseMatrix<number>::frobenius_norm () const
{
                                   // simply add up all entries in the
                                   // sparsity pattern, without taking any
                                   // reference to rows or columns
  real_type norm_sqr = 0;
  const unsigned int n_rows = m();
  for (const number *ptr = &val[0];
       ptr != &val[cols->rowstart[n_rows]]; ++ptr)
    norm_sqr +=  numbers::NumberTraits<number>::abs_square(*ptr);

  return std::sqrt (norm_sqr);
}



template <typename number>
template <typename somenumber>
somenumber
SparseMatrix<number>::residual (Vector<somenumber>       &dst,
				const Vector<somenumber> &u,
				const Vector<somenumber> &b) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert(m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));
  Assert(m() == b.size(), ExcDimensionMismatch(m(),b.size()));
  Assert(n() == u.size(), ExcDimensionMismatch(n(),u.size()));

  Assert (&u != &dst, ExcSourceEqualsDestination());

  const unsigned int n_rows = m();

				   // if in MT mode and size sufficiently
				   // large: do it in parallel; the limit
				   // is mostly artificial
  if (DEAL_II_USE_MT &&
      (multithread_info.n_default_threads > 1) &&
      (n_rows/multithread_info.n_default_threads > 2000))
    {
      const unsigned int n_threads = multithread_info.n_default_threads;
 
				       // space for the square norms of
				       // the different parts
      std::vector<somenumber> partial_norms (n_threads, 0);

				       // then spawn threads. since
				       // some compilers have trouble
				       // finding out which
				       // 'encapsulate' function to
				       // take of all those possible
				       // ones if we simply drop in
				       // the address of an overloaded
				       // template member function,
				       // make it simpler for the
				       // compiler by giving it the
				       // correct type right away:
      typedef
	void (SparseMatrix<number>::*mem_fun_p)
	(Vector<somenumber>       &,
	 const Vector<somenumber> &,
	 const Vector<somenumber> &,
	 const std::pair<unsigned int,unsigned int>,
	 somenumber               *) const;
      const mem_fun_p comp_residual = &SparseMatrix<number>::
				     template threaded_residual<somenumber>;
      Threads::ThreadGroup<> threads;
      for (unsigned int i=0; i<n_threads; ++i)
	threads += Threads::spawn<void, SparseMatrix<number> > (*this, comp_residual)(dst, u, b,
                                                         std::pair<unsigned int,unsigned int>
                                                         (n_rows * i / n_threads,
                                                          n_rows * (i+1) / n_threads),
                                                         &partial_norms[i]);

				       // ... and wait until they're finished
      threads.join_all ();
				       // accumulate the partial results
      return std::sqrt(std::accumulate (partial_norms.begin(),
					partial_norms.end(),
					static_cast<somenumber>(0.)));
    }
  else
    {
      somenumber norm=0.;   
  
      for (unsigned int i=0; i<n_rows; ++i)
	{
	  somenumber s = b(i);
	  for (unsigned int j=cols->rowstart[i]; j<cols->rowstart[i+1] ;j++)
	    {
	      const unsigned int p = cols->colnums[j];
	      s -= val[j] * u(p);
	    }
	  dst(i) = s;
	  norm += dst(i)*dst(i);
	}
      return std::sqrt(norm);
    };
}


template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::threaded_residual (Vector<somenumber>       &dst,
					 const Vector<somenumber> &u,
					 const Vector<somenumber> &b,
					 const std::pair<unsigned int, unsigned int> interval,
					 somenumber               *partial_norm) const
{
				   // this function should not be called
				   // when not in parallel mode.
  Assert (DEAL_II_USE_MT, ExcInternalError());

  const unsigned int begin_row = interval.first,
		     end_row   = interval.second;
  
  somenumber norm=0.;   
  
  for (unsigned int i=begin_row; i<end_row; ++i)
    {
      somenumber s = b(i);
      for (unsigned int j=cols->rowstart[i]; j<cols->rowstart[i+1] ;j++)
	{
	  const unsigned int p = cols->colnums[j];
	  s -= val[j] * u(p);
	}
      dst(i) = s;
      norm += dst(i)*dst(i);
    };

  *partial_norm = norm;
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::precondition_Jacobi (Vector<somenumber>       &dst,
					   const Vector<somenumber> &src,
					   const number              om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (dst.size() == n(), ExcDimensionMismatch (dst.size(), n()));
  Assert (src.size() == n(), ExcDimensionMismatch (src.size(), n()));

  const unsigned int n = src.size();
  somenumber              *dst_ptr = dst.begin();
  const somenumber        *src_ptr = src.begin();
  const std::size_t  *rowstart_ptr = &cols->rowstart[0];

				   // optimize the following loop for
				   // the case that the relaxation
				   // factor is one. In that case, we
				   // can save one FP multiplication
				   // per row
				   //
				   // note that for square matrices,
				   // the diagonal entry is the first
				   // in each row, i.e. at index
				   // rowstart[i]. and we do have a
				   // square matrix by above assertion
  if (om != 1.)
    for (unsigned int i=0; i<n; ++i, ++dst_ptr, ++src_ptr, ++rowstart_ptr)
      *dst_ptr = om * *src_ptr / val[*rowstart_ptr];
  else
    for (unsigned int i=0; i<n; ++i, ++dst_ptr, ++src_ptr, ++rowstart_ptr)
      *dst_ptr = *src_ptr / val[*rowstart_ptr];
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::precondition_SSOR (Vector<somenumber>              &dst,
					 const Vector<somenumber>        &src,
					 const number                     om,
					 const std::vector<unsigned int> &pos_right_of_diagonal) const
{
				   // to understand how this function works
				   // you may want to take a look at the CVS
				   // archives to see the original version
				   // which is much clearer...
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (dst.size() == n(), ExcDimensionMismatch (dst.size(), n()));
  Assert (src.size() == n(), ExcDimensionMismatch (src.size(), n()));

  const unsigned int  n            = src.size();
  const std::size_t  *rowstart_ptr = &cols->rowstart[0];
  somenumber         *dst_ptr      = &dst(0);

				   // case when we have stored the position
				   // just right of the diagonal (then we
				   // don't have to search for it).
  if (pos_right_of_diagonal.size() != 0)
    {
      Assert (pos_right_of_diagonal.size() == dst.size(),
	      ExcDimensionMismatch (pos_right_of_diagonal.size(), dst.size()));

				   // forward sweep
      for (unsigned int row=0; row<n; ++row, ++dst_ptr, ++rowstart_ptr)
	{
	  *dst_ptr = src(row);
	  const unsigned int first_right_of_diagonal_index = 
	    pos_right_of_diagonal[row];
	  Assert (first_right_of_diagonal_index <= *(rowstart_ptr+1),
		  ExcInternalError());
	  number s = 0;
	  for (unsigned int j=(*rowstart_ptr)+1; j<first_right_of_diagonal_index; ++j)
	    s += val[j] * dst(cols->colnums[j]);

				   // divide by diagonal element
	  *dst_ptr -= s * om;
	  *dst_ptr /= val[*rowstart_ptr];
	};
  
      rowstart_ptr = &cols->rowstart[0];
      dst_ptr      = &dst(0);
      for (unsigned int row=0; row<n; ++row, ++rowstart_ptr, ++dst_ptr)
	*dst_ptr *= (2.-om)*val[*rowstart_ptr];

				   // backward sweep
      rowstart_ptr = &cols->rowstart[n-1];
      dst_ptr      = &dst(n-1);
      for (int row=n-1; row>=0; --row, --rowstart_ptr, --dst_ptr)
	{
	  const unsigned int end_row = *(rowstart_ptr+1);
	  const unsigned int first_right_of_diagonal_index
	    = pos_right_of_diagonal[row];
	  number s = 0;
	  for (unsigned int j=first_right_of_diagonal_index; j<end_row; ++j)
	    s += val[j] * dst(cols->colnums[j]);
      
	  *dst_ptr -= s * om;
	  *dst_ptr /= val[*rowstart_ptr];
	};
      return;
    }

				   // case when we need to get the position
				   // of the first element right of the
				   // diagonal manually for each sweep.
				   // forward sweep
  for (unsigned int row=0; row<n; ++row, ++dst_ptr, ++rowstart_ptr)
    {
      *dst_ptr = src(row);
				       // find the first element in this line
				       // which is on the right of the diagonal.
				       // we need to precondition with the
				       // elements on the left only.
				       // note: the first entry in each
				       // line denotes the diagonal element,
				       // which we need not check.
      const unsigned int first_right_of_diagonal_index
	= (internals::SparsityPatternTools::optimized_lower_bound (&cols->colnums[*rowstart_ptr+1],
								   &cols->colnums[*(rowstart_ptr+1)],
								   row)
	   -
	   &cols->colnums[0]);

      number s = 0;
      for (unsigned int j=(*rowstart_ptr)+1; j<first_right_of_diagonal_index; ++j)
	s += val[j] * dst(cols->colnums[j]);

				       // divide by diagonal element
      *dst_ptr -= s * om;
      *dst_ptr /= val[*rowstart_ptr];
    };
  
  rowstart_ptr = &cols->rowstart[0];
  dst_ptr      = &dst(0);
  for (unsigned int row=0; row<n; ++row, ++rowstart_ptr, ++dst_ptr)
    *dst_ptr *= (2.-om)*val[*rowstart_ptr];

				   // backward sweep
  rowstart_ptr = &cols->rowstart[n-1];
  dst_ptr      = &dst(n-1);
  for (int row=n-1; row>=0; --row, --rowstart_ptr, --dst_ptr)
    {
      const unsigned int end_row = *(rowstart_ptr+1);
      const unsigned int first_right_of_diagonal_index
	= (internals::SparsityPatternTools::optimized_lower_bound (&cols->colnums[*rowstart_ptr+1],
								   &cols->colnums[end_row],
								   static_cast<unsigned int>(row)) -
	   &cols->colnums[0]);
      number s = 0;
      for (unsigned int j=first_right_of_diagonal_index; j<end_row; ++j)
	s += val[j] * dst(cols->colnums[j]);
      *dst_ptr -= s * om;
      *dst_ptr /= val[*rowstart_ptr];
    };
}


template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::precondition_SOR (Vector<somenumber>& dst,
                                        const Vector<somenumber>& src,
                                        const number om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  

  dst = src;
  SOR(dst,om);
}


template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::precondition_TSOR (Vector<somenumber>& dst,
                                         const Vector<somenumber>& src,
                                         const number om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  

  dst = src;
  TSOR(dst,om);
}


template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::SOR (Vector<somenumber>& dst,
                           const number om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));

  for (unsigned int row=0; row<m(); ++row)
    {
      somenumber s = dst(row);
      for (unsigned int j=cols->rowstart[row]; j<cols->rowstart[row+1]; ++j)
	{
	  const unsigned int col = cols->colnums[j];
	  if (col < row)
	    s -= val[j] * dst(col);
	}
      
      dst(row) = s * om / val[cols->rowstart[row]];
    }
}


template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::TSOR (Vector<somenumber>& dst,
                            const number om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));

  for (unsigned int row=m(); row!=0;)
    {
      --row;
      somenumber s = dst(row);
      for (unsigned int j=cols->rowstart[row]; j<cols->rowstart[row+1]; ++j)
	if (cols->colnums[j] > row)
	  s -= val[j] * dst(cols->colnums[j]);

      dst(row) = s * om / val[cols->rowstart[row]];
    }
}


template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::PSOR (Vector<somenumber>& dst,
                            const std::vector<unsigned int>& permutation,
                            const std::vector<unsigned int>& inverse_permutation,
                            const number om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));
  Assert (m() == permutation.size(),
	  ExcDimensionMismatch(m(), permutation.size()));
  Assert (m() == inverse_permutation.size(),
	  ExcDimensionMismatch(m(), inverse_permutation.size()));

  for (unsigned int urow=0; urow<m(); ++urow)
    {
      const unsigned int row = permutation[urow];
      somenumber s = dst(row);
      
      for (unsigned int j=cols->rowstart[row]; j<cols->rowstart[row+1]; ++j)
	{
	  const unsigned int col = cols->colnums[j];
	  if (inverse_permutation[col] < urow)
	    {
	      s -= val[j] * dst(col);
	    }
	}

      dst(row) = s * om / val[cols->rowstart[row]];
    }
}


template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::TPSOR (Vector<somenumber>& dst,
                             const std::vector<unsigned int>& permutation,
                             const std::vector<unsigned int>& inverse_permutation,
                             const number om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));
  Assert (m() == permutation.size(),
	  ExcDimensionMismatch(m(), permutation.size()));
  Assert (m() == inverse_permutation.size(),
	  ExcDimensionMismatch(m(), inverse_permutation.size()));

  for (unsigned int urow=m(); urow != 0;)
    {
      --urow;
      const unsigned int row = permutation[urow];
      somenumber s = dst(row);
      for (unsigned int j=cols->rowstart[row]; j<cols->rowstart[row+1]; ++j)
	{
	  const unsigned int col = cols->colnums[j];
	  if (inverse_permutation[col] > urow)
	    s -= val[j] * dst(col);
	}

      dst(row) = s * om / val[cols->rowstart[row]];
    }
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::SOR_step (Vector<somenumber> &v,
                                const Vector<somenumber> &b,
                                const number        om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (m() == v.size(), ExcDimensionMismatch(m(),v.size()));
  Assert (m() == b.size(), ExcDimensionMismatch(m(),b.size()));

  for (unsigned int row=0; row<m(); ++row)
    {
      somenumber s = b(row);
      for (unsigned int j=cols->rowstart[row]; j<cols->rowstart[row+1]; ++j)
	{
	  s -= val[j] * v(cols->colnums[j]);
	}
      v(row) += s * om / val[cols->rowstart[row]];
    }
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::TSOR_step (Vector<somenumber> &v,
                                 const Vector<somenumber> &b,
                                 const number        om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (m() == v.size(), ExcDimensionMismatch(m(),v.size()));
  Assert (m() == b.size(), ExcDimensionMismatch(m(),b.size()));

  for (int row=m()-1; row>=0; --row)
    {
      somenumber s = b(row);
      for (unsigned int j=cols->rowstart[row]; j<cols->rowstart[row+1]; ++j)
	{
	  s -= val[j] * v(cols->colnums[j]);
	}
      v(row) += s * om / val[cols->rowstart[row]];
    }
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::SSOR_step (Vector<somenumber> &v,
                                 const Vector<somenumber> &b,
                                 const number        om) const
{
  SOR_step(v,b,om);
  TSOR_step(v,b,om);
}



template <typename number>
template <typename somenumber>
void
SparseMatrix<number>::SSOR (Vector<somenumber>& dst,
                            const number om) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());
  Assert (cols->optimize_diagonal(),
	  typename SparsityPattern::ExcDiagonalNotOptimized());
  
  Assert (m() == dst.size(), ExcDimensionMismatch(m(),dst.size()));

  const unsigned int  n = dst.size();
  unsigned int  j;
  somenumber s;
  
  for (unsigned int i=0; i<n; i++)
    {
      s = 0.;
      for (j=cols->rowstart[i]; j<cols->rowstart[i+1] ;j++)
	{
	  const unsigned int p = cols->colnums[j];
	  if (p != SparsityPattern::invalid_entry)
	    {
	      if (i>j) s += val[j] * dst(p);
	    }
	}
      dst(i) -= s * om;
      dst(i) /= val[cols->rowstart[i]];
    }

  for (int i=n-1; i>=0; i--)  // this time, i is signed, but alsways positive!
    {
      s = 0.;
      for (j=cols->rowstart[i]; j<cols->rowstart[i+1] ;j++)
	{
	  const unsigned int p = cols->colnums[j];
	  if (p != SparsityPattern::invalid_entry)
	    {
	      if (static_cast<unsigned int>(i)<j) s += val[j] * dst(p);
	    }
	}
      dst(i) -= s * om / val[cols->rowstart[i]];
    }
}



template <typename number>
const SparsityPattern &
SparseMatrix<number>::get_sparsity_pattern () const
{
  Assert (cols != 0, ExcNotInitialized());
  return *cols;
}



template <typename number>
void SparseMatrix<number>::print (std::ostream &out) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());

  for (unsigned int i=0; i<cols->rows; ++i)
    for (unsigned int j=cols->rowstart[i]; j<cols->rowstart[i+1]; ++j)
      out << "(" << i << "," << cols->colnums[j] << ") " << val[j] << std::endl;

  AssertThrow (out, ExcIO());
}


template <typename number>
void SparseMatrix<number>::print_formatted (std::ostream &out,
					    const unsigned int precision,
					    const bool scientific,
					    const unsigned int width_,
					    const char* zero_string,
					    const double denominator) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());

  unsigned int width = width_;
  
  std::ios::fmtflags old_flags = out.flags();
  unsigned int old_precision = out.precision (precision);

  if (scientific)
    {
      out.setf (std::ios::scientific, std::ios::floatfield);
      if (!width)
	width = precision+7;
    } else {
      out.setf (std::ios::fixed, std::ios::floatfield);
      if (!width)
	width = precision+2;
    }

  for (unsigned int i=0; i<m(); ++i)
    {
      for (unsigned int j=0; j<n(); ++j)
	if ((*cols)(i,j) != SparsityPattern::invalid_entry)
	  out << std::setw(width)
	      << val[cols->operator()(i,j)] * denominator << ' ';
	else
	  out << std::setw(width) << zero_string << ' ';
      out << std::endl;
    };
  AssertThrow (out, ExcIO());

				   // reset output format
  out.precision(old_precision);
  out.flags (old_flags);
}



template <typename number>
void SparseMatrix<number>::print_pattern (std::ostream &out,
					  const double threshold) const
{
  Assert (cols != 0, ExcNotInitialized());
  Assert (val != 0, ExcNotInitialized());

  for (unsigned int i=0; i<m(); ++i)
    {
      for (unsigned int j=0; j<n(); ++j)
	if ((*cols)(i,j) == SparsityPattern::invalid_entry)
	  out << '.';
	else
	  if (std::fabs(val[cols->operator()(i,j)]) > threshold)
	    out << '*';
	  else
	    out << ':';
      out << std::endl;
    };
  AssertThrow (out, ExcIO());
}



template <typename number>
void
SparseMatrix<number>::block_write (std::ostream &out) const 
{
  AssertThrow (out, ExcIO());

                                   // first the simple objects,
                                   // bracketed in [...]
  out << '[' << max_len << "][";
                                   // then write out real data
  out.write (reinterpret_cast<const char*>(&val[0]),
	     reinterpret_cast<const char*>(&val[max_len])
	     - reinterpret_cast<const char*>(&val[0]));
  out << ']';
  
  AssertThrow (out, ExcIO());
}



template <typename number>
void
SparseMatrix<number>::block_read (std::istream &in)
{
  AssertThrow (in, ExcIO());

  char c;

                                   // first read in simple data
  in >> c;
  AssertThrow (c == '[', ExcIO());
  in >> max_len;

  in >> c;
  AssertThrow (c == ']', ExcIO());
  in >> c;
  AssertThrow (c == '[', ExcIO());

                                   // reallocate space
  delete[] val;
  val  = new number[max_len];
  
                                   // then read data
  in.read (reinterpret_cast<char*>(&val[0]),
           reinterpret_cast<char*>(&val[max_len])
           - reinterpret_cast<char*>(&val[0]));
  in >> c;
  AssertThrow (c == ']', ExcIO());
}



template <typename number>
unsigned int
SparseMatrix<number>::memory_consumption () const
{
  return sizeof(*this) + max_len*sizeof(number);
}


DEAL_II_NAMESPACE_CLOSE

#endif
