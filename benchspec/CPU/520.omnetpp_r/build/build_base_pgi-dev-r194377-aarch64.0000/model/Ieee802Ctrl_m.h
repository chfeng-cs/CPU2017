//
// Generated file, do not edit! Created by opp_msgc 4.0 from Ieee802Ctrl.msg.
//

#ifndef _IEEE802CTRL_M_H_
#define _IEEE802CTRL_M_H_

#include <omnetpp.h>

// opp_msgc version check
#define MSGC_VERSION 0x0400
#if (MSGC_VERSION!=OMNETPP_VERSION)
#    error Version mismatch! Probably this file was generated by an earlier version of opp_msgc: 'make clean' should help.
#endif

// cplusplus {{ ... }} section:

#include "MACAddress.h"
// end cplusplus



/**
 * Enum generated from <tt>Ieee802Ctrl.msg</tt> by opp_msgc.
 * <pre>
 * enum Ieee802MessageKind
 * {
 * 
 *     IEEE802CTRL_DATA = 2003;  
 *     IEEE802CTRL_REGISTER_DSAP = 2004;  
 *     IEEE802CTRL_DEREGISTER_DSAP = 2005;  
 *     IEEE802CTRL_SENDPAUSE = 2006;  
 * }
 * </pre>
 */
enum Ieee802MessageKind {
    IEEE802CTRL_DATA = 2003,
    IEEE802CTRL_REGISTER_DSAP = 2004,
    IEEE802CTRL_DEREGISTER_DSAP = 2005,
    IEEE802CTRL_SENDPAUSE = 2006
};

/**
 * Enum generated from <tt>Ieee802Ctrl.msg</tt> by opp_msgc.
 * <pre>
 * enum SAPCode
 * {
 * 
 *     SAP_IBM_SNA = 0x04;
 *     SAP_IP = 0x06;
 *     SAP_3COM = 0x80;
 *     SAP_SNAP = 0xAA;
 *     SAP_BANYAN = 0xBC;
 *     SAP_NOVELL_IPX = 0xE0;
 *     SAP_LAN_MANAGER = 0xF4;
 *     SAP_CLNS = 0xFE;
 * }
 * </pre>
 */
enum SAPCode {
    SAP_IBM_SNA = 0x04,
    SAP_IP = 0x06,
    SAP_3COM = 0x80,
    SAP_SNAP = 0xAA,
    SAP_BANYAN = 0xBC,
    SAP_NOVELL_IPX = 0xE0,
    SAP_LAN_MANAGER = 0xF4,
    SAP_CLNS = 0xFE
};

/**
 * Enum generated from <tt>Ieee802Ctrl.msg</tt> by opp_msgc.
 * <pre>
 * enum EtherType
 * {
 * 
 *     ETHERTYPE_IP = 0x0800;
 *     ETHERTYPE_ARP = 0x0806;
 *     ETHERTYPE_RARP = 0x8035;
 * }
 * </pre>
 */
enum EtherType {
    ETHERTYPE_IP = 0x0800,
    ETHERTYPE_ARP = 0x0806,
    ETHERTYPE_RARP = 0x8035
};

/**
 * Class generated from <tt>Ieee802Ctrl.msg</tt> by opp_msgc.
 * <pre>
 * class Ieee802Ctrl
 * {
 *     MACAddress src;  
 *     MACAddress dest; 
 *     int etherType;   
 *     int ssap;        
 *     int dsap;        
 *     int pauseUnits;  
 *     int inputPort;   
 * }
 * </pre>
 */
class Ieee802Ctrl : public cObject
{
  protected:
    MACAddress src_var;
    MACAddress dest_var;
    int etherType_var;
    int ssap_var;
    int dsap_var;
    int pauseUnits_var;
    int inputPort_var;

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const Ieee802Ctrl&);

  public:
    Ieee802Ctrl();
    Ieee802Ctrl(const Ieee802Ctrl& other);
    virtual ~Ieee802Ctrl();
    Ieee802Ctrl& operator=(const Ieee802Ctrl& other);
    virtual Ieee802Ctrl *dup() const {return new Ieee802Ctrl(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual MACAddress& getSrc();
    virtual const MACAddress& getSrc() const {return const_cast<Ieee802Ctrl*>(this)->getSrc();}
    virtual void setSrc(const MACAddress& src_var);
    virtual MACAddress& getDest();
    virtual const MACAddress& getDest() const {return const_cast<Ieee802Ctrl*>(this)->getDest();}
    virtual void setDest(const MACAddress& dest_var);
    virtual int getEtherType() const;
    virtual void setEtherType(int etherType_var);
    virtual int getSsap() const;
    virtual void setSsap(int ssap_var);
    virtual int getDsap() const;
    virtual void setDsap(int dsap_var);
    virtual int getPauseUnits() const;
    virtual void setPauseUnits(int pauseUnits_var);
    virtual int getInputPort() const;
    virtual void setInputPort(int inputPort_var);
};

inline void doPacking(cCommBuffer *b, Ieee802Ctrl& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, Ieee802Ctrl& obj) {obj.parsimUnpack(b);}


#endif // _IEEE802CTRL_M_H_
