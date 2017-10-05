#!/usr/bin/perl

# En aquest programa es llegeix el fitxer amb 4 columnes separades per tabuladors amb paraules amb categories tancaes
# 0. ocurrències
# 1. paraula catalana
# 2. categoria gramatical sarda
# 3. paraula sarda
# 4. categoria gramatical sarda
# El programa genera 2 fitxers per carregar als 2 fitxers de diccionari
# Només genera paraules per als fitxers si la paraula català no té traducció prèvia en el fitxer bilingüe

use strict;
use utf8;

my ($fsrd, $fbi, $fdixsrd, $fdixcat, $fdixbi);

open($fdixsrd, "../apertium-srd/apertium-srd.srd.dix") || die "can't open apertium-srd.srd.dix: $!";
open($fdixcat, "../apertium-cat/apertium-cat.cat.dix") || die "can't open apertium-cat.cat.dix: $!";
open($fdixbi, "apertium-cat-srd.cat-srd.dix") || die "can't open apertium-cat.cat.dix: $!";

open($fsrd, ">f_srd.dix.txt") || die "can't open f_srd.dix: $!";
open($fbi, ">f_bi.dix.txt") || die "can't open f_bi.dix: $!";

binmode(STDIN, ":encoding(UTF-8)");
binmode($fdixsrd, ":encoding(UTF-8)");
binmode($fdixcat, ":encoding(UTF-8)");
binmode($fdixbi, ":encoding(UTF-8)");
binmode($fsrd, ":encoding(UTF-8)");
binmode($fbi, ":encoding(UTF-8)");
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");


# llegeixo el fitxer sard: n, adj, adv, np, abbr
sub llegir_dix {
	my ($nfitx, $fitx, $r_struct) = @_;
	my ($lemma, $par, $morf);

#<e lm="megacuntzertu"><i>megacuntzert</i><par n="àbac/u__n"/></e>
#<e lm="acumandare">      <i>a</i><par n="cum/com"/><i>and</i><par n="cant/are__vblex"/></e>
#<e lm="intertzèdere">    <p><l>intertzed</l> <r>intertzèdere</r></p><par n="tim/o__vblex"/></e>
#<e lm="ismòrrere">       <p><l>ismorr</l>    <r>ismòrrere</r></p><par n="tim/o__vblex"/></e>
#<e lm="més" a="mginesti"><i>més</i><par n="multimèdia__adj"/></e>
#<e lm="tènnere logu">    <p><l>ten</l>       <r>tènnere</r></p><par n="ten/es__vblex"/><p><l><b/>logu</l><r><g><b/>logu</g></r></p></e>
#<e r="LR" lm="els Estats Units"><i>els<b/>Estats<b/>Units</i><par n="Afganistan__np"/></e>


	while (my $linia = <$fitx>) {
		chop $linia;
print "1. fitxer $nfitx, $linia\n" if $nfitx eq 'cat' && $linia =~ /solter/o;
		if ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;

		} elsif ($nfitx eq 'cat' && $linia =~ m|<e r="LR" lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($nfitx eq 'srd' && $linia =~ m|<e r="RL" lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/></e>|o) {
#<e r="RL" lm="chi bennit"><i>chi<b/>benni</i><par n="chi_proveni/t__adj"/></e>
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e lm="([^"]*)">[^<]*<par n="(.*)"/></e>|o) {
#<e lm="ampli">           <par n="/ampli__adj"/></e>
			$lemma = $1;
			$par = $2;
		} else {
			next;
		}
		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer $nfitx, $linia, par=$par";
		}
print "2. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $nfitx eq 'cat' && $linia =~ /solter/o;
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'np' && $morf ne 'vblex' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}
print "3. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $nfitx eq 'cat' && $linia =~ /solter/o;

		$r_struct->{$morf}{$lemma} = $par;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $par =~ /vblex/o;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $lemma =~ /solter/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
	}
}

