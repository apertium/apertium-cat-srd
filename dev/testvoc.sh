echo "==Catalan->Sardinian==========================";
bash inconsistency.sh cat-srd > /tmp/cat-srd.testvoc; sh inconsistency-summary.sh /tmp/cat-srd.testvoc cat-srd
#echo ""
#echo "==Sardinian->Catalan===========================";
#bash inconsistency.sh srd-cat > /tmp/srd-cat.testvoc; bash inconsistency-summary.sh /tmp/srd-cat.testvoc srd-cat
