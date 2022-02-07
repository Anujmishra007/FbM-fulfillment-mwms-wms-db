--rdtfnc_DynamicPick_UCCPickAndPack_Confirm
execute rdt.rdtdropmsg 65601, 65650

execute rdt.rdtAddMsg 65601, 10, '65601 UpdOrdersFail ', 'us_english', 949  
execute rdt.rdtAddMsg 65602, 10, '65602 UpdPickDtlFail', 'us_english', 949  
execute rdt.rdtAddMsg 65603, 10, '65603 Upd UCC Fail  ', 'us_english', 949  
execute rdt.rdtAddMsg 65604, 10, '65604 InsPackHdrFail', 'us_english', 949  
execute rdt.rdtAddMsg 65605, 10, '65605 InsPKInfoFail ', 'us_english', 949  
execute rdt.rdtAddMsg 65606, 10, '65606 InsPackDtlFail', 'us_english', 949  
