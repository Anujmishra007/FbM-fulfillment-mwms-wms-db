IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Id = OBJECT_ID(N'dbo.ispGenCCAdjustmentPost_MultiCnt') AND OBJECTPROPERTY(Id, N'IsProcedure') = 1)
   DROP PROCEDURE dbo.ispGenCCAdjustmentPost_MultiCnt
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*****************************************************************************/
/* Stored Procedure: ispGenCCAdjustmentPost_MultiCnt                         */
/* Creation Date  : 19-May-2005                                              */
/* Copyright      : IDS                                                      */
/* Written by     : Shong                                                    */
/*                                                                           */
/* Purpose:                                                                  */
/*                                                                           */
/* Called from: 1 (Stock Take )                                              */
/*    1. From PowerBuilder                                                   */
/*    2. From scheduler                                                      */
/*    3. From others stored procedures or triggers                           */
/*    4. From interface program. DX, DTS                                     */
/*                                                                           */
/* PVCS Version: 3.0                                                         */
/*                                                                           */
/* Version: 5.4                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author    Ver.  Purposes                                     */
/* 29-Jun-2005  June      1.0   SOS35681 - Turn ANSI NULL OFF before         */
/*                              compiling, otherwise incorrect Lot#          */
/* 01-Jul-2005  June      1.1   Add CCDetail Finalizeflag 'Y' checking       */
/* 10-Nov-2005  MaryVong  1.2   SOS42806 Increase length of returned fields  */
/*                              from ispParseParameters to NVARCHAR(800)     */
/* 05-Jan-2006  MaryVong  1.3   SOS44193 Update CCDetail.Status = '9'        */
/* 09-Nov-2006  Shong     1.4   Increase the Length of Id Variable, 10 to 18 */
/* 18-Jan-2008  June      1.5   SOS66279 : Include STOCKTAKEPARM2 checking   */
/* 05-Aug-2010  NJOW01    1.6   182454 - Add skugroup parameter              */
/* 24-Jan-2011  NJOW02    1.7   201680 - Add exclude Qty picked checking when*/
/*                              calculate system Qty                         */
/* 21-Jun-2012  Ung       1.8   SOS227151 - TM RDT CC                        */
/* 28-Aug-2012  Leong     1.9   SOS# 254455 - Group duplicate #Deposit record*/
/*                                          - Insert detail with Lottables.  */
/* 30-Aug-2012  SPChin    2.0   SOS254825-Update Adjustment.FinalizedFlag='Y'*/
/* 10-Sep-2012  James     2.1   SOS# 255810 - Remove LTRIM & RTRIM function. */
/* 19-Oct-2012  Ung       2.2   SOS254691 StocktakeSheetParameters.CountType */
/*                              Block normal countsheet if detected UCC data */
/* 03-Jan-2013  SPChin    2.3   SOS264402 - Bug Fixed                        */
/* 28-May-2014  TKLIM     2.4   Added Lottables 06-15                        */
/* 09-Sep-2014  YTWan     2.5   SOS#314647-Message prompt when there is no   */
/*                              qty variance for cycle count adjustment      */
/*                              posting. (Wan01)                             */
/* 26-Mar-2015  NJOW03    2.6   315484-CC Post adj by pallet current loc     */
/* 30-MAR-2016  Wan02     2.7   SOS#366947: SG-Stocktake LocationRoom Parm   */
/* 16-JUN-2016  Wan03     2.8   SOS#366947: SOS#371185 - CN Carter's SH      */
/*                              WMS Cycle Count module                       */
/* 29-JUN-2016  Wan03     2.9   SOS#370874 - TW Add Cycle Count Strategy     */
/* 23-NOV-2016  Wan04     3.0   WMS-648 - GW StockTake Parameter2 Enhancement*/
/*****************************************************************************/

