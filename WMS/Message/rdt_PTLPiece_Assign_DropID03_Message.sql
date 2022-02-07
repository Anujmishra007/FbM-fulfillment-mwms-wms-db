--rdt_PTLPiece_Assign_DropID03
execute rdt.rdtDropMsg 176001, 176050

execute rdt.rdtAddMsg 176001, 10, '176001^Need DropID  ', 'us_english', 803
execute rdt.rdtAddMsg 176002, 10, '176002^Bad DropID   ', 'us_english', 803
execute rdt.rdtAddMsg 176003, 10, '176003^Diff batch   ', 'us_english', 803
execute rdt.rdtAddMsg 176004, 10, '176004^Not enuf Pos ', 'us_english', 803
execute rdt.rdtAddMsg 176005, 10, '176005^INS Log fail ', 'us_english', 803
execute rdt.rdtAddMsg 176006, 10, '176006^UPD Log fail ', 'us_english', 803
execute rdt.rdtAddMsg 176007, 10, '176007^Invalid DPLoc', 'us_english', 803
execute rdt.rdtAddMsg 176008, 10, '176008^Upd Log Fail ', 'us_english', 803

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 176001 and 176050

