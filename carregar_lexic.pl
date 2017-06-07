#!/usr/bin/perl

# En aquest programa es llegeix el fitxer amb 4 columnes separades per tabuladors amb paraules amb categories tancaes
# 0. ocurrències
# 1. paraula catalana
# 2. categoria gramatical
# 3. paraula sarda
# El programa genera 2 fitxers per carregar als 2 fitxers de diccionari

use strict;
use utf8;

my ($fsrd, $fbi, $fdixsrd, $fdixcat);

open($fdixsrd, "../apertium-srd/apertium-srd.srd.dix") || die "can't open apertium-srd.srd.dix: $!";
open($fdixcat, "../apertium-cat/apertium-cat.cat.dix") || die "can't open apertium-cat.cat.dix: $!";

open($fsrd, ">f_srd.dix.txt") || die "can't open f_srd.dix: $!";
open($fbi, ">f_bi.dix.txt") || die "can't open f_bi.dix: $!";

binmode(STDIN, ":encoding(UTF-8)");
binmode($fdixsrd, ":encoding(UTF-8)");
binmode($fdixcat, ":encoding(UTF-8)");
binmode($fsrd, ":encoding(UTF-8)");
binmode($fbi, ":encoding(UTF-8)");
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");


# llegeixo el fitxer sard: n, adj, adv, np, abbr
sub llegir_dix {
	my ($nfitx, $fitx, $r_struct) = @_;
	my ($lemma, $par, $morf);

#<e lm="megacuntzertu"><i>megacuntzert</i><par n="mac/u__n"/></e>
#<e lm="acumandare">      <i>a</i><par n="cum/com"/><i>and</i><par n="cant/are__vblex"/></e>
#<e lm="intertzèdere">    <p><l>intertzed</l> <r>intertzèdere</r></p><par n="tim/o__vblex"/></e>
#<e lm="ismòrrere">       <p><l>ismorr</l>    <r>ismòrrere</r></p><par n="tim/o__vblex"/></e>
#<e lm="més" a="mginesti"><i>més</i><par n="multimèdia__adj"/></e>

	while (my $linia = <$fitx>) {
		chop $linia;
#print "1. fitxer $nfitx, $linia\n" if $nfitx eq 'cat' && $linia =~ /comarca/o;
		if ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} else {
			next;
		}
		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer $nfitx, $linia, par=$par, morf=$morf";
		}
#print "2. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $nfitx eq 'cat' && $linia =~ /comarca/o;
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'np' && $morf ne 'vblex' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}
#print "3. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $nfitx eq 'cat' && $linia =~ /comarca/o;

		$r_struct->{$morf}{$lemma} = $par;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $par =~ /vblex/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $lemma =~ /comarca/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
	}
}

my %dix_srd = ();
my %dix_cat = ();

llegir_dix('srd', $fdixsrd, \%dix_srd);
llegir_dix('cat', $fdixcat, \%dix_cat);

