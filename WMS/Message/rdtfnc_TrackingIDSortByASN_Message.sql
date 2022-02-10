--rdtfnc_TrackingIDSortByASN
rdt.rdtDropMsg 150001 , 150050

execute rdt.rdtAddMsg 150001, 10, '50001^Invalid RefNo',    'us_english', 644
execute rdt.rdtAddMsg 150002, 10, '50002^RefNo NotInASN',   'us_english', 644
execute rdt.rdtAddMsg 150003, 10, '50003^Need ASN or PO',   'us_english', 644
execute rdt.rdtAddMsg 150004, 10, '50004^ASN&PONotExist',   'us_english', 644
execute rdt.rdtAddMsg 150005, 10, '50005^ASN Not Exist',    'us_english', 644
execute rdt.rdtAddMsg 150006, 10, '50006^PO Not Exist',     'us_english', 644
execute rdt.rdtAddMsg 150007, 10, '50007^PO Not In ASN',    'us_english', 644
execute rdt.rdtAddMsg 150008, 10, '50008^ASN not exist',    'us_english', 644
execute rdt.rdtAddMsg 150009, 10, '50009^MultiPO In ASN',   'us_english', 644
execute rdt.rdtAddMsg 150010, 10, '50010^PO not exist',     'us_english', 644
execute rdt.rdtAddMsg 150011, 10, '50011^MultiASN in PO',   'us_english', 644
execute rdt.rdtAddMsg 150012, 10, '50012^Diff facility',    'us_english', 644
execute rdt.rdtAddMsg 150013, 10, '50013^NotInStorerGrp',   'us_english', 644
execute rdt.rdtAddMsg 150014, 10, '50014^Diff storer',      'us_english', 644
execute rdt.rdtAddMsg 150015, 10, '50015^ASN is closed',    'us_english', 644
execute rdt.rdtAddMsg 150016, 10, '50016^Need LOC',         'us_english', 644
execute rdt.rdtAddMsg 150017, 10, '50017^Invalid LOC',      'us_english', 644
execute rdt.rdtAddMsg 150018, 10, '50018^Diff facility',    'us_english', 644
execute rdt.rdtAddMsg 150019, 10, '50019^Need Value',       'us_english', 644
execute rdt.rdtAddMsg 150020, 10, '50020^Need SKU',         'us_english', 644
execute rdt.rdtAddMsg 150021, 10, '50021^Invalid SKU',      'us_english', 644
execute rdt.rdtAddMsg 150022, 10, '50022^MultiBarcodSKU',   'us_english', 644
execute rdt.rdtAddMsg 150023, 10, '50023^SKU NOTIN SKU',    'us_english', 644
execute rdt.rdtAddMsg 150024, 10, '50024^Need Child ID',    'us_english', 644
execute rdt.rdtAddMsg 150025, 10, '50025^Invalid Format',   'us_english', 644
execute rdt.rdtAddMsg 150026, 10, '50026^TrackID Scanned',  'us_english', 644
execute rdt.rdtAddMsg 150027, 10, '50027^Need Value',       'us_english', 644
execute rdt.rdtAddMsg 150028, 10, '50028^Need Id',          'us_english', 644
execute rdt.rdtAddMsg 150029, 10, '50029^Invalid Format',   'us_english', 644
execute rdt.rdtAddMsg 150030, 10, '50030^Duplicate ID',     'us_english', 644
execute rdt.rdtAddMsg 150031, 10, '50031^ID received',      'us_english', 644
execute rdt.rdtAddMsg 150032, 10, '50032^Need Parent ID',   'us_english', 644
execute rdt.rdtAddMsg 150033, 10, '50033^Invalid Format',   'us_english', 644
execute rdt.rdtAddMsg 150034, 10, '50034^Pallet Closed',    'us_english', 644
execute rdt.rdtAddMsg 150035, 10, '50035^Over Scanned',     'us_english', 644
execute rdt.rdtAddMsg 150036, 10, '50036^Invalid Loc',      'us_english', 644
execute rdt.rdtAddMsg 150037, 10, 'Release Done',           'us_english', 644


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 150001 AND 150050