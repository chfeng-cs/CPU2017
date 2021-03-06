#ifndef OPERATORS_H
#define OPERATORS_H

#include <MoL/cctk.h>

CCTK_INT
MoL_LinearCombination(cGH const *const cctkGH,
                      CCTK_INT   const var,
                      CCTK_REAL  const scale,
                      CCTK_INT   const srcs[],
                      CCTK_INT   const tls[],
                      CCTK_REAL  const facts[],
                      CCTK_INT   const nsrcs);

#endif  // #ifndef OPERATORS_H
