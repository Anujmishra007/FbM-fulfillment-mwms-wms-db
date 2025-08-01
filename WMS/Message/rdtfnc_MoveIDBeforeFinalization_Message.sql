--FCR-3830
--rdtfnc_MoveIDBeforeFinalization
exec rdt.rdtDropMsg 237751 , 237800

execute rdt.rdtAddMsg 237751, 10, '237751 ID Needed',             'us_english', 664
execute rdt.rdtAddMsg 237752, 10, '237752 Stock Exists',          'us_english', 664
execute rdt.rdtAddMsg 237753, 10, '237753 Invalid ID',            'us_english', 664
execute rdt.rdtAddMsg 237754, 10, '237754 Invalid ASN',           'us_english', 664, 0, '237754 ASN is finalized or cancelled'
execute rdt.rdtAddMsg 237755, 10, '237755 Loc Needed',            'us_english', 664
execute rdt.rdtAddMsg 237756, 10, '237756 Invalid Loc',           'us_english', 664
execute rdt.rdtAddMsg 237757, 10, '237757 Diff Facility',         'us_english', 664, 0, '237757 Different facility'
execute rdt.rdtAddMsg 237758, 10, '237758 No Record',             'us_english', 664, 0, '237758 No record is found in ASN Details'
execute rdt.rdtAddMsg 237759, 10, '237759 From Loc > 1',          'us_english', 664
execute rdt.rdtAddMsg 237760, 10, '237760 Invalid Loc',           'us_english', 664
execute rdt.rdtAddMsg 237761, 10, '237761 Diff Facility',         'us_english', 664, 0, '237761 Different facility'
execute rdt.rdtAddMsg 237762, 10, '237762 No More SKU',           'us_english', 664, 0, '237762 No more SKU to process'
execute rdt.rdtAddMsg 237763, 10, '237763 Invalid Loc',           'us_english', 664
execute rdt.rdtAddMsg 237764, 10, '237764 Diff Facility',         'us_english', 664, 0, '237764 Different facility'
execute rdt.rdtAddMsg 237765, 10, '237765 SameFromToLoc',         'us_english', 664, 0, '237765 ToLoc cannot be the same as FromLoc'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 237751 AND 237800 