<STDIN>;	# saltem la primera línia
my ($stem_cat, $stem_srd, $gen_cat, $gen_srd, $num_cat, $num_srd, $lemma_cat, $lemma_srd);
while (my $linia = <STDIN>) {
	chop $linia;
	$linia =~ s/[^a-z\t]+$//o;
#	$linia =~ tr/[A-ZÀÈÌÒÙÉÍÓÚ/a-zàèìòùéíóú/;
	my @dades = split /\t/, $linia;
	for (my $i=0; $i<=$#dades; $i++) { 
		$dades[$i] =~ s/^ +//o;
		$dades[$i] =~ s/ +$//o;
	}

	next unless $dades[3];			# línia buida
	next if $dades[5] =~ /\?/o;		# dubtes
print "99. $. dades[1] = $dades[1]\n" if length $dades[1] == 1;	# una sola lletra

	$stem_cat = $dades[1];
	$stem_cat =~ s| +| |og;
	$stem_cat =~ s|^ ||o;
	$stem_cat =~ s| $||o;
	$lemma_cat = $stem_cat;
	if ($stem_cat =~ m/\#/o) {
		$stem_cat = $` . '<g>' . $' . '</g>';
		$lemma_cat =~ s/#//o;
	}
	$stem_cat =~ s| |<b/>|og;

	$dades[3] =~ s|,|;|og;

#print "11. $linia - stem_cat=$stem_cat, lemma_cat=$lemma_cat, dades[3]=$dades[3]\n" if $lemma_cat eq 'parella';
	my @stem_srd = split /;/o, $dades[3];
	my $primer = 1;
	my $n = 0; 	# index en @stem_srd
	foreach my $stem_srd (@stem_srd) {
		$stem_srd =~ s| +| |og;
		$stem_srd =~ s|^ ||o;
		$stem_srd =~ s| $||o;
		next unless $stem_srd;
		$lemma_srd = $stem_srd;
		if ($stem_srd =~ m/\#/o) {
			$stem_srd = $` . '<g>' . $' . '</g>';
			$lemma_srd =~ s/#//o;
		}
		$stem_srd =~ s| |<b/>|og;

		my $gram_cat = $dades[2];
		$gram_cat =~ s/^ *<//og;
		$gram_cat =~ s/> *$//og;
		if ($gram_cat =~ /></o) {
			my @gram_cat = split /;/o, $gram_cat;
			$gram_cat = $gram_cat[$n];
			$gram_cat = $gram_cat[0] unless $gram_cat;	# potser hi ha només una definició per a totes les possibilitats
			$gram_cat = 'n' if $gram_cat =~ /^n>/o;
			$gram_cat = 'np' if $gram_cat =~ /^np>/o;
		}

		my $gram_srd = $dades[4];
		if ($gram_srd) {
			$gram_srd =~ s/^ *<//og;
			$gram_srd =~ s/> *$//og;
			if ($gram_srd =~ /></o) {
				my @gram_srd = split /;/o, $gram_srd;
				$gram_srd = $gram_srd[$n];
				$gram_srd = $gram_srd[0] unless $gram_srd;	# potser hi ha només una definició per a totes les possibilitats
				$gram_srd = 'n' if $gram_srd =~ /^n>/o;
				$gram_srd = 'np' if $gram_cat =~ /^np>/o;
			}
		} else {
			$gram_srd = $gram_cat;
		}
#print "12. $linia - stem_srd=$stem_srd, lemma_srd=$lemma_srd, gram_cat = $gram_cat, gram_srd = $gram_srd\n" if $lemma_cat eq 'parella';

		# sortida: diccionari bilingüe
		if ($gram_cat eq 'vblex') {
			# comprovo que és en el diccionari monolingüe
			print STDERR "Falta $lemma_srd <$gram_srd>\n" unless $dix_srd{$gram_srd}{$lemma_srd};
#			print "dix_srd{$gram_srd}{$lemma_srd} = $dix_srd{$gram_srd}{$lemma_srd}\n";
			next unless $dix_srd{$gram_srd}{$lemma_srd};

			my $rl = ' r="RL"' unless $primer;
			printf $fbi "      <e$rl><p><l>%s<s n=\"$gram_cat\"/></l><r>%s<s n=\"$gram_srd\"/></r></p></e>\n", $stem_cat, $stem_srd;

		} elsif ($gram_cat eq 'adv') {
			# comprovo que és en el diccionari monolingüe
			print STDERR "Falta $lemma_srd <$gram_srd>\n" unless $dix_srd{$gram_srd}{$lemma_srd};
#			print "dix_srd{$gram_srd}{$lemma_srd} = $dix_srd{$gram_srd}{$lemma_srd}\n";
			next unless $dix_srd{$gram_srd}{$lemma_srd};

			my $rl = ' r="RL"' unless $primer;
			printf $fbi "      <e$rl><p><l>%s<s n=\"$gram_cat\"/></l><r>%s<s n=\"$gram_srd\"/></r></p></e>\n", $stem_cat, $stem_srd;

		} elsif ($gram_cat eq 'adj') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_srd = $dix_srd{$gram_srd}{$lemma_srd};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
			next unless $par_cat;
			print STDERR "Falta srd $lemma_srd <$gram_srd>\n" unless $par_srd;
			next unless $par_srd;

			if ($par_cat eq 'multimèdia__adj' && $par_srd eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afric/à__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abusi/u__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adjudicat/ari__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'triparti/t__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alacant/í__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'j/ove__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'de_dos__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"ord\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alt__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf+sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf+sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'triparti/t__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'r/àpid__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'blan/c__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alt__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bo__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bo__adj' && $par_srd eq 'àter/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'important__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alegr/e__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'altr/e__adj' && $par_srd eq 'àter/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'po/c__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"ind\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'multimèdia__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
			} else {
				print STDERR "adj 1. par_cat = $par_cat, par_srd = $par_srd\n";
			}

		} elsif ($gram_cat eq 'n') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_srd = $dix_srd{$gram_srd}{$lemma_srd};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
			next unless $par_cat;
			print STDERR "Falta srd $lemma_srd <$gram_srd>\n" unless $par_srd;
			next unless $par_srd;

			if ($par_cat eq 'abell/a__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acústi/ca__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alg/a__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acci/ó__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acci/ó__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acci/ó__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adre/ça__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'atletisme__n' && $par_srd eq 'nord__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'atletisme__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sg_ND\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'aband/ó__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'as__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'as__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'carism/a__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abast__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acc/és__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'assa/ig__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'cos__n' && $par_srd eq 'temp/us__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'cos__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'pa__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'campus__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'as__n' && $par_srd eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'mac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;

			} elsif ($par_cat eq 'angl/ès__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'advoca/t__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alacant/í__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'americ/à__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ami/c__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'asiàti/c__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adjudicat/ari__n' && $par_srd eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'ingegner/i__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;

			} elsif ($par_cat eq 'q__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/>/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'BBC__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'BBVA__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'IRPF__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sp\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} else {
				print STDERR "n 1. par_cat = $par_cat, par_srd = $par_srd, $stem_cat > $stem_srd\n";
			}


		} elsif ($gram_cat eq 'np') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_srd = $dix_srd{$gram_srd}{$lemma_srd};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
			next unless $par_cat;
			print STDERR "Falta srd $lemma_srd <$gram_srd>\n" unless $par_srd;
			next unless $par_srd;

			if ($par_cat eq 'Abad__np' && $par_srd eq 'Antoni__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Abad__np' && $par_srd eq 'Maria__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Abad__np' && $par_srd eq 'Saussure__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"cog\"/><s n=\"mf\"/><s n=\"sp\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Afganistan__np' && $par_srd eq 'Afganistàn__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Afganistan__np' && $par_srd eq 'Etiòpia__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Afganistan__np' && $par_srd eq 'Istados_Unidos__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Afganistan__np' && $par_srd eq 'Is_Pratzas__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Afganistan__np' && $par_srd eq 'Po__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"hyd\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Afganistan__np' && $par_srd eq 'Loira__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"loc\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} else {
				print STDERR "np 1. par_cat = $par_cat, par_srd = $par_srd, $stem_cat > $stem_srd\n";
			}

		} else {
			print STDERR "10. línia $.: $linia - morf $gram_cat, morf $gram_srd\n";
			next;
		}

		$primer = 0;
		$n++;
	}

}
