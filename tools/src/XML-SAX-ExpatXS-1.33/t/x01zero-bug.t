use Test;
BEGIN { plan tests => 1 }
use XML::SAX::ExpatXS;

my $handler = TestH->new();
my $parser = XML::SAX::ExpatXS->new( Handler => $handler );

my $xml =<<_xml_;
<foo>0</foo>
_xml_

$parser->parse_string($xml);

#warn "[$handler->{data}]";
ok($handler->{data} eq '0');

package TestH;
#use Devel::Peek;

sub new { bless {data => ''}, shift }


sub characters {
    my ($self, $char) = @_;
    #warn("Char:$char->{Data}\n");
    #Dump($char);
    $self->{data} .= $char->{Data};
}
