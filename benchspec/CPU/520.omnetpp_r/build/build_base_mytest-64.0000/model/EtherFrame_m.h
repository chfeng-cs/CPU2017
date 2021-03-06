//
// Generated file, do not edit! Created by opp_msgc 4.0 from EtherFrame.msg.
//

#ifndef _ETHERFRAME_M_H_
#define _ETHERFRAME_M_H_

#include <omnetpp.h>

// opp_msgc version check
#define MSGC_VERSION 0x0400
#if (MSGC_VERSION!=OMNETPP_VERSION)
#    error Version mismatch! Probably this file was generated by an earlier version of opp_msgc: 'make clean' should help.
#endif

// cplusplus {{ ... }} section:

#include "Ethernet.h"
#include "MACAddress.h"
#include "Ieee802Ctrl_m.h"
// end cplusplus



/**
 * Class generated from <tt>EtherFrame.msg</tt> by opp_msgc.
 * <pre>
 * packet EtherJam
 * {
 * }
 * </pre>
 */
class EtherJam : public cPacket
{
  protected:

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const EtherJam&);

  public:
    EtherJam(const char *name=NULL, int kind=0);
    EtherJam(const EtherJam& other);
    virtual ~EtherJam();
    EtherJam& operator=(const EtherJam& other);
    virtual EtherJam *dup() const {return new EtherJam(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
};

inline void doPacking(cCommBuffer *b, EtherJam& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, EtherJam& obj) {obj.parsimUnpack(b);}

/**
 * Class generated from <tt>EtherFrame.msg</tt> by opp_msgc.
 * <pre>
 * packet EtherFrame
 * {
 *     MACAddress dest;
 *     MACAddress src;
 *
 * }
 * </pre>
 */
class EtherFrame : public cPacket
{
  protected:
    MACAddress dest_var;
    MACAddress src_var;

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const EtherFrame&);

  public:
    EtherFrame(const char *name=NULL, int kind=0);
    EtherFrame(const EtherFrame& other);
    virtual ~EtherFrame();
    EtherFrame& operator=(const EtherFrame& other);
    virtual EtherFrame *dup() const {return new EtherFrame(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual MACAddress& getDest();
    virtual const MACAddress& getDest() const {return const_cast<EtherFrame*>(this)->getDest();}
    virtual void setDest(const MACAddress& dest_var);
    virtual MACAddress& getSrc();
    virtual const MACAddress& getSrc() const {return const_cast<EtherFrame*>(this)->getSrc();}
    virtual void setSrc(const MACAddress& src_var);
};

inline void doPacking(cCommBuffer *b, EtherFrame& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, EtherFrame& obj) {obj.parsimUnpack(b);}

/**
 * Class generated from <tt>EtherFrame.msg</tt> by opp_msgc.
 * <pre>
 * packet EthernetIIFrame extends EtherFrame
 * {
 *     int etherType;
 * }
 * </pre>
 */
class EthernetIIFrame : public EtherFrame
{
  protected:
    int etherType_var;

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const EthernetIIFrame&);

  public:
    EthernetIIFrame(const char *name=NULL, int kind=0);
    EthernetIIFrame(const EthernetIIFrame& other);
    virtual ~EthernetIIFrame();
    EthernetIIFrame& operator=(const EthernetIIFrame& other);
    virtual EthernetIIFrame *dup() const {return new EthernetIIFrame(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual int getEtherType() const;
    virtual void setEtherType(int etherType_var);
};

inline void doPacking(cCommBuffer *b, EthernetIIFrame& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, EthernetIIFrame& obj) {obj.parsimUnpack(b);}

/**
 * Class generated from <tt>EtherFrame.msg</tt> by opp_msgc.
 * <pre>
 * packet EtherFrameWithLLC extends EtherFrame
 * {
 *     int ssap;
 *     int dsap;
 *     int control;
 * }
 * </pre>
 */
class EtherFrameWithLLC : public EtherFrame
{
  protected:
    int ssap_var;
    int dsap_var;
    int control_var;

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const EtherFrameWithLLC&);

  public:
    EtherFrameWithLLC(const char *name=NULL, int kind=0);
    EtherFrameWithLLC(const EtherFrameWithLLC& other);
    virtual ~EtherFrameWithLLC();
    EtherFrameWithLLC& operator=(const EtherFrameWithLLC& other);
    virtual EtherFrameWithLLC *dup() const {return new EtherFrameWithLLC(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual int getSsap() const;
    virtual void setSsap(int ssap_var);
    virtual int getDsap() const;
    virtual void setDsap(int dsap_var);
    virtual int getControl() const;
    virtual void setControl(int control_var);
};

inline void doPacking(cCommBuffer *b, EtherFrameWithLLC& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, EtherFrameWithLLC& obj) {obj.parsimUnpack(b);}

/**
 * Class generated from <tt>EtherFrame.msg</tt> by opp_msgc.
 * <pre>
 * packet EtherFrameWithSNAP extends EtherFrame
 * {
 *     long orgCode;
 *     int localcode;
 * }
 * </pre>
 */
class EtherFrameWithSNAP : public EtherFrame
{
  protected:
    long orgCode_var;
    int localcode_var;

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const EtherFrameWithSNAP&);

  public:
    EtherFrameWithSNAP(const char *name=NULL, int kind=0);
    EtherFrameWithSNAP(const EtherFrameWithSNAP& other);
    virtual ~EtherFrameWithSNAP();
    EtherFrameWithSNAP& operator=(const EtherFrameWithSNAP& other);
    virtual EtherFrameWithSNAP *dup() const {return new EtherFrameWithSNAP(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual long getOrgCode() const;
    virtual void setOrgCode(long orgCode_var);
    virtual int getLocalcode() const;
    virtual void setLocalcode(int localcode_var);
};

inline void doPacking(cCommBuffer *b, EtherFrameWithSNAP& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, EtherFrameWithSNAP& obj) {obj.parsimUnpack(b);}

/**
 * Class generated from <tt>EtherFrame.msg</tt> by opp_msgc.
 * <pre>
 * packet EtherPauseFrame extends EtherFrame
 * {
 *     int pauseTime;
 * }
 * </pre>
 */
class EtherPauseFrame : public EtherFrame
{
  protected:
    int pauseTime_var;

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const EtherPauseFrame&);

  public:
    EtherPauseFrame(const char *name=NULL, int kind=0);
    EtherPauseFrame(const EtherPauseFrame& other);
    virtual ~EtherPauseFrame();
    EtherPauseFrame& operator=(const EtherPauseFrame& other);
    virtual EtherPauseFrame *dup() const {return new EtherPauseFrame(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual int getPauseTime() const;
    virtual void setPauseTime(int pauseTime_var);
};

inline void doPacking(cCommBuffer *b, EtherPauseFrame& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, EtherPauseFrame& obj) {obj.parsimUnpack(b);}

/**
 * Class generated from <tt>EtherFrame.msg</tt> by opp_msgc.
 * <pre>
 * packet EtherAutoconfig
 * {
 *     long txrate = 0;
 *     bool halfDuplex = false;
 * }
 * </pre>
 */
class EtherAutoconfig : public cPacket
{
  protected:
    long txrate_var;
    bool halfDuplex_var;

    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const EtherAutoconfig&);

  public:
    EtherAutoconfig(const char *name=NULL, int kind=0);
    EtherAutoconfig(const EtherAutoconfig& other);
    virtual ~EtherAutoconfig();
    EtherAutoconfig& operator=(const EtherAutoconfig& other);
    virtual EtherAutoconfig *dup() const {return new EtherAutoconfig(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual long getTxrate() const;
    virtual void setTxrate(long txrate_var);
    virtual bool getHalfDuplex() const;
    virtual void setHalfDuplex(bool halfDuplex_var);
};

inline void doPacking(cCommBuffer *b, EtherAutoconfig& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, EtherAutoconfig& obj) {obj.parsimUnpack(b);}


#endif // _ETHERFRAME_M_H_
