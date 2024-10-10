-- rdtfnc_PickPiece
-- FCR-540
execute rdt.rdtDropMsg 221301, 221350

execute rdt.rdtAddMsg 221301, 10, '221301DiffToLoc',        'us_english', 839
execute rdt.rdtAddMsg 221302, 10, '221302CannotReturn',     'us_english', 839
execute rdt.rdtAddMsg 221303, 10, '221303IncorrectSetup',   'us_english', 839
execute rdt.rdtAddMsg 221304, 10, '221304MoveItemFail',     'us_english', 839
execute rdt.rdtAddMsg 221305, 10, '221305UpdDateFail',      'us_english', 839
execute rdt.rdtAddMsg 221306, 10, '221306ToLocNeeded',      'us_english', 839
execute rdt.rdtAddMsg 221307, 10, '221307InvalidLoc',       'us_english', 839
execute rdt.rdtAddMsg 221308, 10, '221308CdlookupErr',      'us_english', 839

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 221301 AND 221350
