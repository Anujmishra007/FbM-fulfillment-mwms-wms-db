-- rdt_898ExtScn07 - FCR-11903 Columbia Malaysia (CFS) UCC Receiving
-- Message range: 264801 - 264850

execute rdt.rdtDropMsg 264801, 264850

execute rdt.rdtAddMsg 264801, 10, '264801^CID:UCC no exist', 'us_english', 898
execute rdt.rdtAddMsg 264802, 10, '264802^ProcessType Req', 'us_english', 898
execute rdt.rdtAddMsg 264803, 10, '264803^Invalid ProcessT', 'us_english', 898
execute rdt.rdtAddMsg 264804, 10, '264804^UCC Required',     'us_english', 898
execute rdt.rdtAddMsg 264805, 10, '264805^SKU Required',     'us_english', 898
execute rdt.rdtAddMsg 264806, 10, '264806^Invalid SKU',      'us_english', 898
execute rdt.rdtAddMsg 264807, 10, '264807^QTY Required',     'us_english', 898
execute rdt.rdtAddMsg 264808, 10, '264808^Invalid QTY',      'us_english', 898
execute rdt.rdtAddMsg 264809, 10, '264809^UCC Update Fail',  'us_english', 898
execute rdt.rdtAddMsg 264810, 10, '264810^SKU Mismatch',     'us_english', 898
execute rdt.rdtAddMsg 264811, 10, '264811^Max UCC Reached',  'us_english', 898
execute rdt.rdtAddMsg 264812, 10, '264812^ASN Fully Rcvd',   'us_english', 898
execute rdt.rdtAddMsg 264813, 10, '264813^UCC Received',     'us_english', 898
execute rdt.rdtAddMsg 264814, 10, '264814^UCC Not Found',    'us_english', 898
execute rdt.rdtAddMsg 264815, 10, '264815^Invalid UCC Fmt',  'us_english', 898
execute rdt.rdtAddMsg 264816, 10, '264816^Rcpt Confirm Err', 'us_english', 898
execute rdt.rdtAddMsg 264817, 10, '264817^SKU on UCC diff',  'us_english', 898
execute rdt.rdtAddMsg 264818, 10, '264818^Multi SKU/UCC',    'us_english', 898
execute rdt.rdtAddMsg 264819, 10, '264819^LottUpdFail',      'us_english', 898
