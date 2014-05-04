package Compass::Points;

use strict;
use warnings;
use open qw( :std :utf8 );

our $VERSION = '0.01';

my @FIELDS;
my %FIELDS;
my @DATA;
my %DATA;

# initialize from data section
while ( <DATA> ) {
	last if m!\A__END__\b!;	# stop on end marker
	chomp;			# remove newline
	s![ ]*\t[ ]*!\t!g;	# clean up trailing spaces

	# split row into multiple parts
	my @row = split( m!\t! );

	# remove degree sign
	s!°\z!! for @row;

	# bind to wind class for stringification and accessors
	my $row = bless( \@row, __PACKAGE__ . "::Wind" );

	# add row as separate columns
	push( @DATA, $row );

	# get header from first line
	if ( @DATA == 1 ) {
		# list of field names
		@FIELDS = @row;
		# mapping from name to offset
		%FIELDS = map +( $FIELDS[ $_ ], $_ ), 0 .. $#FIELDS;
	}

	# index specific fields
	for my $field ( qw( name abbr ) ) {
		# lower case name
		my $key = lc( $row[ $FIELDS{ $field } ] );

		# point from key per field to row
		$DATA{ $field }{ $key } = $row;
	}
}

# abbr -> Compass::Points::Wind
sub abbr
{
	my $class = shift;
	my $abbr = lc( shift // "" );

	return undef
		unless exists( $DATA{abbr}{ $abbr } );

	return $DATA{abbr}{ $abbr };
}

# id -> Compass::Points::Wind
sub id
{
	my $class = shift;
	my $id = shift;

	return undef
		if $id > @DATA;

	return $DATA[ $id ];
}

# val -> Compass::Points::Wind
sub val
{
	my $class = shift;
	my $val = shift;
	my ( $data ) = grep +(
		$_->[ $FIELDS{id} ] ne "id" &&
		$val >= $_->[ $FIELDS{low} ] &&
		$val <= $_->[ $FIELDS{high} ]
	), @DATA;

	return $data;
}

# build mapping method for every field
for my $n ( 0 .. $#FIELDS ) {
	# different inputs
	for my $type ( qw( abbr val ) ) {
		# input2output name
		my $sub = $type . "2" . $FIELDS[$n];

		no strict "refs";

		*$sub = sub {
			local *__ANON__ = __PACKAGE__ . "::" . $sub;

			return undef
				unless my $data = shift->$type( @_ );

			return $data->[ $n ];
		};
	}

	# accessors for wind class
	my $method = __PACKAGE__ . "::Wind::$FIELDS[$n]";

	no strict "refs";

	*$method = sub {
		local *__ANON__ = $method;

		return shift->[ $n ];
	};

}

# namespace for stringification support and accessors
{
	package Compass::Points::Wind;

	use overload
	    '""'	=> \&to_string
	;

	sub to_string
	{
		return shift->[ $FIELDS{abbr} ];
	}

	1;
}

1;

__DATA__
id 	name 	abbr 	trad 	low 	mid 	high
1 	North 	N 	Tramontana 	354.38° 	0.00° 	5.62°
2 	North by east 	NbE 	Qto Tramontana verso Greco 	5.63° 	11.25° 	16.87°
3 	North-northeast 	NNE 	Greco-Tramontana 	16.88° 	22.50° 	28.12°
4 	Northeast by north 	NEbN 	Qto Greco verso Tramontana 	28.13° 	33.75° 	39.37°
5 	Northeast 	NE 	Greco 	39.38° 	45.00° 	50.62°
6 	Northeast by east 	NEbE 	Qto Greco verso Levante 	50.63° 	56.25° 	61.87°
7 	East-northeast 	ENE 	Greco-Levante 	61.88° 	67.50° 	73.12°
8 	East by north 	EbN 	Qto Levante verso Greco 	73.13° 	78.75° 	84.37°
9 	East 	E 	Levante 	84.38° 	90.00° 	95.62°
10 	East by south 	EbS 	Qto Levante verso Scirocco 	95.63° 	101.25° 	106.87°
11 	East-southeast 	ESE 	Levante-Scirocco 	106.88° 	112.50° 	118.12°
12 	Southeast by east 	SEbE 	Qto Scirocco verso Levante 	118.13° 	123.75° 	129.37°
13 	Southeast 	SE 	Scirocco 	129.38° 	135.00° 	140.62°
14 	Southeast by south 	SEbS 	Qto Scirocco verso Ostro 	140.63° 	146.25° 	151.87°
15 	South-southeast 	SSE 	Ostro-Scirocco 	151.88° 	157.50° 	163.12°
16 	South by east 	SbE 	Qto Ostro verso Scirocco 	163.13° 	168.75° 	174.37°
17 	South 	S 	Ostro 	174.38° 	180.00° 	185.62°
18 	South by west 	SbW 	Qto Ostro verso Libeccio 	185.63° 	191.25° 	196.87°
19 	South-southwest 	SSW 	Ostro-Libeccio 	196.88° 	202.50° 	208.12°
20 	Southwest by south 	SWbS 	Qto Libeccio verso Ostro 	208.13° 	213.75° 	219.37°
21 	Southwest 	SW 	Libeccio 	219.38° 	225.00° 	230.62°
22 	Southwest by west 	SWbW 	Qto Libeccio verso Ponente 	230.63° 	236.25° 	241.87°
23 	West-southwest 	WSW 	Ponente-Libeccio 	241.88° 	247.50° 	253.12°
24 	West by south 	WbS 	Qto Ponente verso Libeccio 	253.13° 	258.75° 	264.37°
25 	West 	W 	Ponente 	264.38° 	270.00° 	275.62°
26 	West by north 	WbN 	Qto Ponente verso Maestro 	275.63° 	281.25° 	286.87°
27 	West-northwest 	WNW 	Maestro-Ponente 	286.88° 	292.50° 	298.12°
28 	Northwest by west 	NWbW 	Qto Maestro verso Ponente 	298.13° 	303.75° 	309.37°
29 	Northwest 	NW 	Maestro 	309.38° 	315.00° 	320.62°
30 	Northwest by north 	NWbN 	Qto Maestro verso Tramontana 	320.63° 	326.25° 	331.87°
31 	North-northwest 	NNW 	Maestro-Tramontana 	331.88° 	337.50° 	343.12°
32 	North by west 	NbW 	Qto Tramontana verso Maestro 	343.13° 	348.75° 	354.37°
__END__

=head1 NAME

Compass::Points - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Compass::Points;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Compass::Points, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>simon@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

