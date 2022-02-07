--rdt_Lottable_Format_RegularExpression
rdt.rdtDropMsg 173751 , 173800		

execute rdt.rdtAddMsg 173751, 10, '173751 InvalidFormat',    'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 173751 AND 173800	