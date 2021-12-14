package Business::Tax::ID::PPH21;

use 5.010001;
use strict;
use warnings;

use Exporter::Rinci qw(import);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

my $latest_supported_year = 2022;

our %arg_tp_status = (
    tp_status => {
        summary => 'Taxypayer status',
        description => <<'_',

Taypayer status reflects his/her marital status and affects the amount of
his/her non-taxable income.

_
        schema => ['str*', in=>[
            'TK/0', 'TK/1', 'TK/2', 'TK/3',
            'K/0' , 'K/1',  'K/2',  'K/3',
        ]],
        req => 1,
    },
);

our %arg_year = (
    year => {
        schema => ['int*', min=>1983],
        req => 1,
        pos => 0,
    },
);

our %arg_net_income = (
    net_income => {
        summary => 'Yearly net income',
        schema => ['float*', min=>0],
        req => 1,
    },
);

our %arg_pph21_op = (
    pph21_op => {
        summary => 'Amount of PPh 21 op paid',
        schema => ['float*', min=>0],
        req => 1,
        pos => 1,
    },
);

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Routines to help calculate Indonesian income tax article 21 (PPh pasal 21)',
    description => <<'_',

The law ("undang-undang") for income tax ("pajak penghasilan") in Indonesia is
UU 7/1983 (along with its several amendments, the latest of which is UU
36/2008). This law is comprised of several articles ("pasal"). Article 21
("pasal 21") regulates earned income, which is income generated by
individual/statutory bodies from performed work/services, including: employment
(salary and benefits, as well as severance pay), freelance work, business,
pension, and "jaminan hari tua" (life insurance paid to dependents when a worker
is deceased). Article 21 also regulates some types of passive income, which is
income generated from capital or other non-work sources, including: savings
interests, gifts/lotteries, royalties.

Some other passive income like rent and dividends are regulated in article 23
("pasal 23") instead of article 21. And some articles regulate other aspects or
special cases, e.g. income tax for sales to government agencies/import/specific
industries ("pasal 22"), rules regarding monthly tax payments ("pasal 25"), or
rules regarding work earned in Indonesia by non-citizens ("pasal 26").

This module contains several routines to help calculate income tax article 21.

_

};

