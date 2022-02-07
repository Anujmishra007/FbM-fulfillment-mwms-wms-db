-- rdt_838ConfirmSP04
execute rdt.rdtDropMsg 130001, 130050

execute rdt.rdtAddMsg 130001, 10, '30001^InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 130002, 10, '30002^No UDF04      ', 'us_english', 838
execute rdt.rdtAddMsg 130003, 10, '30003^Get Track Fail', 'us_english', 838
execute rdt.rdtAddMsg 130004, 10, '30004^GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 130005, 10, '30005^GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 130006, 10, '30006^InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 130007, 10, '30007^UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 130008, 10, '30008^INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 130009, 10, '30009^UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 130010, 10, '30010^UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 130011, 10, '30011^INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 130012, 10, '30012^SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 130013, 10, '30013^Upd CaseID Err', 'us_english', 838
execute rdt.rdtAddMsg 130014, 10, '30014^Upd CaseID Err', 'us_english', 838
execute rdt.rdtAddMsg 130015, 10, '30015^GetDetKeyFail ', 'us_english', 838
execute rdt.rdtAddMsg 130016, 10, '30016^Ins PDtl Fail ', 'us_english', 838
execute rdt.rdtAddMsg 130017, 10, '30017^INS RefKeyFail', 'us_english', 838
execute rdt.rdtAddMsg 130018, 10, '30018^Upd CaseID Err', 'us_english', 838
execute rdt.rdtAddMsg 130019, 10, '30019^Upd CaseID Err', 'us_english', 838

--WMS-12052
execute rdt.rdtAddMsg 130020, 10, '30020^INSPackSNOFail', 'us_english', 838
execute rdt.rdtAddMsg 130021, 10, '30021^SNO ady scan',   'us_english', 838
execute rdt.rdtAddMsg 130022, 10, '30022^DEL TmpSN Fail', 'us_english', 838
execute rdt.rdtAddMsg 130023, 10, '30023^Offset error',   'us_english', 838
execute rdt.rdtAddMsg 130024, 10, '30024^Offset error',   'us_english', 838

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130001 AND 130050

