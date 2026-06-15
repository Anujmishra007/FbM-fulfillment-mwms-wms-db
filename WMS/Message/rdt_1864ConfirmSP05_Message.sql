-- 269801 - 269850
execute rdt.rdtDropMsg 269801, 269850

execute rdt.rdtAddMsg 269801, 10, '269801^IncorrectSetup',      'us_english', 1864
execute rdt.rdtAddMsg 269802, 10, '269802^IncorrectSetup',      'us_english', 1864
execute rdt.rdtAddMsg 269803, 10, '269803^ID status is not OK', 'us_english', 1864
execute rdt.rdtAddMsg 269804, 10, '269804^UPD PKDtl Fail',      'us_english', 1864
execute rdt.rdtAddMsg 269805, 10, '269805^INS PKSNO Fail',      'us_english', 1864
execute rdt.rdtAddMsg 269806, 10, '269806^UPD SNO Fail',        'us_english', 1864
execute rdt.rdtAddMsg 269807, 10, '269807^SNO NOT TALLY',       'us_english', 1864
execute rdt.rdtAddMsg 269808, 10, '269808^UPD UCC fail',        'us_english', 1864
execute rdt.rdtAddMsg 269809, 10, '269809^UPD UCC fail',        'us_english', 1864

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 269801 AND 269850