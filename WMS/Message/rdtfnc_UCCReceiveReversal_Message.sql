
-- UCC Receive Reversal Messages
-- ******************************
execute rdt.rdtDropMsg 62901 , 62926

execute rdt.rdtAddMsg 62901, 10, '62901 UCC Config OFF', 'us_english'
execute rdt.rdtAddMsg 62902, 10, '62902 ASN needed', 'us_english'
execute rdt.rdtAddMsg 62903, 10, '62903 Invalid ASN', 'us_english'
execute rdt.rdtAddMsg 62904, 10, '62904 ASN Not Open', 'us_english'
execute rdt.rdtAddMsg 62905, 10, '62905 LOC not in ASN', 'us_english'
execute rdt.rdtAddMsg 62906, 10, '62906 Diff Facility', 'us_english'
execute rdt.rdtAddMsg 62907, 10, '62907 No Record', 'us_english'
execute rdt.rdtAddMsg 62908, 10, '62908 ID not in ASN', 'us_english'
execute rdt.rdtAddMsg 62909, 10, '62909 No Record', 'us_english'
execute rdt.rdtAddMsg 62910, 10, '62910 UCC not in ASN', 'us_english'
execute rdt.rdtAddMsg 62911, 10, '62911 Invalid option', 'us_english'
execute rdt.rdtAddMsg 62912, 10, '62912 UCC QTY fixed', 'us_english'
execute rdt.rdtAddMsg 62913, 10, '62913 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 62914, 10, '62914 Line Over Rcpt', 'us_english'
execute rdt.rdtAddMsg 62915, 10, '62915 Line finalized', 'us_english'
execute rdt.rdtAddMsg 62916, 10, '62916 UCC finalized', 'us_english'
execute rdt.rdtAddMsg 62917, 10, '62917 Fail to adjust', 'us_english'
execute rdt.rdtAddMsg 62918, 10, '62918 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 62919, 10, '62919 Line finalized', 'us_english'
execute rdt.rdtAddMsg 62920, 10, '62920 UCC finalized', 'us_english'
execute rdt.rdtAddMsg 62921, 10, '62921 Fail to adjust', 'us_english'

--WMS-20734
execute rdt.rdtAddMsg 62922, 10, '62922 MIX SKU UCC   ', 'us_english', 888
execute rdt.rdtAddMsg 62923, 10, '62923 OVER UCC QTY  ', 'us_english', 888

--FCR-8271
execute rdt.rdtAddMsg 62924, 10, '62924 Invalid Option', 'us_english', 888

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 62901 AND 62926

