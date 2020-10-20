!c     Calculate the contribution to the stress energy tensor T_munu
!c     which are calcualated via the CalcTmunu.inc mechanism.
!c     Then make a copy of that into the T2munu variables.
subroutine TmunuBase_SetTmunu (cctk_dim,cctk_gsh,cctk_lsh,cctk_lbn&
     &d,cctk_ubnd,cctk_ash,cctk_from,cctk_to,cctk_bbox,cctk_delta_time,c&
     &ctk_time,cctk_delta_space,cctk_origin_space,cctk_levfac,cctk_levof&
     &f,cctk_levoffdenom,cctk_timefac,cctk_convlevel,cctk_convfac,cctk_n&
     &ghostzones,cctk_iteration,cctkGH,cctk_ash1,cctk_ash2,cctk_ash3, eT&
     &2tt,eT2tx,eT2ty,eT2tz,eT2xx,eT2xy,eT2xz,eT2yy,eT2yz,eT2zz,stress_e&
     &nergy_2_state, alp,alp_p,alp_p_p,betax,betax_p,betax_p_p,betay,bet&
     &ay_p,betay_p_p,betaz,betaz_p,betaz_p_p,coarse_dx,coarse_dy,coarse_&
     &dz,conformal_state,dtalp,dtalp_p,dtalp_p_p,dtbetax,dtbetax_p,dtbet&
     &ax_p_p,dtbetay,dtbetay_p,dtbetay_p_p,dtbetaz,dtbetaz_p,dtbetaz_p_p&
     &,dtlapse_state,dtshift_state,eTtt,eTtt_p,eTtt_p_p,eTtx,eTtx_p,eTtx&
     &_p_p,eTty,eTty_p,eTty_p_p,eTtz,eTtz_p,eTtz_p_p,eTxx,eTxx_p,eTxx_p_&
     &p,eTxy,eTxy_p,eTxy_p_p,eTxz,eTxz_p,eTxz_p_p,eTyy,eTyy_p,eTyy_p_p,e&
     &Tyz,eTyz_p,eTyz_p_p,eTzz,eTzz_p,eTzz_p_p,gxx,gxx_p,gxx_p_p,gxy,gxy&
     &_p,gxy_p_p,gxz,gxz_p,gxz_p_p,gyy,gyy_p,gyy_p_p,gyz,gyz_p,gyz_p_p,g&
     &zz,gzz_p,gzz_p_p,kxx,kxx_p,kxx_p_p,kxy,kxy_p,kxy_p_p,kxz,kxz_p,kxz&
     &_p_p,kyy,kyy_p,kyy_p_p,kyz,kyz_p,kyz_p_p,kzz,kzz_p,kzz_p_p,psi,psi&
     &x,psixx,psixy,psixz,psiy,psiyy,psiyz,psiz,psizz,r,shift_state,stre&
     &ss_energy_state,x,y,z)
      use iso_c_binding
      implicit none
      INTEGER cctk_dim
      integer, parameter :: cctki_use_cctk_dim = kind(cctk_dim)
      INTEGER cctk_gsh (cctk_dim)
      integer, parameter :: cctki_use_cctk_gsh = kind(cctk_gsh)
      INTEGER cctk_lsh (cctk_dim)
      integer, parameter :: cctki_use_cctk_lsh = kind(cctk_lsh)
      INTEGER cctk_lbnd (cctk_dim)
      integer, parameter :: cctki_use_cctk_lbnd = kind(cctk_lbnd)
      INTEGER cctk_ubnd (cctk_dim)
      integer, parameter :: cctki_use_cctk_ubnd = kind(cctk_ubnd)
      INTEGER cctk_ash (cctk_dim)
      integer, parameter :: cctki_use_cctk_ash = kind(cctk_ash)
      INTEGER cctk_from (cctk_dim)
      integer, parameter :: cctki_use_cctk_from = kind(cctk_from)
      INTEGER cctk_to (cctk_dim)
      integer, parameter :: cctki_use_cctk_to = kind(cctk_to)
      INTEGER cctk_bbox (2*cctk_dim)
      integer, parameter :: cctki_use_cctk_bbox = kind(cctk_bbox)
      REAL(8) cctk_delta_time
      integer, parameter :: cctki_use_cctk_delta_time = kind(cctk_delta_time)
      REAL(8) cctk_time
      integer, parameter :: cctki_use_cctk_time = kind(cctk_time)
      REAL(8) cctk_delta_space (cctk_dim)
      integer, parameter :: cctki_use_cctk_delta_space = kind(cctk_delta_space)
      REAL(8) cctk_origin_space (cctk_dim)
      integer, parameter :: cctki_use_cctk_origin_space = kind(cctk_origin_space)
      INTEGER cctk_levfac (cctk_dim)
      integer, parameter :: cctki_use_cctk_levfac = kind(cctk_levfac)
      INTEGER cctk_levoff (cctk_dim)
      integer, parameter :: cctki_use_cctk_levoff = kind(cctk_levoff)
      INTEGER cctk_levoffdenom (cctk_dim)
      integer, parameter :: cctki_use_cctk_levoffdenom = kind(cctk_levoffdenom)
      INTEGER cctk_timefac
      integer, parameter :: cctki_use_cctk_timefac = kind(cctk_timefac)
      INTEGER cctk_convlevel
      integer, parameter :: cctki_use_cctk_convlevel = kind(cctk_convlevel)
      INTEGER cctk_convfac
      integer, parameter :: cctki_use_cctk_convfac = kind(cctk_convfac)
      INTEGER cctk_nghostzones (cctk_dim)
      integer, parameter :: cctki_use_cctk_nghostzones = kind(cctk_nghostzones)
      INTEGER cctk_iteration
      integer, parameter :: cctki_use_cctk_iteration = kind(cctk_iteration)
      integer(c_size_t) cctkGH
      integer, parameter :: cctki_use_cctkGH = kind(cctkGH)
      INTEGER cctk_ash1
      integer, parameter :: cctki_use_cctk_ash1 = kind(cctk_ash1)
      INTEGER cctk_ash2
      integer, parameter :: cctki_use_cctk_ash2 = kind(cctk_ash2)
      INTEGER cctk_ash3
      integer, parameter :: cctki_use_cctk_ash3 = kind(cctk_ash3)
      REAL(8) eT2tt (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2tt = kind(eT2tt)
      REAL(8) eT2tx (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2tx = kind(eT2tx)
      REAL(8) eT2ty (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2ty = kind(eT2ty)
      REAL(8) eT2tz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2tz = kind(eT2tz)
      REAL(8) eT2xx (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2xx = kind(eT2xx)
      REAL(8) eT2xy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2xy = kind(eT2xy)
      REAL(8) eT2xz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2xz = kind(eT2xz)
      REAL(8) eT2yy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2yy = kind(eT2yy)
      REAL(8) eT2yz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2yz = kind(eT2yz)
      REAL(8) eT2zz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eT2zz = kind(eT2zz)
      INTEGER(4) stress_energy_2_state
      integer, parameter :: cctki_use_stress_energy_2_state = &
     &kind(stress_energy_2_state)
      REAL(8) alp (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_alp = kind(alp)
      REAL(8) alp_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_alp_p = kind(alp_p)
      REAL(8) alp_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_alp_p_p = kind(alp_p_p)
      REAL(8) betax (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betax = kind(betax)
      REAL(8) betax_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betax_p = kind(betax_p)
      REAL(8) betax_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betax_p_p = kind(betax_p_p)
      REAL(8) betay (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betay = kind(betay)
      REAL(8) betay_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betay_p = kind(betay_p)
      REAL(8) betay_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betay_p_p = kind(betay_p_p)
      REAL(8) betaz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betaz = kind(betaz)
      REAL(8) betaz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betaz_p = kind(betaz_p)
      REAL(8) betaz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_betaz_p_p = kind(betaz_p_p)
      REAL(8) coarse_dx
      integer, parameter :: cctki_use_coarse_dx = kind(coarse_dx)
      REAL(8) coarse_dy
      integer, parameter :: cctki_use_coarse_dy = kind(coarse_dy)
      REAL(8) coarse_dz
      integer, parameter :: cctki_use_coarse_dz = kind(coarse_dz)
      INTEGER(4) conformal_state
      integer, parameter :: cctki_use_conformal_state = &
     &kind(conformal_state)
      REAL(8) dtalp (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtalp = kind(dtalp)
      REAL(8) dtalp_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtalp_p = kind(dtalp_p)
      REAL(8) dtalp_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtalp_p_p = kind(dtalp_p_p)
      REAL(8) dtbetax (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetax = kind(dtbetax)
      REAL(8) dtbetax_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetax_p = kind(dtbetax_p)
      REAL(8) dtbetax_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetax_p_p = kind(dtbetax_p_p)
      REAL(8) dtbetay (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetay = kind(dtbetay)
      REAL(8) dtbetay_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetay_p = kind(dtbetay_p)
      REAL(8) dtbetay_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetay_p_p = kind(dtbetay_p_p)
      REAL(8) dtbetaz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetaz = kind(dtbetaz)
      REAL(8) dtbetaz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetaz_p = kind(dtbetaz_p)
      REAL(8) dtbetaz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_dtbetaz_p_p = kind(dtbetaz_p_p)
      INTEGER(4) dtlapse_state
      integer, parameter :: cctki_use_dtlapse_state = &
     &kind(dtlapse_state)
      INTEGER(4) dtshift_state
      integer, parameter :: cctki_use_dtshift_state = &
     &kind(dtshift_state)
      REAL(8) eTtt (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtt = kind(eTtt)
      REAL(8) eTtt_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtt_p = kind(eTtt_p)
      REAL(8) eTtt_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtt_p_p = kind(eTtt_p_p)
      REAL(8) eTtx (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtx = kind(eTtx)
      REAL(8) eTtx_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtx_p = kind(eTtx_p)
      REAL(8) eTtx_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtx_p_p = kind(eTtx_p_p)
      REAL(8) eTty (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTty = kind(eTty)
      REAL(8) eTty_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTty_p = kind(eTty_p)
      REAL(8) eTty_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTty_p_p = kind(eTty_p_p)
      REAL(8) eTtz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtz = kind(eTtz)
      REAL(8) eTtz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtz_p = kind(eTtz_p)
      REAL(8) eTtz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTtz_p_p = kind(eTtz_p_p)
      REAL(8) eTxx (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxx = kind(eTxx)
      REAL(8) eTxx_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxx_p = kind(eTxx_p)
      REAL(8) eTxx_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxx_p_p = kind(eTxx_p_p)
      REAL(8) eTxy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxy = kind(eTxy)
      REAL(8) eTxy_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxy_p = kind(eTxy_p)
      REAL(8) eTxy_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxy_p_p = kind(eTxy_p_p)
      REAL(8) eTxz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxz = kind(eTxz)
      REAL(8) eTxz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxz_p = kind(eTxz_p)
      REAL(8) eTxz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTxz_p_p = kind(eTxz_p_p)
      REAL(8) eTyy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTyy = kind(eTyy)
      REAL(8) eTyy_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTyy_p = kind(eTyy_p)
      REAL(8) eTyy_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTyy_p_p = kind(eTyy_p_p)
      REAL(8) eTyz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTyz = kind(eTyz)
      REAL(8) eTyz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTyz_p = kind(eTyz_p)
      REAL(8) eTyz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTyz_p_p = kind(eTyz_p_p)
      REAL(8) eTzz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTzz = kind(eTzz)
      REAL(8) eTzz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTzz_p = kind(eTzz_p)
      REAL(8) eTzz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_eTzz_p_p = kind(eTzz_p_p)
      REAL(8) gxx (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxx = kind(gxx)
      REAL(8) gxx_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxx_p = kind(gxx_p)
      REAL(8) gxx_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxx_p_p = kind(gxx_p_p)
      REAL(8) gxy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxy = kind(gxy)
      REAL(8) gxy_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxy_p = kind(gxy_p)
      REAL(8) gxy_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxy_p_p = kind(gxy_p_p)
      REAL(8) gxz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxz = kind(gxz)
      REAL(8) gxz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxz_p = kind(gxz_p)
      REAL(8) gxz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gxz_p_p = kind(gxz_p_p)
      REAL(8) gyy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gyy = kind(gyy)
      REAL(8) gyy_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gyy_p = kind(gyy_p)
      REAL(8) gyy_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gyy_p_p = kind(gyy_p_p)
      REAL(8) gyz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gyz = kind(gyz)
      REAL(8) gyz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gyz_p = kind(gyz_p)
      REAL(8) gyz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gyz_p_p = kind(gyz_p_p)
      REAL(8) gzz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gzz = kind(gzz)
      REAL(8) gzz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gzz_p = kind(gzz_p)
      REAL(8) gzz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_gzz_p_p = kind(gzz_p_p)
      REAL(8) kxx (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxx = kind(kxx)
      REAL(8) kxx_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxx_p = kind(kxx_p)
      REAL(8) kxx_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxx_p_p = kind(kxx_p_p)
      REAL(8) kxy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxy = kind(kxy)
      REAL(8) kxy_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxy_p = kind(kxy_p)
      REAL(8) kxy_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxy_p_p = kind(kxy_p_p)
      REAL(8) kxz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxz = kind(kxz)
      REAL(8) kxz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxz_p = kind(kxz_p)
      REAL(8) kxz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kxz_p_p = kind(kxz_p_p)
      REAL(8) kyy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kyy = kind(kyy)
      REAL(8) kyy_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kyy_p = kind(kyy_p)
      REAL(8) kyy_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kyy_p_p = kind(kyy_p_p)
      REAL(8) kyz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kyz = kind(kyz)
      REAL(8) kyz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kyz_p = kind(kyz_p)
      REAL(8) kyz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kyz_p_p = kind(kyz_p_p)
      REAL(8) kzz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kzz = kind(kzz)
      REAL(8) kzz_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kzz_p = kind(kzz_p)
      REAL(8) kzz_p_p (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_kzz_p_p = kind(kzz_p_p)
      REAL(8) psi (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psi = kind(psi)
      REAL(8) psix (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psix = kind(psix)
      REAL(8) psixx (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psixx = kind(psixx)
      REAL(8) psixy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psixy = kind(psixy)
      REAL(8) psixz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psixz = kind(psixz)
      REAL(8) psiy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psiy = kind(psiy)
      REAL(8) psiyy (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psiyy = kind(psiyy)
      REAL(8) psiyz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psiyz = kind(psiyz)
      REAL(8) psiz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psiz = kind(psiz)
      REAL(8) psizz (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_psizz = kind(psizz)
      REAL(8) r (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_r = kind(r)
      INTEGER(4) shift_state
      integer, parameter :: cctki_use_shift_state = kind(shift_state)
      INTEGER(4) stress_energy_state
      integer, parameter :: cctki_use_stress_energy_state = &
     &kind(stress_energy_state)
      REAL(8) x (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_x = kind(x)
      REAL(8) y (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_y = kind(y)
      REAL(8) z (cctk_ash1,cctk_ash2,cctk_ash3)
      integer, parameter :: cctki_use_z = kind(z)
      
      external     CCTK_PointerTo
      integer(c_size_t) CCTK_PointerTo
      interface
      integer function CCTK_Equals (arg1, arg2)
      use iso_c_binding
      implicit none
      integer(c_size_t) arg1
      character(c_char) arg2(*)
      end function CCTK_Equals
      integer function CCTK_MyProc (cctkGH)
      use iso_c_binding
      implicit none
      integer(c_size_t) cctkGH
      end function CCTK_MyProc
      integer function CCTK_nProcs (cctkGH)
      use iso_c_binding
      implicit none
      integer(c_size_t) cctkGH
      end function CCTK_nProcs
      integer function CCTK_IsThornActive (name)
      use iso_c_binding
      implicit none
      character(c_char) name(*)
      end function CCTK_IsThornActive
      integer(c_size_t) function CCTK_NullPointer ()
      use iso_c_binding
      implicit none
      end function CCTK_NullPointer
      end interface
      
      INTEGER(4) stress_energy_at_RHS
      integer, parameter :: cctki_use_stress_energy_at_RHS = &
     &kind(stress_energy_at_RHS)
      INTEGER(4) support_old_CalcTmunu_mechanism
      integer, parameter :: cctki_use_support_old_CalcTmunu_mechanism =&
     &kind(support_old_CalcTmunu_mechanism)
      COMMON /TmunuBaserest/stress_energy_at_RHS, &
     &support_old_CalcTmunu_mechanism
      integer(8) prolongation_type
      integer, parameter :: cctki_use_prolongation_type = &
     &kind(prolongation_type)
      INTEGER(4) stress_energy_storage
      integer, parameter :: cctki_use_stress_energy_storage = &
     &kind(stress_energy_storage)
      INTEGER(4) timelevels
      integer, parameter :: cctki_use_timelevels = kind(timelevels)
      COMMON /TmunuBasepriv/prolongation_type, stress_energy_storage, &
     &timelevels
      
      REAL(8) detg_psi4
      REAL(8) detg_tempxx,detg_tempxy,detg_tempxz
      REAL(8) detg_tempyy,detg_tempyz,detg_tempzz
      REAL(8) detg_detg, detg_detcg
      REAL(8) iuppermet_fdet
      REAL(8) uppermet_uxx, uppermet_uxy, uppermet_uxz
      REAL(8) uppermet_uyy, uppermet_uyz, uppermet_uzz
       REAL(8) trt_ialp2
       REAL(8) trt_trt
      REAL(8) Ttt
      REAL(8) Ttx
      REAL(8) Tty
      REAL(8) Ttz
      REAL(8) Txx
      REAL(8) Txy
      REAL(8) Txz
      REAL(8) Tyy
      REAL(8) Tyz
      REAL(8) Tzz
      REAL(8) uxx,uxy,uxz,uyy,uyz,uzz
      REAL(8) detg
      integer i, j, k
      do k = 1, cctk_lsh(3)
         do j = 1, cctk_lsh(2)
            do i = 1, cctk_lsh(1)
      IF (conformal_state .eq. 0) THEN
         detg_psi4 = 1.0d0
      ELSE
         detg_psi4 = psi(i,j,k)**4
      ENDIF
      detg_tempxx =  gyy(i,j,k)*gzz(i,j,k) - gyz(i,j,k)*gyz(i,j,k)
      detg_tempxy =  gxz(i,j,k)*gyz(i,j,k) - gxy(i,j,k)*gzz(i,j,k)
      detg_tempxz = -gxz(i,j,k)*gyy(i,j,k) + gxy(i,j,k)*gyz(i,j,k)
      detg_tempyy =  gxx(i,j,k)*gzz(i,j,k) - gxz(i,j,k)*gxz(i,j,k)
      detg_tempyz =  gxy(i,j,k)*gxz(i,j,k) - gxx(i,j,k)*gyz(i,j,k)
      detg_tempzz =  gxx(i,j,k)*gyy(i,j,k) - gxy(i,j,k)*gxy(i,j,k)
      detg_detcg = (detg_tempxx*gxx(i,j,k) +           detg_tempxy*&
     &gxy(i,j,k) + detg_tempxz*gxz(i,j,k))
      detg_detg = detg_psi4**3*detg_detcg
      iuppermet_fdet = 1.d0 / (detg_psi4*detg_detcg)
      uppermet_uxx = detg_tempxx*iuppermet_fdet
      uppermet_uxy = detg_tempxy*iuppermet_fdet
      uppermet_uxz = detg_tempxz*iuppermet_fdet
      uppermet_uyy = detg_tempyy*iuppermet_fdet
      uppermet_uyz = detg_tempyz*iuppermet_fdet
      uppermet_uzz = detg_tempzz*iuppermet_fdet
      uxx = uppermet_uxx; uyy = uppermet_uyy; uzz = uppermet_uzz
      uxy = uppermet_uxy; uxz = uppermet_uxz; uyz = uppermet_uyz
      detg = detg_detcg
      Ttt = 0.0D0; Ttx = 0.0D0
      Tty = 0.0D0; Ttz = 0.0D0
      Txx = 0.0D0; Txy = 0.0D0
      Txz = 0.0D0; Tyy = 0.0D0
      Tyz = 0.0D0; Tzz = 0.0D0
      if (CCTK_IsThornActive("TmunuBase").eq.1) then
      end if
      trt_ialp2 = 1D0/alp(i,j,k)**2
      trt_trt = -Ttt*trt_ialp2+Txx*uppermet_uxx+Tyy*uppermet_uyy+Tzz* &
     &uppermet_uzz+2D0*(Txy*uppermet_uxy+Txz*uppermet_uxz+Tyz* &
     &uppermet_uyz)
      if (shift_state .ne. 0) then
        trt_trt = trt_trt - trt_ialp2*(Txx*betax(i,j,k)*betax(i,j,k) &
     &                               + Tyy*betay(i,j,k)*betay(i,j,k) &
     &                               + Tzz*betaz(i,j,k)*betaz(i,j,k) &
     &                          + 2D0*(Txy*betax(i,j,k)*betay(i,j,k) &
     &                                + Txz*betax(i,j,k)*betaz(i,j,k) &
     &                                + Tyz*betay(i,j,k)*betaz(i,j,k) &
     &                                - Ttx*betax(i,j,k) &
     &                                - Tty*betay(i,j,k) &
     &                                - Ttz*betaz(i,j,k)))
      endif
               eTtt(i,j,k) = Ttt
               eTtx(i,j,k) = Ttx
               eTty(i,j,k) = Tty
               eTtz(i,j,k) = Ttz
               eTxx(i,j,k) = Txx
               eTxy(i,j,k) = Txy
               eTxz(i,j,k) = Txz
               eTyy(i,j,k) = Tyy
               eTyz(i,j,k) = Tyz
               eTzz(i,j,k) = Tzz
            end do
         end do
      end do
      eT2tt = eTtt
      eT2tx = eTtx
      eT2ty = eTty
      eT2tz = eTtz
      eT2xx = eTxx
      eT2xy = eTxy
      eT2xz = eTxz
      eT2yy = eTyy
      eT2yz = eTyz
      eT2zz = eTzz
      end
