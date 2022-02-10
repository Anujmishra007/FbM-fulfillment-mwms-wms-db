-- rdtfnc_PackByCartonID
rdt.rdtDropMsg 137101 , 137150

execute rdt.rdtAddMsg 137101, 10, '37101^WaveKey req',      'us_english', 833
execute rdt.rdtAddMsg 137102, 10, '37102^Invalid Wave',     'us_english', 833
execute rdt.rdtAddMsg 137103, 10, '37103^Need UPC/SKU',     'us_english', 833
execute rdt.rdtAddMsg 137104, 10, '37104^Need Case ID',     'us_english', 833
execute rdt.rdtAddMsg 137105, 10, '37105^Need Serial No',   'us_english', 833
execute rdt.rdtAddMsg 137106, 10, '37106^Invalid SKU',      'us_english', 833
execute rdt.rdtAddMsg 137107, 10, '37107^MultiSKUBarcod',   'us_english', 833
execute rdt.rdtAddMsg 137108, 10, '37108^Invalid Format',   'us_english', 833

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137101 AND 137150