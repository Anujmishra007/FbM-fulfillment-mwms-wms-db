--rdtfnc_DynamicPick_UCCPickAndPack_Confirm
execute rdt.rdtdropmsg 81001, 81050

execute rdt.rdtAddMsg 81001, 10, '81001 UPDOrdersFail ', 'us_english', 580  
execute rdt.rdtAddMsg 81002, 10, '81002 UpdPickDtlFail', 'us_english', 580  
execute rdt.rdtAddMsg 81003, 10, '81003 Upd UCC Fail  ', 'us_english', 580  
execute rdt.rdtAddMsg 81004, 10, '81004 InsPackHdrFail', 'us_english', 580  
execute rdt.rdtAddMsg 81005, 10, '81005 InsPKInfoFail ', 'us_english', 580
execute rdt.rdtAddMsg 81006, 10, '81006 InsPackDtlFail', 'us_english', 580  
