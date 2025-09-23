--rdt_830ExtVal05
exec rdt.rdtDropMsg 246201 , 246250 

execute rdt.rdtAddMsg 246201, 10, '246201^DropID is used by another PS',   'us_english', 830,0 ,'246201^DropID Is Used By Another PS'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 246201 AND 246250

