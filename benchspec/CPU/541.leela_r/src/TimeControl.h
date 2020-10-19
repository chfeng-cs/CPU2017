#ifndef TIMECONTROL_H_INCLUDED
#define TIMECONTROL_H_INCLUDED

#include <boost/tr1/array.hpp>

#include "Timing.h"

class TimeControl {    
public:    
    /*
        Initialize time control. Timing info is per GTP and in centiseconds
    */        
    TimeControl(int boardsize = 9, 
                int maintime = 5 * 60 * 100, 
                int byotime = 0, int byostones = 25);
    
    void start(int color);
    void stop(int color);
    bool time_forfeit(int color);
    int max_time_for_move(int color);
    void adjust_time(int color, int time, int stones);
    void set_boardsize(int boardsize);
    void display_times();    
    int get_maintime(); /* main time in seconds */
    int get_remaining_time(int color);
    
private:
    int m_maintime;        
    int m_byotime;
    int m_byostones;    
    int m_moves_expected;    
    
    std::tr1::array<int,  2> m_remaining_time;    /* main time per player */
    std::tr1::array<int,  2> m_stones_left;       /* stones to play in byo period */
    std::tr1::array<bool, 2> m_inbyo;             /* player is in byo yomi */
    
    std::tr1::array<Time, 2> m_times;             /* storage for player times */
};

#endif
