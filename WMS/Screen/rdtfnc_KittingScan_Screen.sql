/************************************************************************/
/* Screen definitions for rdtfnc_KittingScan                            */
/* Function ID: 1880                                                    */
/* Screens: 6880-6884                                                   */
/*                                                                      */
/* Date         Rev  Author     Purposes                                */
/* 2026-04-09   1.0  Dennis     Created                                 */
/* 2026-04-30   1.1  Dennis     FCR-99283 Added screen 6884 for Step 6  */
/************************************************************************/

-- 6880 = Screen 1: Scan KitKey
DELETE rdt.RDTScn WHERE Scn = 6880 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6880, 'ENG',
    @cLine01 = 'KitKey:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1880

-- 6881 = Screen 2: Scan To LOC and To ID
DELETE rdt.RDTScn WHERE Scn = 6881 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6881, 'ENG',
    @cLine01 = 'To LOC:'
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'To ID:'
   ,@cLine05 = '%18i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 1880

-- 6882 = Screen 3: Scan Parent SKU and QTY
DELETE rdt.RDTScn WHERE Scn = 6882 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6882, 'ENG',
    @cLine01 = 'Parent SKU:'
   ,@cLine02 = '%200iV_Barcode'
   ,@cLine04 = 'QTY:'
   ,@cLine05 = '%05i02^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 1880

-- 6883 = Screen 4: Scan Child SKU (Loop)
DELETE rdt.RDTScn WHERE Scn = 6883 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6883, 'ENG',
    @cLine01 = 'Parent SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'Child SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'Child SKU:'
   ,@cLine08 = '%200iV_Barcode'
   ,@cLine10 = 'QTY Exp: %05d06'
   ,@cLine11 = 'BOM QTY: %05d07'
   ,@cLine12 = 'QTY:'
   ,@cLine13 = '%05i08^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["4","5","6"],"3":["7","8"],"4":["10","11"],"5":["12","13"]}'
   ,@nFunc = 1880

-- 6884 = Screen 6: Scan Child SKU (Single Scan - Non-Lottable)
DELETE rdt.RDTScn WHERE Scn = 6884 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6884, 'ENG',
    @cLine01 = 'Parent SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'Child SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'Child SKU:'
   ,@cLine08 = '%200iV_Barcode'
   ,@cLine09 = 'QTY Exp: %05d06'
   ,@cLine10 = 'BOM QTY: %05d07'
   ,@cLine11 = 'Scanned: %05d09'
   ,@cLine12 = 'QTY:'
   ,@cLine13 = '%05i08^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["4","5","6"],"3":["7","8"],"4":["9","10","11"],"5":["12","13"]}'
   ,@nFunc = 1880
