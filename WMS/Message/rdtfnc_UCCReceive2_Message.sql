-- rdtfnc_UCCReceive2
exec rdt.rdtDropMsg 111501 , 111550

execute rdt.rdtAddMsg 111501, 10, '11501^Need Ctn ID',      'us_english', 1582
execute rdt.rdtAddMsg 111502, 10, '11502^Need ASN',         'us_english', 1582
execute rdt.rdtAddMsg 111503, 10, '11503^ASN Not Exists',   'us_english', 1582
execute rdt.rdtAddMsg 111504, 10, '11504^ASN No Ctn ID',    'us_english', 1582
execute rdt.rdtAddMsg 111505, 10, '11505^ASN Not Exists',   'us_english', 1582
execute rdt.rdtAddMsg 111506, 10, '11506^Diff Facility',    'us_english', 1582
execute rdt.rdtAddMsg 111507, 10, '11507^Diff Storer',      'us_english', 1582
execute rdt.rdtAddMsg 111508, 10, '11508^ASN CANC',         'us_english', 1582
execute rdt.rdtAddMsg 111509, 10, '11509^ASN Closed',       'us_english', 1582
execute rdt.rdtAddMsg 111510, 10, '11510^Ctn Multi ASN',    'us_english', 1582
execute rdt.rdtAddMsg 111511, 10, '11511^SKU Required',     'us_english', 1582
execute rdt.rdtAddMsg 111512, 10, '11512^Invalid SKU',      'us_english', 1582
execute rdt.rdtAddMsg 111513, 10, '11513^MultiSKUBarcod',   'us_english', 1582
execute rdt.rdtAddMsg 111514, 10, '11514^SKU Not In Ctn',   'us_english', 1582
execute rdt.rdtAddMsg 111515, 10, '11515^Qty Required',     'us_english', 1582
execute rdt.rdtAddMsg 111516, 10, '11516^Invalid Qty',      'us_english', 1582
execute rdt.rdtAddMsg 111517, 10, '11517^Invalid Format',   'us_english', 1582
execute rdt.rdtAddMsg 111518, 10, '11518^Duplicate ID',     'us_english', 1582
execute rdt.rdtAddMsg 111519, 10, '11519^Need LOC',         'us_english', 1582
execute rdt.rdtAddMsg 111520, 10, '11520^Invalid LOC',      'us_english', 1582
execute rdt.rdtAddMsg 111521, 10, '11521^Diff Facility',    'us_english', 1582
execute rdt.rdtAddMsg 111522, 10, '11522^Nothing To Rcv',   'us_english', 1582
execute rdt.rdtAddMsg 111523, 10, '11523^Upd RcvLog Err',   'us_english', 1582
execute rdt.rdtAddMsg 111524, 10, '11524^Ins RcvLog Err',   'us_english', 1582
execute rdt.rdtAddMsg 111525, 10, '11525^Nothing To Rcv',   'us_english', 1582
execute rdt.rdtAddMsg 111526, 10, '11526^RECEIVED QTY',     'us_english', 1582
execute rdt.rdtAddMsg 111527, 10, '11527^MISMATCH',         'us_english', 1582
execute rdt.rdtAddMsg 111528, 10, '11528^Upd RcvLog Err',   'us_english', 1582

select * from rdt.rdtmsg (nolock) where message_id between 111501 and 111550