echo "==Catalan->Sardinian==========================";
bash inconsistency.sh ca-sc > /tmp/ca-sc.testvoc; sh inconsistency-summary.sh /tmp/ca-sc.testvoc ca-sc
echo ""
echo "==Sardinian->Catalan===========================";
bash inconsistency.sh sc-ca > /tmp/sc-ca.testvoc; bash inconsistency-summary.sh /tmp/sc-ca.testvoc sc-ca
