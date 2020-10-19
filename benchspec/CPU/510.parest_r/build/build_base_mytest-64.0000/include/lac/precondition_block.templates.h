//---------------------------------------------------------------------------
//    $Id: precondition_block.templates.h 15008 2007-08-21 21:28:55Z kanschat $
//    Version: $Name$
//
//    Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__precondition_block_templates_h
#define __deal2__precondition_block_templates_h


#include <base/config.h>
#include <base/exceptions.h>
#include <base/logstream.h>
#include <base/memory_consumption.h>
#include <lac/householder.h>
#include <lac/precondition_block.h>
#include <lac/vector.h>
#include <lac/full_matrix.h>

DEAL_II_NAMESPACE_OPEN


template <class MATRIX, typename inverse_type>
PreconditionBlock<MATRIX,inverse_type>::PreconditionBlock ():
		blocksize(0),
		A(0),
		store_diagonals(false),
		var_same_diagonal(false)
{}


template <class MATRIX, typename inverse_type>
PreconditionBlock<MATRIX,inverse_type>::~PreconditionBlock ()
{
  if (var_inverse.size()!=0)
    var_inverse.erase(var_inverse.begin(), var_inverse.end());
  if (var_diagonal.size()!=0)
    var_diagonal.erase(var_diagonal.begin(), var_diagonal.end());
}


template <class MATRIX, typename inverse_type>
void PreconditionBlock<MATRIX,inverse_type>::clear ()
{
  if (var_inverse.size()!=0)
    var_inverse.erase(var_inverse.begin(), var_inverse.end());
  if (var_diagonal.size()!=0)
    var_diagonal.erase(var_diagonal.begin(), var_diagonal.end());
  blocksize     = 0;
  var_same_diagonal = false;
  A = 0;
}


template <class MATRIX, typename inverse_type>
void PreconditionBlock<MATRIX,inverse_type>::initialize (
  const MATRIX &M,
  const AdditionalData parameters)
{
  const unsigned int bsize = parameters.block_size;
  
  clear();
  Assert (M.m() == M.n(), ExcNotQuadratic());
  A = &M;
  Assert (bsize>0, ExcIndexRange(bsize, 1, M.m()));
  Assert (A->m()%bsize==0, ExcWrongBlockSize(bsize, A->m()));
  blocksize=bsize;
  relaxation = parameters.relaxation;
  var_same_diagonal = parameters.same_diagonal;
  nblocks = A->m()/bsize;
  
  if (parameters.invert_diagonal)
    invert_diagblocks();
}

template <class MATRIX, typename inverse_type>
void PreconditionBlock<MATRIX,inverse_type>::initialize (
  const MATRIX &M,
  const std::vector<unsigned int>& permutation,
  const std::vector<unsigned int>& inverse_permutation,
  const AdditionalData parameters)
{
  
  const unsigned int bsize = parameters.block_size;
  
  clear();
  Assert (M.m() == M.n(), ExcNotQuadratic());
  A = &M;
  Assert (bsize>0, ExcIndexRange(bsize, 1, M.m()));
  Assert (A->m()%bsize==0, ExcWrongBlockSize(bsize, A->m()));
  blocksize=bsize;
  relaxation = parameters.relaxation;
  var_same_diagonal = parameters.same_diagonal;
  nblocks = A->m()/bsize;
  
  if (parameters.invert_diagonal)
    invert_permuted_diagblocks(permutation, inverse_permutation);
  
}

