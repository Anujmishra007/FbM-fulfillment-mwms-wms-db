--rdt_PTLPiece_Assign_DropID02
execute rdt.rdtDropMsg 170901, 170950

execute rdt.rdtAddMsg 170901, 10, '170901^Need DropID  ', 'us_english', 803
execute rdt.rdtAddMsg 170902, 10, '170902^Bad DropID   ', 'us_english', 803
execute rdt.rdtAddMsg 170903, 10, '170903^Diff batch   ', 'us_english', 803
execute rdt.rdtAddMsg 170904, 10, '170904^Not enuf Pos ', 'us_english', 803
execute rdt.rdtAddMsg 170905, 10, '170905^INS Log fail ', 'us_english', 803
execute rdt.rdtAddMsg 170906, 10, '170906^Invalid DPLoc', 'us_english', 803

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 170901 and 170950

