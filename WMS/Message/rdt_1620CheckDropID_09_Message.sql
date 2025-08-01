execute rdt.rdtDropMsg 238351, 238400

execute rdt.rdtAddMsg 238351, 10, '238351Drop ID Diff','us_english', 1620 ,0, 'DropID cannot be different'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 238351 AND 238400