# llegeixo el fitxer bilingüe: n, adj, adv, np, abbr
sub llegir_bidix {
	my ($fitx, $r_struct) = @_;
	my ($lemma_cat, $lemma_srd, $morf, $morf2);

#       <e><p><l>derrota<s n="n"/><s n="f"/></l><r>derrota<s n="n"/><s n="f"/></r></p></e>
#      <e><p><l>proper<s n="adj"/></l><r>imbeniente<s n="adj"/></r></p><par n="GD_mf"/></e>
#      <e r="LR"><p><l>aqueix<s n="prn"/><s n="tn"/></l><r>custu<s n="prn"/><s n="tn"/></r></p></e>
#      <e><p><l>pacient<s n="n"/></l><r>malàidu<s n="n"/></r></p><par n="mf_GD"/></e>
#      <e><p><l>arribar<g><b/>a</g><s n="vblex"/></l><r>arribare<g><b/>a</g><s n="vblex"/></r></p></e>
	while (my $linia = <$fitx>) {
		chop $linia;
		$linia =~ s|<b/>| |og;
		$linia =~ s|<g>|#|og;
		$linia =~ s|</g>||og;
print "1. fitxer bidix, $linia\n" if $linia =~ /solter/o;
		if ($linia =~ m|<e> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_cat = $1;
			$morf = $2;
			$lemma_srd = $3;
		} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_cat = $1;
			$morf = $2;
			$lemma_srd = $3;
		} else {
			next;
		}
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'np' && $morf ne 'vblex' && $morf ne 'abbr') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}

		# en el cas de n i np busco el segon membre de la definició morfològica
		if ($morf eq 'n' || $morf eq 'np') {
			if ($linia =~ m|<e> *<p><l>([^<]*)<s n="([^"]*)".><s n="([^"]*)".>.*<r>([^<]*)<s|o) {
				$lemma_cat = $1;
				$morf = $2 . $3;
				$lemma_srd = $4;
			} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="([^"]*)".><s n="([^"]*)".>.*<r>([^<]*)<s|o) {
				$lemma_cat = $1;
				$morf = $2 . $3;
				$lemma_srd = $3;
			} else {
				print STDERR "000x línia $.: $linia - morf $morf\n" unless $morf eq 'n';	# és normal que no hi hagi gènere en noms que en poden tenir dos
			}
		}

print "3. fitxer bidix, $linia, morf=$morf\n" if $linia =~ /solter/o;

		$r_struct->{$morf}{$lemma_cat} = $lemma_srd;
#print "r_struct->{$morf}{$lemma_cat} = $r_struct->{$morf}{$lemma_cat}\n" if $morf =~ /vblex/o;
print "r_struct->{$morf}{$lemma_cat} = $r_struct->{$morf}{$lemma_cat}\n" if $lemma_cat =~ /solter/o;
#print "r_struct->{$morf}{$lemma_cat} = $r_struct->{$morf}{$lemma_cat}\n";
	}
}

my %dix_srd = ();
my %dix_cat = ();
my %dix_bi = ();

llegir_dix('srd', $fdixsrd, \%dix_srd);
llegir_dix('cat', $fdixcat, \%dix_cat);
llegir_bidix($fdixbi, \%dix_bi);

my $nbr_entrades = 0;
my $nbr_entrades_np = 0;