CREATE PROC [dbo].[ispGenCCAdjustmentPost_MultiCnt] (
   @c_StockTakeKey  NVARCHAR(10),
   @c_CountNo       NVARCHAR(1),
   @b_success       Int OUTPUT,
   @c_TaskDetailKey NVARCHAR(10) = '',  -- From RDT
   @c_ByPalletLevel NVARCHAR(10) = 'N', -- NJOW03   
   @c_IDOnHold      NVARCHAR(10) = 'N'  -- NJOW03
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_facility         NVARCHAR(5),
           @c_StorerParm       NVARCHAR(60),
           @c_AisleParm        NVARCHAR(60),
           @c_LevelParm        NVARCHAR(60),
           @c_ZoneParm         NVARCHAR(60),
           @c_SKUParm          NVARCHAR(125),
           @c_HostWHCodeParm   NVARCHAR(60),
           @c_ClearHistory     NVARCHAR(1),
           @c_WithQuantity     NVARCHAR(1),
           @c_EmptyLocation    NVARCHAR(1),
           @n_LinesPerPage     Int,
           -- Added by SHONG 01 OCT 2002
           @c_AgencyParm       NVARCHAR(150),
           @c_ABCParm          NVARCHAR(60),
           @c_SkuGroupParm     NVARCHAR(125),
           @c_ExcludeQtyPicked NVARCHAR(1),
           @c_Loc              NVARCHAR(10),
           @c_Sku              NVARCHAR(20), 
           @c_CountType        NVARCHAR(10)
         --(Wan02) - START
         , @c_Extendedparm1Field       NVARCHAR(50)
         , @c_ExtendedParm1DataType    NVARCHAR(20)
         , @c_Extendedparm1            NVARCHAR(125)
         , @c_Extendedparm2Field       NVARCHAR(50)
         , @c_ExtendedParm2DataType    NVARCHAR(20)
         , @c_Extendedparm2            NVARCHAR(125)
         , @c_Extendedparm3Field       NVARCHAR(50)
         , @c_ExtendedParm3DataType    NVARCHAR(20)
         , @c_Extendedparm3            NVARCHAR(125)
         --(Wan02) - END
         , @c_ExcludeQtyAllocated      NVARCHAR(1)      --Wan03
   -- declare a select condition variable for parameters
   -- SOS42806 Changed NVARCHAR(250) and NVARCHAR(255) to NVARCHAR(800)
   DECLARE @c_AisleSQL         NVARCHAR(800),
           @c_LevelSQL         NVARCHAR(800),
           @c_ZoneSQL          NVARCHAR(800),
           @c_HostWHCodeSQL    NVARCHAR(800),
           @c_AisleSQL2        NVARCHAR(800),
           @c_LevelSQL2        NVARCHAR(800),
           @c_ZoneSQL2         NVARCHAR(800),
           @c_HostWHCodeSQL2   NVARCHAR(800),
           @c_SKUSQL           NVARCHAR(800),
           @c_SKUSQL2          NVARCHAR(800),
           @c_StorerSQL        NVARCHAR(800),
           @c_StorerSQL2       NVARCHAR(800),
           @n_continue         Int,
           @b_debug            Int,
           @c_sourcekey        NVARCHAR(20),
           @c_password         NVARCHAR(10),
           @c_protect          NVARCHAR(1),
           @c_AgencySQL        NVARCHAR(800),
           @c_AgencySQL2       NVARCHAR(800),
           @c_ABCSQL           NVARCHAR(800),
           @c_ABCSQL2          NVARCHAR(800),
           @c_AdjReasonCode    NVARCHAR(10),
           @c_AdjType          NVARCHAR(3),
           @c_SkuGroupSQL      NVARCHAR(800),
           @c_SkuGroupSQL2     NVARCHAR(800),
           @c_LocSQL           NVARCHAR(800),
           @c_Remark           NVARCHAR(260) --NJOW03
           --@c_Storer_SCSQL     NVARCHAR(800), --NJOW03
           --@c_Storer_SCSQL2    NVARCHAR(800), --NJOW03
           --@c_CCPostAdjByPalletID NVARCHAR(10) --NJOW03
         --(Wan02) - START
         ,  @c_Extendedparm1SQL  NVARCHAR(800)
         ,  @c_Extendedparm1SQL2 NVARCHAR(800)
         ,  @c_Extendedparm2SQL  NVARCHAR(800)
         ,  @c_Extendedparm2SQL2 NVARCHAR(800)
         ,  @c_Extendedparm3SQL  NVARCHAR(800)
         ,  @c_Extendedparm3SQL2 NVARCHAR(800)
         --(Wan02) - END
         ,  @c_StrategySQL    NVARCHAR(4000)       --(Wan03)
         ,  @c_StrategySkuSQL NVARCHAR(4000)       --(Wan03)
         ,  @c_StrategyLocSQL NVARCHAR(4000)       --(Wan03)

   --(Wan04) - START
   DECLARE @c_SkuConditionSQL          NVARCHAR(MAX)
         , @c_LocConditionSQL          NVARCHAR(MAX)
         , @c_ExtendedConditionSQL1    NVARCHAR(MAX)   
         , @c_ExtendedConditionSQL2    NVARCHAR(MAX)
         , @c_ExtendedConditionSQL3    NVARCHAR(MAX)
         , @c_StocktakeParm2SQL        NVARCHAR(MAX)
         , @c_StocktakeParm2OtherSQL   NVARCHAR(MAX)
   --(Wan04) - END

   -- Start : SOS66279
   DECLARE @c_SQL              NVARCHAR(max),
           @c_sqlOther         NVARCHAR(4000),
           @c_sqlWhere         NVARCHAR(4000)

   SELECT  @c_sqlOther = ''
   -- End : SOS66279

   DECLARE @c_StorerKey        NVARCHAR(15),
           @c_PrevStorerKey    NVARCHAR(15),
           @c_Lot              NVARCHAR(10),
           @c_Id               NVARCHAR(18),
           @c_Lottable01       NVARCHAR(18),
           @c_Lottable02       NVARCHAR(18),
           @c_Lottable03       NVARCHAR(18),
           @d_Lottable04       DATETIME,
           @d_Lottable05       DATETIME,
           @c_Lottable06       NVARCHAR(30),
           @c_Lottable07       NVARCHAR(30),
           @c_Lottable08       NVARCHAR(30),
           @c_Lottable09       NVARCHAR(30),
           @c_Lottable10       NVARCHAR(30),
           @c_Lottable11       NVARCHAR(30),
           @c_Lottable12       NVARCHAR(30),
           @d_Lottable13       DATETIME,
           @d_Lottable14       DATETIME,
           @d_Lottable15       DATETIME,
           @c_AdjustmentKey    NVARCHAR(10),
           @c_AdjDetailLine    NVARCHAR(5),
           @n_Qty              Int ,
           @c_UOM              NVARCHAR(10),
           @c_PackKey          NVARCHAR(10)

   DECLARE @b_isok             Int,
           @n_err              Int,
           @c_errmsg           NVARCHAR(215)

   SET @b_success = 1 -- 1=Success
   SELECT @n_continue = 1, @b_debug = 0

   --(Wan02) - START
   SET @c_Extendedparm1Field   = ''
   SET @c_ExtendedParm1DataType= ''
   SET @c_Extendedparm1        = ''
   SET @c_Extendedparm2Field   = '' 
   SET @c_ExtendedParm2DataType= ''
   SET @c_Extendedparm2        = ''
   SET @c_Extendedparm3Field   = ''
   SET @c_ExtendedParm3DataType= ''
   SET @c_Extendedparm3        = ''
   SET @c_Extendedparm1SQL     = ''
   SET @c_Extendedparm1SQL2    = ''
   SET @c_Extendedparm2SQL     = ''
   SET @c_Extendedparm2SQL2    = ''
   SET @c_Extendedparm3SQL     = ''
   SET @c_Extendedparm3SQL2    = ''
   --(Wan02) - END

   DECLARE @tAdjustment TABLE (AdjustmentKey NVARCHAR(10))

   SET @c_Loc = ISNULL(RTRIM(@c_Loc), '')
   SET @c_Sku = ISNULL(RTRIM(@c_Sku), '')

   DECLARE @n_IsRDT Int
   EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

   IF @n_IsRDT = 1
   BEGIN
      -- Set stock take parameters
      SELECT @c_StorerParm = '',
             @c_AisleParm = '',
             @c_LevelParm = '',
             @c_ZoneParm = '',
             @c_HostWHCodeParm = '',
             @c_SKUParm = '',
             @c_AgencyParm = '',
             @c_ABCParm = '',
             @c_SkuGroupParm = '',
             @c_ExcludeQtyPicked = 'Y'
       
      SET @c_ExcludeQtyAllocated = 'N'        --(Wan03)
      -- Get task info
      SELECT
         @c_Loc = FromLOC,
         @c_Sku = Sku
      FROM TaskDetail WITH (NOLOCK)
      WHERE TaskDetailKey = @c_TaskDetailKey

      -- Get facility
      SELECT @c_Facility = Facility FROM Loc WITH (NOLOCK) WHERE Loc = @c_Loc

      IF ISNULL(RTRIM(@c_Loc),'') <> ''
      BEGIN
         SET @c_LocSQL = ' AND (LOTxLOCxID.Loc = ''' + @c_Loc + ''' )'
      END

      IF ISNULL(RTRIM(@c_Sku),'') <> ''
      BEGIN
         SET @c_SkuSQL = ' AND (LOTxLOCxID.Sku = ''' + @c_Sku + ''' )'
      END
   END
   ELSE
   BEGIN
 
      SELECT @c_Facility = Facility,
             @c_StorerParm = StorerKey,
             @c_AisleParm = AisleParm,
             @c_LevelParm = LevelParm,
             @c_ZoneParm = ZoneParm,
             @c_HostWHCodeParm = HostWHCodeParm,
             @c_SKUParm = SKUParm,
             @c_WithQuantity = WithQuantity,
             @c_ClearHistory = ClearHistory,
             @c_EmptyLocation = EmptyLocation,
             @n_LinesPerPage = LinesPerPage,
             @c_password = password,
             @c_protect = protect,
             @c_AgencyParm = AgencyParm,
             @c_ABCParm = ABCParm,
             @c_AdjReasonCode = AdjReasonCode,
             @c_AdjType    = AdjType,
             @c_SkuGroupParm = SkuGroupParm,
             @c_ExcludeQtyPicked = ExcludeQtyPicked, 
             @c_CountType = CountType
            --(Wan02) - START
            , @c_ExtendedParm1Field = ExtendedParm1Field
            , @c_ExtendedParm1      = ExtendedParm1 
            , @c_ExtendedParm2Field = ExtendedParm2Field
            , @c_ExtendedParm2      = ExtendedParm2 
            , @c_ExtendedParm3Field = ExtendedParm3Field 
            , @c_ExtendedParm3      = ExtendedParm3
            --(Wan02) - END 
            , @c_ExcludeQtyAllocated = ExcludeQtyAllocated        --(Wan03)
      FROM StockTakeSheetParameters WITH (NOLOCK)
      WHERE StockTakeKey = @c_StockTakeKey

      IF @c_CountType = 'UCC'
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 67106
         SELECT @c_errmsg = "NSQL" + CONVERT(Char(5), @n_err) + "CountType=UCC, but posting=non-UCC (ispGenCCAdjustmentPost_MultiCnt)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
         GOTO EXIT_SP
      END

      IF @c_StorerParm IS NULL
      BEGIN
         SELECT @n_continue = 3
         RAISERROR ('Bad StorerKey', 16, 1)
         RETURN
      END

      IF @c_CountNo NOT IN ('1','2','3')
      BEGIN
         SELECT @n_continue = 3
         RAISERROR ('Bad Count Number.', 16, 1)
         RETURN
      END

      EXEC ispParseParameters
           @c_AisleParm,
           'string',
           'Loc.LOCAISLE',
           @c_AisleSQL OUTPUT,
           @c_AisleSQL2 OUTPUT,
           @b_success OUTPUT

      EXEC ispParseParameters
           @c_LevelParm,
           'number',
           'Loc.LOCLEVEL',
           @c_LevelSQL OUTPUT,
           @c_LevelSQL2 OUTPUT,
           @b_success OUTPUT

      EXEC ispParseParameters
           @c_ZoneParm,
           'string',
           'Loc.PutawayZone',
           @c_ZoneSQL OUTPUT,
           @c_ZoneSQL2 OUTPUT,
           @b_success OUTPUT

      EXEC ispParseParameters
           @c_HostWHCodeParm,
           'string',
           'Loc.HostWHCode',
           @c_HostWHCodeSQL OUTPUT,
           @c_HostWHCodeSQL2 OUTPUT,
           @b_success OUTPUT

      EXEC ispParseParameters
           @c_SKUParm,
           'string',
           'LOTxLOCxID.Sku',
           @c_SKUSQL OUTPUT,
           @c_SKUSQL2 OUTPUT,
           @b_success OUTPUT

      EXEC ispParseParameters
           @c_StorerParm,
           'string',
           'LOTxLOCxID.StorerKey',
           @c_StorerSQL OUTPUT,
           @c_StorerSQL2 OUTPUT,
           @b_success OUTPUT

      -- Added By SHONG 01 Oct 2002
      EXEC ispParseParameters
           @c_AgencyParm,
           'string',
           'Sku.SUSR3',
           @c_AgencySQL OUTPUT,
           @c_AgencySQL2 OUTPUT,
           @b_success OUTPUT

      EXEC ispParseParameters
           @c_ABCParm,
           'string',
           'Sku.ABC',
           @c_ABCSQL OUTPUT,
           @c_ABCSQL2 OUTPUT,
           @b_success OUTPUT
      -- End
      EXEC ispParseParameters
           @c_SkuGroupParm,
           'string',
           'Sku.SKUGROUP',
           @c_SkuGroupSQL OUTPUT,
           @c_SkuGroupSQL2 OUTPUT,
           @b_success OUTPUT

      --(Wan02) - START
      EXEC isp_GetDataType
         @c_TableName   = ''
       , @c_FieldName   = @c_ExtendedParm1Field
       , @c_DB_DataType = ''  
       , @c_PB_DataType = @c_ExtendedParm1DataType OUTPUT


      IF @c_ExtendedParm1DataType <> '' 
      BEGIN
         EXEC ispParseParameters
          @c_ExtendedParm1
         ,@c_ExtendedParm1DataType 
         ,@c_ExtendedParm1Field
         ,@c_ExtendedParm1SQL    OUTPUT 
         ,@c_ExtendedParm1SQL2   OUTPUT 
         ,@b_success             OUTPUT
      END 

      EXEC isp_GetDataType
         @c_TableName   = ''
       , @c_FieldName   = @c_ExtendedParm2Field
       , @c_DB_DataType = ''  
       , @c_PB_DataType = @c_ExtendedParm2DataType OUTPUT

      IF @c_ExtendedParm2DataType <> '' 
      BEGIN
         EXEC ispParseParameters
          @c_ExtendedParm2
         ,@c_ExtendedParm2DataType 
         ,@c_ExtendedParm2Field
         ,@c_ExtendedParm2SQL    OUTPUT 
         ,@c_ExtendedParm2SQL2   OUTPUT 
         ,@b_success             OUTPUT
      END 

      EXEC isp_GetDataType
         @c_TableName   = ''
       , @c_FieldName   = @c_ExtendedParm3Field
       , @c_DB_DataType = ''  
       , @c_PB_DataType = @c_ExtendedParm3DataType OUTPUT

      IF @c_ExtendedParm3DataType <> '' 
      BEGIN
         EXEC ispParseParameters
          @c_ExtendedParm3
         ,@c_ExtendedParm3DataType 
         ,@c_ExtendedParm3Field
         ,@c_ExtendedParm3SQL    OUTPUT 
         ,@c_ExtendedParm3SQL2   OUTPUT 
         ,@b_success             OUTPUT
      END 
      --(Wan02) - END

      --NJOW03
      /*
      EXEC ispParseParameters
           @c_StorerParm,
           'string',
           'STORER.StorerKey',
           @c_Storer_SCSQL OUTPUT,
           @c_Storer_SCSQL2 OUTPUT,
           @b_success OUTPUT                      
      */
   END
 
   -- Generate WithDraw Stock from Lotxlocxid table
   IF @b_debug = 1
   BEGIN
      SELECT RTRIM(@c_facility) + '" '
           + RTRIM(@c_ZoneSQL) + ' ' + RTRIM(@c_ZoneSQL2) + ' '
           + RTRIM(@c_AisleSQL) + ' ' + RTRIM(@c_AisleSQL2) + ' '
           + RTRIM(@c_LevelSQL) + ' ' + RTRIM(@c_LevelSQL2) + ' '
           + RTRIM(@c_HostWHCodeSQL) + ' ' + RTRIM(@c_HostWHCodeSQL2) + ' '
           + RTRIM(@c_SKUSQL) + ' ' + RTRIM(@c_SKUSQL2) + ' '
           + RTRIM(@c_StorerSQL) + ' ' + RTRIM(@c_StorerSQL2)
   END

   CREATE TABLE #Withdraw  (
         StorerKey      NVARCHAR (15) NULL ,
         Sku            NVARCHAR (20) NOT NULL ,
         Lot            NVARCHAR (10) NULL ,
         Id             NVARCHAR (18) NULL,
         Loc            NVARCHAR (10) NOT NULL ,
         Qty            Int       NOT NULL,
         Lottable01     NVARCHAR (18) NULL ,
         Lottable02     NVARCHAR (18) NULL ,
         Lottable03     NVARCHAR (18) NULL ,
         Lottable04     DATETIME  NULL ,
         Lottable05     DATETIME  NULL ,
         Lottable06     NVARCHAR (30) NULL ,
         Lottable07     NVARCHAR (30) NULL ,
         Lottable08     NVARCHAR (30) NULL ,
         Lottable09     NVARCHAR (30) NULL ,
         Lottable10     NVARCHAR (30) NULL ,
         Lottable11     NVARCHAR (30) NULL ,
         Lottable12     NVARCHAR (30) NULL ,
         Lottable13     DATETIME NULL ,
         Lottable14     DATETIME NULL ,
         Lottable15     DATETIME NULL 

   )
   CREATE TABLE #Deposit (
         StorerKey      NVARCHAR (15) NULL ,
         Sku            NVARCHAR (20) NOT NULL ,
         Lot            NVARCHAR (10) NULL ,
         Id             NVARCHAR (18) NULL,
         Loc            NVARCHAR (10) NOT NULL ,
         Qty            Int       NOT NULL,
         Lottable01     NVARCHAR (18) NULL ,
         Lottable02     NVARCHAR (18) NULL ,
         Lottable03     NVARCHAR (18) NULL ,
         Lottable04     DATETIME  NULL ,
         Lottable05     DATETIME  NULL ,
         Lottable06     NVARCHAR (30) NULL ,
         Lottable07     NVARCHAR (30) NULL ,
         Lottable08     NVARCHAR (30) NULL ,
         Lottable09     NVARCHAR (30) NULL ,
         Lottable10     NVARCHAR (30) NULL ,
         Lottable11     NVARCHAR (30) NULL ,
         Lottable12     NVARCHAR (30) NULL ,
         Lottable13     DATETIME NULL ,
         Lottable14     DATETIME NULL ,
         Lottable15     DATETIME NULL 
   )
   CREATE TABLE #Variance (
         StorerKey      NVARCHAR (15) NULL ,
         Sku            NVARCHAR (20) NOT NULL ,
         Lot            NVARCHAR (10) NULL ,
         Id             NVARCHAR (18) NULL,
         Loc            NVARCHAR (10) NOT NULL ,
         Qty            Int       NOT NULL,
         Lottable01     NVARCHAR (18) NULL ,
         Lottable02     NVARCHAR (18) NULL ,
         Lottable03     NVARCHAR (18) NULL ,
         Lottable04     DATETIME  NULL ,
         Lottable05     DATETIME  NULL ,
         Lottable06     NVARCHAR (30) NULL ,
         Lottable07     NVARCHAR (30) NULL ,
         Lottable08     NVARCHAR (30) NULL ,
         Lottable09     NVARCHAR (30) NULL ,
         Lottable10     NVARCHAR (30) NULL ,
         Lottable11     NVARCHAR (30) NULL ,
         Lottable12     NVARCHAR (30) NULL ,
         Lottable13     DATETIME NULL ,
         Lottable14     DATETIME NULL ,
         Lottable15     DATETIME NULL 
   )

   CREATE TABLE #Deposit2 ( -- SOS# 254455
         StorerKey      NVARCHAR (15) NULL ,
         Sku            NVARCHAR (20) NOT NULL ,
         Lot            NVARCHAR (10) NULL ,
         Id             NVARCHAR (18) NULL,
         Loc            NVARCHAR (10) NOT NULL ,
         Qty            Int       NOT NULL,
         Lottable01     NVARCHAR (18) NULL ,
         Lottable02     NVARCHAR (18) NULL ,
         Lottable03     NVARCHAR (18) NULL ,
         Lottable04     DATETIME  NULL ,
         Lottable05     DATETIME  NULL ,
         Lottable06     NVARCHAR (30) NULL ,
         Lottable07     NVARCHAR (30) NULL ,
         Lottable08     NVARCHAR (30) NULL ,
         Lottable09     NVARCHAR (30) NULL ,
         Lottable10     NVARCHAR (30) NULL ,
         Lottable11     NVARCHAR (30) NULL ,
         Lottable12     NVARCHAR (30) NULL ,
         Lottable13     DATETIME NULL ,
         Lottable14     DATETIME NULL ,
         Lottable15     DATETIME NULL 
   )

   --NJOW03 Start
   /*
   CREATE TABLE #STORER_CONFIG (
         StorerKey  NVARChar (15) NULL ,
         Configkey  NVARChar (30) NULL ,
         SValue     NVARChar (10) NULL 
   )
   
   SELECT @c_SQL = N'SELECT STORER.Storerkey, STORERCONFIG.Configkey, STORERCONFIG.Svalue '
         +  'FROM STORER (NOLOCK) '
         +  'LEFT JOIN STORERCONFIG (NOLOCK) ON STORER.Storerkey = STORERCONFIG.Storerkey AND STORERCONFIG.Svalue=''1'' '
         +  '                                AND (ISNULL(STORERCONFIG.Facility,'''')='''' OR STORERCONFIG.Facility = ''' + ISNULL(RTRIM(@c_facility), '') + ''') '
         +  'WHERE 1=1 '
         +  ISNULL(RTRIM(@c_Storer_SCSQL), '') + ' ' + ISNULL(RTRIM(@c_Storer_SCSQL2), '') + ' '
   
   INSERT INTO #STORER_CONFIG (StorerKey, Configkey, Svalue)
     EXEC (@c_SQL )         
         
   IF ((SELECT COUNT(DISTINCT Storerkey) FROM #STORER_CONFIG WHERE Configkey = 'CCPostAdjByPalletID' AND ISNULL(Svalue,'')='1') =      
      (SELECT COUNT(DISTINCT Storerkey) FROM #STORER_CONFIG)) AND 
      (SELECT COUNT(DISTINCT Storerkey) FROM #STORER_CONFIG WHERE Configkey = 'CCPostAdjByPalletID' AND ISNULL(Svalue,'')='1') > 0
   BEGIN
   	  SELECT @c_CCPostAdjByPalletID = '1'
   END
   ELSE
   BEGIN
   	  SELECT @c_CCPostAdjByPalletID = '0'
   END   
   */
   --NJOW03 End
   
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      --(Wan03) - START
      EXEC ispCCStrategy 
         @c_StockTakeKey   = @c_StockTakeKey
      ,  @c_StrategySQL    = @c_StrategySQL     OUTPUT
      ,  @c_StrategySkuSQL = @c_StrategySkuSQL  OUTPUT
      ,  @c_StrategyLocSQL = @c_StrategyLocSQL  OUTPUT
      ,  @b_Success        = @b_Success         OUTPUT      
      ,  @n_err            = @n_err             OUTPUT        
      ,  @c_errmsg         = @c_errmsg          OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
         RAISERROR('Error Executing ispCCStrategy', 16, 1)
         RETURN 
      END
      --(Wan03) - END

      --(Wan04) - START
      SET @c_SkuConditionSQL = ISNULL(RTrim(@c_SKUSQL), '')      + ' ' + ISNULL(RTrim(@c_SKUSQL2), '') + ' '
                             + ISNULL(RTrim(@c_AgencySQL), '')   + ' ' + ISNULL(RTrim(@c_AgencySQL2), '') + ' '
                             + ISNULL(RTrim(@c_ABCSQL), '')      + ' ' + ISNULL(RTrim(@c_ABCSQL2), '') + ' '
                             + ISNULL(RTrim(@c_SkuGroupSQL), '') + ' ' + ISNULL(RTrim(@c_SkuGroupSQL2), '') + ' ' 

      SET @c_LocConditionSQL =        
                             + ISNULL(RTrim(@c_ZoneSQL), '')       + ' ' + ISNULL(RTrim(@c_ZoneSQL2), '') + ' '
                             + ISNULL(RTrim(@c_AisleSQL), '')      + ' ' + ISNULL(RTrim(@c_AisleSQL2), '') + ' '
                             + ISNULL(RTrim(@c_LevelSQL), '')      + ' ' + ISNULL(RTrim(@c_LevelSQL2), '') + ' '
                             + ISNULL(RTrim(@c_HostWHCodeSQL), '') + ' ' + ISNULL(RTrim(@c_HostWHCodeSQL2), '') + ' '
                              
      SET @c_ExtendedConditionSQL1 = ISNULL(RTrim(@c_ExtendedParm1SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm1SQL2), '')                               
      SET @c_ExtendedConditionSQL2 = ISNULL(RTrim(@c_ExtendedParm2SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm2SQL2), '') 
      SET @c_ExtendedConditionSQL3 = ISNULL(RTrim(@c_ExtendedParm3SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm3SQL2), '') 

      EXEC ispGetStocktakeParm2 
            @c_StockTakeKey    = @c_StockTakeKey
         ,  @c_ByPalletLevel   = @c_ByPalletLevel
         ,  @c_SkuConditionSQL = @c_SkuConditionSQL
         ,  @c_LocConditionSQL = @c_LocConditionSQL
         ,  @c_ExtendedConditionSQL1 = @c_ExtendedConditionSQL1
         ,  @c_ExtendedConditionSQL2 = @c_ExtendedConditionSQL2
         ,  @c_ExtendedConditionSQL3 = @c_ExtendedConditionSQL3
         ,  @c_StocktakeParm2SQL = @c_StocktakeParm2SQL OUTPUT
         ,  @c_StocktakeParm2OtherSQL = @c_StocktakeParm2OtherSQL OUTPUT
      --(Wan04) - END


      -- Start : SOS66279
      IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK) WHERE Stocktakekey = @c_StockTakeKey) OR @n_IsRDT = 1
      BEGIN
      -- End : SOS66279
         IF @c_ByPalletLevel = 'Y' 
         BEGIN         
         	  --NJOW03
            SELECT @c_SQL = N'SELECT LOTxLOCxID.StorerKey, LOTxLOCxID.Sku, LOTxLOCxID.Lot, '
                + 'LOTxLOCxID.Id, LOTxLOCxID.Loc, '
                --(Wan03) - START
                --+ CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.qtypicked, ' ELSE 'LOTxLOCxID.Qty, ' END
                +  CASE WHEN @c_ExcludeQtyAllocated = 'Y' AND @c_ExcludeQtyPicked = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated-LOTxLOCxID.Qtypicked, '
                        WHEN @c_ExcludeQtyAllocated = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated, ' 
                        WHEN @c_ExcludeQtyPicked    = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtypicked, '
                        ELSE 'LOTxLOCxID.Qty, ' END
                --(Wan03) - END   
                + 'ISNULL(LotAttribute.Lottable01, ''''), ISNULL(LotAttribute.Lottable02, ''''), '
                + 'ISNULL(LotAttribute.Lottable03, ''''), LotAttribute.Lottable04, '
                + 'LotAttribute.Lottable05, '
                + 'ISNULL(LotAttribute.Lottable06, ''''), '
                + 'ISNULL(LotAttribute.Lottable07, ''''), '
                + 'ISNULL(LotAttribute.Lottable08, ''''), '
                + 'ISNULL(LotAttribute.Lottable09, ''''), '
                + 'ISNULL(LotAttribute.Lottable10, ''''), '
                + 'ISNULL(LotAttribute.Lottable11, ''''), '
                + 'ISNULL(LotAttribute.Lottable12, ''''), '
                + 'LotAttribute.Lottable13, '
                + 'LotAttribute.Lottable14, '
                + 'LotAttribute.Lottable15 '
                + 'FROM Loc (NOLOCK), LOTxLOCxID (NOLOCK), LotAttribute (NOLOCK), Sku (NOLOCK) '
                + 'WHERE Loc.Loc = LOTxLOCxID.Loc '
                + 'AND LOTxLOCxID.Lot = LotAttribute.Lot '
                + 'AND LOTxLOCxID.StorerKey = Sku.StorerKey '
                + 'AND LOTxLOCxID.Sku = Sku.Sku '
                --(Wan03) - START
                --+ CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'AND LOTxLOCxID.Qty > 0 ' END
                +  CASE WHEN @c_ExcludeQtyAllocated = 'Y' AND @c_ExcludeQtyPicked = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated-LOTxLOCxID.Qtypicked > 0 '
                        WHEN @c_ExcludeQtyAllocated = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated > 0 ' 
                        WHEN @c_ExcludeQtyPicked    = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.Qtypicked > 0 '
                        ELSE 'AND LOTxLOCxID.Qty > 0 ' END
                --(Wan03) - END 
                + 'AND Loc.facility = "' + ISNULL(RTRIM(@c_facility), '') + '" '
                + 'AND EXISTS (SELECT 1 FROM CCDETAIL CC (NOLOCK) WHERE CC.Storerkey = LOTXLOCXID.Storerkey AND CC.Id = LOTXLOCXID.ID ' 
                + '            AND ISNULL(CC.ID,'''') <> '''' AND CC.CCKey = ''' + RTRIM(ISNULL(@c_StockTakeKey,'')) + ''') '
                + ISNULL(RTRIM(@c_StorerSQL), '') + ' ' + ISNULL(RTRIM(@c_StorerSQL2), '') + ' '
                + ISNULL(RTRIM(@c_SKUSQL), '') + ' ' + ISNULL(RTRIM(@c_SKUSQL2), '') + ' '
                + ISNULL(RTRIM(@c_AgencySQL), '') + ' ' + ISNULL(RTRIM(@c_AgencySQL2), '') + ' '
                + ISNULL(RTRIM(@c_ABCSQL), '') + ' ' + ISNULL(RTRIM(@c_ABCSQL2), '') + ' '
                + ISNULL(RTRIM(@c_SkuGroupSQL), '') + ' ' + ISNULL(RTRIM(@c_SkuGroupSQL2), '') + ' '
                + ISNULL(RTRIM(@c_LocSQL), '') + ' '
               + ISNULL(RTRIM(@c_ExtendedParm1SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm1SQL2), '') + ' '  --(Wan02)
               + ISNULL(RTRIM(@c_ExtendedParm2SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm2SQL2), '') + ' '  --(Wan02)
               + ISNULL(RTRIM(@c_ExtendedParm3SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm3SQL2), '') + ' '  --(Wan02)
               + RTRIM(@c_StrategySQL) + ' '                                                                   --(Wan03)
         END
         ELSE
         BEGIN
            SELECT @c_SQL = N'SELECT LOTxLOCxID.StorerKey, LOTxLOCxID.Sku, LOTxLOCxID.Lot, '
                + 'LOTxLOCxID.Id, LOTxLOCxID.Loc, '
                --(Wan03) - START
                --+ CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.qtypicked, ' ELSE 'LOTxLOCxID.Qty, ' END
                +  CASE WHEN @c_ExcludeQtyAllocated = 'Y' AND @c_ExcludeQtyPicked = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated-LOTxLOCxID.Qtypicked, '
                        WHEN @c_ExcludeQtyAllocated = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated, ' 
                        WHEN @c_ExcludeQtyPicked    = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtypicked, '
                        ELSE 'LOTxLOCxID.Qty, ' END
                --(Wan03) - END  
                + 'ISNULL(LotAttribute.Lottable01, ''''), '
                + 'ISNULL(LotAttribute.Lottable02, ''''), '
                + 'ISNULL(LotAttribute.Lottable03, ''''), '
                + 'LotAttribute.Lottable04, '
                + 'LotAttribute.Lottable05, '
                + 'ISNULL(LotAttribute.Lottable06, ''''), '
                + 'ISNULL(LotAttribute.Lottable07, ''''), '
                + 'ISNULL(LotAttribute.Lottable08, ''''), '
                + 'ISNULL(LotAttribute.Lottable09, ''''), '
                + 'ISNULL(LotAttribute.Lottable10, ''''), '
                + 'ISNULL(LotAttribute.Lottable11, ''''), '
                + 'ISNULL(LotAttribute.Lottable12, ''''), '
                + 'LotAttribute.Lottable13, '
                + 'LotAttribute.Lottable14, '
                + 'LotAttribute.Lottable15 '
                + 'FROM Loc (NOLOCK), LOTxLOCxID (NOLOCK), LotAttribute (NOLOCK), Sku (NOLOCK) '
                + 'WHERE Loc.Loc = LOTxLOCxID.Loc '
                + 'AND LOTxLOCxID.Lot = LotAttribute.Lot '
                + 'AND LOTxLOCxID.StorerKey = Sku.StorerKey '
                + 'AND LOTxLOCxID.Sku = Sku.Sku '
                --(Wan03) - START
                --+ CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'AND LOTxLOCxID.Qty > 0 ' END
                +  CASE WHEN @c_ExcludeQtyAllocated = 'Y' AND @c_ExcludeQtyPicked = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated-LOTxLOCxID.Qtypicked > 0 '
                        WHEN @c_ExcludeQtyAllocated = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated > 0 ' 
                        WHEN @c_ExcludeQtyPicked    = 'Y' THEN 'AND LOTxLOCxID.Qty-LOTxLOCxID.Qtypicked > 0 '
                        ELSE 'AND LOTxLOCxID.Qty > 0 ' END
                --(Wan03) - END  
                + 'AND Loc.facility = "' + ISNULL(RTRIM(@c_facility), '') + '" '
                + ISNULL(RTRIM(@c_ZoneSQL), '') + ' ' + ISNULL(RTRIM(@c_ZoneSQL2), '') + ' '
                + ISNULL(RTRIM(@c_AisleSQL), '') + ' ' + ISNULL(RTRIM(@c_AisleSQL2), '') + ' '
                + ISNULL(RTRIM(@c_LevelSQL), '') + ' ' + ISNULL(RTRIM(@c_LevelSQL2), '') + ' '
                + ISNULL(RTRIM(@c_HostWHCodeSQL), '') + ' ' + ISNULL(RTRIM(@c_HostWHCodeSQL2), '') + ' '
                + ISNULL(RTRIM(@c_StorerSQL), '') + ' ' + ISNULL(RTRIM(@c_StorerSQL2), '') + ' '
                + ISNULL(RTRIM(@c_SKUSQL), '') + ' ' + ISNULL(RTRIM(@c_SKUSQL2), '') + ' '
                + ISNULL(RTRIM(@c_AgencySQL), '') + ' ' + ISNULL(RTRIM(@c_AgencySQL2), '') + ' '
                + ISNULL(RTRIM(@c_ABCSQL), '') + ' ' + ISNULL(RTRIM(@c_ABCSQL2), '') + ' '
                + ISNULL(RTRIM(@c_SkuGroupSQL), '') + ' ' + ISNULL(RTRIM(@c_SkuGroupSQL2), '') + ' '
                + ISNULL(RTRIM(@c_LocSQL), '') + ' '
               + ISNULL(RTRIM(@c_ExtendedParm1SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm1SQL2), '') + ' '  --(Wan02)
               + ISNULL(RTRIM(@c_ExtendedParm2SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm2SQL2), '') + ' '  --(Wan02)
               + ISNULL(RTRIM(@c_ExtendedParm3SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm3SQL2), '') + ' '  --(Wan02)
               + RTRIM(@c_StrategySQL) + ' '                                                                   --(Wan03)
         END
      -- Start : SOS66279
      END
      ELSE
      BEGIN
         SELECT @c_SQL = N'SELECT LOTxLOCxID.StorerKey, LOTxLOCxID.Sku, LOTxLOCxID.Lot, '
                        + 'LOTxLOCxID.Id, LOTxLOCxID.Loc, '
                        --(Wan03) - START
                        --+  CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.qtypicked, ' ELSE 'LOTxLOCxID.Qty, ' END
                        +  CASE WHEN @c_ExcludeQtyAllocated = 'Y' AND @c_ExcludeQtyPicked = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated-LOTxLOCxID.Qtypicked, '
                                WHEN @c_ExcludeQtyAllocated = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated, ' 
                                WHEN @c_ExcludeQtyPicked    = 'Y' THEN 'LOTxLOCxID.Qty-LOTxLOCxID.Qtypicked, '
                                ELSE 'LOTxLOCxID.Qty, ' END
                        --(Wan03) - END                                 
                        + 'ISNULL(LotAttribute.Lottable01, ''''), '
                        + 'ISNULL(LotAttribute.Lottable02, ''''), '
                        + 'ISNULL(LotAttribute.Lottable03, ''''), '
                        + 'LotAttribute.Lottable04, '
                        + 'LotAttribute.Lottable05, '
                        + 'ISNULL(LotAttribute.Lottable06, ''''), '
                        + 'ISNULL(LotAttribute.Lottable07, ''''), '
                        + 'ISNULL(LotAttribute.Lottable08, ''''), '
                        + 'ISNULL(LotAttribute.Lottable09, ''''), '
                        + 'ISNULL(LotAttribute.Lottable10, ''''), '
                        + 'ISNULL(LotAttribute.Lottable11, ''''), '
                        + 'ISNULL(LotAttribute.Lottable12, ''''), '
                        + 'LotAttribute.Lottable13, '
                        + 'LotAttribute.Lottable14, '
                        + 'LotAttribute.Lottable15 '
                        + 'FROM Loc WITH (NOLOCK) '
                        + 'JOIN LOTxLOCxID WITH (NOLOCK) ON LOTxLOCxID.Loc = Loc.Loc '
                        + 'JOIN LotAttribute WITH (NOLOCK) ON LotAttribute.Lot = LOTxLOCxID.Lot '
                        + 'JOIN Sku WITH (NOLOCK) ON Sku.StorerKey = LOTxLOCxID.StorerKey AND Sku.Sku = LOTxLOCxID.Sku '

         --(Wan04) - START
         SET @c_sql = @c_sql + @c_StocktakeParm2SQL
         SET @c_sqlOther = @c_sqlOther + @c_StocktakeParm2OtherSQL

         /* 
         IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK)
                        WHERE Stocktakekey = @c_StockTakeKey
                        AND   UPPER(Tablename) = 'Sku')
         BEGIN
            SELECT @c_SQLOther = @c_SQLOther + ' '
                               + ISNULL(RTRIM(@c_SKUSQL), '') + ' ' + ISNULL(RTRIM(@c_SKUSQL2), '') + ' '
                               + ISNULL(RTRIM(@c_AgencySQL), '') + ' ' + ISNULL(RTRIM(@c_AgencySQL2), '') + ' '
                               + ISNULL(RTRIM(@c_ABCSQL), '') + ' ' + ISNULL(RTRIM(@c_ABCSQL2), '') + ' '
                               + ISNULL(RTRIM(@c_SkuGroupSQL), '') + ' ' + ISNULL(RTRIM(@c_SkuGroupSQL2), '') + ' '
               --(Wan02) - START
               IF ISNULL(RTRIM(@c_ExtendedParm1Field),'') <> '' AND 
                  SUBSTRING(@c_ExtendedParm1Field, 1, CHARINDEX('.', @c_ExtendedParm1Field) - 1) = 'sku' 
               BEGIN
                  SET @c_SQLOther = @c_SQLOther + ' ' 
                                  + ISNULL(RTrim(@c_ExtendedParm1SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm1SQL2), '') 
                                  + ' '
               END

               IF ISNULL(RTRIM(@c_ExtendedParm2Field),'') <> '' AND 
                  SUBSTRING(@c_ExtendedParm2Field, 1, CHARINDEX('.', @c_ExtendedParm2Field) - 1) = 'sku' 
               BEGIN
                  SET @c_SQLOther = @c_SQLOther + ' ' 
                                  + ISNULL(RTrim(@c_ExtendedParm2SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm2SQL2), '')
                                  + ' ' 
               END

               IF ISNULL(RTRIM(@c_ExtendedParm3Field),'') <> '' AND 
                  SUBSTRING(@c_ExtendedParm3Field, 1, CHARINDEX('.', @c_ExtendedParm3Field) - 1) = 'sku' 
               BEGIN
                  SET @c_SQLOther = @c_SQLOther + ' ' 
                                  + ISNULL(RTrim(@c_ExtendedParm3SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm3SQL2), '') 
                                  + ' ' 
               END
               --(Wan02) - END
         END
         ELSE
         BEGIN
            SELECT @c_SQL = @c_SQL + ' '
                          + 'JOIN STOCKTAKEPARM2 PARM2_SKU WITH (NOLOCK) '
                          + ' ON PARM2_SKU.StorerKey = LOTxLOCxID.StorerKey '
                          + 'AND RTRIM(LTRIM(PARM2_SKU.Value)) = LOTxLOCxID.Sku '
                          + 'AND UPPER(PARM2_SKU.Tablename) = ''Sku'' '
                          + 'AND PARM2_SKU.Stocktakekey = ''' + ISNULL(RTRIM(@c_StockTakeKey), '') + ''''
         END

         IF @c_ByPalletLevel <> 'Y' --NJOW03
         BEGIN
            IF NOT EXISTS (SELECT 1 FROM STOCKTAKEPARM2 WITH (NOLOCK)
                           WHERE Stocktakekey = @c_StockTakeKey
                           AND   UPPER(Tablename) = 'Loc')
            BEGIN
               SELECT @c_SQLOther = @c_SQLOther + ' '
                                  + ISNULL(RTRIM(@c_ZoneSQL), '') + ' ' + ISNULL(RTRIM(@c_ZoneSQL2), '') + ' '
                                  + ISNULL(RTRIM(@c_AisleSQL), '') + ' ' + ISNULL(RTRIM(@c_AisleSQL2), '') + ' '
                                  + ISNULL(RTRIM(@c_LevelSQL), '') + ' ' + ISNULL(RTRIM(@c_LevelSQL2), '') + ' '
                                  + ISNULL(RTRIM(@c_HostWHCodeSQL), '') + ' ' + ISNULL(RTRIM(@c_HostWHCodeSQL2), '')+ ' '  

               --(Wan02) - START
               IF ISNULL(RTRIM(@c_ExtendedParm1Field),'') <> '' AND 
                  SUBSTRING(@c_ExtendedParm1Field, 1, CHARINDEX('.', @c_ExtendedParm1Field) - 1) = 'loc' 
               BEGIN
                  SET @c_SQLOther = @c_SQLOther + ' ' 
                                  + ISNULL(RTrim(@c_ExtendedParm1SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm1SQL2), '') 
                                  + ' '
               END

               IF ISNULL(RTRIM(@c_ExtendedParm2Field),'') <> '' AND 
                  SUBSTRING(@c_ExtendedParm2Field, 1, CHARINDEX('.', @c_ExtendedParm2Field) - 1) = 'loc' 
               BEGIN
                  SET @c_SQLOther = @c_SQLOther + ' ' 
                                  + ISNULL(RTrim(@c_ExtendedParm2SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm2SQL2), '')
                                  + ' ' 
               END

               IF ISNULL(RTRIM(@c_ExtendedParm3Field),'') <> '' AND 
                  SUBSTRING(@c_ExtendedParm3Field, 1, CHARINDEX('.', @c_ExtendedParm3Field) - 1) = 'loc' 
               BEGIN
                  SET @c_SQLOther = @c_SQLOther + ' ' 
                                  + ISNULL(RTrim(@c_ExtendedParm3SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm3SQL2), '') 
                                  + ' ' 
               END
               --(Wan02) - END
            END
            ELSE
            BEGIN
               SELECT @c_SQL = @c_SQL + ' '
                             + 'JOIN STOCKTAKEPARM2 PARM2_LOC WITH (NOLOCK) '
                             + ' ON RTRIM(LTRIM(PARM2_LOC.Value)) = LOTxLOCxID.Loc '
                             + 'AND UPPER(PARM2_LOC.Tablename) = ''Loc'' '
                             + 'AND PARM2_LOC.Stocktakekey = ''' + ISNULL(RTRIM(@c_StockTakeKey), '') + ''''
            END
         END

         --(Wan01) - START
         IF ISNULL(RTRIM(@c_ExtendedParm1Field),'') <> '' AND 
            SUBSTRING(@c_ExtendedParm1Field, 1, CHARINDEX('.', @c_ExtendedParm1Field) - 1) = 'lotattribute' 
         BEGIN
            SET @c_sqlOther = @c_sqlOther + ' ' 
                              + ISNULL(RTrim(@c_ExtendedParm1SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm1SQL2), '') 
                              + ' '
         END

         IF ISNULL(RTRIM(@c_ExtendedParm2Field),'') <> '' AND 
            SUBSTRING(@c_ExtendedParm2Field, 1, CHARINDEX('.', @c_ExtendedParm2Field) - 1) = 'lotattribute' 
         BEGIN
            SET @c_sqlOther = @c_sqlOther + ' ' 
                              + ISNULL(RTrim(@c_ExtendedParm2SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm2SQL2), '')
                              + ' ' 
         END

         IF ISNULL(RTRIM(@c_ExtendedParm3Field),'') <> '' AND 
            SUBSTRING(@c_ExtendedParm3Field, 1, CHARINDEX('.', @c_ExtendedParm3Field) - 1) = 'lotattribute' 
         BEGIN
            SET @c_sqlOther = @c_sqlOther + ' ' 
                              + ISNULL(RTrim(@c_ExtendedParm3SQL), '') + ' ' + ISNULL(RTrim(@c_ExtendedParm3SQL2), '') 
                              + ' ' 
         END
         --(Wan01) - END 
         */
         --(Wan04) - END
         SELECT @c_SQLWhere = ' '
                            --+ CASE WHEN @c_ExcludeQtyPicked = 'Y' THEN 'WHERE LOTxLOCxID.Qty-LOTxLOCxID.QtyPicked > 0 ' ELSE 'WHERE LOTxLOCxID.Qty > 0 ' END
                            --(Wan03) - START
                            +  CASE WHEN @c_ExcludeQtyAllocated = 'Y' AND @c_ExcludeQtyPicked = 'Y' THEN 'WHERE LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated-LOTxLOCxID.Qtypicked > 0 '
                                    WHEN @c_ExcludeQtyAllocated = 'Y' THEN 'WHERE LOTxLOCxID.Qty-LOTxLOCxID.Qtyallocated > 0 ' 
                                    WHEN @c_ExcludeQtyPicked    = 'Y' THEN 'WHERE LOTxLOCxID.Qty-LOTxLOCxID.Qtypicked > 0 '
                                    ELSE 'WHERE LOTxLOCxID.Qty > 0 ' END
                            --(Wan03) - END 
                            + 'AND Loc.facility = "' + ISNULL(RTRIM(@c_facility), '') + '" '
                            + ISNULL(RTRIM(@c_StorerSQL), '') + ' ' + ISNULL(RTRIM(@c_StorerSQL2), '') + ' '
                            + RTRIM(@c_StrategySQL) + ' '                                             --(Wan03)
         IF @c_ByPalletLevel = 'Y' --NJOW03
         BEGIN                                                        
            SELECT @c_SQLWhere = @c_SQLWhere 
                   + ' AND EXISTS (SELECT 1 FROM CCDETAIL CC (NOLOCK) WHERE CC.Storerkey = LOTXLOCXID.Storerkey AND CC.Id = LOTXLOCXID.ID '  
                   + '             AND ISNULL(CC.ID,'''') <> '''' AND CC.CCKey = ''' + RTRIM(ISNULL(@c_StockTakeKey,'')) + ''') '  
         END

         SELECT @c_sql = @c_sql + ' ' + @c_sqlWhere + ' ' + @c_sqlOther
      END

      INSERT INTO #Withdraw (StorerKey, Sku, Lot, Id, Loc, Qty, 
                              Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
                              Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                              Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
      EXEC ( @c_SQL )

      IF @b_debug = 1
      BEGIN
         SELECT @c_SQL
         SELECT * FROM #Withdraw
      END
      -- End : SOS66279
   END

   -- Generate Deposit Transaction From CCDETAIL Table
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE @c_Checking NVARCHAR(255)

      SELECT @c_Checking = ''

      IF @c_CountNo = '1'
      BEGIN
         SELECT @c_Checking = 'AND CCDETAIL.Qty > 0 AND CCDETAIL.FinalizeFlag = "Y" '
      END
      IF @c_CountNo = '2'
      BEGIN
         SELECT @c_Checking = 'AND CCDETAIL.QTY_Cnt2 > 0 AND CCDETAIL.FinalizeFlag_Cnt2 = "Y" '
      END
      IF @c_CountNo = '3'
      BEGIN
         SELECT @c_Checking = 'AND CCDETAIL.QTY_Cnt3 > 0 AND CCDETAIL.FinalizeFlag_Cnt3 = "Y" '
      END

      IF @n_IsRDT = 1
      BEGIN
         SELECT @c_Checking = ISNULL(RTRIM(@c_Checking),'') + ' AND CCDETAIL.CCSheetNo = ''' + @c_TaskDetailKey + ''''
      END

      INSERT INTO #Deposit (StorerKey, Sku, Lot, Id, Loc, Qty, 
                              Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
                              Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                              Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
      EXEC ( 'SELECT CCDETAIL.StorerKey, CCDETAIL.Sku, '
           +  ''''' as Lot, CCDETAIL.Id, CCDETAIL.Loc, '
           -- +  'CCDETAIL.Lot as Lot, CCDETAIL.Id, CCDETAIL.Loc, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN CCDETAIL.Qty '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN CCDETAIL.qty_Cnt2 '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN CCDETAIL.qty_Cnt3 '
           +  'END As Qty, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable01,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable01_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable01_Cnt3,'''') '
           +  'END As Lottable01, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable02,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable02_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable02_Cnt3,'''') '
           +  'END As Lottable02, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable03,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable03_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable03_Cnt3,'''') '
           +  'END As Lottable03, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN CCDETAIL.Lottable04 '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN CCDETAIL.Lottable04_Cnt2 '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN CCDETAIL.Lottable04_Cnt3 '
           +  'END As Lottable04, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN CCDETAIL.Lottable05 '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN CCDETAIL.Lottable05_Cnt2 '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN CCDETAIL.Lottable05_Cnt3 '
           +  'END As Lottable05, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable06,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable06_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable06_Cnt3,'''') '
           +  'END As Lottable06, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable07,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable07_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable07_Cnt3,'''') '
           +  'END As Lottable07, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable08,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable08_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable08_Cnt3,'''') '
           +  'END As Lottable08, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable09,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable09_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable09_Cnt3,'''') '
           +  'END As Lottable09, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable10,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable10_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable10_Cnt3,'''') '
           +  'END As Lottable10, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable11,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable11_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable11_Cnt3,'''') '
           +  'END As Lottable11, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN ISNULL(CCDETAIL.Lottable12,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN ISNULL(CCDETAIL.Lottable12_Cnt2,'''') '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN ISNULL(CCDETAIL.Lottable12_Cnt3,'''') '
           +  'END As Lottable12, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN CCDETAIL.Lottable13 '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN CCDETAIL.Lottable13_Cnt2 '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN CCDETAIL.Lottable13_Cnt3 '
           +  'END As Lottable13, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN CCDETAIL.Lottable14 '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN CCDETAIL.Lottable14_Cnt2 '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN CCDETAIL.Lottable14_Cnt3 '
           +  'END As Lottable14, '
           +  'CASE WHEN ' + @c_CountNo + ' = 1 THEN CCDETAIL.Lottable15 '
           +  '     WHEN ' + @c_CountNo + ' = 2 THEN CCDETAIL.Lottable15_Cnt2 '
           +  '     WHEN ' + @c_CountNo + ' = 3 THEN CCDETAIL.Lottable15_Cnt3 '
           +  'END As Lottable15 '
           +  'FROM  CCDETAIL (NOLOCK), Sku (NOLOCK) '
           +  'WHERE CCDETAIL.CCKEY = "' + @c_StockTakeKey + '" '
           +  'AND   CCDETAIL.StorerKey = Sku.StorerKey '
           +  'AND   CCDETAIL.Sku = Sku.Sku '
           +  @c_Checking )

      IF @@ERROR <> 0
      BEGIN
         SELECT @n_continue = 3
         RETURN
      END

      IF @b_debug = 1
      BEGIN
         SELECT @c_Checking
         SELECT * FROM #Deposit
      END
   END

   -- Assign Lot# to #Deposit
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE CUR1 CURSOR READ_ONLY FAST_FORWARD FOR
      SELECT StorerKey, Sku, 
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
      FROM   #Deposit
      WHERE ISNULL(RTRIM(Lot),'') = ''
      AND    Qty > 0

      OPEN CUR1
      FETCH NEXT FROM CUR1 INTO @c_StorerKey, @c_Sku, 
                                 @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
                                 @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                 @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15

      WHILE @@fetch_status <> -1
      BEGIN
         SELECT @b_isok = 0
         EXECUTE nsp_LotLookUp
                 @c_StorerKey
               , @c_Sku
               , @c_Lottable01
               , @c_Lottable02
               , @c_Lottable03
               , @d_Lottable04
               , @d_Lottable05
               , @c_Lottable06
               , @c_Lottable07
               , @c_Lottable08
               , @c_Lottable09
               , @c_Lottable10
               , @c_Lottable11
               , @c_Lottable12
               , @d_Lottable13
               , @d_Lottable14
               , @d_Lottable15
               , @c_Lot      OUTPUT
               , @b_isok     OUTPUT
               , @n_err      OUTPUT
               , @c_errmsg   OUTPUT

         IF @b_isok = 1
         BEGIN
            /* Add To Lotattribute File */
            SELECT @b_isok = 0
            EXECUTE nsp_LotGen
                    @c_StorerKey
                  , @c_Sku
                  , @c_Lottable01
                  , @c_Lottable02
                  , @c_Lottable03
                  , @d_Lottable04
                  , @d_Lottable05
                  , @c_Lottable06
                  , @c_Lottable07
                  , @c_Lottable08
                  , @c_Lottable09
                  , @c_Lottable10
                  , @c_Lottable11
                  , @c_Lottable12
                  , @d_Lottable13
                  , @d_Lottable14
                  , @d_Lottable15
                  , @c_Lot      OUTPUT
                  , @b_isok     OUTPUT
                  , @n_err      OUTPUT
                  , @c_errmsg   OUTPUT

            IF @b_isok <> 1
            BEGIN
               SELECT @n_continue = 3
            END

            IF ISNULL(RTRIM(@c_Lot),'') <> ''
            BEGIN
                UPDATE #Deposit SET Lot = @c_Lot
                WHERE StorerKey = @c_StorerKey
                AND   Sku = @c_Sku
                AND   Lottable01 = @c_Lottable01
                AND   Lottable02 = @c_Lottable02
                AND   Lottable03 = @c_Lottable03
                AND   Lottable04 = @d_Lottable04
                AND   Lottable05 = @d_Lottable05
                AND   Lottable06 = @c_Lottable06
                AND   Lottable07 = @c_Lottable07
                AND   Lottable08 = @c_Lottable08
                AND   Lottable09 = @c_Lottable09
                AND   Lottable10 = @c_Lottable10
                AND   Lottable11 = @c_Lottable11
                AND   Lottable12 = @c_Lottable12
                AND   Lottable13 = @d_Lottable13
                AND   Lottable14 = @d_Lottable14
                AND   Lottable15 = @d_Lottable15
                --AND   ISNULL(RTRIM(@c_Lot),'') = '' --SOS264402
                AND   ISNULL(RTRIM(Lot),'') = ''      --SOS264402
            END
         END
         FETCH NEXT FROM CUR1 INTO @c_StorerKey, @c_Sku, 
                                    @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
                                    @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                    @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15

      END -- while
      CLOSE CUR1
      DEALLOCATE CUR1
   END

   -- SOS# 254455
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      INSERT INTO #Deposit2 (StorerKey, Sku, Lot, Id, Loc, Qty, 
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
      SELECT StorerKey, Sku, Lot, Id, Loc, SUM(Qty), 
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
      FROM #Deposit
      GROUP BY StorerKey, Sku, Lot, Id, Loc, 
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
   END

   --NJOW03
   IF (@n_continue = 1 OR @n_continue = 2) AND @c_ByPalletLevel = 'Y' 
   BEGIN   	
   	  SELECT D2.ID, MAX(ISNULL(LLI.Loc,'')) AS Loc
   	  INTO #TMP_IDLOC
   	  FROM #Deposit2 D2
   	  LEFT JOIN LOTXLOCXID LLI (NOLOCK) ON D2.Id = LLI.Id AND D2.Storerkey = LLI.Storerkey AND LLI.Qty > 0 AND ISNULL(LLI.ID,'') <> ''
   	  GROUP BY D2.ID
   	  
   	  UPDATE #Deposit2
   	  SET #Deposit2.Loc = CASE WHEN #TMP_IDLOC.Loc <> '' THEN #TMP_IDLOC.Loc ELSE #Deposit2.Loc END
   	  FROM #Deposit2
   	  JOIN #TMP_IDLOC ON #Deposit2.ID = #TMP_IDLOC.ID   	
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- (Deposit) Insert Lot Found in Stock Take which is not in LOTxLOCxID (System)
      INSERT INTO #Variance (StorerKey, Sku, Lot, Id, Loc, Qty, 
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
      SELECT D.StorerKey, D.Sku, D.Lot, D.Id, D.Loc, D.Qty, 
            D.Lottable01, D.Lottable02, D.Lottable03, D.Lottable04, D.Lottable05,
            D.Lottable06, D.Lottable07, D.Lottable08, D.Lottable09, D.Lottable10,
            D.Lottable11, D.Lottable12, D.Lottable13, D.Lottable14, D.Lottable15
      FROM   #Deposit2 D
      LEFT OUTER JOIN #WithDraw W ON (W.Lot = D.Lot and W.Loc = D.Loc and W.Id = D.Id)
      WHERE W.Lot IS NULL

      -- (Withdraw) INSERT Lot That not in Count But Exists in LOTxLOCxID (System)
      INSERT INTO #Variance (StorerKey, Sku, Lot, Id, Loc, Qty, 
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
      SELECT W.StorerKey, W.Sku, W.Lot, W.Id, W.Loc, (W.Qty * -1), 
            W.Lottable01, W.Lottable02, W.Lottable03, W.Lottable04, W.Lottable05,
            W.Lottable06, W.Lottable07, W.Lottable08, W.Lottable09, W.Lottable10, 
            W.Lottable11, W.Lottable12, W.Lottable13, W.Lottable14, W.Lottable15
      FROM   #WithDraw W
      LEFT OUTER JOIN #Deposit2 D ON (W.Lot = D.Lot and W.Loc = D.Loc and W.Id = D.Id)
      WHERE D.Lot IS NULL

      INSERT INTO #Variance (StorerKey, Sku, Lot, Id, Loc, Qty, 
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15)
      SELECT W.StorerKey, W.Sku, W.Lot, W.Id, W.Loc,
            CASE WHEN W.Qty > D.Qty THEN D.Qty - W.Qty -- System > Counted (Withdraw)
                  ELSE D.Qty - W.Qty -- Count > System (Deposit)
            END,
            W.Lottable01, W.Lottable02, W.Lottable03, W.Lottable04, W.Lottable05,
            W.Lottable06, W.Lottable07, W.Lottable08, W.Lottable09, W.Lottable10, 
            W.Lottable11, W.Lottable12, W.Lottable13, W.Lottable14, W.Lottable15
      FROM   #WithDraw W
      INNER JOIN #Deposit2 D ON (W.Lot = D.Lot and W.Loc = D.Loc and W.Id = D.Id)
      WHERE D.Qty <> W.Qty
   END

   IF @b_debug = 1
   BEGIN
      SELECT * FROM #Variance
   END

   IF EXISTS(SELECT 1 FROM #Variance)
   BEGIN
    SELECT V.StorerKey, V.Sku, V.Lot, V.Id, V.Loc, V.Qty, P.PackKey, P.PackUOM3, 
            V.Lottable01, V.Lottable02, V.Lottable03, V.Lottable04, V.Lottable05, -- SOS# 254455
            V.Lottable06, V.Lottable07, V.Lottable08, V.Lottable09, V.Lottable10, 
            V.Lottable11, V.Lottable12, V.Lottable13, V.Lottable14, V.Lottable15
      FROM   #Variance V
      JOIN   Sku S (NOLOCK) ON S.StorerKey = V.StorerKey AND S.Sku = V.Sku
      JOIN   PACK P (NOLOCK) ON S.PackKey = P.PackKey
      ORDER BY V.StorerKey, V.Sku

      SET @c_PrevStorerKey = ''
      DECLARE CUR2 CURSOR READ_ONLY FAST_FORWARD FOR
         SELECT V.StorerKey, V.Sku, V.Lot, V.Id, V.Loc, V.Qty, P.PackKey, P.PackUOM3, 
               V.Lottable01, V.Lottable02, V.Lottable03, V.Lottable04, V.Lottable05, -- SOS# 254455
               V.Lottable06, V.Lottable07, V.Lottable08, V.Lottable09, V.Lottable10, 
               V.Lottable11, V.Lottable12, V.Lottable13, V.Lottable14, V.Lottable15
         FROM   #Variance V
         JOIN   Sku S (NOLOCK) ON S.StorerKey = V.StorerKey AND S.Sku = V.Sku
         JOIN   PACK P (NOLOCK) ON S.PackKey = P.PackKey
         ORDER BY V.StorerKey, V.Sku

      OPEN CUR2
      FETCH NEXT FROM CUR2 INTO @c_StorerKey, @c_Sku, @c_Lot, @c_Id, @c_Loc, @n_Qty, @c_PackKey, @c_UOM, 
                              @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
                              @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                              @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF @c_PrevStorerKey <> @c_StorerKey
         BEGIN
        
            EXECUTE nspg_GetKey
                    'Adjustment'
                  , 10
                  , @c_AdjustmentKey OUTPUT
                  , @b_success       OUTPUT
                  , @n_err           OUTPUT
                  , @c_errmsg        OUTPUT

            IF NOT @b_success = 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 67101
               SELECT @c_errmsg = "NSQL" + CONVERT(Char(5), @n_err) + ": Unable to Obtain Adjustment key. (ispGenCCAdjustmentPost_MultiCnt)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
               GOTO EXIT_SP
            END
            ELSE -- insert new Adjustment header record
            BEGIN
               IF @n_IsRDT = 1
               BEGIN
                  -- Get adjustment type
                  SET @c_AdjType = 'RDTCC'
                  SELECT @c_AdjType = Short FROM CodeLKUP WITH (NOLOCK) WHERE ListName = 'RDTCCADJ' AND Code = 'ADJTYPE' AND StorerKey = @c_StorerKey

                  -- Get reason code
                  SET @c_AdjReasonCode = 'CC'
                  SELECT @c_AdjReasonCode = Short FROM CodeLKUP WITH (NOLOCK) WHERE ListName = 'RDTCCADJ' AND Code = 'REASONCODE' AND StorerKey = @c_StorerKey

                  INSERT INTO @tAdjustment (AdjustmentKey) VALUES (@c_AdjustmentKey)

                  INSERT INTO Adjustment (AdjustmentKey, AdjustmentType, StorerKey, Facility, CustomerRefNo, Remarks, UserDefine01, UserDefine02, UserDefine03)
                  VALUES (@c_AdjustmentKey, @c_AdjType, @c_StorerKey, @c_Facility, @c_StockTakeKey, '', @c_Loc, @c_Sku, @c_TaskDetailKey)

                  SET @n_err = @@error
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 67102
                     SELECT @c_errmsg = "NSQL" + CONVERT(Char(5), @n_err) + ": Failed to Create Adjustment Header. (ispGenCCAdjustmentPost_MultiCnt)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
                     GOTO EXIT_SP
                  END
               END
               ELSE
               BEGIN
                  INSERT INTO Adjustment (AdjustmentKey, AdjustmentType, StorerKey, Facility, CustomerRefNo, Remarks)
                  VALUES (@c_AdjustmentKey, @c_AdjType, @c_StorerKey, @c_Facility, @c_StockTakeKey, '')

                  SET @n_err = @@error
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 67103
                     SELECT @c_errmsg = "NSQL" + CONVERT(Char(5), @n_err) + ": Failed to Create Adjustment Header. (ispGenCCAdjustmentPost_MultiCnt)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
                     GOTO EXIT_SP
                  END
               END
            END
            SELECT @c_PrevStorerKey = @c_StorerKey
         END

         SELECT @c_AdjDetailLine = RIGHT('0000' + RTRIM(CAST((ISNULL(MAX(AdjustmentLineNumber),0) + 1) AS NVARCHAR(5))),5)
         FROM  AdjustmentDetail WITH (NOLOCK)
         WHERE AdjustmentKey = @c_AdjustmentKey

         INSERT INTO AdjustmentDetail (AdjustmentKey, AdjustmentLineNumber, StorerKey, Sku, Loc, Lot, Id, ReasonCode, UOM, PackKey, Qty, 
                                       Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
                                       Lottable06, Lottable07, Lottable08, Lottable09, Lottable10, 
                                       Lottable11, Lottable12, Lottable13, Lottable14, Lottable15 ) -- SOS# 254455
         VALUES ( @c_AdjustmentKey, @c_AdjDetailLine, @c_StorerKey, @c_Sku, @c_Loc, @c_Lot, @c_Id, @c_AdjReasonCode, @c_UOM, @c_PackKey, @n_Qty, 
                                       @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
                                       @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                       @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15)

         SET @n_err = @@error
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err = 67104
            SELECT @c_errmsg = "NSQL" + CONVERT(Char(5), @n_err) + ": Failed to Create Adjustment Detail. (ispGenCCAdjustmentPost_MultiCnt)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
            BREAK
         END

         --NJOW03
         IF @c_IDOnHold = 'Y' AND ISNULL(@c_Id,'') <> ''
         BEGIN
            SET @c_Remark = 'Stock Take# '+ RTRIM(@c_StockTakeKey) +'. Posting Adj Hold By Variance Pallet'
            EXECUTE nspInventoryHold 
                             ''--@c_lot
                           , ''--@c_Loc
                           , @c_Id
                           , 'CCIDHOLD'--@c_Status
                           , '1'--@c_Hold
                           , @b_Success OUTPUT
                           , @n_Err OUTPUT
                           , @c_Errmsg OUTPUT
                           , @c_Remark   
            
            IF @n_Err <> 0
            BEGIN
            	 SELECT @n_Continue = 3 
	             SELECT @c_Errmsg='NSQL'+CONVERT(varchar(5),@n_Err)+': Hold By Palled ID Failed. (ispGenCCAdjustmentPost_MultiCnt). ' + RTRIM(LTRIM(ISNULL(@c_Errmsg,'')))
            END 
            ELSE
            BEGIN
            	  UPDATE INVENTORYHOLD WITH (ROWLOCK)
            	  SET Storerkey = @c_Storerkey,
            	      TrafficCop = NULL
            	  WHERE Id = @c_ID
            	  AND Status = 'CCIDHOLD'
            END         	
         END
         
         FETCH NEXT FROM CUR2 INTO @c_StorerKey, @c_Sku, @c_Lot, @c_Id, @c_Loc, @n_Qty, @c_PackKey, @c_UOM, 
                                 @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
                                 @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                                 @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
      END -- while cursor
      CLOSE CUR2
      DEALLOCATE CUR2
   END

   -- SOS44193 Update status in CCDETAIL to POSTED ('9')
   IF EXISTS (SELECT 1 FROM ADJUSTMENT WITH (NOLOCK) WHERE CustomerRefNo = @c_StockTakeKey)
      OR NOT EXISTS (SELECT 1 FROM #Variance)                                                   --(Wan01)
   BEGIN
      IF @n_IsRDT = 1
      BEGIN
         UPDATE CCDETAIL
         SET    Status = '9'
         WHERE  CCDETAIL.CCKEY = @c_StockTakeKey AND CCSheetNo = @c_TaskDetailKey
      END
      ELSE
      BEGIN
         UPDATE CCDETAIL
         SET    Status = '9'
         WHERE  CCDETAIL.CCKEY = @c_StockTakeKey
      END
   END

   IF @n_IsRDT = 1 AND EXISTS(SELECT 1 FROM @tAdjustment)
   BEGIN
      --BEGIN TRAN
      WHILE 1=1
      BEGIN
         SELECT TOP 1 @c_AdjustmentKey = AdjustmentKey FROM @tAdjustment
         IF @c_AdjustmentKey <> ''
         BEGIN
            SET @n_err = 0
            EXEC isp_FinalizeADJ
                  @c_AdjustmentKey,
                  @b_Success  OUTPUT,
                  @n_err      OUTPUT,
                  @c_errmsg   OUTPUT

            IF @n_err <> 0
            BEGIN
               --ROLLBACK TRAN
               GOTO EXIT_SP
            END

            --SOS254825 Start
            IF NOT EXISTS (SELECT 1 FROM ADJUSTMENTDETAIL (NOLOCK) WHERE Adjustmentkey = @c_AdjustmentKey AND FinalizedFlag = 'N')
            BEGIN
               UPDATE Adjustment WITH (ROWLOCK)
               SET FinalizedFlag = 'Y'
               WHERE AdjustmentKey = @c_AdjustmentKey
                              
               SET @n_err = @@error
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 67105
                  SELECT @c_errmsg = "NSQL" + CONVERT(Char(5), @n_err) + ": Update Failed On Adjustment Table. (ispGenCCAdjustmentPost_MultiCnt)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
                  GOTO EXIT_SP
               END
            END
            --SOS254825 End
            
            DELETE @tAdjustment WHERE AdjustmentKey = @c_AdjustmentKey

            SET @c_AdjustmentKey = ''
         END
         ELSE
         BEGIN
            BREAK
         END
      END
      --COMMIT TRAN
   END

EXIT_SP:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON ispGenCCAdjustmentPost_MultiCnt TO NSQL
GO
