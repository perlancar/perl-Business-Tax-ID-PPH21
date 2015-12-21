package Business::Tax::ID::PPH21;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter::Rinci qw(import);

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Routines to help calculating Indonesian income tax article 21 (PPh pasal 21)',
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

$SPEC{get_pph21_individual_tax_rates} = {
    v => 1.1,
    summary => 'Get PPh21 tax rates for individuals',
    description => <<'_',

PPh 21 differentiates rates between individuals and statutory bodies (e.g.
companies).

Keywords: tax brackets.

_
    'description.alt.lang.id_ID' => <<'_',

Kata kunci: tarif pajak.

_
    args => {
        year => {
            schema => ['int*', min=>1983],
            req => 1,
            pos => 0,
        },
    },
    examples => [
        {args=>{year=>2015}},
    ],
};
sub get_pph21_individual_tax_rates {
    my %args = @_;
    my $year = $args{year};
    if ($year >= 2009 && $year <= 2015) {
        state $rate = [
            200, "OK",
            [
                {                   max=> 50_000_000, rate=>0.05},
                {xmin=> 50_000_000, max=>250_000_000, rate=>0.15},
                {xmin=>250_000_000, max=>500_000_000, rate=>0.25},
                {xmin=>500_000_000,                   rate=>0.30},
            ],
            {'table.fields' => [qw/xmin max rate/]},
        ];
        return $rate;
    } elsif ($year >= 2000 && $year <= 2008) {
        state $rate = [
            200, "OK",
            [
                {                   max=> 25_000_000, rate=>0.05},
                {xmin=> 25_000_000, max=> 50_000_000, rate=>0.10},
                {xmin=> 50_000_000, max=>100_000_000, rate=>0.15},
                {xmin=>100_000_000, max=>200_000_000, rate=>0.25},
                {xmin=>200_000_000,                   rate=>0.35},
            ],
            {'table.fields' => [qw/xmin max rate/]},
        ];
        return $rate;
    } else {
        return [412, "Year unknown or unsupported"];
    }
}

# TODO: get_pph21_statbody_tax_rates

$SPEC{get_pph21_individual_nontaxable_incomes} = {
    v => 1.1,
    summary => 'Get PPh21 individual non-taxable income amount (PTKP)',
    description => <<'_',

When calculating individual income tax, the net income is subtracted by this
amount. This means that if a person has income below this amount, he/she does
not need to pay income tax.

_
    'description.alt.lang.id_ID' => <<'_',

Kata kunci: PTKP, penghasilan tidak kena pajak.

_
    args => {
        year => {
            schema => ['int*', min=>1983],
            req => 1,
            pos => 0,
        },
    },
    examples => [
        {args=>{year=>2015}},
    ],
};
sub get_pph21_individual_nontaxable_incomes {
}

1;
# ABSTRACT:

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

=cut
