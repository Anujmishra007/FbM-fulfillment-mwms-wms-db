--rdt_PTLStation_Assign_OrderPosTote
rdt.rdtDropMsg 147901 , 147950

execute rdt.rdtAddMsg 147901, 10, '47901^Need OrderKey',    'us_english', 805
execute rdt.rdtAddMsg 147902, 10, '47902^Bad OrderKey',     'us_english', 805
execute rdt.rdtAddMsg 147903, 10, '47903^Diff storer',      'us_english', 805
execute rdt.rdtAddMsg 147904, 10, '47904^Diff facility',    'us_english', 805
execute rdt.rdtAddMsg 147905, 10, '47905^Order CANCEL',     'us_english', 805
execute rdt.rdtAddMsg 147906, 10, '47906^Order NotAlloc',   'us_english', 805
execute rdt.rdtAddMsg 147907, 10, '47907^Order picked',     'us_english', 805
execute rdt.rdtAddMsg 147908, 10, '47908^OrderAssigned',    'us_english', 805
execute rdt.rdtAddMsg 147909, 10, '47909^Order no task',    'us_english', 805
execute rdt.rdtAddMsg 147910, 10, '47910^NoMorePosition',   'us_english', 805
execute rdt.rdtAddMsg 147911, 10, '47911^Need Position',    'us_english', 805
execute rdt.rdtAddMsg 147912, 10, '47912^Bad Position',     'us_english', 805
execute rdt.rdtAddMsg 147913, 10, '47913^Pos assigned',     'us_english', 805
execute rdt.rdtAddMsg 147914, 10, '47914^Need CartonID',    'us_english', 805
execute rdt.rdtAddMsg 147915, 10, '47915^Invalid Format ',  'us_english', 805
execute rdt.rdtAddMsg 147916, 10, '47916^Carton Assigned',  'us_english', 805
execute rdt.rdtAddMsg 147917, 10, '47917^INS Log Fail',     'us_english', 805
execute rdt.rdtAddMsg 147918, 10, '47918^UPD Log Fail ',    'us_english', 805

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 147901 AND 147950