--rdt_840ExtUpd09
execute rdt.rdtdropmsg 163301 , 163350
 	
execute rdt.rdtAddMsg 163301, 10, '63301^Upd PackInfo Err',    'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 163301 AND 163350



