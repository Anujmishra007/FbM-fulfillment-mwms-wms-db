-- FCR-6483
-- rrdt_1864ConfirmSP03
execute rdt.rdtDropMsg 243551, 243600

execute rdt.rdtAddMsg 243551, 10, '243551IncorrectSetup',      'us_english', 1864
execute rdt.rdtAddMsg 243552, 10, '243552IncorrectSetup',      'us_english', 1864
execute rdt.rdtAddMsg 243553, 10, '243553UPD PKDtl Fail',      'us_english', 1864
execute rdt.rdtAddMsg 243554, 10, '243554INS PKSNO Fail',      'us_english', 1864
execute rdt.rdtAddMsg 243555, 10, '243555UPD SNO Fail  ',      'us_english', 1864
execute rdt.rdtAddMsg 243556, 10, '243556SNO NOT TALLY ',      'us_english', 1864
execute rdt.rdtAddMsg 243557, 10, '243557UPD UCC fail  ',      'us_english', 1864
execute rdt.rdtAddMsg 243558, 10, '243558ID:           ',      'us_english', 1864
execute rdt.rdtAddMsg 243559, 10, '243559InsPHdrFail',         'us_english', 1864, 0, '243559 Insert Packheader Fail'
execute rdt.rdtAddMsg 243560, 10, '243560GenLabelFail',        'us_english', 1864, 0, '243560 Generate Label Fail'
execute rdt.rdtAddMsg 243561, 10, '243561InsPackDtlFail',      'us_english', 1864, 0, '243561 Insert PackDetail Fail'
execute rdt.rdtAddMsg 243562, 10, '243562UpdPickDtlFail',      'us_english', 1864, 0, '243562 Update PickDetail Fail'
execute rdt.rdtAddMsg 243563, 10, '243563UpdPackDtlFail',      'us_english', 1864, 0, '243563 Update PackDetail Fail'
execute rdt.rdtAddMsg 243564, 10, '243564InsPDInfoFail',       'us_english', 1864, 0, '243564 Insert PackDetailInfo Fail'
execute rdt.rdtAddMsg 243565, 10, '243565UpdPDInfoFail',       'us_english', 1864, 0, '243565 Update PackDetailInfo Fail'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 243551 AND 243600