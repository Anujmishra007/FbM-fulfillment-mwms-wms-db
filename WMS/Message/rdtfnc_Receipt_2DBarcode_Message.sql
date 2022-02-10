-- rdtfnc_Receipt_2DBarcode
execute rdt.rdtDropMsg 103801 , 103850

execute rdt.rdtAddMsg 103801, 10, '03801 RefNo NotInASN', 'us_english', 609
execute rdt.rdtAddMsg 103802, 10, '03802 Need ASN or PO', 'us_english', 609
execute rdt.rdtAddMsg 103803, 10, '03803 ASN&PONotExist', 'us_english', 609
execute rdt.rdtAddMsg 103804, 10, '03804 ASN Not Exist ', 'us_english', 609
execute rdt.rdtAddMsg 103805, 10, '03805 PO Not Exist  ', 'us_english', 609
execute rdt.rdtAddMsg 103806, 10, '03806 PO Not In ASN ', 'us_english', 609
execute rdt.rdtAddMsg 103807, 10, '03807 ASN not exist ', 'us_english', 609
execute rdt.rdtAddMsg 103808, 10, '03808 MultiPO In ASN', 'us_english', 609
execute rdt.rdtAddMsg 103809, 10, '03809 PO not exist  ', 'us_english', 609
execute rdt.rdtAddMsg 103810, 10, '03810 MultiASN in PO', 'us_english', 609
execute rdt.rdtAddMsg 103811, 10, '03811 Invalid RefNo',  'us_english', 609
execute rdt.rdtAddMsg 103812, 10, '03812 Diff facility ', 'us_english', 609
execute rdt.rdtAddMsg 103813, 10, '03813 Diff storer   ', 'us_english', 609
execute rdt.rdtAddMsg 103814, 10, '03814 ASN is closed ', 'us_english', 609
execute rdt.rdtAddMsg 103815, 10, '03815 NotInStorerGrp', 'us_english', 609
execute rdt.rdtAddMsg 103816, 10, '03816 SKU is require', 'us_english', 609
execute rdt.rdtAddMsg 103817, 10, '03817 Invalid SKU   ', 'us_english', 609
execute rdt.rdtAddMsg 103818, 10, '03818 MultiSKUBarcod', 'us_english', 609
execute rdt.rdtAddMsg 103819, 10, '03819 SKU not in PO ', 'us_english', 609
execute rdt.rdtAddMsg 103820, 10, '03820 SKU not in ASN', 'us_english', 609
execute rdt.rdtAddMsg 103821, 10, '03821 Invalid QTY   ', 'us_english', 609
execute rdt.rdtAddMsg 103822, 10, '03822 Invalid QTY   ', 'us_english', 609
execute rdt.rdtAddMsg 103823, 10, '03823 Bad ReasonCode', 'us_english', 609

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 103801 AND 103850