##---------------------------------------------------------------------------##
##  File:
##	$Id: mhdb.pl,v 2.43 2011/01/03 06:42:39 ehood Exp $
##  Author:
##      Earl Hood       mhonarc@mhonarc.org
##  Description:
##      MHonArc library defining routines for outputing database.
##---------------------------------------------------------------------------##
##    MHonArc -- Internet mail-to-HTML converter
##    Copyright (C) 1995-2002	Earl Hood, mhonarc@mhonarc.org
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
##    02111-1307, USA
##---------------------------------------------------------------------------##

use File::Basename;

my $_true  = "1";
my $_false = "0";

##---------------------------------------------------------------------------
##	output_db() spits out the state of mhonarc to a file.  This
##	(database) file contains information to update mail threading
##	when incremental adding is done.  The actual database file
##	is a Perl program defining all the internal data structures.
##	All mhonarc does is 'require' it when updating.  This is
##	faster than having to extract the data from message files
##	-- which would require opening every file to perform
##	updates.
##
sub output_db {
    my($pathname) = shift;
    my($dirname) = dirname($pathname);
    my($db, $tmpfile) = file_temp('dbXXXXXXXXXX', $dirname);

    ## Invoke pre-save callback
    if (defined($CBDbPreSave) && defined(&$CBDbPreSave)) {
	return  unless &$CBDbPreSave($pathname, $tmpfile);
    }

# CPU2017
#    if (!open($db, ">$tmpfile")) {
    if (!($db = file_create($tmpfile))) {
	warn qq/ERROR: Unable to create "$tmpfile": $!\n/;
	return 0;
    }
# CPU2017
    #binmode($db);  # Unix text format okay for Perl source on Windog

# CPU2017
#print $db "## MHonArcDB (Automatically generated by MHonArc)\n";
push @$db, "## MHonArcDB (Automatically generated by MHonArc)\n";
print_var($db,'DbVERSION',     \$VERSION);

## Meta-data
print_var($db,'ContentType', \%ContentType);
print_var($db,'Date',        \%Date);
print_var($db,'Derived',     \%Derived);
print_var($db,'FollowOld',   \%Follow);
print_var($db,'From',        \%From);
print_var($db,'DoFromName',  \$DoFromName);
print_var($db,'FromName',    \%FromName)  if $DoFromName;
print_var($db,'DoFromAddr',  \$DoFromAddr);
print_var($db,'FromAddr',    \%FromAddr)  if $DoFromAddr;
print_var($db,'IndexNum',    \%IndexNum);
print_var($db,'MsgId',       \%MsgId);
print_var($db,'Refs',        \%Refs);
print_var($db,'Subject',     \%Subject);
print_var($db,'Time',        \%Time);
print_var($db,'ExtraHFields',\@ExtraHFields);
print_var($db,'ExtraHFields',\%ExtraHFields);
print_var($db,'TListOrder',  \@TListOrder);
print_var($db,'LastMsgNum',  \$LastMsgNum);
print_var($db,'MAXPGS',      \$MAXPGS);
print_var($db,'MULTIIDX',    \$MULTIIDX);
print_var($db,'NumOfMsgs',   \$NumOfMsgs);
print_var($db,'NumOfPages',  \$NumOfPages);
print_var($db,'NumOfPrintedPages',\$NumOfPrintedPages);
print_var($db,'PrintXComments',\$PrintXComments);
print_var($db,'SaveRsrcs',   \$SaveRsrcs);

if ($SaveRsrcs) {

## Resources
print_var($db,'CustomRcVars',\%CustomRcVars);
print_var($db,'FieldODefs',  \%FieldODefs);
print_var($db,'HFieldsExc',  \%HFieldsExc);
print_var($db,'HeadFields',  \%HeadFields);
print_var($db,'HeadHeads',   \%HeadHeads);
print_var($db,'Icons',       \%Icons);
print_var($db,'UDerivedFile',\%UDerivedFile);
print_var($db,'ZoneUD',      \%ZoneUD);

unless ($IsDefault{'CHARSETALIASES'} && !$SaveMIMECharsetAliases) {
    print_var($db,'SaveMIMECharsetAliases', \$_true);
    print_var($db,'readmail::MIMECharsetAliases',
		    \%readmail::MIMECharsetAliases);
}
unless ($IsDefault{'CHARSETCONVERTERS'} && !$SaveMIMECharSetConverters) {
    print_var($db,'SaveMIMECharSetConverters', \$_true);
    print_var($db,'readmail::MIMECharSetConverters',
		    \%readmail::MIMECharSetConverters);
    print_var($db,'readmail::MIMECharSetConvertersSrc',
		    \%readmail::MIMECharSetConvertersSrc);
}
unless ($readmail::TextDefCharset eq 'us-ascii') {
    print_var($db,'readmail::TextDefCharset',
		  \$readmail::TextDefCharset);
}
unless ($IsDefault{'TEXTENCODE'} && !$SaveTextEncode) {
    print_var($db,'SaveTextEncode', \$_true);
    print_var($db,'readmail::TextEncode',
		    \$readmail::TextEncode);
    print_var($db,'readmail::TextEncoderFunc',
		    \$readmail::TextEncoderFunc);
    print_var($db,'readmail::TextEncoderSrc',
		    \$readmail::TextEncoderSrc);
}
unless ($IsDefault{'MIMEDECODERS'} && !$SaveMIMEDecoders) {
    print_var($db,'SaveMIMEDecoders', \$_true);
    print_var($db,'readmail::MIMEDecoders',
		    \%readmail::MIMEDecoders);
    print_var($db,'readmail::MIMEDecodersSrc',
		    \%readmail::MIMEDecodersSrc);
}
unless ($IsDefault{'MIMEFILTERS'} && !$SaveMIMEFilters) {
    print_var($db,'SaveMIMEFilters', \$_true);
    print_var($db,'readmail::MIMEFilters',
		    \%readmail::MIMEFilters);
    print_var($db,'readmail::MIMEFiltersSrc',
		    \%readmail::MIMEFiltersSrc);
}
unless ($IsDefault{'MIMEARGS'} && !$SaveMIMEFiltersArgs) {
    print_var($db,'SaveMIMEFiltersArgs', \$_true);
    print_var($db,'readmail::MIMEFiltersArgs',
		    \%readmail::MIMEFiltersArgs);
}
if (%readmail::MIMEExcs) {
    print_var($db,'readmail::MIMEExcs',
		    \%readmail::MIMEExcs)
		    unless $IsDefault{'MIMEEXCS'};
}
if (%readmail::MIMEIncs) {
    print_var($db,'readmail::MIMEIncs',
		    \%readmail::MIMEIncs)
		    unless $IsDefault{'MIMEINCS'};
}
unless ($IsDefault{'MIMEALTPREFS'} && !$SaveMIMEAltPrefs) {
    print_var($db,'SaveMIMEAltPrefs', \$_true);
    print_var($db,'MIMEAltPrefs',
		    \@MIMEAltPrefs);
}

print_var($db,'DateFields', \@DateFields) unless $IsDefault{'DATEFIELDS'};
print_var($db,'FieldOrder', \@FieldOrder);
print_var($db,'FromFields', \@FromFields) unless $IsDefault{'FROMFIELDS'};
print_var($db,'Months',     \@Months)     if scalar(@Months);
print_var($db,'months',     \@months)     if scalar(@months);
print_var($db,'OtherIdxs',  \@OtherIdxs)  if scalar(@OtherIdxs);
print_var($db,'PerlINC',    \@PerlINC)    if scalar(@PerlINC);
print_var($db,'Weekdays',   \@Weekdays)   if scalar(@Weekdays);
print_var($db,'weekdays',   \@weekdays)   if scalar(@weekdays);

## I should use a hash for this stuff instead of individual variables.
## A legacy of Perl 4 days and a program getting larger than expected.

print_var($db,'AddressModify',  \$AddressModify)
				unless $IsDefault{'AddressModify'};
print_var($db,'AddrModifyBodies', \$AddrModifyBodies);
print_var($db,'AttachmentDir',  \$AttachmentDir);
print_var($db,'AttachmentUrl',  \$AttachmentUrl);
print_var($db,'CheckNoArchive', \$CheckNoArchive);
print_var($db,'DOCURL',         \$DOCURL);
print_var($db,'NODOC',          \$NODOC);
print_var($db,'DecodeHeads',    \$DecodeHeads);
print_var($db,'DoFolRefs',      \$DoFolRefs);
print_var($db,'ExpireDate',     \$ExpireDate);
print_var($db,'ExpireTime',     \$ExpireTime);
print_var($db,'FastTempFiles',  \$FastTempFiles);
print_var($db,'FollowSymlinks', \$FollowSymlinks);
print_var($db,'FROM',           \$FROM);
print_var($db,'GMTDateFmt',     \$GMTDateFmt);
print_var($db,'GzipExe',        \$GzipExe);
print_var($db,'GzipFiles',      \$GzipFiles);
print_var($db,'GzipLinks',      \$GzipLinks);
print_var($db,'HtmlExt',        \$HtmlExt);
print_var($db,'IconURLPrefix',  \$IconURLPrefix);
print_var($db,'IDXSIZE',        \$IDXSIZE);
print_var($db,'KeepOnRmm',      \$KeepOnRmm);
print_var($db,'Lang',           \$Lang);
print_var($db,'LocalDateFmt',   \$LocalDateFmt);
print_var($db,'MAILTOURL',      \$MAILTOURL)  unless $IsDefault{'MAILTOURL'};
print_var($db,'MAIN',           \$MAIN);
print_var($db,'MAXSIZE',        \$MAXSIZE);
print_var($db,'MHPATTERN',      \$MHPATTERN);
print_var($db,'MODTIME',        \$MODTIME);
print_var($db,'MSGFOOT',        \$MSGFOOT);
print_var($db,'MsgGMTDateFmt',  \$MsgGMTDateFmt);
print_var($db,'MSGHEAD',        \$MSGHEAD);
print_var($db,'MsgExcFilter',   \$MsgExcFilter);
print_var($db,'MsgLocalDateFmt',\$MsgLocalDateFmt);
print_var($db,'MsgPrefix',      \$MsgPrefix);
print_var($db,'NewsUrl',        \$NewsUrl)  unless $IsDefault{'NEWSURL'};
print_var($db,'NOMAILTO',       \$NOMAILTO);
print_var($db,'NONEWS',         \$NONEWS);
print_var($db,'NOURL',          \$NOURL);
print_var($db,'NoMsgPgs',       \$NoMsgPgs);
print_var($db,'NoSubjectThreads', \$NoSubjectThreads);
print_var($db,'NoSubjectTxt',   \$NoSubjectTxt);
print_var($db,'NoteDir',        \$NoteDir);
print_var($db,'POSIXstrftime',  \$POSIXstrftime);
print_var($db,'THREAD',         \$THREAD);
print_var($db,'SubArtRxp',      \$SubArtRxp);
print_var($db,'SubReplyRxp',    \$SubReplyRxp);
print_var($db,'SubStripCode',   \$SubStripCode);
print_var($db,'UseLocalTime',   \$UseLocalTime);
print_var($db,'UsingLASTPG',    \$UsingLASTPG);
print_var($db,'VarExp',    	 \$VarExp);

print_var($db,'MSGPGSSMARKUP',  \$MSGPGSSMARKUP);
print_var($db,'IDXPGSSMARKUP',  \$IDXPGSSMARKUP);
print_var($db,'TIDXPGSSMARKUP', \$TIDXPGSSMARKUP);
print_var($db,'SSMARKUP',       \$SSMARKUP);
print_var($db,'SpamMode',       \$SpamMode);

if (!$IsDefault{'TEXTCLIPFUNC'}) {
    print_var($db,'TextClipFunc', \$TextClipFunc);
    print_var($db,'TextClipSrc',  \$TextClipSrc);
};

# Main index resources
print_var($db,'AUTHSORT',     \$AUTHSORT);
print_var($db,'NOSORT',       \$NOSORT);
print_var($db,'REVSORT',      \$REVSORT);
print_var($db,'SUBSORT',      \$SUBSORT);

print_var($db,'AUTHBEG',      \$AUTHBEG) unless $IsDefault{'AUTHBEG'};
print_var($db,'AUTHEND',      \$AUTHEND) unless $IsDefault{'AUTHEND'};
print_var($db,'DAYBEG',       \$DAYBEG) unless $IsDefault{'DAYBEG'};
print_var($db,'DAYEND',       \$DAYEND) unless $IsDefault{'DAYEND'};
print_var($db,'IDXLABEL',     \$IDXLABEL) unless $IsDefault{'IDXLABEL'};
print_var($db,'IDXNAME',      \$IDXNAME);
print_var($db,'IDXPGBEG',     \$IDXPGBEG) unless $IsDefault{'IDXPGBEG'};
print_var($db,'IDXPGEND',     \$IDXPGEND) unless $IsDefault{'IDXPGEND'};
print_var($db,'IDXPREFIX',    \$IDXPREFIX);
print_var($db,'LIBEG',        \$LIBEG) unless $IsDefault{'LIBEG'};
print_var($db,'LIEND',        \$LIEND) unless $IsDefault{'LIEND'};
print_var($db,'LITMPL',       \$LITMPL) unless $IsDefault{'LITMPL'};
print_var($db,'FIRSTPGLINK',  \$FIRSTPGLINK) unless $IsDefault{'FIRSTPGLINK'};
print_var($db,'LASTPGLINK',   \$LASTPGLINK) unless $IsDefault{'LASTPGLINK'};
print_var($db,'NEXTPGLINK',   \$NEXTPGLINK) unless $IsDefault{'NEXTPGLINK'};
print_var($db,'NEXTPGLINKIA', \$NEXTPGLINKIA)
				unless $IsDefault{'NEXTPGLINKIA'};
print_var($db,'PREVPGLINK',   \$PREVPGLINK) unless $IsDefault{'PREVPGLINK'};
print_var($db,'PREVPGLINKIA', \$PREVPGLINKIA)
				unless $IsDefault{'PREVPGLINKIA'};
print_var($db,'SUBJECTBEG',   \$SUBJECTBEG) unless $IsDefault{'SUBJECTBEG'};
print_var($db,'SUBJECTEND',   \$SUBJECTEND) unless $IsDefault{'SUBJECTEND'};
print_var($db,'TITLE',        \$TITLE);

# Thread index resources
print_var($db,'TNOSORT',      \$TNOSORT);
print_var($db,'TREVERSE',     \$TREVERSE);
print_var($db,'TSUBSORT',     \$TSUBSORT);

print_var($db,'TCONTBEG',     \$TCONTBEG) unless $IsDefault{'TCONTBEG'};
print_var($db,'TCONTEND',     \$TCONTEND) unless $IsDefault{'TCONTEND'};
print_var($db,'TFOOT',        \$TFOOT) unless $IsDefault{'TFOOT'};
print_var($db,'THEAD',        \$THEAD) unless $IsDefault{'THEAD'};
print_var($db,'TIDXLABEL',    \$TIDXLABEL) unless $IsDefault{'TIDXLABEL'};
print_var($db,'TIDXNAME',     \$TIDXNAME);
print_var($db,'TIDXPGBEG',    \$TIDXPGBEG) unless $IsDefault{'TIDXPGBEG'};
print_var($db,'TIDXPGEND',    \$TIDXPGEND) unless $IsDefault{'TIDXPGEND'};
print_var($db,'TIDXPREFIX',   \$TIDXPREFIX);
print_var($db,'TINDENTBEG',   \$TINDENTBEG) unless $IsDefault{'TINDENTBEG'};
print_var($db,'TINDENTEND',   \$TINDENTEND) unless $IsDefault{'TINDENTEND'};
print_var($db,'TLEVELS',      \$TLEVELS);
print_var($db,'TLIEND',       \$TLIEND) unless $IsDefault{'TLIEND'};
print_var($db,'TLINONE',      \$TLINONE) unless $IsDefault{'TLINONE'};
print_var($db,'TLINONEEND',   \$TLINONEEND) unless $IsDefault{'TLINONEEND'};
print_var($db,'TLITXT',       \$TLITXT) unless $IsDefault{'TLITXT'};
print_var($db,'TFIRSTPGLINK', \$TFIRSTPGLINK)
				unless $IsDefault{'TFIRSTPGLINK'};
print_var($db,'TLASTPGLINK',  \$TLASTPGLINK)
				unless $IsDefault{'TLASTPGLINK'};
print_var($db,'TNEXTPGLINK',  \$TNEXTPGLINK) unless $IsDefault{'TNEXTPGLINK'};
print_var($db,'TNEXTPGLINKIA',\$TNEXTPGLINKIA)
				unless $IsDefault{'TNEXTPGLINKIA'};
print_var($db,'TPREVPGLINK',  \$TPREVPGLINK) unless $IsDefault{'TPREVPGLINK'};
print_var($db,'TPREVPGLINKIA',\$TPREVPGLINKIA)
				unless $IsDefault{'TPREVPGLINKIA'};
print_var($db,'TSINGLETXT',   \$TSINGLETXT) unless $IsDefault{'TSINGLETXT'};
print_var($db,'TSUBJECTBEG',  \$TSUBJECTBEG) unless $IsDefault{'TSUBJECTBEG'};
print_var($db,'TSUBJECTEND',  \$TSUBJECTEND) unless $IsDefault{'TSUBJECTEND'};
print_var($db,'TSUBLISTBEG',  \$TSUBLISTBEG) unless $IsDefault{'TSUBLISTBEG'};
print_var($db,'TSUBLISTEND',  \$TSUBLISTEND) unless $IsDefault{'TSUBLISTEND'};
print_var($db,'TTITLE',       \$TTITLE);
print_var($db,'TTOPBEG',      \$TTOPBEG) unless $IsDefault{'TTOPBEG'};
print_var($db,'TTOPEND',      \$TTOPEND) unless $IsDefault{'TTOPEND'};

print_var($db,'TSLICESINGLETXT', \$TSLICESINGLETXT)
				unless $IsDefault{'TSLICESINGLETXT'};
print_var($db,'TSLICETOPBEG', \$TSLICETOPBEG)
				unless $IsDefault{'TSLICETOPBEG'};
print_var($db,'TSLICETOPEND', \$TSLICETOPEND)
				unless $IsDefault{'TSLICETOPEND'};
print_var($db,'TSLICESUBLISTBEG', \$TSLICESUBLISTBEG)
				unless $IsDefault{'TSLICESUBLISTBEG'};
print_var($db,'TSLICESUBLISTEND', \$TSLICESUBLISTEND)
				unless $IsDefault{'TSLICESUBLISTEND'};
print_var($db,'TSLICELEVELS', \$TSLICELEVELS)
				unless $IsDefault{'TSLICELEVELS'};
print_var($db,'TSLICELITXT', \$TSLICELITXT)
				unless $IsDefault{'TSLICELITXT'};
print_var($db,'TSLICELIEND', \$TSLICELIEND)
				unless $IsDefault{'TSLICELIEND'};
print_var($db,'TSLICELINONE', \$TSLICELINONE)
				unless $IsDefault{'TSLICELINONE'};
print_var($db,'TSLICELINONEEND', \$TSLICELINONEEND)
				unless $IsDefault{'TSLICELINONEEND'};
print_var($db,'TSLICESUBJECTBEG', \$TSLICESUBJECTBEG)
				unless $IsDefault{'TSLICESUBJECTBEG'};
print_var($db,'TSLICESUBJECTEND', \$TSLICESUBJECTEND)
				unless $IsDefault{'TSLICESUBJECTEND'};
print_var($db,'TSLICEINDENTBEG', \$TSLICEINDENTBEG)
				unless $IsDefault{'TSLICEINDENTBEG'};
print_var($db,'TSLICEINDENTEND', \$TSLICEINDENTEND)
				unless $IsDefault{'TSLICEINDENTEND'};
print_var($db,'TSLICECONTBEG', \$TSLICECONTBEG)
				unless $IsDefault{'TSLICECONTBEG'};
print_var($db,'TSLICECONTEND', \$TSLICECONTEND)
				unless $IsDefault{'TSLICECONTEND'};
print_var($db,'TSLICESINGLETXTCUR', \$TSLICESINGLETXTCUR)
				unless $IsDefault{'TSLICESINGLETXTCUR'};
print_var($db,'TSLICETOPBEGCUR', \$TSLICETOPBEGCUR)
				unless $IsDefault{'TSLICETOPBEGCUR'};
print_var($db,'TSLICETOPENDCUR', \$TSLICETOPENDCUR)
				unless $IsDefault{'TSLICETOPENDCUR'};
print_var($db,'TSLICELITXTCUR', \$TSLICELITXTCUR)
				unless $IsDefault{'TSLICELITXTCUR'};
print_var($db,'TSLICELIENDCUR', \$TSLICELIENDCUR)
				unless $IsDefault{'TSLICELIENDCUR'};

## Other resources
print_var($db,'BOTLINKS',     \$BOTLINKS) unless $IsDefault{'BOTLINKS'};
print_var($db,'FIELDSBEG',    \$FIELDSBEG) unless $IsDefault{'FIELDSBEG'};
print_var($db,'FIELDSEND',    \$FIELDSEND) unless $IsDefault{'FIELDSEND'};
print_var($db,'FLDBEG',       \$FLDBEG) unless $IsDefault{'FLDBEG'};
print_var($db,'FLDEND',       \$FLDEND) unless $IsDefault{'FLDEND'};
print_var($db,'FOLUPBEGIN',   \$FOLUPBEGIN) unless $IsDefault{'FOLUPBEGIN'};
print_var($db,'FOLUPEND',     \$FOLUPEND) unless $IsDefault{'FOLUPEND'};
print_var($db,'FOLUPLITXT',   \$FOLUPLITXT) unless $IsDefault{'FOLUPLITXT'};
print_var($db,'HEADBODYSEP',  \$HEADBODYSEP) unless $IsDefault{'HEADBODYSEP'};
print_var($db,'LABELBEG',     \$LABELBEG) unless $IsDefault{'LABELBEG'};
print_var($db,'LABELEND',     \$LABELEND) unless $IsDefault{'LABELEND'};
print_var($db,'MSGBODYEND',   \$MSGBODYEND) unless $IsDefault{'MSGBODYEND'};
print_var($db,'MSGIDLINK',    \$MSGIDLINK) unless $IsDefault{'MSGIDLINK'};
print_var($db,'MSGPGBEG',     \$MSGPGBEG) unless $IsDefault{'MSGPGBEG'};
print_var($db,'MSGPGEND',     \$MSGPGEND) unless $IsDefault{'MSGPGEND'};
print_var($db,'NEXTBUTTON',   \$NEXTBUTTON) unless $IsDefault{'NEXTBUTTON'};
print_var($db,'NEXTBUTTONIA', \$NEXTBUTTONIA)
				unless $IsDefault{'NEXTBUTTONIA'};
print_var($db,'NEXTLINK',     \$NEXTLINK) unless $IsDefault{'NEXTLINK'};
print_var($db,'NEXTLINKIA',   \$NEXTLINKIA) unless $IsDefault{'NEXTLINKIA'};
print_var($db,'NOTE',         \$NOTE) unless $IsDefault{'NOTE'};
print_var($db,'NOTEIA',       \$NOTEIA) unless $IsDefault{'NOTEIA'};
print_var($db,'NOTEICON',     \$NOTEICON) unless $IsDefault{'NOTEICON'};
print_var($db,'NOTEICONIA',   \$NOTEICONIA) unless $IsDefault{'NOTEICONIA'};
print_var($db,'PREVBUTTON',   \$PREVBUTTON) unless $IsDefault{'PREVBUTTON'};
print_var($db,'PREVBUTTONIA', \$PREVBUTTONIA)
				unless $IsDefault{'PREVBUTTONIA'};
print_var($db,'PREVLINK',     \$PREVLINK) unless $IsDefault{'PREVLINK'};
print_var($db,'PREVLINKIA',   \$PREVLINKIA) unless $IsDefault{'PREVLINKIA'};
print_var($db,'REFSBEGIN',    \$REFSBEGIN) unless $IsDefault{'REFSBEGIN'};
print_var($db,'REFSEND',      \$REFSEND) unless $IsDefault{'REFSEND'};
print_var($db,'REFSLITXT',    \$REFSLITXT) unless $IsDefault{'REFSLITXT'};
print_var($db,'SUBJECTHEADER',\$SUBJECTHEADER)
				unless $IsDefault{'SUBJECTHEADER'};
print_var($db,'TNEXTBUTTON',  \$TNEXTBUTTON) unless $IsDefault{'TNEXTBUTTON'};
print_var($db,'TNEXTBUTTONIA',\$TNEXTBUTTONIA)
				unless $IsDefault{'TNEXTBUTTONIA'};
print_var($db,'TNEXTINBUTTON',  \$TNEXTINBUTTON)
				unless $IsDefault{'TNEXTINBUTTON'};
print_var($db,'TNEXTINBUTTONIA',  \$TNEXTINBUTTONIA)
				unless $IsDefault{'TNEXTINBUTTONIA'};
print_var($db,'TNEXTINLINK',  \$TNEXTINLINK)
				unless $IsDefault{'TNEXTINLINK'};
print_var($db,'TNEXTINLINKIA',  \$TNEXTINLINKIA)
				unless $IsDefault{'TNEXTINLINKIA'};
print_var($db,'TNEXTLINK',    \$TNEXTLINK) unless $IsDefault{'TNEXTLINK'};
print_var($db,'TNEXTLINKIA',  \$TNEXTLINKIA) unless $IsDefault{'TNEXTLINKIA'};
print_var($db,'TOPLINKS',     \$TOPLINKS) unless $IsDefault{'TOPLINKS'};
print_var($db,'TPREVBUTTON',  \$TPREVBUTTON) unless $IsDefault{'TPREVBUTTON'};
print_var($db,'TPREVBUTTONIA',\$TPREVBUTTONIA)
				unless $IsDefault{'TPREVBUTTONIA'};
print_var($db,'TPREVINBUTTON',  \$TPREVINBUTTON)
				unless $IsDefault{'TPREVINBUTTON'};
print_var($db,'TPREVINBUTTONIA',  \$TPREVINBUTTONIA)
				unless $IsDefault{'TPREVINBUTTONIA'};
print_var($db,'TPREVINLINK',  \$TPREVINLINK)
				unless $IsDefault{'TPREVINLINK'};
print_var($db,'TPREVINLINKIA',  \$TPREVINLINKIA)
				unless $IsDefault{'TPREVINLINKIA'};
print_var($db,'TPREVLINK',    \$TPREVLINK) unless $IsDefault{'TPREVLINK'};
print_var($db,'TPREVLINKIA',  \$TPREVLINKIA) unless $IsDefault{'TPREVLINKIA'};
print_var($db,'TSLICEBEG',    \$TSLICEBEG) unless $IsDefault{'TSLICEBEG'};
print_var($db,'TSLICEEND',    \$TSLICEEND) unless $IsDefault{'TSLICEEND'};
print_var($db,'TTOPBUTTON',   \$TTOPBUTTON) unless $IsDefault{'TTOPBUTTON'};
print_var($db,'TTOPBUTTONIA', \$TTOPBUTTONIA) unless $IsDefault{'TTOPBUTTONIA'};
print_var($db,'TENDBUTTON',   \$TENDBUTTON) unless $IsDefault{'TENDBUTTON'};
print_var($db,'TENDBUTTONIA', \$TENDBUTTONIA) unless $IsDefault{'TENDBUTTONIA'};
print_var($db,'TTOPLINK',     \$TTOPLINK) unless $IsDefault{'TTOPLINK'};
print_var($db,'TTOPLINKIA',   \$TTOPLINKIA) unless $IsDefault{'TTOPLINKIA'};
print_var($db,'TENDLINK',     \$TENDLINK) unless $IsDefault{'TENDLINK'};
print_var($db,'TENDLINKIA',   \$TENDLINKIA) unless $IsDefault{'TENDLINKIA'};
print_var($db,'TNEXTTOPBUTTON',  \$TNEXTTOPBUTTON)
				unless $IsDefault{'TNEXTTOPBUTTON'};
print_var($db,'TNEXTTOPBUTTONIA',  \$TNEXTTOPBUTTONIA)
				unless $IsDefault{'TNEXTTOPBUTTONIA'};
print_var($db,'TNEXTTOPLINK',  \$TNEXTTOPLINK)
				unless $IsDefault{'TNEXTTOPLINK'};
print_var($db,'TNEXTTOPLINKIA',  \$TNEXTTOPLINKIA)
				unless $IsDefault{'TNEXTTOPLINKIA'};
print_var($db,'TPREVTOPBUTTON',  \$TPREVTOPBUTTON)
				unless $IsDefault{'TPREVTOPBUTTON'};
print_var($db,'TPREVTOPBUTTONIA',  \$TPREVTOPBUTTONIA)
				unless $IsDefault{'TPREVTOPBUTTONIA'};
print_var($db,'TPREVTOPLINK',  \$TPREVTOPLINK)
				unless $IsDefault{'TPREVTOPLINK'};
print_var($db,'TPREVTOPLINKIA',  \$TPREVTOPLINKIA)
				unless $IsDefault{'TPREVTOPLINKIA'};

print_var($db,'DbFilePerms',     \$DbFilePerms);
print_var($db,'FilePerms',       \$FilePerms);
print_var($db,'TSliceNBefore',   \$TSliceNBefore);
print_var($db,'TSliceNAfter',    \$TSliceNAfter);
print_var($db,'TSliceInclusive', \$TSliceInclusive);
print_var($db,'UMASK',	         \$UMASK);

}

    ## Invoke save callback
    if (defined($CBDbSave) && defined(&$CBDbSave)) {
	&$CBDbSave($db);
    }

    ## Make sure file ends with a true value
# CPU2017
    #print $db "1;\n";
    push @$db, "1;\n";

# CPU2017
     file_rename($tmpfile, $pathname);
#    close($db);
#
#    if (!rename($tmpfile, $pathname)) {
#	warn qq/ERROR: Unable to rename "$tmpfile" to "$pathname": $!\n/;
#	return 0;
#    }
#    file_chmod($pathname, $DbFilePermsOct);
    1;
}

