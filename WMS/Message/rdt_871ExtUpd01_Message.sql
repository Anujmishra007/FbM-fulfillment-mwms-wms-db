-- rdt_871ExtUpd01
exec rdt.rdtDropMsg 114901 , 114950

execute rdt.rdtAddMsg 114901, 10, '14901^DEL SrNo ERROR',   'us_english', 871
execute rdt.rdtAddMsg 114902, 10, '14902^DEL SrNo ERROR',   'us_english', 871

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114901 AND 114950