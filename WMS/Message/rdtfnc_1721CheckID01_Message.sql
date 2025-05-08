execute rdt.rdtDropMsg 219301, 219350


execute rdt.rdtAddMsg 219301, 10, '219301 Need ID',               'us_english', 1721
execute rdt.rdtAddMsg 219302, 10, '219302 Invalid ID',            'us_english', 1721
execute rdt.rdtAddMsg 219303, 10, '219303 ID had shipped',        'us_english', 1721
execute rdt.rdtAddMsg 219304, 10, '219304 Upd PalletDetail fail', 'us_english', 1721
execute rdt.rdtAddMsg 219305, 10, '219305 Upd LOTxLOCxID fail',   'us_english', 1721
execute rdt.rdtAddMsg 219307, 10, '219307 UpdPickDetail Fail',   'us_english', 1721

--FCR-953
execute rdt.rdtAddMsg 219306, 10, '219306NotAllowToMove',         'us_english', 1721

IF NOT EXISTS (SELECT 1 FROM rdt.RDTMSG where Message_ID=1721)
INSERT INTO rdt.RDTMSG(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType)
VALUES (1721,'ENG','FNC','PALLET MOVE','rdtfnc_Pallet_Move','4')

SELECT * FROM rdt.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 219301 AND 219350

