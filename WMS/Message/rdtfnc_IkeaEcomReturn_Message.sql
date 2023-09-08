--rdtfnc_IkeaIkeaReturn
execute rdt.rdtdropmsg 203901 , 203950

execute rdt.rdtAddMsg 203901, 10, '203901Invalid Format',   'us_english', 657
execute rdt.rdtAddMsg 203902, 10, '203902 Need To ID   ',   'us_english', 657
execute rdt.rdtAddMsg 203903, 10, '203903 Need To LOC  ',   'us_english', 657
execute rdt.rdtAddMsg 203904, 10, '203904Invalid Format',   'us_english', 657
execute rdt.rdtAddMsg 203905, 10, '203905 Invalid ToLoc',   'us_english', 657
execute rdt.rdtAddMsg 203906, 10, '203906 Need Method  ',   'us_english', 657
execute rdt.rdtAddMsg 203907, 10, '203907 Need RefNo   ',   'us_english', 657
execute rdt.rdtAddMsg 203908, 10, '203908 ASN Not Found',   'us_english', 657
execute rdt.rdtAddMsg 203909, 10, '203909 HAND OVER    ',   'us_english', 657
execute rdt.rdtAddMsg 203910, 10, '203910 NOT COMPLETE ',   'us_english', 657
execute rdt.rdtAddMsg 203911, 10, '203911 1 ASN Only   ',   'us_english', 657
execute rdt.rdtAddMsg 203912, 10, '203912 1 To ID      ',   'us_english', 657
execute rdt.rdtAddMsg 203913, 10, '203913 SKU needed   ',   'us_english', 657
execute rdt.rdtAddMsg 203914, 10, '203914 Invalid SKU  ',   'us_english', 657
execute rdt.rdtAddMsg 203915, 10, '203915SKU Not in ASN',   'us_english', 657
execute rdt.rdtAddMsg 203916, 10, '203916 Invalid QTY  ',   'us_english', 657
execute rdt.rdtAddMsg 203917, 10, '203917 Over received',   'us_english', 657
execute rdt.rdtAddMsg 203918, 10, '203918 Need Value   ',   'us_english', 657
execute rdt.rdtAddMsg 203919, 10, '203919 Invalid Value',   'us_english', 657
execute rdt.rdtAddMsg 203920, 10, '203920 Invalid Value',   'us_english', 657
execute rdt.rdtAddMsg 203921, 10, '203921 Need RefNo   ',   'us_english', 657
execute rdt.rdtAddMsg 203922, 10, '203922 ASN Not Found',   'us_english', 657
execute rdt.rdtAddMsg 203923, 10, '203923 Upd ASN Fail ',   'us_english', 657
execute rdt.rdtAddMsg 203924, 10, '203924 Invalid Value',   'us_english', 657
execute rdt.rdtAddMsg 203925, 10, '203925 Invalid Value',   'us_english', 657
execute rdt.rdtAddMsg 203926, 10, '203926 Upd UDF01 Err',   'us_english', 657
execute rdt.rdtAddMsg 203927, 10, '203927 ASN Not Found',   'us_english', 657
execute rdt.rdtAddMsg 203928, 10, '203928 Need Option  ',   'us_english', 657
execute rdt.rdtAddMsg 203929, 10, '203929Invalid Option',   'us_english', 657
execute rdt.rdtAddMsg 203930, 10, '203930Invalid Option',   'us_english', 657
execute rdt.rdtAddMsg 203931, 10, '203931 Over received',   'us_english', 657
execute rdt.rdtAddMsg 203932, 10, '203932 Invalid Value',   'us_english', 657

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 203901 AND 203950