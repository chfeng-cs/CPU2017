#ifdef EW_PERIODIC
# define IV_RANGE Istr-1,Iend+1
# define IU_RANGE Istr-1,Iend+1
#else
# define IV_RANGE MAX(1,Istr-1),MIN(Iend+1,Lm(ng))
# define IU_RANGE MAX(2,IstrU-1),MIN(Iend+1,Lm(ng))
#endif
#ifdef NS_PERIODIC
# define JU_RANGE Jstr-1,Jend+1
# define JV_RANGE Jstr-1,Jend+1
#else
# define JU_RANGE MAX(1,Jstr-1),MIN(Jend+1,Mm(ng))
# define JV_RANGE MAX(2,JstrV-1),MIN(Jend+1,Mm(ng))
#endif

      SUBROUTINE uv3dmix4 (ng, tile)
!
!svn $Id: uv3dmix4_geo.h 294 2009-01-09 21:37:26Z arango $
!************************************************** Hernan G. Arango ***
!  Copyright (c) 2002-2009 The ROMS/TOMS Group                         !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.txt                                              !
!***********************************************************************
!                                                                      !
!  This subroutine computes  biharmonic mixing of momentum,  rotated   !
!  along geopotentials, from the horizontal divergence of the stress   !
!  tensor.  A transverse isotropy is assumed so the stress tensor is   !
!  split into vertical and horizontal subtensors.                      !
!                                                                      !
!  Reference:                                                          !
!                                                                      !
!      Wajsowicz, R.C, 1993: A consistent formulation of the           !
!         anisotropic stress tensor for use in models of the           !
!         large-scale ocean circulation, JCP, 105, 333-338.            !
!                                                                      !
!      Sadourny, R. and K. Maynard, 1997: Formulations of              !
!         lateral diffusion in geophysical fluid dynamics              !
!         models, In Numerical Methods of Atmospheric and              !
!         Oceanic Modelling. Lin, Laprise, and Ritchie,                !
!         Eds., NRC Research Press, 547-556.                           !
!                                                                      !
!      Griffies, S.M. and R.W. Hallberg, 2000: Biharmonic              !
!         friction with a Smagorinsky-like viscosity for               !
!         use in large-scale eddy-permitting ocean models,             !
!         Monthly Weather Rev., 128, 8, 2935-2946.                     !
!                                                                      !
!***********************************************************************
!
      USE mod_param
      USE mod_coupling
#ifdef DIAGNOSTICS_UV
      USE mod_diags
#endif
      USE mod_grid
      USE mod_mixing
      USE mod_ocean
      USE mod_stepping
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile
!
!  Local variable declarations.
!
#include "tile.h"
!
#ifdef PROFILE
      CALL wclock_on (ng, iNLM, 33)
#endif
      CALL uv3dmix4_tile (ng, tile,                                     &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    IminS, ImaxS, JminS, JmaxS,                   &
     &                    nrhs(ng), nnew(ng),                           &
#ifdef MASKING
     &                    GRID(ng) % pmask,                             &
     &                    GRID(ng) % rmask,                             &
     &                    GRID(ng) % umask,                             &
     &                    GRID(ng) % vmask,                             &
#endif
     &                    GRID(ng) % om_p,                              &
     &                    GRID(ng) % om_r,                              &
     &                    GRID(ng) % om_u,                              &
     &                    GRID(ng) % om_v,                              &
     &                    GRID(ng) % on_p,                              &
     &                    GRID(ng) % on_r,                              &
     &                    GRID(ng) % on_u,                              &
     &                    GRID(ng) % on_v,                              &
     &                    GRID(ng) % pm,                                &
     &                    GRID(ng) % pn,                                &
     &                    GRID(ng) % Hz,                                &
     &                    GRID(ng) % z_r,                               &
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
     &                    MIXING(ng) % Uvis3d_r,                        &
     &                    MIXING(ng) % Vvis3d_r,                        &
# else
     &                    MIXING(ng) % visc3d_r,                        &
# endif
#else
     &                    MIXING(ng) % visc4_p,                         &
     &                    MIXING(ng) % visc4_r,                         &
#endif
#ifdef DIAGNOSTICS_UV
     &                    DIAGS(ng) % DiaRUfrc,                         &
     &                    DIAGS(ng) % DiaRVfrc,                         &
     &                    DIAGS(ng) % DiaU3wrk,                         &
     &                    DIAGS(ng) % DiaV3wrk,                         &
#endif
     &                    COUPLING(ng) % rufrc,                         &
     &                    COUPLING(ng) % rvfrc,                         &
     &                    OCEAN(ng) % u,                                &
     &                    OCEAN(ng) % v)
#ifdef PROFILE
      CALL wclock_off (ng, iNLM, 33)
#endif
      RETURN
      END SUBROUTINE uv3dmix4
!
!***********************************************************************
      SUBROUTINE uv3dmix4_tile (ng, tile,                               &
     &                          LBi, UBi, LBj, UBj,                     &
     &                          IminS, ImaxS, JminS, JmaxS,             &
     &                          nrhs, nnew,                             &
#ifdef MASKING
     &                          pmask, rmask, umask, vmask,             &
#endif
     &                          om_p, om_r, om_u, om_v,                 &
     &                          on_p, on_r, on_u, on_v,                 &
     &                          pm, pn,                                 &
     &                          Hz, z_r,                                &
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
     &                          Uvis3d_r, Vvis3d_r,                     &
# else
     &                          visc3d_r,                               &
# endif
#else
     &                          visc4_p, visc4_r,                       &
#endif
#ifdef DIAGNOSTICS_UV
     &                          DiaRUfrc, DiaRVfrc,                     &
     &                          DiaU3wrk, DiaV3wrk,                     &
#endif
     &                          rufrc, rvfrc,                           &
     &                          u, v)
!***********************************************************************
!
      USE mod_param
      USE mod_scalars
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
      integer, intent(in) :: nrhs, nnew

#ifdef ASSUMED_SHAPE
# ifdef MASKING
      real(r8), intent(in) :: pmask(LBi:,LBj:)
      real(r8), intent(in) :: rmask(LBi:,LBj:)
      real(r8), intent(in) :: umask(LBi:,LBj:)
      real(r8), intent(in) :: vmask(LBi:,LBj:)
# endif
      real(r8), intent(in) :: om_p(LBi:,LBj:)
      real(r8), intent(in) :: om_r(LBi:,LBj:)
      real(r8), intent(in) :: om_u(LBi:,LBj:)
      real(r8), intent(in) :: om_v(LBi:,LBj:)
      real(r8), intent(in) :: on_p(LBi:,LBj:)
      real(r8), intent(in) :: on_r(LBi:,LBj:)
      real(r8), intent(in) :: on_u(LBi:,LBj:)
      real(r8), intent(in) :: on_v(LBi:,LBj:)
      real(r8), intent(in) :: pm(LBi:,LBj:)
      real(r8), intent(in) :: pn(LBi:,LBj:)
      real(r8), intent(in) :: Hz(LBi:,LBj:,:)
      real(r8), intent(in) :: z_r(LBi:,LBj:,:)
# ifdef VISC_3DCOEF
#  ifdef UV_U3ADV_SPLIT
      real(r8), intent(in) :: Uvis3d_r(LBi:,LBj:,:)
      real(r8), intent(in) :: Vvis3d_r(LBi:,LBj:,:)
#  else
      real(r8), intent(in) :: visc3d_r(LBi:,LBj:,:)
#  endif
# else
      real(r8), intent(in) :: visc4_p(LBi:,LBj:)
      real(r8), intent(in) :: visc4_r(LBi:,LBj:)
# endif
# ifdef DIAGNOSTICS_UV
      real(r8), intent(inout) :: DiaRUfrc(LBi:,LBj:,:,:)
      real(r8), intent(inout) :: DiaRVfrc(LBi:,LBj:,:,:)
      real(r8), intent(inout) :: DiaU3wrk(LBi:,LBj:,:,:)
      real(r8), intent(inout) :: DiaV3wrk(LBi:,LBj:,:,:)
