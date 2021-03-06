/*
 * $Id: zle_bindings.c,v 2.6 1996/10/15 20:16:35 hzoli Exp $
 *
 * zle_bindings.c - commands and keymaps
 *
 * This file is part of zsh, the Z shell.
 *
 * Copyright (c) 1992-1996 Paul Falstad
 * All rights reserved.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and to distribute modified versions of this software for any
 * purpose, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 *
 * In no event shall Paul Falstad or the Zsh Development Group be liable
 * to any party for direct, indirect, special, incidental, or consequential
 * damages arising out of the use of this software and its documentation,
 * even if Paul Falstad and the Zsh Development Group have been advised of
 * the possibility of such damage.
 *
 * Paul Falstad and the Zsh Development Group specifically disclaim any
 * warranties, including, but not limited to, the implied warranties of
 * merchantability and fitness for a particular purpose.  The software
 * provided hereunder is on an "as is" basis, and Paul Falstad and the
 * Zsh Development Group have no obligation to provide maintenance,
 * support, updates, enhancements, or modifications.
 *
 */

#define ZLE
#include "zsh.h"

struct zlecmd zlecmds[] =
{
    {"accept-and-hold", acceptandhold, 0},
    {"accept-and-infer-next-history", acceptandinfernexthistory, 0},
    {"accept-and-menu-complete", acceptandmenucomplete, ZLE_MENUCMP},
    {"accept-line", acceptline, 0},
    {"accept-line-and-down-history", acceptlineanddownhistory, 0},
    {"backward-char", backwardchar, ZLE_MOVEMENT},
    {"backward-delete-char", backwarddeletechar, ZLE_DELETE},
    {"backward-delete-word", backwarddeleteword, ZLE_DELETE},
    {"backward-kill-line", backwardkillline, ZLE_KILL},
    {"backward-kill-word", backwardkillword, ZLE_KILL | ZLE_DELETE},
    {"backward-word", backwardword, ZLE_MOVEMENT},
    {"beginning-of-buffer-or-history", beginningofbufferorhistory, ZLE_MOVEMENT},
    {"beginning-of-history", beginningofhistory, 0},
    {"beginning-of-line", beginningofline, ZLE_MOVEMENT},
    {"beginning-of-line-hist", beginningoflinehist, ZLE_MOVEMENT},
    {"capitalize-word", capitalizeword, 0},
    {"clear-screen", clearscreen, ZLE_MENUCMP},
    {"complete-word", completeword, ZLE_MENUCMP},
    {"copy-prev-word", copyprevword, 0},
    {"copy-region-as-kill", copyregionaskill, ZLE_KILL},
    {"delete-char", deletechar, ZLE_DELETE},
    {"delete-char-or-list", deletecharorlist, ZLE_MENUCMP},
    {"delete-word", deleteword, ZLE_DELETE},
    {"describe-key-briefly", describekeybriefly, ZLE_MENUCMP},
    {"digit-argument", digitargument, ZLE_DIGIT | ZLE_ARG | ZLE_MENUCMP},
    {"down-case-word", downcaseword, 0},
    {"down-history", downhistory, 0},
    {"down-line-or-history", downlineorhistory, ZLE_MOVEMENT | ZLE_LINEMOVE},
    {"down-line-or-search", downlineorsearch, ZLE_MOVEMENT | ZLE_LINEMOVE | ZLE_HISTSEARCH},
    {"emacs-backward-word", emacsbackwardword, ZLE_MOVEMENT},
    {"emacs-forward-word", emacsforwardword, ZLE_MOVEMENT},
    {"end-of-buffer-or-history", endofbufferorhistory, ZLE_MOVEMENT},
    {"end-of-history", endofhistory, 0},
    {"end-of-line", endofline, ZLE_MOVEMENT},
    {"end-of-line-hist", endoflinehist, ZLE_MOVEMENT},
    {"exchange-point-and-mark", exchangepointandmark, ZLE_MOVEMENT},
    {"execute-last-named-cmd", (F) 0, 0},
    {"execute-named-cmd", (F) 0, 0},
    {"expand-cmd-path", expandcmdpath, 0},
    {"expand-history", expandhistory, 0},
    {"expand-or-complete", expandorcomplete, ZLE_MENUCMP},
    {"expand-or-complete-prefix", expandorcompleteprefix, ZLE_MENUCMP},
    {"expand-word", expandword, 0},
    {"forward-char", forwardchar, ZLE_MOVEMENT},
    {"forward-word", forwardword, ZLE_MOVEMENT},
    {"get-line", getline, 0},
    {"gosmacs-transpose-chars", gosmacstransposechars, 0},
    {"history-beginning-search-backward", historybeginningsearchbackward, ZLE_HISTSEARCH},
    {"history-beginning-search-forward", historybeginningsearchforward, ZLE_HISTSEARCH},
    {"history-incremental-search-backward", historyincrementalsearchbackward, 0},
    {"history-incremental-search-forward", historyincrementalsearchforward, 0},
    {"history-search-backward", historysearchbackward, ZLE_HISTSEARCH},
    {"history-search-forward", historysearchforward, ZLE_HISTSEARCH},
    {"infer-next-history", infernexthistory, 0},
    {"insert-last-word", insertlastword, ZLE_INSERT},
    {"kill-buffer", killbuffer, ZLE_KILL},
    {"kill-line", killline, ZLE_KILL},
    {"kill-region", killregion, ZLE_KILL},
    {"kill-whole-line", killwholeline, ZLE_KILL},
    {"kill-word", killword, ZLE_KILL},
    {"list-choices", listchoices, ZLE_MENUCMP},
    {"list-expand", listexpand, ZLE_MENUCMP},
    {"magic-space", magicspace, 0},
    {"menu-complete", menucomplete, ZLE_MENUCMP},
    {"menu-expand-or-complete", menuexpandorcomplete, ZLE_MENUCMP},
    {"neg-argument", negargument, ZLE_NEGARG | ZLE_ARG | ZLE_MENUCMP},
    {"overwrite-mode", overwritemode, 0},
    {"pound-insert", poundinsert, 0},
    {"prefix", (F) 0, 0},
    {"push-input", pushinput, 0},
    {"push-line", pushline, 0},
    {"push-line-or-edit", pushlineoredit, 0},
    {"quoted-insert", quotedinsert, ZLE_INSERT},
    {"quote-line", quoteline, 0},
    {"quote-region", quoteregion, 0},
    {"redisplay", redisplay, ZLE_MENUCMP},
    {"reverse-menu-complete", reversemenucomplete, ZLE_MENUCMP},
    {"run-help", processcmd, ZLE_MENUCMP},
    {"self-insert", selfinsert, ZLE_INSERT},
    {"self-insert-unmeta", selfinsertunmeta, ZLE_INSERT},
    {"send-break", sendbreak, 0},
    {"send-string", sendstring, 0},
    {"set-mark-command", setmarkcommand, ZLE_MENUCMP},
    {"spell-word", spellword, 0},
    {"transpose-chars", transposechars, 0},
    {"transpose-words", transposewords, 0},
    {"undefined-key", undefinedkey, 0},
    {"undo", undo, ZLE_UNDO},
    {"universal-argument", universalargument, ZLE_ARG | ZLE_MENUCMP},
    {"up-case-word", upcaseword, 0},
    {"up-history", uphistory, 0},
    {"up-line-or-history", uplineorhistory, ZLE_LINEMOVE | ZLE_MOVEMENT},
    {"up-line-or-search", uplineorsearch, ZLE_MOVEMENT | ZLE_LINEMOVE | ZLE_HISTSEARCH},
    {"vi-add-eol", viaddeol, 0},
    {"vi-add-next", viaddnext, 0},
    {"vi-backward-blank-word", vibackwardblankword, ZLE_MOVEMENT},
    {"vi-backward-char", vibackwardchar, ZLE_MOVEMENT},
    {"vi-backward-delete-char", vibackwarddeletechar, ZLE_DELETE},
    {"vi-backward-kill-word", vibackwardkillword, ZLE_KILL},
    {"vi-backward-word", vibackwardword, ZLE_MOVEMENT},
    {"vi-beginning-of-line", vibeginningofline, ZLE_MOVEMENT},
    {"vi-caps-lock-panic", vicapslockpanic, 0},
    {"vi-change", vichange, 0},
    {"vi-change-eol", vichangeeol, 0},
    {"vi-change-whole-line", vichangewholeline, 0},
    {"vi-cmd-mode", vicmdmode, 0},
    {"vi-delete", videlete, ZLE_KILL},
    {"vi-delete-char", videletechar, ZLE_DELETE},
    {"vi-digit-or-beginning-of-line", (F) 0, 0},
    {"vi-down-line-or-history", vidownlineorhistory, ZLE_LINEMOVE | ZLE_MOVEMENT},
    {"vi-end-of-line", viendofline, ZLE_MOVEMENT},
    {"vi-fetch-history", vifetchhistory, 0},
    {"vi-find-next-char", vifindnextchar, ZLE_MOVEMENT},
    {"vi-find-next-char-skip", vifindnextcharskip, ZLE_MOVEMENT},
    {"vi-find-prev-char", vifindprevchar, ZLE_MOVEMENT},
    {"vi-find-prev-char-skip", vifindprevcharskip, ZLE_MOVEMENT},
    {"vi-first-non-blank", vifirstnonblank, ZLE_MOVEMENT},
    {"vi-forward-blank-word", viforwardblankword, ZLE_MOVEMENT},
    {"vi-forward-blank-word-end", viforwardblankwordend, ZLE_MOVEMENT},
    {"vi-forward-char", viforwardchar, ZLE_MOVEMENT},
    {"vi-forward-word", viforwardword, ZLE_MOVEMENT},
    {"vi-forward-word-end", viforwardwordend, ZLE_MOVEMENT},
    {"vi-goto-column", vigotocolumn, ZLE_MOVEMENT},
    {"vi-goto-mark", vigotomark, ZLE_MOVEMENT},
    {"vi-goto-mark-line", vigotomarkline, ZLE_MOVEMENT},
    {"vi-history-search-backward", vihistorysearchbackward, 0},
    {"vi-history-search-forward", vihistorysearchforward, 0},
    {"vi-indent", viindent, 0},
    {"vi-insert", viinsert, 0},
    {"vi-insert-bol", viinsertbol, 0},
    {"vi-join", vijoin, 0},
    {"vi-kill-eol", vikilleol, ZLE_KILL},
    {"vi-kill-line", vikillline, ZLE_KILL},
    {"vi-match-bracket", vimatchbracket, ZLE_MOVEMENT},
    {"vi-open-line-above", viopenlineabove, 0},
    {"vi-open-line-below", viopenlinebelow, 0},
    {"vi-oper-swap-case", vioperswapcase, 0},
    {"vi-pound-insert", vipoundinsert, 0},
    {"vi-put-after", viputafter, ZLE_YANK},
    {"vi-put-before", viputbefore, ZLE_YANK},
    {"vi-quoted-insert", viquotedinsert, ZLE_INSERT},
    {"vi-repeat-change", virepeatchange, 0},
    {"vi-repeat-find", virepeatfind, ZLE_MOVEMENT},
    {"vi-repeat-search", virepeatsearch, ZLE_MOVEMENT},
    {"vi-replace", vireplace, 0},
    {"vi-replace-chars", vireplacechars, 0},
    {"vi-rev-repeat-find", virevrepeatfind, ZLE_MOVEMENT},
    {"vi-rev-repeat-search", virevrepeatsearch, ZLE_MOVEMENT},
    {"vi-set-buffer", visetbuffer, ZLE_ARG | ZLE_MENUCMP},
    {"vi-set-mark", visetmark, ZLE_MENUCMP},
    {"vi-substitute", visubstitute, 0},
    {"vi-swap-case", viswapcase, 0},
    {"vi-undo-change", undo, 0},
    {"vi-unindent", viunindent, 0},
    {"vi-up-line-or-history", viuplineorhistory, ZLE_LINEMOVE | ZLE_MOVEMENT},
    {"vi-yank", viyank, 0},
    {"vi-yank-eol", viyankeol, 0},
    {"vi-yank-whole-line", viyankwholeline, 0},
    {"where-is", whereis, ZLE_MENUCMP},
    {"which-command", processcmd, ZLE_MENUCMP},
    {"yank", yank, ZLE_YANK},
    {"yank-pop", yankpop, ZLE_YANK},
    {"", (F) 0, 0}
};

