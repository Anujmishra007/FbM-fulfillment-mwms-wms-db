-- rdt_515ExtScn02
-- 256801 - 256850


execute rdt.rdtDropMsg 256801, 256850

execute rdt.rdtAddMsg 256801, 10, '256801 InvOption',       'us_english', 515, 0, '256801 Invalid option'
execute rdt.rdtAddMsg 256802, 10, '256802 CartTypEmpty',    'us_english', 515, 0, '256802 Carton type is required'
execute rdt.rdtAddMsg 256803, 10, '256803 CartCntEmpty',    'us_english', 515, 0, '256803 Carton count is required'
execute rdt.rdtAddMsg 256804, 10, '256804 UpdMobrecErr',    'us_english', 515, 0, '256804 Update MOBREC failed'
execute rdt.rdtAddMsg 256805, 10, '256805 ToLocRequired',   'us_english', 515, 0, '256805 ToLoc is required'
execute rdt.rdtAddMsg 256806, 10, '256806 InvalidLoc',      'us_english', 515, 0, '256806 Invalid ToLoc'
execute rdt.rdtAddMsg 256807, 10, '256807 DiffFacility',    'us_english', 515, 0, '256807 Different facility'
execute rdt.rdtAddMsg 256808, 10, '256808 InsDropIdFail',   'us_english', 515, 0, '256808 Generate DropId failed'
execute rdt.rdtAddMsg 256809, 10, '256809 InsDropDtlFail',  'us_english', 515, 0, '256809 Generate DropDetail failed'
execute rdt.rdtAddMsg 256810, 10, '256810 CarTypeExists',   'us_english', 515, 0, '256810 DropID + CartonType already exists'
execute rdt.rdtAddMsg 256811, 10, '256811 InvOption',       'us_english', 515, 0, '256811 Invalid option'
execute rdt.rdtAddMsg 256812, 10, '256812 InsDropIdFail',   'us_english', 515, 0, '256812 Generate DropId failed'
execute rdt.rdtAddMsg 256813, 10, '256813 InsDropDtlFail',  'us_english', 515, 0, '256813 Generate DropDetail failed'
execute rdt.rdtAddMsg 256814, 10, '256814 InsDropDtlFail',  'us_english', 515, 0, '256814 Generate DropDetail failed'
execute rdt.rdtAddMsg 256815, 10, '256815 InvChanged',      'us_english', 515, 0, '256815 Inventory changed'
execute rdt.rdtAddMsg 256816, 10, '256816 InvChanged',      'us_english', 515, 0, '256816 Inventory changed'
execute rdt.rdtAddMsg 256817, 10, '256817 ToIDRequired',    'us_english', 515, 0, '256817 ToID is empty'
execute rdt.rdtAddMsg 256818, 10, '256818 DropDtlExists',   'us_english', 515, 0, '256818 DropID + CartonType already exists'
execute rdt.rdtAddMsg 256819, 10, '256819 ToIDDuplicate',   'us_english', 515, 0, '256819 ToID exists in another Loc'
execute rdt.rdtAddMsg 256820, 10, '256820 InvCartType',     'us_english', 515, 0, '256820 Invalid carton type'

select * from rdt.rdtmsg (nolock) where message_id between 256801 and 256850