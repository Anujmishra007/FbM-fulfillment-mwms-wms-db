-- UWP-53936
EXECUTE rdt.rdtDropMsg 264751, 264800

EXECUTE rdt.rdtAddMsg 264751 ,10, '264751^INS @tPackDetail Fail',             'us_english', 0, 0, '264751 Insert into @tPackDetail Fail'
EXECUTE rdt.rdtAddMsg 264752 ,10, '264752^UPD PackDetail Fail',               'us_english', 0, 0, '264752 Update PackDetail Fail'
EXECUTE rdt.rdtAddMsg 264753 ,10, '264753^INS @tPickDetail Fail',             'us_english', 0, 0, '264753 Insert into @tPickDetail Fail'
EXECUTE rdt.rdtAddMsg 264754 ,10, '264754^UPD PICKDETAIL Fail',               'us_english', 0, 0, '264754 Update PickDetail Fail'
EXECUTE rdt.rdtAddMsg 264755 ,10, '264755^INS rdtArchiveTote_Audit Fail',     'us_english', 0, 0, '264755 Insert into rdtArchiveTote_Audit Fail'
EXECUTE rdt.rdtAddMsg 264756 ,10, '264756^ispGenTransmitLog2 Fail',           'us_english', 0, 0, '264756 Exec ispGenTransmitLog2 Fail'
EXECUTE rdt.rdtAddMsg 264757 ,10, '264757^ToteID Not 10 char',                'us_english', 0, 0, '264757 ToteID Not 10 char'
EXECUTE rdt.rdtAddMsg 264758 ,10, '264758^InvToteID',                         'us_english', 0, 0, '264758 ToteID first 4 chars must be 00000'
EXECUTE rdt.rdtAddMsg 264759 ,10, '264759^ToteID Not Exists',                 'us_english', 0, 0, '264759 ToteID Not Exists'

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 264751 AND 264800