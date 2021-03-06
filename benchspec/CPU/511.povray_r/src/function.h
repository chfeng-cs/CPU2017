/****************************************************************************
 *                  function.h
 *
 * This module contains all defines, typedefs, and prototypes for fnsyntax.c.
 *
 * This module is based on code by D. Skarda, T. Bily and R. Suzuki.
 *
 * from Persistence of Vision(tm) Ray Tracer version 3.6.
 * Copyright 1991-2003 Persistence of Vision Team
 * Copyright 2003-2009 Persistence of Vision Raytracer Pty. Ltd.
 *---------------------------------------------------------------------------
 * NOTICE: This source code file is provided so that users may experiment
 * with enhancements to POV-Ray and to port the software to platforms other
 * than those supported by the POV-Ray developers. There are strict rules
 * regarding how you are permitted to use this file. These rules are contained
 * in the distribution and derivative versions licenses which should have been
 * provided with this file.
 *
 * These licences may be found online, linked from the end-user license
 * agreement that is located at http://www.povray.org/povlegal.html
 *---------------------------------------------------------------------------
 * This program is based on the popular DKB raytracer version 2.12.
 * DKBTrace was originally written by David K. Buck.
 * DKBTrace Ver 2.0-2.12 were written by David K. Buck & Aaron A. Collins.
 *---------------------------------------------------------------------------
 * $File: //depot/povray/spec-3.6/source/function.h $
 * $Revision: #1 $
 * $Change: 5014 $
 * $DateTime: 2010/06/13 03:51:51 $
 * $Author: thorsten $
 * $Log$
 *****************************************************************************/


#ifndef FUNCTION_H
#define FUNCTION_H

BEGIN_POV_NAMESPACE

typedef unsigned int FUNCTION;
typedef FUNCTION * FUNCTION_PTR;

FUNCTION_PTR Parse_Function(void);
FUNCTION_PTR Parse_FunctionContent(void);
#if !defined(SPEC)
FUNCTION_PTR Parse_DeclareFunction(int *token_id, char *fn_name, bool is_loca);
#else
FUNCTION_PTR Parse_DeclareFunction(int *token_id, const char *fn_name, bool is_loca);
#endif
void Destroy_Function(FUNCTION_PTR Function);
FUNCTION_PTR Copy_Function(FUNCTION_PTR Function);

#define MAX_CALL_STACK_SIZE 1024

END_POV_NAMESPACE

#endif
