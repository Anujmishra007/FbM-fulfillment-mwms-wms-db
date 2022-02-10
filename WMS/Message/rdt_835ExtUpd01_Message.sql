--rdt_835ExtUpd01
rdt.rdtDropMsg 168851 , 168900

execute rdt.rdtAddMsg 168851, 10, '168851 Loose UCC Err',   'us_english', 835

--WMS-17549
execute rdt.rdtAddMsg 168852, 10, '168852 Upd PInfo Err',   'us_english', 835
execute rdt.rdtAddMsg 168853, 10, '168853 Upd PInfo Err',   'us_english', 835

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 168851 AND 168900