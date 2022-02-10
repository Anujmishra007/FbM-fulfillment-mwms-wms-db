/************************************************************************/
/*Changed Log                                                           */
/*                                                                      */
/* Date         Rev  Author     Purposes                                */
/* 30-Jun-2015  1.0  James      SOS342407-Change 1876, 1882 & 1887 to   */
/*                              carton type (james01)                   */
/* 08-Jul-2015  1.1  James      SOS342111-Change screen 1873            */
/* 02-Sep-2016  1.2  James      SOS375742-Change screen 1888            */
/* 29-Oct-2018  1.3  James      WMS6843-Add new line @ screen 1875      */
/* 30-Oct-2020  1.4  James      WMS-15548 Extend DropID from 20 to 60   */
/*                              chars for scn 1876                      */
/************************************************************************/

-- 1870 = WAVEKEY screen
DELETE rdt.RDTScn WHERE Scn = 1870 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1870, 'ENG',
    @cLine01 = 'WAVEKEY: %10i01'
   ,@cLine14 = '%e'
 
-- 1871 = LOADKEY screen
DELETE rdt.RDTScn WHERE Scn = 1871 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1871, 'ENG',
    @cLine01 = 'WAVEKEY: %10d01'
   ,@cLine02 = 'LOADKEY: %10i02'
   ,@cLine14 = '%e'
 
-- 1872 = OREDRKEY screen
DELETE rdt.RDTScn WHERE Scn = 1872 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1872, 'ENG',
    @cLine01 = 'WAVEKEY: %10d01'
   ,@cLine02 = 'LOADKEY: %10d02'
   ,@cLine04 = 'ORDERKEY:'
   ,@cLine05 = '%10i03'
   ,@cLine07 = 'LAST ORDERKEY:'
   ,@cLine08 = '%10d04'
   ,@cLine10 = 'ORDERKEY COUNT:'
   ,@cLine11 = '%05d05'
   ,@cLine14 = '%e'
 
-- 1873 = PUTAWAY screen
DELETE rdt.RDTScn WHERE Scn = 1873 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1873, 'ENG',
    @cLine01 = 'SELECT PUTAWAY ZONE'
   ,@cLine03 = '%01i01 %10d12'
   ,@cLine05 = '%01i02 %10d07'
   ,@cLine06 = '%01i03 %10d08'
   ,@cLine07 = '%01i04 %10d09'
   ,@cLine08 = '%01i05 %10d10'
   ,@cLine09 = '%01i06 %10d11'
   ,@cLine10 = '1 = Select Zone'
   ,@cLine11 = 'ENTER = Next Record'
   ,@cLine14 = '%e'
 
-- 1874 = PICKZONE screen
DELETE rdt.RDTScn WHERE Scn = 1874 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1874, 'ENG',
    @cLine01 = 'PICK ZONE:'
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'BLANK = System Assign'
   ,@cLine14 = '%e'
 
-- 1875 = PICK screen
DELETE rdt.RDTScn WHERE Scn = 1875 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1875, 'ENG',
    @cLine01 = 'START PICKING? %01i01'
   ,@cLine03 = '1 = YES 2 = NO'
   ,@cLine04 = 'WAVEKEY: %10d02'
   ,@cLine05 = 'LOADKEY: %10d03'
   ,@cLine06 = 'PUTAWAY ZONE:'
   ,@cLine07 = '%10d04'
   ,@cLine08 = 'PICK ZONE:'
   ,@cLine09 = '%10d05'
   ,@cLine10 = 'ORDER COUNT: %05d06'
   ,@cLine11 = 'SKU COUNT: %05d07'
   ,@cLine12 = 'TTL ALLOC QTY: %05d08'
   ,@cLine13 = '%20d09'
   ,@cLine14 = '%e'
 