# endif
      real(r8), intent(inout) :: rufrc(LBi:,LBj:)
      real(r8), intent(inout) :: rvfrc(LBi:,LBj:)
      real(r8), intent(inout) :: u(LBi:,LBj:,:,:)
      real(r8), intent(inout) :: v(LBi:,LBj:,:,:)
#else
# ifdef MASKING
      real(r8), intent(in) :: pmask(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: rmask(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: umask(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: vmask(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(in) :: om_p(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: om_r(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: om_u(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: om_v(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: on_p(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: on_r(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: on_u(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: on_v(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: pm(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: pn(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: Hz(LBi:UBi,LBj:UBj,N(ng))
      real(r8), intent(in) :: z_r(LBi:UBi,LBj:UBj,N(ng))
# ifdef VISC_3DCOEF
#  ifdef UV_U3ADV_SPLIT
      real(r8), intent(in) :: Uvis3d_r(LBi:UBi,LBj:UBj,N(ng))
      real(r8), intent(in) :: Vvis3d_r(LBi:UBi,LBj:UBj,N(ng))
#  else
      real(r8), intent(in) :: visc3d_r(LBi:UBi,LBj:UBj,N(ng))
#  endif
# else
      real(r8), intent(in) :: visc4_p(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: visc4_r(LBi:UBi,LBj:UBj)
# endif
# ifdef DIAGNOSTICS_UV
      real(r8), intent(inout) :: DiaRUfrc(LBi:UBi,LBj:UBj,3,NDM2d-1)
      real(r8), intent(inout) :: DiaRVfrc(LBi:UBi,LBj:UBj,3,NDM2d-1)
      real(r8), intent(inout) :: DiaU3wrk(LBi:UBi,LBj:UBj,N(ng),NDM3d)
      real(r8), intent(inout) :: DiaV3wrk(LBi:UBi,LBj:UBj,N(ng),NDM3d)
# endif
      real(r8), intent(inout) :: rufrc(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: rvfrc(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: u(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(inout) :: v(LBi:UBi,LBj:UBj,N(ng),2)
#endif
!
!  Local variable declarations.
!
      integer :: i, j, k, k1, k2

      real(r8) :: cff, fac1, fac2, pm_p, pn_p
      real(r8) :: cff1, cff2, cff3, cff4
      real(r8) :: cff5, cff6, cff7, cff8
      real(r8) :: dmUdz, dnUdz, dmVdz, dnVdz
#ifdef VISC_3DCOEF
      real(r8) :: Uvis_p, Vvis_p, visc_p
#endif

      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,N(ng)) :: LapU
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,N(ng)) :: LapV

      real(r8), dimension(IminS:ImaxS,JminS:JmaxS) :: UFe
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS) :: VFe
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS) :: UFx
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS) :: VFx

      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: UFs
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: VFs
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dmUde
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dmVde
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dnUdx
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dnVdx
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dUdz
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dVdz
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dZde_p
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dZde_r
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dZdx_p
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,2) :: dZdx_r

#include "set_bounds.h"
!
!-----------------------------------------------------------------------
!  Compute horizontal biharmonic viscosity along geopotential
!  surfaces.  The biharmonic operator is computed by applying
!  the harmonic operator twice.
!-----------------------------------------------------------------------
!
!  Compute horizontal and vertical gradients.  Notice the recursive
!  blocking sequence. It is assumed here that the mixing coefficients
!  are the squared root of the biharmonic viscosity coefficient. For
!  momentum balance purposes, the thickness "Hz" appears only when
!  computing the second harmonic operator. The vertical placement of
!  the gradients is:
!
!    dZdx_r, dZde_r, dnUdx, dmVde(:,:,k1) k      rho-points
!    dZdx_r, dZde_r, dnUdx, dmVde(:,:,k2) k+1    rho-points
!    dZdx_p, dZde_p, dnVdx, dmUde(:,:,k1) k      psi-points
!    dZdx_p, dZde_p, dnVdx, dmUde(:,:,k2) k+1    psi-points
!                       UFs, dUdz(:,:,k1) k-1/2  WU-points
!                       UFs, dUdz(:,:,k2) k+1/2  WU-points
!                       VFs, dVdz(:,:,k1) k-1/2  WV-points
!                       VFs, dVdz(:,:,k2) k+1/2  WV-points
!
      k2=1
      K_LOOP1 : DO k=0,N(ng)
        k1=k2
        k2=3-k1
        IF (k.lt.N(ng)) THEN
!
!  Compute slopes (nondimensional) at RHO- and PSI-points.
!
          DO j=-1+JU_RANGE+1
            DO i=IV_RANGE+1
              cff=0.5_r8*(pm(i-1,j)+pm(i,j))
#ifdef MASKING
              cff=cff*umask(i,j)
#endif
              UFx(i,j)=cff*(z_r(i  ,j,k+1)-                             &
     &                      z_r(i-1,j,k+1))
            END DO
            DO i=IV_RANGE
              dZdx_r(i,j,k2)=0.5_r8*(UFx(i  ,j)+                        &
     &                               UFx(i+1,j))
            END DO
          END DO
          DO j=JU_RANGE+1
            DO i=-1+IV_RANGE+1
              cff=0.5_r8*(pn(i,j-1)+pn(i,j))
#ifdef MASKING
              cff=cff*vmask(i,j)
#endif
              VFe(i,j)=cff*(z_r(i,j  ,k+1)-                             &
     &                      z_r(i,j-1,k+1))
            END DO
            DO i=IV_RANGE+1
              dZde_p(i,j,k2)=0.5_r8*(VFe(i-1,j)+                        &
     &                               VFe(i  ,j))
              dZdx_p(i,j,k2)=0.5_r8*(UFx(i,j-1)+                        &
     &                               UFx(i,j  ))
            END DO
          END DO
          DO j=JU_RANGE
            DO i=-1+IV_RANGE+1
              dZde_r(i,j,k2)=0.5_r8*(VFe(i,j  )+                        &
     &                               VFe(i,j+1))
            END DO
          END DO
!
!  Compute momentum horizontal (1/m/s) and vertical (1/s) gradients.
!
          DO j=-1+JV_RANGE
            DO i=-1+IU_RANGE
              cff=0.5_r8*pm(i,j)
#ifdef MASKING
              cff=cff*rmask(i,j)
#endif
              dnUdx(i,j,k2)=cff*((pn(i  ,j)+pn(i+1,j))*                 &
     &                           u(i+1,j,k+1,nrhs)-                     &
     &                           (pn(i-1,j)+pn(i  ,j))*                 &
     &                           u(i  ,j,k+1,nrhs))
              cff=0.5_r8*pn(i,j)
#ifdef MASKING
              cff=cff*rmask(i,j)
#endif
              dmVde(i,j,k2)=cff*((pm(i,j  )+pm(i,j+1))*                 &
     &                           v(i,j+1,k+1,nrhs)-                     &
     &                           (pm(i,j-1)+pm(i,j  ))*                 &
     &                           v(i,j  ,k+1,nrhs))
            END DO
          END DO
          DO j=JU_RANGE+1
            DO i=IV_RANGE+1
              cff=0.125_r8*(pn(i-1,j  )+pn(i,j  )+                      &
     &                      pn(i-1,j-1)+pn(i,j-1))
#ifdef MASKING
              cff=cff*pmask(i,j)
#endif
              dmUde(i,j,k2)=cff*((pm(i-1,j  )+pm(i,j  ))*               &
     &                           u(i,j  ,k+1,nrhs)-                     &
     &                           (pm(i-1,j-1)+pm(i,j-1))*               &
     &                           u(i,j-1,k+1,nrhs))
              cff=0.125_r8*(pm(i-1,j  )+pm(i,j  )+                      &
     &                      pm(i-1,j-1)+pm(i,j-1))
#ifdef MASKING
              cff=cff*pmask(i,j)
#endif
              dnVdx(i,j,k2)=cff*((pn(i  ,j-1)+pn(i  ,j))*               &
     &                           v(i  ,j,k+1,nrhs)-                     &
     &                           (pn(i-1,j-1)+pn(i-1,j))*               &
     &                           v(i-1,j,k+1,nrhs))
            END DO
          END DO
        END IF
        IF ((k.eq.0).or.(k.eq.N(ng))) THEN
          DO j=JU_RANGE
            DO i=-1+IU_RANGE+1
              dUdz(i,j,k2)=0.0_r8
              UFs(i,j,k2)=0.0_r8
            END DO
          END DO
          DO j=-1+JV_RANGE+1
            DO i=IV_RANGE
              dVdz(i,j,k2)=0.0_r8
              VFs(i,j,k2)=0.0_r8
            END DO
          END DO
        ELSE
          DO j=JU_RANGE
            DO i=-1+IU_RANGE+1
              cff=1.0_r8/(0.5_r8*(z_r(i-1,j,k+1)-z_r(i-1,j,k)+          &
     &                            z_r(i  ,j,k+1)-z_r(i  ,j,k)))
              dUdz(i,j,k2)=cff*(u(i,j,k+1,nrhs)-                        &
     &                          u(i,j,k  ,nrhs))
            END DO
          END DO
          DO j=-1+JV_RANGE+1
            DO i=IV_RANGE
              cff=1.0_r8/(0.5_r8*(z_r(i,j-1,k+1)-z_r(i,j-1,k)+          &
     &                            z_r(i,j  ,k+1)-z_r(i,j  ,k)))
              dVdz(i,j,k2)=cff*(v(i,j,k+1,nrhs)-                        &
     &                          v(i,j,k  ,nrhs))
            END DO
          END DO
        END IF
!
!  Compute components of the rotated viscous flux (m^4 s-^3/2) along
!  geopotential surfaces in the XI- and ETA-directions.
!
        IF (k.gt.0) THEN
          DO j=-1+JV_RANGE
            DO i=-1+IU_RANGE
              cff1=MIN(dZdx_r(i,j,k1),0.0_r8)
              cff2=MAX(dZdx_r(i,j,k1),0.0_r8)
              cff3=MIN(dZde_r(i,j,k1),0.0_r8)
              cff4=MAX(dZde_r(i,j,k1),0.0_r8)
              cff=(on_r(i,j)*(dnUdx(i,j,k1)-                            &
     &                        0.5_r8*pn(i,j)*                           &
     &                        (cff1*(dUdz(i  ,j,k1)+                    &
     &                               dUdz(i+1,j,k2))+                   &
     &                         cff2*(dUdz(i  ,j,k2)+                    &
     &                               dUdz(i+1,j,k1))))-                 &
     &             om_r(i,j)*(dmVde(i,j,k1)-                            &
     &                        0.5_r8*pm(i,j)*                           &
     &                        (cff3*(dVdz(i,j  ,k1)+                    &
     &                               dVdz(i,j+1,k2))+                   &
     &                         cff4*(dVdz(i,j  ,k2)+                    &
     &                               dVdz(i,j+1,k1)))))
#ifdef MASKING
              cff=cff*rmask(i,j)
#endif
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
              UFx(i,j)=on_r(i,j)*on_r(i,j)*Uvis3d_r(i,j,k)*cff
              VFe(i,j)=om_r(i,j)*om_r(i,j)*Vvis3d_r(i,j,k)*cff
# else
              UFx(i,j)=on_r(i,j)*on_r(i,j)*visc3d_r(i,j,k)*cff
              VFe(i,j)=om_r(i,j)*om_r(i,j)*visc3d_r(i,j,k)*cff
# endif
#else
              UFx(i,j)=on_r(i,j)*on_r(i,j)*visc4_r(i,j)*cff
              VFe(i,j)=om_r(i,j)*om_r(i,j)*visc4_r(i,j)*cff
#endif
            END DO
          END DO
          DO j=JU_RANGE+1
            DO i=IV_RANGE+1
              pm_p=0.25_r8*(pm(i-1,j-1)+pm(i-1,j)+                      &
     &                      pm(i  ,j-1)+pm(i  ,j))
              pn_p=0.25_r8*(pn(i-1,j-1)+pn(i-1,j)+                      &
     &                      pn(i  ,j-1)+pn(i  ,j))
              cff1=MIN(dZdx_p(i,j,k1),0.0_r8)
              cff2=MAX(dZdx_p(i,j,k1),0.0_r8)
              cff3=MIN(dZde_p(i,j,k1),0.0_r8)
              cff4=MAX(dZde_p(i,j,k1),0.0_r8)
              cff=(on_p(i,j)*(dnVdx(i,j,k1)-                            &
     &                        0.5_r8*pn_p*                              &
     &                        (cff1*(dVdz(i-1,j,k1)+                    &
     &                               dVdz(i  ,j,k2))+                   &
     &                         cff2*(dVdz(i-1,j,k2)+                    &
     &                               dVdz(i  ,j,k1))))+                 &
     &             om_p(i,j)*(dmUde(i,j,k1)-                            &
     &                        0.5_r8*pm_p*                              &
     &                        (cff3*(dUdz(i,j-1,k1)+                    &
     &                               dUdz(i,j  ,k2))+                   &
     &                         cff4*(dUdz(i,j-1,k2)+                    &
     &                               dUdz(i,j  ,k1)))))
#ifdef MASKING
              cff=cff*pmask(i,j)
#endif 
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
              Uvis_p=0.25_r8*(Uvis3d_r(i-1,j-1,k)+Uvis3d_r(i-1,j,k)+    &
     &                        Uvis3d_r(i  ,j-1,k)+Uvis3d_r(i  ,j,k))
              Vvis_p=0.25_r8*(Vvis3d_r(i-1,j-1,k)+Vvis3d_r(i-1,j,k)+    &
     &                        Vvis3d_r(i  ,j-1,k)+Vvis3d_r(i  ,j,k))
              UFe(i,j)=om_p(i,j)*om_p(i,j)*Uvis_p*cff
              VFx(i,j)=on_p(i,j)*on_p(i,j)*Vvis_p*cff
# else
              visc_p=0.25_r8*(visc3d_r(i-1,j-1,k)+visc3d_r(i-1,j,k)+    &
     &                        visc3d_r(i  ,j-1,k)+visc3d_r(i  ,j,k))
              UFe(i,j)=om_p(i,j)*om_p(i,j)*visc_p*cff
              VFx(i,j)=on_p(i,j)*on_p(i,j)*visc_p*cff
# endif
#else
              UFe(i,j)=om_p(i,j)*om_p(i,j)*visc4_p(i,j)*cff
              VFx(i,j)=on_p(i,j)*on_p(i,j)*visc4_p(i,j)*cff
#endif
            END DO
          END DO
!
!  Compute vertical flux (m^2 s^-3/2) due to sloping terrain-following
!  surfaces.
!
          IF (k.lt.N(ng)) THEN
            DO j=JU_RANGE
              DO i=IU_RANGE
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
                cff=0.125_r8*(Uvis3d_r(i-1,j,k  )+Uvis3d_r(i,j,k  )+    &
     &                        Uvis3d_r(i-1,j,k+1)+Uvis3d_r(i,j,k+1))
# else
                cff=0.125_r8*(visc3d_r(i-1,j,k  )+visc3d_r(i,j,k  )+    &
     &                        visc3d_r(i-1,j,k+1)+visc3d_r(i,j,k+1))
# endif
#else
                cff=0.25_r8*(visc4_r(i-1,j)+visc4_r(i,j))
#endif
                fac1=cff*on_u(i,j)
                fac2=cff*om_u(i,j)
                cff=0.5_r8*(pn(i-1,j)+pn(i,j))
                dnUdz=cff*dUdz(i,j,k2)
                dnVdz=cff*0.25_r8*(dVdz(i-1,j+1,k2)+                    &
     &                             dVdz(i  ,j+1,k2)+                    &
     &                             dVdz(i-1,j  ,k2)+                    &
     &                             dVdz(i  ,j  ,k2))
                cff=0.5_r8*(pm(i-1,j)+pm(i,j))
                dmUdz=cff*dUdz(i,j,k2)
                dmVdz=cff*0.25_r8*(dVdz(i-1,j+1,k2)+                    &
     &                             dVdz(i  ,j+1,k2)+                    &
     &                             dVdz(i-1,j  ,k2)+                    &
     &                             dVdz(i  ,j  ,k2))
                cff1=MIN(dZdx_r(i-1,j,k1),0.0_r8)
                cff2=MIN(dZdx_r(i  ,j,k2),0.0_r8)
                cff3=MAX(dZdx_r(i-1,j,k2),0.0_r8)
                cff4=MAX(dZdx_r(i  ,j,k1),0.0_r8)
                UFs(i,j,k2)=fac1*                                       &
     &                      (cff1*(cff1*dnUdz-dnUdx(i-1,j,k1))+         &
     &                       cff2*(cff2*dnUdz-dnUdx(i  ,j,k2))+         &
     &                       cff3*(cff3*dnUdz-dnUdx(i-1,j,k2))+         &
     &                       cff4*(cff4*dnUdz-dnUdx(i  ,j,k1)))
                cff1=MIN(dZde_p(i,j  ,k1),0.0_r8)
                cff2=MIN(dZde_p(i,j+1,k2),0.0_r8)
                cff3=MAX(dZde_p(i,j  ,k2),0.0_r8)
                cff4=MAX(dZde_p(i,j+1,k1),0.0_r8)
                UFs(i,j,k2)=UFs(i,j,k2)+                                &
     &                      fac2*                                       &
     &                      (cff1*(cff1*dmUdz-dmUde(i,j  ,k1))+         &
     &                       cff2*(cff2*dmUdz-dmUde(i,j+1,k2))+         &
     &                       cff3*(cff3*dmUdz-dmUde(i,j  ,k2))+         &
     &                       cff4*(cff4*dmUdz-dmUde(i,j+1,k1)))
                cff1=MIN(dZde_p(i,j  ,k1),0.0_r8)
                cff2=MIN(dZde_p(i,j+1,k2),0.0_r8)
                cff3=MAX(dZde_p(i,j  ,k2),0.0_r8)
                cff4=MAX(dZde_p(i,j+1,k1),0.0_r8)
                cff5=MIN(dZdx_p(i,j  ,k1),0.0_r8)
                cff6=MIN(dZdx_p(i,j+1,k2),0.0_r8)
                cff7=MAX(dZdx_p(i,j  ,k2),0.0_r8)
                cff8=MAX(dZdx_p(i,j+1,k1),0.0_r8)
                UFs(i,j,k2)=UFs(i,j,k2)+                                &
     &                      fac1*                                       &
     &                      (cff1*(cff5*dnVdz-dnVdx(i,j  ,k1))+         &
     &                       cff2*(cff6*dnVdz-dnVdx(i,j+1,k2))+         &
     &                       cff3*(cff7*dnVdz-dnVdx(i,j  ,k2))+         &
     &                       cff4*(cff8*dnVdz-dnVdx(i,j+1,k1)))
                cff1=MIN(dZdx_r(i-1,j,k1),0.0_r8)
                cff2=MIN(dZdx_r(i  ,j,k2),0.0_r8)
                cff3=MAX(dZdx_r(i-1,j,k2),0.0_r8)
                cff4=MAX(dZdx_r(i  ,j,k1),0.0_r8)
                cff5=MIN(dZde_r(i-1,j,k1),0.0_r8)
                cff6=MIN(dZde_r(i  ,j,k2),0.0_r8)
                cff7=MAX(dZde_r(i-1,j,k2),0.0_r8)
                cff8=MAX(dZde_r(i  ,j,k1),0.0_r8)
                UFs(i,j,k2)=UFs(i,j,k2)-                                &
     &                      fac2*                                       &
     &                      (cff1*(cff5*dmVdz-dmVde(i-1,j,k1))+         &
     &                       cff2*(cff6*dmVdz-dmVde(i  ,j,k2))+         &
     &                       cff3*(cff7*dmVdz-dmVde(i-1,j,k2))+         &
     &                       cff4*(cff8*dmVdz-dmVde(i  ,j,k1)))
              END DO
            END DO
!
            DO j=JV_RANGE
              DO i=IV_RANGE
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
                cff=0.125_r8*(Vvis3d_r(i,j-1,k  )+Vvis3d_r(i,j,k  )+    &
     &                        Vvis3d_r(i,j-1,k+1)+Vvis3d_r(i,j,k+1))
# else
                cff=0.125_r8*(visc3d_r(i,j-1,k  )+visc3d_r(i,j,k  )+    &
     &                        visc3d_r(i,j-1,k+1)+visc3d_r(i,j,k+1))
# endif
#else
                cff=0.25_r8*(visc4_r(i,j-1)+visc4_r(i,j))
#endif
                fac1=cff*on_v(i,j)
                fac2=cff*om_v(i,j)
                cff=0.5_r8*(pn(i,j-1)+pn(i,j))
                dnUdz=cff*0.25_r8*(dUdz(i  ,j  ,k2)+                    &
     &                             dUdz(i+1,j  ,k2)+                    &
     &                             dUdz(i  ,j-1,k2)+                    &
     &                             dUdz(i+1,j-1,k2))
                dnVdz=cff*dVdz(i,j,k2)
                cff=0.5_r8*(pm(i,j-1)+pm(i,j))
                dmUdz=cff*0.25_r8*(dUdz(i  ,j  ,k2)+                    &
     &                             dUdz(i+1,j  ,k2)+                    &
     &                             dUdz(i  ,j-1,k2)+                    &
     &                             dUdz(i+1,j-1,k2))
                dmVdz=cff*dVdz(i,j,k2)
                cff1=MIN(dZdx_p(i  ,j,k1),0.0_r8)
                cff2=MIN(dZdx_p(i+1,j,k2),0.0_r8)
                cff3=MAX(dZdx_p(i  ,j,k2),0.0_r8)
                cff4=MAX(dZdx_p(i+1,j,k1),0.0_r8)
                VFs(i,j,k2)=fac1*                                       &
     &                      (cff1*(cff1*dnVdz-dnVdx(i  ,j,k1))+         &
     &                       cff2*(cff2*dnVdz-dnVdx(i+1,j,k2))+         &
     &                       cff3*(cff3*dnVdz-dnVdx(i  ,j,k2))+         &
     &                       cff4*(cff4*dnVdz-dnVdx(i+1,j,k1)))
                cff1=MIN(dZde_r(i,j-1,k1),0.0_r8)
                cff2=MIN(dZde_r(i,j  ,k2),0.0_r8)
                cff3=MAX(dZde_r(i,j-1,k2),0.0_r8)
                cff4=MAX(dZde_r(i,j  ,k1),0.0_r8)
                VFs(i,j,k2)=VFs(i,j,k2)+                                &
     &                      fac2*                                       &
     &                      (cff1*(cff1*dmVdz-dmVde(i,j-1,k1))+         &
     &                       cff2*(cff2*dmVdz-dmVde(i,j  ,k2))+         &
     &                       cff3*(cff3*dmVdz-dmVde(i,j-1,k2))+         &
     &                       cff4*(cff4*dmVdz-dmVde(i,j  ,k1)))
                cff1=MIN(dZde_r(i,j-1,k1),0.0_r8)
                cff2=MIN(dZde_r(i,j  ,k2),0.0_r8)
                cff3=MAX(dZde_r(i,j-1,k2),0.0_r8)
                cff4=MAX(dZde_r(i,j  ,k1),0.0_r8)
                cff5=MIN(dZdx_r(i,j-1,k1),0.0_r8)
                cff6=MIN(dZdx_r(i,j  ,k2),0.0_r8)
                cff7=MAX(dZdx_r(i,j-1,k2),0.0_r8)
                cff8=MAX(dZdx_r(i,j  ,k1),0.0_r8)
                VFs(i,j,k2)=VFs(i,j,k2)-                                &
     &                      fac1*                                       &
     &                      (cff1*(cff5*dnUdz-dnUdx(i,j-1,k1))+         &
     &                       cff2*(cff6*dnUdz-dnUdx(i,j  ,k2))+         &
     &                       cff3*(cff7*dnUdz-dnUdx(i,j-1,k2))+         &
     &                       cff4*(cff8*dnUdz-dnUdx(i,j  ,k1)))
                cff1=MIN(dZdx_p(i  ,j,k1),0.0_r8)
                cff2=MIN(dZdx_p(i+1,j,k2),0.0_r8)
                cff3=MAX(dZdx_p(i  ,j,k2),0.0_r8)
                cff4=MAX(dZdx_p(i+1,j,k1),0.0_r8)
                cff5=MIN(dZde_p(i  ,j,k1),0.0_r8)
                cff6=MIN(dZde_p(i+1,j,k2),0.0_r8)
                cff7=MAX(dZde_p(i  ,j,k2),0.0_r8)
                cff8=MAX(dZde_p(i+1,j,k1),0.0_r8)
                VFs(i,j,k2)=VFs(i,j,k2)+                                &
     &                      fac2*                                       &
     &                      (cff1*(cff5*dmUdz-dmUde(i  ,j,k1))+         &
     &                       cff2*(cff6*dmUdz-dmUde(i+1,j,k2))+         &
     &                       cff3*(cff7*dmUdz-dmUde(i  ,j,k2))+         &
     &                       cff4*(cff8*dmUdz-dmUde(i+1,j,k1)))
              END DO
            END DO
          END IF
!
!  Compute first harmonic operator (m s^-3/2).
!
          DO j=JU_RANGE
            DO i=IU_RANGE
              cff=0.125_r8*(pm(i-1,j)+pm(i,j))*                         &
     &                     (pn(i-1,j)+pn(i,j))
              cff1=1.0_r8/(0.5_r8*(Hz(i-1,j,k)+Hz(i,j,k)))
              LapU(i,j,k)=cff*((pn(i-1,j)+pn(i,j))*                     &
                               (UFx(i,j)-UFx(i-1,j))+                   &
     &                         (pm(i-1,j)+pm(i,j))*                     &
     &                         (UFe(i,j+1)-UFe(i,j)))+                  &
     &                    cff1*(UFs(i,j,k2)-UFs(i,j,k1))
#ifdef MASKING
              LapU(i,j,k)=LapU(i,j,k)*umask(i,j)
#endif
            END DO
          END DO
          DO j=JV_RANGE
            DO i=IV_RANGE
              cff=0.125_r8*(pm(i,j)+pm(i,j-1))*                         &
     &                     (pn(i,j)+pn(i,j-1))
              cff1=1.0_r8/(0.5_r8*(Hz(i,j-1,k)+Hz(i,j,k)))
              LapV(i,j,k)=cff*((pn(i,j-1)+pn(i,j))*                     &
     &                         (VFx(i+1,j)-VFx(i,j))-                   &
     &                         (pm(i,j-1)+pm(i,j))*                     &
     &                         (VFe(i,j)-VFe(i,j-1)))+                  &
     &                    cff1*(VFs(i,j,k2)-VFs(i,j,k1))
#ifdef MASKING
              LapV(i,j,k)=LapV(i,j,k)*vmask(i,j)
#endif
            END DO
          END DO
        END IF
      END DO K_LOOP1
!
!  Apply boundary conditions (except periodic; closed or gradient)
!  to the first harmonic operator.
!
#ifndef EW_PERIODIC
      IF (WESTERN_EDGE) THEN
        DO k=1,N(ng)
          DO j=JU_RANGE
# ifdef WESTERN_WALL
            LapU(IstrU-1,j,k)=0.0_r8
# else
            LapU(IstrU-1,j,k)=LapU(IstrU,j,k)
# endif
          END DO
          DO j=JV_RANGE
# ifdef WESTERN_WALL
            LapV(Istr-1,j,k)=gamma2(ng)*LapV(Istr,j,k)
# else
            LapV(Istr-1,j,k)=0.0_r8
# endif
          END DO
        END DO
      END IF
      IF (EASTERN_EDGE) THEN
        DO k=1,N(ng)
          DO j=JU_RANGE
# ifdef EASTERN_WALL
            LapU(Iend+1,j,k)=0.0_r8
# else
            LapU(Iend+1,j,k)=LapU(Iend,j,k)
# endif
          END DO
          DO j=JV_RANGE
# ifdef EASTERN_WALL
            LapV(Iend+1,j,k)=gamma2(ng)*LapV(Iend,j,k)
# else
            LapV(Iend+1,j,k)=0.0_r8
# endif
          END DO
        END DO
      END IF
#endif
#ifndef NS_PERIODIC
      IF (SOUTHERN_EDGE) THEN
        DO k=1,N(ng)
          DO i=IU_RANGE
# ifdef SOUTHERN_WALL
            LapU(i,Jstr-1,k)=gamma2(ng)*LapU(i,Jstr,k)
# else
            LapU(i,Jstr-1,k)=0.0_r8
# endif
          END DO
          DO i=IV_RANGE
# ifdef SOUTHERN_WALL
            LapV(i,JstrV-1,k)=0.0_r8
# else
            LapV(i,JstrV-1,k)=LapV(i,JstrV,k)
# endif
          END DO
        END DO
      END IF
      IF (NORTHERN_EDGE) THEN
        DO k=1,N(ng)
          DO i=IU_RANGE
# ifdef NORTHERN_WALL
            LapU(i,Jend+1,k)=gamma2(ng)*LapU(i,Jend,k)
# else
            LapU(i,Jend+1,k)=0.0_r8
# endif
          END DO
          DO i=IV_RANGE
# ifdef NORTHERN_WALL
            LapV(i,Jend+1,k)=0.0_r8
# else
            LapV(i,Jend+1,k)=LapV(i,Jend,k)
# endif
          END DO
        END DO
      END IF
#endif
#if !defined EW_PERIODIC && !defined NS_PERIODIC
      IF ((SOUTHERN_EDGE).and.(WESTERN_EDGE)) THEN
        DO k=1,N(ng)
          LapU(Istr  ,Jstr-1,k)=0.5_r8*(LapU(Istr+1,Jstr-1,k)+          &
     &                                  LapU(Istr  ,Jstr  ,k))
          LapV(Istr-1,Jstr  ,k)=0.5_r8*(LapV(Istr-1,Jstr+1,k)+          &
     &                                  LapV(Istr  ,Jstr  ,k))
        END DO
      END IF
      IF ((SOUTHERN_EDGE).and.(EASTERN_EDGE)) THEN
        DO k=1,N(ng)
          LapU(Iend+1,Jstr-1,k)=0.5_r8*(LapU(Iend  ,Jstr-1,k)+          &
     &                                  LapU(Iend+1,Jstr  ,k))
          LapV(Iend+1,Jstr  ,k)=0.5_r8*(LapV(Iend  ,Jstr  ,k)+          &
     &                                  LapV(Iend+1,Jstr+1,k))
        END DO
      END IF
      IF ((NORTHERN_EDGE).and.(WESTERN_EDGE)) THEN
        DO k=1,N(ng)
          LapU(Istr  ,Jend+1,k)=0.5_r8*(LapU(Istr+1,Jend+1,k)+          &
     &                                  LapU(Istr  ,Jend  ,k))
          LapV(Istr-1,Jend+1,k)=0.5_r8*(LapV(Istr  ,Jend+1,k)+          &
     &                                  LapV(Istr-1,Jend  ,k))
        END DO
      END IF
      IF ((NORTHERN_EDGE).and.(EASTERN_EDGE)) THEN
        DO k=1,N(ng)
          LapU(Iend+1,Jend+1,k)=0.5_r8*(LapU(Iend  ,Jend+1,k)+          &
     &                                  LapU(Iend+1,Jend  ,k))
          LapV(Iend+1,Jend+1,k)=0.5_r8*(LapV(Iend  ,Jend+1,k)+          &
     &                                  LapV(Iend+1,Jend  ,k))
        END DO
      END IF
#endif
!
!  Compute horizontal and vertical gradients associated with the
!  second rotated harmonic operator.
!
      k2=1
      K_LOOP2 : DO k=0,N(ng)
        k1=k2
        k2=3-k1
        IF (k.lt.N(ng)) THEN
!
!  Compute slopes (nondimensional) at RHO- and PSI-points.
!
          DO j=-1+JU_RANGE+1
            DO i=IV_RANGE+1
              cff=0.5_r8*(pm(i-1,j)+pm(i,j))
# ifdef MASKING
              cff=cff*umask(i,j)
# endif
              UFx(i,j)=cff*(z_r(i  ,j,k+1)-                             &
     &                      z_r(i-1,j,k+1))
            END DO
            DO i=IV_RANGE
              dZdx_r(i,j,k2)=0.5_r8*(UFx(i  ,j)+                        &
     &                               UFx(i+1,j))
            END DO
          END DO
          DO j=JU_RANGE+1
            DO i=-1+IV_RANGE+1
              cff=0.5_r8*(pn(i,j-1)+pn(i,j))
# ifdef MASKING
              cff=cff*vmask(i,j)
# endif
              VFe(i,j)=cff*(z_r(i,j  ,k+1)-                             &
     &                      z_r(i,j-1,k+1))
            END DO
            DO i=IV_RANGE+1
              dZde_p(i,j,k2)=0.5_r8*(VFe(i-1,j)+                        &
     &                               VFe(i  ,j))
              dZdx_p(i,j,k2)=0.5_r8*(UFx(i,j-1)+                        &
     &                               UFx(i,j  ))
            END DO
          END DO
          DO j=JU_RANGE
            DO i=-1+IV_RANGE+1
              dZde_r(i,j,k2)=0.5_r8*(VFe(i,j  )+                        &
     &                               VFe(i,j+1))
            END DO
          END DO
!
!  Compute momentum horizontal (m^-1 s^-3/2) and vertical (s^-3/2)
!  gradients.
!
          DO j=JstrV-1,Jend
            DO i=IstrU-1,Iend
              cff=0.5_r8*pm(i,j)
# ifdef MASKING
              cff=cff*rmask(i,j)
# endif
              dnUdx(i,j,k2)=cff*((pn(i  ,j)+pn(i+1,j))*                 &
     &                           LapU(i+1,j,k+1)-                       &
     &                           (pn(i-1,j)+pn(i  ,j))*                 &
     &                           LapU(i  ,j,k+1))
              cff=0.5_r8*pn(i,j)
#ifdef MASKING
              cff=cff*rmask(i,j)
#endif
              dmVde(i,j,k2)=cff*((pm(i,j  )+pm(i,j+1))*                 &
     &                           LapV(i,j+1,k+1)-                       &
     &                           (pm(i,j-1)+pm(i,j  ))*                 &
     &                           LapV(i,j  ,k+1))
            END DO
          END DO
          DO j=Jstr,Jend+1
            DO i=Istr,Iend+1
              cff=0.125_r8*(pn(i-1,j  )+pn(i,j  )+                      &
     &                      pn(i-1,j-1)+pn(i,j-1))
#ifdef MASKING
              cff=cff*pmask(i,j)
#endif
              dmUde(i,j,k2)=cff*((pm(i-1,j  )+pm(i,j  ))*               &
     &                           LapU(i,j  ,k+1)-                       &
     &                           (pm(i-1,j-1)+pm(i,j-1))*               &
     &                           LapU(i,j-1,k+1))
              cff=0.125_r8*(pm(i-1,j  )+pm(i,j  )+                      &
     &                      pm(i-1,j-1)+pm(i,j-1))
#ifdef MASKING
              cff=cff*pmask(i,j)
#endif
              dnVdx(i,j,k2)=cff*((pn(i  ,j-1)+pn(i  ,j))*               &
     &                           LapV(i  ,j,k+1)-                       &
     &                           (pn(i-1,j-1)+pn(i-1,j))*               &
     &                           LapV(i-1,j,k+1))
            END DO
          END DO
        END IF
        IF ((k.eq.0).or.(k.eq.N(ng))) THEN
          DO j=Jstr-1,Jend+1
            DO i=IstrU-1,Iend+1
              dUdz(i,j,k2)=0.0_r8
              UFs(i,j,k2)=0.0_r8
            END DO
          END DO
          DO j=JstrV-1,Jend+1
            DO i=Istr-1,Iend+1
              dVdz(i,j,k2)=0.0_r8
              VFs(i,j,k2)=0.0_r8
            END DO
          END DO
        ELSE
          DO j=Jstr-1,Jend+1
            DO i=IstrU-1,Iend+1
              cff=1.0_r8/(0.5_r8*(z_r(i-1,j,k+1)-z_r(i-1,j,k)+          &
     &                            z_r(i  ,j,k+1)-z_r(i  ,j,k)))
              dUdz(i,j,k2)=cff*(LapU(i,j,k+1)-                          &
     &                          LapU(i,j,k  ))
            END DO
          END DO
          DO j=JstrV-1,Jend+1
            DO i=Istr-1,Iend+1
              cff=1.0_r8/(0.5_r8*(z_r(i,j-1,k+1)-z_r(i,j-1,k)+          &
     &                            z_r(i,j  ,k+1)-z_r(i,j  ,k)))
              dVdz(i,j,k2)=cff*(LapV(i,j,k+1)-                          &
     &                          LapV(i,j,k  ))
            END DO
          END DO
        END IF
!
!  Compute components of the rotated viscous flux (m5/s2) along
!  geopotential surfaces in the XI- and ETA-directions.
!
        IF (k.gt.0) THEN
          DO j=JstrV-1,Jend
            DO i=IstrU-1,Iend
              cff1=MIN(dZdx_r(i,j,k1),0.0_r8)
              cff2=MAX(dZdx_r(i,j,k1),0.0_r8)
              cff3=MIN(dZde_r(i,j,k1),0.0_r8)
              cff4=MAX(dZde_r(i,j,k1),0.0_r8)
              cff=Hz(i,j,k)*                                            &
     &            (on_r(i,j)*(dnUdx(i,j,k1)-                            &
     &                        0.5_r8*pn(i,j)*                           &
     &                        (cff1*(dUdz(i  ,j,k1)+                    &
     &                               dUdz(i+1,j,k2))+                   &
     &                         cff2*(dUdz(i  ,j,k2)+                    &
     &                               dUdz(i+1,j,k1))))-                 &
     &             om_r(i,j)*(dmVde(i,j,k1)-                            &
     &                        0.5_r8*pm(i,j)*                           &
     &                        (cff3*(dVdz(i,j  ,k1)+                    &
     &                               dVdz(i,j+1,k2))+                   &
     &                         cff4*(dVdz(i,j  ,k2)+                    &
     &                               dVdz(i,j+1,k1)))))
#ifdef MASKING
              cff=cff*rmask(i,j)
#endif
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
              UFx(i,j)=on_r(i,j)*on_r(i,j)*Uvis3d_r(i,j,k)*cff
              VFe(i,j)=om_r(i,j)*om_r(i,j)*Vvis3d_r(i,j,k)*cff
# else
              UFx(i,j)=on_r(i,j)*on_r(i,j)*visc3d_r(i,j,k)*cff
              VFe(i,j)=om_r(i,j)*om_r(i,j)*visc3d_r(i,j,k)*cff
# endif
#else
              UFx(i,j)=on_r(i,j)*on_r(i,j)*visc4_r(i,j)*cff
              VFe(i,j)=om_r(i,j)*om_r(i,j)*visc4_r(i,j)*cff
#endif
            END DO
          END DO
          DO j=Jstr,Jend+1
            DO i=Istr,Iend+1
              pm_p=0.25_r8*(pm(i-1,j-1)+pm(i-1,j)+                      &
     &                      pm(i  ,j-1)+pm(i  ,j))
              pn_p=0.25_r8*(pn(i-1,j-1)+pn(i-1,j)+                      &
     &                      pn(i  ,j-1)+pn(i  ,j))
              cff1=MIN(dZdx_p(i,j,k1),0.0_r8)
              cff2=MAX(dZdx_p(i,j,k1),0.0_r8)
              cff3=MIN(dZde_p(i,j,k1),0.0_r8)
              cff4=MAX(dZde_p(i,j,k1),0.0_r8)
              cff=0.25_r8*                                              &
     &            (Hz(i-1,j  ,k)+Hz(i,j  ,k)+                           &
     &             Hz(i-1,j-1,k)+Hz(i,j-1,k))*                          &
     &             (on_p(i,j)*(dnVdx(i,j,k1)-                           &
     &                         0.5_r8*pn_p*                             &
     &                         (cff1*(dVdz(i-1,j,k1)+                   &
     &                                dVdz(i  ,j,k2))+                  &
     &                          cff2*(dVdz(i-1,j,k2)+                   &
     &                                dVdz(i  ,j,k1))))+                &
     &              om_p(i,j)*(dmUde(i,j,k1)-                           &
     &                         0.5_r8*pm_p*                             &
     &                         (cff3*(dUdz(i,j-1,k1)+                   &
     &                                dUdz(i,j  ,k2))+                  &
     &                          cff4*(dUdz(i,j-1,k2)+                   &
     &                                dUdz(i,j  ,k1)))))
#ifdef MASKING
              cff=cff*pmask(i,j)
#endif
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
              Uvis_p=0.25_r8*(Uvis3d_r(i-1,j-1,k)+Uvis3d_r(i-1,j,k)+    &
     &                        Uvis3d_r(i  ,j-1,k)+Uvis3d_r(i  ,j,k))
              Vvis_p=0.25_r8*(Vvis3d_r(i-1,j-1,k)+Vvis3d_r(i-1,j,k)+    &
     &                        Vvis3d_r(i  ,j-1,k)+Vvis3d_r(i  ,j,k))
              UFe(i,j)=om_p(i,j)*om_p(i,j)*Uvis_p*cff
              VFx(i,j)=on_p(i,j)*on_p(i,j)*Vvis_p*cff
# else
              visc_p=0.25_r8*(visc3d_r(i-1,j-1,k)+visc3d_r(i-1,j,k)+    &
     &                        visc3d_r(i  ,j-1,k)+visc3d_r(i  ,j,k))
              UFe(i,j)=om_p(i,j)*om_p(i,j)*visc_p*cff
              VFx(i,j)=on_p(i,j)*on_p(i,j)*visc_p*cff
# endif
#else
              UFe(i,j)=om_p(i,j)*om_p(i,j)*visc4_p(i,j)*cff
              VFx(i,j)=on_p(i,j)*on_p(i,j)*visc4_p(i,j)*cff
#endif
            END DO
          END DO
!
!  Compute vertical flux (m2/s2) due to sloping terrain-following
!  surfaces.
!
          IF (k.lt.N(ng)) THEN
            DO j=Jstr,Jend
              DO i=IstrU,Iend
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
                cff=0.125_r8*(Uvis3d_r(i-1,j,k  )+Uvis3d_r(i,j,k  )+    &
     &                        Uvis3d_r(i-1,j,k+1)+Uvis3d_r(i,j,k+1))
# else
                cff=0.125_r8*(visc3d_r(i-1,j,k  )+visc3d_r(i,j,k  )+    &
     &                        visc3d_r(i-1,j,k+1)+visc3d_r(i,j,k+1))
# endif
#else
                cff=0.25_r8*(visc4_r(i-1,j)+visc4_r(i,j))
#endif
                fac1=cff*on_u(i,j)
                fac2=cff*om_u(i,j)
                cff=0.5_r8*(pn(i-1,j)+pn(i,j))
                dnUdz=cff*dUdz(i,j,k2)
                dnVdz=cff*0.25_r8*(dVdz(i-1,j+1,k2)+                    &
     &                             dVdz(i  ,j+1,k2)+                    &
     &                             dVdz(i-1,j  ,k2)+                    &
     &                             dVdz(i  ,j  ,k2))
                cff=0.5_r8*(pm(i-1,j)+pm(i,j))
                dmUdz=cff*dUdz(i,j,k2)
                dmVdz=cff*0.25_r8*(dVdz(i-1,j+1,k2)+                    &
     &                             dVdz(i  ,j+1,k2)+                    &
     &                             dVdz(i-1,j  ,k2)+                    &
     &                             dVdz(i  ,j  ,k2))
                cff1=MIN(dZdx_r(i-1,j,k1),0.0_r8)
                cff2=MIN(dZdx_r(i  ,j,k2),0.0_r8)
                cff3=MAX(dZdx_r(i-1,j,k2),0.0_r8)
                cff4=MAX(dZdx_r(i  ,j,k1),0.0_r8)
                UFs(i,j,k2)=fac1*                                       &
     &                      (cff1*(cff1*dnUdz-dnUdx(i-1,j,k1))+         &
     &                       cff2*(cff2*dnUdz-dnUdx(i  ,j,k2))+         &
     &                       cff3*(cff3*dnUdz-dnUdx(i-1,j,k2))+         &
     &                       cff4*(cff4*dnUdz-dnUdx(i  ,j,k1)))
                cff1=MIN(dZde_p(i,j  ,k1),0.0_r8)
                cff2=MIN(dZde_p(i,j+1,k2),0.0_r8)
                cff3=MAX(dZde_p(i,j  ,k2),0.0_r8)
                cff4=MAX(dZde_p(i,j+1,k1),0.0_r8)
                UFs(i,j,k2)=UFs(i,j,k2)+                                &
     &                      fac2*                                       &
     &                      (cff1*(cff1*dmUdz-dmUde(i,j  ,k1))+         &
     &                       cff2*(cff2*dmUdz-dmUde(i,j+1,k2))+         &
     &                       cff3*(cff3*dmUdz-dmUde(i,j  ,k2))+         &
     &                       cff4*(cff4*dmUdz-dmUde(i,j+1,k1)))
                cff1=MIN(dZde_p(i,j  ,k1),0.0_r8)
                cff2=MIN(dZde_p(i,j+1,k2),0.0_r8)
                cff3=MAX(dZde_p(i,j  ,k2),0.0_r8)
                cff4=MAX(dZde_p(i,j+1,k1),0.0_r8)
                cff5=MIN(dZdx_p(i,j  ,k1),0.0_r8)
                cff6=MIN(dZdx_p(i,j+1,k2),0.0_r8)
                cff7=MAX(dZdx_p(i,j  ,k2),0.0_r8)
                cff8=MAX(dZdx_p(i,j+1,k1),0.0_r8)
                UFs(i,j,k2)=UFs(i,j,k2)+                                &
     &                      fac1*                                       &
     &                      (cff1*(cff5*dnVdz-dnVdx(i,j  ,k1))+         &
     &                       cff2*(cff6*dnVdz-dnVdx(i,j+1,k2))+         &
     &                       cff3*(cff7*dnVdz-dnVdx(i,j  ,k2))+         &
     &                       cff4*(cff8*dnVdz-dnVdx(i,j+1,k1)))
                cff1=MIN(dZdx_r(i-1,j,k1),0.0_r8)
                cff2=MIN(dZdx_r(i  ,j,k2),0.0_r8)
                cff3=MAX(dZdx_r(i-1,j,k2),0.0_r8)
                cff4=MAX(dZdx_r(i  ,j,k1),0.0_r8)
                cff5=MIN(dZde_r(i-1,j,k1),0.0_r8)
                cff6=MIN(dZde_r(i  ,j,k2),0.0_r8)
                cff7=MAX(dZde_r(i-1,j,k2),0.0_r8)
                cff8=MAX(dZde_r(i  ,j,k1),0.0_r8)
                UFs(i,j,k2)=UFs(i,j,k2)-                                &
     &                      fac2*                                       &
     &                      (cff1*(cff5*dmVdz-dmVde(i-1,j,k1))+         &
     &                       cff2*(cff6*dmVdz-dmVde(i  ,j,k2))+         &
     &                       cff3*(cff7*dmVdz-dmVde(i-1,j,k2))+         &
     &                       cff4*(cff8*dmVdz-dmVde(i  ,j,k1)))
              END DO
            END DO
!
            DO j=JstrV,Jend
              DO i=Istr,Iend
#ifdef VISC_3DCOEF
# ifdef UV_U3ADV_SPLIT
                cff=0.125_r8*(Vvis3d_r(i,j-1,k  )+Vvis3d_r(i,j,k  )+    &
     &                        Vvis3d_r(i,j-1,k+1)+Vvis3d_r(i,j,k+1))
# else
                cff=0.125_r8*(visc3d_r(i,j-1,k  )+visc3d_r(i,j,k  )+    &
     &                        visc3d_r(i,j-1,k+1)+visc3d_r(i,j,k+1))
# endif
#else
                cff=0.25_r8*(visc4_r(i,j-1)+visc4_r(i,j))
#endif
                fac1=cff*on_v(i,j)
                fac2=cff*om_v(i,j)
                cff=0.5_r8*(pn(i,j-1)+pn(i,j))
                dnUdz=cff*0.25_r8*(dUdz(i  ,j  ,k2)+                    &
     &                             dUdz(i+1,j  ,k2)+                    &
     &                             dUdz(i  ,j-1,k2)+                    &
     &                             dUdz(i+1,j-1,k2))
                dnVdz=cff*dVdz(i,j,k2)
                cff=0.5_r8*(pm(i,j-1)+pm(i,j))
                dmUdz=cff*0.25_r8*(dUdz(i  ,j  ,k2)+                    &
     &                             dUdz(i+1,j  ,k2)+                    &
     &                             dUdz(i  ,j-1,k2)+                    &
     &                             dUdz(i+1,j-1,k2))
                dmVdz=cff*dVdz(i,j,k2)
                cff1=MIN(dZdx_p(i  ,j,k1),0.0_r8)
                cff2=MIN(dZdx_p(i+1,j,k2),0.0_r8)
                cff3=MAX(dZdx_p(i  ,j,k2),0.0_r8)
                cff4=MAX(dZdx_p(i+1,j,k1),0.0_r8)
                VFs(i,j,k2)=fac1*                                       &
     &                      (cff1*(cff1*dnVdz-dnVdx(i  ,j,k1))+         &
     &                       cff2*(cff2*dnVdz-dnVdx(i+1,j,k2))+         &
     &                       cff3*(cff3*dnVdz-dnVdx(i  ,j,k2))+         &
     &                       cff4*(cff4*dnVdz-dnVdx(i+1,j,k1)))
                cff1=MIN(dZde_r(i,j-1,k1),0.0_r8)
                cff2=MIN(dZde_r(i,j  ,k2),0.0_r8)
                cff3=MAX(dZde_r(i,j-1,k2),0.0_r8)
                cff4=MAX(dZde_r(i,j  ,k1),0.0_r8)
                VFs(i,j,k2)=VFs(i,j,k2)+                                &
     &                      fac2*                                       &
     &                      (cff1*(cff1*dmVdz-dmVde(i,j-1,k1))+         &
     &                       cff2*(cff2*dmVdz-dmVde(i,j  ,k2))+         &
     &                       cff3*(cff3*dmVdz-dmVde(i,j-1,k2))+         &
     &                       cff4*(cff4*dmVdz-dmVde(i,j  ,k1)))
                cff1=MIN(dZde_r(i,j-1,k1),0.0_r8)
                cff2=MIN(dZde_r(i,j  ,k2),0.0_r8)
                cff3=MAX(dZde_r(i,j-1,k2),0.0_r8)
                cff4=MAX(dZde_r(i,j  ,k1),0.0_r8)
                cff5=MIN(dZdx_r(i,j-1,k1),0.0_r8)
                cff6=MIN(dZdx_r(i,j  ,k2),0.0_r8)
                cff7=MAX(dZdx_r(i,j-1,k2),0.0_r8)
                cff8=MAX(dZdx_r(i,j  ,k1),0.0_r8)
                VFs(i,j,k2)=VFs(i,j,k2)-                                &
     &                      fac1*                                       &
     &                      (cff1*(cff5*dnUdz-dnUdx(i,j-1,k1))+         &
     &                       cff2*(cff6*dnUdz-dnUdx(i,j  ,k2))+         &
     &                       cff3*(cff7*dnUdz-dnUdx(i,j-1,k2))+         &
     &                       cff4*(cff8*dnUdz-dnUdx(i,j  ,k1)))
                cff1=MIN(dZdx_p(i  ,j,k1),0.0_r8)
                cff2=MIN(dZdx_p(i+1,j,k2),0.0_r8)
                cff3=MAX(dZdx_p(i  ,j,k2),0.0_r8)
                cff4=MAX(dZdx_p(i+1,j,k1),0.0_r8)
                cff5=MIN(dZde_p(i  ,j,k1),0.0_r8)
                cff6=MIN(dZde_p(i+1,j,k2),0.0_r8)
                cff7=MAX(dZde_p(i  ,j,k2),0.0_r8)
                cff8=MAX(dZde_p(i+1,j,k1),0.0_r8)
                VFs(i,j,k2)=VFs(i,j,k2)+                                &
     &                      fac2*                                       &
     &                      (cff1*(cff5*dmUdz-dmUde(i  ,j,k1))+         &
     &                       cff2*(cff6*dmUdz-dmUde(i+1,j,k2))+         &
     &                       cff3*(cff7*dmUdz-dmUde(i  ,j,k2))+         &
     &                       cff4*(cff8*dmUdz-dmUde(i+1,j,k1)))
              END DO
            END DO
          END IF
!
!  Time-step biharmonic, geopotential viscosity term. Notice that
!  momentum at this stage is HzU and HzV and has m2/s units.  Add
!  contribution for barotropic forcing terms.
!
          DO j=Jstr,Jend
            DO i=IstrU,Iend
              cff=0.25_r8*(pm(i-1,j)+pm(i,j))*(pn(i-1,j)+pn(i,j))
              cff1=0.5_r8*((pn(i-1,j)+pn(i,j))*                         &
     &                     (UFx(i,j  )-UFx(i-1,j))+                     &
     &                     (pm(i-1,j)+pm(i,j))*                         &
     &                     (UFe(i,j+1)-UFe(i  ,j)))
              cff2=UFs(i,j,k2)-UFs(i,j,k1)
              cff3=dt(ng)*(cff*cff1+cff2)
              rufrc(i,j)=rufrc(i,j)-cff1-cff2
              u(i,j,k,nnew)=u(i,j,k,nnew)-cff3
!!#ifdef DIAGNOSTICS_UV
!!            DiaRUfrc(i,j,3,M2hvis)=DiaRUfrc(i,j,3,M2hvis)-cff1-cff2
!!            DiaU3wrk(i,j,k,M3hvis)=-cff3
!!#endif
            END DO
          END DO
          DO j=JstrV,Jend
            DO i=Istr,Iend
              cff=0.25_r8*(pm(i,j)+pm(i,j-1))*(pn(i,j)+pn(i,j-1))
              cff1=0.5_r8*((pn(i,j-1)+pn(i,j))*                         &
     &                     (VFx(i+1,j)-VFx(i,j  ))-                     &
     &                     (pm(i,j-1)+pm(i,j))*                         &
     &                     (VFe(i  ,j)-VFe(i,j-1)))
              cff2=VFs(i,j,k2)-VFs(i,j,k1)
              cff3=dt(ng)*(cff*cff1+cff2)
              rvfrc(i,j)=rvfrc(i,j)-cff1-cff2
              v(i,j,k,nnew)=v(i,j,k,nnew)-cff3
!!#ifdef DIAGNOSTICS_UV
!!            DiaRVfrc(i,j,3,M2hvis)=DiaRVfrc(i,j,3,M2hvis)-cff1-cff2
!!            DiaV3wrk(i,j,k,M3hvis)=-cff3
!!#endif
            END DO
          END DO
        END IF
      END DO K_LOOP2
#undef IU_RANGE
#undef IV_RANGE
#undef JU_RANGE
#undef JV_RANGE
      RETURN
      END SUBROUTINE uv3dmix4_tile
