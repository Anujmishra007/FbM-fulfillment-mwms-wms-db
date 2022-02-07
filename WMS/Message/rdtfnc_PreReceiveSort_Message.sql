-- rdtfnc_PreReceiveSort
exec rdt.rdtDropMsg 106001 , 106050

execute rdt.rdtAddMsg 106001, 10, '06001^ASN Required',     'us_english', 1825
execute rdt.rdtAddMsg 106002, 10, '06002^LANE Required',    'us_english', 1825
execute rdt.rdtAddMsg 106003, 10, '06003^ASN Not Exists',   'us_english', 1825
execute rdt.rdtAddMsg 106004, 10, '06004^Diff Facility',    'us_english', 1825
execute rdt.rdtAddMsg 106005, 10, '06005^Diff Storer',      'us_english', 1825
execute rdt.rdtAddMsg 106006, 10, '06006^ASN Closed',       'us_english', 1825
execute rdt.rdtAddMsg 106007, 10, '06007^Invalid Lane',     'us_english', 1825
execute rdt.rdtAddMsg 106008, 10, '06008^Diff Facility',    'us_english', 1825
execute rdt.rdtAddMsg 106009, 10, '06009^UCC Required',     'us_english', 1825
execute rdt.rdtAddMsg 106010, 10, '06010^UCC Not Exists',   'us_english', 1825
execute rdt.rdtAddMsg 106011, 10, '06011^UCC Received',     'us_english', 1825