template <class MATRIX, typename inverse_type>
void PreconditionBlock<MATRIX,inverse_type>::invert_permuted_diagblocks(
  const std::vector<unsigned int>& permutation,
  const std::vector<unsigned int>& inverse_permutation)
{
  Assert (A!=0, ExcNotInitialized());
  Assert (blocksize!=0, ExcNotInitialized());

  const MATRIX &M=*A;
  Assert (var_inverse.size()==0, ExcInverseMatricesAlreadyExist());

  FullMatrix<inverse_type> M_cell(blocksize);

  if (same_diagonal())
    {
      deallog << "PreconditionBlock uses only one diagonal block" << std::endl;
				       // Invert only the first block
				       // This is a copy of the code in the
				       // 'else' part, stripped of the outer loop
      if (store_diagonals)
	var_diagonal.resize(1);
      var_inverse.resize(1);
      var_inverse[0].reinit(blocksize, blocksize);

      for (unsigned int row_cell=0; row_cell<blocksize; ++row_cell)
	{
	  typename MATRIX::const_iterator entry = M.begin(row_cell);
	  const typename MATRIX::const_iterator row_end = M.end(row_cell);
	  while(entry != row_end)
	    {
	      if (entry->column() < blocksize)
		M_cell(row_cell, entry->column()) = entry->value();
	      ++entry;
	    }
	}
      if (store_diagonals)
	var_diagonal[0] = M_cell;
      var_inverse[0].invert(M_cell);
    }
  else
    {
				       // cell_row, cell_column are the
				       // numbering of the blocks (cells).
				       // row_cell, column_cell are the local
				       // numbering of the unknowns in the
				       // blocks.
				       // row, column are the global numbering
				       // of the unkowns.

				       // set the var_inverse array to the right
				       // size. we could do it like this:
				       // var_inverse = vector<>(nblocks,FullMatrix<>())
				       // but this would involve copying many
				       // FullMatrix objects.
				       //
				       // the following is a neat trick which
				       // avoids copying
      if (store_diagonals)
	{
	  std::vector<FullMatrix<inverse_type> >
	    tmp(nblocks, FullMatrix<inverse_type>(blocksize));
	  var_diagonal.swap (tmp);
	}

      if (true)
	{
	  std::vector<FullMatrix<inverse_type> >
	    tmp(nblocks, FullMatrix<inverse_type>(blocksize));
	  var_inverse.swap (tmp);
					   // make sure the tmp object
					   // goes out of scope as
					   // soon as possible
	};

      M_cell = 0;
      
      for (unsigned int cell=0; cell<nblocks; ++cell)
	{
	  const unsigned int cell_start = cell*blocksize;
	  for (unsigned int row_cell=0; row_cell<blocksize; ++row_cell)
	    {
	      const unsigned int urow = row_cell + cell_start;

	      const unsigned int row = permutation[urow];

	      typename MATRIX::const_iterator entry = M.begin(row);
	      const typename MATRIX::const_iterator row_end = M.end(row);

	      for (;entry != row_end; ++entry)
		{
		  //if (entry->column()<cell_start)
		  if (inverse_permutation[entry->column()]<cell_start)
		    continue;
		  
		  const unsigned int column_cell = inverse_permutation[entry->column()]-cell_start;
		  if (column_cell >= blocksize)
		    continue;
		  M_cell(row_cell, column_cell) = entry->value();
		}
	    }

	  if (store_diagonals)
	    var_diagonal[cell] = M_cell;
	  var_inverse[cell].invert(M_cell);
	}
    }
}



template <class MATRIX, typename inverse_type>
const FullMatrix<inverse_type>&
PreconditionBlock<MATRIX,inverse_type>::inverse(unsigned int i) const
{
  if (same_diagonal())
    return var_inverse[0];
  
  Assert (i < var_inverse.size(), ExcIndexRange(i,0,var_inverse.size()));
  return var_inverse[i];
}


template <class MATRIX, typename inverse_type>
const FullMatrix<inverse_type>&
PreconditionBlock<MATRIX,inverse_type>::diagonal(unsigned int i) const
{
  Assert(store_diagonals, ExcDiagonalsNotStored());
  
  if (same_diagonal())
    return var_diagonal[0];
  
  Assert (i < var_diagonal.size(), ExcIndexRange(i,0,var_diagonal.size()));
  return var_diagonal[i];
}