int emacsbind[256] =
{
    /* ^@ */ z_setmarkcommand,
    /* ^A */ z_beginningofline,
    /* ^B */ z_backwardchar,
    /* ^C */ z_undefinedkey,
    /* ^D */ z_deletecharorlist,
    /* ^E */ z_endofline,
    /* ^F */ z_forwardchar,
    /* ^G */ z_sendbreak,
    /* ^H */ z_backwarddeletechar,
    /* ^I */ z_expandorcomplete,
    /* ^J */ z_acceptline,
    /* ^K */ z_killline,
    /* ^L */ z_clearscreen,
    /* ^M */ z_acceptline,
    /* ^N */ z_downlineorhistory,
    /* ^O */ z_acceptlineanddownhistory,
    /* ^P */ z_uplineorhistory,
    /* ^Q */ z_pushline,
    /* ^R */ z_historyincrementalsearchbackward,
    /* ^S */ z_historyincrementalsearchforward,
    /* ^T */ z_transposechars,
    /* ^U */ z_killwholeline,
    /* ^V */ z_quotedinsert,
    /* ^W */ z_backwardkillword,
    /* ^X */ z_prefix,
    /* ^Y */ z_yank,
    /* ^Z */ z_undefinedkey,
    /* ^[ */ z_prefix,
    /* ^\ */ z_undefinedkey,
    /* ^] */ z_undefinedkey,
    /* ^^ */ z_undefinedkey,
    /* ^_ */ z_undo,
    /*   */ z_selfinsert,
    /* ! */ z_selfinsert,
    /* " */ z_selfinsert,
    /* # */ z_selfinsert,
    /* $ */ z_selfinsert,
    /* % */ z_selfinsert,
    /* & */ z_selfinsert,
    /* ' */ z_selfinsert,
    /* ( */ z_selfinsert,
    /* ) */ z_selfinsert,
    /* * */ z_selfinsert,
    /* + */ z_selfinsert,
    /* , */ z_selfinsert,
    /* - */ z_selfinsert,
    /* . */ z_selfinsert,
    /* / */ z_selfinsert,
    /* 0 */ z_selfinsert,
    /* 1 */ z_selfinsert,
    /* 2 */ z_selfinsert,
    /* 3 */ z_selfinsert,
    /* 4 */ z_selfinsert,
    /* 5 */ z_selfinsert,
    /* 6 */ z_selfinsert,
    /* 7 */ z_selfinsert,
    /* 8 */ z_selfinsert,
    /* 9 */ z_selfinsert,
    /* : */ z_selfinsert,
    /* ; */ z_selfinsert,
    /* < */ z_selfinsert,
    /* = */ z_selfinsert,
    /* > */ z_selfinsert,
    /* ? */ z_selfinsert,
    /* @ */ z_selfinsert,
    /* A */ z_selfinsert,
    /* B */ z_selfinsert,
    /* C */ z_selfinsert,
    /* D */ z_selfinsert,
    /* E */ z_selfinsert,
    /* F */ z_selfinsert,
    /* G */ z_selfinsert,
    /* H */ z_selfinsert,
    /* I */ z_selfinsert,
    /* J */ z_selfinsert,
    /* K */ z_selfinsert,
    /* L */ z_selfinsert,
    /* M */ z_selfinsert,
    /* N */ z_selfinsert,
    /* O */ z_selfinsert,
    /* P */ z_selfinsert,
    /* Q */ z_selfinsert,
    /* R */ z_selfinsert,
    /* S */ z_selfinsert,
    /* T */ z_selfinsert,
    /* U */ z_selfinsert,
    /* V */ z_selfinsert,
    /* W */ z_selfinsert,
    /* X */ z_selfinsert,
    /* Y */ z_selfinsert,
    /* Z */ z_selfinsert,
    /* [ */ z_selfinsert,
    /* \ */ z_selfinsert,
    /* ] */ z_selfinsert,
    /* ^ */ z_selfinsert,
    /* _ */ z_selfinsert,
    /* ` */ z_selfinsert,
    /* a */ z_selfinsert,
    /* b */ z_selfinsert,
    /* c */ z_selfinsert,
    /* d */ z_selfinsert,
    /* e */ z_selfinsert,
    /* f */ z_selfinsert,
    /* g */ z_selfinsert,
    /* h */ z_selfinsert,
    /* i */ z_selfinsert,
    /* j */ z_selfinsert,
    /* k */ z_selfinsert,
    /* l */ z_selfinsert,
    /* m */ z_selfinsert,
    /* n */ z_selfinsert,
    /* o */ z_selfinsert,
    /* p */ z_selfinsert,
    /* q */ z_selfinsert,
    /* r */ z_selfinsert,
    /* s */ z_selfinsert,
    /* t */ z_selfinsert,
    /* u */ z_selfinsert,
    /* v */ z_selfinsert,
    /* w */ z_selfinsert,
    /* x */ z_selfinsert,
    /* y */ z_selfinsert,
    /* z */ z_selfinsert,
    /* { */ z_selfinsert,
    /* | */ z_selfinsert,
    /* } */ z_selfinsert,
    /* ~ */ z_selfinsert,
    /* ^? */ z_backwarddeletechar,
    /* M-^@ */ z_undefinedkey,
    /* M-^A */ z_undefinedkey,
    /* M-^B */ z_undefinedkey,
    /* M-^C */ z_undefinedkey,
    /* M-^D */ z_listchoices,
    /* M-^E */ z_undefinedkey,
    /* M-^F */ z_undefinedkey,
    /* M-^G */ z_sendbreak,
    /* M-^H */ z_backwardkillword,
    /* M-^I */ z_selfinsertunmeta,
    /* M-^J */ z_selfinsertunmeta,
    /* M-^K */ z_undefinedkey,
    /* M-^L */ z_clearscreen,
    /* M-^M */ z_selfinsertunmeta,
    /* M-^N */ z_undefinedkey,
    /* M-^O */ z_undefinedkey,
    /* M-^P */ z_undefinedkey,
    /* M-^Q */ z_undefinedkey,
    /* M-^R */ z_undefinedkey,
    /* M-^S */ z_undefinedkey,
    /* M-^T */ z_undefinedkey,
    /* M-^U */ z_undefinedkey,
    /* M-^V */ z_undefinedkey,
    /* M-^W */ z_undefinedkey,
    /* M-^X */ z_undefinedkey,
    /* M-^Y */ z_undefinedkey,
    /* M-^Z */ z_undefinedkey,
    /* M-^[ */ z_undefinedkey,
    /* M-^\ */ z_undefinedkey,
    /* M-^] */ z_undefinedkey,
    /* M-^^ */ z_undefinedkey,
    /* M-^_ */ z_copyprevword,
    /* M-  */ z_expandhistory,
    /* M-! */ z_expandhistory,
    /* M-" */ z_quoteregion,
    /* M-# */ z_undefinedkey,
    /* M-$ */ z_spellword,
    /* M-% */ z_undefinedkey,
    /* M-& */ z_undefinedkey,
    /* M-' */ z_quoteline,
    /* M-( */ z_undefinedkey,
    /* M-) */ z_undefinedkey,
    /* M-* */ z_undefinedkey,
    /* M-+ */ z_undefinedkey,
    /* M-, */ z_undefinedkey,
    /* M-- */ z_negargument,
    /* M-. */ z_insertlastword,
    /* M-/ */ z_undefinedkey,
    /* M-0 */ z_digitargument,
    /* M-1 */ z_digitargument,
    /* M-2 */ z_digitargument,
    /* M-3 */ z_digitargument,
    /* M-4 */ z_digitargument,
    /* M-5 */ z_digitargument,
    /* M-6 */ z_digitargument,
    /* M-7 */ z_digitargument,
    /* M-8 */ z_digitargument,
    /* M-9 */ z_digitargument,
    /* M-: */ z_undefinedkey,
    /* M-; */ z_undefinedkey,
    /* M-< */ z_beginningofbufferorhistory,
    /* M-= */ z_undefinedkey,
    /* M-> */ z_endofbufferorhistory,
    /* M-? */ z_whichcommand,
    /* M-@ */ z_undefinedkey,
    /* M-A */ z_acceptandhold,
    /* M-B */ z_backwardword,
    /* M-C */ z_capitalizeword,
    /* M-D */ z_killword,
    /* M-E */ z_undefinedkey,
    /* M-F */ z_forwardword,
    /* M-G */ z_getline,
    /* M-H */ z_runhelp,
    /* M-I */ z_undefinedkey,
    /* M-J */ z_undefinedkey,
    /* M-K */ z_undefinedkey,
    /* M-L */ z_downcaseword,
    /* M-M */ z_undefinedkey,
    /* M-N */ z_historysearchforward,
    /* M-O */ z_undefinedkey,
    /* M-P */ z_historysearchbackward,
    /* M-Q */ z_pushline,
    /* M-R */ z_undefinedkey,
    /* M-S */ z_spellword,
    /* M-T */ z_transposewords,
    /* M-U */ z_upcaseword,
    /* M-V */ z_undefinedkey,
    /* M-W */ z_copyregionaskill,
    /* M-X */ z_undefinedkey,
    /* M-Y */ z_undefinedkey,
    /* M-Z */ z_undefinedkey,
    /* M-[ */ z_undefinedkey,
    /* M-\ */ z_undefinedkey,
    /* M-] */ z_undefinedkey,
    /* M-^ */ z_undefinedkey,
    /* M-_ */ z_insertlastword,
    /* M-` */ z_undefinedkey,
    /* M-a */ z_acceptandhold,
    /* M-b */ z_backwardword,
    /* M-c */ z_capitalizeword,
    /* M-d */ z_killword,
    /* M-e */ z_undefinedkey,
    /* M-f */ z_forwardword,
    /* M-g */ z_getline,
    /* M-h */ z_runhelp,
    /* M-i */ z_undefinedkey,
    /* M-j */ z_undefinedkey,
    /* M-k */ z_undefinedkey,
    /* M-l */ z_downcaseword,
    /* M-m */ z_undefinedkey,
    /* M-n */ z_historysearchforward,
    /* M-o */ z_undefinedkey,
    /* M-p */ z_historysearchbackward,
    /* M-q */ z_pushline,
    /* M-r */ z_undefinedkey,
    /* M-s */ z_spellword,
    /* M-t */ z_transposewords,
    /* M-u */ z_upcaseword,
    /* M-v */ z_undefinedkey,
    /* M-w */ z_copyregionaskill,
    /* M-x */ z_executenamedcmd,
    /* M-y */ z_yankpop,
    /* M-z */ z_executelastnamedcmd,
    /* M-{ */ z_undefinedkey,
    /* M-| */ z_vigotocolumn,
    /* M-} */ z_undefinedkey,
    /* M-~ */ z_undefinedkey,
    /* M-^? */ z_backwardkillword,
};

