-- rdtfnc_PickPiece
-- FCR-6584
execute rdt.rdtDropMsg 249701, 249750

execute rdt.rdtAddMsg 249701, 10, '249701DiffToLoc',        'us_english', 839
execute rdt.rdtAddMsg 249702, 10, '249702CannotReturn',     'us_english', 839
execute rdt.rdtAddMsg 249703, 10, '249703IncorrectSetup',   'us_english', 839
execute rdt.rdtAddMsg 249704, 10, '249704MoveItemFail',     'us_english', 839
execute rdt.rdtAddMsg 249705, 10, '249705UpdDateFail',      'us_english', 839
execute rdt.rdtAddMsg 249706, 10, '249706ToLocNeeded',      'us_english', 839
execute rdt.rdtAddMsg 249707, 10, '249707InvalidLoc',       'us_english', 839
execute rdt.rdtAddMsg 249708, 10, '249708CdlookupErr',      'us_english', 839
execute rdt.rdtAddMsg 249709, 10, '249709nspg_GetKey Fail',      'us_english', 839
execute rdt.rdtAddMsg 249710, 10, '249710ITrnSerialNoMove Fail',      'us_english', 839
execute rdt.rdtAddMsg 249711, 10, '249711Update SN ID Failed',      'us_english', 839

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 249701 AND 249750
