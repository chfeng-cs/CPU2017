//==========================================================================
//   CFSM.H  -  header for
//                     OMNeT++/OMNEST
//            Discrete System Simulation in C++
//
//  Contents:
//    FSM building macros
//    class cFSM: stores the state of an FSM
//
//==========================================================================

/*--------------------------------------------------------------*
  Copyright (C) 1992-2008 Andras Varga
  Copyright (C) 2006-2008 OpenSim Ltd.

  This file is distributed WITHOUT ANY WARRANTY. See the file
  `license' for details on this and other legal matters.
*--------------------------------------------------------------*/

#ifndef __CFSM_H
#define __CFSM_H

#include "cownedobject.h"

NAMESPACE_BEGIN

/**
 * @ingroup Macros
 * @defgroup MacrosFSM Final State Machine macros
 */
//@{

/**
 * After this many transitions without reaching a steady state
 * we assume the FSM is in an infinite loop.
 */
#define FSM_MAXT  64

/**
 * Implements a Finite State Machine. FSM state is stored in
 * an object of type cFSM.
 *
 * There are two kinds of states: transient and steady. At each
 * execution of the FSM_Switch() statement, the FSM transitions out
 * of the current (steady) state, potentially undergoes a series of
 * state changes to transient states, and arrives at another
 * steady state.
 *
 * The actual FSM is embedded in an FSM_Switch(), which has cases for
 * entering and leaving each state:
 *
 * <PRE>
 * FSM_Switch(fsm)
 * {
 *     case FSM_Exit(state1):
 *         //...
 *         break;
 *     case FSM_Enter(state1):
 *         //...
 *         break;
 *     case FSM_Exit(state2):
 *         //...
 *         break;
 *     case FSM_Enter(state2):
 *         //...
 *         break;
 *     //...
 * }
 * </PRE>
 *
 * States are declared in enums, using the FSM_Transient() and FSM_Steady() macros.
 *
 * State transitions are done via calls to FSM_Goto(), which simply stores the
 * new state in the cFSM object.
 *
 * @hideinitializer
 * @see cFSM, FSM_Transient, FSM_Steady, FSM_Goto, FSM_Debug, FSM_Print
 */
//
// operation:
// - __i counts up (starting from 1) until the FSM reaches a steady state.
// - at __i=1,3,5,7,etc, FSM_Exit code is executed
// - at __i=2,4,6,8,etc, FSM_Enter code is executed
// - FSM_Enter code must not contain state change (this is verified)
// - state changes should be encoded in FSM_Exit code
// - infinite loops (when control never reaches steady state) are detected (FSM_MAXT)
//
#define FSM_Switch(fsm)  \
   for (int __i=1, __savedstate;  \
        (__i<3 || (__i&1)==0 || (fsm).isInTransientState()) &&  \
        (__i<2*FSM_MAXT || (opp_error(eINFLOOP,(fsm).getStateName()),0));  \
        ((__i&1)==0 && __savedstate!=(fsm).getState() &&  \
         (opp_error(eSTATECHG,(fsm).getStateName()),0)),  \
         __savedstate=(fsm).getState(),++__i)  \
     switch (FSM_Print(fsm,__i&1),(((fsm).getState()<<1)|(__i&1)))

/**
 * Declares a transient state; to be used in enum which declares states.
 * Example:
 *
 * <PRE>
 * enum {
 *    INIT = 0,
 *    SLEEP = FSM_Steady(1),
 *    ACTIVE = FSM_Steady(2),
 *    SEND = FSM_Transient(1),
 * };
 * </PRE>
 *
 * The numbers in parens must be unique within the state type and they are
 * used for constructing numeric IDs for the states.
 *
 * @hideinitializer
 * @see FSM_Steady, FSM_Switch
 */
#define FSM_Transient(state)   (-(state))

/**
 * Declares a steady state; to be used in enum which declares states.
 * See example in FSM_Transient.
 *
 * @hideinitializer
 * @see FSM_Transient, FSM_Switch
 */
#define FSM_Steady(state)      (state)

