//---------------------------------------------------------------------------
//    $Id: swappable_vector.templates.h 14038 2006-10-23 02:46:34Z bangerth $
//    Version: $Name$
//
//    Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005, 2006 by the deal.II authors
//
//    This file is subject to QPL and may not be  distributed
//    without copyright and license information. Please refer
//    to the file deal.II/doc/license.html for the  text  and
//    further information on this license.
//
//---------------------------------------------------------------------------
#ifndef __deal2__swappable_vector_templates_h
#define __deal2__swappable_vector_templates_h


#include <base/memory_consumption.h>
#include <lac/swappable_vector.h>
#include <fstream>

DEAL_II_NAMESPACE_OPEN


template <typename number>
SwappableVector<number>::SwappableVector ()
		:
		data_is_preloaded (false)
{}



template <typename number>
SwappableVector<number>::SwappableVector (const SwappableVector<number> &v) :
		Vector<number>(v),
                filename (),
                data_is_preloaded (false)
{
  Assert (v.filename == "", ExcInvalidCopyOperation());
}



template <typename number>
SwappableVector<number>::~SwappableVector ()
{
				   // if the vector was stored in a
				   // file previously, and that has
				   // not been deleted in the
				   // meantime, then we kill that file
				   // first, before killing the vector
				   // itself

  if (filename != "")
    kill_file ();
}



template <typename number>
SwappableVector<number> &
SwappableVector<number>::operator= (const SwappableVector<number> &v)
{
				   // if necessary, first delete data
  if (filename != "")
    kill_file ();

				   // if in MT mode, block all other
				   // operations. if not in MT mode,
				   // this is a no-op
  Threads::ThreadMutex::ScopedLock lock(this->lock);
  
  Vector<number>::operator = (v);
  data_is_preloaded = false;
  
  return *this;
}



template <typename number>
void SwappableVector<number>::swap_out (const std::string &name)
{
				   // if the vector was stored in
				   // another file previously, and
				   // that has not been deleted in the
				   // meantime, then we kill that file
				   // first
  if (filename != "")
    kill_file ();
  
  filename = name;
  
  Assert (this->size() != 0, ExcSizeZero());

				   // if in MT mode, block all other
				   // operations. if not in MT mode,
				   // this is a no-op
  Threads::ThreadMutex::ScopedLock lock(this->lock);

                                   //  check that we have not called
				   //  @p alert without the respective
				   //  @p reload function
  Assert (data_is_preloaded == false, ExcInternalError());
  
  std::ofstream tmp_out(filename.c_str());
  this->block_write (tmp_out);
  tmp_out.close ();
	
  this->reinit (0);
}



template <typename number>
void SwappableVector<number>::reload () 
{
				   // if in MT mode: synchronise with
				   // possibly existing @p alert
				   // calls. if not in MT mode, this
				   // is a no-op
  lock.acquire ();
  
				   // if data was already preloaded,
				   // then there is no more need to
				   // load it
  if (data_is_preloaded == false)
				     // reload data. note that this
				     // function also releases the
				     // lock
    reload_vector (false);
  else
    {
				       // clear flag since no more
				       // needed
      data_is_preloaded = false;

				       // release lock. the lock is
				       // also released in the other
				       // branch of the if-clause
      lock.release ();
    };
}



template <typename number>
void SwappableVector<number>::alert ()
{
				   // note: this function does nothing
				   // in non-MT mode
  if (!DEAL_II_USE_MT)
    return;
  
				   // synchronise with possible other
				   // invocations of this function and
				   // other functions in this class
  lock.acquire ();
  
				   // calling this function multiple
				   // times does no harm:
  if ( (data_is_preloaded == true) ||
				   // calling this function while the
				   // vector is active does no harm
				   // either
       (this->size() != 0))
    lock.release ();
  else
				     // data has not been preloaded so
				     // far, so go on! For this, start
				     // a detached thread
    Threads::spawn (*this, &SwappableVector<number>::reload_vector)(true);
				   // note that reload_vector also
				   // releases the lock
}



template <typename number>
void SwappableVector<number>::reload_vector (const bool set_flag)
{
  Assert (filename != "", ExcInvalidFilename (filename));
  Assert (this->size() == 0, ExcSizeNonzero());
  
  std::ifstream tmp_in(filename.c_str());
  this->block_read (tmp_in);
  tmp_in.close ();

				   // release the lock that was
				   // acquired by the calling
				   // functions
  if (DEAL_II_USE_MT)
    {
                                       // set the flag if so required
      if (set_flag)
        data_is_preloaded = true;
      lock.release ();
    };
}



template <typename number>
void SwappableVector<number>::kill_file () 
{
				   // if in MT mode, wait for other
				   // operations to finish first
				   // (there should be none, but who
				   // knows). if not in MT mode,
				   // this is a no-op
  Threads::ThreadMutex::ScopedLock lock(this->lock);

				   // this is too bad: someone
				   // requested the vector in advance,
				   // but never got to fetch it. this
				   // is most probably an error, not?
  Assert (data_is_preloaded == false, ExcInternalError());
  
  if (filename != "")
    {
      int status = std::remove (filename.c_str());
      AssertThrow (status == 0, ExcInternalError());
  
      filename = "";
    };
}



template <typename number>
const std::string &
SwappableVector<number>::get_filename () const 
{
  return filename;
}



template <typename number>
unsigned int
SwappableVector<number>::memory_consumption () const
{
  return (MemoryConsumption::memory_consumption (filename) +
	  sizeof(lock) +
	  MemoryConsumption::memory_consumption (data_is_preloaded) +
	  Vector<number>::memory_consumption ());
}




DEAL_II_NAMESPACE_CLOSE

#endif // __deal2__swappable_vector_templates_h
