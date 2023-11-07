--rdt_PrePalletizeSort_UCC
execute rdt.rdtDropMsg 204901 , 204950

execute rdt.rdtAddMsg 204901, 10, '204901 INS UCC Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 204902, 10, '204902 UPD UCC Fail ',   'us_english', 1841

--WMS-23878
execute rdt.rdtAddMsg 204903, 10, '204903UPD CTNTYPE ER',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 204901 AND 204950