int viinsbind[32] =
{
    /* ^@ */ z_undefinedkey,
    /* ^A */ z_selfinsert,
    /* ^B */ z_selfinsert,
    /* ^C */ z_selfinsert,
    /* ^D */ z_listchoices,
    /* ^E */ z_selfinsert,
    /* ^F */ z_selfinsert,
    /* ^G */ z_listexpand,
    /* ^H */ z_vibackwarddeletechar,
    /* ^I */ z_expandorcomplete,
    /* ^J */ z_acceptline,
    /* ^K */ z_selfinsert,
    /* ^L */ z_clearscreen,
    /* ^M */ z_acceptline,
    /* ^N */ z_selfinsert,
    /* ^O */ z_selfinsert,
    /* ^P */ z_selfinsert,
    /* ^Q */ z_viquotedinsert,
    /* ^R */ z_redisplay,
    /* ^S */ z_selfinsert,
    /* ^T */ z_selfinsert,
    /* ^U */ z_vikillline,
    /* ^V */ z_viquotedinsert,
    /* ^W */ z_vibackwardkillword,
    /* ^X */ z_selfinsert,
    /* ^Y */ z_selfinsert,
    /* ^Z */ z_selfinsert,
    /* ^[ */ z_prefix,
    /* ^\ */ z_selfinsert,
    /* ^] */ z_selfinsert,
    /* ^^ */ z_selfinsert,
    /* ^_ */ z_selfinsert,
};

