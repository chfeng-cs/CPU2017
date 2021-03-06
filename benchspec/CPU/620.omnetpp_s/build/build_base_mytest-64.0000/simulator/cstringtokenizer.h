//==========================================================================
//  CSTRINGTOKENIZER.H - part of
//                     OMNeT++/OMNEST
//            Discrete System Simulation in C++
//
//
//  Declaration of the following classes:
//    cStringTokenizer  : string tokenizer utility class
//
//==========================================================================

/*--------------------------------------------------------------*
  Copyright (C) 1992-2008 Andras Varga
  Copyright (C) 2006-2008 OpenSim Ltd.

  This file is distributed WITHOUT ANY WARRANTY. See the file
  `license' for details on this and other legal matters.
*--------------------------------------------------------------*/

#ifndef __CSTRINGTOKENIZER_H
#define __CSTRINGTOKENIZER_H

#include <string>
#include <vector>
#include "simkerneldefs.h"

NAMESPACE_BEGIN

/**
 * String tokenizer class, modelled after strtok(). It considers the input
 * string to consist of tokens, separated by one or more delimiter characters.
 * Repeated calls to nextToken() will enumerate the tokens in the string,
 * returning NULL after the last token. The function hasMoreTokens() can be
 * used to find out whether there are more tokens without consuming one.
 *
 * Limitations: this class does not honor quotes, apostrophes or backslash
 * quoting; nor does it return empty tokens if it encounters multiple
 * delimiter characters in a row (so setting the delimiter to "," does not
 * produce the desired results). This behaviour is consistent with strtok().
 *
 * Example 1:
 *
 * <pre>
 * const char *str = "one two three four";
 * cStringTokenizer tokenizer(str);
 * while (tokenizer.hasMoreTokens())
 *     ev << " [" << tokenizer.nextToken() << "]";
 * </pre>
 *
 * Example 2:
 *
 * <pre>
 * const char *str = "42 13 46 72 41";
 * std::vector\<int\> array = cStringTokenizer(str).asIntVector();
 * </pre>
 *
 * @ingroup SimSupport
 */
class SIM_API cStringTokenizer
{
  private:
    char *str; // copy of full string
    char *rest; // rest of string (to be tokenized)
    std::string delimiter;

  public:
    /**
     * Constructor. The class will make its own copy of the input string
     * and of the delimiters string. The delimiters default to all whitespace
     * characters (space, tab, CR, LF, FF).
     */
    cStringTokenizer(const char *str, const char *delimiters=NULL);

    /**
     * Destructor.
     */
    ~cStringTokenizer();

    /**
     * Change delimiters. This allows for switching delimiters during
     * tokenization.
     */
    void setDelimiter(const char *s);

    /**
     * Returns true if there're more tokens (i.e. the next nextToken()
     * call won't return NULL).
     */
    bool hasMoreTokens();

    /**
     * Returns the next token. The returned pointers will stay valid as long
     * as the tokenizer object exists. If there're no more tokens,
     * a NULL pointer will be returned.
     */
    const char *nextToken();

    /**
     * Utility function: tokenizes the full input string at once, and
     * returns the tokens in a string vector.
     */
    std::vector<std::string> asVector();

    /**
     * Utility function: converts all tokens to int, and returns them
     * in a vector.
     */
    std::vector<int> asIntVector();

    /**
     * Utility function: converts all tokens to double, and returns them
     * in a vector.
     */
    std::vector<double> asDoubleVector();
};

NAMESPACE_END


#endif

