SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: isp_RCM_WV_Std_CreateTransfer                      */
/* Creation Date: 2026-08-04                                            */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-14633 - JP - Fanatics - Wave Create Transfer            */
/*                                                                      */
/* Called By: WM.lsp_RCMConfigSP_WAVE_Wrapper                           */
/*          : Wave RCM configure at listname 'RCMConfig'                */
/*                                                                      */
/* Parameters:                                                          */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 2026-08-04   Michael   1.0   DEVOPS Combine Script                   */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_RCM_WV_Std_CreateTransfer]
   @c_Wavekey  NVARCHAR(10)
 , @b_success  int           OUTPUT
 , @n_err      int           OUTPUT
 , @c_errmsg   NVARCHAR(225) OUTPUT
 , @c_code     NVARCHAR(30) = ''
AS
BEGIN
/* CODELKUP
   .ListName  =  'WAV2TRFCFG'
   .Code2     =  'isp_RCM_WV_Std_CreateTransfer'
   .Storerkey =  <Storerkey>

   Code                 Description             Short(Enable)   Long(Fieldname)  Notes(SQL)
   SQL_JOIN_ORD         Order JOIN              Y/N                              <Join Clause>
   SQL_WHERE_ORD        Order WHERE             Y/N                              <Where Clause>
   SQL_JOIN_LLI         LOTxLOCxID JOIN         Y/N                              <Join Clause>
   SQL_WHERE_LLI        LOTxLOCxID WHERE        Y/N                              <Where Clause>
   SQL_SORT_LLI         LOTxLOCxID ORDER BY     Y/N                              <Order By Clause>
   SQL_JOIN_FldMap      Field Map JOIN          Y/N                              <Join Clause>
   SQL_WHERE_FldMap     Field Map WHERE         Y/N                              <Where Clause>
   SQL_SORT_FldMap      Field Map ORDER BY      Y/N                              <Order By Clause>
   MAP_HDR_999          Map Header Exp          Y/N             Field Name       <SQL Expresssion>
   MAP_DTL_999          Map Detail Exp          Y/N             Field Name       <SQL Expresssion>
   AvailableQty         Available Qty Exp       Y/N                              <SQL Expresssion>
   LocationFlagCond     LocationFlag WHERE      Y/N                              <Where Clause>
   NoFinalizeTransfer   Not Finalize Transfer   Y/N
   Debug                Debug mode              Y/N

   (For Code MAP_XXX_999 means allow mulit records for mulit Fields Mapping)
*/
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_SP_Name          NVARCHAR(128) = 'isp_RCM_WV_Std_CreateTransfer'
         , @c_ListName         NVARCHAR(10)  = 'WAV2TRFCFG'
         , @c_Transferkey      NVARCHAR(10)
         , @c_Storerkey        NVARCHAR(15)
         , @c_Facility         NVARCHAR(5)
         , @c_Sku              NVARCHAR(20)
         , @c_Lottable04Label  NVARCHAR(20)
         , @c_Lot              NVARCHAR(10)
         , @c_FromLoc          NVARCHAR(10)
         , @c_Id               NVARCHAR(18)
         , @n_Qty              INT
         , @n_OpenQty          INT
         , @n_TrfQty           INT
         , @n_continue         INT = 1
         , @n_starttcnt        INT = @@TRANCOUNT
         , @b_debug            INT = 0

   DECLARE @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQL_MAP            NVARCHAR(MAX) = ''
         , @c_Parms1             NVARCHAR(MAX) = ''
         , @c_Parms2             NVARCHAR(MAX) = ''
         , @c_SQL_JOIN_ORD       NVARCHAR(MAX) = ''
         , @c_SQL_WHERE_ORD      NVARCHAR(MAX) = ''
         , @c_SQL_JOIN_LLI       NVARCHAR(MAX) = ''
         , @c_SQL_WHERE_LLI      NVARCHAR(MAX) = ''
         , @c_SQL_SORT_LLI       NVARCHAR(MAX) = ''
         , @c_SQL_JOIN_FldMap    NVARCHAR(MAX) = ''
         , @c_SQL_WHERE_FldMap   NVARCHAR(MAX) = ''
         , @c_SQL_SORT_FldMap    NVARCHAR(MAX) = ''
         , @c_NoFinalizeTransfer NVARCHAR(10)  = ''
         , @c_AvailableQty_Exp   NVARCHAR(MAX) = ''
         , @c_LocationFlagCond   NVARCHAR(MAX) = ''
         , @c_MAP_Fields         NVARCHAR(MAX)
         , @c_Long               NVARCHAR(252)
         , @c_Notes              NVARCHAR(MAX)

   DECLARE @H_Type               NVARCHAR(12)
         , @H_ReasonCode         NVARCHAR(10)
         , @H_CustomerRefNo      NVARCHAR(20)
         , @H_Remarks            NVARCHAR(200)
         , @H_UserDefine01       NVARCHAR(20)
         , @H_UserDefine02       NVARCHAR(20)
         , @H_UserDefine03       NVARCHAR(20)
         , @H_UserDefine04       NVARCHAR(20)
         , @H_UserDefine05       NVARCHAR(20)
         , @H_UserDefine06       DATETIME
         , @H_UserDefine07       DATETIME
         , @H_UserDefine08       NVARCHAR(10)
         , @H_UserDefine09       NVARCHAR(10)
         , @H_UserDefine10       NVARCHAR(10)
         , @D_FromQty            INT
         , @D_ToLot              NVARCHAR(10)
         , @D_ToLoc              NVARCHAR(10)
         , @D_ToID               NVARCHAR(18)
         , @D_ToQty              INT
         , @D_ToLottable01       NVARCHAR(18)
         , @D_ToLottable02       NVARCHAR(18)
         , @D_ToLottable03       NVARCHAR(18)
         , @D_ToLottable04       DATETIME
         , @D_ToLottable05       DATETIME
         , @D_ToLottable06       NVARCHAR(18)
         , @D_ToLottable07       NVARCHAR(30)
         , @D_ToLottable08       NVARCHAR(30)
         , @D_ToLottable09       NVARCHAR(30)
         , @D_ToLottable10       NVARCHAR(30)
         , @D_ToLottable11       NVARCHAR(30)
         , @D_ToLottable12       NVARCHAR(30)
         , @D_ToLottable13       DATETIME
         , @D_ToLottable14       DATETIME
         , @D_ToLottable15       DATETIME
         , @D_UserDefine01       NVARCHAR(20)
         , @D_UserDefine02       NVARCHAR(20)
         , @D_UserDefine03       NVARCHAR(20)
         , @D_UserDefine04       NVARCHAR(20)
         , @D_UserDefine05       NVARCHAR(20)
         , @D_UserDefine06       DATETIME
         , @D_UserDefine07       DATETIME
         , @D_UserDefine08       NVARCHAR(10)
         , @D_UserDefine09       NVARCHAR(10)
         , @D_UserDefine10       NVARCHAR(10)

   SELECT @b_success = 1, @c_errmsg='', @n_err=0

   SELECT TOP 1 @c_Transferkey = TH.Transferkey
     FROM WAVE       WH WITH(NOLOCK)
     JOIN WAVEDETAIL WD WITH(NOLOCK) ON WH.Wavekey = WD.Wavekey
     JOIN ORDERS     OH WITH(NOLOCK) ON WD.Orderkey = OH.Orderkey
     JOIN TRANSFER   TH WITH(NOLOCK) ON WH.Userdefine10 = TH.Transferkey AND OH.Storerkey = TH.FromStorerkey AND OH.Facility = TH.Facility
    WHERE WH.Wavekey = @c_Wavekey

   IF ISNULL(@c_Transferkey,'') <> ''
   BEGIN
      SET @n_continue = 3
      SET @n_err = 63210
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_err)+': This Wave has been tranfer before at Transfer# ' + RTRIM(@c_Transferkey) + '.'
      GOTO EXIT_SP
   END

   IF OBJECT_ID('tempdb..#TEMP_STORER') IS NOT NULL
      DROP TABLE #TEMP_STORER

   SELECT DISTINCT OH.Storerkey
     INTO #TEMP_STORER
     FROM WAVE       WH WITH(NOLOCK)
     JOIN WAVEDETAIL WD WITH(NOLOCK) ON WH.Wavekey = WD.Wavekey
     JOIN ORDERS     OH WITH(NOLOCK) ON WD.Orderkey = OH.Orderkey
    WHERE WD.Wavekey = @c_Wavekey

   IF NOT EXISTS(SELECT TOP 1 1 FROM #TEMP_STORER)
      GOTO EXIT_SP

   IF @@TRANCOUNT = 0
     BEGIN TRAN

   SET @c_Transferkey = ''

   SET @c_Parms1 =
        N'@c_Wavekey NVARCHAR(10), @c_code NVARCHAR(30), @c_Transferkey NVARCHAR(10), @c_Facility NVARCHAR(5), @c_Storerkey NVARCHAR(15)'
     + ', @c_Sku NVARCHAR(20), @c_Lot NVARCHAR(10), @c_FromLoc NVARCHAR(10), @c_Id NVARCHAR(18), @n_Qty INT, @n_OpenQty INT, @n_TrfQty INT'

   SET @c_Parms2 = @c_Parms1
     + ', @H_Type          NVARCHAR(12)  OUTPUT, @H_ReasonCode    NVARCHAR(10)  OUTPUT, @H_CustomerRefNo NVARCHAR(20)  OUTPUT, @H_Remarks       NVARCHAR(200) OUTPUT, @H_UserDefine01  NVARCHAR(20)  OUTPUT'
     + ', @H_UserDefine02  NVARCHAR(20)  OUTPUT, @H_UserDefine03  NVARCHAR(20)  OUTPUT, @H_UserDefine04  NVARCHAR(20)  OUTPUT, @H_UserDefine05  NVARCHAR(20)  OUTPUT, @H_UserDefine06  DATETIME      OUTPUT'
     + ', @H_UserDefine07  DATETIME      OUTPUT, @H_UserDefine08  NVARCHAR(10)  OUTPUT, @H_UserDefine09  NVARCHAR(10)  OUTPUT, @H_UserDefine10  NVARCHAR(10)  OUTPUT'
     + ', @D_FromQty       INT           OUTPUT, @D_ToLot         NVARCHAR(10)  OUTPUT, @D_ToLoc         NVARCHAR(10)  OUTPUT, @D_ToID          NVARCHAR(18)  OUTPUT, @D_ToQty         INT           OUTPUT'
     + ', @D_ToLottable01  NVARCHAR(18)  OUTPUT, @D_ToLottable02  NVARCHAR(18)  OUTPUT, @D_ToLottable03  NVARCHAR(18)  OUTPUT, @D_ToLottable04  DATETIME      OUTPUT, @D_ToLottable05  DATETIME      OUTPUT'
     + ', @D_ToLottable06  NVARCHAR(18)  OUTPUT, @D_ToLottable07  NVARCHAR(30)  OUTPUT, @D_ToLottable08  NVARCHAR(30)  OUTPUT, @D_ToLottable09  NVARCHAR(30)  OUTPUT, @D_ToLottable10  NVARCHAR(30)  OUTPUT'
     + ', @D_ToLottable11  NVARCHAR(30)  OUTPUT, @D_ToLottable12  NVARCHAR(30)  OUTPUT, @D_ToLottable13  DATETIME      OUTPUT, @D_ToLottable14  DATETIME      OUTPUT, @D_ToLottable15  DATETIME      OUTPUT'
     + ', @D_UserDefine01  NVARCHAR(20)  OUTPUT, @D_UserDefine02  NVARCHAR(20)  OUTPUT, @D_UserDefine03  NVARCHAR(20)  OUTPUT, @D_UserDefine04  NVARCHAR(20)  OUTPUT, @D_UserDefine05  NVARCHAR(20)  OUTPUT'
     + ', @D_UserDefine06  DATETIME      OUTPUT, @D_UserDefine07  DATETIME      OUTPUT, @D_UserDefine08  NVARCHAR(10)  OUTPUT, @D_UserDefine09  NVARCHAR(10)  OUTPUT, @D_UserDefine10  NVARCHAR(10)  OUTPUT'

   SET @c_MAP_Fields =
      ',H_Type,H_ReasonCode,H_CustomerRefNo,H_Remarks,H_UserDefine01,H_UserDefine02,H_UserDefine03,H_UserDefine04,H_UserDefine05,H_UserDefine06,'
     + 'H_UserDefine07,H_UserDefine08,H_UserDefine09,H_UserDefine10,'
     + 'D_FromQty,D_ToLot,D_ToLoc,D_ToID,D_ToQty,D_ToLottable01,D_ToLottable02,D_ToLottable03,D_ToLottable04,D_ToLottable05,'
     + 'D_ToLottable06,D_ToLottable07,D_ToLottable08,D_ToLottable09,D_ToLottable10,D_ToLottable11,D_ToLottable12,D_ToLottable13,D_ToLottable14,D_ToLottable15,'
     + 'D_UserDefine01,D_UserDefine02,D_UserDefine03,D_UserDefine04,D_UserDefine05,D_UserDefine06,D_UserDefine07,D_UserDefine08,D_UserDefine09,D_UserDefine10,'


   -- Loop Storerkey
   DECLARE CUR_STORER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT Storerkey FROM #TEMP_STORER ORDER BY 1

   OPEN CUR_STORER

   WHILE @n_continue IN(1,2)
   BEGIN
      FETCH NEXT FROM CUR_STORER INTO @c_Storerkey

      IF @@FETCH_STATUS <> 0
         BREAK

      -- Get WAV2TFRCFG setup
      SELECT @c_SQL_JOIN_ORD       = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN_ORD'     AND Short = 'Y' THEN Notes END)),'')
           , @c_SQL_WHERE_ORD      = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_WHERE_ORD'    AND Short = 'Y' THEN Notes END)),'')
           , @c_SQL_JOIN_LLI       = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN_LLI'     AND Short = 'Y' THEN Notes END)),'')
           , @c_SQL_WHERE_LLI      = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_WHERE_LLI'    AND Short = 'Y' THEN Notes END)),'')
           , @c_SQL_SORT_LLI       = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_SORT_LLI'     AND Short = 'Y' THEN Notes END)),'')
           , @c_SQL_JOIN_FldMap    = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_JOIN_FldMap'  AND Short = 'Y' THEN Notes END)),'')
           , @c_SQL_WHERE_FldMap   = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_WHERE_FldMap' AND Short = 'Y' THEN Notes END)),'')
           , @c_SQL_SORT_FldMap    = ISNULL(TRIM(MAX(CASE WHEN Code = 'SQL_SORT_FldMap'  AND Short = 'Y' THEN Notes END)),'')
           , @c_AvailableQty_Exp   = ISNULL(TRIM(MAX(CASE WHEN Code = 'AvailableQty'     AND Short = 'Y' THEN Notes END)),'')
           , @c_LocationFlagCond   = ISNULL(TRIM(MAX(CASE WHEN Code = 'LocationFlagCond' AND Short = 'Y' THEN Notes END)),'')
           , @c_NoFinalizeTransfer = ISNULL(TRIM(MAX(CASE WHEN Code = 'NoFinalizeTransfer'               THEN Short END)),'')
           , @b_debug              = ISNULL(MAX(CASE WHEN Code = 'Debug' AND Short IN ('1','Y') THEN 1 END),0)
        FROM dbo.CODELKUP WITH(NOLOCK)
       WHERE ListName = @c_ListName
         AND Code2 = @c_SP_Name
         AND Storerkey = @c_Storerkey

      IF LEFT(@c_SQL_WHERE_ORD,4) = 'AND '
         SET @c_SQL_WHERE_ORD = SUBSTRING(@c_SQL_WHERE_ORD, 5, LEN(@c_SQL_WHERE_ORD))

      IF LEFT(@c_SQL_WHERE_LLI,4) = 'AND '
         SET @c_SQL_WHERE_LLI = SUBSTRING(@c_SQL_WHERE_LLI, 5, LEN(@c_SQL_WHERE_LLI))

      IF LEFT(@c_SQL_WHERE_FldMap,4) = 'AND '
         SET @c_SQL_WHERE_FldMap = SUBSTRING(@c_SQL_WHERE_FldMap, 5, LEN(@c_SQL_WHERE_FldMap))

      IF LEFT(@c_LocationFlagCond,4) = 'AND '
         SET @c_LocationFlagCond = SUBSTRING(@c_LocationFlagCond, 5, LEN(@c_LocationFlagCond))


      -- Build Field Mapping SQL
      DECLARE CUR_MAP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT CASE WHEN LEFT(Code,7) = 'MAP_HDR' THEN 'H_' ELSE 'D_' END + TRIM(Long)
           , TRIM(Notes)
      FROM dbo.CODELKUP WITH(NOLOCK)
      WHERE ListName = @c_ListName
        AND Code2 = @c_SP_Name
        AND Storerkey = @c_Storerkey
        AND LEFT(Code,7) IN ('MAP_HDR', 'MAP_DTL')
        AND Short = 'Y'
        AND ISNULL(Long,'') <> ''
        AND ISNULL(Notes,'') <> ''
      ORDER BY Code

      OPEN CUR_MAP

      SET @c_SQL_MAP = ''

      WHILE @n_Continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_MAP
         INTO @c_Long, @c_Notes

         IF @@FETCH_STATUS<>0
            BREAK

         IF @c_MAP_Fields LIKE '%,'+@c_Long+',%'
            SET @c_SQL_MAP = @c_SQL_MAP + ',@' + @c_Long + '=(' + @c_Notes + ')'
      END
      CLOSE CUR_MAP
      DEALLOCATE CUR_MAP


      -- Loop OrderDetail
      SET @c_SQL = N'DECLARE CUR_TRF CURSOR FAST_FORWARD READ_ONLY FOR'
        +' SELECT OH.Facility'
        +      ', OD.Sku'
        +      ', OpenQty = SUM(OD.OpenQty - OD.QtyAllocated - OD.QtyPicked)'
        +      ', Lottable04Label = MAX(SKU.Lottable04Label)'
        +  ' FROM dbo.WAVEDETAIL  WD  WITH(NOLOCK)'
        +  ' JOIN dbo.ORDERS      OH  WITH(NOLOCK) ON WD.Orderkey = OH.Orderkey'
        +  ' JOIN dbo.ORDERDETAIL OD  WITH(NOLOCK) ON OH.Orderkey = OD.Orderkey'
        +  ' JOIN dbo.SKU         SKU WITH(NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku'

      IF ISNULL(@c_SQL_JOIN_ORD,'') <> ''
         SET @c_SQL = @c_SQL + ' ' + @c_SQL_JOIN_ORD

      SET @c_SQL = @c_SQL
        + ' WHERE WD.Wavekey = N''' + ISNULL(REPLACE(@c_Wavekey,'''',''''''),'') + ''''
        +   ' AND OD.Storerkey = N''' + ISNULL(REPLACE(@c_Storerkey,'''',''''''),'') + ''''

      IF ISNULL(@c_SQL_WHERE_ORD,'') <> ''
         SET @c_SQL = @c_SQL + ' AND (' + @c_SQL_WHERE_ORD + ')'
      ELSE
         SET @c_SQL = @c_SQL + ' AND OD.Status < ''9'''

      SET @c_SQL = @c_SQL
        + ' GROUP BY OH.Facility, OD.Sku'
        + ' ORDER BY 1,2'

      IF @b_debug = 1
         SELECT @c_SQL AS [CUR_TRF]

      BEGIN TRY
         EXEC sp_ExecuteSql @c_SQL, @c_Parms1
            , @c_Wavekey, @c_code, @c_Transferkey, @c_Facility, @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_Id, @n_Qty, @n_OpenQty, @n_TrfQty
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err = 63211
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Declare Cursor CUR_TRF Error (' + ISNULL(ERROR_MESSAGE(),'') +').'
         GOTO EXIT_SP
      END CATCH

      OPEN CUR_TRF

      WHILE @n_continue IN(1,2)
      BEGIN
         FETCH NEXT FROM CUR_TRF INTO @c_Facility, @c_Sku, @n_OpenQty, @c_Lottable04Label

         IF @@FETCH_STATUS <> 0
            BREAK

         -- Loop LOTxLOCxID
         SET @c_SQL = N'DECLARE CUR_INV CURSOR FAST_FORWARD READ_ONLY FOR'
           +' SELECT LLI.Lot'
           +      ', LLI.Loc'
           +      ', LLI.Id'
           +      ', Qty = ' + CASE WHEN @c_AvailableQty_Exp<>'' THEN '(' + @c_AvailableQty_Exp + ')' ELSE 'LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked' END
           + ' FROM LOTXLOCXID   LLI WITH(NOLOCK)'
           + ' JOIN dbo.ID       ID  WITH(NOLOCK) ON LLI.ID  = ID.ID'
           + ' JOIN dbo.LOC      LOC WITH(NOLOCK) ON LLI.Loc = LOC.Loc'
           + ' JOIN dbo.LOT      LOT WITH(NOLOCK) ON LLI.Lot = LOT.Lot'
           + ' JOIN LOTATTRIBUTE LA  WITH(NOLOCK) ON LLI.Lot = LA.Lot'

         IF ISNULL(@c_SQL_JOIN_LLI,'') <> ''
            SET @c_SQL = @c_SQL + ' ' + @c_SQL_JOIN_LLI

         SET @c_SQL = @c_SQL
           +' WHERE LLI.Storerkey = N''' + ISNULL(REPLACE(@c_Storerkey,'''',''''''),'') + ''''
           +  ' AND LOC.Facility = N''' + ISNULL(REPLACE(@c_Facility,'''',''''''),'') + ''''
           +  ' AND LLI.Sku = N''' + ISNULL(REPLACE(@c_Sku,'''',''''''),'') + ''''
           +  ' AND ' + CASE WHEN @c_AvailableQty_Exp<>'' THEN '(' + @c_AvailableQty_Exp + ')' ELSE 'LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked' END + ' > 0'
           +  ' AND LOT.Status = ''OK'''
           +  ' AND ID.Status  = ''OK'''
           +  ' AND LOC.Status = ''OK'''

         IF ISNULL(@c_LocationFlagCond,'') <> ''
            SET @c_SQL = @c_SQL + ' AND (' + @c_LocationFlagCond + ')'
         ELSE
            SET @c_SQL = @c_SQL + ' AND LOC.LocationFlag = ''NONE'''

         IF ISNULL(@c_SQL_WHERE_LLI,'') <> ''
            SET @c_SQL = @c_SQL + ' AND (' + @c_SQL_WHERE_LLI + ')'

         IF ISNULL(@c_SQL_SORT_LLI,'') <> ''
            SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_SQL_SORT_LLI
         ELSE
            SET @c_SQL = @c_SQL + ' ORDER BY ' + CASE WHEN @c_Lottable04Label<>'' THEN 'LA.Lottable04,' ELSE '' END + 'LA.Lottable05, LA.Lot, LOC.LogicalLocation, LLI.Loc, LLI.Id'

         IF @b_debug = 1
            SELECT @c_SQL AS [CUR_INV]

         BEGIN TRY
            EXEC (@c_SQL)
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err = 63212
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Declare Cursor CUR_INV Error (' + ISNULL(ERROR_MESSAGE(),'') +').'
            GOTO EXIT_SP
         END CATCH

         OPEN CUR_INV

         WHILE @n_continue IN(1,2) AND @n_OpenQty > 0
         BEGIN
            FETCH NEXT FROM CUR_INV INTO @c_Lot, @c_FromLoc, @c_Id, @n_Qty

            IF @@FETCH_STATUS <> 0
               BREAK

            SET @n_TrfQty = CASE WHEN @n_OpenQty >= @n_Qty THEN @n_Qty ELSE @n_OpenQty END

            SELECT @H_Type       = 'RELOT', @H_ReasonCode    = '01', @H_CustomerRefNo = ''  , @H_Remarks       = ''  , @H_UserDefine01  = ''
                 , @H_UserDefine02  = ''  , @H_UserDefine03  = ''  , @H_UserDefine04  = ''  , @H_UserDefine05  = ''  , @H_UserDefine06  = NULL
                 , @H_UserDefine07  = NULL, @H_UserDefine08  = ''  , @H_UserDefine09  = ''  , @H_UserDefine10  = ''
                 , @D_FromQty  = @n_TrfQty, @D_ToLot         = ''  , @D_ToLoc   = @c_FromLoc, @D_ToID          = ''  , @D_ToQty         = 0
                 , @D_ToLottable01  = ''  , @D_ToLottable02  = ''  , @D_ToLottable03  = ''  , @D_ToLottable04  = NULL, @D_ToLottable05  = NULL
                 , @D_ToLottable06  = ''  , @D_ToLottable07  = ''  , @D_ToLottable08  = ''  , @D_ToLottable09  = ''  , @D_ToLottable10  = ''
                 , @D_ToLottable11  = ''  , @D_ToLottable12  = ''  , @D_ToLottable13  = NULL, @D_ToLottable14  = NULL, @D_ToLottable15  = NULL
                 , @D_UserDefine01  = ''  , @D_UserDefine02  = ''  , @D_UserDefine03  = ''  , @D_UserDefine04  = ''  , @D_UserDefine05  = ''
                 , @D_UserDefine06  = NULL, @D_UserDefine07  = NULL, @D_UserDefine08  = ''  , @D_UserDefine09  = ''  , @D_UserDefine10  = ''

            -- Field Mapping
            IF ISNULL(@c_SQL_MAP,'') <> ''
            BEGIN
               SET @c_SQL = N'DECLARE @n_RowID INT'
                 + ' SELECT TOP 1 @n_RowID = RowID'
                 +   @c_SQL_MAP
                 + ' FROM (SELECT 1 AS RowID) X'

               IF ISNULL(@c_SQL_JOIN_FldMap,'') <> ''
                  SET @c_SQL = @c_SQL + ' ' + @c_SQL_JOIN_FldMap

               SET @c_SQL = @c_SQL
                 + ' WHERE X.RowID = 1'

               IF ISNULL(@c_SQL_WHERE_FldMap,'') <> ''
                  SET @c_SQL = @c_SQL + ' AND (' + @c_SQL_WHERE_FldMap + ')'

               IF ISNULL(@c_SQL_SORT_FldMap,'') <> ''
                  SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_SQL_SORT_FldMap

               IF @b_debug = 1
                  SELECT @c_SQL AS [Assign Variables]

               BEGIN TRY
                  EXEC sp_ExecuteSql @c_SQL, @c_Parms2
                     , @c_Wavekey, @c_code, @c_Transferkey, @c_Facility, @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_Id, @n_Qty, @n_OpenQty, @n_TrfQty
                     , @H_Type            OUTPUT, @H_ReasonCode      OUTPUT, @H_CustomerRefNo   OUTPUT, @H_Remarks         OUTPUT, @H_UserDefine01    OUTPUT
                     , @H_UserDefine02    OUTPUT, @H_UserDefine03    OUTPUT, @H_UserDefine04    OUTPUT, @H_UserDefine05    OUTPUT, @H_UserDefine06    OUTPUT
                     , @H_UserDefine07    OUTPUT, @H_UserDefine08    OUTPUT, @H_UserDefine09    OUTPUT, @H_UserDefine10    OUTPUT
                     , @D_FromQty         OUTPUT, @D_ToLot           OUTPUT, @D_ToLoc           OUTPUT, @D_ToID            OUTPUT, @D_ToQty           OUTPUT
                     , @D_ToLottable01    OUTPUT, @D_ToLottable02    OUTPUT, @D_ToLottable03    OUTPUT, @D_ToLottable04    OUTPUT, @D_ToLottable05    OUTPUT
                     , @D_ToLottable06    OUTPUT, @D_ToLottable07    OUTPUT, @D_ToLottable08    OUTPUT, @D_ToLottable09    OUTPUT, @D_ToLottable10    OUTPUT
                     , @D_ToLottable11    OUTPUT, @D_ToLottable12    OUTPUT, @D_ToLottable13    OUTPUT, @D_ToLottable14    OUTPUT, @D_ToLottable15    OUTPUT
                     , @D_UserDefine01    OUTPUT, @D_UserDefine02    OUTPUT, @D_UserDefine03    OUTPUT, @D_UserDefine04    OUTPUT, @D_UserDefine05    OUTPUT
                     , @D_UserDefine06    OUTPUT, @D_UserDefine07    OUTPUT, @D_UserDefine08    OUTPUT, @D_UserDefine09    OUTPUT, @D_UserDefine10    OUTPUT
               END TRY
               BEGIN CATCH
                  SET @n_Continue = 3
                  SET @n_err = 63213
                  SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Assign Variables Error (' + ISNULL(ERROR_MESSAGE(),'') +').'
                  GOTO EXIT_SP
               END CATCH
            END

            IF @b_debug = 1
            BEGIN
               SET @c_SQL = 'SELECT'
                 + ' c_Wavekey        =N''' + ISNULL(REPLACE(@c_Wavekey         ,'''',''''''),'') + ''''
                 + ',c_code           =N''' + ISNULL(REPLACE(@c_code            ,'''',''''''),'') + ''''
                 + ',c_Transferkey    =N''' + ISNULL(REPLACE(@c_Transferkey     ,'''',''''''),'') + ''''
                 + ',c_Facility       =N''' + ISNULL(REPLACE(@c_Facility        ,'''',''''''),'') + ''''
                 + ',c_Storerkey      =N''' + ISNULL(REPLACE(@c_Storerkey       ,'''',''''''),'') + ''''
                 + ',c_Sku            =N''' + ISNULL(REPLACE(@c_Sku             ,'''',''''''),'') + ''''
                 + ',c_Lot            =N''' + ISNULL(REPLACE(@c_Lot             ,'''',''''''),'') + ''''
                 + ',c_FromLoc        =N''' + ISNULL(REPLACE(@c_FromLoc         ,'''',''''''),'') + ''''
                 + ',c_Id             =N''' + ISNULL(REPLACE(@c_Id              ,'''',''''''),'') + ''''
                 + ',n_Qty            ='    + ISNULL(CONVERT(VARCHAR(10),@n_Qty    ),'')
                 + ',n_OpenQty        ='    + ISNULL(CONVERT(VARCHAR(10),@n_OpenQty),'')
                 + ',n_TrfQty         ='    + ISNULL(CONVERT(VARCHAR(10),@n_TrfQty ),'')
                 + ',H_Type           =N''' + ISNULL(REPLACE(@H_Type            ,'''',''''''),'') + ''''
                 + ',H_ReasonCode     =N''' + ISNULL(REPLACE(@H_ReasonCode      ,'''',''''''),'') + ''''
                 + ',H_CustomerRefNo  =N''' + ISNULL(REPLACE(@H_CustomerRefNo   ,'''',''''''),'') + ''''
                 + ',H_Remarks        =N''' + ISNULL(REPLACE(@H_Remarks         ,'''',''''''),'') + ''''
                 + ',H_UserDefine01   =N''' + ISNULL(REPLACE(@H_UserDefine01    ,'''',''''''),'') + ''''
                 + ',H_UserDefine02   =N''' + ISNULL(REPLACE(@H_UserDefine02    ,'''',''''''),'') + ''''
                 + ',H_UserDefine03   =N''' + ISNULL(REPLACE(@H_UserDefine03    ,'''',''''''),'') + ''''
                 + ',H_UserDefine04   =N''' + ISNULL(REPLACE(@H_UserDefine04    ,'''',''''''),'') + ''''
                 + ',H_UserDefine05   =N''' + ISNULL(REPLACE(@H_UserDefine05    ,'''',''''''),'') + ''''
                 + ',H_UserDefine06   =N''' + ISNULL(CONVERT(VARCHAR(23),@H_UserDefine06,121),'') + ''''
                 + ',H_UserDefine07   =N''' + ISNULL(CONVERT(VARCHAR(23),@H_UserDefine07,121),'') + ''''
                 + ',H_UserDefine08   =N''' + ISNULL(REPLACE(@H_UserDefine08    ,'''',''''''),'') + ''''
                 + ',H_UserDefine09   =N''' + ISNULL(REPLACE(@H_UserDefine09    ,'''',''''''),'') + ''''
                 + ',H_UserDefine10   =N''' + ISNULL(REPLACE(@H_UserDefine10    ,'''',''''''),'') + ''''
                 + ',D_FromQty        ='    + ISNULL(CONVERT(VARCHAR(10),@D_FromQty),'')
                 + ',D_ToLot          =N''' + ISNULL(REPLACE(@D_ToLot           ,'''',''''''),'') + ''''
                 + ',D_ToLoc          =N''' + ISNULL(REPLACE(@D_ToLoc           ,'''',''''''),'') + ''''
                 + ',D_ToID           =N''' + ISNULL(REPLACE(@D_ToID            ,'''',''''''),'') + ''''
                 + ',D_ToQty          ='    + ISNULL(CONVERT(VARCHAR(10),@D_ToQty),'')
                 + ',D_ToLottable01   =N''' + ISNULL(REPLACE(@D_ToLottable01    ,'''',''''''),'') + ''''
                 + ',D_ToLottable02   =N''' + ISNULL(REPLACE(@D_ToLottable02    ,'''',''''''),'') + ''''
                 + ',D_ToLottable03   =N''' + ISNULL(REPLACE(@D_ToLottable03    ,'''',''''''),'') + ''''
                 + ',D_ToLottable04   =N''' + ISNULL(CONVERT(VARCHAR(23),@D_ToLottable04,121),'') + ''''
                 + ',D_ToLottable05   =N''' + ISNULL(CONVERT(VARCHAR(23),@D_ToLottable05,121),'') + ''''
                 + ',D_ToLottable06   =N''' + ISNULL(REPLACE(@D_ToLottable06    ,'''',''''''),'') + ''''
                 + ',D_ToLottable07   =N''' + ISNULL(REPLACE(@D_ToLottable07    ,'''',''''''),'') + ''''
                 + ',D_ToLottable08   =N''' + ISNULL(REPLACE(@D_ToLottable08    ,'''',''''''),'') + ''''
                 + ',D_ToLottable09   =N''' + ISNULL(REPLACE(@D_ToLottable09    ,'''',''''''),'') + ''''
                 + ',D_ToLottable10   =N''' + ISNULL(REPLACE(@D_ToLottable10    ,'''',''''''),'') + ''''
                 + ',D_ToLottable11   =N''' + ISNULL(REPLACE(@D_ToLottable11    ,'''',''''''),'') + ''''
                 + ',D_ToLottable12   =N''' + ISNULL(REPLACE(@D_ToLottable12    ,'''',''''''),'') + ''''
                 + ',D_ToLottable13   =N''' + ISNULL(CONVERT(VARCHAR(23),@D_ToLottable13,121),'') + ''''
                 + ',D_ToLottable14   =N''' + ISNULL(CONVERT(VARCHAR(23),@D_ToLottable14,121),'') + ''''
                 + ',D_ToLottable15   =N''' + ISNULL(CONVERT(VARCHAR(23),@D_ToLottable15,121),'') + ''''
                 + ',D_UserDefine01   =N''' + ISNULL(REPLACE(@D_UserDefine01    ,'''',''''''),'') + ''''
                 + ',D_UserDefine02   =N''' + ISNULL(REPLACE(@D_UserDefine02    ,'''',''''''),'') + ''''
                 + ',D_UserDefine03   =N''' + ISNULL(REPLACE(@D_UserDefine03    ,'''',''''''),'') + ''''
                 + ',D_UserDefine04   =N''' + ISNULL(REPLACE(@D_UserDefine04    ,'''',''''''),'') + ''''
                 + ',D_UserDefine05   =N''' + ISNULL(REPLACE(@D_UserDefine05    ,'''',''''''),'') + ''''
                 + ',D_UserDefine06   =N''' + ISNULL(CONVERT(VARCHAR(23),@D_UserDefine06,121),'') + ''''
                 + ',D_UserDefine07   =N''' + ISNULL(CONVERT(VARCHAR(23),@D_UserDefine07,121),'') + ''''
                 + ',D_UserDefine08   =N''' + ISNULL(REPLACE(@D_UserDefine08    ,'''',''''''),'') + ''''
                 + ',D_UserDefine09   =N''' + ISNULL(REPLACE(@D_UserDefine09    ,'''',''''''),'') + ''''
                 + ',D_UserDefine10   =N''' + ISNULL(REPLACE(@D_UserDefine10    ,'''',''''''),'') + ''''

               EXEC (@c_SQL)
            END

            SET @b_Success = 0

            -- Create Transfer
            IF EXISTS(SELECT TOP 1 1 FROM sys.parameters (NOLOCK) WHERE object_id = OBJECT_ID('dbo.ispCreateTransfer') AND name = '@c_UserDefine01')
               EXEC dbo.ispCreateTransfer
                    @c_FromStorerkey   = @c_Storerkey
                  , @c_FromSku         = @c_Sku
                  , @c_FromFacility    = @c_Facility
                  , @c_FromLot         = @c_Lot
                  , @c_FromLoc         = @c_FromLoc
                  , @c_FromID          = @c_Id
                  , @n_FromQty         = @D_FromQty
                  , @c_ToLot           = @D_ToLot
                  , @c_ToLoc           = @D_ToLoc
                  , @c_ToID            = @D_ToID
                  , @n_ToQty           = @D_ToQty
                  , @c_ToLottable01    = @D_ToLottable01
                  , @c_ToLottable02    = @D_ToLottable02
                  , @c_ToLottable03    = @D_ToLottable03
                  , @dt_ToLottable04   = @D_ToLottable04
                  , @dt_ToLottable05   = @D_ToLottable05
                  , @c_ToLottable06    = @D_ToLottable06
                  , @c_ToLottable07    = @D_ToLottable07
                  , @c_ToLottable08    = @D_ToLottable08
                  , @c_ToLottable09    = @D_ToLottable09
                  , @c_ToLottable10    = @D_ToLottable10
                  , @c_ToLottable11    = @D_ToLottable11
                  , @c_ToLottable12    = @D_ToLottable12
                  , @dt_ToLottable13   = @D_ToLottable13
                  , @dt_ToLottable14   = @D_ToLottable14
                  , @dt_ToLottable15   = @D_ToLottable15
                  , @c_CopyLottable    = 'Y'
                  , @c_Finalize        = 'N'
                  , @c_Type            = @H_Type
                  , @c_ReasonCode      = @H_ReasonCode
                  , @c_CustomerRefNo   = @H_CustomerRefNo
                  , @c_Remarks         = @H_Remarks
                  , @c_UserDefine01    = @H_UserDefine01
                  , @c_UserDefine02    = @H_UserDefine02
                  , @c_UserDefine03    = @H_UserDefine03
                  , @c_UserDefine04    = @H_UserDefine04
                  , @c_UserDefine05    = @H_UserDefine05
                  , @dt_UserDefine06   = @H_UserDefine06
                  , @dt_UserDefine07   = @H_UserDefine07
                  , @c_UserDefine08    = @H_UserDefine08
                  , @c_UserDefine09    = @H_UserDefine09
                  , @c_UserDefine10    = @H_UserDefine10
                  , @c_TDUserDefine01  = @D_UserDefine01
                  , @c_TDUserDefine02  = @D_UserDefine02
                  , @c_TDUserDefine03  = @D_UserDefine03
                  , @c_TDUserDefine04  = @D_UserDefine04
                  , @c_TDUserDefine05  = @D_UserDefine05
                  , @dt_TDUserDefine06 = @D_UserDefine06
                  , @dt_TDUserDefine07 = @D_UserDefine07
                  , @c_TDUserDefine08  = @D_UserDefine08
                  , @c_TDUserDefine09  = @D_UserDefine09
                  , @c_TDUserDefine10  = @D_UserDefine10
                  , @c_AllowTrfQtyAllocated = 'N'
                  , @c_Transferkey     = @c_Transferkey OUTPUT
                  , @b_Success         = @b_Success     OUTPUT
                  , @n_Err             = @n_Err         OUTPUT
                  , @c_ErrMsg          = @c_ErrMsg      OUTPUT
            ELSE
               EXEC dbo.ispCreateTransfer
                    @c_FromStorerkey   = @c_Storerkey
                  , @c_FromSku         = @c_Sku
                  , @c_FromFacility    = @c_Facility
                  , @c_FromLot         = @c_Lot
                  , @c_FromLoc         = @c_FromLoc
                  , @c_FromID          = @c_Id
                  , @n_FromQty         = @D_FromQty
                  , @c_ToLot           = @D_ToLot
                  , @c_ToLoc           = @D_ToLoc
                  , @c_ToID            = @D_ToID
                  , @n_ToQty           = @D_ToQty
                  , @c_ToLottable01    = @D_ToLottable01
                  , @c_ToLottable02    = @D_ToLottable02
                  , @c_ToLottable03    = @D_ToLottable03
                  , @dt_ToLottable04   = @D_ToLottable04
                  , @dt_ToLottable05   = @D_ToLottable05
                  , @c_ToLottable06    = @D_ToLottable06
                  , @c_ToLottable07    = @D_ToLottable07
                  , @c_ToLottable08    = @D_ToLottable08
                  , @c_ToLottable09    = @D_ToLottable09
                  , @c_ToLottable10    = @D_ToLottable10
                  , @c_ToLottable11    = @D_ToLottable11
                  , @c_ToLottable12    = @D_ToLottable12
                  , @dt_ToLottable13   = @D_ToLottable13
                  , @dt_ToLottable14   = @D_ToLottable14
                  , @dt_ToLottable15   = @D_ToLottable15
                  , @c_CopyLottable    = 'Y'
                  , @c_Finalize        = 'N'
                  , @c_Type            = @H_Type
                  , @c_ReasonCode      = @H_ReasonCode
                  , @c_CustomerRefNo   = @H_CustomerRefNo
                  , @c_Remarks         = @H_Remarks
                  , @c_Transferkey     = @c_Transferkey OUTPUT
                  , @b_Success         = @b_Success     OUTPUT
                  , @n_Err             = @n_Err         OUTPUT
                  , @c_ErrMsg          = @c_ErrMsg      OUTPUT

            IF  @b_Success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_Err), @n_err = 63214
               SELECT @c_errmsg = 'NSQL'+CONVERT(VARCHAR(10),@n_err)+': Create Transfer Error. (SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ')'
               BREAK
            END

            SET @n_OpenQty = @n_OpenQty - @D_FromQty
         END
         CLOSE CUR_INV
         DEALLOCATE CUR_INV
      END
      CLOSE CUR_TRF
      DEALLOCATE CUR_TRF
   END
   CLOSE CUR_STORER
   DEALLOCATE CUR_STORER

   --finalize current transfer
   IF @n_continue IN(1,2) AND ISNULL(@c_Transferkey,'') <> ''
   BEGIN
      UPDATE WAVE WITH (ROWLOCK)
         SET UserDefine10 = @c_Transferkey
           , Trafficcop = NULL
       WHERE Wavekey = @c_WaveKey

      IF ISNULL(@c_NoFinalizeTransfer,'') NOT IN ('1','Y')
      BEGIN
         EXEC ispFinalizeTransfer @c_Transferkey, @b_Success OUTPUT, @n_err OUTPUT, @c_errmsg OUTPUT

         IF @b_Success <> 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(VARCHAR(10),@n_err), @n_err = 63215
            SELECT @c_errmsg = 'NSQL'+CONVERT(VARCHAR(10),@n_err)+': Finalize Transfer# ' + RTRIM(@c_Transferkey) + ' Failed! (SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ')'
            GOTO EXIT_SP
         END
      END
   END

EXIT_SP:
   IF XACT_STATE() = -1   --(-1 = uncommittable)
      ROLLBACK TRAN

   IF CURSOR_STATUS( 'LOCAL', 'CUR_STORER') in (0 , 1)
   BEGIN
      CLOSE CUR_STORER
      DEALLOCATE CUR_STORER
   END
   IF CURSOR_STATUS( 'LOCAL', 'CUR_MAP') in (0 , 1)
   BEGIN
      CLOSE CUR_MAP
      DEALLOCATE CUR_MAP
   END
   IF CURSOR_STATUS( 'GLOBAL', 'CUR_TRF') in (0 , 1)
   BEGIN
      CLOSE CUR_TRF
      DEALLOCATE CUR_TRF
   END
   IF CURSOR_STATUS( 'GLOBAL', 'CUR_INV') in (0 , 1)
   BEGIN
      CLOSE CUR_INV
      DEALLOCATE CUR_INV
   END

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, @c_SP_Name
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END -- End PROC
GO
GRANT EXECUTE ON  [dbo].[isp_RCM_WV_Std_CreateTransfer] TO [NSQL]
GO