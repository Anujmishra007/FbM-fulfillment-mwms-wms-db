-- rdt_CaseIDCapture_Confirm
execute rdt.rdtDropMsg 86001, 86050

execute rdt.rdtAddMsg 86001, 10, '86001 BrandNoCapture', 'us_english', 877
execute rdt.rdtAddMsg 86002, 10, '86002 SKU NotIn PSNO', 'us_english', 877
execute rdt.rdtAddMsg 86003, 10, '86003 CaseID scanned', 'us_english', 877
execute rdt.rdtAddMsg 86004, 10, '86004 Batch NotInPS ', 'us_english', 877
execute rdt.rdtAddMsg 86005, 10, '86005 UPD PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 86006, 10, '86006 UPD PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 86007, 10, '86007 GetKey Fail   ', 'us_english', 877
execute rdt.rdtAddMsg 86008, 10, '86008 INS PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 86009, 10, '86009 UPD PKDtl Fail', 'us_english', 877
execute rdt.rdtAddMsg 86010, 10, '86010 NoPKDtl Offset', 'us_english', 877
execute rdt.rdtAddMsg 86011, 10, '86011 NotFullyOffset', 'us_english', 877
