--rdt_514ExtUpdSP02
rdt.rdtDropMsg 141451 , 141500

execute rdt.rdtAddMsg 141451, 10, '41451^No Tran Record',   'us_english', 514
execute rdt.rdtAddMsg 141452, 10, '41452^UpdTrnsfDtFail',   'us_english', 514
execute rdt.rdtAddMsg 141453, 10, '41453^Upd UCC Fail',     'us_english', 514
execute rdt.rdtAddMsg 141454, 10, '41454^Upd UCC Fail',     'us_english', 514
execute rdt.rdtAddMsg 141455, 10, '41455^UCC Multi Tran',   'us_english', 514
execute rdt.rdtAddMsg 141456, 10, '41456^UnLock PMV Err',   'us_english', 514


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141451 AND 141500