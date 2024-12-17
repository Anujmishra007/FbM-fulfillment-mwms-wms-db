

-- rdt_830ExtUpd01_Message
execute rdt.rdtDropMsg 226201, 226250

execute rdt.rdtAddMsg 226201, 10 ,'226201 UpdUDF01Fail','us_english' ,830
execute rdt.rdtAddMsg 226202, 10 ,'226202 UpdUDF01Fail','us_english' ,830
execute rdt.rdtAddMsg 226203, 10 ,'226203 UpdUDF01Fail','us_english' ,830

select * from rdt.rdtmsg (nolock) where message_id between 226201 AND 226250

GO
