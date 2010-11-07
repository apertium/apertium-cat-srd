all:
	lt-comp lr apertium-ca-sc.sc.dix sc-ca.automorf.bin apertium-ca-sc.sc.acx
	lt-comp rl apertium-ca-sc.ca-sc.dix sc-ca.autobil.bin
	apertium-validate-transfer apertium-ca-sc.sc-ca.t1x
	apertium-preprocess-transfer apertium-ca-sc.sc-ca.t1x sc-ca.t1x.bin
	lt-comp lr apertium-ca-sc.post-ca.dix sc-ca.autopgen.bin
	lt-comp rl ca/ca.dix sc-ca.autogen.bin

	lt-comp lr ca/ca.dix ca-sc.automorf.bin apertium-ca-sc.sc.acx
	lt-comp lr apertium-ca-sc.ca-sc.dix ca-sc.autobil.bin
	apertium-preprocess-transfer apertium-ca-sc.ca-sc.t1x ca-sc.t1x.bin
	lt-comp rl apertium-ca-sc.sc.dix ca-sc.autogen.bin
	lt-comp lr apertium-ca-sc.post-sc.dix ca-sc.autopgen.bin
	apertium-gen-modes modes.xml
	cp *.mode modes/

sc-ca.autogen.bin:
	xsltproc ../apertium-ca-it/translate-to-default-equivalent.xsl ../apertium-ca-it/apertium-ca-it.ca.dix | xsltproc --stringparam lang cat --stringparam side left ../apertium-ca-it/filter.xsl - | xsltproc --stringparam alt std ../apertium-ca-it/alt.xsl - > apertium-ca-sc.ca.dixtmp1
	lt-comp rl apertium-ca-sc.ca.dixtmp1 sc-ca.autogen.bin apertium-ca-sc.sc.acx
