module cctk_Misc
  use iso_c_binding
  implicit none
  interface
     subroutine Util_SplitString (ierr, before, before_length, after, after_length, string, sep)
       implicit none
       integer      ierr
       character(*) before
       integer      before_length
       character(*) after
       integer      after_length
       character(*) string
       character(*) sep
     end subroutine Util_SplitString
     ! CCTK_Equals is declared in cctk.h
     subroutine CCTK_FortranString (nchars, c_string, f_string) bind(c,name="cctk_fortranstring_") 
       use iso_c_binding
       implicit none
       integer(c_int) ::   nchars
       integer(c_size_t) :: c_string
       character(c_char) ::  f_string(*)
     end subroutine CCTK_FortranString
     subroutine Util_NullTerminateString (c_string, f_string)
       use iso_c_binding
       implicit none
       integer(c_size_t) c_string
       character(c_char) f_string(*)
     end subroutine Util_NullTerminateString
     subroutine Util_IntInRange (inrange, inval, range)
       implicit none
       integer      inrange
       integer      inval
       character(*) range
     end subroutine Util_IntInRange
     subroutine Util_DoubleInRange (inrange, inval, range)
       implicit none
       integer          inrange
       double precision inval
       character(*)     range
     end subroutine Util_DoubleInRange
     subroutine CCTK_SetString (ierr, data, value)
       use iso_c_binding
       implicit none
       integer      ierr
       integer(c_size_t) data
       character(c_char) value(*)
     end subroutine CCTK_SetString
     subroutine CCTK_SetBoolean (ierr, data, value)
       implicit none
       integer      ierr
       INTEGER(4)     data
       character(*) value
     end subroutine CCTK_SetBoolean
     subroutine CCTK_RunTime (time)
       implicit none
       integer time
     end subroutine CCTK_RunTime
     subroutine Util_CurrentTime (ierr, now)
       implicit none
       integer      ierr
       character(*) now
     end subroutine Util_CurrentTime
     subroutine Util_CurrentDate (ierr, now)
       implicit none
       integer      ierr
       character(*) now
     end subroutine Util_CurrentDate
     subroutine Util_RunTitle (ierr, title)
       implicit none
       integer      ierr
       character(*) title
     end subroutine Util_RunTitle
  end interface
  ! Do not declare these, because some compilers insist on a
  ! definition once they have seen an external declaration:
!!$  external Util_InList
!!$  external Util_IntInRangeList
!!$  external Util_DoubleInRangeList
!!$  external CCTK_SetDoubleInRangeList
!!$  external CCTK_SetIntInRangeList
!!$  external CCTK_SetKeywordInRangeList
end module cctk_Misc