##---------------------------------------------------------------------------

sub escape_str {
    my($str) = $_[0];
    $str =~ s/(['\\])/\\$1/g;
    $str;
}

##---------------------------------------------------------------------------

sub print_var {
    my($fh, $name, $ref, $d) = @_;

    if (ref($ref) eq 'SCALAR') {
	if (defined($$ref)) {
# CPU2017
	    #print $fh qq/\$$name='/, escape_str($$ref), qq/'/;
	    push @$fh, qq/\$$name='/. escape_str($$ref). qq/'/;
	} else {
# CPU2017
	    #print $fh '$',$name, '=undef';
	    push @$fh, '$'.$name. '=undef';
	}
# CPU2017
#	print $fh qq/ unless defined(\$$name)/  if $d;
#	print $fh qq/;\n/;
	push @$fh, qq/ unless defined(\$$name)/  if $d;
	push @$fh, qq/;\n/;
	return;
    }

    if (ref($ref) eq 'HASH') {
	my($key, $value, $sep);
	if (defined($name)) {
# CPU2017
	    #print $fh "%$name=(\n";
	    push @$fh, "%$name=(\n";
	    $sep = "\n";
	} else {
# CPU2017
	    #print $fh '{';
	    push @$fh, '{';
	    $sep = "";
	}
	while (($key, $value) = each(%$ref)) {
# CPU2017
	    #print $fh qq/'/, escape_str($key), qq/',/;
	    push @$fh, qq/'/. escape_str($key). qq/',/;
	    if (ref($value)) {
		print_var($fh, undef, $value, 0);
  # CPU2017
		#print $fh ",\n";
		push @$fh, ",\n";
		next;
	    }
	    if (defined($value)) {
  # CPU2017
		#print $fh qq/'/, escape_str($value), qq/',/, $sep;
		push @$fh, qq/'/. escape_str($value). qq/',/. $sep;
	    } else {
  # CPU2017
		#print $fh 'undef,', $sep;
		push @$fh, 'undef,'. $sep;
	    }
	}
	if (defined($name)) {
# CPU2017
	    #print $fh ");\n";
	    push @$fh, ");\n";
	} else {
# CPU2017
	    #print $fh '}';
	    push @$fh, '}';
	}
	return;
    }

    if (ref($ref) eq 'ARRAY') {
	local $_;
	my $sep;
	if (defined($name)) {
# CPU2017
	    #print $fh "\@$name=(\n";
	    push @$fh, "\@$name=(\n";
	    $sep = "\n";
	} else {
# CPU2017
	    #print $fh '[';
	    push @$fh, '[';
	    $sep = "";
	}
	foreach (@$ref) {
	    if (ref($_)) {
		print_var($fh, undef, $_, 0);
  # CPU2017
		#print $fh ",\n";
		push @$fh, ",\n";
		next;
	    }
	    if (defined($_)) {
  # CPU2017
		#print $fh qq/'/, escape_str($_), qq/',/, $sep;
		push @$fh, qq/'/. escape_str($_). qq/',/. $sep;
	    } else {
  # CPU2017
		#print $fh 'undef,', $sep;
		push @$fh, 'undef,'. $sep;
	    }
	}
	if (defined($name)) {
# CPU2017
	    #print $fh ");\n";
	    push @$fh, ");\n";
	} else {
# CPU2017
	    #print $fh ']';
	    push @$fh, ']';
	}
	return;
    }

# CPU2017
#    print $fh qq/\$$name='/, escape_str($ref), qq/'/;
#    print $fh qq/ unless defined(\$$name)/  if $d;
#    print $fh qq/;\n/;
    push @$fh, qq/\$$name='/. escape_str($ref). qq/'/;
    push @$fh, qq/ unless defined(\$$name)/  if $d;
    push @$fh, qq/;\n/;
}

##---------------------------------------------------------------------------##
1;