-- 1876 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 1876 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1876, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ORDERKEY: %10d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = 'CUST: %14d04'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = 'SCAN CARTON ID'
   ,@cLine11 = 'DROP ID:'
   ,@cLine12 = '%60i09'       -- WMS-15548 change to 60 chars
   ,@cLine13 = '%09d10 %10i11'
   ,@cLine14 = '%e'
 
-- 1877 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 1877 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1877, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'DROPID: %12d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%32i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
--   ,@cLine08 = 'TTL OS QTY: %05d08'
   ,@cLine08 = '%20d08' -- SOS209194
   ,@cLine09 = 'ORDERKEY %10d09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = 'CUST: %14d11'
   ,@cLine12 = 'QTY: %11d12'
   ,@cLine13 = 'QTY TO PICK: %05i13'
   ,@cLine14 = '%e'
 
-- 1878 = CONFIRM SHORT PICK screen
DELETE rdt.RDTScn WHERE Scn = 1878 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1878, 'ENG',
    @cLine01 = 'CONFIRM SHORTPICK? %01i01'
   ,@cLine02 = '%20d13'
   ,@cLine03 = 'QTY: %11d02'
   ,@cLine04 = 'ORDERKEY %10d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%20d11'
   ,@cLine13 = '%20d12'
   ,@cLine14 = '%e'
 
-- 1879 = PICK COMPLETED screen
DELETE rdt.RDTScn WHERE Scn = 1879 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1879, 'ENG',
    @cLine01 = 'PICKING COMPLETED'
   ,@cLine03 = 'WAVEKEY: %10d01'
   ,@cLine04 = 'LOADKEY: %10d02'
   ,@cLine05 = 'PUTAWAY ZONE:'
   ,@cLine06 = '%10d03'
   ,@cLine07 = 'PICK ZONE:'
   ,@cLine08 = '%10d04'
   ,@cLine09 = 'ORDER COUNT: %05d05'
   ,@cLine10 = 'PICKED QTY: %05d06'
   ,@cLine13 = '%20d07'    -- (james36)
   ,@cLine14 = '%e'
 
-- 1880 = EXIT PICK screen
DELETE rdt.RDTScn WHERE Scn = 1880 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1880, 'ENG',
    @cLine01 = 'EXIT PICKING? %01i01'
   ,@cLine03 = '1 = YES 2 = NO'
   ,@cLine05 = 'WAVEKEY: %10d02'
   ,@cLine06 = 'LOADKEY: %10d03'
   ,@cLine07 = 'PUTAWAY ZONE:'
   ,@cLine08 = '%10d04'
   ,@cLine09 = 'PICK ZONE:'
   ,@cLine10 = '%10d05'
   ,@cLine11 = 'ORDER COUNT: %05d06'
   ,@cLine12 = 'QTY: %11d07'
   ,@cLine13 = '%20d08'    -- (james36)
   ,@cLine14 = '%e'
 
-- 1881 = CANCEL PICK screen
DELETE rdt.RDTScn WHERE Scn = 1881 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1881, 'ENG',
    @cLine01 = 'PLEASE INPUT? %01i01'
   ,@cLine03 = '1=Confirm Short Pick'
   ,@cLine04 = 'of Current SKU of'
   ,@cLine05 = 'Current Order'
   ,@cLine07 = '2=Cancel Pick'
   ,@cLine08 = 'Put the goods back'
   ,@cLine09 = 'To Original Loc'
   ,@cLine11 = '%20i02'
   ,@cLine14 = '%e'
   
-- 1882 = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 1882 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1882, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ORDERKEY: %10d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = 'CUST: %14d04'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = 'L2 %18d08'
   ,@cLine10 = 'L4 %18d09'
   ,@cLine11 = 'SCAN CARTON ID'
   ,@cLine12 = '%20i10'        -- SOS304353 change to 20 chars
   ,@cLine13 = '%09d11 %10i12'
   ,@cLine14 = '%e'

