use strict;
use warnings;
use Test::More tests => 8;
use MIME::Words qw(:all);

is(encode_mimeword('wookie', 'Q', 'ISO-8859-1'),
    '=?ISO-8859-1?Q?wookie?=');
is(encode_mimeword('Fran�ois', 'Q', 'ISO-8859-1'),
    '=?ISO-8859-1?Q?Fran=E7ois?=');
is(encode_mimewords('Me and Fran�ois'), 'Me and =?ISO-8859-1?Q?Fran=E7ois?=');
is(decode_mimewords('Me and =?ISO-8859-1?Q?Fran=E7ois?='),
   'Me and Fran�ois');

is(encode_mimewords('Me and Fran�ois and Fran�ois    and Fran�ois       and Fran�ois               and Fran�ois                      and Fran�ois'),
   'Me and =?ISO-8859-1?Q?Fran=E7ois=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois?=');


is(decode_mimewords('Me and =?ISO-8859-1?Q?Fran=E7ois=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois?='),
   'Me and Fran�ois and Fran�ois    and Fran�ois       and Fran�ois               and Fran�ois                      and Fran�ois');


is(encode_mimewords('Me and Fran�ois and Fran�ois    and Fran�ois       and Fran�ois               and Fran�ois                      and Fran�ois and wookie and wookie and wookie and wookie and wookie and wookie'),
   'Me and =?ISO-8859-1?Q?Fran=E7ois=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20?=and wookie and wookie and wookie and wookie and wookie and wookie');

is(decode_mimewords('Me and =?ISO-8859-1?Q?Fran=E7ois=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20?=and =?ISO-8859-1?Q?Fran=E7ois=20?=and wookie and wookie and wookie and wookie and wookie and wookie'),
   'Me and Fran�ois and Fran�ois    and Fran�ois       and Fran�ois               and Fran�ois                      and Fran�ois and wookie and wookie and wookie and wookie and wookie and wookie');