$SPEC{get_pph21_op_rates} = {
    v => 1.1,
    summary => 'Get tax rates for PPh21 for individuals ("OP", "orang pribadi")',
    description => <<'_',

PPh21 differentiates rates between individuals ("OP", "orang pribadi") and
statutory bodies ("badan"). Both are progressive. This routine returns the tax
rates for individuals.

Keywords: tax rates, tax brackets.

_
    'description.alt.lang.id_ID' => <<'_',

Kata kunci: tarif pajak, lapisan pajak.

_
    args => {
        %arg_year,
    },
    examples => [
        {args=>{year=>2022}},
    ],
};
sub get_pph21_op_rates {
    my %args = @_;
    my $year = $args{year};
    my $resmeta = {
        'table.fields' => [qw/xmin max rate/],
        'table.field_formats' => [
            undef, undef, ['percent', {sprintf=>'%3.0f%%'}]
        ],
    };
    if ($year >= 2022 && $year <= $latest_supported_year) {
        state $res = [
            200, "OK",
            [
                {                     max=>   60_000_000, rate=>0.05},
                {xmin=>   60_000_000, max=>  250_000_000, rate=>0.15},
                {xmin=>  250_000_000, max=>  500_000_000, rate=>0.25},
                {xmin=>  500_000_000, max=>5_000_000_000, rate=>0.30},
                {xmin=>5_000_000_000,                     rate=>0.35},
            ],
            $resmeta,
        ];
        return $res;
    if ($year >= 2009 && $year <= 2022) {
        state $res = [
            200, "OK",
            [
                {                   max=> 50_000_000, rate=>0.05},
                {xmin=> 50_000_000, max=>250_000_000, rate=>0.15},
                {xmin=>250_000_000, max=>500_000_000, rate=>0.25},
                {xmin=>500_000_000,                   rate=>0.30},
            ],
            $resmeta,
        ];
        return $res;
    } elsif ($year >= 2000 && $year <= 2008) {
        state $res = [
            200, "OK",
            [
                {                   max=> 25_000_000, rate=>0.05},
                {xmin=> 25_000_000, max=> 50_000_000, rate=>0.10},
                {xmin=> 50_000_000, max=>100_000_000, rate=>0.15},
                {xmin=>100_000_000, max=>200_000_000, rate=>0.25},
                {xmin=>200_000_000,                   rate=>0.35},
            ],
            $resmeta,
        ];
        return $res;
    } else {
        return [412, "Year unknown or unsupported (latest supported year is ".
                    "$latest_supported_year)"];
    }
}

# TODO: get_pph21_badan_rates

$SPEC{get_pph21_op_ptkp} = {
    v => 1.1,
    summary => 'Get PPh21 non-taxable income amount ("PTKP") for individuals',
    description => <<'_',

When calculating individual income tax, the net income is subtracted by this
amount first. This means that if a person has income below this amount, he/she
does not need to pay income tax.

_
    'description.alt.lang.id_ID' => <<'_',

Kata kunci: penghasilan tidak kena pajak.

_
    args => {
        %arg_year,
    },
    examples => [
        {args=>{year=>2016}},
    ],
};
sub get_pph21_op_ptkp {
    my %args = @_;

    my $tp_status = $args{tp_status};
    my $year = $args{year};

    my $code_make = sub {
        my ($base, $add) = @_;
        return {
            map {
                ("TK/$_" => $base + $add*$_,
                 "K/$_"  => $base + $add + $add*$_)
            } 0..3
        };
    };

    if ($year >= 2016 && $year <= $latest_supported_year) { # UU PMK: 101/PMK.010/2016
        state $res = [200, "OK", $code_make->( 54_000_000, 4_500_000)];
        return $res;
    } elsif ($year >= 2015 && $year <= 2015) {
        state $res = [200, "OK", $code_make->( 36_000_000, 3_000_000)];
        return $res;
    } elsif ($year >= 2013 && $year <= 2014) {
        state $res = [200, "OK", $code_make->( 24_300_000, 2_025_000)];
        return $res;
    } elsif ($year >= 2009 && $year <= 2012) {
        state $res = [200, "OK", $code_make->( 15_840_000, 1_320_000)];
        return $res;
    } elsif ($year >= 2006 && $year <= 2008) {
        state $res = [200, "OK", $code_make->( 13_200_000, 1_200_000)];
        return $res;
    } elsif ($year >= 2005 && $year <= 2005) {
        state $res = [200, "OK", $code_make->( 12_000_000, 1_200_000)];
        return $res;
    } elsif ($year >= 2001 && $year <= 2004) {
        state $res = [200, "OK", $code_make->(  2_880_000, 1_440_000)];
        return $res;
    } elsif ($year >= 1994 && $year <= 2000) {
        state $res = [200, "OK", $code_make->(  1_728_000,   864_000)];
        return $res;
    } elsif ($year >= 1983 && $year <= 1994) {
        state $res = [200, "OK", $code_make->(    960_000,   480_000)];
        return $res;
    } else {
        return [412, "Year unknown or unsupported (latest supported year is ".
                    "$latest_supported_year)"];
    }
}

sub _min { $_[0] < $_[1] ? $_[0] : $_[1] }

$SPEC{calc_pph21_op} = {
    v => 1.1,
    summary => 'Calculate PPh 21 for individuals ("OP", "orang pribadi")',
    args => {
        %arg_year,
        %arg_tp_status,
        %arg_net_income,
    },
    examples => [
        {
            summary => 'Someone who earns below PTKP',
            args => {year=>2015, tp_status=>'TK/0', net_income=>30_000_000},
        },
        {
            args => {year=>2015, tp_status=>'K/2', net_income=>300_000_000},
        },
    ],
};
sub calc_pph21_op {
    my %args = @_;

    my $year       = $args{year};
    my $tp_status  = $args{tp_status};
    my $net_income = $args{net_income};

    my $res;

    $res = get_pph21_op_ptkp(year => $year);
    return $res unless $res->[0] == 200;
    my $ptkps = $res->[2];
    my $ptkp = $ptkps->{$tp_status}
        or die "BUG: Can't get PTKP for '$tp_status'";

    my $pkp = $net_income - $ptkp;
    return [200, "OK", 0] if $pkp <= 0;

    $res = get_pph21_op_rates(year => $year);
    return $res unless $res->[0] == 200;
    my $brackets = $res->[2];

    my $tax = 0;
    for my $bracket (@$brackets) {
        if (defined $bracket->{max}) {
            $tax += (_min($pkp, $bracket->{max}) -
                         ($bracket->{xmin} // 0)) * $bracket->{rate};
            last if $pkp <= $bracket->{max};
        } else {
            $tax += ($pkp - $bracket->{xmin}) * $bracket->{rate};
            last;
        }
    }

    [200, "OK", $tax];
}

$SPEC{calc_net_income_from_pph21_op} = {
    v => 1.1,
    summary => 'Given that someone pays a certain amount of PPh 21 op, '.
        'calculate her yearly net income',
    description => <<'_',

If pph21_op is 0, will return the PTKP amount. Actually one can earn between
zero and the full PTKP amount to pay zero PPh 21 op.

_
    args => {
        %arg_year,
        %arg_tp_status,
        %arg_pph21_op,
        monthly => {
            summary => 'Instead of yearly, return monthly net income',
            schema => ['bool*', is=>1],
        },
    },
    examples => [
        {
            summary => "Someone who doesn't pay PPh 21 op earns at or below PTKP",
            args => {year=>2016, tp_status=>'TK/0', pph21_op=>0},
        },
        {
            args => {year=>2016, tp_status=>'K/2', pph21_op=>20_000_000},
        },
    ],
};
sub calc_net_income_from_pph21_op {
    my %args = @_;

    my $year      = $args{year};
    my $tp_status = $args{tp_status};
    my $pph21_op  = $args{pph21_op};

    my $res;

    $res = get_pph21_op_ptkp(year => $year);
    return $res unless $res->[0] == 200;
    my $ptkps = $res->[2];
    my $ptkp = $ptkps->{$tp_status}
        or die "BUG: Can't get PTKP for '$tp_status'";

    $res = get_pph21_op_rates(year => $year);
    return $res unless $res->[0] == 200;
    my $brackets = $res->[2];

    my $net_income = $ptkp;
    for my $bracket (@$brackets) {
        if (defined $bracket->{max}) {
            my $range = $bracket->{max} - ($bracket->{xmin} // 0);
            my $bracket_tax = $range * $bracket->{rate};
            if ($pph21_op <= $bracket_tax) {
                $net_income += $pph21_op / $bracket->{rate};
                last;
            } else {
                $pph21_op -= $bracket_tax;
                $net_income += $range;
            }
        } else {
            $net_income += $pph21_op/$bracket->{rate};
            last;
        }
    }
    [200, "OK", $args{monthly} ? $net_income / 12 : $net_income];
}

1;
# ABSTRACT:

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

=cut
