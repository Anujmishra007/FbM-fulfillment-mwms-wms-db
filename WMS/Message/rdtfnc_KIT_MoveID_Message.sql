--rdtfnc_KIT_MoveID
--252901 - 252950

execute rdt.rdtDropMsg 252901, 252950


execute rdt.rdtAddMsg 252901, 10, '252901^ID needed',      'us_english'
execute rdt.rdtAddMsg 252902, 10, '252902^IDNotInKit',     'us_english', 1873, 0, '252902:ID Not in KIT'
execute rdt.rdtAddMsg 252903, 10, '252903^LOC needed',     'us_english'
execute rdt.rdtAddMsg 252904, 10, '252904^Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 252905, 10, '252904^Diff facility',  'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 252901 and 252950