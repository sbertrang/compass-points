package Compass::Points;

use strict;
use warnings;

our $VERSION = "0.01";

our @FIELDS = qw( abbr name );
our @NAMES = (
        [ N	=> "North"		],
        [ NbE	=> "North by east"	],
        [ NNE	=> "North-northeast"	],
        [ NEbN	=> "Northeast by north"	],
        [ NE	=> "Northeast"		],
        [ NEbE	=> "Northeast by east"	],
        [ ENE	=> "East-northeast"	],
        [ EbN	=> "East by north"	],
        [ E	=> "East"		],
        [ EbS	=> "East by south"	],
        [ ESE	=> "East-southeast"	],
        [ SEbE	=> "Southeast by east"	],
        [ SE	=> "Southeast"		],
        [ SEbS	=> "Southeast by south"	],
        [ SSE	=> "South-southeast"	],
        [ SbE	=> "South by east"	],
        [ S	=> "South"		],
        [ SbW	=> "South by west"	],
        [ SSW	=> "South-southwest"	],
        [ SWbS	=> "Southwest by south"	],
        [ SW	=> "Southwest"		],
        [ SWbW	=> "Southwest by west"	],
        [ WSW	=> "West-southwest"	],
        [ WbS	=> "West by south"	],
        [ W	=> "West"		],
        [ WbN	=> "West by north"	],
        [ WNW	=> "West-northwest"	],
        [ NWbW	=> "Northwest by west"	],
        [ NW	=> "Northwest"		],
        [ NWbN	=> "Northwest by north"	],
        [ NNW	=> "North-northwest"	],
        [ NbW	=> "North by west"	],
);
our @GROUP;	# separate groups to assign different degree values
our @INDEX;	# index per group
our @MAP;	# mapping for easy access

for my $n ( 0 .. 3 ) {
	my $slice = 360 / ( 2 ** ( 2 + $n ) );		# 90, 45, 22.5, 11.25
	my $mod = 2 ** ( 3 - $n );			# 8, 4, 2, 1
	my @offs = grep $_ % $mod == 0, 0 .. $#NAMES;	# 0,8,16,24 0,4,8,12,...

	$GROUP[ $n ] = bless( [], __PACKAGE__ );

	for my $m ( 0 .. $#offs ) {
		my @entry = @{ $NAMES[ $offs[ $m ] ] };

		for my $key ( map lc, @entry ) {
			$key =~ s![^a-z]!!g;

			$INDEX[ $n ]{ $key } = \@entry;
		}

		$entry[ 2 ] = $m * $slice;

		$GROUP[ $n ][ $m ] = \@entry;
	}

	$MAP[ $_ ] = $n for @MAP .. $#offs;
}

sub new
{
	my $class = shift;
	my $number = shift || 16;

	$number = @{ $GROUP[ $#GROUP ] }
		if $number > @{ $GROUP[ $#GROUP ] };

	return $GROUP[ $MAP[ $number - 1 ] ];
}

for my $offset ( 0 .. $#FIELDS ) {
	my $deg2sub = "deg2$FIELDS[ $offset ]";
	my $sub2deg = "$FIELDS[ $offset ]2deg";

	no strict qw( refs );

	*$deg2sub = sub {
		my $self = shift;
		my $deg = abs( shift || 0 );

		$deg -= 360 while $deg > 360;

		my $slice = 360 / @$self;
		my $index = ( $deg + $slice / 2 ) / $slice;

		return $self->[ $index ][ $offset ];
	};

	*$sub2deg = sub {
		my $self = shift;
		my $key = lc( shift || "" );
		my $index = $INDEX[ $MAP[ @$self - 1 ] ];

		$key =~ s![^a-z]!!g;

		return exists( $index->{ $key } )
			     ? $index->{ $key }[ 2 ]
		     	     : undef
		;
	};
}

1;

__END__

=head1 NAME

Compass::Points - Convert between compass point names, abbreviations and values

=head1 SYNOPSIS

  use Compass::Points;
  my $points = Compass::Points->new();
  my $deg = $points->abbr2deg( "NNE" );

=head1 DESCRIPTION

This module converts compass point names and abbreviations to degrees
and vice versa.
It supports four different compass point systems: 4, 8, 16 and 32.
The default is 16 and can be used for wind compass usage.

=head1 METHODS

=head2 new( [ $points ] )

Returns a Compass::Points object for the number of points (defaults to 16).

=head2 deg2abbr( $degree )

Takes a degree value and returns the corresponding abbreviation for the
matching wind name.

=head2 deg2name( $degree )

Same as deg2abbr() but returns the full wind name.

=head2 abbr2deg( $abbreviation )

Given a wind name abbreviation returns the degree of the points object.

=head2 name2deg( $name )

Same as abbr2deg() but takes full wind names.

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Points_of_the_compass>

=head1 AUTHOR

Simon Bertrang, E<lt>janus@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Simon Bertrang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