<STDIN>;	# saltem la primera línia
my ($stem_cat, $stem_srd, $gen_cat, $gen_srd, $num_cat, $num_srd, $lemma_cat, $lemma_srd);
while (my $linia = <STDIN>) {
	chop $linia;
	$linia =~ s/[^a-z\t]+$//o;
	$linia =~ s|\r| |og;
	$linia =~ s| +| |og;
	my @dades = split /\t/, $linia;
	for (my $i=0; $i<=$#dades; $i++) { 
		$dades[$i] =~ s/^ +//o;
		$dades[$i] =~ s/ +$//o;
	}

	next unless $dades[3];			# línia buida
	$nbr_entrades++;
	$nbr_entrades_np++ if $dades[2] =~ /np/o;
	next if $dades[5] =~ /\?/o;		# dubtes
	next if length $dades[1] == 1;		# una sola lletra
#print "99. $. dades[1] = $dades[1]\n" if length $dades[1] == 1;	# una sola lletra

	$stem_cat = $dades[1];
	$stem_cat =~ s| +| |og;
	$stem_cat =~ s|^ ||o;
	$stem_cat =~ s| $||o;
	$lemma_cat = $stem_cat;
	if ($stem_cat =~ m/\#/o) {
		$stem_cat = $` . '<g>' . $' . '</g>';
	}
	$stem_cat =~ s| |<b/>|og;

	my $gram_cat = $dades[2];
	$gram_cat =~ s/^ *<//og;
	$gram_cat =~ s/> *$//og;
	$gram_cat =~ s/><//og;
	# verifico que la paraula no estigui ja en en diccionari bilingüe
	if ($dix_bi{$gram_cat}{$lemma_cat}) {
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
		next;
	}
	if ($gram_cat eq 'nm' && $dix_bi{n}{$lemma_cat}) {	# sovint apareixen com a nm paraules que són n (i.e. m+f)
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
$gram_cat = 'n';
#		next;
	}
	if ($gram_cat eq 'nmf' && $dix_bi{n}{$lemma_cat}) {	# sovint apareixen com a nmf paraules que estan posades com a n
#print "No es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
$gram_cat = 'n';
#		next;
	}
#print "Sí es carrega: dix_bi{$gram_cat}{$lemma_cat} = $dix_bi{$gram_cat}{$lemma_cat}\n";
	$lemma_cat =~ s/#//o;


	$dades[3] =~ s|,|;|og;

print "11. $linia - stem_cat=$stem_cat, lemma_cat=$lemma_cat, gram_cat = $gram_cat, dades[3]=$dades[3]\n" if $lemma_cat =~ /solter/o;
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
		$gram_cat =~ s/ //og;
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
		$gram_srd =~ s/ //og;
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
print "12. $linia - stem_srd=$stem_srd, lemma_srd=$lemma_srd, gram_cat = $gram_cat, gram_srd = $gram_srd\n" if $lemma_cat =~ /solter/o;
#print "12. $linia - stem_srd=$stem_srd, lemma_srd=$lemma_srd, gram_cat = $gram_cat, gram_srd = $gram_srd\n";

		# sortida: diccionari bilingüe
		if ($gram_cat eq 'vblex') {
			# comprovo que és en el diccionari monolingüe
			print STDERR "Falta srd $lemma_srd <$gram_srd>\n" unless $dix_srd{$gram_srd}{$lemma_srd};
#			print "dix_srd{$gram_srd}{$lemma_srd} = $dix_srd{$gram_srd}{$lemma_srd}\n";
			next unless $dix_srd{$gram_srd}{$lemma_srd};

			my $rl = ' r="RL"' unless $primer;
			printf $fbi "      <e$rl><p><l>%s<s n=\"$gram_cat\"/></l><r>%s<s n=\"$gram_srd\"/></r></p></e>\n", $stem_cat, $stem_srd;

		} elsif ($gram_cat eq 'adv') {
			# comprovo que és en el diccionari monolingüe
			unless ($dix_srd{$gram_srd}{$lemma_srd}) {
				if ($gram_srd eq 'adv') {
				# generem el paradigma al diccionari sard
					my $par_srd = 'bene__adv';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} else {
					print STDERR "Falta srd $lemma_srd <$gram_srd>\n" unless $dix_srd{$gram_srd}{$lemma_srd};
#					print "dix_srd{$gram_srd}{$lemma_srd} = $dix_srd{$gram_srd}{$lemma_srd}\n";
					next;
				}
			}

			my $rl = ' r="RL"' unless $primer;
			printf $fbi "      <e$rl><p><l>%s<s n=\"$gram_cat\"/></l><r>%s<s n=\"$gram_srd\"/></r></p></e>\n", $stem_cat, $stem_srd;

		} elsif ($gram_cat eq 'adj') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_srd = $dix_srd{$gram_srd}{$lemma_srd};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
			next unless $par_cat;

			unless ($par_srd) {
				# generem el paradigma al diccionari sard (tot i que només en alguns casos)
				if ($lemma_srd =~ /^de /) {
					$par_srd = 'matessi__adj';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($lemma_srd =~ /^a /) {
					$par_srd = 'matessi__adj';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($lemma_srd =~ /^chi /) {
					$par_srd = 'chi_proveni/t__adj';
					my $stem_srd2 = $stem_srd;
					$stem_srd2 =~ s/t$//o;
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd2, $par_srd;
				} else {
					print STDERR "Falta srd $lemma_srd <$gram_srd>\n";
					next;
				}
			}

			if ($par_cat eq 'multimèdia__adj' && $par_srd eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afectu/ós__adj' && $par_srd eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_srd eq 'matessi__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bre/u__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD+sup_0\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adept/e__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'chi_proveni/t__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abdominal__adj' && $par_srd eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abstract/e__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'preco/ç__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"capaç_capatzu\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'preco/ç__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"capaç_capatze\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'access/ori__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'andal/ús__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'access/ori__adj' && $par_srd eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'a/eri__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'arqueòl/eg__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afric/à__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'sangu/ini__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'far/ingi__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afectu/ós__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afric/à__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alacant/í__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'contempor/ani__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ami/c__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'complex__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'interm/edi__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'complex__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abusi/u__adj' && $par_srd eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abusi/u__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'to/u__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p>/e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abusi/u__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'to/u__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adjudicat/ari__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afectu/ós__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'aliment/ós__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ali/è__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'imprec/ís__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'triparti/t__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'banduler/i__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adjudicat/ari__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afgan/ès__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'af/í__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alacant/í__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acadèmi/c__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bo__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'dol/ç__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'agrícol/a__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'agrícol/a__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'agrícol/a__adj' && $par_srd eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'belg/a__adj' && $par_srd eq 'meda__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'j/ove__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'absolut__adj' && $par_srd eq 'de_dos__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"ord\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ali/è__adj' && $par_srd eq 'de_dos__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/><s n=\"ord\"/></r></p><par n=\"GD+ND_mf+sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ate/u__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'annex__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'annex__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alt__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'amfitri/ó__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'amfitri/ó__adj' && $par_srd eq 'cunservador/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'cont/inu__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'fict/ici__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'fict/ici__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'gal__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'heterog/eni__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'perp/etu__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'triparti/t__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'r/àpid__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'afortuna/t__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bas/c__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bas/c__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'blan/c__adj' && $par_srd eq 'linguìsti/cu__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alt__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bo__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bo__adj' && $par_srd eq 'àter/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'important__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'important__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alegr/e__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bre/u__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"sup_0_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'esc/às__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'genu/í__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ce/c__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'genu/í__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'altr/e__adj' && $par_srd eq 'àter/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'po/c__adj' && $par_srd eq 'frantzes/u__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"ind\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'multimèdia__adj' && $par_srd eq 'fàtzil/e__adj') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"adj\"/><s n=\"mf\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
			} else {
				print STDERR "adj 1. par_cat = $par_cat, par_srd = $par_srd, $stem_cat > $stem_srd\n";
			}

		} elsif ($gram_cat eq 'n') {
			my $rl = ' r="RL"' unless $primer;
			my $par_cat = $dix_cat{$gram_cat}{$lemma_cat};
			my $par_srd = $dix_srd{$gram_srd}{$lemma_srd};
			# comprovo que és en el diccionari monolingüe
			print STDERR "FALTA CAT $lemma_cat <$gram_cat>\n" unless $par_cat;		# seria estranyíssim no trobar-lo!
#			print STDERR "dades[1] = #$dades[1]#, length = ", length($dades[1]), "\n" unless $par_cat;
			next unless $par_cat;

			unless ($par_srd) {
				# generem el paradigma al diccionari sard (tot i que només en alguns casos)
				if ($par_cat eq 'BBC__n') {
					$par_srd = 'TV__n';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($par_cat eq 'BBVA__n') {
					$par_srd = 'PNB__n';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} else {
					print STDERR "Falta srd $lemma_srd <$gram_srd>\n";
					next;
				}
			}

			if ($par_cat eq 'abell/a__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'difer/èntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adre/ça__n' && $par_srd eq 'difer/èntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'import/àntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acústi/ca__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acústi/ca__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acústi/ca__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alg/a__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alg/a__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abell/a__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accessibilitat__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acci/ó__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acci/ó__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acci/ó__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acci/ó__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adre/ça__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adre/ça__n' && $par_srd eq 'import/àntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adre/ça__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'atletisme__n' && $par_srd eq 'nord__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'atletisme__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sg_ND\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'gay__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'nord__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sg\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'difer/èntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'import/àntzia__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acetil/è__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bacall/à__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bacall/à__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'aband/ó__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bacall/à__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'or/igen__n' && $par_srd eq 'region/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'aband/ó__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'aband/ó__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abd/omen__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'antic/òs__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'passad/ís__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'as__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'as__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'as__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'barre/ja__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'barre/ja__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'caf/è__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'caf/è__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'carism/a__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'carism/a__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abast__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abast__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acc/és__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abast__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acc/és__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'assa/ig__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'rebu/ig__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'assa/ig__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'caf/è__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'cos__n' && $par_srd eq 'temp/us__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'cos__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'm/arge__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'pa__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'cos__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'pa__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'atletisme__n' && $par_srd eq 'anarchismu__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'campus__n' && $par_srd eq 'anarchismu__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sp\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'anarchismu__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'campus__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'campus__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'campus__n' && $par_srd eq 'temp/us__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'campus__n' && $par_srd eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'as__n' && $par_srd eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accionist/a__n' && $par_srd eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accionist/a__n' && $par_srd eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'col·leg/a__n' && $par_srd eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'col·leg/a__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'monar/ca__n' && $par_srd eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'mesa__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'ingegner/i__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'acompanyant__n' && $par_srd eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'av/ís__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'boc/í__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'capat/às__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'desi/g__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'nitr/ogen__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'pols__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;

			} elsif ($par_cat eq 'addict/e__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"nostre_nostru\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'xil/è__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'angl/ès__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accionist/a__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'accionist/a__n' && $par_srd eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adjudicat/ari__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'advoca/t__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'advoca/t__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alacant/í__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'americ/à__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'amfitri/ó__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ami/c__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'asiàti/c__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adjudicat/ari__n' && $par_srd eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ate/u__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'biòl/eg__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'indiv/idu__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'rus__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 've/í__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'ingegner/i__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'dentista__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'adjudicat/ari__n' && $par_srd eq 'albanes/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'administrati/u__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alcalde__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'pres__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alcalde__n' && $par_srd eq 'traballador/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'alcalde__n' && $par_srd eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'emperad/or__n' && $par_srd eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'bar/ó__n' && $par_srd eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'cont/e__n' && $par_srd eq 'cont/e__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'camous_n' && $par_srd eq 'lapis__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'guardaespatlles__n' && $par_srd eq 'gay__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_cat, $stem_srd;

			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'pane__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'senyor__n' && $par_srd eq 'àbac/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'amig/u__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'abric__n' && $par_srd eq 'traballador/e__n,') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_cat, $stem_srd;

			} elsif ($par_cat eq 'q__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/>/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'BBC__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'BBVA__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'BBVA__n' && $par_srd eq 'PNB__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'BBC__n' && $par_srd eq 'TV__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'IRPF__n' && $par_srd eq 'a.C.__abbr') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sp\"/></l><r>%s<s n=\"abbr\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'PNB__n' && $par_srd eq 'IRPF__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'TV__n' && $par_srd eq 'MTS__n') {
					printf $fbi "      <e$rl><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_cat, $stem_srd;
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

			unless ($par_srd) {
print "No es troba dix_srd{$gram_srd}{$lemma_srd}. Es prova de generar $lemma_srd\n" if $lemma_cat =~ /solter/o;
				# generem el paradigma al diccionari sard
				if ($gram_srd eq 'np><ant><m><sg') {
					$par_srd = 'Antoni__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><ant><f><sg') {
					$par_srd = 'Maria__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd =~ /^np><cog/o) {
					$par_srd = 'Saussure__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><top><f><sg') {
					$par_srd = 'Etiòpia__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><top><m><sg') {
					$par_srd = 'Afganistàn__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><top><f><pl') {
					$par_srd = 'Is_Pratzas__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><top><m><pl') {
					$par_srd = 'Istados_Unidos__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><hyd><m><sg') {
					$par_srd = 'Po__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><hyd><f><sg') {
					$par_srd = 'Loira__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><al><m><sg') {
					$par_srd = 'Linux__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} elsif ($gram_srd eq 'np><al><f><sg') {
					$par_srd = 'Wikipedia__np';
					printf $fsrd "<e lm=\"%s\">           <i>%s</i><par n=\"%s\"/></e>\n", $lemma_srd, $stem_srd, $par_srd;
				} else {
					print STDERR "Falta srd $lemma_srd [$gram_srd], [$gram_cat] - no el podem generar (falten dades)\n" unless $par_srd;
					next;
				} 
			}

			if ($par_cat eq 'Abad__np' && $par_srd eq 'Antoni__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Abad__np' && $par_srd eq 'Maria__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Pau__np' && $par_srd eq 'Antoni__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Abad__np' && $par_srd eq 'Maria__np') {
			} elsif ($par_cat eq 'Marc__np' && $par_srd eq 'Antoni__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Maria__np' && $par_srd eq 'Maria__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Abad__np' && $par_srd eq 'Saussure__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"ant\"/></l><r>%s<s n=\"np\"/><s n=\"cog\"/><s n=\"mf\"/><s n=\"sp\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'Saussure__np' && $par_srd eq 'Saussure__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"cog\"/></l><r>%s<s n=\"np\"/><s n=\"cog\"/>></r></p></e>\n", $stem_cat, $stem_srd;
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
			} elsif ($par_cat eq 'ABC__np' && $par_srd eq 'Fiat__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"al\"/></l><r>%s<s n=\"np\"/><s n=\"org\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ABC__np' && $par_srd eq 'Linux__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"al\"/></l><r>%s<s n=\"np\"/><s n=\"al\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
			} elsif ($par_cat eq 'ABC__np' && $par_srd eq 'Wikipedia__np') {
				printf $fbi "      <e$rl><p><l>%s<s n=\"np\"/><s n=\"al\"/></l><r>%s<s n=\"np\"/><s n=\"al\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_cat, $stem_srd;
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

print "nbr_entrades = $nbr_entrades\n";
print "nbr_entrades_np = $nbr_entrades_np\n";
