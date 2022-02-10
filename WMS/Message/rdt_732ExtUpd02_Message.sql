--rdt_732ExtUpd02
execute rdt.rdtDropMsg 146201 , 146250

execute rdt.rdtAddMsg 146201, 10, '46201^Qty Required',     'us_english', 732

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 146201 AND 146250