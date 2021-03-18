//---------------------------------------------------------------------------
//    $Id: petsc_vector.cc 15631 2008-01-17 23:47:31Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2004, 2006, 2008 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------


#include <lac/petsc_vector.h>

#include <cmath>

#ifdef DEAL_II_USE_PETSC

DEAL_II_NAMESPACE_OPEN

namespace PETScWrappers
{


  Vector::Vector ()
  {
    Vector::create_vector (0);
  }



  Vector::Vector (const unsigned int n)
  {
    Vector::create_vector (n);
  }

  

  Vector::Vector (const Vector &v)
                  :
                  VectorBase ()
  {
                                     // first create a dummy vector, then copy
                                     // over the other one
    Vector::create_vector (1);
    Vector::operator = (v);
  }



  Vector::Vector (const MPI::Vector &v)
  {
                                     // first create a dummy vector, then copy
                                     // over the other one
    Vector::create_vector (1);
    Vector::operator = (v);
  }



  void
  Vector::reinit (const unsigned int n,
                  const bool         fast)
  {
                                     // only do something if the sizes
                                     // mismatch
    if (size() != n)
      {
                                         // FIXME: I'd like to use this here,
                                         // but somehow it leads to odd errors
                                         // somewhere down the line in some of
                                         // the tests:
//         const int ierr = VecSetSizes (vector, n, n);
//         AssertThrow (ierr == 0, ExcPETScError(ierr));

                                         // so let's go the slow way:
        int ierr;
        ierr = VecDestroy (vector);
        AssertThrow (ierr == 0, ExcPETScError(ierr));

        create_vector (n);
      }

                                     // finally clear the new vector if so
                                     // desired
    if (fast == false)
      *this = 0;
  }



  void
  Vector::reinit (const Vector &v,
                  const bool    fast)
  {
    reinit (v.size(), fast);
  }
  

  
  void
  Vector::create_vector (const unsigned int n)
  {
    const int ierr
      = VecCreateSeq (PETSC_COMM_SELF, n, &vector);
    AssertThrow (ierr == 0, ExcPETScError(ierr));
  }
}

DEAL_II_NAMESPACE_CLOSE

#endif // DEAL_II_USE_PETSC
