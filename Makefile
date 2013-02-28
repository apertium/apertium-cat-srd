all:
	lt-comp lr apertium-cat-srd.srd.dix srd-cat.automorf.bin apertium-cat-srd.srd.acx
	lt-comp rl apertium-cat-srd.cat-srd.dix srd-cat.autobil.bin
	apertium-validate-transfer apertium-cat-srd.srd-cat.t1x
	apertium-preprocess-transfer apertium-cat-srd.srd-cat.t1x srd-cat.t1x.bin
	lt-comp lr apertium-cat-srd.post-cat.dix srd-cat.autopgen.bin
	lt-comp rl apertium-cat-srd.cat.dix srd-cat.autogen.bin

	lt-comp lr apertium-cat-srd.cat.dix cat-srd.automorf.bin apertium-cat-srd.srd.acx
	lt-comp lr apertium-cat-srd.cat-srd.dix cat-srd.autobil.bin
	apertium-preprocess-transfer apertium-cat-srd.cat-srd.t1x cat-srd.t1x.bin
	lt-comp rl apertium-cat-srd.srd.dix cat-srd.autogen.bin
	lt-comp lr apertium-cat-srd.post-srd.dix cat-srd.autopgen.bin
	apertium-gen-modes modes.xml
	cp *.mode modes/

srd-cat.autogen.bin:
	xsltproc ../trunk/apertium-ca-it/translate-to-default-equivalent.xsl ../trunk/apertium-ca-it/apertium-ca-it.ca.dix | xsltproc --stringparam lang cat --stringparam side left ../trunk/apertium-ca-it/filter.xsl - | xsltproc --stringparam alt std ../trunk/apertium-ca-it/alt.xsl - > apertium-cat-srd.cat.dixtmp1
	lt-comp rl apertium-cat-srd.cat.dixtmp1 srd-cat.autogen.bin apertium-cat-srd.srd.acx

clean:
	rm -r *.bin *.mode modes/