-- 1883 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 1883 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1883, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%32i03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = 'L2 %18i06' -- SOS291607
   ,@cLine07 = 'L4 %18d07'
   ,@cLine08 = '%20d08' -- SOS209194
   ,@cLine09 = 'ORDERKEY %10d09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = 'TTL OS ORD: %05d11'
   ,@cLine12 = 'QTY: %11d12'
   ,@cLine13 = '%05i15 %05i13 %09d14' -- SOS291607
   ,@cLine14 = '%e'
 
-- 1884 = CONFIRM SHORT PICK screen
DELETE rdt.RDTScn WHERE Scn = 1884 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1884, 'ENG',
    @cLine01 = 'CONFIRM SHORTPICK? %01i01'
   ,@cLine02 = '%20d13'
   ,@cLine03 = 'QTY: %11d02'
   ,@cLine04 = 'ORDERKEY %10d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = 'L2 %20d10'
   ,@cLine12 = 'L4 %20d11'
   ,@cLine14 = '%e'
 
-- 1885 = PRINT LABEL
DELETE rdt.RDTScn WHERE Scn = 1885 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1885, 'ENG',
    @cLine01 = 'PRINT LABEL? %01i01'
   ,@cLine02 = '1 = YES 2 = NO'
   ,@cLine14 = '%e'
 
-- 1886 = CLOSE CASE
DELETE rdt.RDTScn WHERE Scn = 1886 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1886, 'ENG',
    @cLine01 = 'CLOSE CASE? %01i01' -- (FOR AEO james01)
   ,@cLine02 = '1 = YES 2 = NO'
   ,@cLine14 = '%e'
 
-- SOS170848 - Add new screen for conso pock
-- 1887 = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 1887 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1887, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'LOADKEY: %10d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = 'L2 %18d08'
   ,@cLine09 = 'L4 %18d09'
   ,@cLine10 = 'SCAN CARTON ID'
   ,@cLine11 = 'DROP ID:'
   ,@cLine12 = '%20i10'    -- SOS304353 change to 20 chars
   ,@cLine13 = '%09d11 %10i12'
   ,@cLine14 = '%e'
 
-- 1888 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 1888 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1888, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%32i03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d10'
   ,@cLine07 = 'L2 %18i06' -- SOS291607
   ,@cLine08 = 'L4 %18d07'
   ,@cLine09 = '%20d08' -- SOS209194
   ,@cLine10 = 'LOADKEY %10d09'
   ,@cLine11 = 'TTL OS ORD: %05d11'
   ,@cLine12 = 'QTY: %11d12'
   ,@cLine13 = '%05i15 %05i13 %09d14' -- SOS291607
   ,@cLine14 = '%e'
 
-- 1889 = CONFIRM SHORT PICK screen
DELETE rdt.RDTScn WHERE Scn = 1889 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1889, 'ENG',
    @cLine01 = 'CONFIRM SHORTPICK? %01i01'
   ,@cLine02 = '%20d13'
   ,@cLine03 = 'QTY: %11d02'
   ,@cLine04 = 'LOADKEY %10d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%20d11'
   ,@cLine13 = '%20d12'
   ,@cLine14 = '%e'
 
-- 1890 = NEW DROPID screen
DELETE rdt.RDTScn WHERE Scn = 1890 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1890, 'ENG',
    @cLine01 = 'NEW DROP ID ?'
   ,@cLine02 = '1 = YES 2 = NO'
   ,@cLine04 = 'Option: %01i01'
   ,@cLine14 = '%e'
 
-- 1891 = SCAN ADCODE screen
DELETE rdt.RDTScn WHERE Scn = 1891 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1891, 'ENG',
    @cLine01 = 'SKU/UPC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'DESC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'ADCode:'
   ,@cLine08 = '%18i05'
   ,@cLine10 = 'SCAN: %11d06'
   ,@cLine14 = '%e'
 
-- SOS263803
-- 1892 = Confirm LOC screen
DELETE rdt.RDTScn WHERE Scn = 1892 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1892, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'CONFIRM LOC:'
   ,@cLine03 = '%10i02'
   ,@cLine14 = '%e' 