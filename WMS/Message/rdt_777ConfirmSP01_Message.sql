-- rdt_Pack_Confirm
-- FCR-9200
execute rdt.rdtDropMsg 251851, 251900

execute rdt.rdtAddMsg 251851, 10, '251851InsPHdrFail   ', 'us_english', 777
execute rdt.rdtAddMsg 251852, 10, '251852GenLabelNoFail', 'us_english', 777
execute rdt.rdtAddMsg 251853, 10, '251853GenLabelNoFail', 'us_english', 777
execute rdt.rdtAddMsg 251854, 10, '251854InsPackDtlFail', 'us_english', 777
execute rdt.rdtAddMsg 251855, 10, '251855UpdPackDtlFail', 'us_english', 777
execute rdt.rdtAddMsg 251856, 10, '251856INSPackInfFail', 'us_english', 777
execute rdt.rdtAddMsg 251857, 10, '251857UPDPackInfFail', 'us_english', 777
execute rdt.rdtAddMsg 251858, 10, '251858UPD UCC Fail  ', 'us_english', 777
execute rdt.rdtAddMsg 251859, 10, '251859SN QTYNotTally', 'us_english', 777
execute rdt.rdtAddMsg 251860, 10, '251860INSPackSNOFail', 'us_english', 777
execute rdt.rdtAddMsg 251861, 10, '251861SNO ady scan  ', 'us_english', 777
execute rdt.rdtAddMsg 251862, 10, '251862DEL TmpSN Fail', 'us_english', 777
execute rdt.rdtAddMsg 251863, 10, '251863Offset error  ', 'us_english', 777
execute rdt.rdtAddMsg 251864, 10, '251864Offset error  ', 'us_english', 777
execute rdt.rdtAddMsg 251865, 10, '251865INS RDSNo Fail', 'us_english', 777
execute rdt.rdtAddMsg 251866, 10, '251866SNO ady scan  ', 'us_english', 777
execute rdt.rdtAddMsg 251867, 10, '251867INS PDInfoFail', 'us_english', 777
execute rdt.rdtAddMsg 251868, 10, '251868UPD PDInfoFail', 'us_english', 777
execute rdt.rdtAddMsg 251869, 10, '251869GenPkdKeyFail' , 'us_english', 777, 0, '251869 Generate PickDetailKey Failed'
execute rdt.rdtAddMsg 251870, 10, '251870INS PackHeader Fail' , 'us_english', 777, 0, '251870 Insert PackHeader Failed'
execute rdt.rdtAddMsg 251871, 10, '251871GenLabelNoFail', 'us_english', 777
execute rdt.rdtAddMsg 251872, 10, '251872GenLabelNoFail', 'us_english', 777
execute rdt.rdtAddMsg 251873, 10, '251873InsPackDtlFail', 'us_english', 777
execute rdt.rdtAddMsg 251874, 10, '251874UpdPackDtlFail', 'us_english', 777
execute rdt.rdtAddMsg 251875, 10, '251875INSPackInfFail', 'us_english', 777
execute rdt.rdtAddMsg 251876, 10, '251876UPDPackInfFail', 'us_english', 777
execute rdt.rdtAddMsg 251877, 10, '251877GenPkdKeyFail' , 'us_english', 777, 0, '251877 Generate PickDetailKey Failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) where Message_ID BETWEEN  251851 AND 251900