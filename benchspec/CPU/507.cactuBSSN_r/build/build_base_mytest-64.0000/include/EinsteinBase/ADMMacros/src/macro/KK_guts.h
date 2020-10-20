/*@@
  @header   KK_guts.h
  @date     Jun 98
  @author   Gabrielle Allen
  @desc

  Macro to calculate term K_{ik}K^{k}_{l}

  The macro is defined in terms of standard variables in
  KK_declare.h

  Requires: Upper physical metric
            Lower extrinsic curvature

  Provides: Components of K_{ik}K^{k}_{l}

  @enddesc
@@*/

#ifndef KK_GUTS
#define KK_GUTS

#include "UPPERMET_guts.h"

#ifdef FCODE

      KK_KKXX = 2*(UPPERMET_UYZ*KK_HXY*KK_HXZ + KK_HXX*(UPPERMET_UXY*KK_HXY + \
     UPPERMET_UXZ*KK_HXZ)) + UPPERMET_UXX*KK_HXX*KK_HXX + \
     UPPERMET_UYY*KK_HXY*KK_HXY + UPPERMET_UZZ*KK_HXZ*KK_HXZ

      KK_KKXY = KK_HXY*(UPPERMET_UXX*KK_HXX + UPPERMET_UYY*KK_HYY) + \
     UPPERMET_UZZ*KK_HXZ*KK_HYZ + UPPERMET_UXZ*(KK_HXY*KK_HXZ + \
     KK_HXX*KK_HYZ) + UPPERMET_UYZ*(KK_HXZ*KK_HYY + KK_HXY*KK_HYZ) + \
     UPPERMET_UXY*(KK_HXX*KK_HYY + KK_HXY*KK_HXY) 

      KK_KKXZ = UPPERMET_UYY*KK_HXY*KK_HYZ + UPPERMET_UXY*(KK_HXY*KK_HXZ + \
     KK_HXX*KK_HYZ) + KK_HXZ*(UPPERMET_UXX*KK_HXX + UPPERMET_UZZ*KK_HZZ) + \
     UPPERMET_UYZ*(KK_HXZ*KK_HYZ + KK_HXY*KK_HZZ) + \
     UPPERMET_UXZ*(KK_HXX*KK_HZZ + KK_HXZ*KK_HXZ) 

      KK_KKYY = 2*(UPPERMET_UYZ*KK_HYY*KK_HYZ + KK_HXY*(UPPERMET_UXY*KK_HYY + \
     UPPERMET_UXZ*KK_HYZ)) + UPPERMET_UXX*KK_HXY*KK_HXY  + \
     UPPERMET_UYY*KK_HYY*KK_HYY + UPPERMET_UZZ*KK_HYZ*KK_HYZ ;

      KK_KKYZ = UPPERMET_UXX*KK_HXY*KK_HXZ + UPPERMET_UXY*(KK_HXZ*KK_HYY + \
     KK_HXY*KK_HYZ) + KK_HYZ*(UPPERMET_UYY*KK_HYY + UPPERMET_UZZ*KK_HZZ) + \
     UPPERMET_UXZ*(KK_HXZ*KK_HYZ + KK_HXY*KK_HZZ) + \
     UPPERMET_UYZ*(KK_HYY*KK_HZZ + KK_HYZ*KK_HYZ) 

      KK_KKZZ = 2*(UPPERMET_UYZ*KK_HYZ*KK_HZZ + KK_HXZ*(UPPERMET_UXY*KK_HYZ + \
     UPPERMET_UXZ*KK_HZZ)) + UPPERMET_UXX*KK_HXZ*KK_HXZ + \
     UPPERMET_UYY*KK_HYZ*KK_HYZ + UPPERMET_UZZ*KK_HZZ*KK_HZZ 

#endif

#ifdef CCODE

KK_KKXX = 2*(UPPERMET_UYZ*KK_HXY*KK_HXZ + KK_HXX*(UPPERMET_UXY*KK_HXY +
UPPERMET_UXZ*KK_HXZ)) + UPPERMET_UXX*KK_HXX*KK_HXX +
UPPERMET_UYY*KK_HXY*KK_HXY + UPPERMET_UZZ*KK_HXZ*KK_HXZ;

KK_KKXY = KK_HXY*(UPPERMET_UXX*KK_HXX + UPPERMET_UYY*KK_HYY) +
UPPERMET_UZZ*KK_HXZ*KK_HYZ + UPPERMET_UXZ*(KK_HXY*KK_HXZ +
KK_HXX*KK_HYZ) + UPPERMET_UYZ*(KK_HXZ*KK_HYY + KK_HXY*KK_HYZ) +
UPPERMET_UXY*(KK_HXX*KK_HYY + KK_HXY*KK_HXY) ;

KK_KKXZ = UPPERMET_UYY*KK_HXY*KK_HYZ + UPPERMET_UXY*(KK_HXY*KK_HXZ +
KK_HXX*KK_HYZ) + KK_HXZ*(UPPERMET_UXX*KK_HXX + UPPERMET_UZZ*KK_HZZ) +
UPPERMET_UYZ*(KK_HXZ*KK_HYZ + KK_HXY*KK_HZZ) +
UPPERMET_UXZ*(KK_HXX*KK_HZZ + KK_HXZ*KK_HXZ) ;

KK_KKYY = 2*(UPPERMET_UYZ*KK_HYY*KK_HYZ + KK_HXY*(UPPERMET_UXY*KK_HYY +
UPPERMET_UXZ*KK_HYZ)) + UPPERMET_UXX*KK_HXY*KK_HXY  +
UPPERMET_UYY*KK_HYY*KK_HYY + UPPERMET_UZZ*KK_HYZ*KK_HYZ ;

KK_KKYZ = UPPERMET_UXX*KK_HXY*KK_HXZ + UPPERMET_UXY*(KK_HXZ*KK_HYY +
KK_HXY*KK_HYZ) + KK_HYZ*(UPPERMET_UYY*KK_HYY + UPPERMET_UZZ*KK_HZZ) +
UPPERMET_UXZ*(KK_HXZ*KK_HYZ + KK_HXY*KK_HZZ) +
UPPERMET_UYZ*(KK_HYY*KK_HZZ + KK_HYZ*KK_HYZ) ;

KK_KKZZ = 2*(UPPERMET_UYZ*KK_HYZ*KK_HZZ + KK_HXZ*(UPPERMET_UXY*KK_HYZ +
UPPERMET_UXZ*KK_HZZ)) + UPPERMET_UXX*KK_HXZ*KK_HXZ +
UPPERMET_UYY*KK_HYZ*KK_HYZ + UPPERMET_UZZ*KK_HZZ*KK_HZZ ;

#endif

#endif
  