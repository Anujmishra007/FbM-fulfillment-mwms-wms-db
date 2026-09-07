SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*********************************************************************************/
/* Stored Procedure: ispGenCCAdjustmentPost_SP01                                 */
/* Creation Date  : 28-Aug-2026                                                  */
/* Copyright      : Maersk                                                       */
/* Written by     : Michael Lam                                                  */
/*                                                                               */
/* Purpose: Custom SP for generating Adjustment with UCC & SerialNo              */
/*                                                                               */
/* Called from: lsp_GenCCAdjustment_Wrapper -> ispGenCCAdjustmentPost_MultiCnt   */
/*                                                                               */
/* PVCS Version: 1.0                                                             */
/*                                                                               */
/* Version: 7.0                                                                  */
/*                                                                               */
/* Data Modifications:                                                           */
/*                                                                               */
/* Updates:                                                                      */
/* Date         Author    Ver.  Purposes                                         */
/* 28-Aug-2026  Michael   1.0   FCR-15134 - Gen CC Adj /w UCC, SerialNo, Channel */
/*********************************************************************************/
CREATE OR ALTER PROC [dbo].[ispGenCCAdjustmentPost_SP01] (
     @c_StockTakeKey  NVARCHAR(10)
   , @c_CountNo       NVARCHAR(1)
   , @b_success       INT          OUTPUT
   , @c_TaskDetailKey NVARCHAR(10) = ''
   , @c_ByPalletLevel NVARCHAR(10) = 'N'
   , @c_IDOnHold      NVARCHAR(10) = 'N'
)
AS
BEGIN
/*
   CODELKUP
   ListName  = CCADJCFG
   Code2     = ispGenCCAdjustmentPost_SP01
   Storerkey = <Storerkey>

   Code               Description                                                           Short  Long   Notes
   -----------------  --------------------------------------------------------------------  -----  -----  -----
   CC_Chanel_Exp      CC Channel Exp                                                        Y/N           SQL
   ChannelSearchSeq   Channel Search Sequnce (XXX,YYY,...)                                  Y/N    Value
   DefaultChannel     Default Channel                                                       Y/N    Value
   NotUpdLocForSameID Not Update Loc for Same ID                                            Y/N    1/0
*/
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_Facility               NVARCHAR(5)
         , @c_StorerParm             NVARCHAR(60)
         , @c_AisleParm              NVARCHAR(60)
         , @c_LevelParm              NVARCHAR(60)
         , @c_ZoneParm               NVARCHAR(60)
         , @c_HostWHCodeParm         NVARCHAR(60)
         , @c_SKUParm                NVARCHAR(125)
         , @c_WithQuantity           NVARCHAR(1)
         , @c_ClearHistory           NVARCHAR(1)
         , @c_EmptyLocation          NVARCHAR(1)
         , @n_LinesPerPage           INT
         , @c_password               NVARCHAR(10)
         , @c_protect                NVARCHAR(1)
         , @c_AgencyParm             NVARCHAR(150)
         , @c_ABCParm                NVARCHAR(60)
         , @c_AdjReasonCode          NVARCHAR(10)
         , @c_AdjType                NVARCHAR(3)
         , @c_SkuGroupParm           NVARCHAR(125)
         , @c_ExcludeQtyPicked       NVARCHAR(1)
         , @c_CountType              NVARCHAR(10)  = ''
         , @c_Extendedparm1Field     NVARCHAR(50)  = ''
         , @c_Extendedparm1          NVARCHAR(125) = ''
         , @c_Extendedparm2Field     NVARCHAR(50)  = ''
         , @c_Extendedparm2          NVARCHAR(125) = ''
         , @c_Extendedparm3Field     NVARCHAR(50)  = ''
         , @c_Extendedparm3          NVARCHAR(125) = ''
         , @c_ExcludeQtyAllocated    NVARCHAR(1)
         , @c_ParmDataType           NVARCHAR(20)  = ''
         , @n_FinalizeStage          INT           = 0

   -- declare a select condition variable for parameters
   DECLARE @c_AisleSQL               NVARCHAR(MAX)
         , @c_AisleSQL2              NVARCHAR(MAX)
         , @c_LevelSQL               NVARCHAR(MAX)
         , @c_LevelSQL2              NVARCHAR(MAX)
         , @c_ZoneSQL                NVARCHAR(MAX)
         , @c_ZoneSQL2               NVARCHAR(MAX)
         , @c_HostWHCodeSQL          NVARCHAR(MAX)
         , @c_HostWHCodeSQL2         NVARCHAR(MAX)
         , @c_SKUSQL                 NVARCHAR(MAX)
         , @c_SKUSQL2                NVARCHAR(MAX)
         , @c_StorerSQL              NVARCHAR(MAX)
         , @c_StorerSQL2             NVARCHAR(MAX)
         , @c_AgencySQL              NVARCHAR(MAX)
         , @c_AgencySQL2             NVARCHAR(MAX)
         , @c_ABCSQL                 NVARCHAR(MAX)
         , @c_ABCSQL2                NVARCHAR(MAX)
         , @c_SkuGroupSQL            NVARCHAR(MAX)
         , @c_SkuGroupSQL2           NVARCHAR(MAX)
         , @c_Extendedparm1SQL       NVARCHAR(MAX) = ''
         , @c_Extendedparm1SQL2      NVARCHAR(MAX) = ''
         , @c_Extendedparm2SQL       NVARCHAR(MAX) = ''
         , @c_Extendedparm2SQL2      NVARCHAR(MAX) = ''
         , @c_Extendedparm3SQL       NVARCHAR(MAX) = ''
         , @c_Extendedparm3SQL2      NVARCHAR(MAX) = ''
         , @c_StrategySQL            NVARCHAR(MAX)
         , @c_StrategySkuSQL         NVARCHAR(MAX)
         , @c_StrategyLocSQL         NVARCHAR(MAX)
         , @c_LocSQL                 NVARCHAR(MAX)
         , @c_SkuConditionSQL        NVARCHAR(MAX)
         , @c_LocConditionSQL        NVARCHAR(MAX)
         , @c_ExtendedConditionSQL1  NVARCHAR(MAX)
         , @c_ExtendedConditionSQL2  NVARCHAR(MAX)
         , @c_ExtendedConditionSQL3  NVARCHAR(MAX)
         , @c_StocktakeParm2SQL      NVARCHAR(MAX)
         , @c_StocktakeParm2OtherSQL NVARCHAR(MAX)
         , @c_ChannelAttrSQL         NVARCHAR(MAX) = ''
         , @c_ChannelAttrParm        NVARCHAR(MAX) = ''
         , @c_SQL                    NVARCHAR(MAX)

   DECLARE @n_continue               INT
         , @b_debug                  INT
         , @c_SP_Name                NVARCHAR(128) = 'ispGenCCAdjustmentPost_SP01'
         , @c_ListName_CCADJCFG      NVARCHAR(10)  = 'CCADJCFG'
         , @c_Remark                 NVARCHAR(260)
         , @c_CCAdjNotCompareCurrInv NVARCHAR(30)  = ''
         , @c_SerialNoUpdateLotLocID NVARCHAR(30)  = ''
         , @c_GenCCdetailbyExcludePKDStatus3 NVARCHAR(30) = ''
         , @c_ChannelInventoryMgmt   NVARCHAR(30)  = ''
         , @c_CCMoveAdjQtyToLoc      NVARCHAR(10)  = ''
         , @c_Hostwhcode_UDF01       NVARCHAR(10)  = ''
         , @n_MoveQty                INT
         , @n_SysQty                 INT           = 0
         , @C_CCSheetNo              NVARCHAR(10)  = ''
         , @c_Storerkey              NVARCHAR(15)
         , @c_PrevStorerKey          NVARCHAR(15)
         , @c_Lot                    NVARCHAR(10)
         , @c_Id                     NVARCHAR(18)
         , @c_Loc                    NVARCHAR(10)  = ''
         , @c_Sku                    NVARCHAR(20)  = ''
         , @c_Lottable01             NVARCHAR(18)
         , @c_Lottable02             NVARCHAR(18)
         , @c_Lottable03             NVARCHAR(18)
         , @d_Lottable04             DATETIME
         , @d_Lottable05             DATETIME
         , @c_Lottable06             NVARCHAR(30)
         , @c_Lottable07             NVARCHAR(30)
         , @c_Lottable08             NVARCHAR(30)
         , @c_Lottable09             NVARCHAR(30)
         , @c_Lottable10             NVARCHAR(30)
         , @c_Lottable11             NVARCHAR(30)
         , @c_Lottable12             NVARCHAR(30)
         , @d_Lottable13             DATETIME
         , @d_Lottable14             DATETIME
         , @d_Lottable15             DATETIME
         , @c_AdjustmentKey          NVARCHAR(10)
         , @n_Qty                    INT
         , @c_UOM                    NVARCHAR(10)
         , @c_PackKey                NVARCHAR(10)
         , @n_Adjline                INT           = 0
         , @n_CountSerialKey         BIGINT        = 0
         , @c_CCDetailkey            NVARCHAR(10)  = ''
         , @c_UCCNo                  NVARCHAR(20)
         , @c_SerialNo               NVARCHAR(50)
         , @c_Channel                NVARCHAR(20)
         , @n_Channel_ID             BIGINT
         , @n_ChannelQty             INT
         , @n_VarQty                 INT
         , @n_VarAbsQty              INT
         , @c_C_AttributeLbl01       NVARCHAR(30) = ''
         , @c_C_AttributeLbl02       NVARCHAR(30) = ''
         , @c_C_AttributeLbl03       NVARCHAR(30) = ''
         , @c_C_AttributeLbl04       NVARCHAR(30) = ''
         , @c_C_AttributeLbl05       NVARCHAR(30) = ''
         , @c_C_Attribute01          NVARCHAR(30)
         , @c_C_Attribute02          NVARCHAR(30)
         , @c_C_Attribute03          NVARCHAR(30)
         , @c_C_Attribute04          NVARCHAR(30)
         , @c_C_Attribute05          NVARCHAR(30)
         , @c_CC_Chanel_Exp          NVARCHAR(MAX)
         , @c_ChannelSearchSeq       NVARCHAR(250)
         , @c_DefaultChannel         NVARCHAR(20)
         , @c_NotUpdLocForSameID     NVARCHAR(10)
         , @n_RowID                  INT

   DECLARE @b_isok                   INT
         , @n_err                    INT
         , @c_errmsg                 NVARCHAR(215)

   DECLARE @tAdjustment TABLE (AdjustmentKey NVARCHAR(10) PRIMARY KEY)

   DECLARE @nFunc                    INT
         , @nRDTNotAutoFinalizeAdj   INT = 0
         , @cStorerKey               NVARCHAR(15)  = ''

   SET @b_success = 1   -- 1=Success
   SELECT @n_continue = 1, @b_debug = 0

   DECLARE @n_IsRDT INT
   EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

   IF @n_IsRDT = 1
   BEGIN
      SELECT @nFunc = Func
           , @cStorerKey = StorerKey
        FROM RDT.RDTMOBREC WITH (NOLOCK)
       WHERE UserName = SUSER_SNAME()

      -- Set stock take parameters
      SELECT @c_StorerParm = @cStorerKey
           , @c_AisleParm = ''
           , @c_LevelParm = ''
           , @c_ZoneParm = ''
           , @c_HostWHCodeParm = ''
           , @c_SKUParm = ''
           , @c_AgencyParm = ''
           , @c_ABCParm = ''
           , @c_SkuGroupParm = ''
           , @c_ExcludeQtyPicked = 'Y'

      SET @c_ExcludeQtyAllocated = 'N'
      -- Get task info
      SELECT @c_Loc = FromLOC
           , @c_Sku = Sku
        FROM dbo.TaskDetail WITH (NOLOCK)
       WHERE TaskDetailKey = @c_TaskDetailKey

      -- Get facility
      SELECT @c_Facility = Facility
        FROM dbo.LOC WITH (NOLOCK)
       WHERE Loc = @c_Loc

      IF ISNULL(RTRIM(@c_Loc),'') <> ''
         SET @c_LocSQL = ' AND (LOTxLOCxID.Loc = N''' + ISNULL(REPLACE(RTRIM(@c_Loc),'''',''''''),'') + ''' )'

      IF ISNULL(RTRIM(@c_Sku),'') <> ''
         SET @c_SkuSQL = ' AND (LOTxLOCxID.Sku = N''' + ISNULL(REPLACE(RTRIM(@c_Sku),'''',''''''),'') + ''' )'

      SET @nRDTNotAutoFinalizeAdj = rdt.rdtGetConfig(@nFunc, 'RDTNotAutoFinalizeAdj', @cStorerKey)
   END
   ELSE
   BEGIN
      SELECT @c_Facility            = Facility
           , @c_StorerParm          = StorerKey
           , @c_AisleParm           = AisleParm
           , @c_LevelParm           = LevelParm
           , @c_ZoneParm            = ZoneParm
           , @c_HostWHCodeParm      = HostWHCodeParm
           , @c_SKUParm             = SKUParm
           , @c_WithQuantity        = WithQuantity
           , @c_ClearHistory        = ClearHistory
           , @c_EmptyLocation       = EmptyLocation
           , @n_LinesPerPage        = LinesPerPage
           , @c_password            = password
           , @c_protect             = protect
           , @c_AgencyParm          = AgencyParm
           , @c_ABCParm             = ABCParm
           , @c_AdjReasonCode       = AdjReasonCode
           , @c_AdjType             = AdjType
           , @c_SkuGroupParm        = SkuGroupParm
           , @c_ExcludeQtyPicked    = ExcludeQtyPicked
           , @c_CountType           = CountType
           , @c_ExtendedParm1Field  = ExtendedParm1Field
           , @c_ExtendedParm1       = ExtendedParm1
           , @c_ExtendedParm2Field  = ExtendedParm2Field
           , @c_ExtendedParm2       = ExtendedParm2
           , @c_ExtendedParm3Field  = ExtendedParm3Field
           , @c_ExtendedParm3       = ExtendedParm3
           , @c_ExcludeQtyAllocated = ExcludeQtyAllocated
           , @n_FinalizeStage       = FinalizeStage
        FROM dbo.StockTakeSheetParameters WITH (NOLOCK)
       WHERE StockTakeKey = @c_StockTakeKey

      IF @c_StorerParm IS NULL
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'Bad StorerKey'
         GOTO EXIT_SP
      END

      IF @c_CountNo NOT IN ('1','2','3')
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'Bad Count Number'
         GOTO EXIT_SP
      END

      IF ISNULL(TRY_CONVERT(INT,@c_CountNo),0) <> @n_FinalizeStage
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'Count Number (' + ISNULL(@c_CountNo,'') + ') not match with FinalizeStage (' + ISNULL(CONVERT(NVARCHAR(10),@n_FinalizeStage),'') +')'
         GOTO EXIT_SP
      END

      EXEC ispParseParameters @c_AisleParm     , 'string', 'Loc.LOCAISLE'        , @c_AisleSQL      OUTPUT, @c_AisleSQL2      OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_LevelParm     , 'number', 'Loc.LOCLEVEL'        , @c_LevelSQL      OUTPUT, @c_LevelSQL2      OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_ZoneParm      , 'string', 'Loc.PutawayZone'     , @c_ZoneSQL       OUTPUT, @c_ZoneSQL2       OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_HostWHCodeParm, 'string', 'Loc.HostWHCode'      , @c_HostWHCodeSQL OUTPUT, @c_HostWHCodeSQL2 OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_SKUParm       , 'string', 'LOTxLOCxID.Sku'      , @c_SKUSQL        OUTPUT, @c_SKUSQL2        OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_StorerParm    , 'string', 'LOTxLOCxID.StorerKey', @c_StorerSQL     OUTPUT, @c_StorerSQL2     OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_AgencyParm    , 'string', 'Sku.SUSR3'           , @c_AgencySQL     OUTPUT, @c_AgencySQL2     OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_ABCParm       , 'string', 'Sku.ABC'             , @c_ABCSQL        OUTPUT, @c_ABCSQL2        OUTPUT, @b_success OUTPUT
      EXEC ispParseParameters @c_SkuGroupParm  , 'string', 'Sku.SKUGROUP'        , @c_SkuGroupSQL   OUTPUT, @c_SkuGroupSQL2   OUTPUT, @b_success OUTPUT

      EXEC isp_GetDataType @c_TableName = '', @c_FieldName = @c_ExtendedParm1Field, @c_DB_DataType = '', @c_PB_DataType = @c_ParmDataType OUTPUT
      IF @c_ParmDataType <> ''
         EXEC ispParseParameters @c_ExtendedParm1, @c_ParmDataType, @c_ExtendedParm1Field, @c_ExtendedParm1SQL OUTPUT, @c_ExtendedParm1SQL2 OUTPUT, @b_success OUTPUT

      EXEC isp_GetDataType @c_TableName = '', @c_FieldName = @c_ExtendedParm2Field, @c_DB_DataType = '', @c_PB_DataType = @c_ParmDataType OUTPUT
      IF @c_ParmDataType <> ''
         EXEC ispParseParameters @c_ExtendedParm2, @c_ParmDataType, @c_ExtendedParm2Field, @c_ExtendedParm2SQL OUTPUT, @c_ExtendedParm2SQL2 OUTPUT, @b_success OUTPUT

      EXEC isp_GetDataType @c_TableName = '', @c_FieldName = @c_ExtendedParm3Field, @c_DB_DataType = '', @c_PB_DataType = @c_ParmDataType OUTPUT
      IF @c_ParmDataType <> ''
         EXEC ispParseParameters @c_ExtendedParm3, @c_ParmDataType, @c_ExtendedParm3Field, @c_ExtendedParm3SQL OUTPUT, @c_ExtendedParm3SQL2 OUTPUT, @b_success OUTPUT
   END

   EXEC ispCCStrategy
        @c_StockTakeKey   = @c_StockTakeKey
      , @c_StrategySQL    = @c_StrategySQL     OUTPUT
      , @c_StrategySkuSQL = @c_StrategySkuSQL  OUTPUT
      , @c_StrategyLocSQL = @c_StrategyLocSQL  OUTPUT
      , @b_Success        = @b_Success         OUTPUT
      , @n_err            = @n_err             OUTPUT
      , @c_errmsg         = @c_errmsg          OUTPUT

   IF @b_Success <> 1
   BEGIN
      SELECT @n_continue = 3, @c_errmsg = 'Error Executing ispCCStrategy'
      GOTO EXIT_SP
   END

   SET @c_SkuConditionSQL = ISNULL(RTRIM(@c_SKUSQL), '')      + ' ' + ISNULL(RTRIM(@c_SKUSQL2), '') + ' '
                          + ISNULL(RTRIM(@c_AgencySQL), '')   + ' ' + ISNULL(RTRIM(@c_AgencySQL2), '') + ' '
                          + ISNULL(RTRIM(@c_ABCSQL), '')      + ' ' + ISNULL(RTRIM(@c_ABCSQL2), '') + ' '
                          + ISNULL(RTRIM(@c_SkuGroupSQL), '') + ' ' + ISNULL(RTRIM(@c_SkuGroupSQL2), '') + ' '

   SET @c_LocConditionSQL = ISNULL(RTRIM(@c_ZoneSQL), '')       + ' ' + ISNULL(RTRIM(@c_ZoneSQL2), '') + ' '
                          + ISNULL(RTRIM(@c_AisleSQL), '')      + ' ' + ISNULL(RTRIM(@c_AisleSQL2), '') + ' '
                          + ISNULL(RTRIM(@c_LevelSQL), '')      + ' ' + ISNULL(RTRIM(@c_LevelSQL2), '') + ' '
                          + ISNULL(RTRIM(@c_HostWHCodeSQL), '') + ' ' + ISNULL(RTRIM(@c_HostWHCodeSQL2), '') + ' '

   SET @c_ExtendedConditionSQL1 = ISNULL(RTRIM(@c_ExtendedParm1SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm1SQL2), '')
   SET @c_ExtendedConditionSQL2 = ISNULL(RTRIM(@c_ExtendedParm2SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm2SQL2), '')
   SET @c_ExtendedConditionSQL3 = ISNULL(RTRIM(@c_ExtendedParm3SQL), '') + ' ' + ISNULL(RTRIM(@c_ExtendedParm3SQL2), '')

   EXEC ispGetStocktakeParm2
        @c_StockTakeKey           = @c_StockTakeKey
      , @c_ByPalletLevel          = @c_ByPalletLevel
      , @c_SkuConditionSQL        = @c_SkuConditionSQL
      , @c_LocConditionSQL        = @c_LocConditionSQL
      , @c_ExtendedConditionSQL1  = @c_ExtendedConditionSQL1
      , @c_ExtendedConditionSQL2  = @c_ExtendedConditionSQL2
      , @c_ExtendedConditionSQL3  = @c_ExtendedConditionSQL3
      , @c_StocktakeParm2SQL      = @c_StocktakeParm2SQL      OUTPUT
      , @c_StocktakeParm2OtherSQL = @c_StocktakeParm2OtherSQL OUTPUT

   -- Generate WithDraw Stock from Lotxlocxid table
   IF @b_debug = 1
   BEGIN
      SELECT @c_Facility
           , @c_StorerSQL + ' ' + @c_StorerSQL2
           , @c_SkuConditionSQL
           , @c_LocConditionSQL
           , @c_ExtendedConditionSQL1 + ' ' + @c_ExtendedConditionSQL2 + ' ' + @c_ExtendedConditionSQL3
      SELECT @c_StocktakeParm2SQL + ' ' + @c_StocktakeParm2OtherSQL
   END

   -- Prepare Temp Tables
   IF OBJECT_ID('tempdb..#Withdraw') IS NOT NULL
      DROP TABLE #Withdraw
   IF OBJECT_ID('tempdb..#Deposit') IS NOT NULL
      DROP TABLE #Deposit
   IF OBJECT_ID('tempdb..#Variance') IS NOT NULL
      DROP TABLE #Variance
   IF OBJECT_ID('tempdb..#TEMP_CHANNELINV') IS NOT NULL
      DROP TABLE #TEMP_CHANNELINV
   IF OBJECT_ID('tempdb..#TEMP_CHANNELSEARCHLIST') IS NOT NULL
      DROP TABLE #TEMP_CHANNELSEARCHLIST

   CREATE TABLE #Withdraw  (
        [RowID]        INT IDENTITY(1,1) PRIMARY KEY
      , StorerKey      NVARCHAR(15) NULL
      , Sku            NVARCHAR(20) NOT NULL
      , Lot            NVARCHAR(10) NULL
      , Id             NVARCHAR(18) NULL
      , Loc            NVARCHAR(10) NOT NULL
      , Qty            INT          NOT NULL
      , Lottable01     NVARCHAR(18) NULL
      , Lottable02     NVARCHAR(18) NULL
      , Lottable03     NVARCHAR(18) NULL
      , Lottable04     DATETIME     NULL
      , Lottable05     DATETIME     NULL
      , Lottable06     NVARCHAR(30) NULL
      , Lottable07     NVARCHAR(30) NULL
      , Lottable08     NVARCHAR(30) NULL
      , Lottable09     NVARCHAR(30) NULL
      , Lottable10     NVARCHAR(30) NULL
      , Lottable11     NVARCHAR(30) NULL
      , Lottable12     NVARCHAR(30) NULL
      , Lottable13     DATETIME     NULL
      , Lottable14     DATETIME     NULL
      , Lottable15     DATETIME     NULL
      , UCCNo          NVARCHAR(20) NULL
      , UCC_Qty        INT          NULL
      , SerialNo       NVARCHAR(50) NULL
      , SN_Qty         INT          NULL
   )
   CREATE TABLE #Deposit (
        [RowID]        INT IDENTITY(1,1) PRIMARY Key
      , CCDetailkey    NVARCHAR(10) NOT NULL DEFAULT('')
      , StorerKey      NVARCHAR(15) NULL
      , Sku            NVARCHAR(20) NOT NULL
      , Lot            NVARCHAR(10) NULL
      , Id             NVARCHAR(18) NULL
      , Loc            NVARCHAR(10) NOT NULL
      , Qty            INT          NOT NULL
      , Lottable01     NVARCHAR(18) NULL
      , Lottable02     NVARCHAR(18) NULL
      , Lottable03     NVARCHAR(18) NULL
      , Lottable04     DATETIME     NULL
      , Lottable05     DATETIME     NULL
      , Lottable06     NVARCHAR(30) NULL
      , Lottable07     NVARCHAR(30) NULL
      , Lottable08     NVARCHAR(30) NULL
      , Lottable09     NVARCHAR(30) NULL
      , Lottable10     NVARCHAR(30) NULL
      , Lottable11     NVARCHAR(30) NULL
      , Lottable12     NVARCHAR(30) NULL
      , Lottable13     DATETIME     NULL
      , Lottable14     DATETIME     NULL
      , Lottable15     DATETIME     NULL
      , UCCNo          NVARCHAR(20) NULL
      , UCC_Qty        INT          NULL
      , SerialNo       NVARCHAR(50) NULL
      , SN_Qty         INT          NULL
   )
   CREATE TABLE #Variance (
        [RowID]        INT IDENTITY(1,1) PRIMARY Key
      , StorerKey      NVARCHAR(15) NULL
      , Sku            NVARCHAR(20) NOT NULL
      , Lot            NVARCHAR(10) NULL
      , Id             NVARCHAR(18) NULL
      , Loc            NVARCHAR(10) NOT NULL
      , Qty            INT          NOT NULL
      , Lottable01     NVARCHAR(18) NULL
      , Lottable02     NVARCHAR(18) NULL
      , Lottable03     NVARCHAR(18) NULL
      , Lottable04     DATETIME     NULL
      , Lottable05     DATETIME     NULL
      , Lottable06     NVARCHAR(30) NULL
      , Lottable07     NVARCHAR(30) NULL
      , Lottable08     NVARCHAR(30) NULL
      , Lottable09     NVARCHAR(30) NULL
      , Lottable10     NVARCHAR(30) NULL
      , Lottable11     NVARCHAR(30) NULL
      , Lottable12     NVARCHAR(30) NULL
      , Lottable13     DATETIME     NULL
      , Lottable14     DATETIME     NULL
      , Lottable15     DATETIME     NULL
      , UCCNo          NVARCHAR(20) NULL
      , SerialNo       NVARCHAR(50) NULL
      , Channel        NVARCHAR(20) NULL DEFAULT('')
      , Channel_ID     BIGINT       NULL DEFAULT(0)
      , CCDetailkey    NVARCHAR(10) NULL DEFAULT('')
   )
   CREATE TABLE #TEMP_CHANNELINV (
        Channel_ID     BIGINT PRIMARY KEY
      , StorerKey      NVARCHAR(15) NULL
      , SKU            NVARCHAR(20) NULL
      , Facility       NVARCHAR(5)  NULL
      , Channel        NVARCHAR(20) NULL
      , C_Attribute01  NVARCHAR(30) NULL
      , C_Attribute02  NVARCHAR(30) NULL
      , C_Attribute03  NVARCHAR(30) NULL
      , C_Attribute04  NVARCHAR(30) NULL
      , C_Attribute05  NVARCHAR(30) NULL
      , Qty            INT          NULL
      , QtyAllocated   INT          NULL
      , QtyOnHold      INT          NULL
   )
   CREATE TABLE #TEMP_CHANNELSEARCHLIST (
        [RowID]        INT IDENTITY(1,1) PRIMARY Key
      , Channel        NVARCHAR(20) NULL
   )

   SELECT @c_CC_Chanel_Exp      = ISNULL(TRIM(MAX(CASE WHEN Code = 'CC_Chanel_Exp'     AND Short = 'Y' THEN Notes END)),'')
        , @c_DefaultChannel     = ISNULL(TRIM(MAX(CASE WHEN Code = 'DefaultChannel'    AND Short = 'Y' THEN Long  END)),'')
        , @c_ChannelSearchSeq   = ISNULL(TRIM(MAX(CASE WHEN Code = 'ChannelSearchSeq'  AND Short = 'Y' THEN Long  END)),'')
        , @c_NotUpdLocForSameID = ISNULL(TRIM(MAX(CASE WHEN Code = 'ChannelSearchSeq'  AND Short = 'Y' THEN Long  END)),'')
        , @b_debug = CASE WHEN @b_debug=1 THEN @b_debug ELSE ISNULL(MAX(CASE WHEN Code = 'Debug' AND Short IN ('1','Y') THEN 1 END),0) END
     FROM dbo.CODELKUP WITH(NOLOCK)
    WHERE ListName = @c_ListName_CCADJCFG
      AND Code2 = @c_SP_Name
      AND Storerkey = @c_StorerParm

   SELECT @c_CCAdjNotCompareCurrInv = Authority FROM dbo.fnc_GetRight2(@c_Facility, @c_StorerParm, '','CCAdjNotCompareCurrInv')
   SELECT @c_SerialNoUpdateLotLocID = Authority FROM dbo.fnc_GetRight2(@c_Facility, @c_StorerParm, '','SerialNoUpdateLotLocID')
   SELECT @c_GenCCdetailbyExcludePKDStatus3 = Authority FROM dbo.fnc_GetRight2(@c_Facility, @c_StorerParm, '','GenCCdetailbyExcludePKDStatus3')
   SELECT @c_ChannelInventoryMgmt = Authority FROM dbo.fnc_GetRight2(@c_Facility, @c_StorerParm, '','ChannelInventoryMgmt')

   IF ISNULL(@c_ChannelInventoryMgmt,'') = '1'
   BEGIN
      SELECT TOP 1
             @c_C_AttributeLbl01 = ISNULL(TRIM(C_AttributeLabel01),'')
           , @c_C_AttributeLbl02 = ISNULL(TRIM(C_AttributeLabel02),'')
           , @c_C_AttributeLbl03 = ISNULL(TRIM(C_AttributeLabel03),'')
           , @c_C_AttributeLbl04 = ISNULL(TRIM(C_AttributeLabel04),'')
           , @c_C_AttributeLbl05 = ISNULL(TRIM(C_AttributeLabel05),'')
        FROM dbo.ChannelAttributeConfig WITH (NOLOCK)
       WHERE StorerKey = @c_StorerParm

      IF @@ROWCOUNT <= 0
         SET @c_ChannelAttrSQL = 'SELECT @c_C_Attribute01='''', @c_C_Attribute02='''', @c_C_Attribute03='''', @c_C_Attribute04='''', @c_C_Attribute05='''''
      ELSE
      BEGIN
         SET @c_ChannelAttrSQL = N'SELECT TOP 1'
           +  ' @c_C_Attribute01 = ' + CASE WHEN @c_C_AttributeLbl01 LIKE 'Lottable[0-9][0-9]' AND @c_C_AttributeLbl01 BETWEEN 'Lottable01' AND 'Lottable15' THEN 'TRIM(LA.' + @c_C_AttributeLbl01 + ')' ELSE '''''' END
           + ', @c_C_Attribute02 = ' + CASE WHEN @c_C_AttributeLbl02 LIKE 'Lottable[0-9][0-9]' AND @c_C_AttributeLbl02 BETWEEN 'Lottable01' AND 'Lottable15' THEN 'TRIM(LA.' + @c_C_AttributeLbl02 + ')' ELSE '''''' END
           + ', @c_C_Attribute03 = ' + CASE WHEN @c_C_AttributeLbl03 LIKE 'Lottable[0-9][0-9]' AND @c_C_AttributeLbl03 BETWEEN 'Lottable01' AND 'Lottable15' THEN 'TRIM(LA.' + @c_C_AttributeLbl03 + ')' ELSE '''''' END
           + ', @c_C_Attribute04 = ' + CASE WHEN @c_C_AttributeLbl04 LIKE 'Lottable[0-9][0-9]' AND @c_C_AttributeLbl04 BETWEEN 'Lottable01' AND 'Lottable15' THEN 'TRIM(LA.' + @c_C_AttributeLbl04 + ')' ELSE '''''' END
           + ', @c_C_Attribute05 = ' + CASE WHEN @c_C_AttributeLbl05 LIKE 'Lottable[0-9][0-9]' AND @c_C_AttributeLbl05 BETWEEN 'Lottable01' AND 'Lottable15' THEN 'TRIM(LA.' + @c_C_AttributeLbl05 + ')' ELSE '''''' END
           +  ' FROM LOTATTRIBUTE AS LA WITH (NOLOCK)'
           + ' WHERE LA.Lot = @c_Lot'
      END

      SET @c_ChannelAttrParm =
          N'@c_Lot           NVARCHAR(10)'
        + ',@c_C_Attribute01 NVARCHAR(30) OUTPUT'
        + ',@c_C_Attribute02 NVARCHAR(30) OUTPUT'
        + ',@c_C_Attribute03 NVARCHAR(30) OUTPUT'
        + ',@c_C_Attribute04 NVARCHAR(30) OUTPUT'
        + ',@c_C_Attribute05 NVARCHAR(30) OUTPUT'
   END

   -- Generate Withdrwal Transaction
   INSERT INTO #Withdraw (
          StorerKey, Sku, Lot, Id, Loc, Qty
        , Lottable01, Lottable02, Lottable03, Lottable04, Lottable05
        , Lottable06, Lottable07, Lottable08, Lottable09, Lottable10
        , Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
        , UCCNo, UCC_Qty, SerialNo, SN_Qty)
   SELECT CCD.Storerkey, CCD.Sku, CCD.Lot, CCD.ID, CCD.Loc, SUM(CCD.SystemQty)
        , LA.Lottable01, LA.Lottable02, LA.Lottable03, LA.Lottable04, LA.Lottable05
        , LA.Lottable06, LA.Lottable07, LA.Lottable08, LA.Lottable09, LA.Lottable10
        , LA.Lottable11, LA.Lottable12, LA.Lottable13, LA.Lottable14, LA.Lottable15
        , ISNULL(CCD.RefNo,''), SUM(CCD.SystemQty)
        , CASE WHEN ISNULL(@c_SerialNoUpdateLotLocID,'') = '1' THEN ISNULL(SN.SerialNo,'') ELSE '' END
        , CASE WHEN ISNULL(@c_SerialNoUpdateLotLocID,'') = '1' THEN ISNULL(SUM(SN.Qty),0)  ELSE 0 END
     FROM dbo.CCDETAIL      CCD WITH (NOLOCK)
     JOIN dbo.LOTATTRIBUTE  LA  WITH (NOLOCK) ON CCD.Lot = LA.Lot
     JOIN dbo.SKU           SKU WITH (NOLOCK) ON CCD.Storerkey = SKU.Storerkey AND CCD.Sku = SKU.Sku
     JOIN dbo.LOC           LOC WITH (NOLOCK) ON CCD.Loc = LOC.Loc
     LEFT JOIN dbo.SERIALNO SN  WITH (NOLOCK) ON CCD.Storerkey = SN.Storerkey AND CCD.Sku = SN.Sku
                                             AND CCD.Lot = SN.Lot AND CCD.ID = SN.ID AND CCD.Loc=SN.Loc
                                             AND SN.Status = '1' AND SKU.SerialNoCapture IN ('1','2','3')
                                             AND (ISNULL(LOC.LoseUCC,'')<>'0' OR ISNULL(CCD.RefNo,'') = ISNULL(SN.UCCNo,''))
    WHERE CCD.CCKey = @c_StockTakeKey
      AND CCD.CCSheetNo = CASE WHEN ISNULL(@c_TaskDetailkey,'') <> '' THEN @c_TaskDetailkey ELSE CCD.CCSheetNo END
      AND CCD.SystemQty > 0
      AND (@c_CCAdjNotCompareCurrInv = '1' OR ISNULL(CCD.RefNo,'')<>'')   -- CCAdjNotCompareCurrInv or UCC CCDetail
    GROUP BY CCD.Storerkey, CCD.Sku, CCD.Lot, CCD.ID, CCD.Loc
           , LA.Lottable01, LA.Lottable02, LA.Lottable03, LA.Lottable04, LA.Lottable05
           , LA.Lottable06, LA.Lottable07, LA.Lottable08, LA.Lottable09, LA.Lottable10
           , LA.Lottable11, LA.Lottable12, LA.Lottable13, LA.Lottable14, LA.Lottable15
           , ISNULL(CCD.RefNo,'')
           , CASE WHEN ISNULL(@c_SerialNoUpdateLotLocID,'') = '1' THEN ISNULL(SN.SerialNo,'') ELSE '' END

   IF ISNULL(@c_CCAdjNotCompareCurrInv,'') <> '1'
   BEGIN
      SET @c_SQL =
        N'SELECT LOTxLOCxID.StorerKey'
        +     ', LOTxLOCxID.Sku'
        +     ', LOTxLOCxID.Lot'
        +     ', LOTxLOCxID.Id'
        +     ', LOTxLOCxID.Loc'
        +     ', CASE WHEN LOC.LOSEUCC=''0'' AND ISNULL(UCC.UCCNo,'''')='''' THEN 0 ELSE LOTxLOCxID.Qty'
        +        CASE WHEN @c_ExcludeQtyAllocated = 'Y' THEN '-LOTxLOCxID.Qtyallocated' ELSE '' END
        +        CASE WHEN @c_ExcludeQtyPicked    = 'Y' THEN '-LOTxLOCxID.Qtypicked'    ELSE '' END
        +        CASE WHEN ISNULL(@c_ExcludeQtyAllocated,'')<>'Y' AND ISNULL(@c_GenCCdetailbyExcludePKDStatus3,'')='1' THEN '-ISNULL(PD.Qty_Status3,0)' ELSE '' END
        +      ' END'
        +     ', ISNULL(LotAttribute.Lottable01,'''')'
        +     ', ISNULL(LotAttribute.Lottable02,'''')'
        +     ', ISNULL(LotAttribute.Lottable03,'''')'
        +     ', LotAttribute.Lottable04'
        +     ', LotAttribute.Lottable05'
        +     ', ISNULL(LotAttribute.Lottable06,'''')'
        +     ', ISNULL(LotAttribute.Lottable07,'''')'
        +     ', ISNULL(LotAttribute.Lottable08,'''')'
        +     ', ISNULL(LotAttribute.Lottable09,'''')'
        +     ', ISNULL(LotAttribute.Lottable10,'''')'
        +     ', ISNULL(LotAttribute.Lottable11,'''')'
        +     ', ISNULL(LotAttribute.Lottable12,'''')'
        +     ', LotAttribute.Lottable13'
        +     ', LotAttribute.Lottable14'
        +     ', LotAttribute.Lottable15'
        +     ', ISNULL(UCC.UCCNo,'''')'
        +     ', ISNULL(UCC.Qty,0)'
        +     ', ' + CASE WHEN ISNULL(@c_SerialNoUpdateLotLocID,'') = '1' THEN 'ISNULL(SERIALNO.SerialNo,'''')' ELSE '''''' END
        +     ', ' + CASE WHEN ISNULL(@c_SerialNoUpdateLotLocID,'') = '1' THEN 'ISNULL(SERIALNO.Qty,'''')'      ELSE '0'    END
        + ' FROM dbo.LOC           WITH (NOLOCK)'
        + ' JOIN dbo.LOTxLOCxID    WITH (NOLOCK) ON LOC.Loc = LOTxLOCxID.Loc'
        + ' JOIN dbo.LotAttribute  WITH (NOLOCK) ON LOTxLOCxID.Lot = LotAttribute.Lot'
        + ' JOIN dbo.SKU           WITH (NOLOCK) ON LOTxLOCxID.StorerKey = SKU.StorerKey AND LOTxLOCxID.Sku = SKU.Sku'
        + ' LEFT JOIN dbo.UCC      WITH (NOLOCK) ON LOTxLOCxID.Storerkey = UCC.Storerkey AND LOTxLOCxID.Sku = UCC.Sku AND LOTxLOCxID.Lot = UCC.Lot AND LOTxLOCxID.Loc = UCC.Loc AND LOTxLOCxID.ID = UCC.ID'
        +                                     ' AND ISNULL(LOC.LoseUCC,'''')=''0'' AND UCC.Status BETWEEN ''1'' AND ''3'''

      IF ISNULL(@c_ExcludeQtyAllocated,'')<>'Y' AND ISNULL(@c_GenCCdetailbyExcludePKDStatus3,'')='1'
         SET @c_SQL = @c_SQL
           + ' OUTER APPLY ('
           +    ' SELECT Qty_Status3 = SUM(PD.Qty)'
           +      ' FROM dbo.PICKDETAIL PD WITH (NOLOCK)'
           +     ' WHERE PD.Lot = LOTxLOCxID.Lot'
           +       ' AND PD.Loc = LOTxLOCxID.Loc'
           +       ' AND PD.ID  = LOTxLOCxID.ID'
           +       ' AND PD.Status = ''3'''
           +  ') PD'

      IF ISNULL(@c_SerialNoUpdateLotLocID,'') = '1'
         SET @c_SQL = @c_SQL
           + ' LEFT JOIN dbo.SERIALNO WITH (NOLOCK) ON LOTxLOCxID.Storerkey = SERIALNO.Storerkey AND LOTxLOCxID.Sku = SERIALNO.Sku'
           +                                     ' AND LOTxLOCxID.Lot = SERIALNO.Lot AND LOTxLOCxID.Loc = SERIALNO.Loc AND LOTxLOCxID.ID = SERIALNO.ID'
           +                                     ' AND SERIALNO.Status = ''1'' AND SKU.SerialNoCapture IN (''1'',''2'',''3'')'
           +                                     ' AND (ISNULL(LOC.LoseUCC,'''')<>''0'' OR (ISNULL(LOC.LoseUCC,'''')=''0'' AND ISNULL(UCC.UCCNo,'''')=ISNULL(SERIALNO.UCCNo,'''')))'

      SET @c_SQL = @c_SQL
        +' WHERE UCC.UCCNo IS NULL'
        +  ' AND LOC.Facility = N''' + ISNULL(REPLACE(RTRIM(@c_Facility),'''',''''''),'') + ''''
        +  ' AND CASE WHEN LOC.LOSEUCC=''0'' AND ISNULL(UCC.UCCNo,'''')='''' THEN 0 ELSE LOTxLOCxID.Qty'
        +        CASE WHEN @c_ExcludeQtyAllocated = 'Y' THEN '-LOTxLOCxID.Qtyallocated' ELSE '' END
        +        CASE WHEN @c_ExcludeQtyPicked    = 'Y' THEN '-LOTxLOCxID.Qtypicked'    ELSE '' END
        +        CASE WHEN ISNULL(@c_ExcludeQtyAllocated,'')<>'Y' AND ISNULL(@c_GenCCdetailbyExcludePKDStatus3,'')='1' THEN '-ISNULL(PD.Qty_Status3,0)' ELSE '' END
        +      ' END > 0'
        + ' ' + ISNULL(RTRIM(@c_StorerSQL  ),'') + ' ' + ISNULL(RTRIM(@c_StorerSQL2),'')
        + ' ' + ISNULL(RTRIM(@c_StrategySQL),'')

      IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.STOCKTAKEPARM2 WITH (NOLOCK) WHERE Stocktakekey = @c_StockTakeKey) OR @n_IsRDT = 1
      BEGIN
         SET @c_SQL = @c_SQL
           + ' ' + @c_SkuConditionSQL
           + ' ' + @c_ExtendedConditionSQL1
           + ' ' + @c_ExtendedConditionSQL2
           + ' ' + @c_ExtendedConditionSQL3
           + ' ' + ISNULL(RTRIM(@c_LocSQL), '')

         IF ISNULL(@c_ByPalletLevel,'')<>'Y'
            SET @c_SQL = @c_SQL +' '+ @c_LocConditionSQL
      END
      ELSE
         SET @c_SQL = @c_SQL + @c_StocktakeParm2SQL + @c_StocktakeParm2OtherSQL

      IF @c_ByPalletLevel = 'Y'
         SET @c_SQL = @c_SQL
           + ' AND EXISTS (SELECT TOP 1 1 FROM dbo.CCDETAIL CC WITH(NOLOCK) WHERE CC.Storerkey = LOTXLOCXID.Storerkey AND CC.Id = LOTXLOCXID.ID'
           +                ' AND ISNULL(CC.ID,'''')<>'''' AND CC.CCKey = N''' + ISNULL(REPLACE(RTRIM(@c_StockTakeKey),'''',''''''),'') + ''')'

      IF @b_debug = 1
         SELECT 'Withdraw', @c_SQL

      INSERT INTO #Withdraw (
            StorerKey, Sku, Lot, Id, Loc, Qty,
            Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
            Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
            Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
            UCCNo, UCC_Qty, SerialNo, SN_Qty)
      EXEC ( @c_SQL )
   END

   -- Generate Deposit Transaction From CCDETAIL Table
   SET @c_SQL =
     N'SELECT CCDETAIL.CCDetailkey'
     +     ', CCDETAIL.StorerKey'
     +     ', CCDETAIL.Sku'
     +     ', N'''' as Lot'
     +     ', CCDETAIL.Id'
     +     ', CCDETAIL.Loc'
     +     ', '        + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Qty'        WHEN '2' THEN 'CCDETAIL.Qty_Cnt2'        WHEN '3' THEN 'CCDETAIL.Qty_Cnt3'        ELSE '''''' END
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable01' WHEN '2' THEN 'CCDETAIL.Lottable01_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable01_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable02' WHEN '2' THEN 'CCDETAIL.Lottable02_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable02_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable03' WHEN '2' THEN 'CCDETAIL.Lottable03_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable03_Cnt3' ELSE '''''' END + ','''')'
     +     ', '        + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable04' WHEN '2' THEN 'CCDETAIL.Lottable04_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable04_Cnt3' ELSE '''''' END
     +     ', '        + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable05' WHEN '2' THEN 'CCDETAIL.Lottable05_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable05_Cnt3' ELSE '''''' END
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable06' WHEN '2' THEN 'CCDETAIL.Lottable06_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable06_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable07' WHEN '2' THEN 'CCDETAIL.Lottable07_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable07_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable08' WHEN '2' THEN 'CCDETAIL.Lottable08_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable08_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable09' WHEN '2' THEN 'CCDETAIL.Lottable09_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable09_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable10' WHEN '2' THEN 'CCDETAIL.Lottable10_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable10_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable11' WHEN '2' THEN 'CCDETAIL.Lottable11_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable11_Cnt3' ELSE '''''' END + ','''')'
     +     ', ISNULL(' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable12' WHEN '2' THEN 'CCDETAIL.Lottable12_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable12_Cnt3' ELSE '''''' END + ','''')'
     +     ', '        + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable13' WHEN '2' THEN 'CCDETAIL.Lottable13_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable13_Cnt3' ELSE '''''' END
     +     ', '        + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable14' WHEN '2' THEN 'CCDETAIL.Lottable14_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable14_Cnt3' ELSE '''''' END
     +     ', '        + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Lottable15' WHEN '2' THEN 'CCDETAIL.Lottable15_Cnt2' WHEN '3' THEN 'CCDETAIL.Lottable15_Cnt3' ELSE '''''' END
     +     ', ISNULL(CCDETAIL.RefNo,'''')'
     +     ', '        + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Qty'        WHEN '2' THEN 'CCDETAIL.Qty_Cnt2'        WHEN '3' THEN 'CCDETAIL.Qty_Cnt3'        ELSE '''''' END
     +     ', ' + CASE WHEN ISNULL(@c_SerialNoUpdateLotLocID,'') = '1' THEN 'ISNULL(CCSerialNoLog.SerialNo,'''')' ELSE '''''' END
     +     ', ' + CASE WHEN ISNULL(@c_SerialNoUpdateLotLocID,'') = '1' THEN 'ISNULL(CCSerialNoLog.Qty,0)'         ELSE '0'    END
     + ' FROM dbo.CCDETAIL WITH (NOLOCK)'
     + ' JOIN dbo.SKU      WITH (NOLOCK) ON CCDETAIL.StorerKey = SKU.StorerKey AND CCDETAIL.Sku = SKU.Sku'

   IF ISNULL(@c_SerialNoUpdateLotLocID,'') = '1'
      SET @c_SQL = @c_SQL
        + ' LEFT JOIN dbo.CCSerialNoLog WITH (NOLOCK) ON CCDETAIL.CCDetailKey = CCSerialNoLog.CCDetailKey AND SKU.SerialNoCapture IN (''1'',''2'',''3'')'

   SET @c_SQL = @c_SQL
     +' WHERE CCDETAIL.CCKEY = N''' + ISNULL(REPLACE(@c_StockTakeKey,'''',''''''),'') + ''''
     +  ' AND ' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.Qty'          WHEN '2' THEN 'CCDETAIL.Qty_Cnt2'          WHEN '3' THEN 'CCDETAIL.Qty_Cnt3'          ELSE '''''' END + ' > 0'
     +  ' AND ' + CASE @c_CountNo WHEN '1' THEN 'CCDETAIL.FinalizeFlag' WHEN '2' THEN 'CCDETAIL.FinalizeFlag_Cnt2' WHEN '3' THEN 'CCDETAIL.FinalizeFlag_Cnt3' ELSE '''''' END + ' = ''Y'''

   IF @n_IsRDT = 1 AND ISNULL(@c_SQL,'')<>''
      SET @c_SQL = @c_SQL + ' AND CCDETAIL.CCSheetNo = N''' + ISNULL(REPLACE(@c_TaskDetailKey,'''',''''''),'') + ''''

   IF @b_debug = 1
      SELECT 'Deposit', @c_SQL

   INSERT INTO #Deposit (
         CCDetailkey, StorerKey, Sku, Lot, Id, Loc, Qty,
         Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
         Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
         Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
         UCCNo, UCC_Qty, SerialNo, SN_Qty)
   EXEC ( @c_SQL )

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF ISNULL(@c_NotUpdLocForSameID,'') NOT IN ('1','Y')
      BEGIN
         -- Same ID should be same Loc
         UPDATE a
            SET Loc = ISNULL(b.Loc,'')
           FROM #Deposit a
           JOIN (
              SELECT ID, Loc = MAX(Loc)
                FROM #Deposit
               WHERE ISNULL(ID,'')<>''
               GROUP BY ID
           ) b ON a.ID = b.ID
          WHERE ISNULL(a.ID,'')<>'' AND ISNULL(a.Loc,'') <> ISNULL(b.Loc,'')
      END
   END

   IF @b_debug = 1
   BEGIN
      SELECT 'Withdraw', * FROM #Withdraw
      SELECT 'Deposit' , * FROM #Deposit
   END

   -- Assign Lot# to #Deposit
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE CUR_DEPOSIT CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT CCDetailkey, StorerKey, Sku,
             Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
             Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
             Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
        FROM #Deposit
       WHERE ISNULL(Lot,'') = ''
         AND Qty > 0

      OPEN CUR_DEPOSIT

      WHILE @n_continue = 1 OR @n_continue = 2
      BEGIN
         FETCH NEXT FROM CUR_DEPOSIT INTO
            @c_CCDetailkey, @c_Storerkey, @c_Sku,
            @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
            @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
            @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15

         IF @@FETCH_STATUS <> 0
            BREAK

         SELECT @b_isok = 0
         EXECUTE nsp_LotLookUp @c_Storerkey, @c_Sku
               , @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05
               , @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
               , @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
               , @c_Lot      OUTPUT
               , @b_isok     OUTPUT
               , @n_err      OUTPUT
               , @c_errmsg   OUTPUT

         IF @b_isok = 1
         BEGIN
            -- Add To Lotattribute table
            SELECT @b_isok = 0
            EXECUTE nsp_LotGen @c_Storerkey, @c_Sku
                  , @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05
                  , @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10
                  , @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15
                  , @c_Lot      OUTPUT
                  , @b_isok     OUTPUT
                  , @n_err      OUTPUT
                  , @c_errmsg   OUTPUT

            IF @b_isok <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'Lot Generation Error'
               BREAK
            END

            IF ISNULL(RTRIM(@c_Lot),'') <> ''
            BEGIN
               UPDATE #Deposit
                  SET Lot = @c_Lot
                WHERE CCDetailkey = @c_CCDetailkey
                  AND ISNULL(RTRIM(Lot),'') = ''
            END
         END
      END
      CLOSE CUR_DEPOSIT
      DEALLOCATE CUR_DEPOSIT
   END

   -- Check UCC Qty & SerialNo Qty
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SET @c_ErrMsg = ''
      SELECT TOP 1 @c_ErrMsg =
             CASE WHEN Y.SerialNo <> '' AND Y.SN_QtySum <> Y.UCC_Qty
                  THEN 'CCSerialNoLog Qty Not Match'
                     + ' (Lot='       + ISNULL(RTRIM(Lot),'')
                     + ', Loc='       + ISNULL(RTRIM(Loc),'')
                     + ', ID='        + ISNULL(RTRIM(ID),'')
                     + ', SystemQty=' + ISNULL(CONVERT(VARCHAR(10),Qty),'')
                     + CASE WHEN UCCNo<>''
                            THEN ', UCCNo='   + ISNULL(RTRIM(UCCNo),'')
                               + ', UCC_Qty=' + ISNULL(CONVERT(VARCHAR(10),UCC_Qty),'')
                            ELSE ''
                       END
                     + ', Total_SN_Qty=' + ISNULL(CONVERT(VARCHAR(10),SN_QtySum),'')
                     + ')'
                  WHEN Y.UCCNo <> '' AND Y.UCC_QtySum <> Y.Qty
                  THEN 'CCDetail UCC Qty Not Match'
                     + ' (Lot='       + ISNULL(RTRIM(Lot),'')
                     + ', Loc='       + ISNULL(RTRIM(Loc),'')
                     + ', ID='        + ISNULL(RTRIM(ID),'')
                     + ', SystemQty=' + ISNULL(CONVERT(VARCHAR(10),Qty),'')
                     + ', Total_UCC_Qty=' + ISNULL(CONVERT(VARCHAR(10),UCC_QtySum),'')
                     + ')'
             END
      FROM (
         SELECT *, UCC_QtySum = SUM(CASE WHEN UCC_LineNo=1 THEN UCC_Qty ELSE 0 END) OVER(PARTITION BY Storerkey, Sku, Lot, Loc, ID)
         FROM (
            SELECT Storerkey, Sku, Lot, Loc, ID, Qty, UCCNo, UCC_Qty, SerialNo, SN_Qty
                 , UCC_LineNo = ROW_NUMBER() OVER(PARTITION BY Storerkey, Sku, Lot, Loc, ID, UCCNo ORDER BY SerialNo)
                 , SN_QtySum = SUM(SN_Qty) OVER(PARTITION BY Storerkey, Sku, Lot, Loc, ID, UCCNo)
            FROM #deposit
         ) X
      ) Y
      WHERE (Y.SerialNo<>'' AND Y.SN_QtySum  <> Y.UCC_Qty)
         OR (Y.UCCNo   <>'' AND Y.UCC_QtySum <> Y.Qty    )

      IF ISNULL(@c_ErrMsg,'') <> ''
      BEGIN
         SET @n_continue = 3
         GOTO EXIT_SP
      END
   END

   -- Generate Variance
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      INSERT INTO #Variance (StorerKey, Sku, Lot, Id, Loc, Qty,
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               UCCNo, SerialNo, CCDetailkey)
      SELECT * FROM (
         SELECT Storerkey   = CASE WHEN d.Sku IS NULL THEN w.Storerkey  ELSE d.Storerkey   END
              , Sku         = CASE WHEN d.Sku IS NULL THEN w.Sku        ELSE d.Sku         END
              , Lot         = CASE WHEN d.Sku IS NULL THEN w.Lot        ELSE d.Lot         END
              , ID          = CASE WHEN d.Sku IS NULL THEN w.ID         ELSE d.ID          END
              , Loc         = CASE WHEN d.Sku IS NULL THEN w.Loc        ELSE d.Loc         END
              , QtyVariance = CASE WHEN ISNULL(w.SerialNo, d.SerialNo)<>'' THEN ISNULL(d.SN_Qty ,0) - ISNULL(w.SN_Qty ,0)
                                   WHEN ISNULL(w.UCCNo   , d.UCCNo   )<>'' THEN ISNULL(d.UCC_qty,0) - ISNULL(w.UCC_qty,0)
                                   ELSE                                         ISNULL(d.Qty    ,0) - ISNULL(w.Qty    ,0)
                              END
              , Lottable01  = CASE WHEN d.Sku IS NULL THEN w.Lottable01 ELSE d.Lottable01  END
              , Lottable02  = CASE WHEN d.Sku IS NULL THEN w.Lottable02 ELSE d.Lottable02  END
              , Lottable03  = CASE WHEN d.Sku IS NULL THEN w.Lottable03 ELSE d.Lottable03  END
              , Lottable04  = CASE WHEN d.Sku IS NULL THEN w.Lottable04 ELSE d.Lottable04  END
              , Lottable05  = CASE WHEN d.Sku IS NULL THEN w.Lottable05 ELSE d.Lottable05  END
              , Lottable06  = CASE WHEN d.Sku IS NULL THEN w.Lottable06 ELSE d.Lottable06  END
              , Lottable07  = CASE WHEN d.Sku IS NULL THEN w.Lottable07 ELSE d.Lottable07  END
              , Lottable08  = CASE WHEN d.Sku IS NULL THEN w.Lottable08 ELSE d.Lottable08  END
              , Lottable09  = CASE WHEN d.Sku IS NULL THEN w.Lottable09 ELSE d.Lottable09  END
              , Lottable10  = CASE WHEN d.Sku IS NULL THEN w.Lottable10 ELSE d.Lottable10  END
              , Lottable11  = CASE WHEN d.Sku IS NULL THEN w.Lottable11 ELSE d.Lottable11  END
              , Lottable12  = CASE WHEN d.Sku IS NULL THEN w.Lottable12 ELSE d.Lottable12  END
              , Lottable13  = CASE WHEN d.Sku IS NULL THEN w.Lottable13 ELSE d.Lottable13  END
              , Lottable14  = CASE WHEN d.Sku IS NULL THEN w.Lottable14 ELSE d.Lottable14  END
              , Lottable15  = CASE WHEN d.Sku IS NULL THEN w.Lottable15 ELSE d.Lottable15  END
              , UCCNo       = CASE WHEN d.Sku IS NULL THEN w.UCCNo      ELSE d.UCCNo       END
              , SerialNo    = CASE WHEN d.Sku IS NULL THEN w.SerialNo   ELSE d.SerialNo    END
              , CCDetailkey = CASE WHEN d.Sku IS NULL THEN ''           ELSE d.CCDetailkey END
         FROM #Withdraw w
         FULL JOIN (
            SELECT StorerKey, Sku, Lot, Id, Loc, Qty = SUM(Qty),
                  Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
                  Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
                  Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                  UCCNo, UCC_Qty = SUM(UCC_Qty), SerialNo, SN_Qty = SUM(SN_Qty),
                  CCDetailkey = CASE WHEN MIN(CCDetailkey)=MAX(CCDetailkey) THEN MAX(CCDetailkey) ELSE '' END
            FROM #Deposit
            GROUP BY StorerKey, Sku, Lot, Id, Loc,
                  Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
                  Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
                  Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                  UCCNo, SerialNo
         ) d ON w.Storerkey = d.Storerkey AND w.Sku = d.Sku AND w.Lot = d.Lot AND w.ID = d.ID AND w.Loc = d.Loc AND w.UCCNo = d.UCCNo AND w.SerialNo = d.SerialNo
      ) WD
      WHERE WD.QtyVariance <> 0
      ORDER BY CASE WHEN QtyVariance < 0 THEN 1 ELSE 2 END
             , Storerkey, UCCNo, Sku, Lot, ID, Loc, SerialNo, ABS(QtyVariance)
   END

   -- Get Channel and Channel ID
   IF (@n_continue = 1 OR @n_continue = 2)
      AND ISNULL(@c_ChannelInventoryMgmt,'') = '1'
   BEGIN
      IF ISNULL(@c_CC_Chanel_Exp,'') <> ''
      BEGIN
         SET @c_SQL = N'UPDATE TMP'
           + ' SET Channel = ISNULL(' + @c_CC_Chanel_Exp + ','''')'
           + ' FROM #Variance TMP'
           + ' WHERE Channel_ID <= 0'
         EXEC ( @c_SQL )
      END

      TRUNCATE TABLE #TEMP_CHANNELINV

      INSERT INTO #TEMP_CHANNELINV (
             Channel_ID, StorerKey, SKU, Facility, Channel
           , C_Attribute01, C_Attribute02, C_Attribute03, C_Attribute04, C_Attribute05
           , Qty, QtyAllocated, QtyOnHold)
      SELECT CINV.Channel_ID, CINV.StorerKey, CINV.SKU, CINV.Facility, CINV.Channel
           , CINV.C_Attribute01, CINV.C_Attribute02, CINV.C_Attribute03, CINV.C_Attribute04, CINV.C_Attribute05
           , CINV.Qty + ISNULL(V.Qty,0), CINV.QtyAllocated, CINV.QtyOnHold
        FROM CHANNELINV CINV WITH (NOLOCK)
        LEFT JOIN (
           SELECT Channel_ID, Qty=SUM(Qty)
             FROM #Variance
            WHERE Qty<0 AND Channel_ID>0 GROUP BY Channel_ID
        ) V ON CINV.Channel_ID = V.Channel_ID
       WHERE Facility  = @c_Facility
         AND EXISTS(SELECT TOP 1 1 FROM #Variance WHERE Storerkey = CINV.Storerkey AND Sku = CINV.Sku)

      TRUNCATE TABLE #TEMP_CHANNELSEARCHLIST

      IF ISNULL(@c_ChannelSearchSeq,'') <> ''
      BEGIN
         INSERT INTO #TEMP_CHANNELSEARCHLIST (Channel)
         SELECT ColValue
           FROM dbo.fnc_DelimSplit(',', @c_ChannelSearchSeq)
          WHERE ISNULL(ColValue,'')<>''
          GROUP BY ColValue
          ORDER BY MIN(SeqNo)
      END


      SET @n_RowID = 0

      WHILE @n_continue = 1 OR @n_continue = 2
      BEGIN
         SELECT TOP 1
                @n_RowID       = [RowID]
              , @c_Storerkey   = Storerkey
              , @c_Sku         = Sku
              , @c_Lot         = Lot
              , @c_Loc         = Loc
              , @c_ID          = ID
              , @c_UCCNo       = UCCNo
              , @n_VarQty      = Qty
              , @c_Channel     = Channel
           FROM #variance
          WHERE Channel_ID = 0
            AND [RowID] > @n_RowID
          ORDER BY [RowID]

         IF @@ROWCOUNT <= 0
            BREAK

         IF ISNULL(@c_Channel,'') = ''
            SET @c_Channel = @c_DefaultChannel

         EXEC sp_ExecuteSQL @c_ChannelAttrSQL, @c_ChannelAttrParm
            , @c_LOT
            , @c_C_Attribute01  OUTPUT
            , @c_C_Attribute02  OUTPUT
            , @c_C_Attribute03  OUTPUT
            , @c_C_Attribute04  OUTPUT
            , @c_C_Attribute05  OUTPUT

         SELECT @c_C_Attribute01 = ISNULL(@c_C_Attribute01,'')
              , @c_C_Attribute02 = ISNULL(@c_C_Attribute02,'')
              , @c_C_Attribute03 = ISNULL(@c_C_Attribute03,'')
              , @c_C_Attribute04 = ISNULL(@c_C_Attribute04,'')
              , @c_C_Attribute05 = ISNULL(@c_C_Attribute05,'')

         SET @n_Channel_ID = 0
         SET @n_ChannelQty = 0

         IF @n_VarQty < 0
         BEGIN
            SET @n_VarAbsQty = ABS(@n_VarQty)

            SELECT TOP 1
                   @n_Channel_ID = CINV.Channel_ID
                 , @c_Channel    = CINV.Channel
                 , @n_ChannelQty = CINV.Qty
              FROM #TEMP_CHANNELINV             CINV
              LEFT JOIN #TEMP_CHANNELSEARCHLIST CSLT ON CINV.Channel = CSLT.Channel
             WHERE CINV.StorerKey = @c_Storerkey
               AND CINV.Facility  = @c_Facility
               AND CINV.SKU = @c_Sku
               AND CINV.C_Attribute01 = @c_C_Attribute01
               AND CINV.C_Attribute02 = @c_C_Attribute02
               AND CINV.C_Attribute03 = @c_C_Attribute03
               AND CINV.C_Attribute04 = @c_C_Attribute04
               AND CINV.C_Attribute05 = @c_C_Attribute05
               AND CINV.Qty > 0
             ORDER BY CASE WHEN CINV.Channel = @c_Channel THEN 1 ELSE 2 END
                    , ISNULL(CSLT.RowID,99999999)
                    , CASE WHEN CINV.Qty > CINV.Qtyallocated THEN 1 ELSE 2 END
                    , CASE WHEN CINV.Qty >= @n_VarAbsQty  THEN 1 ELSE 2 END
                    , CINV.Qty
                    , CINV.Channel_ID

            IF @@ROWCOUNT <= 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 67102
               SELECT @c_errmsg = 'NSQL' + CONVERT(VARCHAR(10), @n_err) + ': Insuffient Channel Inv to adj out '
                                + CONVERT(NVARCHAR(10), @n_VarAbsQty) + ' qty from Sku=' + RTRIM(@c_Sku)
                                + ' Lot=' + RTRIM(@c_Lot) + ' Loc=' + RTRIM(@c_Loc) + ' ID=' + RTRIM(@c_ID)
                                + CASE WHEN ISNULL(@c_UCCNo,'')<>'' THEN ' UCCNo=' + RTRIM(@c_UCCNo) ELSE '' END
                                + '. (' + @c_SP_Name + ')'
               BREAK
            END

            SET @n_Qty = CASE WHEN @n_VarAbsQty > @n_ChannelQty THEN @n_ChannelQty ELSE @n_VarAbsQty END

            IF @n_VarAbsQty > @n_ChannelQty
            BEGIN
               INSERT INTO #Variance(
                      StorerKey, Sku, Lot, Id, Loc, Qty
                    , Lottable01, Lottable02, Lottable03, Lottable04, Lottable05
                    , Lottable06, Lottable07, Lottable08, Lottable09, Lottable10
                    , Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
                    , UCCNo, SerialNo, Channel, Channel_ID, CCDetailKey)
               SELECT StorerKey, Sku, Lot, Id, Loc, Qty + @n_Qty
                    , Lottable01, Lottable02, Lottable03, Lottable04, Lottable05
                    , Lottable06, Lottable07, Lottable08, Lottable09, Lottable10
                    , Lottable11, Lottable12, Lottable13, Lottable14, Lottable15
                    , UCCNo, SerialNo, Channel, 0, CCDetailKey
                 FROM #Variance
                WHERE [RowID] = @n_RowID

               UPDATE #Variance
                  SET Qty = -@n_Qty
                WHERE [RowID] = @n_RowID
            END

            UPDATE #TEMP_CHANNELINV
               SET Qty = Qty - @n_Qty
             WHERE Channel_ID = @n_Channel_ID
         END
         ELSE
         BEGIN
            IF ISNULL(@c_Channel,'') <> ''
            BEGIN
               SELECT TOP 1
                      @n_Channel_ID = Channel_ID
                 FROM #TEMP_CHANNELINV
                WHERE StorerKey = @c_Storerkey
                  AND Facility  = @c_Facility
                  AND SKU = @c_Sku
                  AND Channel = @c_Channel
                  AND C_Attribute01 = @c_C_Attribute01
                  AND C_Attribute02 = @c_C_Attribute02
                  AND C_Attribute03 = @c_C_Attribute03
                  AND C_Attribute04 = @c_C_Attribute04
                  AND C_Attribute05 = @c_C_Attribute05
            END

            IF @n_Channel_ID <= 0
            BEGIN
               SELECT TOP 1
                      @n_Channel_ID = CINV.Channel_ID
                    , @c_Channel    = CINV.Channel
                 FROM #TEMP_CHANNELINV             CINV
                 LEFT JOIN #TEMP_CHANNELSEARCHLIST CSLT ON CINV.Channel = CSLT.Channel
                 OUTER APPLY (
                    SELECT V.Channel_ID, Qty = SUM(V.Qty)
                      FROM #Variance V
                     WHERE V.Channel_ID > 0 AND V.Channel_ID = CINV.Channel_ID
                     GROUP BY V.Channel_ID
                     HAVING SUM(V.Qty) < 0
                 ) X
                WHERE CINV.StorerKey = @c_Storerkey
                  AND CINV.Facility  = @c_Facility
                  AND CINV.SKU = @c_Sku
                  AND CINV.C_Attribute01 = @c_C_Attribute01
                  AND CINV.C_Attribute02 = @c_C_Attribute02
                  AND CINV.C_Attribute03 = @c_C_Attribute03
                  AND CINV.C_Attribute04 = @c_C_Attribute04
                  AND CINV.C_Attribute05 = @c_C_Attribute05
                ORDER BY CASE WHEN X.Channel_ID > 0 AND @n_VarQty <= ABS(X.Qty) THEN ABS(X.Qty) ELSE 999999999 END
                       , CASE WHEN X.Channel_ID > 0 THEN X.Qty ELSE 999999999 END
                       , ISNULL(CSLT.RowID,999999999)
                       , CASE WHEN CINV.Qty > 0 THEN 1 ELSE 2 END
                       , CINV.Channel_ID
            END

            IF @n_Channel_ID <= 0
            BEGIN
               EXEC isp_ChannelGetID
                    @c_Storerkey        = @c_Storerkey
                  , @c_Sku              = @c_Sku
                  , @c_Facility         = @c_Facility
                  , @c_Channel          = @c_Channel
                  , @c_LOT              = @c_Lot
                  , @n_Channel_ID       = @n_Channel_ID OUTPUT
                  , @b_Success          = @b_Success    OUTPUT
                  , @n_ErrNo            = @n_Err        OUTPUT
                  , @c_ErrMsg           = @c_ErrMsg     OUTPUT
                  , @c_CreateIfNotExist = 'Y'

               IF @b_Success = 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 67103
                  SELECT @c_errmsg = 'NSQL' + CONVERT(VARCHAR(10), @n_err) + ': isp_ChannelGetID Failed. (' + @c_SP_Name + ')'
                                            + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
                  BREAK
               END
            END
         END

         IF ISNULL(@n_Channel_ID,0) <= 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err = 67104
            SELECT @c_errmsg = 'NSQL' + CONVERT(VARCHAR(10), @n_err) + ': Channel_ID Not Found for Channel=''' + ISNULL(RTRIM(@c_Channel),'')
                             + ''', Sku=''' + ISNULL(RTRIM(@c_Sku),'') + '''. (' + @c_SP_Name + ')'
            BREAK
         END

         UPDATE #Variance
            SET Channel_ID = @n_Channel_ID
              , Channel    = @c_Channel
          WHERE [RowID] = @n_RowID
      END
   END

   IF @b_debug = 1
      SELECT 'Variance', * FROM #Variance

   -- Generate Adjustment
   IF (@n_continue = 1 OR @n_continue = 2)
      AND EXISTS(SELECT TOP 1 1 FROM #Variance WHERE Qty<>0)
   BEGIN
      DECLARE CUR_ADJ CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT V.StorerKey, V.Sku, V.Lot, V.Id, V.Loc, V.Qty, P.PackKey, P.PackUOM3,
             V.Lottable01, V.Lottable02, V.Lottable03, V.Lottable04, V.Lottable05,
             V.Lottable06, V.Lottable07, V.Lottable08, V.Lottable09, V.Lottable10,
             V.Lottable11, V.Lottable12, V.Lottable13, V.Lottable14, V.Lottable15,
             V.UCCNo, V.SerialNo, V.Channel, V.Channel_ID, V.CCDetailKey
        FROM #Variance V
        JOIN dbo.SKU   S WITH (NOLOCK) ON V.StorerKey = S.StorerKey AND V.Sku = S.Sku
        JOIN dbo.PACK  P WITH (NOLOCK) ON S.PackKey = P.PackKey
       WHERE V.Qty <> 0
       ORDER BY V.StorerKey, V.Sku, V.UCCNo, V.SerialNo, V.Channel, V.Loc, V.ID, V.[RowID]

      OPEN CUR_ADJ

      SET @c_PrevStorerKey = ''

      WHILE @n_continue = 1 OR @n_continue = 2
      BEGIN
         FETCH NEXT FROM CUR_ADJ INTO
            @c_Storerkey, @c_Sku, @c_Lot, @c_Id, @c_Loc, @n_Qty, @c_PackKey, @c_UOM,
            @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
            @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
            @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15,
            @c_UCCNo, @c_SerialNo, @c_Channel, @n_Channel_ID, @c_CCDetailkey

         IF @@FETCH_STATUS <> 0
            BREAK

         IF @c_PrevStorerKey <> @c_Storerkey
         BEGIN
            SELECT @c_CCAdjNotCompareCurrInv = Authority FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '','CCAdjNotCompareCurrInv')

            SELECT @c_CCMoveAdjQtyToLoc = ''
                 , @c_Hostwhcode_UDF01  = ''

            SELECT TOP 1
                   @c_CCMoveAdjQtyToLoc = LOC.Loc
                 , @c_Hostwhcode_UDF01  = CL.UDF01
              FROM dbo.CODELKUP CL  WITH (NOLOCK)
              JOIN dbo.LOC      LOC WITH (NOLOCK) ON CL.Code = LOC.Loc
             WHERE CL.ListName  = 'CCADJMVLOC'
               AND CL.Storerkey = @c_Storerkey

            -- Check sufficient balance to adj out
            IF @c_CCAdjNotCompareCurrInv = '1' AND NOT (@n_IsRDT = 1 AND @nRDTNotAutoFinalizeAdj = 1)
            BEGIN
               SELECT @c_Lot = '', @c_Loc = '', @c_ID = '', @n_Qty = 0

               SELECT TOP 1
                      @c_Lot    = V.Lot
                    , @c_Loc    = V.Loc
                    , @c_Id     = V.Id
                    , @n_Qty    = SUM(V.Qty) * -1
                    , @n_SysQty = SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked)
               FROM #Variance V
               JOIN LOTXLOCXID LLI WITH (NOLOCK) ON V.Storerkey = LLI.Storerkey AND V.Sku = LLI.Sku
                                                AND V.Lot = LLI.Lot AND V.Loc = LLI.Loc AND V.ID = LLI.Id
               WHERE V.Qty < 0
                 AND V.Storerkey = @c_Storerkey
               GROUP BY V.Lot, V.Loc, V.Id
               HAVING SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked) < (SUM(V.Qty) * -1)

               SELECT TOP 1 @c_CCSheetNo = CCSheetNo
                 FROM dbo.CCDETAIL WITH (NOLOCK)
                WHERE CCKey = @c_StockTakeKey
                  AND Lot   = @c_Lot
                  AND Loc   = @c_Loc
                  AND Id    = @c_ID

               IF @c_Lot <> '' AND @c_Loc <> ''
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 67105
                  SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err) + ': Insuffient bal to adj out '
                                   + CAST(@n_Qty AS NVARCHAR) + ' qty from lot: ' + RTRIM(@c_Lot)
                                   + ' Loc: ' + RTRIM(@c_Loc) + ' ID: ' + RTRIM(@c_ID)
                                   + ' SysQty: ' + CAST(@n_SysQty AS NVARCHAR) + ' CSheet#: ' + RTRIM(@c_CCSheetNo)
                                   + '. (' + @c_SP_Name + ')'
                  BREAK
               END
            END

            -- Create Adjustment Header
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
               SELECT @n_err = 67106
               SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err) + ': Unable to Obtain Adjustment key. (' + @c_SP_Name + ')'
                                + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
               BREAK
            END
            ELSE -- insert new Adjustment header record
            BEGIN
               INSERT INTO @tAdjustment (AdjustmentKey) VALUES (@c_AdjustmentKey)

               IF @n_IsRDT = 1
               BEGIN
                  -- Get adjustment type
                  SET @c_AdjType = 'RDTCC'
                  SELECT @c_AdjType = Short
                    FROM dbo.CODELKUP WITH (NOLOCK)
                   WHERE ListName = 'RDTCCADJ' AND Code = 'ADJTYPE' AND StorerKey = @c_Storerkey

                  -- Get reason code
                  SET @c_AdjReasonCode = 'CC'
                  SELECT @c_AdjReasonCode = Short
                    FROM dbo.CODELKUP WITH (NOLOCK)
                   WHERE ListName = 'RDTCCADJ' AND Code = 'REASONCODE' AND StorerKey = @c_Storerkey

                  INSERT INTO dbo.ADJUSTMENT (AdjustmentKey, AdjustmentType, StorerKey, Facility, CustomerRefNo, Remarks, UserDefine01, UserDefine02, UserDefine03, UserDefine10)
                  VALUES (@c_AdjustmentKey, @c_AdjType, @c_Storerkey, @c_Facility, @c_StockTakeKey, '', @c_Loc, @c_Sku, @c_TaskDetailKey, 'NoUCCPreAJ')

                  SET @n_err = @@error
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 67107
                     SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err) + ': Failed to Create Adjustment Header. (' + @c_SP_Name + ')'
                     BREAK
                  END
               END
               ELSE
               BEGIN
                  INSERT INTO dbo.ADJUSTMENT (AdjustmentKey, AdjustmentType, StorerKey, Facility, CustomerRefNo, Remarks, UserDefine10)
                  VALUES (@c_AdjustmentKey, @c_AdjType, @c_Storerkey, @c_Facility, @c_StockTakeKey, '', 'NoUCCPreAJ')

                  SET @n_err = @@error
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 67108
                     SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err) + ': Failed to Create Adjustment Header. (' + @c_SP_Name + ')'
                     BREAK
                  END
               END
            END
            SELECT @c_PrevStorerKey = @c_Storerkey
         END

         -- CC Move AdjQty ToLoc
         IF ISNULL(@c_CCMoveAdjQtyToLoc,'') <> ''
         BEGIN
            IF EXISTS(SELECT TOP 1 1 FROM dbo.LOC WITH (NOLOCK)
                      WHERE LOC = @c_Loc AND (HostWhCode = @c_Hostwhcode_UDF01 OR ISNULL(@c_Hostwhcode_UDF01,'') = '') )
               AND @n_Qty < 0
               AND @c_Loc <> @c_CCMoveAdjQtyToLoc
            BEGIN
               SET @n_MoveQty = ABS(@n_Qty)
               EXEC nspItrnAddMove
                    @n_ItrnSysId     = NULL
                  , @c_Storerkey     = @c_Storerkey
                  , @c_Sku           = @c_Sku
                  , @c_Lot           = @c_Lot
                  , @c_FromLoc       = @c_Loc
                  , @c_FromID        = @c_ID
                  , @c_ToLoc         = @c_CCMoveAdjQtyToLoc
                  , @c_ToID          = @c_ID
                  , @c_Status        = '0'
                  , @c_lottable01    = ''
                  , @c_lottable02    = ''
                  , @c_lottable03    = ''
                  , @d_lottable04    = NULL
                  , @d_lottable05    = NULL
                  , @c_lottable06    = ''
                  , @c_lottable07    = ''
                  , @c_lottable08    = ''
                  , @c_lottable09    = ''
                  , @c_lottable10    = ''
                  , @c_lottable11    = ''
                  , @c_lottable12    = ''
                  , @d_lottable13    = NULL
                  , @d_lottable14    = NULL
                  , @d_lottable15    = NULL
                  , @n_casecnt       = 0
                  , @n_innerpack     = 0
                  , @n_qty           = @n_MoveQty
                  , @n_pallet        = 0
                  , @f_cube          = 0
                  , @f_grosswgt      = 0
                  , @f_netwgt        = 0
                  , @f_otherunit1    = 0
                  , @f_otherunit2    = 0
                  , @c_SourceKey     = @c_AdjustmentKey
                  , @c_SourceType    = @c_SP_Name
                  , @c_PackKey       = @c_PackKey
                  , @c_UOM           = @c_UOM
                  , @b_UOMCalc       = NULL
                  , @d_EffectiveDate = NULL
                  , @c_itrnkey       = NULL
                  , @b_Success       = @b_Success OUTPUT
                  , @n_err           = @n_Err OUTPUT
                  , @c_errmsg        = @c_ErrMsg OUTPUT
                  , @c_MoveRefKey    = NULL
                  , @c_Channel       = @c_Channel
                  , @n_Channel_ID    = @n_Channel_ID

               IF @b_Success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 67109
                  SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err) + ': Failed to Move Adjustment Stock. (' + @c_SP_Name + ')'
                                   + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
                  BREAK
               END
               ELSE
                  SET @c_Loc = @c_CCMoveAdjQtyToLoc
            END
         END

         -- Insert Adjustment Detail
         SELECT @n_AdjLine = ISNULL(TRY_CONVERT(INT, MAX(AdjustmentLineNumber)), 0)
           FROM dbo.ADJUSTMENTDETAIL WITH (NOLOCK)
          WHERE AdjustmentKey = @c_AdjustmentKey

         INSERT INTO dbo.ADJUSTMENTDETAIL (
                AdjustmentKey,
                AdjustmentLineNumber,
                StorerKey, Sku, Lot, Id, Loc, Qty, PackKey, UOM, ReasonCode,
                Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
                Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
                Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                UCCNo, UserDefine01, UserDefine02, SerialNo, Channel, Channel_ID )
         VALUES(@c_AdjustmentKey,
                RIGHT('00000' + CONVERT(NVARCHAR(10),@n_AdjLine+1),5),
                @c_Storerkey, @c_Sku, @c_Lot, @c_Id, @c_Loc, @n_Qty, @c_PackKey, @c_UOM, @c_AdjReasonCode,
                @c_Lottable01, @c_Lottable02, @c_Lottable03, @d_Lottable04, @d_Lottable05,
                @c_Lottable06, @c_Lottable07, @c_Lottable08, @c_Lottable09, @c_Lottable10,
                @c_Lottable11, @c_Lottable12, @d_Lottable13, @d_Lottable14, @d_Lottable15,
                @c_UCCNo, @c_UCCNo, @c_CCDetailkey, @c_SerialNo, @c_Channel, @n_Channel_ID)

         SET @n_err = @@error

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err = 67110
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err) + ': Failed to Create Adjustment Detail. (' + @c_SP_Name + ')'
            BREAK
         END

         -- ID Hold
         IF @c_IDOnHold = 'Y' AND ISNULL(@c_Id,'') <> ''
         BEGIN
            SET @c_Remark = 'Stock Take# '+ RTRIM(@c_StockTakeKey) +'. Posting Adj Hold By Variance Pallet'
            EXECUTE nspInventoryHold
                    ''          --@c_lot
                  , ''          --@c_Loc
                  , @c_Id
                  , 'CCIDHOLD'  --@c_Status
                  , '1'         --@c_Hold
                  , @b_Success OUTPUT
                  , @n_Err     OUTPUT
                  , @c_Errmsg  OUTPUT
                  , @c_Remark

            IF @n_Err <> 0
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Hold By Palled ID Failed. (' + @c_SP_Name + '). ' + RTRIM(LTRIM(ISNULL(@c_Errmsg,'')))
               BREAK
            END
            ELSE
            BEGIN
               UPDATE dbo.INVENTORYHOLD WITH (ROWLOCK)
                  SET Storerkey = @c_Storerkey
                    , TrafficCop = NULL
                WHERE Id = @c_ID
                  AND Status = 'CCIDHOLD'
                  AND ISNULL(Storerkey,'') <> @c_Storerkey
            END
         END
      END
      CLOSE CUR_ADJ
      DEALLOCATE CUR_ADJ
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- Update CCDetail Status
      IF EXISTS(SELECT TOP 1 1 FROM dbo.ADJUSTMENT WITH (NOLOCK) WHERE CustomerRefNo = @c_StockTakeKey)
         OR NOT EXISTS(SELECT TOP 1 1 FROM #Variance)
      BEGIN
         IF @n_IsRDT = 1
         BEGIN
            UPDATE dbo.CCDETAIL WITH(ROWLOCK)
               SET Status = '9'
             WHERE CCDETAIL.CCKEY = @c_StockTakeKey AND CCSheetNo = @c_TaskDetailKey
         END
         ELSE
         BEGIN
            UPDATE dbo.CCDETAIL WITH(ROWLOCK)
               SET Status = '9'
             WHERE CCDETAIL.CCKEY = @c_StockTakeKey
         END
      END
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- Update CCSerialNoLog Status
      DECLARE CUR_CCSNLOG CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT DISTINCT CSL.CountSerialKey
        FROM #Deposit          DP
        JOIN dbo.CCDetail      CCD WITH (NOLOCK) ON CCD.CCDetailKey = DP.CCdetailkey
        JOIN dbo.CCSerialNoLog CSL WITH (NOLOCK) ON CSL.CCDetailKey = CCD.CCdetailkey
       WHERE CCD.CCKey = @c_StockTakeKey
         AND CCD.[Status] = '9'
         AND CSL.[Status] = '0'
         AND ISNULL(CCD.CCDetailkey,'')<>''
       ORDER BY 1

      OPEN CUR_CCSNLOG

      WHILE @n_continue = 1 OR @n_continue = 2
      BEGIN
         FETCH NEXT FROM CUR_CCSNLOG INTO @n_CountSerialKey

         IF @@FETCH_STATUS <> 0
            BREAK

         UPDATE dbo.CCSerialNoLog WITH (ROWLOCK)
            SET [Status] = '9'
              , EditWho = dbo.fnc_GetUserName()
              , EditDate= dbo.fnc_GetDate()
          WHERE CountSerialKey = @n_CountSerialKey
            AND CCKey    = @c_StockTakeKey
            AND [Status] = '0'

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @n_err = 67111
            SET @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err)
                          + ': Update Failed On CCSerialNoLog. (' + @c_SP_Name + ')'
            BREAK
         END
      END
      CLOSE CUR_CCSNLOG
      DEALLOCATE CUR_CCSNLOG
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      EXEC isp_PostCCAdjustment_Wrapper
           @c_StockTakeKey = @c_StockTakeKey
         , @c_SourceType   = @c_SP_Name
         , @b_Success      = @b_Success OUTPUT
         , @n_Err          = @n_err     OUTPUT
         , @c_Errmsg       = @c_errmsg  OUTPUT
   END

   IF (@n_continue = 1 OR @n_continue = 2)
      AND @n_IsRDT = 1 AND EXISTS(SELECT TOP 1 1 FROM @tAdjustment) AND @nRDTNotAutoFinalizeAdj = 0
   BEGIN
      WHILE EXISTS(SELECT TOP 1 1 FROM @tAdjustment)
      BEGIN
         SET @c_AdjustmentKey = ''
         SELECT TOP 1 @c_AdjustmentKey = AdjustmentKey
           FROM @tAdjustment
          WHERE ISNULL(AdjustmentKey,'') <> ''
          ORDER BY 1

         IF ISNULL(@c_AdjustmentKey,'') = ''
            BREAK

         SET @n_err = 0
         EXEC isp_FinalizeADJ
              @c_AdjustmentKey
            , @b_Success  OUTPUT
            , @n_err      OUTPUT
            , @c_errmsg   OUTPUT

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            BREAK
         END

         IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.ADJUSTMENTDETAIL (NOLOCK) WHERE Adjustmentkey = @c_AdjustmentKey AND FinalizedFlag = 'N')
         BEGIN
            UPDATE dbo.ADJUSTMENT WITH (ROWLOCK)
               SET FinalizedFlag = 'Y'
             WHERE AdjustmentKey = @c_AdjustmentKey

            SET @n_err = @@error
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 67112
               SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(10), @n_err) + ': Update Failed On Adjustment Table. (' + @c_SP_Name + ')' + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
               BREAK
            END
         END

         DELETE @tAdjustment WHERE AdjustmentKey = @c_AdjustmentKey
      END
   END

   EXIT_SP:

   IF @n_continue = 3
   BEGIN
      SET @b_Success = 0
      IF @c_errmsg <> ''
         RAISERROR(@c_errmsg, 16, 1) WITH SETERROR
   END
END
GO
GRANT EXECUTE ON ispGenCCAdjustmentPost_SP01 TO NSQL
GO
