SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ispPRADJGP                                                  */
/* Creation Date: 2026-06-02                                            */
/* Copyright: Maersk                                                    */
/* Written by: Michael                                                  */
/*                                                                      */
/* Purpose: Generic SP for PreFinalizeADJSP                             */
/*                                                                      */
/* Called By: ispPreFinalizeADJWrapper                                  */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 2026-06-02   Michael   1.0 UWP-56444-PreFinalizeADJSP GenericSP(ML01)*/
/************************************************************************/
CREATE OR ALTER PROC ispPRADJGP
  @c_AdjustmentKey  NVARCHAR(10)
, @b_Success        INT = 1  OUTPUT
, @n_err            INT = 0  OUTPUT
, @c_errmsg         NVARCHAR(215) = '' OUTPUT
AS
BEGIN
/* STORERCONFIG
   .ConfigKey = 'PreFinalizeADJSP'
   .SValue    = 'ispPRADJGP'
   .OPTION5   = '@c_ExtPreFinalizeADJSP=xxx'  -- Calling another PreFinalizeADJSP if setup

   CODELKUP
   .ListName  =  'PREADJCFG'
   .Code2     =  'ispPRADJGP'
   .Storerkey =  <Storerkey>

   Code          Description       Short(Enable)   Long(Fieldname)   Notes(SQL)
   SEL_JOIN      Select JOIN       Y/N                               <Join Clause>
   SEL_WHERE     Select WHERE      Y/N                               <Where Clause>
   SEL_SORT      Select ORDER BY   Y/N                               <Order By Clause>
   HDR_JOIN      Header JOIN       Y/N                               <Join Clause>
   HDR_WHERE     Header WHERE      Y/N                               <Where Clause>
   HDR_SORT      Header ORDER BY   Y/N                               <Order By Clause>
   DTL_JOIN      Detail JOIN       Y/N                               <Join Clause>
   DTL_WHERE     Detail WHERE      Y/N                               <Where Clause>
   DTL_SORT      Detail ORDER BY   Y/N                               <Order By Clause>
   UPD_HDR_999   Update Header     Y/N             Field Name        <SQL Expresssion>
   UPD_DTL_999   Update Detail     Y/N             Field Name        <SQL Expresssion>
   UPD_VAR_999   Update Variable   Y/N             Var Name          <SQL Expresssion>

   (For Code UPD_XXX_999 means allow mulit records for mulit Fields update)
*/
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt        INT = @@TRANCOUNT
         , @n_Continue         INT = 1
         , @b_debug            INT = 0
         , @c_Option5          NVARCHAR(MAX) = ''
         , @c_SP_Name          NVARCHAR(128) = 'ispPRADJGP'
         , @c_AdjKey           NVARCHAR(10)
         , @c_AdjLineNumber    NVARCHAR(5)
         , @c_x_Storerkey      NVARCHAR(15)  = ''
         , @c_x_Facility       NVARCHAR(15)  = ''
         , @c_SEL_JOIN         NVARCHAR(MAX) = ''
         , @c_SEL_WHERE        NVARCHAR(MAX) = ''
         , @c_SEL_SORT         NVARCHAR(MAX) = ''
         , @c_HDR_JOIN         NVARCHAR(MAX) = ''
         , @c_HDR_WHERE        NVARCHAR(MAX) = ''
         , @c_HDR_SORT         NVARCHAR(MAX) = ''
         , @c_DTL_JOIN         NVARCHAR(MAX) = ''
         , @c_DTL_WHERE        NVARCHAR(MAX) = ''
         , @c_DTL_SORT         NVARCHAR(MAX) = ''
         , @c_ListName         NVARCHAR(10)  = 'PREADJCFG'
         , @c_Code             NVARCHAR(50)
         , @c_Long             NVARCHAR(500)
         , @c_Notes            NVARCHAR(MAX)
         , @c_UDF01            NVARCHAR(60)
         , @c_SQL              NVARCHAR(MAX)
         , @c_SQL2             NVARCHAR(MAX)
         , @c_SQLParm          NVARCHAR(MAX)
         , @c_SQLParm_HDR      NVARCHAR(MAX)
         , @c_SQLParm_DTL      NVARCHAR(MAX)
         , @c_SQLParm_VAR      NVARCHAR(MAX)
         , @c_SQLParm_UPDHDR   NVARCHAR(MAX)
         , @c_SQLParm_UPDDTL   NVARCHAR(MAX)
         , @c_HDR_UPD_Fields   NVARCHAR(MAX)
         , @c_DTL_UPD_Fields   NVARCHAR(MAX)
         , @c_ExtPreFinalizeADJSP NVARCHAR(MAX) = ''

   DECLARE @H_CustomerRefNo    NVARCHAR(10)
         , @H_AdjustmentType   NVARCHAR(3)
         , @H_Remarks          NVARCHAR(200)
         , @H_FromToWhse       NVARCHAR(6)
         , @H_PrintFlag        NVARCHAR(1)
         , @H_UserDefine01     NVARCHAR(20)
         , @H_UserDefine02     NVARCHAR(20)
         , @H_UserDefine03     NVARCHAR(20)
         , @H_UserDefine04     NVARCHAR(20)
         , @H_UserDefine05     NVARCHAR(20)
         , @H_UserDefine06     DATETIME
         , @H_UserDefine07     DATETIME
         , @H_UserDefine08     NVARCHAR(10)
         , @H_UserDefine09     NVARCHAR(10)
         , @H_UserDefine10     NVARCHAR(10)

   DECLARE @H_AdjustmentKey    NVARCHAR(10)
         , @H_EffectiveDate    DATETIME
         , @H_Storerkey        NVARCHAR(15)
         , @H_AddDate          DATETIME
         , @H_AddWho           NVARCHAR(128)
         , @H_EditDate         DATETIME
         , @H_EditWho          NVARCHAR(128)
         , @H_Facility         NVARCHAR(15)
         , @H_FinalizedFlag    NVARCHAR(1)
         , @H_DocType          NVARCHAR(1)
         , @H_Temp01           NVARCHAR(MAX)
         , @H_Temp02           NVARCHAR(MAX)
         , @H_Temp03           NVARCHAR(MAX)
         , @H_Temp04           NVARCHAR(MAX)
         , @H_Temp05           NVARCHAR(MAX)
         , @H_Temp06           NVARCHAR(MAX)
         , @H_Temp07           NVARCHAR(MAX)
         , @H_Temp08           NVARCHAR(MAX)
         , @H_Temp09           NVARCHAR(MAX)
         , @H_Temp10           NVARCHAR(MAX)

   DECLARE @D_Loc              NVARCHAR(10)
         , @D_Lot              NVARCHAR(10)
         , @D_Id               NVARCHAR(18)
         , @D_ReasonCode       NVARCHAR(10)
         , @D_Qty              INT
         , @D_UserDefine01     NVARCHAR(20)
         , @D_UserDefine02     NVARCHAR(20)
         , @D_UserDefine03     NVARCHAR(20)
         , @D_UserDefine04     NVARCHAR(20)
         , @D_UserDefine05     NVARCHAR(20)
         , @D_UserDefine06     DATETIME
         , @D_UserDefine07     DATETIME
         , @D_UserDefine08     NVARCHAR(10)
         , @D_UserDefine09     NVARCHAR(10)
         , @D_UserDefine10     NVARCHAR(10)
         , @D_Lottable01       NVARCHAR(18)
         , @D_Lottable02       NVARCHAR(18)
         , @D_Lottable03       NVARCHAR(18)
         , @D_Lottable04       DATETIME
         , @D_Lottable05       DATETIME
         , @D_UCCNo            NVARCHAR(20)
         , @D_Lottable06       NVARCHAR(30)
         , @D_Lottable07       NVARCHAR(30)
         , @D_Lottable08       NVARCHAR(30)
         , @D_Lottable09       NVARCHAR(30)
         , @D_Lottable10       NVARCHAR(30)
         , @D_Lottable11       NVARCHAR(30)
         , @D_Lottable12       NVARCHAR(30)
         , @D_Lottable13       DATETIME
         , @D_Lottable14       DATETIME
         , @D_Lottable15       DATETIME
         , @D_Channel          NVARCHAR(20)
         , @D_SerialNo         NVARCHAR(50)

   DECLARE @D_AdjustmentKey    NVARCHAR(10)
         , @D_AdjustmentLineNumber NVARCHAR(5)
         , @D_StorerKey        NVARCHAR(15)
         , @D_Sku              NVARCHAR(20)
         , @D_UOM              NVARCHAR(10)
         , @D_PackKey          NVARCHAR(10)
         , @D_CaseCnt          INT
         , @D_InnerPack        INT
         , @D_Pallet           INT
         , @D_Cube             FLOAT
         , @D_GrossWgt         FLOAT
         , @D_NetWgt           FLOAT
         , @D_OtherUnit1       FLOAT
         , @D_OtherUnit2       FLOAT
         , @D_ItrnKey          NVARCHAR(10)
         , @D_EffectiveDate    DATETIME
         , @D_AddDate          DATETIME
         , @D_AddWho           NVARCHAR(128)
         , @D_EditDate         DATETIME
         , @D_EditWho          NVARCHAR(128)
         , @D_FinalizedFlag    NVARCHAR(1)
         , @D_Channel_ID       BIGINT
         , @D_PalletType       NVARCHAR(10)
         , @D_Temp01           NVARCHAR(MAX)
         , @D_Temp02           NVARCHAR(MAX)
         , @D_Temp03           NVARCHAR(MAX)
         , @D_Temp04           NVARCHAR(MAX)
         , @D_Temp05           NVARCHAR(MAX)
         , @D_Temp06           NVARCHAR(MAX)
         , @D_Temp07           NVARCHAR(MAX)
         , @D_Temp08           NVARCHAR(MAX)
         , @D_Temp09           NVARCHAR(MAX)
         , @D_Temp10           NVARCHAR(MAX)


   SET @n_err      = 0
   SET @c_errmsg   = ''

   SELECT @c_x_Storerkey = Storerkey
        , @c_x_Facility  = Facility
   FROM ADJUSTMENT (NOLOCK)
   WHERE AdjustmentKey = @c_AdjustmentKey

   -- Extended PreFinalizeADJSP
   SELECT @c_Option5 = SC.Option5
   FROM dbo.fnc_GetRight2(@c_x_Facility, @c_x_Storerkey, '', 'PreFinalizeADJSP') AS SC
   WHERE Authority='ispPRADJGP'

   SELECT @c_ExtPreFinalizeADJSP = dbo.fnc_GetParamValueFromString ('@c_ExtPreFinalizeADJSP', @c_option5, '')

   IF ISNULL(@c_ExtPreFinalizeADJSP,'') NOT IN ('', @c_SP_Name) AND
      EXISTS (SELECT 1 FROM sys.objects WHERE name = @c_ExtPreFinalizeADJSP AND [type] = 'P')
   BEGIN
      SET @c_SQL = N'EXECUTE ' + @c_ExtPreFinalizeADJSP
        + ' @c_AdjustmentKey = @c_AdjustmentKey'
        +', @b_Success  = @b_Success OUTPUT'
        +', @n_Err      = @n_Err     OUTPUT'
        +', @c_ErrMsg   = @c_ErrMsg  OUTPUT'

      SET @c_SQLParm =
          N'@c_AdjustmentKey  NVARCHAR(10)'
        +', @b_Success INT OUTPUT'
        +', @n_Err     INT OUTPUT'
        +', @c_ErrMsg  NVARCHAR(250) OUTPUT '

      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm
         , @c_AdjustmentKey
         , @b_Success OUTPUT
         , @n_Err     OUTPUT
         , @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
         GOTO QUIT_SP
      END
   END

   -- Check existing of PREADJCFG setup
   IF NOT EXISTS(SELECT TOP 1 1
      FROM dbo.CODELKUP WITH(NOLOCK)
      WHERE ListName = @c_ListName
         AND Code2 = @c_SP_Name
         AND Storerkey = @c_x_Storerkey
         AND LEFT(Code,7) IN ('UPD_HDR', 'UPD_DTL', 'UPD_VAR')
         AND Short = 'Y'
         AND ISNULL(Long,'') <> ''
         AND ISNULL(Notes,'') <> '')
      GOTO STEP_2

   -- Get PREADJCFG setup
   SELECT @c_SEL_JOIN  = ISNULL(TRIM(MAX(CASE WHEN Code = 'SEL_JOIN'  AND Short = 'Y' THEN Notes END)),'')
        , @c_SEL_WHERE = ISNULL(TRIM(MAX(CASE WHEN Code = 'SEL_WHERE' AND Short = 'Y' THEN Notes END)),'')
        , @c_SEL_SORT  = ISNULL(TRIM(MAX(CASE WHEN Code = 'SEL_SORT'  AND Short = 'Y' THEN Notes END)),'')
        , @c_HDR_JOIN  = ISNULL(TRIM(MAX(CASE WHEN Code = 'HDR_JOIN'  AND Short = 'Y' THEN Notes END)),'')
        , @c_HDR_WHERE = ISNULL(TRIM(MAX(CASE WHEN Code = 'HDR_WHERE' AND Short = 'Y' THEN Notes END)),'')
        , @c_HDR_SORT  = ISNULL(TRIM(MAX(CASE WHEN Code = 'HDR_SORT'  AND Short = 'Y' THEN Notes END)),'')
        , @c_DTL_JOIN  = ISNULL(TRIM(MAX(CASE WHEN Code = 'DTL_JOIN'  AND Short = 'Y' THEN Notes END)),'')
        , @c_DTL_WHERE = ISNULL(TRIM(MAX(CASE WHEN Code = 'DTL_WHERE' AND Short = 'Y' THEN Notes END)),'')
        , @c_DTL_SORT  = ISNULL(TRIM(MAX(CASE WHEN Code = 'DTL_SORT'  AND Short = 'Y' THEN Notes END)),'')
        , @b_debug     = ISNULL(MAX(CASE WHEN Code = 'Debug' AND Short IN ('1','Y') THEN 1 END),0)
     FROM dbo.CODELKUP WITH(NOLOCK)
    WHERE ListName = @c_ListName
      AND Code2 = @c_SP_Name
      AND Storerkey = @c_x_Storerkey

   IF LEFT(@c_SEL_WHERE,4) = 'AND '
      SET @c_SEL_WHERE = SUBSTRING(@c_SEL_WHERE, 5, LEN(@c_SEL_WHERE))

   IF LEFT(@c_HDR_WHERE,4) = 'AND '
      SET @c_HDR_WHERE = SUBSTRING(@c_HDR_WHERE, 5, LEN(@c_HDR_WHERE))

   IF LEFT(@c_DTL_WHERE,4) = 'AND '
      SET @c_DTL_WHERE = SUBSTRING(@c_DTL_WHERE, 5, LEN(@c_DTL_WHERE))

   IF OBJECT_ID('tempdb..#TMP_ADJ_LINE') IS NOT NULL
      DROP TABLE #TMP_ADJ_LINE

   CREATE TABLE #TMP_ADJ_LINE (
      Row_ID               INT IDENTITY(1,1)
    , AdjustmentKey        NVARCHAR(10) NOT NULL DEFAULT('')
    , AdjustmentLineNumber NVARCHAR(5)  NOT NULL DEFAULT('')
   )

   ----------------------------------------------
   -- Select Adjustment Detail into Temp Table --
   ----------------------------------------------
   SET @c_SQL =
      N'INSERT INTO #TMP_ADJ_LINE (AdjustmentKey, AdjustmentLineNumber)'
     +' SELECT ADJUSTMENTDETAIL.AdjustmentKey'
     +      ', ADJUSTMENTDETAIL.AdjustmentLineNumber'
     +' FROM ADJUSTMENT WITH(NOLOCK)'
     +' JOIN ADJUSTMENTDETAIL WITH(NOLOCK) ON ADJUSTMENT.AdjustmentKey=ADJUSTMENTDETAIL.AdjustmentKey'

   IF ISNULL(@c_SEL_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_SEL_JOIN

   SET @c_SQL = @c_SQL
     +' WHERE ADJUSTMENT.AdjustmentKey = N''' + ISNULL(REPLACE(@c_AdjustmentKey,'''',''''''),'') + ''''
     +  ' AND ISNULL(ADJUSTMENT.FinalizedFlag,'''') <> ''Y'''
     +  ' AND ISNULL(ADJUSTMENTDETAIL.FinalizedFlag,'''') <> ''Y'''

   IF ISNULL(@c_SEL_WHERE,'') <> ''
      SET @c_SQL = @c_SQL
        + ' AND (' + @c_SEL_WHERE + ')'

   IF ISNULL(@c_SEL_SORT,'') <> ''
      SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_SEL_SORT
   ELSE
      SET @c_SQL = @c_SQL + ' ORDER BY 1, 2'

   IF @b_debug = 1
      SELECT @c_SQL AS [Insert Temp Table]

   BEGIN TRY
      EXEC (@c_SQL)
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err  = 61071
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Temp Table Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
      GOTO QUIT_SP
   END CATCH

   IF NOT EXISTS(SELECT TOP 1 1 FROM #TMP_ADJ_LINE)
      GOTO STEP_2


   SET @c_HDR_UPD_Fields =
      ',CustomerRefNo,AdjustmentType,Remarks,FromToWhse,PrintFlag,UserDefine01,UserDefine02,UserDefine03,UserDefine04,UserDefine05,'
     + 'UserDefine06,UserDefine07,UserDefine08,UserDefine09,UserDefine10,'

   SET @c_DTL_UPD_Fields =
      ',Loc,Lot,Id,ReasonCode,Qty,UserDefine01,UserDefine02,UserDefine03,UserDefine04,UserDefine05,'
     + 'UserDefine06,UserDefine07,UserDefine08,UserDefine09,UserDefine10,Lottable01,Lottable02,Lottable03,Lottable04,Lottable05,'
     + 'UCCNo,Lottable06,Lottable07,Lottable08,Lottable09,Lottable10,Lottable11,Lottable12,Lottable13,Lottable14,'
     + 'Lottable15,Channel,SerialNo,'

   SET @c_SQLParm_HDR
     =  '@H_CustomerRefNo  NVARCHAR(10)  OUTPUT, @H_AdjustmentType NVARCHAR(3)   OUTPUT, @H_Remarks        NVARCHAR(200) OUTPUT'
     +', @H_FromToWhse     NVARCHAR(6)   OUTPUT, @H_PrintFlag      NVARCHAR(1)   OUTPUT, @H_UserDefine01   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine02   NVARCHAR(20)  OUTPUT, @H_UserDefine03   NVARCHAR(20)  OUTPUT, @H_UserDefine04   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine05   NVARCHAR(20)  OUTPUT, @H_UserDefine06   DATETIME      OUTPUT, @H_UserDefine07   DATETIME      OUTPUT'
     +', @H_UserDefine08   NVARCHAR(10)  OUTPUT, @H_UserDefine09   NVARCHAR(10)  OUTPUT, @H_UserDefine10   NVARCHAR(10)  OUTPUT'
     +', @H_AdjustmentKey  NVARCHAR(10)  OUTPUT, @H_EffectiveDate  DATETIME      OUTPUT, @H_Storerkey      NVARCHAR(15)  OUTPUT'
     +', @H_AddDate        DATETIME      OUTPUT, @H_AddWho         NVARCHAR(128) OUTPUT, @H_EditDate       DATETIME      OUTPUT'
     +', @H_EditWho        NVARCHAR(128) OUTPUT, @H_Facility       NVARCHAR(15)  OUTPUT, @H_FinalizedFlag  NVARCHAR(1)   OUTPUT'
     +', @H_DocType        NVARCHAR(1)   OUTPUT'
     +', @H_Temp01         NVARCHAR(MAX) OUTPUT, @H_Temp02         NVARCHAR(MAX) OUTPUT, @H_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp04         NVARCHAR(MAX) OUTPUT, @H_Temp05         NVARCHAR(MAX) OUTPUT, @H_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp07         NVARCHAR(MAX) OUTPUT, @H_Temp08         NVARCHAR(MAX) OUTPUT, @H_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp10         NVARCHAR(MAX) OUTPUT'

   SET @c_SQLParm_DTL
     =  '@D_Loc            NVARCHAR(10)  OUTPUT, @D_Lot            NVARCHAR(10)  OUTPUT, @D_Id             NVARCHAR(18)  OUTPUT'
     +', @D_ReasonCode     NVARCHAR(10)  OUTPUT, @D_Qty            INT           OUTPUT, @D_UserDefine01   NVARCHAR(20)  OUTPUT'
     +', @D_UserDefine02   NVARCHAR(20)  OUTPUT, @D_UserDefine03   NVARCHAR(20)  OUTPUT, @D_UserDefine04   NVARCHAR(20)  OUTPUT'
     +', @D_UserDefine05   NVARCHAR(20)  OUTPUT, @D_UserDefine06   DATETIME      OUTPUT, @D_UserDefine07   DATETIME      OUTPUT'
     +', @D_UserDefine08   NVARCHAR(10)  OUTPUT, @D_UserDefine09   NVARCHAR(10)  OUTPUT, @D_UserDefine10   NVARCHAR(10)  OUTPUT'
     +', @D_Lottable01     NVARCHAR(18)  OUTPUT, @D_Lottable02     NVARCHAR(18)  OUTPUT, @D_Lottable03     NVARCHAR(18)  OUTPUT'
     +', @D_Lottable04     DATETIME      OUTPUT, @D_Lottable05     DATETIME      OUTPUT, @D_UCCNo          NVARCHAR(20)  OUTPUT'
     +', @D_Lottable06     NVARCHAR(30)  OUTPUT, @D_Lottable07     NVARCHAR(30)  OUTPUT, @D_Lottable08     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable09     NVARCHAR(30)  OUTPUT, @D_Lottable10     NVARCHAR(30)  OUTPUT, @D_Lottable11     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable12     NVARCHAR(30)  OUTPUT, @D_Lottable13     DATETIME      OUTPUT, @D_Lottable14     DATETIME      OUTPUT'
     +', @D_Lottable15     DATETIME      OUTPUT, @D_Channel        NVARCHAR(20)  OUTPUT, @D_SerialNo       NVARCHAR(50)  OUTPUT'
     +', @D_AdjustmentKey  NVARCHAR(10)  OUTPUT, @D_AdjustmentLineNumber NVARCHAR(5) OUTPUT, @D_StorerKey  NVARCHAR(15)  OUTPUT'
     +', @D_Sku            NVARCHAR(20)  OUTPUT, @D_UOM            NVARCHAR(10)  OUTPUT, @D_PackKey        NVARCHAR(10)  OUTPUT'
     +', @D_CaseCnt        INT           OUTPUT, @D_InnerPack      INT           OUTPUT, @D_Pallet         INT           OUTPUT'
     +', @D_Cube           FLOAT         OUTPUT, @D_GrossWgt       FLOAT         OUTPUT, @D_NetWgt         FLOAT         OUTPUT'
     +', @D_OtherUnit1     FLOAT         OUTPUT, @D_OtherUnit2     FLOAT         OUTPUT, @D_ItrnKey        NVARCHAR(10)  OUTPUT'
     +', @D_EffectiveDate  DATETIME      OUTPUT, @D_AddDate        DATETIME      OUTPUT, @D_AddWho         NVARCHAR(128) OUTPUT'
     +', @D_EditDate       DATETIME      OUTPUT, @D_EditWho        NVARCHAR(128) OUTPUT, @D_FinalizedFlag  NVARCHAR(1)   OUTPUT'
     +', @D_Channel_ID     BIGINT        OUTPUT, @D_PalletType     NVARCHAR(10)  OUTPUT'
     +', @D_Temp01         NVARCHAR(MAX) OUTPUT, @D_Temp02         NVARCHAR(MAX) OUTPUT, @D_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp04         NVARCHAR(MAX) OUTPUT, @D_Temp05         NVARCHAR(MAX) OUTPUT, @D_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp07         NVARCHAR(MAX) OUTPUT, @D_Temp08         NVARCHAR(MAX) OUTPUT, @D_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp10         NVARCHAR(MAX) OUTPUT'

   SET @c_SQLParm_VAR
     =  '@H_CustomerRefNo  NVARCHAR(10)  OUTPUT, @H_AdjustmentType NVARCHAR(3)   OUTPUT, @H_Remarks        NVARCHAR(200) OUTPUT'
     +', @H_FromToWhse     NVARCHAR(6)   OUTPUT, @H_PrintFlag      NVARCHAR(1)   OUTPUT, @H_UserDefine01   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine02   NVARCHAR(20)  OUTPUT, @H_UserDefine03   NVARCHAR(20)  OUTPUT, @H_UserDefine04   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine05   NVARCHAR(20)  OUTPUT, @H_UserDefine06   DATETIME      OUTPUT, @H_UserDefine07   DATETIME      OUTPUT'
     +', @H_UserDefine08   NVARCHAR(10)  OUTPUT, @H_UserDefine09   NVARCHAR(10)  OUTPUT, @H_UserDefine10   NVARCHAR(10)  OUTPUT'
     +', @H_AdjustmentKey  NVARCHAR(10)  OUTPUT, @H_EffectiveDate  DATETIME      OUTPUT, @H_Storerkey      NVARCHAR(15)  OUTPUT'
     +', @H_AddDate        DATETIME      OUTPUT, @H_AddWho         NVARCHAR(128) OUTPUT, @H_EditDate       DATETIME      OUTPUT'
     +', @H_EditWho        NVARCHAR(128) OUTPUT, @H_Facility       NVARCHAR(15)  OUTPUT, @H_FinalizedFlag  NVARCHAR(1)   OUTPUT'
     +', @H_DocType        NVARCHAR(1)   OUTPUT'
     +', @D_Loc            NVARCHAR(10)  OUTPUT, @D_Lot            NVARCHAR(10)  OUTPUT, @D_Id             NVARCHAR(18)  OUTPUT'
     +', @D_ReasonCode     NVARCHAR(10)  OUTPUT, @D_Qty            INT           OUTPUT, @D_UserDefine01   NVARCHAR(20)  OUTPUT'
     +', @D_UserDefine02   NVARCHAR(20)  OUTPUT, @D_UserDefine03   NVARCHAR(20)  OUTPUT, @D_UserDefine04   NVARCHAR(20)  OUTPUT'
     +', @D_UserDefine05   NVARCHAR(20)  OUTPUT, @D_UserDefine06   DATETIME      OUTPUT, @D_UserDefine07   DATETIME      OUTPUT'
     +', @D_UserDefine08   NVARCHAR(10)  OUTPUT, @D_UserDefine09   NVARCHAR(10)  OUTPUT, @D_UserDefine10   NVARCHAR(10)  OUTPUT'
     +', @D_Lottable01     NVARCHAR(18)  OUTPUT, @D_Lottable02     NVARCHAR(18)  OUTPUT, @D_Lottable03     NVARCHAR(18)  OUTPUT'
     +', @D_Lottable04     DATETIME      OUTPUT, @D_Lottable05     DATETIME      OUTPUT, @D_UCCNo          NVARCHAR(20)  OUTPUT'
     +', @D_Lottable06     NVARCHAR(30)  OUTPUT, @D_Lottable07     NVARCHAR(30)  OUTPUT, @D_Lottable08     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable09     NVARCHAR(30)  OUTPUT, @D_Lottable10     NVARCHAR(30)  OUTPUT, @D_Lottable11     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable12     NVARCHAR(30)  OUTPUT, @D_Lottable13     DATETIME      OUTPUT, @D_Lottable14     DATETIME      OUTPUT'
     +', @D_Lottable15     DATETIME      OUTPUT, @D_Channel        NVARCHAR(20)  OUTPUT, @D_SerialNo       NVARCHAR(50)  OUTPUT'
     +', @D_AdjustmentKey  NVARCHAR(10)  OUTPUT, @D_AdjustmentLineNumber NVARCHAR(5) OUTPUT, @D_StorerKey  NVARCHAR(15)  OUTPUT'
     +', @D_Sku            NVARCHAR(20)  OUTPUT, @D_UOM            NVARCHAR(10)  OUTPUT, @D_PackKey        NVARCHAR(10)  OUTPUT'
     +', @D_CaseCnt        INT           OUTPUT, @D_InnerPack      INT           OUTPUT, @D_Pallet         INT           OUTPUT'
     +', @D_Cube           FLOAT         OUTPUT, @D_GrossWgt       FLOAT         OUTPUT, @D_NetWgt         FLOAT         OUTPUT'
     +', @D_OtherUnit1     FLOAT         OUTPUT, @D_OtherUnit2     FLOAT         OUTPUT, @D_ItrnKey        NVARCHAR(10)  OUTPUT'
     +', @D_EffectiveDate  DATETIME      OUTPUT, @D_AddDate        DATETIME      OUTPUT, @D_AddWho         NVARCHAR(128) OUTPUT'
     +', @D_EditDate       DATETIME      OUTPUT, @D_EditWho        NVARCHAR(128) OUTPUT, @D_FinalizedFlag  NVARCHAR(1)   OUTPUT'
     +', @D_Channel_ID     BIGINT        OUTPUT, @D_PalletType     NVARCHAR(10)  OUTPUT'
     +', @H_Temp01         NVARCHAR(MAX) OUTPUT, @H_Temp02         NVARCHAR(MAX) OUTPUT, @H_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp04         NVARCHAR(MAX) OUTPUT, @H_Temp05         NVARCHAR(MAX) OUTPUT, @H_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp07         NVARCHAR(MAX) OUTPUT, @H_Temp08         NVARCHAR(MAX) OUTPUT, @H_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp10         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp01         NVARCHAR(MAX) OUTPUT, @D_Temp02         NVARCHAR(MAX) OUTPUT, @D_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp04         NVARCHAR(MAX) OUTPUT, @D_Temp05         NVARCHAR(MAX) OUTPUT, @D_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp07         NVARCHAR(MAX) OUTPUT, @D_Temp08         NVARCHAR(MAX) OUTPUT, @D_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp10         NVARCHAR(MAX) OUTPUT'


   SET @c_SQLParm_UPDDTL
     =  '@D_Loc           NVARCHAR(10), @D_Lot            NVARCHAR(10), @D_Id           NVARCHAR(18)'
     +', @D_ReasonCode    NVARCHAR(10), @D_Qty            INT         , @D_UserDefine01 NVARCHAR(20)'
     +', @D_UserDefine02  NVARCHAR(20), @D_UserDefine03   NVARCHAR(20), @D_UserDefine04 NVARCHAR(20)'
     +', @D_UserDefine05  NVARCHAR(20), @D_UserDefine06   DATETIME    , @D_UserDefine07 DATETIME'
     +', @D_UserDefine08  NVARCHAR(10), @D_UserDefine09   NVARCHAR(10), @D_UserDefine10 NVARCHAR(10)'
     +', @D_Lottable01    NVARCHAR(18), @D_Lottable02     NVARCHAR(18), @D_Lottable03   NVARCHAR(18)'
     +', @D_Lottable04    DATETIME    , @D_Lottable05     DATETIME    , @D_UCCNo        NVARCHAR(20)'
     +', @D_Lottable06    NVARCHAR(30), @D_Lottable07     NVARCHAR(30), @D_Lottable08   NVARCHAR(30)'
     +', @D_Lottable09    NVARCHAR(30), @D_Lottable10     NVARCHAR(30), @D_Lottable11   NVARCHAR(30)'
     +', @D_Lottable12    NVARCHAR(30), @D_Lottable13     DATETIME    , @D_Lottable14   DATETIME'
     +', @D_Lottable15    DATETIME    , @D_Channel        NVARCHAR(20), @D_SerialNo     NVARCHAR(50)'

   SET @c_SQLParm_UPDHDR
     =  '@H_CustomerRefNo NVARCHAR(10), @H_AdjustmentType NVARCHAR(3) , @H_Remarks      NVARCHAR(200)'
     +', @H_FromToWhse    NVARCHAR(6) , @H_PrintFlag      NVARCHAR(1) , @H_UserDefine01 NVARCHAR(20)'
     +', @H_UserDefine02  NVARCHAR(20), @H_UserDefine03   NVARCHAR(20), @H_UserDefine04 NVARCHAR(20)'
     +', @H_UserDefine05  NVARCHAR(20), @H_UserDefine06   DATETIME    , @H_UserDefine07 DATETIME'
     +', @H_UserDefine08  NVARCHAR(10), @H_UserDefine09   NVARCHAR(10), @H_UserDefine10 NVARCHAR(10)'

   --------------------------
   -- Select Header Fields --
   --------------------------
   SET @c_SQL = 'SELECT TOP 1'
     + ' @H_CustomerRefNo  = <<ADJUSTMENT.CustomerRefNo>>'
     +', @H_AdjustmentType = <<ADJUSTMENT.AdjustmentType>>'
     +', @H_Remarks        = <<ADJUSTMENT.Remarks>>'
     +', @H_FromToWhse     = <<ADJUSTMENT.FromToWhse>>'
     +', @H_PrintFlag      = <<ADJUSTMENT.PrintFlag>>'
     +', @H_UserDefine01   = <<ADJUSTMENT.UserDefine01>>'
     +', @H_UserDefine02   = <<ADJUSTMENT.UserDefine02>>'
     +', @H_UserDefine03   = <<ADJUSTMENT.UserDefine03>>'
     +', @H_UserDefine04   = <<ADJUSTMENT.UserDefine04>>'
     +', @H_UserDefine05   = <<ADJUSTMENT.UserDefine05>>'
     +', @H_UserDefine06   = <<ADJUSTMENT.UserDefine06>>'
     +', @H_UserDefine07   = <<ADJUSTMENT.UserDefine07>>'
     +', @H_UserDefine08   = <<ADJUSTMENT.UserDefine08>>'
     +', @H_UserDefine09   = <<ADJUSTMENT.UserDefine09>>'
     +', @H_UserDefine10   = <<ADJUSTMENT.UserDefine10>>'
     +', @H_AdjustmentKey  = <<ADJUSTMENT.AdjustmentKey>>'
     +', @H_EffectiveDate  = <<ADJUSTMENT.EffectiveDate>>'
     +', @H_Storerkey      = <<ADJUSTMENT.Storerkey>>'
     +', @H_AddDate        = <<ADJUSTMENT.AddDate>>'
     +', @H_AddWho         = <<ADJUSTMENT.AddWho>>'
     +', @H_EditDate       = <<ADJUSTMENT.EditDate>>'
     +', @H_EditWho        = <<ADJUSTMENT.EditWho>>'
     +', @H_Facility       = <<ADJUSTMENT.Facility>>'
     +', @H_FinalizedFlag  = <<ADJUSTMENT.FinalizedFlag>>'
     +', @H_DocType        = <<ADJUSTMENT.DocType>>'
     +', @H_Temp01         = <<@H_Temp01>>'
     +', @H_Temp02         = <<@H_Temp02>>'
     +', @H_Temp03         = <<@H_Temp03>>'
     +', @H_Temp04         = <<@H_Temp04>>'
     +', @H_Temp05         = <<@H_Temp05>>'
     +', @H_Temp06         = <<@H_Temp06>>'
     +', @H_Temp07         = <<@H_Temp07>>'
     +', @H_Temp08         = <<@H_Temp08>>'
     +', @H_Temp09         = <<@H_Temp09>>'
     +', @H_Temp10         = <<@H_Temp10>>'
     +' FROM ADJUSTMENT WITH(NOLOCK)'

   IF ISNULL(@c_HDR_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_HDR_JOIN

   SET @c_SQL = @c_SQL
     + ' WHERE ADJUSTMENT.AdjustmentKey = ''' + ISNULL(REPLACE(@c_AdjustmentKey,'''',''''''),'') + ''''

   IF ISNULL(@c_HDR_WHERE,'') <> ''
      SET @c_SQL = @c_SQL
        + ' AND (' + @c_HDR_WHERE + ')'

   IF ISNULL(@c_HDR_SORT,'') <> ''
      SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_HDR_SORT


   DECLARE CUR_CLK_UPD_HDR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT TRIM(Long), TRIM(Notes)
     FROM dbo.CODELKUP WITH(NOLOCK)
    WHERE ListName = @c_ListName
      AND Code2 = @c_SP_Name
      AND Storerkey = @c_x_Storerkey
      AND LEFT(Code,7) = 'UPD_HDR'
      AND Short = 'Y'
      AND ISNULL(Long,'') <> ''
      AND ISNULL(Notes,'') <> ''

   OPEN CUR_CLK_UPD_HDR

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_CLK_UPD_HDR
       INTO @c_Long, @c_Notes

      IF @@FETCH_STATUS<>0
         BREAK

      IF ISNULL(@c_Long,'') <> ''
      BEGIN
         SET @c_Long = '<<' + CASE WHEN @c_Long LIKE '@%' THEN '' ELSE 'ADJUSTMENT.' END + @c_Long + '>>'
         SET @c_SQL = REPLACE(@c_SQL, ISNULL(@c_Long,''), @c_Notes)
      END
   END
   CLOSE CUR_CLK_UPD_HDR
   DEALLOCATE CUR_CLK_UPD_HDR

   SET @c_SQL = REPLACE(REPLACE(@c_SQL, '<<', ''), '>>', '')

   SELECT @H_CustomerRefNo  = NULL, @H_AdjustmentType = NULL, @H_Remarks        = NULL
        , @H_FromToWhse     = NULL, @H_PrintFlag      = NULL, @H_UserDefine01   = NULL
        , @H_UserDefine02   = NULL, @H_UserDefine03   = NULL, @H_UserDefine04   = NULL
        , @H_UserDefine05   = NULL, @H_UserDefine06   = NULL, @H_UserDefine07   = NULL
        , @H_UserDefine08   = NULL, @H_UserDefine09   = NULL, @H_UserDefine10   = NULL
        , @H_AdjustmentKey  = NULL, @H_EffectiveDate  = NULL, @H_Storerkey      = NULL
        , @H_AddDate        = NULL, @H_AddWho         = NULL, @H_EditDate       = NULL
        , @H_EditWho        = NULL, @H_Facility       = NULL, @H_FinalizedFlag  = NULL
        , @H_DocType        = NULL
        , @H_Temp01         = NULL, @H_Temp02         = NULL, @H_Temp03         = NULL
        , @H_Temp04         = NULL, @H_Temp05         = NULL, @H_Temp06         = NULL
        , @H_Temp07         = NULL, @H_Temp08         = NULL, @H_Temp09         = NULL
        , @H_Temp10         = NULL

   IF @b_debug = 1
      SELECT @c_SQL AS [Select Header], @c_SQLParm_HDR AS SQLParam_HDR

   BEGIN TRY
      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_HDR
         , @H_CustomerRefNo   OUTPUT, @H_AdjustmentType  OUTPUT, @H_Remarks         OUTPUT
         , @H_FromToWhse      OUTPUT, @H_PrintFlag       OUTPUT, @H_UserDefine01    OUTPUT
         , @H_UserDefine02    OUTPUT, @H_UserDefine03    OUTPUT, @H_UserDefine04    OUTPUT
         , @H_UserDefine05    OUTPUT, @H_UserDefine06    OUTPUT, @H_UserDefine07    OUTPUT
         , @H_UserDefine08    OUTPUT, @H_UserDefine09    OUTPUT, @H_UserDefine10    OUTPUT
         , @H_AdjustmentKey   OUTPUT, @H_EffectiveDate   OUTPUT, @H_Storerkey       OUTPUT
         , @H_AddDate         OUTPUT, @H_AddWho          OUTPUT, @H_EditDate        OUTPUT
         , @H_EditWho         OUTPUT, @H_Facility        OUTPUT, @H_FinalizedFlag   OUTPUT
         , @H_DocType         OUTPUT
         , @H_Temp01          OUTPUT, @H_Temp02          OUTPUT, @H_Temp03          OUTPUT
         , @H_Temp04          OUTPUT, @H_Temp05          OUTPUT, @H_Temp06          OUTPUT
         , @H_Temp07          OUTPUT, @H_Temp08          OUTPUT, @H_Temp09          OUTPUT
         , @H_Temp10          OUTPUT
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err  = 61072
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Select Adjustment Header Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
      GOTO QUIT_SP
   END CATCH


   --------------------------
   -- Select Detail Fields --
   --------------------------
   DECLARE CUR_ADJ_DTL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT AdjustmentKey
        , AdjustmentLineNumber
   FROM #TMP_ADJ_LINE
   ORDER BY Row_ID

   OPEN CUR_ADJ_DTL

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_ADJ_DTL
       INTO @c_AdjKey, @c_AdjLineNumber

      IF @@FETCH_STATUS<>0
         BREAK

      SET @c_SQL = 'SELECT TOP 1'
        + ' @D_Loc          = <<ADJUSTMENTDETAIL.Loc>>'
        +', @D_Lot          = <<ADJUSTMENTDETAIL.Lot>>'
        +', @D_Id           = <<ADJUSTMENTDETAIL.Id>>'
        +', @D_ReasonCode   = <<ADJUSTMENTDETAIL.ReasonCode>>'
        +', @D_Qty          = <<ADJUSTMENTDETAIL.Qty>>'
        +', @D_UserDefine01 = <<ADJUSTMENTDETAIL.UserDefine01>>'
        +', @D_UserDefine02 = <<ADJUSTMENTDETAIL.UserDefine02>>'
        +', @D_UserDefine03 = <<ADJUSTMENTDETAIL.UserDefine03>>'
        +', @D_UserDefine04 = <<ADJUSTMENTDETAIL.UserDefine04>>'
        +', @D_UserDefine05 = <<ADJUSTMENTDETAIL.UserDefine05>>'
        +', @D_UserDefine06 = <<ADJUSTMENTDETAIL.UserDefine06>>'
        +', @D_UserDefine07 = <<ADJUSTMENTDETAIL.UserDefine07>>'
        +', @D_UserDefine08 = <<ADJUSTMENTDETAIL.UserDefine08>>'
        +', @D_UserDefine09 = <<ADJUSTMENTDETAIL.UserDefine09>>'
        +', @D_UserDefine10 = <<ADJUSTMENTDETAIL.UserDefine10>>'
        +', @D_Lottable01   = <<ADJUSTMENTDETAIL.Lottable01>>'
        +', @D_Lottable02   = <<ADJUSTMENTDETAIL.Lottable02>>'
        +', @D_Lottable03   = <<ADJUSTMENTDETAIL.Lottable03>>'
        +', @D_Lottable04   = <<ADJUSTMENTDETAIL.Lottable04>>'
        +', @D_Lottable05   = <<ADJUSTMENTDETAIL.Lottable05>>'
        +', @D_UCCNo        = <<ADJUSTMENTDETAIL.UCCNo>>'
        +', @D_Lottable06   = <<ADJUSTMENTDETAIL.Lottable06>>'
        +', @D_Lottable07   = <<ADJUSTMENTDETAIL.Lottable07>>'
        +', @D_Lottable08   = <<ADJUSTMENTDETAIL.Lottable08>>'
        +', @D_Lottable09   = <<ADJUSTMENTDETAIL.Lottable09>>'
        +', @D_Lottable10   = <<ADJUSTMENTDETAIL.Lottable10>>'
        +', @D_Lottable11   = <<ADJUSTMENTDETAIL.Lottable11>>'
        +', @D_Lottable12   = <<ADJUSTMENTDETAIL.Lottable12>>'
        +', @D_Lottable13   = <<ADJUSTMENTDETAIL.Lottable13>>'
        +', @D_Lottable14   = <<ADJUSTMENTDETAIL.Lottable14>>'
        +', @D_Lottable15   = <<ADJUSTMENTDETAIL.Lottable15>>'
        +', @D_Channel      = <<ADJUSTMENTDETAIL.Channel>>'
        +', @D_SerialNo     = <<ADJUSTMENTDETAIL.SerialNo>>'
        +', @D_AdjustmentKey= <<ADJUSTMENTDETAIL.AdjustmentKey>>'
        +', @D_AdjustmentLineNumber = <<ADJUSTMENTDETAIL.AdjustmentLineNumber>>'
        +', @D_StorerKey    = <<ADJUSTMENTDETAIL.StorerKey>>'
        +', @D_Sku          = <<ADJUSTMENTDETAIL.Sku>>'
        +', @D_UOM          = <<ADJUSTMENTDETAIL.UOM>>'
        +', @D_PackKey      = <<ADJUSTMENTDETAIL.PackKey>>'
        +', @D_CaseCnt      = <<ADJUSTMENTDETAIL.CaseCnt>>'
        +', @D_InnerPack    = <<ADJUSTMENTDETAIL.InnerPack>>'
        +', @D_Pallet       = <<ADJUSTMENTDETAIL.Pallet>>'
        +', @D_Cube         = <<ADJUSTMENTDETAIL.Cube>>'
        +', @D_GrossWgt     = <<ADJUSTMENTDETAIL.GrossWgt>>'
        +', @D_NetWgt       = <<ADJUSTMENTDETAIL.NetWgt>>'
        +', @D_OtherUnit1   = <<ADJUSTMENTDETAIL.OtherUnit1>>'
        +', @D_OtherUnit2   = <<ADJUSTMENTDETAIL.OtherUnit2>>'
        +', @D_ItrnKey      = <<ADJUSTMENTDETAIL.ItrnKey>>'
        +', @D_EffectiveDate= <<ADJUSTMENTDETAIL.EffectiveDate>>'
        +', @D_AddDate      = <<ADJUSTMENTDETAIL.AddDate>>'
        +', @D_AddWho       = <<ADJUSTMENTDETAIL.AddWho>>'
        +', @D_EditDate     = <<ADJUSTMENTDETAIL.EditDate>>'
        +', @D_EditWho      = <<ADJUSTMENTDETAIL.EditWho>>'
        +', @D_FinalizedFlag= <<ADJUSTMENTDETAIL.FinalizedFlag>>'
        +', @D_Channel_ID   = <<ADJUSTMENTDETAIL.Channel_ID>>'
        +', @D_PalletType   = <<ADJUSTMENTDETAIL.PalletType>>'
        +', @D_Temp01         = <<@D_Temp01>>'
        +', @D_Temp02         = <<@D_Temp02>>'
        +', @D_Temp03         = <<@D_Temp03>>'
        +', @D_Temp04         = <<@D_Temp04>>'
        +', @D_Temp05         = <<@D_Temp05>>'
        +', @D_Temp06         = <<@D_Temp06>>'
        +', @D_Temp07         = <<@D_Temp07>>'
        +', @D_Temp08         = <<@D_Temp08>>'
        +', @D_Temp09         = <<@D_Temp09>>'
        +', @D_Temp10         = <<@D_Temp10>>'
        +' FROM ADJUSTMENTDETAIL WITH(NOLOCK)'

      IF ISNULL(@c_DTL_JOIN,'') <> ''
         SET @c_SQL = @c_SQL + ' ' + @c_DTL_JOIN

      SET @c_SQL = @c_SQL
        + ' WHERE ADJUSTMENTDETAIL.AdjustmentKey = ''' + ISNULL(REPLACE(@c_AdjKey,'''',''''''),'') + ''''
        +   ' AND ADJUSTMENTDETAIL.AdjustmentLineNumber = ''' + ISNULL(REPLACE(@c_AdjLineNumber,'''',''''''),'') + ''''

      IF ISNULL(@c_DTL_WHERE,'') <> ''
         SET @c_SQL = @c_SQL
           + ' AND (' + @c_DTL_WHERE + ')'

      IF ISNULL(@c_DTL_SORT,'') <> ''
         SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_DTL_SORT


      DECLARE CUR_CLK_UPD_DTL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT TRIM(Long), TRIM(Notes)
      FROM dbo.CODELKUP WITH(NOLOCK)
      WHERE ListName = @c_ListName
         AND Code2 = @c_SP_Name
         AND Storerkey = @c_x_Storerkey
         AND LEFT(Code,7) = 'UPD_DTL'
         AND Short = 'Y'
         AND ISNULL(Long,'') <> ''
         AND ISNULL(Notes,'') <> ''

      OPEN CUR_CLK_UPD_DTL

      WHILE @n_Continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_CLK_UPD_DTL
         INTO @c_Long, @c_Notes

         IF @@FETCH_STATUS<>0
            BREAK

         IF ISNULL(@c_Long,'') <> ''
         BEGIN
            SET @c_Long = '<<' + CASE WHEN @c_Long LIKE '@%' THEN '' ELSE 'ADJUSTMENTDETAIL.' END + @c_Long + '>>'
            SET @c_SQL = REPLACE(@c_SQL, ISNULL(@c_Long,''), @c_Notes)
         END
      END
      CLOSE CUR_CLK_UPD_DTL
      DEALLOCATE CUR_CLK_UPD_DTL

      SET @c_SQL = REPLACE(REPLACE(@c_SQL, '<<', ''), '>>', '')

      SELECT @D_Loc             = NULL, @D_Lot             = NULL, @D_Id              = NULL
           , @D_ReasonCode      = NULL, @D_Qty             = NULL, @D_UserDefine01    = NULL
           , @D_UserDefine02    = NULL, @D_UserDefine03    = NULL, @D_UserDefine04    = NULL
           , @D_UserDefine05    = NULL, @D_UserDefine06    = NULL, @D_UserDefine07    = NULL
           , @D_UserDefine08    = NULL, @D_UserDefine09    = NULL, @D_UserDefine10    = NULL
           , @D_Lottable01      = NULL, @D_Lottable02      = NULL, @D_Lottable03      = NULL
           , @D_Lottable04      = NULL, @D_Lottable05      = NULL, @D_UCCNo           = NULL
           , @D_Lottable06      = NULL, @D_Lottable07      = NULL, @D_Lottable08      = NULL
           , @D_Lottable09      = NULL, @D_Lottable10      = NULL, @D_Lottable11      = NULL
           , @D_Lottable12      = NULL, @D_Lottable13      = NULL, @D_Lottable14      = NULL
           , @D_Lottable15      = NULL, @D_Channel         = NULL, @D_SerialNo        = NULL
           , @D_AdjustmentKey   = NULL, @D_AdjustmentLineNumber = NULL, @D_StorerKey  = NULL
           , @D_Sku             = NULL, @D_UOM             = NULL, @D_PackKey         = NULL
           , @D_CaseCnt         = NULL, @D_InnerPack       = NULL, @D_Pallet          = NULL
           , @D_Cube            = NULL, @D_GrossWgt        = NULL, @D_NetWgt          = NULL
           , @D_OtherUnit1      = NULL, @D_OtherUnit2      = NULL, @D_ItrnKey         = NULL
           , @D_EffectiveDate   = NULL, @D_AddDate         = NULL, @D_AddWho          = NULL
           , @D_EditDate        = NULL, @D_EditWho         = NULL, @D_FinalizedFlag   = NULL
           , @D_Channel_ID      = NULL, @D_PalletType      = NULL
           , @D_Temp01          = NULL, @D_Temp02          = NULL, @D_Temp03          = NULL
           , @D_Temp04          = NULL, @D_Temp05          = NULL, @D_Temp06          = NULL
           , @D_Temp07          = NULL, @D_Temp08          = NULL, @D_Temp09          = NULL
           , @D_Temp10          = NULL

      IF @b_debug = 1
         SELECT @c_SQL AS [Select Detail], @c_SQLParm_DTL AS SQLParam_DTL

      BEGIN TRY
         EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_DTL
            , @D_Loc             OUTPUT, @D_Lot             OUTPUT, @D_Id              OUTPUT
            , @D_ReasonCode      OUTPUT, @D_Qty             OUTPUT, @D_UserDefine01    OUTPUT
            , @D_UserDefine02    OUTPUT, @D_UserDefine03    OUTPUT, @D_UserDefine04    OUTPUT
            , @D_UserDefine05    OUTPUT, @D_UserDefine06    OUTPUT, @D_UserDefine07    OUTPUT
            , @D_UserDefine08    OUTPUT, @D_UserDefine09    OUTPUT, @D_UserDefine10    OUTPUT
            , @D_Lottable01      OUTPUT, @D_Lottable02      OUTPUT, @D_Lottable03      OUTPUT
            , @D_Lottable04      OUTPUT, @D_Lottable05      OUTPUT, @D_UCCNo           OUTPUT
            , @D_Lottable06      OUTPUT, @D_Lottable07      OUTPUT, @D_Lottable08      OUTPUT
            , @D_Lottable09      OUTPUT, @D_Lottable10      OUTPUT, @D_Lottable11      OUTPUT
            , @D_Lottable12      OUTPUT, @D_Lottable13      OUTPUT, @D_Lottable14      OUTPUT
            , @D_Lottable15      OUTPUT, @D_Channel         OUTPUT, @D_SerialNo        OUTPUT
            , @D_AdjustmentKey   OUTPUT, @D_AdjustmentLineNumber OUTPUT, @D_StorerKey  OUTPUT
            , @D_Sku             OUTPUT, @D_UOM             OUTPUT, @D_PackKey         OUTPUT
            , @D_CaseCnt         OUTPUT, @D_InnerPack       OUTPUT, @D_Pallet          OUTPUT
            , @D_Cube            OUTPUT, @D_GrossWgt        OUTPUT, @D_NetWgt          OUTPUT
            , @D_OtherUnit1      OUTPUT, @D_OtherUnit2      OUTPUT, @D_ItrnKey         OUTPUT
            , @D_EffectiveDate   OUTPUT, @D_AddDate         OUTPUT, @D_AddWho          OUTPUT
            , @D_EditDate        OUTPUT, @D_EditWho         OUTPUT, @D_FinalizedFlag   OUTPUT
            , @D_Channel_ID      OUTPUT, @D_PalletType      OUTPUT
            , @D_Temp01          OUTPUT, @D_Temp02          OUTPUT, @D_Temp03          OUTPUT
            , @D_Temp04          OUTPUT, @D_Temp05          OUTPUT, @D_Temp06          OUTPUT
            , @D_Temp07          OUTPUT, @D_Temp08          OUTPUT, @D_Temp09          OUTPUT
            , @D_Temp10          OUTPUT
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err  = 61073
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Select Adjustment Detail Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
         GOTO QUIT_SP
      END CATCH


      ----------------------
      -- Update Variables --
      ----------------------
      DECLARE CUR_CLK_UPD_VAR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT TRIM(Long), TRIM(Notes), RTRIM(UDF01)
      FROM dbo.CODELKUP WITH(NOLOCK)
      WHERE ListName = @c_ListName
         AND Code2 = @c_SP_Name
         AND Storerkey = @c_x_Storerkey
         AND LEFT(Code,7) = 'UPD_VAR'
         AND Short = 'Y'
         AND ISNULL(Long,'') <> ''
         AND LTRIM(Long) LIKE '@%'
         AND ISNULL(Notes,'') <> ''

      OPEN CUR_CLK_UPD_VAR

      WHILE @n_Continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_CLK_UPD_VAR
         INTO @c_Long, @c_Notes, @c_UDF01

         IF @@FETCH_STATUS<>0
            BREAK

         IF @c_UDF01 = 'DECODE'
            SET @c_SQL = @c_Notes
         ELSE
            SET @c_SQL = 'SELECT ' + @c_Long + ' = (' + @c_Notes + ');'

         IF @b_debug = 1
            SELECT @c_SQL AS [Update Variable], @c_SQLParm_VAR AS SQLParam_VAR

         BEGIN TRY
            EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_VAR
               , @H_CustomerRefNo   OUTPUT, @H_AdjustmentType  OUTPUT, @H_Remarks         OUTPUT
               , @H_FromToWhse      OUTPUT, @H_PrintFlag       OUTPUT, @H_UserDefine01    OUTPUT
               , @H_UserDefine02    OUTPUT, @H_UserDefine03    OUTPUT, @H_UserDefine04    OUTPUT
               , @H_UserDefine05    OUTPUT, @H_UserDefine06    OUTPUT, @H_UserDefine07    OUTPUT
               , @H_UserDefine08    OUTPUT, @H_UserDefine09    OUTPUT, @H_UserDefine10    OUTPUT
               , @H_AdjustmentKey   OUTPUT, @H_EffectiveDate   OUTPUT, @H_Storerkey       OUTPUT
               , @H_AddDate         OUTPUT, @H_AddWho          OUTPUT, @H_EditDate        OUTPUT
               , @H_EditWho         OUTPUT, @H_Facility        OUTPUT, @H_FinalizedFlag   OUTPUT
               , @H_DocType         OUTPUT
               , @D_Loc             OUTPUT, @D_Lot             OUTPUT, @D_Id              OUTPUT
               , @D_ReasonCode      OUTPUT, @D_Qty             OUTPUT, @D_UserDefine01    OUTPUT
               , @D_UserDefine02    OUTPUT, @D_UserDefine03    OUTPUT, @D_UserDefine04    OUTPUT
               , @D_UserDefine05    OUTPUT, @D_UserDefine06    OUTPUT, @D_UserDefine07    OUTPUT
               , @D_UserDefine08    OUTPUT, @D_UserDefine09    OUTPUT, @D_UserDefine10    OUTPUT
               , @D_Lottable01      OUTPUT, @D_Lottable02      OUTPUT, @D_Lottable03      OUTPUT
               , @D_Lottable04      OUTPUT, @D_Lottable05      OUTPUT, @D_UCCNo           OUTPUT
               , @D_Lottable06      OUTPUT, @D_Lottable07      OUTPUT, @D_Lottable08      OUTPUT
               , @D_Lottable09      OUTPUT, @D_Lottable10      OUTPUT, @D_Lottable11      OUTPUT
               , @D_Lottable12      OUTPUT, @D_Lottable13      OUTPUT, @D_Lottable14      OUTPUT
               , @D_Lottable15      OUTPUT, @D_Channel         OUTPUT, @D_SerialNo        OUTPUT
               , @D_AdjustmentKey   OUTPUT, @D_AdjustmentLineNumber OUTPUT, @D_StorerKey  OUTPUT
               , @D_Sku             OUTPUT, @D_UOM             OUTPUT, @D_PackKey         OUTPUT
               , @D_CaseCnt         OUTPUT, @D_InnerPack       OUTPUT, @D_Pallet          OUTPUT
               , @D_Cube            OUTPUT, @D_GrossWgt        OUTPUT, @D_NetWgt          OUTPUT
               , @D_OtherUnit1      OUTPUT, @D_OtherUnit2      OUTPUT, @D_ItrnKey         OUTPUT
               , @D_EffectiveDate   OUTPUT, @D_AddDate         OUTPUT, @D_AddWho          OUTPUT
               , @D_EditDate        OUTPUT, @D_EditWho         OUTPUT, @D_FinalizedFlag   OUTPUT
               , @D_Channel_ID      OUTPUT, @D_PalletType      OUTPUT
               , @H_Temp01          OUTPUT, @H_Temp02          OUTPUT, @H_Temp03          OUTPUT
               , @H_Temp04          OUTPUT, @H_Temp05          OUTPUT, @H_Temp06          OUTPUT
               , @H_Temp07          OUTPUT, @H_Temp08          OUTPUT, @H_Temp09          OUTPUT
               , @H_Temp10          OUTPUT
               , @D_Temp01          OUTPUT, @D_Temp02          OUTPUT, @D_Temp03          OUTPUT
               , @D_Temp04          OUTPUT, @D_Temp05          OUTPUT, @D_Temp06          OUTPUT
               , @D_Temp07          OUTPUT, @D_Temp08          OUTPUT, @D_Temp09          OUTPUT
               , @D_Temp10          OUTPUT
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err  = 61074
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Variable Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
            GOTO QUIT_SP
         END CATCH
      END
      CLOSE CUR_CLK_UPD_VAR
      DEALLOCATE CUR_CLK_UPD_VAR


      --------------------------
      -- Update Detail Record --
      --------------------------
      DECLARE CUR_UPDATE_DET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT Code, TRIM(Long)
      FROM dbo.CODELKUP WITH(NOLOCK)
      WHERE ListName = @c_ListName
         AND Code2 = @c_SP_Name
         AND Storerkey = @c_x_Storerkey
         AND (LEFT(Code,7) = 'UPD_DTL' AND Long NOT LIKE '%@%'
           OR LEFT(Code,7) = 'UPD_VAR' AND LEFT(LTRIM(Long),3)='@D_')
         AND Short = 'Y'
         AND ISNULL(Long,'') <> ''
         AND Long NOT LIKE '%@%'
      ORDER BY Code

      OPEN CUR_UPDATE_DET

      SET @c_SQL = ''
      SET @c_SQL2 = ''

      WHILE @n_Continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_UPDATE_DET
         INTO @c_Code, @c_Long

         IF @@FETCH_STATUS<>0
            BREAK

         IF LEFT(@c_Code,7) = 'UPD_VAR' AND LEFT(LTRIM(@c_Long),3)='@D_'
            SET @c_Long = SUBSTRING(@c_Long,4,LEN(@c_Long))

         IF @c_DTL_UPD_Fields LIKE '%,'+@c_Long+',%'
         BEGIN
            SET @c_SQL = @c_SQL + ',' + @c_Long + '=@D_' + @c_Long
            SET @c_SQL2 = @c_SQL2 + IIF(@c_SQL2<>'',' OR ','') + 'ISNULL(' + @c_Long + ','''')<>@D_' + @c_Long
         END
      END
      CLOSE CUR_UPDATE_DET
      DEALLOCATE CUR_UPDATE_DET

      IF ISNULL(@c_SQL,'')<>'' AND ISNULL(@c_SQL2,'')<>''
      BEGIN
         SET @c_SQL = 'UPDATE ADJUSTMENTDETAIL WITH(ROWLOCK)'
           +' SET Trafficcop=NULL' + @c_SQL
           +' WHERE AdjustmentKey=''' + ISNULL(REPLACE(@c_AdjKey,'''',''''''),'') + ''''
           +' AND AdjustmentLineNumber=''' + ISNULL(REPLACE(@c_AdjLineNumber,'''',''''''),'') + ''''
           +' AND (' + @c_SQL2 + ')'

         IF @b_debug = 1
            SELECT @c_SQL AS [Update Detail Record], @c_SQLParm_UPDDTL AS SQLParam_UPDDTL

         BEGIN TRY
            EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_UPDDTL
               , @D_Loc          , @D_Lot         , @D_Id
               , @D_ReasonCode   , @D_Qty         , @D_UserDefine01
               , @D_UserDefine02 , @D_UserDefine03, @D_UserDefine04
               , @D_UserDefine05 , @D_UserDefine06, @D_UserDefine07
               , @D_UserDefine08 , @D_UserDefine09, @D_UserDefine10
               , @D_Lottable01   , @D_Lottable02  , @D_Lottable03
               , @D_Lottable04   , @D_Lottable05  , @D_UCCNo
               , @D_Lottable06   , @D_Lottable07  , @D_Lottable08
               , @D_Lottable09   , @D_Lottable10  , @D_Lottable11
               , @D_Lottable12   , @D_Lottable13  , @D_Lottable14
               , @D_Lottable15   , @D_Channel     , @D_SerialNo
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err  = 61075
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Adjustment Detail Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
            GOTO QUIT_SP
         END CATCH
      END
   END
   CLOSE CUR_ADJ_DTL
   DEALLOCATE CUR_ADJ_DTL


   --------------------------
   -- Update Header Record --
   --------------------------
   DECLARE CUR_UPDATE_HDR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT Code, TRIM(Long)
   FROM dbo.CODELKUP WITH(NOLOCK)
   WHERE ListName = @c_ListName
      AND Code2 = @c_SP_Name
      AND Storerkey = @c_x_Storerkey
      AND (LEFT(Code,7) = 'UPD_HDR' AND Long NOT LIKE '%@%'
        OR LEFT(Code,7) = 'UPD_VAR' AND LEFT(LTRIM(Long),3)='@H_')
      AND Short = 'Y'
      AND ISNULL(Long,'') <> ''
   ORDER BY Code

   OPEN CUR_UPDATE_HDR

   SET @c_SQL = ''
   SET @c_SQL2 = ''

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_UPDATE_HDR
      INTO @c_Code, @c_Long

      IF @@FETCH_STATUS<>0
         BREAK

      IF LEFT(@c_Code,7) = 'UPD_VAR' AND LEFT(LTRIM(@c_Long),3)='@H_'
         SET @c_Long = SUBSTRING(@c_Long,4,LEN(@c_Long))

      IF @c_HDR_UPD_Fields LIKE '%,'+@c_Long+',%'
      BEGIN
         SET @c_SQL = @c_SQL + ',' + @c_Long + '=@H_' + @c_Long
         SET @c_SQL2 = @c_SQL2 + IIF(@c_SQL2<>'',' OR ','') + 'ISNULL(' + @c_Long + ','''')<>@H_' + @c_Long
      END
   END
   CLOSE CUR_UPDATE_HDR
   DEALLOCATE CUR_UPDATE_HDR

   IF ISNULL(@c_SQL,'')<>'' AND ISNULL(@c_SQL2,'')<>''
   BEGIN
      SET @c_SQL = 'UPDATE ADJUSTMENT WITH(ROWLOCK)'
        +' SET Trafficcop=NULL' + @c_SQL
        +' WHERE AdjustmentKey=''' + ISNULL(REPLACE(@c_AdjustmentKey,'''',''''''),'') + ''''
        +' AND (' + @c_SQL2 + ')'

      IF @b_debug = 1
         SELECT @c_SQL AS [Update Header Record], @c_SQLParm_UPDHDR AS SQLParam_UPDHDR

      BEGIN TRY
         EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_UPDHDR
            , @H_CustomerRefNo, @H_AdjustmentType, @H_Remarks
            , @H_FromToWhse   , @H_PrintFlag     , @H_UserDefine01
            , @H_UserDefine02 , @H_UserDefine03  , @H_UserDefine04
            , @H_UserDefine05 , @H_UserDefine06  , @H_UserDefine07
            , @H_UserDefine08 , @H_UserDefine09  , @H_UserDefine10
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err  = 61076
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Adjustment Header Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
         GOTO QUIT_SP
      END CATCH
   END

STEP_2:


QUIT_SP:
   IF XACT_STATE() = -1   --(-1 = uncommittable)
      ROLLBACK TRAN

   IF CURSOR_STATUS( 'LOCAL', 'CUR_ADJ_DTL') in (0 , 1)
   BEGIN
      CLOSE CUR_ADJ_DTL
      DEALLOCATE CUR_ADJ_DTL
   END
   IF CURSOR_STATUS( 'LOCAL', 'CUR_CLK_UPD_HDR') in (0 , 1)
   BEGIN
      CLOSE CUR_CLK_UPD_HDR
      DEALLOCATE CUR_CLK_UPD_HDR
   END
   IF CURSOR_STATUS( 'LOCAL', 'CUR_CLK_UPD_DTL') in (0 , 1)
   BEGIN
      CLOSE CUR_CLK_UPD_DTL
      DEALLOCATE CUR_CLK_UPD_DTL
   END
   IF CURSOR_STATUS( 'LOCAL', 'C_CLK_UPD_VAR') in (0 , 1)
   BEGIN
      CLOSE C_CLK_UPD_VAR
      DEALLOCATE C_CLK_UPD_VAR
   END
   IF CURSOR_STATUS( 'LOCAL', 'CUR_UPDATE_DET') in (0 , 1)
   BEGIN
      CLOSE CUR_UPDATE_DET
      DEALLOCATE CUR_UPDATE_DET
   END
   IF CURSOR_STATUS( 'LOCAL', 'CUR_UPDATE_HDR') in (0 , 1)
   BEGIN
      CLOSE CUR_UPDATE_HDR
      DEALLOCATE CUR_UPDATE_HDR
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, @c_SP_Name
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[ispPRADJGP] TO nSQL
GO
