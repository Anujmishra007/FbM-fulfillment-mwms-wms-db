--rdt_593Testprinter01 
execute rdt.rdtDropMsg 116151,116156

Execute rdt.rdtAddMsg 116151 , 10, '16151^Printer Req',     'us_English', 593
Execute rdt.rdtAddMsg 116152 , 10, '16152^Printer Inv',     'us_English', 593
Execute rdt.rdtAddMsg 116153 , 10, '16153InsertLBLFail',    'us_English', 593
Execute rdt.rdtAddMsg 116154 , 10, '16154InsertBarTdFail',  'us_English', 593
Execute rdt.rdtAddMsg 116155 , 10, '16155^getkeyfail',      'us_English', 593
Execute rdt.rdtAddMsg 116156 , 10, '16156InsertPPRFail',    'us_English', 593

SELECT * FROM RDT.RDTMSG WITH (NOLOCK) WHERE MESSAGE_ID BETWEEN 116151 AND 116156