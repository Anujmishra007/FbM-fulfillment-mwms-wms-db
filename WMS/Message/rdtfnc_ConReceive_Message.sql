-- rdtfnc_ConReceive
execute rdt.rdtDropMsg 55901, 55950

execute rdt.rdtAddMsg 55901, 10, '55901 Need RefNo    ', 'us_english', 598
execute rdt.rdtAddMsg 55902, 10, '55902 Bad RefNoSetup', 'us_english', 598
execute rdt.rdtAddMsg 55903, 10, '55903 Invalid RefNo ', 'us_english', 598
execute rdt.rdtAddMsg 55904, 10, '55904 RefNo NotInASN', 'us_english', 598
execute rdt.rdtAddMsg 55905, 10, '55905 Need LOC      ', 'us_english', 598
execute rdt.rdtAddMsg 55906, 10, '55906 Invalid LOC   ', 'us_english', 598
execute rdt.rdtAddMsg 55907, 10, '55907 Diff facility ', 'us_english', 598
execute rdt.rdtAddMsg 55908, 10, '55908 AutoGenID Fail', 'us_english', 598
execute rdt.rdtAddMsg 55909, 10, '55909 Invalid Format', 'us_english', 598
execute rdt.rdtAddMsg 55910, 10, '55910 Duplicate ID  ', 'us_english', 598
execute rdt.rdtAddMsg 55911, 10, '55911 ID received   ', 'us_english', 598
execute rdt.rdtAddMsg 55912, 10, '55912 SKU is require', 'us_english', 598
execute rdt.rdtAddMsg 55913, 10, '55913 Invalid SKU   ', 'us_english', 598
execute rdt.rdtAddMsg 55914, 10, '55914 MultiSKUBarcod', 'us_english', 598
execute rdt.rdtAddMsg 55915, 10, '55915 SKU not in PO ', 'us_english', 598
execute rdt.rdtAddMsg 55916, 10, '55916 SKU not in ASN', 'us_english', 598
execute rdt.rdtAddMsg 55917, 10, '55917 Invalid QTY   ', 'us_english', 598
execute rdt.rdtAddMsg 55918, 10, '55918 Invalid QTY   ', 'us_english', 598
execute rdt.rdtAddMsg 55919, 10, '55919 Bad Cond Code ', 'us_english', 598
execute rdt.rdtAddMsg 55920, 10, '55920 AutoGenID Fail', 'us_english', 598
execute rdt.rdtAddMsg 55921, 10, '55921 Need Option   ', 'us_english', 598
execute rdt.rdtAddMsg 55922, 10, '55922 Invalid Option', 'us_english', 598
execute rdt.rdtAddMsg 55923, 10, '55923 Need Option   ', 'us_english', 598
execute rdt.rdtAddMsg 55924, 10, '55924 Invalid Option', 'us_english', 598
execute rdt.rdtAddMsg 55925, 10, '55925 NoLoginPrinter', 'us_english', 598
execute rdt.rdtAddMsg 55926, 10, '55926 DWNOTSetup    ', 'us_english', 598
execute rdt.rdtAddMsg 55927, 10, '55927 TgetDB Not Set', 'us_english', 598
execute rdt.rdtAddMsg 55928, 10, '55928 AutoGenID Fail', 'us_english', 598
execute rdt.rdtAddMsg 55929, 10, '55929 AutoGenID Fail', 'us_english', 598
execute rdt.rdtAddMsg 55930, 10, '55930 AutoGenID Fail', 'us_english', 598
execute rdt.rdtAddMsg 55931, 10, '55931 Bad ReasonCode', 'us_english', 598

--WMS-17244
execute rdt.rdtAddMsg 55932, 10, '55932 Invalid Format', 'us_english', 598
execute rdt.rdtAddMsg 55933, 10, '55933 Duplicate ID  ', 'us_english', 598
execute rdt.rdtAddMsg 55934, 10, '55934 ID received   ', 'us_english', 598

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 55901 and 55950