/**
 * Within an FSM_Switch() case branch, declares code to be executed
 * on entering the given state. No calls to FSM_Goto() are allowed
 * within a state's Enter block.
 *
 * @hideinitializer
 * @see FSM_Switch
 */
#define FSM_Enter(state)  ((state)<<1)

/**
 * Within an FSM_Switch() case branch, declares code to be executed
 * on exiting the given state.
 *
 * @hideinitializer
 * @see FSM_Switch
 */
#define FSM_Exit(state)   (((state)<<1)|1)

/**
 * To be used in state exit code, to transition to another state.
 *
 * Uses stringize (\#state), so it only works correctly if 'state'
 * is the enum name itself and not some variable that contains the
 * state code.
 *
 * @hideinitializer
 * @see FSM_Switch
 */
#define FSM_Goto(fsm,state)   (fsm).setState(state,#state)

#ifdef FSM_DEBUG
/**
 * #define FSM_DEBUG before #including "omnetpp.h" to enable reporting
 * all state changes to ev.
 *
 * @hideinitializer
 * @see FSM_Switch
 */
#define FSM_Print(fsm,exiting) \
    (ev << "FSM " << (fsm).getName() \
        << ((exiting) ? ": leaving state  " : ": entering state ") \
        << (fsm).getStateName() << endl)
// this may also be useful as third line:
//      << ((fsm).isInTransientState() ? "transient state " : "steady state ")
#else
#define FSM_Print(fsm,entering) ((void)0)
#endif

//@}

//-----------------------------------------------------

/**
 * Store the state of an FSM. This class is used in conjunction with
 * the FSM_Switch() and other FSM_ macros.
 *
 * @ingroup SimSupport
 * @see FSM_Switch, FSM_Transient, FSM_Steady, FSM_Enter, FSM_Exit, FSM_Goto
 */
class SIM_API cFSM : public cOwnedObject
{
  private:
    //
    // About state codes:
    //  initial state is number 0
    //  negative state codes are transient states
    //  positive state codes are steady states
    //
    int _state;
    const char *_statename;   // just a ptr to an external string

  public:
    /** @name Constructors, destructor, assignment. */
    //@{

    /**
     * Constructor.
     */
    explicit cFSM(const char *name=NULL);

    /**
     * Copy constructor.
     */
    cFSM(const cFSM& vs) : cOwnedObject() {setName(vs.getName());operator=(vs);}

    /**
     * Assignment operator. The name member doesn't get copied;
     * see cOwnedObject's operator=() for more details.
     */
    cFSM& operator=(const cFSM& vs);
    //@}

    /** @name Redefined cObject member functions. */
    //@{

    /**
     * Creates and returns an exact copy of this object.
     * See cObject for more details.
     */
    virtual cFSM *dup() const  {return new cFSM(*this);}

    /**
     * Produces a one-line description of the object's contents.
     * See cObject for more details.
     */
    virtual std::string info() const;

    /**
     * Serializes the object into an MPI send buffer.
     * Used by the simulation kernel for parallel execution.
     * See cObject for more details.
     */
    virtual void parsimPack(cCommBuffer *buffer);

    /**
     * Deserializes the object from an MPI receive buffer
     * Used by the simulation kernel for parallel execution.
     * See cObject for more details.
     */
    virtual void parsimUnpack(cCommBuffer *buffer);
    //@}

    /** @name FSM functions. */
    //@{

    /**
     * Returns the state the FSM is currently in.
     */
    int getState() const  {return _state;}

    /**
     * Returns the name of the state the FSM is currently in.
     */
    const char *getStateName() const {return _statename?_statename:"";}

    /**
     * Returns true if the FSM is currently in a transient state.
     */
    int isInTransientState() const  {return _state<0;}

    /**
     * Sets the state of the FSM. This method is usually invoked through
     * the FSM_Goto() macro.
     *
     * The first arg is the state code. The second arg is the name of the state.
     * setState() assumes this is pointer to a string literal (the string is
     * not copied, only the pointer is stored).
     *
     * @see FSM_Goto
     */
    void setState(int state, const char *stn=NULL)  {_state=state;_statename=stn;}
    //@}
};

NAMESPACE_END


#endif
