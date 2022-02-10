-- rdt_1829ExtUpd02
exec rdt.rdtDropMsg 118901 , 118950

execute rdt.rdtAddMsg 118901, 10, '18901^Upd PreRcv Err',   'us_english', 1829
execute rdt.rdtAddMsg 118902, 10, '18902^Upd PreRcv Err',   'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 118901 AND 118950