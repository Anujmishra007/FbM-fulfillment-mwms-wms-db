--rdt_840ExtPackCfm03
execute rdt.rdtdropmsg 199401 , 199450	

execute rdt.rdtAddMsg 199401, 10, '199401 GetRightFail ',   'us_english', 840
execute rdt.rdtAddMsg 199402, 10, '199402 AutoMBOLPack ',   'us_english', 840
execute rdt.rdtAddMsg 199403, 10, '199403 ConfPackFail ',   'us_english', 840
execute rdt.rdtAddMsg 199404, 10, '199404 Upd CaseId Er',   'us_english', 840
execute rdt.rdtAddMsg 199405, 10, '199405 Exec ITF Fail',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 199401 AND 199450	
