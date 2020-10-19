#include "config.h"

#include <map>
#include <math.h>

#include "Matcher.h"
#include "FastBoard.h"
#include "Utils.h"
#include "WeightsMatcher.h"

Matcher* Matcher::s_matcher = 0;

Matcher* Matcher::get_Matcher(void) {
    if (s_matcher == 0) {
        s_matcher = new Matcher;
    }
    
    return s_matcher;
}

void Matcher::set_Matcher(Matcher * m) {
    if (s_matcher) {
        delete s_matcher;
    }
    
    s_matcher = m;
}

// initialize matcher data
Matcher::Matcher() { 
    const int max = 1 << ((8 * 2) + 4);

    m_patterns[FastBoard::BLACK].resize(max);    
    m_patterns[FastBoard::WHITE].resize(max);    
   
    // minimal board we need is 3x3
    FastBoard board;
    board.reset_board(3);        
     
    // center square
    int startvtx = board.get_vertex(1, 1);
    
    typedef std::map<int, float> patmap;    
    patmap patweights;
    
#ifndef SPEC
    for (int i = 0; i < internal_weights_fast.size(); i++) {
#else
    for (unsigned int i = 0; i < internal_weights_fast.size(); i++) {
#endif
        std::pair<int, float> pr = std::make_pair(internal_patterns_fast[i],
                                                  internal_weights_fast[i]);        
        patweights.insert(pr);
    }    
    
    for (int i = 0; i < max; i++) {
        int w = i;        
        // fill board
        for (int k = 7; k >= 0; k--) {
            board.set_square(startvtx + board.get_extra_dir(k), 
                             static_cast<FastBoard::square_t>(w & 3));
            w = w >> 2;
        }     
        
        int reducpat1 = board.get_pattern3_augment_spec(startvtx, w, false);
        int reducpat2 = board.get_pattern3_augment_spec(startvtx, w, true);
        
        patmap::iterator it = patweights.find(reducpat1);
        
        if (it != patweights.end()) {
            float weight = it->second;
            m_patterns[FastBoard::BLACK][i] = clip(weight * 40.0);
        } else {
            m_patterns[FastBoard::BLACK][i] = 1;
        }
        
        it = patweights.find(reducpat2);
        
        if (it != patweights.end()) {
            float weight = it->second;
            m_patterns[FastBoard::WHITE][i] = clip(weight * 40.0);
        } else {
            m_patterns[FastBoard::WHITE][i] = 1;
        }                                      
    }           
}

int Matcher::matches(int color, int pattern) {
    return m_patterns[color][pattern];
}

unsigned char Matcher::clip(int val) {
    if (val < 0) {
        val = 0;
    } else if (val > 255) {
        val = 255;
    }
    
    return val;
}