template <class MATRIX, typename inverse_type>
unsigned int PreconditionBlock<MATRIX,inverse_type>::block_size() const
{
  return blocksize;
}


template <class MATRIX, typename inverse_type>
void
PreconditionBlock<MATRIX,inverse_type>::set_same_diagonal()
{
  Assert(var_inverse.size()==0, ExcInverseMatricesAlreadyExist());
  var_same_diagonal = true;
}


template <class MATRIX, typename inverse_type>
bool
PreconditionBlock<MATRIX,inverse_type>::same_diagonal() const
{
  return var_same_diagonal;
}


template <class MATRIX, typename inverse_type>
bool
PreconditionBlock<MATRIX,inverse_type>::inverses_ready() const
{
  return (var_inverse.size() != 0);
}


template <class MATRIX, typename inverse_type>
void PreconditionBlock<MATRIX,inverse_type>::invert_diagblocks()
{
  Assert (A!=0, ExcNotInitialized());
  Assert (blocksize!=0, ExcNotInitialized());

  const MATRIX &M=*A;
  Assert (var_inverse.size()==0, ExcInverseMatricesAlreadyExist());

  FullMatrix<inverse_type> M_cell(blocksize);

  if (same_diagonal())
    {
      deallog << "PreconditionBlock uses only one diagonal block" << std::endl;
				       // Invert only the first block
				       // This is a copy of the code in the
				       // 'else' part, stripped of the outer loop
      if (store_diagonals)
	var_diagonal.resize(1);
      var_inverse.resize(1);
      var_inverse[0].reinit(blocksize, blocksize);

      for (unsigned int row_cell=0; row_cell<blocksize; ++row_cell)
	{
	  typename MATRIX::const_iterator entry = M.begin(row_cell);
	  const typename MATRIX::const_iterator row_end = M.end(row_cell);
	  while(entry != row_end)
	    {
	      if (entry->column() < blocksize)
		M_cell(row_cell, entry->column()) = entry->value();
	      ++entry;
	    }
	}
      if (store_diagonals)
	var_diagonal[0] = M_cell;
      var_inverse[0].invert(M_cell);
    }
  else
    {
				       // cell_row, cell_column are the
				       // numbering of the blocks (cells).
				       // row_cell, column_cell are the local
				       // numbering of the unknowns in the
				       // blocks.
				       // row, column are the global numbering
				       // of the unkowns.

				       // set the @p var_inverse array to the right
				       // size. we could do it like this:
				       // var_inverse = vector<>(nblocks,FullMatrix<>())
				       // but this would involve copying many
				       // FullMatrix objects.
				       //
				       // the following is a neat trick which
				       // avoids copying
      if (store_diagonals)
	{
	  std::vector<FullMatrix<inverse_type> >
	    tmp(nblocks, FullMatrix<inverse_type>(blocksize));
	  var_diagonal.swap (tmp);
	}

      if (true)
	{
	  std::vector<FullMatrix<inverse_type> >
	    tmp(nblocks, FullMatrix<inverse_type>(blocksize));
	  var_inverse.swap (tmp);
					   // make sure the tmp object
					   // goes out of scope as
					   // soon as possible
	};

      M_cell = 0;
      
      for (unsigned int cell=0; cell<nblocks; ++cell)
	{
	  const unsigned int cell_start = cell*blocksize;
	  for (unsigned int row_cell=0; row_cell<blocksize; ++row_cell)
	    {
	      const unsigned int row = row_cell + cell_start;
	      typename MATRIX::const_iterator entry = M.begin(row);
	      const typename MATRIX::const_iterator row_end = M.end(row);

	      for (;entry != row_end; ++entry)
		{
		  if (entry->column()<cell_start)
		    continue;
		  
		  const unsigned int column_cell = entry->column()-cell_start;
		  if (column_cell >= blocksize)
		    continue;
		  M_cell(row_cell, column_cell) = entry->value();
		}
	    }

	  if (store_diagonals)
	    var_diagonal[cell] = M_cell;
	  var_inverse[cell].invert(M_cell);
	}
    }
}