int vicmdbind[128] =
{
    /* ^@ */ z_undefinedkey,
    /* ^A */ z_undefinedkey,
    /* ^B */ z_undefinedkey,
    /* ^C */ z_undefinedkey,
    /* ^D */ z_listchoices,
    /* ^E */ z_undefinedkey,
    /* ^F */ z_undefinedkey,
    /* ^G */ z_listexpand,
    /* ^H */ z_vibackwardchar,
    /* ^I */ z_undefinedkey,
    /* ^J */ z_acceptline,
    /* ^K */ z_undefinedkey,
    /* ^L */ z_clearscreen,
    /* ^M */ z_acceptline,
    /* ^N */ z_downhistory,
    /* ^O */ z_undefinedkey,
    /* ^P */ z_uphistory,
    /* ^Q */ z_undefinedkey,
    /* ^R */ z_redisplay,
    /* ^S */ z_undefinedkey,
    /* ^T */ z_undefinedkey,
    /* ^U */ z_undefinedkey,
    /* ^V */ z_undefinedkey,
    /* ^W */ z_undefinedkey,
    /* ^X */ z_undefinedkey,
    /* ^Y */ z_undefinedkey,
    /* ^Z */ z_undefinedkey,
    /* ^[ */ z_prefix,
    /* ^\ */ z_undefinedkey,
    /* ^] */ z_undefinedkey,
    /* ^^ */ z_undefinedkey,
    /* ^_ */ z_undefinedkey,
    /*   */ z_viforwardchar,
    /* ! */ z_undefinedkey,
    /* " */ z_visetbuffer,
    /* # */ z_poundinsert,
    /* $ */ z_viendofline,
    /* % */ z_vimatchbracket,
    /* & */ z_undefinedkey,
    /* ' */ z_vigotomarkline,
    /* ( */ z_undefinedkey,
    /* ) */ z_undefinedkey,
    /* * */ z_undefinedkey,
    /* + */ z_vidownlineorhistory,
    /* , */ z_virevrepeatfind,
    /* - */ z_viuplineorhistory,
    /* . */ z_virepeatchange,
    /* / */ z_vihistorysearchbackward,
    /* 0 */ z_vidigitorbeginningofline,
    /* 1 */ z_digitargument,
    /* 2 */ z_digitargument,
    /* 3 */ z_digitargument,
    /* 4 */ z_digitargument,
    /* 5 */ z_digitargument,
    /* 6 */ z_digitargument,
    /* 7 */ z_digitargument,
    /* 8 */ z_digitargument,
    /* 9 */ z_digitargument,
    /* : */ z_undefinedkey,
    /* ; */ z_virepeatfind,
    /* < */ z_viunindent,
    /* = */ z_listchoices,
    /* > */ z_viindent,
    /* ? */ z_vihistorysearchforward,
    /* @ */ z_undefinedkey,
    /* A */ z_viaddeol,
    /* B */ z_vibackwardblankword,
    /* C */ z_vichangeeol,
    /* D */ z_vikilleol,
    /* E */ z_viforwardblankwordend,
    /* F */ z_vifindprevchar,
    /* G */ z_vifetchhistory,
    /* H */ z_undefinedkey,
    /* I */ z_viinsertbol,
    /* J */ z_vijoin,
    /* K */ z_undefinedkey,
    /* L */ z_undefinedkey,
    /* M */ z_undefinedkey,
    /* N */ z_virevrepeatsearch,
    /* O */ z_viopenlineabove,
    /* P */ z_viputbefore,
    /* Q */ z_undefinedkey,
    /* R */ z_vireplace,
    /* S */ z_vichangewholeline,
    /* T */ z_vifindprevcharskip,
    /* U */ z_undefinedkey,
    /* V */ z_undefinedkey,
    /* W */ z_viforwardblankword,
    /* X */ z_vibackwarddeletechar,
    /* Y */ z_viyankwholeline,
    /* Z */ z_undefinedkey,
    /* [ */ z_undefinedkey,
    /* \ */ z_undefinedkey,
    /* ] */ z_undefinedkey,
    /* ^ */ z_vifirstnonblank,
    /* _ */ z_undefinedkey,
    /* ` */ z_vigotomark,
    /* a */ z_viaddnext,
    /* b */ z_vibackwardword,
    /* c */ z_vichange,
    /* d */ z_videlete,
    /* e */ z_viforwardwordend,
    /* f */ z_vifindnextchar,
    /* g */ z_undefinedkey,
    /* h */ z_vibackwardchar,
    /* i */ z_viinsert,
    /* j */ z_downlineorhistory,
    /* k */ z_uplineorhistory,
    /* l */ z_viforwardchar,
    /* m */ z_visetmark,
    /* n */ z_virepeatsearch,
    /* o */ z_viopenlinebelow,
    /* p */ z_viputafter,
    /* q */ z_undefinedkey,
    /* r */ z_vireplacechars,
    /* s */ z_visubstitute,
    /* t */ z_vifindnextcharskip,
    /* u */ z_viundochange,
    /* v */ z_undefinedkey,
    /* w */ z_viforwardword,
    /* x */ z_videletechar,
    /* y */ z_viyank,
    /* z */ z_undefinedkey,
    /* { */ z_undefinedkey,
    /* | */ z_vigotocolumn,
    /* } */ z_undefinedkey,
    /* ~ */ z_viswapcase,
    /* ^? */ z_vibackwardchar,
};
int ntvirtualbind[24 + 8 + 2] =
{
    /* F1 */ z_undefinedkey,
    /* F2 */ z_undefinedkey,
    /* F3 */ z_undefinedkey,
    /* F4 */ z_undefinedkey,
    /* F5 */ z_undefinedkey,
    /* F6 */ z_undefinedkey,
    /* F7 */ z_undefinedkey,
    /* F8 */ z_undefinedkey,
    /* F9 */ z_undefinedkey,
    /* F10 */ z_undefinedkey,
    /* F11 */ z_undefinedkey,
    /* F12 */ z_undefinedkey,
    /* F13 */ z_undefinedkey,
    /* F14 */ z_undefinedkey,
    /* F15 */ z_undefinedkey,
    /* F16 */ z_undefinedkey,
    /* F17 */ z_undefinedkey,
    /* F18 */ z_undefinedkey,
    /* F19 */ z_undefinedkey,
    /* F20 */ z_undefinedkey,
    /* F21 */ z_undefinedkey,
    /* F22 */ z_undefinedkey,
    /* F23 */ z_undefinedkey,
    /* F24 */ z_undefinedkey,
    /* Pgup */ z_undefinedkey,
    /* Pgdn */ z_undefinedkey,
    /* end */ z_endofline,
    /* home */ z_beginningofline,
    /* left-arrow*/ z_backwardchar,
    /* up-arrow */ z_uplineorhistory,
    /* right-arrow */ z_forwardchar,
    /* down-arrow */ z_downlineorhistory,
    /* Ins */ z_overwritemode,
    /* Del */ z_deletechar,
};