template <class MATRIX, typename inverse_type>
unsigned int
PreconditionBlock<MATRIX,inverse_type>::memory_consumption () const
{
  unsigned int mem = sizeof(*this);
  for (unsigned int i=0; i<var_inverse.size(); ++i)
    mem += MemoryConsumption::memory_consumption(var_inverse[i]);
  for (unsigned int i=0; i<var_diagonal.size(); ++i)
    mem += MemoryConsumption::memory_consumption(var_diagonal[i]);
  return mem;
}




/*--------------------- PreconditionBlockJacobi -----------------------*/


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockJacobi<MATRIX,inverse_type>
::do_vmult (Vector<number2>       &dst,
	    const Vector<number2> &src,
	    bool adding) const
{
				   // introduce the following typedef
				   // since in the use of exceptions,
				   // strict C++ requires us to
				   // specify them fully as they are
				   // from a template dependent base
				   // class. thus, we'd have to write
				   // PreconditionBlock<number,inverse_type>::ExcNoMatrixGivenToUse,
				   // which is lengthy, but also poses
				   // some problems to the
				   // preprocessor due to the comma in
				   // the template arg list. we could
				   // then wrap the whole thing into
				   // parentheses, but that creates a
				   // parse error for gcc for the
				   // exceptions that do not take
				   // args...
  typedef PreconditionBlock<MATRIX,inverse_type> BaseClass;
  Assert(this->A!=0, ExcNotInitialized());
  
  const MATRIX &M=*this->A;

  Vector<number2> b_cell(this->blocksize), x_cell(this->blocksize);

				       // cell_row, cell_column are the
				       // numbering of the blocks (cells).
				       // row_cell, column_cell are the local
				       // numbering of the unknowns in the
				       // blocks.
				       // row, column are the global numbering
				       // of the unkowns.
  unsigned int row, row_cell, begin_diag_block=0;

  if (!this->inverses_ready())
    {
      FullMatrix<number> M_cell(this->blocksize);
      for (unsigned int cell=0; cell < this->nblocks; ++cell)
	{
	  for (row=cell*this->blocksize, row_cell=0;
	       row_cell<this->blocksize;
	       ++row_cell, ++row)
	    {
	      b_cell(row_cell)=src(row);
	      for (unsigned int column_cell=0, column=cell*this->blocksize;
		   column_cell<this->blocksize; ++column_cell, ++column)
		M_cell(row_cell,column_cell)=M(row,column);
	    }
	  Householder<number> house(M_cell);
	  house.least_squares(x_cell,b_cell);
					   // distribute x_cell to dst
	  for (row=cell*this->blocksize, row_cell=0;
	       row_cell<this->blocksize;
	       ++row_cell, ++row)
	    if (adding)
	      dst(row)+=x_cell(row_cell);
	    else
	      dst(row)=x_cell(row_cell);
	  
	  begin_diag_block+=this->blocksize;
	}
    }
  else
    for (unsigned int cell=0; cell < this->nblocks; ++cell)
      {
	for (row=cell*this->blocksize, row_cell=0;
	     row_cell<this->blocksize;
	     ++row_cell, ++row)
	  {
	    b_cell(row_cell)=src(row);
	  }
	this->inverse(cell).vmult(x_cell, b_cell);
					 // distribute x_cell to dst
	for (row=cell*this->blocksize, row_cell=0;
	     row_cell<this->blocksize;
	     ++row_cell, ++row)
	  if (adding)
	    dst(row)+=x_cell(row_cell);
	  else
	    dst(row)=x_cell(row_cell);
	
	begin_diag_block+=this->blocksize;
      }
  dst.scale(this->relaxation);
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockJacobi<MATRIX,inverse_type>
::vmult (Vector<number2>       &dst,
	 const Vector<number2> &src) const
{
  do_vmult(dst, src, false);
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockJacobi<MATRIX,inverse_type>
::Tvmult (Vector<number2>       &dst,
	  const Vector<number2> &src) const
{
  do_vmult(dst, src, false);
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockJacobi<MATRIX,inverse_type>
::vmult_add (Vector<number2>       &dst,
	     const Vector<number2> &src) const
{
  do_vmult(dst, src, true);
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockJacobi<MATRIX,inverse_type>
::Tvmult_add (Vector<number2>       &dst,
	      const Vector<number2> &src) const
{
  do_vmult(dst, src, true);
}


/*--------------------- PreconditionBlockSOR -----------------------*/


template <class MATRIX, typename inverse_type>
void PreconditionBlockSOR<MATRIX,inverse_type>::set_permutation (
  const std::vector<unsigned int>& p,
  const std::vector<unsigned int>& i)
{
  Assert (p.size() == i.size(), ExcDimensionMismatch(p.size(), i.size()));
  permutation.resize(p.size());
  inverse_permutation.resize(p.size());
  for (unsigned int k=0;k<p.size();++k)
    {
      permutation[k] = p[k];
      inverse_permutation[k] = i[k];
    }
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSOR<MATRIX,inverse_type>::forward (
  Vector<number2>       &dst,
  const Vector<number2> &src,
  const bool transpose_diagonal,
  const bool) const
{
				   // introduce the following typedef
				   // since in the use of exceptions,
				   // strict C++ requires us to
				   // specify them fully as they are
				   // from a template dependent base
				   // class. thus, we'd have to write
				   // PreconditionBlock<number,inverse_type>::ExcNoMatrixGivenToUse,
				   // which is lengthy, but also poses
				   // some problems to the
				   // preprocessor due to the comma in
				   // the template arg list. we could
				   // then wrap the whole thing into
				   // parentheses, but that creates a
				   // parse error for gcc for the
				   // exceptions that do not take
				   // args...
  typedef PreconditionBlock<MATRIX,inverse_type> BaseClass;

  Assert (this->A!=0, ExcNotInitialized());
  
  const MATRIX &M=*this->A;
  const bool permuted = (permutation.size() != 0);
  if (permuted)
    {
      Assert (permutation.size() == M.m(), ExcDimensionMismatch(permutation.size(), M.m()));
    }
  
  Vector<number2> b_cell(this->blocksize), x_cell(this->blocksize);

				       // cell_row, cell_column are the
				       // numbering of the blocks (cells).
				       // row_cell, column_cell are the local
				       // numbering of the unknowns in the
				       // blocks.
				       // row, column are the global numbering
				       // of the unkowns.
  unsigned int row, row_cell, block_start=0;
  number2 b_cell_row;
				   // The diagonal block if the
				   // inverses were not precomputed
  FullMatrix<number> M_cell(this->blocksize);
  
  for (unsigned int cell=0; cell < this->nblocks; ++cell)
    {
      const unsigned int permuted_block_start = permuted
						? permutation[block_start]
						:block_start;
      
      for (row = permuted_block_start, row_cell = 0;
	   row_cell < this->blocksize;
	   ++row_cell, ++row)
	{
	  const typename MATRIX::const_iterator row_end = M.end(row);
	  typename MATRIX::const_iterator entry = M.begin(row);
	  
	  b_cell_row=src(row);
	  for (; entry != row_end; ++entry)
	    {
	      const unsigned int column = entry->column();
	      const unsigned int inverse_permuted_column = permuted
							   ? inverse_permutation[column]
							   : column;
	      
	      if (inverse_permuted_column < block_start)
		b_cell_row -= entry->value() * dst(column);
	      else if (!this->inverses_ready() && column < block_start + this->blocksize)
		{
		  const unsigned int column_cell = column - block_start;
		  if (transpose_diagonal)
		    M_cell(column_cell, row_cell) = entry->value();
		  else
		    M_cell(row_cell, column_cell) = entry->value();
		}
	    }
	  b_cell(row_cell)=b_cell_row;
	}
      if (this->inverses_ready())
	{
	  if (transpose_diagonal)
	    this->inverse(cell).Tvmult(x_cell, b_cell);
	  else
	    this->inverse(cell).vmult(x_cell, b_cell);
	}
      else
	{
	  Householder<number> house(M_cell);
	  house.least_squares(x_cell,b_cell);
	}
      
				       // distribute x_cell to dst
      for (row=permuted_block_start, row_cell=0;
	   row_cell<this->blocksize;
	   ++row_cell, ++row)
	dst(row)=this->relaxation*x_cell(row_cell);
      
      block_start+=this->blocksize;
    }
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSOR<MATRIX,inverse_type>::backward (
  Vector<number2>       &dst,
  const Vector<number2> &src,
  const bool transpose_diagonal,
  const bool) const
{
				   // introduce the following typedef
				   // since in the use of exceptions,
				   // strict C++ requires us to
				   // specify them fully as they are
				   // from a template dependent base
				   // class. thus, we'd have to write
				   // PreconditionBlock<number,inverse_type>::ExcNoMatrixGivenToUse,
				   // which is lengthy, but also poses
				   // some problems to the
				   // preprocessor due to the comma in
				   // the template arg list. we could
				   // then wrap the whole thing into
				   // parentheses, but that creates a
				   // parse error for gcc for the
				   // exceptions that do not take
				   // args...
  typedef PreconditionBlock<MATRIX,inverse_type> BaseClass;

  Assert (this->A!=0, ExcNotInitialized());
  
  const MATRIX &M=*this->A;
  const bool permuted = (permutation.size() != 0);
  if (permuted)
    {
      Assert (permutation.size() == M.m(), ExcDimensionMismatch(permutation.size(), M.m()));
    }

  Vector<number2> b_cell(this->blocksize), x_cell(this->blocksize);

				       // cell_row, cell_column are the
				       // numbering of the blocks (cells).
				       // row_cell, column_cell are the local
				       // numbering of the unknowns in the
				       // blocks.
				       // row, column are the global numbering
				       // of the unkowns.
  unsigned int row, row_cell;
  unsigned int block_end=this->blocksize * this->nblocks;
  number2 b_cell_row;

  FullMatrix<number> M_cell(this->blocksize);
  for (unsigned int cell=this->nblocks; cell!=0 ;)
    {
      --cell;
      const unsigned int block_start = block_end - this->blocksize;
				       // Collect upper triangle
      const unsigned int permuted_block_start = (permutation.size() != 0)
						? permutation[block_start]
						:block_start;
      for (row = permuted_block_start, row_cell = 0;
	   row_cell<this->blocksize;
	   ++row_cell, ++row)
	{
	  const typename MATRIX::const_iterator row_end = M.end(row);
	  typename MATRIX::const_iterator entry = M.begin(row);
	  
	  b_cell_row=src(row);
	  for (; entry != row_end; ++entry)
	    {
	      const unsigned int column = entry->column();
	      const unsigned int inverse_permuted_column = permuted
							   ? inverse_permutation[column]
							   : column;
	      if (inverse_permuted_column >= block_end)
		b_cell_row -= entry->value() * dst(column);
	      else if (!this->inverses_ready() && column >= block_start)
		{
		  const unsigned int column_cell = column - block_start;
						   // We need the
						   // transpose of the
						   // diagonal block,
						   // so we switch row
						   // and column
						   // indices
		  if (transpose_diagonal)
		    M_cell(column_cell, row_cell) = entry->value();
		  else
		    M_cell(row_cell, column_cell) = entry->value();
		}
	    }
	  b_cell(row_cell)=b_cell_row;
	}
      if (this->inverses_ready())
	{
	  if (transpose_diagonal)
	    this->inverse(cell).Tvmult(x_cell, b_cell);
	  else
	    this->inverse(cell).vmult(x_cell, b_cell);
	}
      else
	{
	  Householder<number> house(M_cell);
	  house.least_squares(x_cell,b_cell);
	}
      
      
				       // distribute x_cell to dst
      for (row=permuted_block_start, row_cell=0;
	   row_cell<this->blocksize;
	   ++row_cell, ++row)
	dst(row)=this->relaxation*x_cell(row_cell);
      block_end = block_start;
      
    }
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSOR<MATRIX,inverse_type>
::vmult (Vector<number2>       &dst,
	 const Vector<number2> &src) const
{
  forward(dst, src, false, false);
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSOR<MATRIX,inverse_type>
::vmult_add (Vector<number2>       &dst,
	     const Vector<number2> &src) const
{
  forward(dst, src, false, true);
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSOR<MATRIX,inverse_type>
::Tvmult (Vector<number2>       &dst,
	 const Vector<number2> &src) const
{
  backward(dst, src, true, false);
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSOR<MATRIX,inverse_type>
::Tvmult_add (Vector<number2>       &dst,
	     const Vector<number2> &src) const
{
  backward(dst, src, true, true);
}


//---------------------------------------------------------------------------


template <class MATRIX, typename inverse_type>
PreconditionBlockSSOR<MATRIX,inverse_type>::PreconditionBlockSSOR ()
{
  this->store_diagonals = 1;
}


template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSSOR<MATRIX,inverse_type>::vmult (Vector<number2>       &dst,
							const Vector<number2> &src) const
{
  Vector<number2> help;
  help.reinit(dst);
  
  this->forward(help, src, false, false);

  Vector<inverse_type> cell_src(this->blocksize);
  Vector<inverse_type> cell_dst(this->blocksize);
  const double scaling = (2.-this->relaxation)/this->relaxation;
  
				   // Multiply with diagonal blocks
  for (unsigned int cell=0; cell < this->nblocks; ++cell)
    {
      unsigned int row = cell*this->blocksize;
      
      for (unsigned int row_cell=0; row_cell<this->blocksize; ++row_cell)
	cell_src(row_cell)=help(row+row_cell);

      this->diagonal(cell).vmult(cell_dst, cell_src);

      for (unsigned int row_cell=0; row_cell<this->blocksize; ++row_cell)
	help(row+row_cell) = scaling * cell_dst(row_cell);
    }
  
  this->backward(dst, help, false, false);
}

template <class MATRIX, typename inverse_type>
template <typename number2>
void PreconditionBlockSSOR<MATRIX,inverse_type>::Tvmult (Vector<number2>       &dst,
							const Vector<number2> &src) const
{
  Vector<number2> help;
  help.reinit(dst);
  
  this->backward(help, src, true, false);

  Vector<inverse_type> cell_src(this->blocksize);
  Vector<inverse_type> cell_dst(this->blocksize);
  const double scaling = (2.-this->relaxation)/this->relaxation;
  
				   // Multiply with diagonal blocks
  for (unsigned int cell=0; cell < this->nblocks; ++cell)
    {
      unsigned int row = cell*this->blocksize;
      
      for (unsigned int row_cell=0; row_cell<this->blocksize; ++row_cell)
	cell_src(row_cell)=help(row+row_cell);

      this->diagonal(cell).Tvmult(cell_dst, cell_src);

      for (unsigned int row_cell=0; row_cell<this->blocksize; ++row_cell)
	help(row+row_cell) = scaling * cell_dst(row_cell);
    }
  
  this->forward(dst, help, true, false);
}

DEAL_II_NAMESPACE_CLOSE

#endif
