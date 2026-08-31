SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ispPRTRFGP                                                  */
/* Creation Date: 2026-07-15                                            */
/* Copyright: Maersk                                                    */
/* Written by: Michael                                                  */
/*                                                                      */
/* Purpose: Generic SP for PreFinalizeTranferSP                         */
/*                                                                      */
/* Called By: ispFinalizeTransfer -> ispPreFinalizeTransferWrapper      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 2026-07-15   Michael   1.0 UWP-61594-PreFinalizeTranferSP GenericSP  */
/*                            (ML01)                                    */
/************************************************************************/
CREATE OR ALTER PROC ispPRTRFGP
    @c_Transferkey          NVARCHAR(10)
  , @b_Success              INT           OUTPUT
  , @n_Err                  INT           OUTPUT
  , @c_ErrMsg               NVARCHAR(255) OUTPUT
  , @c_TransferLineNumber   NVARCHAR(5)   = ''
AS
BEGIN
/* STORERCONFIG
   .ConfigKey = 'PreFinalizeTranferSP'
   .SValue    = 'ispPRTRFGP'
   .OPTION5   = '@c_ExtPreFinalizeTranferSP=xxx'  -- Calling another PreFinalizeTranferSP if setup

   CODELKUP
   .ListName  =  'PRETRFCFG'
   .Code2     =  'ispPRTRFGP'
   .Storerkey =  <Storerkey>

   Code           Description          Short(Enable)   Long(Fieldname)   Notes(SQL)
   SEL_JOIN       Select JOIN          Y/N                               <Join Clause>
   SEL_WHERE      Select WHERE         Y/N                               <Where Clause>
   SEL_SORT       Select ORDER BY      Y/N                               <Order By Clause>
   HDR_JOIN       Header JOIN          Y/N                               <Join Clause>
   HDR_WHERE      Header WHERE         Y/N                               <Where Clause>
   HDR_SORT       Header ORDER BY      Y/N                               <Order By Clause>
   DTL_JOIN       Detail JOIN          Y/N                               <Join Clause>
   DTL_WHERE      Detail WHERE         Y/N                               <Where Clause>
   DTL_SORT       Detail ORDER BY      Y/N                               <Order By Clause>
   UPD_HDR_999    Update Header        Y/N             Field Name        <SQL Expresssion>
   UPD_DTL_999    Update Detail        Y/N             Field Name        <SQL Expresssion>
   UPD_VAR_999    Update Variable      Y/N             Var Name          <SQL Expresssion>
   USE_TEMPTABLE  Use Temp Table #tVar Y/N             Y/N
   Debug          Debug mode           Y/N

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
         , @c_SP_Name          NVARCHAR(128) = 'ispPRTRFGP'
         , @c_TrfKey           NVARCHAR(10)
         , @c_TrfLineNumber    NVARCHAR(5)
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
         , @c_Use_TempTable    NVARCHAR(10)  = ''
         , @c_ListName         NVARCHAR(10)  = 'PRETRFCFG'
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
         , @c_ExtPreFinalizeTranferSP NVARCHAR(MAX) = ''

   DECLARE @H_Type             NVARCHAR(12)
         , @H_GenerateHOCharges    NVARCHAR(10)
         , @H_GenerateIS_HICharges NVARCHAR(10)
         , @H_ReLot            NVARCHAR(10)
         , @H_ReasonCode       NVARCHAR(10)
         , @H_CustomerRefNo    NVARCHAR(20)
         , @H_Remarks          NVARCHAR(200)
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

   DECLARE @H_TransferKey      NVARCHAR(10)
         , @H_FromStorerKey    NVARCHAR(15)
         , @H_ToStorerKey      NVARCHAR(15)
         , @H_OpenQty          INT
         , @H_Status           NVARCHAR(10)
         , @H_EffectiveDate    DATETIME
         , @H_AddDate          DATETIME
         , @H_AddWho           NVARCHAR(128)
         , @H_EditDate         DATETIME
         , @H_EditWho          NVARCHAR(128)
         , @H_Facility         NVARCHAR(15)
         , @H_ToFacility       NVARCHAR(15)
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

   DECLARE @D_FromLoc          NVARCHAR(10)
         , @D_FromLot          NVARCHAR(10)
         , @D_FromId           NVARCHAR(18)
         , @D_FromQty          INT
         , @D_LOTTABLE01       NVARCHAR(18)
         , @D_LOTTABLE02       NVARCHAR(18)
         , @D_LOTTABLE03       NVARCHAR(18)
         , @D_LOTTABLE04       DATETIME
         , @D_LOTTABLE05       DATETIME
         , @D_ToLoc            NVARCHAR(10)
         , @D_ToLot            NVARCHAR(10)
         , @D_ToId             NVARCHAR(18)
         , @D_ToQty            INT
         , @D_tolottable01     NVARCHAR(18)
         , @D_tolottable02     NVARCHAR(18)
         , @D_tolottable03     NVARCHAR(18)
         , @D_tolottable04     DATETIME
         , @D_tolottable05     DATETIME
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
         , @D_ToLottable06     NVARCHAR(30)
         , @D_ToLottable07     NVARCHAR(30)
         , @D_ToLottable08     NVARCHAR(30)
         , @D_ToLottable09     NVARCHAR(30)
         , @D_ToLottable10     NVARCHAR(30)
         , @D_ToLottable11     NVARCHAR(30)
         , @D_ToLottable12     NVARCHAR(30)
         , @D_ToLottable13     DATETIME
         , @D_ToLottable14     DATETIME
         , @D_ToLottable15     DATETIME
         , @D_FromChannel      NVARCHAR(20)
         , @D_ToChannel        NVARCHAR(20)
         , @D_FromChannel_ID   BIGINT
         , @D_ToChannel_ID     BIGINT
         , @D_FromSerialNo     NVARCHAR(30)
         , @D_ToSerialNo       NVARCHAR(30)
         , @D_FromPalletType   NVARCHAR(10)
         , @D_ToPalletType     NVARCHAR(10)

   DECLARE @D_TransferKey      NVARCHAR(10)
         , @D_TransferLineNumber NVARCHAR(5)
         , @D_FromStorerKey    NVARCHAR(15)
         , @D_FromSku          NVARCHAR(20)
         , @D_FromPackKey      NVARCHAR(10)
         , @D_FromUOM          NVARCHAR(10)
         , @D_ToStorerKey      NVARCHAR(15)
         , @D_ToSku            NVARCHAR(20)
         , @D_ToPackKey        NVARCHAR(10)
         , @D_ToUOM            NVARCHAR(10)
         , @D_Status           NVARCHAR(10)
         , @D_EffectiveDate    DATETIME
         , @D_AddDate          DATETIME
         , @D_AddWho           NVARCHAR(128)
         , @D_EditDate         DATETIME
         , @D_EditWho          NVARCHAR(128)
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

   SELECT @c_x_Storerkey = FromStorerkey
        , @c_x_Facility  = Facility
   FROM dbo.TRANSFER WITH(NOLOCK)
   WHERE TransferKey = @c_TransferKey

   -- Extended PreFinalizeTranferSP
   SELECT @c_Option5 = SC.Option5
   FROM dbo.fnc_GetRight2(@c_x_Facility, @c_x_Storerkey, '', 'PreFinalizeTranferSP') AS SC
   WHERE Authority='ispPRTRFGP'

   SELECT @c_ExtPreFinalizeTranferSP = dbo.fnc_GetParamValueFromString ('@c_ExtPreFinalizeTranferSP', @c_option5, '')

   IF ISNULL(@c_ExtPreFinalizeTranferSP,'') NOT IN ('', @c_SP_Name) AND
      EXISTS (SELECT 1 FROM sys.objects WHERE name = @c_ExtPreFinalizeTranferSP AND [type] = 'P')
   BEGIN
      SET @c_SQL = N'EXECUTE ' + @c_ExtPreFinalizeTranferSP
        + ' @c_Transferkey        = @c_Transferkey'
        +', @b_Success            = @b_Success OUTPUT'
        +', @n_Err                = @n_Err     OUTPUT'
        +', @c_ErrMsg             = @c_ErrMsg  OUTPUT'
        +', @c_TransferLineNumber = @c_TransferLineNumber'

      SET @c_SQLParm =
          N'@c_Transferkey          NVARCHAR(10)'
        +', @b_Success              INT           OUTPUT'
        +', @n_Err                  INT           OUTPUT'
        +', @c_ErrMsg               NVARCHAR(255) OUTPUT'
        +', @c_TransferLineNumber   NVARCHAR(5)   = '''

      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm
         , @c_Transferkey
         , @b_Success            OUTPUT
         , @n_Err                OUTPUT
         , @c_ErrMsg             OUTPUT
         , @c_TransferLineNumber

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
         GOTO QUIT_SP
      END
   END

   -- Check existing of PRETRFCFG setup
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

   -- Get PRETRFCFG setup
   SELECT @c_SEL_JOIN      = ISNULL(TRIM(MAX(CASE WHEN Code = 'SEL_JOIN'      AND Short = 'Y' THEN Notes END)),'')
        , @c_SEL_WHERE     = ISNULL(TRIM(MAX(CASE WHEN Code = 'SEL_WHERE'     AND Short = 'Y' THEN Notes END)),'')
        , @c_SEL_SORT      = ISNULL(TRIM(MAX(CASE WHEN Code = 'SEL_SORT'      AND Short = 'Y' THEN Notes END)),'')
        , @c_HDR_JOIN      = ISNULL(TRIM(MAX(CASE WHEN Code = 'HDR_JOIN'      AND Short = 'Y' THEN Notes END)),'')
        , @c_HDR_WHERE     = ISNULL(TRIM(MAX(CASE WHEN Code = 'HDR_WHERE'     AND Short = 'Y' THEN Notes END)),'')
        , @c_HDR_SORT      = ISNULL(TRIM(MAX(CASE WHEN Code = 'HDR_SORT'      AND Short = 'Y' THEN Notes END)),'')
        , @c_DTL_JOIN      = ISNULL(TRIM(MAX(CASE WHEN Code = 'DTL_JOIN'      AND Short = 'Y' THEN Notes END)),'')
        , @c_DTL_WHERE     = ISNULL(TRIM(MAX(CASE WHEN Code = 'DTL_WHERE'     AND Short = 'Y' THEN Notes END)),'')
        , @c_DTL_SORT      = ISNULL(TRIM(MAX(CASE WHEN Code = 'DTL_SORT'      AND Short = 'Y' THEN Notes END)),'')
        , @c_Use_TempTable = ISNULL(TRIM(MAX(CASE WHEN Code = 'USE_TEMPTABLE' AND Short = 'Y' THEN Long  END)),'')
        , @b_debug         = ISNULL(MAX(CASE WHEN Code = 'Debug' AND Short IN ('1','Y') THEN 1 END),0)
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

   IF OBJECT_ID('tempdb..#TMP_TRF_LINE') IS NOT NULL
      DROP TABLE #TMP_TRF_LINE

   CREATE TABLE #TMP_TRF_LINE (
      Row_ID             INT IDENTITY(1,1)
    , TransferKey        NVARCHAR(10) NOT NULL DEFAULT('')
    , TransferLineNumber NVARCHAR(5)  NOT NULL DEFAULT('')
   )

   IF ISNULL(@c_Use_TempTable,'') IN ('1', 'Y')
   BEGIN
      IF OBJECT_ID('tempdb..#tVar') IS NOT NULL
         DROP TABLE #tVar

      CREATE TABLE #tVar (
         [Var]       NVARCHAR(50)  NOT NULL PRIMARY KEY
       , [Value]     NVARCHAR(MAX) NULL
      )
   END

   ----------------------------------------------
   -- Select Transfer Detail into Temp Table --
   ----------------------------------------------
   SET @c_SQL =
      N'INSERT INTO #TMP_TRF_LINE (TransferKey, TransferLineNumber)'
     +' SELECT TRANSFERDETAIL.TransferKey'
     +      ', TRANSFERDETAIL.TransferLineNumber'
     +' FROM dbo.TRANSFER WITH(NOLOCK)'
     +' JOIN dbo.TRANSFERDETAIL WITH(NOLOCK) ON TRANSFER.TransferKey=TRANSFERDETAIL.TransferKey'

   IF ISNULL(@c_SEL_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_SEL_JOIN

   SET @c_SQL = @c_SQL
     +' WHERE TRANSFER.TransferKey = N''' + ISNULL(REPLACE(@c_TransferKey,'''',''''''),'') + ''''
     +  ' AND ISNULL(TRANSFER.Status,'''') <> ''9'''
     +  ' AND ISNULL(TRANSFERDETAIL.Status,'''') <> ''9'''

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

   IF NOT EXISTS(SELECT TOP 1 1 FROM #TMP_TRF_LINE)
      GOTO STEP_2


   SET @c_HDR_UPD_Fields =
      ',Type,GenerateHOCharges,GenerateIS_HICharges,ReLot,ReasonCode,CustomerRefNo,Remarks,PrintFlag,UserDefine01,UserDefine02,'
     + 'UserDefine03,UserDefine04,UserDefine05,UserDefine06,UserDefine07,UserDefine08,UserDefine09,UserDefine10,'

   SET @c_DTL_UPD_Fields =
      ',FromLoc,FromLot,FromId,FromQty,LOTTABLE01,LOTTABLE02,LOTTABLE03,LOTTABLE04,LOTTABLE05,ToLoc,'
     + 'ToLot,ToId,ToQty,tolottable01,tolottable02,tolottable03,tolottable04,tolottable05,UserDefine01,UserDefine02,'
     + 'UserDefine03,UserDefine04,UserDefine05,UserDefine06,UserDefine07,UserDefine08,UserDefine09,UserDefine10,Lottable06,Lottable07,'
     + 'Lottable08,Lottable09,Lottable10,Lottable11,Lottable12,Lottable13,Lottable14,Lottable15,ToLottable06,ToLottable07,'
     + 'ToLottable08,ToLottable09,ToLottable10,ToLottable11,ToLottable12,ToLottable13,ToLottable14,ToLottable15,FromChannel,ToChannel,'
     + 'FromChannel_ID,ToChannel_ID,FromSerialNo,ToSerialNo,FromPalletType,ToPalletType,'

   SET @c_SQLParm_HDR
     =  '@H_Type           NVARCHAR(12)  OUTPUT, @H_GenerateHOCharges NVARCHAR(10) OUTPUT, @H_GenerateIS_HICharges NVARCHAR(10) OUTPUT'
     +', @H_ReLot          NVARCHAR(10)  OUTPUT, @H_ReasonCode     NVARCHAR(10)  OUTPUT, @H_CustomerRefNo  NVARCHAR(20)  OUTPUT'
     +', @H_Remarks        NVARCHAR(200) OUTPUT, @H_PrintFlag      NVARCHAR(1)   OUTPUT, @H_UserDefine01   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine02   NVARCHAR(20)  OUTPUT, @H_UserDefine03   NVARCHAR(20)  OUTPUT, @H_UserDefine04   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine05   NVARCHAR(20)  OUTPUT, @H_UserDefine06   DATETIME      OUTPUT, @H_UserDefine07   DATETIME      OUTPUT'
     +', @H_UserDefine08   NVARCHAR(10)  OUTPUT, @H_UserDefine09   NVARCHAR(10)  OUTPUT, @H_UserDefine10   NVARCHAR(10)  OUTPUT'
     +', @H_TransferKey    NVARCHAR(10)  OUTPUT, @H_FromStorerKey  NVARCHAR(15)  OUTPUT, @H_ToStorerKey    NVARCHAR(15)  OUTPUT'
     +', @H_OpenQty        INT           OUTPUT, @H_Status         NVARCHAR(10)  OUTPUT, @H_EffectiveDate  DATETIME      OUTPUT'
     +', @H_AddDate        DATETIME      OUTPUT, @H_AddWho         NVARCHAR(128) OUTPUT, @H_EditDate       DATETIME      OUTPUT'
     +', @H_EditWho        NVARCHAR(128) OUTPUT, @H_Facility       NVARCHAR(15)  OUTPUT, @H_ToFacility     NVARCHAR(15)  OUTPUT'
     +', @H_Temp01         NVARCHAR(MAX) OUTPUT, @H_Temp02         NVARCHAR(MAX) OUTPUT, @H_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp04         NVARCHAR(MAX) OUTPUT, @H_Temp05         NVARCHAR(MAX) OUTPUT, @H_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp07         NVARCHAR(MAX) OUTPUT, @H_Temp08         NVARCHAR(MAX) OUTPUT, @H_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp10         NVARCHAR(MAX) OUTPUT'

   SET @c_SQLParm_DTL
     =  '@D_FromLoc        NVARCHAR(10)  OUTPUT, @D_FromLot        NVARCHAR(10)  OUTPUT, @D_FromId         NVARCHAR(18)  OUTPUT'
     +', @D_FromQty        INT           OUTPUT, @D_LOTTABLE01     NVARCHAR(18)  OUTPUT, @D_LOTTABLE02     NVARCHAR(18)  OUTPUT'
     +', @D_LOTTABLE03     NVARCHAR(18)  OUTPUT, @D_LOTTABLE04     DATETIME      OUTPUT, @D_LOTTABLE05     DATETIME      OUTPUT'
     +', @D_ToLoc          NVARCHAR(10)  OUTPUT, @D_ToLot          NVARCHAR(10)  OUTPUT, @D_ToId           NVARCHAR(18)  OUTPUT'
     +', @D_ToQty          INT           OUTPUT, @D_tolottable01   NVARCHAR(18)  OUTPUT, @D_tolottable02   NVARCHAR(18)  OUTPUT'
     +', @D_tolottable03   NVARCHAR(18)  OUTPUT, @D_tolottable04   DATETIME      OUTPUT, @D_tolottable05   DATETIME      OUTPUT'
     +', @D_UserDefine01   NVARCHAR(20)  OUTPUT, @D_UserDefine02   NVARCHAR(20)  OUTPUT, @D_UserDefine03   NVARCHAR(20)  OUTPUT'
     +', @D_UserDefine04   NVARCHAR(20)  OUTPUT, @D_UserDefine05   NVARCHAR(20)  OUTPUT, @D_UserDefine06   DATETIME      OUTPUT'
     +', @D_UserDefine07   DATETIME      OUTPUT, @D_UserDefine08   NVARCHAR(10)  OUTPUT, @D_UserDefine09   NVARCHAR(10)  OUTPUT'
     +', @D_UserDefine10   NVARCHAR(10)  OUTPUT, @D_Lottable06     NVARCHAR(30)  OUTPUT, @D_Lottable07     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable08     NVARCHAR(30)  OUTPUT, @D_Lottable09     NVARCHAR(30)  OUTPUT, @D_Lottable10     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable11     NVARCHAR(30)  OUTPUT, @D_Lottable12     NVARCHAR(30)  OUTPUT, @D_Lottable13     DATETIME      OUTPUT'
     +', @D_Lottable14     DATETIME      OUTPUT, @D_Lottable15     DATETIME      OUTPUT, @D_ToLottable06   NVARCHAR(30)  OUTPUT'
     +', @D_ToLottable07   NVARCHAR(30)  OUTPUT, @D_ToLottable08   NVARCHAR(30)  OUTPUT, @D_ToLottable09   NVARCHAR(30)  OUTPUT'
     +', @D_ToLottable10   NVARCHAR(30)  OUTPUT, @D_ToLottable11   NVARCHAR(30)  OUTPUT, @D_ToLottable12   NVARCHAR(30)  OUTPUT'
     +', @D_ToLottable13   DATETIME      OUTPUT, @D_ToLottable14   DATETIME      OUTPUT, @D_ToLottable15   DATETIME      OUTPUT'
     +', @D_FromChannel    NVARCHAR(20)  OUTPUT, @D_ToChannel      NVARCHAR(20)  OUTPUT, @D_FromChannel_ID BIGINT        OUTPUT'
     +', @D_ToChannel_ID   BIGINT        OUTPUT, @D_FromSerialNo   NVARCHAR(30)  OUTPUT, @D_ToSerialNo     NVARCHAR(30)  OUTPUT'
     +', @D_FromPalletType NVARCHAR(10)  OUTPUT, @D_ToPalletType   NVARCHAR(10)  OUTPUT, @D_TransferKey    NVARCHAR(10)  OUTPUT'
     +', @D_TransferLineNumber NVARCHAR(5) OUTPUT, @D_FromStorerKey NVARCHAR(15) OUTPUT, @D_FromSku        NVARCHAR(20)  OUTPUT'
     +', @D_FromPackKey    NVARCHAR(10)  OUTPUT, @D_FromUOM        NVARCHAR(10)  OUTPUT, @D_ToStorerKey    NVARCHAR(15)  OUTPUT'
     +', @D_ToSku          NVARCHAR(20)  OUTPUT, @D_ToPackKey      NVARCHAR(10)  OUTPUT, @D_ToUOM          NVARCHAR(10)  OUTPUT'
     +', @D_Status         NVARCHAR(10)  OUTPUT, @D_EffectiveDate  DATETIME      OUTPUT, @D_AddDate        DATETIME      OUTPUT'
     +', @D_AddWho         NVARCHAR(128) OUTPUT, @D_EditDate       DATETIME      OUTPUT, @D_EditWho        NVARCHAR(128) OUTPUT'
     +', @D_Temp01         NVARCHAR(MAX) OUTPUT, @D_Temp02         NVARCHAR(MAX) OUTPUT, @D_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp04         NVARCHAR(MAX) OUTPUT, @D_Temp05         NVARCHAR(MAX) OUTPUT, @D_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp07         NVARCHAR(MAX) OUTPUT, @D_Temp08         NVARCHAR(MAX) OUTPUT, @D_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp10         NVARCHAR(MAX) OUTPUT'

   SET @c_SQLParm_VAR
     =  '@H_Type           NVARCHAR(12)  OUTPUT, @H_GenerateHOCharges NVARCHAR(10) OUTPUT, @H_GenerateIS_HICharges NVARCHAR(10) OUTPUT'
     +', @H_ReLot          NVARCHAR(10)  OUTPUT, @H_ReasonCode     NVARCHAR(10)  OUTPUT, @H_CustomerRefNo  NVARCHAR(20)  OUTPUT'
     +', @H_Remarks        NVARCHAR(200) OUTPUT, @H_PrintFlag      NVARCHAR(1)   OUTPUT, @H_UserDefine01   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine02   NVARCHAR(20)  OUTPUT, @H_UserDefine03   NVARCHAR(20)  OUTPUT, @H_UserDefine04   NVARCHAR(20)  OUTPUT'
     +', @H_UserDefine05   NVARCHAR(20)  OUTPUT, @H_UserDefine06   DATETIME      OUTPUT, @H_UserDefine07   DATETIME      OUTPUT'
     +', @H_UserDefine08   NVARCHAR(10)  OUTPUT, @H_UserDefine09   NVARCHAR(10)  OUTPUT, @H_UserDefine10   NVARCHAR(10)  OUTPUT'
     +', @H_TransferKey    NVARCHAR(10)  OUTPUT, @H_FromStorerKey  NVARCHAR(15)  OUTPUT, @H_ToStorerKey    NVARCHAR(15)  OUTPUT'
     +', @H_OpenQty        INT           OUTPUT, @H_Status         NVARCHAR(10)  OUTPUT, @H_EffectiveDate  DATETIME      OUTPUT'
     +', @H_AddDate        DATETIME      OUTPUT, @H_AddWho         NVARCHAR(128) OUTPUT, @H_EditDate       DATETIME      OUTPUT'
     +', @H_EditWho        NVARCHAR(128) OUTPUT, @H_Facility       NVARCHAR(15)  OUTPUT, @H_ToFacility     NVARCHAR(15)  OUTPUT'
     +', @D_FromLoc        NVARCHAR(10)  OUTPUT, @D_FromLot        NVARCHAR(10)  OUTPUT, @D_FromId         NVARCHAR(18)  OUTPUT'
     +', @D_FromQty        INT           OUTPUT, @D_LOTTABLE01     NVARCHAR(18)  OUTPUT, @D_LOTTABLE02     NVARCHAR(18)  OUTPUT'
     +', @D_LOTTABLE03     NVARCHAR(18)  OUTPUT, @D_LOTTABLE04     DATETIME      OUTPUT, @D_LOTTABLE05     DATETIME      OUTPUT'
     +', @D_ToLoc          NVARCHAR(10)  OUTPUT, @D_ToLot          NVARCHAR(10)  OUTPUT, @D_ToId           NVARCHAR(18)  OUTPUT'
     +', @D_ToQty          INT           OUTPUT, @D_tolottable01   NVARCHAR(18)  OUTPUT, @D_tolottable02   NVARCHAR(18)  OUTPUT'
     +', @D_tolottable03   NVARCHAR(18)  OUTPUT, @D_tolottable04   DATETIME      OUTPUT, @D_tolottable05   DATETIME      OUTPUT'
     +', @D_UserDefine01   NVARCHAR(20)  OUTPUT, @D_UserDefine02   NVARCHAR(20)  OUTPUT, @D_UserDefine03   NVARCHAR(20)  OUTPUT'
     +', @D_UserDefine04   NVARCHAR(20)  OUTPUT, @D_UserDefine05   NVARCHAR(20)  OUTPUT, @D_UserDefine06   DATETIME      OUTPUT'
     +', @D_UserDefine07   DATETIME      OUTPUT, @D_UserDefine08   NVARCHAR(10)  OUTPUT, @D_UserDefine09   NVARCHAR(10)  OUTPUT'
     +', @D_UserDefine10   NVARCHAR(10)  OUTPUT, @D_Lottable06     NVARCHAR(30)  OUTPUT, @D_Lottable07     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable08     NVARCHAR(30)  OUTPUT, @D_Lottable09     NVARCHAR(30)  OUTPUT, @D_Lottable10     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable11     NVARCHAR(30)  OUTPUT, @D_Lottable12     NVARCHAR(30)  OUTPUT, @D_Lottable13     DATETIME      OUTPUT'
     +', @D_Lottable14     DATETIME      OUTPUT, @D_Lottable15     DATETIME      OUTPUT, @D_ToLottable06   NVARCHAR(30)  OUTPUT'
     +', @D_ToLottable07   NVARCHAR(30)  OUTPUT, @D_ToLottable08   NVARCHAR(30)  OUTPUT, @D_ToLottable09   NVARCHAR(30)  OUTPUT'
     +', @D_ToLottable10   NVARCHAR(30)  OUTPUT, @D_ToLottable11   NVARCHAR(30)  OUTPUT, @D_ToLottable12   NVARCHAR(30)  OUTPUT'
     +', @D_ToLottable13   DATETIME      OUTPUT, @D_ToLottable14   DATETIME      OUTPUT, @D_ToLottable15   DATETIME      OUTPUT'
     +', @D_FromChannel    NVARCHAR(20)  OUTPUT, @D_ToChannel      NVARCHAR(20)  OUTPUT, @D_FromChannel_ID BIGINT        OUTPUT'
     +', @D_ToChannel_ID   BIGINT        OUTPUT, @D_FromSerialNo   NVARCHAR(30)  OUTPUT, @D_ToSerialNo     NVARCHAR(30)  OUTPUT'
     +', @D_FromPalletType NVARCHAR(10)  OUTPUT, @D_ToPalletType   NVARCHAR(10)  OUTPUT, @D_TransferKey    NVARCHAR(10)  OUTPUT'
     +', @D_TransferLineNumber NVARCHAR(5) OUTPUT, @D_FromStorerKey NVARCHAR(15) OUTPUT, @D_FromSku        NVARCHAR(20)  OUTPUT'
     +', @D_FromPackKey    NVARCHAR(10)  OUTPUT, @D_FromUOM        NVARCHAR(10)  OUTPUT, @D_ToStorerKey    NVARCHAR(15)  OUTPUT'
     +', @D_ToSku          NVARCHAR(20)  OUTPUT, @D_ToPackKey      NVARCHAR(10)  OUTPUT, @D_ToUOM          NVARCHAR(10)  OUTPUT'
     +', @D_Status         NVARCHAR(10)  OUTPUT, @D_EffectiveDate  DATETIME      OUTPUT, @D_AddDate        DATETIME      OUTPUT'
     +', @D_AddWho         NVARCHAR(128) OUTPUT, @D_EditDate       DATETIME      OUTPUT, @D_EditWho        NVARCHAR(128) OUTPUT'
     +', @H_Temp01         NVARCHAR(MAX) OUTPUT, @H_Temp02         NVARCHAR(MAX) OUTPUT, @H_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp04         NVARCHAR(MAX) OUTPUT, @H_Temp05         NVARCHAR(MAX) OUTPUT, @H_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp07         NVARCHAR(MAX) OUTPUT, @H_Temp08         NVARCHAR(MAX) OUTPUT, @H_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp10         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp01         NVARCHAR(MAX) OUTPUT, @D_Temp02         NVARCHAR(MAX) OUTPUT, @D_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp04         NVARCHAR(MAX) OUTPUT, @D_Temp05         NVARCHAR(MAX) OUTPUT, @D_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp07         NVARCHAR(MAX) OUTPUT, @D_Temp08         NVARCHAR(MAX) OUTPUT, @D_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp10         NVARCHAR(MAX) OUTPUT'

   SET @c_SQLParm_UPDDTL
     =  '@D_FromLoc        NVARCHAR(10), @D_FromLot        NVARCHAR(10), @D_FromId         NVARCHAR(18)'
     +', @D_FromQty        INT         , @D_LOTTABLE01     NVARCHAR(18), @D_LOTTABLE02     NVARCHAR(18)'
     +', @D_LOTTABLE03     NVARCHAR(18), @D_LOTTABLE04     DATETIME    , @D_LOTTABLE05     DATETIME'
     +', @D_ToLoc          NVARCHAR(10), @D_ToLot          NVARCHAR(10), @D_ToId           NVARCHAR(18)'
     +', @D_ToQty          INT         , @D_tolottable01   NVARCHAR(18), @D_tolottable02   NVARCHAR(18)'
     +', @D_tolottable03   NVARCHAR(18), @D_tolottable04   DATETIME    , @D_tolottable05   DATETIME'
     +', @D_UserDefine01   NVARCHAR(20), @D_UserDefine02   NVARCHAR(20), @D_UserDefine03   NVARCHAR(20)'
     +', @D_UserDefine04   NVARCHAR(20), @D_UserDefine05   NVARCHAR(20), @D_UserDefine06   DATETIME'
     +', @D_UserDefine07   DATETIME    , @D_UserDefine08   NVARCHAR(10), @D_UserDefine09   NVARCHAR(10)'
     +', @D_UserDefine10   NVARCHAR(10), @D_Lottable06     NVARCHAR(30), @D_Lottable07     NVARCHAR(30)'
     +', @D_Lottable08     NVARCHAR(30), @D_Lottable09     NVARCHAR(30), @D_Lottable10     NVARCHAR(30)'
     +', @D_Lottable11     NVARCHAR(30), @D_Lottable12     NVARCHAR(30), @D_Lottable13     DATETIME'
     +', @D_Lottable14     DATETIME    , @D_Lottable15     DATETIME    , @D_ToLottable06   NVARCHAR(30)'
     +', @D_ToLottable07   NVARCHAR(30), @D_ToLottable08   NVARCHAR(30), @D_ToLottable09   NVARCHAR(30)'
     +', @D_ToLottable10   NVARCHAR(30), @D_ToLottable11   NVARCHAR(30), @D_ToLottable12   NVARCHAR(30)'
     +', @D_ToLottable13   DATETIME    , @D_ToLottable14   DATETIME    , @D_ToLottable15   DATETIME'
     +', @D_FromChannel    NVARCHAR(20), @D_ToChannel      NVARCHAR(20), @D_FromChannel_ID BIGINT'
     +', @D_ToChannel_ID   BIGINT      , @D_FromSerialNo   NVARCHAR(30), @D_ToSerialNo     NVARCHAR(30)'
     +', @D_FromPalletType NVARCHAR(10), @D_ToPalletType   NVARCHAR(10)'

   SET @c_SQLParm_UPDHDR
     =  '@H_Type           NVARCHAR(12), @H_GenerateHOCharges NVARCHAR(10), @H_GenerateIS_HICharges NVARCHAR(10)'
     +', @H_ReLot          NVARCHAR(10), @H_ReasonCode     NVARCHAR(10), @H_CustomerRefNo  NVARCHAR(20)'
     +', @H_Remarks        NVARCHAR(200), @H_PrintFlag     NVARCHAR(1) , @H_UserDefine01   NVARCHAR(20)'
     +', @H_UserDefine02   NVARCHAR(20), @H_UserDefine03   NVARCHAR(20), @H_UserDefine04   NVARCHAR(20)'
     +', @H_UserDefine05   NVARCHAR(20), @H_UserDefine06   DATETIME    , @H_UserDefine07   DATETIME'
     +', @H_UserDefine08   NVARCHAR(10), @H_UserDefine09   NVARCHAR(10), @H_UserDefine10   NVARCHAR(10)'

   --------------------------
   -- Select Header Fields --
   --------------------------
   SET @c_SQL = 'SELECT TOP 1'
     + ' @H_TransferKey    = <<TRANSFER.TransferKey>>'
     +', @H_FromStorerKey  = <<TRANSFER.FromStorerKey>>'
     +', @H_ToStorerKey    = <<TRANSFER.ToStorerKey>>'
     +', @H_Type           = <<TRANSFER.Type>>'
     +', @H_OpenQty        = <<TRANSFER.OpenQty>>'
     +', @H_Status         = <<TRANSFER.Status>>'
     +', @H_GenerateHOCharges = <<TRANSFER.GenerateHOCharges>>'
     +', @H_GenerateIS_HICharges= <<TRANSFER.GenerateIS_HICharges>>'
     +', @H_ReLot          = <<TRANSFER.ReLot>>'
     +', @H_EffectiveDate  = <<TRANSFER.EffectiveDate>>'
     +', @H_AddDate        = <<TRANSFER.AddDate>>'
     +', @H_AddWho         = <<TRANSFER.AddWho>>'
     +', @H_EditDate       = <<TRANSFER.EditDate>>'
     +', @H_EditWho        = <<TRANSFER.EditWho>>'
     +', @H_ReasonCode     = <<TRANSFER.ReasonCode>>'
     +', @H_CustomerRefNo  = <<TRANSFER.CustomerRefNo>>'
     +', @H_Remarks        = <<TRANSFER.Remarks>>'
     +', @H_Facility       = <<TRANSFER.Facility>>'
     +', @H_PrintFlag      = <<TRANSFER.PrintFlag>>'
     +', @H_UserDefine01   = <<TRANSFER.UserDefine01>>'
     +', @H_UserDefine02   = <<TRANSFER.UserDefine02>>'
     +', @H_UserDefine03   = <<TRANSFER.UserDefine03>>'
     +', @H_UserDefine04   = <<TRANSFER.UserDefine04>>'
     +', @H_UserDefine05   = <<TRANSFER.UserDefine05>>'
     +', @H_UserDefine06   = <<TRANSFER.UserDefine06>>'
     +', @H_UserDefine07   = <<TRANSFER.UserDefine07>>'
     +', @H_UserDefine08   = <<TRANSFER.UserDefine08>>'
     +', @H_UserDefine09   = <<TRANSFER.UserDefine09>>'
     +', @H_UserDefine10   = <<TRANSFER.UserDefine10>>'
     +', @H_ToFacility     = <<TRANSFER.ToFacility>>'
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
     +' FROM dbo.TRANSFER WITH(NOLOCK)'

   IF ISNULL(@c_HDR_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_HDR_JOIN

   SET @c_SQL = @c_SQL
     + ' WHERE TRANSFER.TransferKey = N''' + ISNULL(REPLACE(@c_TransferKey,'''',''''''),'') + ''''

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
         SET @c_Long = '<<' + CASE WHEN @c_Long LIKE '@%' THEN '' ELSE 'TRANSFER.' END + @c_Long + '>>'
         SET @c_SQL = REPLACE(@c_SQL, ISNULL(@c_Long,''), @c_Notes)
      END
   END
   CLOSE CUR_CLK_UPD_HDR
   DEALLOCATE CUR_CLK_UPD_HDR

   SET @c_SQL = REPLACE(REPLACE(@c_SQL, '<<', ''), '>>', '')



   SELECT @H_Type          = NULL, @H_GenerateHOCharges = NULL, @H_GenerateIS_HICharges = NULL
        , @H_ReLot         = NULL, @H_ReasonCode    = NULL, @H_CustomerRefNo = NULL
        , @H_Remarks       = NULL, @H_PrintFlag     = NULL, @H_UserDefine01  = NULL
        , @H_UserDefine02  = NULL, @H_UserDefine03  = NULL, @H_UserDefine04  = NULL
        , @H_UserDefine05  = NULL, @H_UserDefine06  = NULL, @H_UserDefine07  = NULL
        , @H_UserDefine08  = NULL, @H_UserDefine09  = NULL, @H_UserDefine10  = NULL
        , @H_TransferKey   = NULL, @H_FromStorerKey = NULL, @H_ToStorerKey   = NULL
        , @H_OpenQty       = NULL, @H_Status        = NULL, @H_EffectiveDate = NULL
        , @H_AddDate       = NULL, @H_AddWho        = NULL, @H_EditDate      = NULL
        , @H_EditWho       = NULL, @H_Facility      = NULL, @H_ToFacility    = NULL
        , @H_Temp01        = NULL, @H_Temp02        = NULL, @H_Temp03        = NULL
        , @H_Temp04        = NULL, @H_Temp05        = NULL, @H_Temp06        = NULL
        , @H_Temp07        = NULL, @H_Temp08        = NULL, @H_Temp09        = NULL
        , @H_Temp10        = NULL

   IF @b_debug = 1
      SELECT @c_SQL AS [Select Header], @c_SQLParm_HDR AS SQLParam_HDR

   BEGIN TRY
      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_HDR
         , @H_Type            OUTPUT, @H_GenerateHOCharges OUTPUT, @H_GenerateIS_HICharges OUTPUT
         , @H_ReLot           OUTPUT, @H_ReasonCode      OUTPUT, @H_CustomerRefNo   OUTPUT
         , @H_Remarks         OUTPUT, @H_PrintFlag       OUTPUT, @H_UserDefine01    OUTPUT
         , @H_UserDefine02    OUTPUT, @H_UserDefine03    OUTPUT, @H_UserDefine04    OUTPUT
         , @H_UserDefine05    OUTPUT, @H_UserDefine06    OUTPUT, @H_UserDefine07    OUTPUT
         , @H_UserDefine08    OUTPUT, @H_UserDefine09    OUTPUT, @H_UserDefine10    OUTPUT
         , @H_TransferKey     OUTPUT, @H_FromStorerKey   OUTPUT, @H_ToStorerKey     OUTPUT
         , @H_OpenQty         OUTPUT, @H_Status          OUTPUT, @H_EffectiveDate   OUTPUT
         , @H_AddDate         OUTPUT, @H_AddWho          OUTPUT, @H_EditDate        OUTPUT
         , @H_EditWho         OUTPUT, @H_Facility        OUTPUT, @H_ToFacility      OUTPUT
         , @H_Temp01          OUTPUT, @H_Temp02          OUTPUT, @H_Temp03          OUTPUT
         , @H_Temp04          OUTPUT, @H_Temp05          OUTPUT, @H_Temp06          OUTPUT
         , @H_Temp07          OUTPUT, @H_Temp08          OUTPUT, @H_Temp09          OUTPUT
         , @H_Temp10          OUTPUT
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err  = 61072
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Select Transfer Header Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
      GOTO QUIT_SP
   END CATCH


   --------------------------
   -- Select Detail Fields --
   --------------------------
   DECLARE CUR_TRF_DTL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT TransferKey
        , TransferLineNumber
   FROM #TMP_TRF_LINE
   ORDER BY Row_ID

   OPEN CUR_TRF_DTL

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_TRF_DTL
       INTO @c_TrfKey, @c_TrfLineNumber

      IF @@FETCH_STATUS<>0
         BREAK

      SET @c_SQL = 'SELECT TOP 1'
        + ' @D_FromLoc        = <<TRANSFERDETAIL.FromLoc>>'
        +', @D_FromLot        = <<TRANSFERDETAIL.FromLot>>'
        +', @D_FromId         = <<TRANSFERDETAIL.FromId>>'
        +', @D_FromQty        = <<TRANSFERDETAIL.FromQty>>'
        +', @D_LOTTABLE01     = <<TRANSFERDETAIL.LOTTABLE01>>'
        +', @D_LOTTABLE02     = <<TRANSFERDETAIL.LOTTABLE02>>'
        +', @D_LOTTABLE03     = <<TRANSFERDETAIL.LOTTABLE03>>'
        +', @D_LOTTABLE04     = <<TRANSFERDETAIL.LOTTABLE04>>'
        +', @D_LOTTABLE05     = <<TRANSFERDETAIL.LOTTABLE05>>'
        +', @D_ToLoc          = <<TRANSFERDETAIL.ToLoc>>'
        +', @D_ToLot          = <<TRANSFERDETAIL.ToLot>>'
        +', @D_ToId           = <<TRANSFERDETAIL.ToId>>'
        +', @D_ToQty          = <<TRANSFERDETAIL.ToQty>>'
        +', @D_tolottable01   = <<TRANSFERDETAIL.tolottable01>>'
        +', @D_tolottable02   = <<TRANSFERDETAIL.tolottable02>>'
        +', @D_tolottable03   = <<TRANSFERDETAIL.tolottable03>>'
        +', @D_tolottable04   = <<TRANSFERDETAIL.tolottable04>>'
        +', @D_tolottable05   = <<TRANSFERDETAIL.tolottable05>>'
        +', @D_UserDefine01   = <<TRANSFERDETAIL.UserDefine01>>'
        +', @D_UserDefine02   = <<TRANSFERDETAIL.UserDefine02>>'
        +', @D_UserDefine03   = <<TRANSFERDETAIL.UserDefine03>>'
        +', @D_UserDefine04   = <<TRANSFERDETAIL.UserDefine04>>'
        +', @D_UserDefine05   = <<TRANSFERDETAIL.UserDefine05>>'
        +', @D_UserDefine06   = <<TRANSFERDETAIL.UserDefine06>>'
        +', @D_UserDefine07   = <<TRANSFERDETAIL.UserDefine07>>'
        +', @D_UserDefine08   = <<TRANSFERDETAIL.UserDefine08>>'
        +', @D_UserDefine09   = <<TRANSFERDETAIL.UserDefine09>>'
        +', @D_UserDefine10   = <<TRANSFERDETAIL.UserDefine10>>'
        +', @D_Lottable06     = <<TRANSFERDETAIL.Lottable06>>'
        +', @D_Lottable07     = <<TRANSFERDETAIL.Lottable07>>'
        +', @D_Lottable08     = <<TRANSFERDETAIL.Lottable08>>'
        +', @D_Lottable09     = <<TRANSFERDETAIL.Lottable09>>'
        +', @D_Lottable10     = <<TRANSFERDETAIL.Lottable10>>'
        +', @D_Lottable11     = <<TRANSFERDETAIL.Lottable11>>'
        +', @D_Lottable12     = <<TRANSFERDETAIL.Lottable12>>'
        +', @D_Lottable13     = <<TRANSFERDETAIL.Lottable13>>'
        +', @D_Lottable14     = <<TRANSFERDETAIL.Lottable14>>'
        +', @D_Lottable15     = <<TRANSFERDETAIL.Lottable15>>'
        +', @D_ToLottable06   = <<TRANSFERDETAIL.ToLottable06>>'
        +', @D_ToLottable07   = <<TRANSFERDETAIL.ToLottable07>>'
        +', @D_ToLottable08   = <<TRANSFERDETAIL.ToLottable08>>'
        +', @D_ToLottable09   = <<TRANSFERDETAIL.ToLottable09>>'
        +', @D_ToLottable10   = <<TRANSFERDETAIL.ToLottable10>>'
        +', @D_ToLottable11   = <<TRANSFERDETAIL.ToLottable11>>'
        +', @D_ToLottable12   = <<TRANSFERDETAIL.ToLottable12>>'
        +', @D_ToLottable13   = <<TRANSFERDETAIL.ToLottable13>>'
        +', @D_ToLottable14   = <<TRANSFERDETAIL.ToLottable14>>'
        +', @D_ToLottable15   = <<TRANSFERDETAIL.ToLottable15>>'
        +', @D_FromChannel    = <<TRANSFERDETAIL.FromChannel>>'
        +', @D_ToChannel      = <<TRANSFERDETAIL.ToChannel>>'
        +', @D_FromChannel_ID = <<TRANSFERDETAIL.FromChannel_ID>>'
        +', @D_ToChannel_ID   = <<TRANSFERDETAIL.ToChannel_ID>>'
        +', @D_FromSerialNo   = <<TRANSFERDETAIL.FromSerialNo>>'
        +', @D_ToSerialNo     = <<TRANSFERDETAIL.ToSerialNo>>'
        +', @D_FromPalletType = <<TRANSFERDETAIL.FromPalletType>>'
        +', @D_ToPalletType   = <<TRANSFERDETAIL.ToPalletType>>'
        +', @D_TransferKey    = <<TRANSFERDETAIL.TransferKey>>'
        +', @D_TransferLineNumber = <<TRANSFERDETAIL.TransferLineNumber>>'
        +', @D_FromStorerKey  = <<TRANSFERDETAIL.FromStorerKey>>'
        +', @D_FromSku        = <<TRANSFERDETAIL.FromSku>>'
        +', @D_FromPackKey    = <<TRANSFERDETAIL.FromPackKey>>'
        +', @D_FromUOM        = <<TRANSFERDETAIL.FromUOM>>'
        +', @D_ToStorerKey    = <<TRANSFERDETAIL.ToStorerKey>>'
        +', @D_ToSku          = <<TRANSFERDETAIL.ToSku>>'
        +', @D_ToPackKey      = <<TRANSFERDETAIL.ToPackKey>>'
        +', @D_ToUOM          = <<TRANSFERDETAIL.ToUOM>>'
        +', @D_Status         = <<TRANSFERDETAIL.Status>>'
        +', @D_EffectiveDate  = <<TRANSFERDETAIL.EffectiveDate>>'
        +', @D_AddDate        = <<TRANSFERDETAIL.AddDate>>'
        +', @D_AddWho         = <<TRANSFERDETAIL.AddWho>>'
        +', @D_EditDate       = <<TRANSFERDETAIL.EditDate>>'
        +', @D_EditWho        = <<TRANSFERDETAIL.EditWho>>'
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
        +' FROM dbo.TRANSFERDETAIL WITH(NOLOCK)'

      IF ISNULL(@c_DTL_JOIN,'') <> ''
         SET @c_SQL = @c_SQL + ' ' + @c_DTL_JOIN

      SET @c_SQL = @c_SQL
        + ' WHERE TRANSFERDETAIL.TransferKey = N''' + ISNULL(REPLACE(@c_TrfKey,'''',''''''),'') + ''''
        +   ' AND TRANSFERDETAIL.TransferLineNumber = N''' + ISNULL(REPLACE(@c_TrfLineNumber,'''',''''''),'') + ''''

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
            SET @c_Long = '<<' + CASE WHEN @c_Long LIKE '@%' THEN '' ELSE 'TRANSFERDETAIL.' END + @c_Long + '>>'
            SET @c_SQL = REPLACE(@c_SQL, ISNULL(@c_Long,''), @c_Notes)
         END
      END
      CLOSE CUR_CLK_UPD_DTL
      DEALLOCATE CUR_CLK_UPD_DTL

      SET @c_SQL = REPLACE(REPLACE(@c_SQL, '<<', ''), '>>', '')

      SELECT @D_FromLoc         = NULL, @D_FromLot         = NULL, @D_FromId          = NULL
           , @D_FromQty         = NULL, @D_LOTTABLE01      = NULL, @D_LOTTABLE02      = NULL
           , @D_LOTTABLE03      = NULL, @D_LOTTABLE04      = NULL, @D_LOTTABLE05      = NULL
           , @D_ToLoc           = NULL, @D_ToLot           = NULL, @D_ToId            = NULL
           , @D_ToQty           = NULL, @D_tolottable01    = NULL, @D_tolottable02    = NULL
           , @D_tolottable03    = NULL, @D_tolottable04    = NULL, @D_tolottable05    = NULL
           , @D_UserDefine01    = NULL, @D_UserDefine02    = NULL, @D_UserDefine03    = NULL
           , @D_UserDefine04    = NULL, @D_UserDefine05    = NULL, @D_UserDefine06    = NULL
           , @D_UserDefine07    = NULL, @D_UserDefine08    = NULL, @D_UserDefine09    = NULL
           , @D_UserDefine10    = NULL, @D_Lottable06      = NULL, @D_Lottable07      = NULL
           , @D_Lottable08      = NULL, @D_Lottable09      = NULL, @D_Lottable10      = NULL
           , @D_Lottable11      = NULL, @D_Lottable12      = NULL, @D_Lottable13      = NULL
           , @D_Lottable14      = NULL, @D_Lottable15      = NULL, @D_ToLottable06    = NULL
           , @D_ToLottable07    = NULL, @D_ToLottable08    = NULL, @D_ToLottable09    = NULL
           , @D_ToLottable10    = NULL, @D_ToLottable11    = NULL, @D_ToLottable12    = NULL
           , @D_ToLottable13    = NULL, @D_ToLottable14    = NULL, @D_ToLottable15    = NULL
           , @D_FromChannel     = NULL, @D_ToChannel       = NULL, @D_FromChannel_ID  = NULL
           , @D_ToChannel_ID    = NULL, @D_FromSerialNo    = NULL, @D_ToSerialNo      = NULL
           , @D_FromPalletType  = NULL, @D_ToPalletType    = NULL, @D_TransferKey     = NULL
           , @D_TransferLineNumber=NULL,@D_FromStorerKey   = NULL, @D_FromSku         = NULL
           , @D_FromPackKey     = NULL, @D_FromUOM         = NULL, @D_ToStorerKey     = NULL
           , @D_ToSku           = NULL, @D_ToPackKey       = NULL, @D_ToUOM           = NULL
           , @D_Status          = NULL, @D_EffectiveDate   = NULL, @D_AddDate         = NULL
           , @D_AddWho          = NULL, @D_EditDate        = NULL, @D_EditWho         = NULL
           , @D_Temp01          = NULL, @D_Temp02          = NULL, @D_Temp03          = NULL
           , @D_Temp04          = NULL, @D_Temp05          = NULL, @D_Temp06          = NULL
           , @D_Temp07          = NULL, @D_Temp08          = NULL, @D_Temp09          = NULL
           , @D_Temp10          = NULL

      IF @b_debug = 1
         SELECT @c_SQL AS [Select Detail], @c_SQLParm_DTL AS SQLParam_DTL

      BEGIN TRY
         EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_DTL
            , @D_FromLoc         OUTPUT, @D_FromLot         OUTPUT, @D_FromId          OUTPUT
            , @D_FromQty         OUTPUT, @D_LOTTABLE01      OUTPUT, @D_LOTTABLE02      OUTPUT
            , @D_LOTTABLE03      OUTPUT, @D_LOTTABLE04      OUTPUT, @D_LOTTABLE05      OUTPUT
            , @D_ToLoc           OUTPUT, @D_ToLot           OUTPUT, @D_ToId            OUTPUT
            , @D_ToQty           OUTPUT, @D_tolottable01    OUTPUT, @D_tolottable02    OUTPUT
            , @D_tolottable03    OUTPUT, @D_tolottable04    OUTPUT, @D_tolottable05    OUTPUT
            , @D_UserDefine01    OUTPUT, @D_UserDefine02    OUTPUT, @D_UserDefine03    OUTPUT
            , @D_UserDefine04    OUTPUT, @D_UserDefine05    OUTPUT, @D_UserDefine06    OUTPUT
            , @D_UserDefine07    OUTPUT, @D_UserDefine08    OUTPUT, @D_UserDefine09    OUTPUT
            , @D_UserDefine10    OUTPUT, @D_Lottable06      OUTPUT, @D_Lottable07      OUTPUT
            , @D_Lottable08      OUTPUT, @D_Lottable09      OUTPUT, @D_Lottable10      OUTPUT
            , @D_Lottable11      OUTPUT, @D_Lottable12      OUTPUT, @D_Lottable13      OUTPUT
            , @D_Lottable14      OUTPUT, @D_Lottable15      OUTPUT, @D_ToLottable06    OUTPUT
            , @D_ToLottable07    OUTPUT, @D_ToLottable08    OUTPUT, @D_ToLottable09    OUTPUT
            , @D_ToLottable10    OUTPUT, @D_ToLottable11    OUTPUT, @D_ToLottable12    OUTPUT
            , @D_ToLottable13    OUTPUT, @D_ToLottable14    OUTPUT, @D_ToLottable15    OUTPUT
            , @D_FromChannel     OUTPUT, @D_ToChannel       OUTPUT, @D_FromChannel_ID  OUTPUT
            , @D_ToChannel_ID    OUTPUT, @D_FromSerialNo    OUTPUT, @D_ToSerialNo      OUTPUT
            , @D_FromPalletType  OUTPUT, @D_ToPalletType    OUTPUT, @D_TransferKey     OUTPUT
            , @D_TransferLineNumber OUTPUT,@D_FromStorerKey OUTPUT, @D_FromSku         OUTPUT
            , @D_FromPackKey     OUTPUT, @D_FromUOM         OUTPUT, @D_ToStorerKey     OUTPUT
            , @D_ToSku           OUTPUT, @D_ToPackKey       OUTPUT, @D_ToUOM           OUTPUT
            , @D_Status          OUTPUT, @D_EffectiveDate   OUTPUT, @D_AddDate         OUTPUT
            , @D_AddWho          OUTPUT, @D_EditDate        OUTPUT, @D_EditWho         OUTPUT
            , @D_Temp01          OUTPUT, @D_Temp02          OUTPUT, @D_Temp03          OUTPUT
            , @D_Temp04          OUTPUT, @D_Temp05          OUTPUT, @D_Temp06          OUTPUT
            , @D_Temp07          OUTPUT, @D_Temp08          OUTPUT, @D_Temp09          OUTPUT
            , @D_Temp10          OUTPUT
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err  = 61073
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Select Transfer Detail Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
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
               , @H_Type            OUTPUT, @H_GenerateHOCharges OUTPUT, @H_GenerateIS_HICharges OUTPUT
               , @H_ReLot           OUTPUT, @H_ReasonCode      OUTPUT, @H_CustomerRefNo   OUTPUT
               , @H_Remarks         OUTPUT, @H_PrintFlag       OUTPUT, @H_UserDefine01    OUTPUT
               , @H_UserDefine02    OUTPUT, @H_UserDefine03    OUTPUT, @H_UserDefine04    OUTPUT
               , @H_UserDefine05    OUTPUT, @H_UserDefine06    OUTPUT, @H_UserDefine07    OUTPUT
               , @H_UserDefine08    OUTPUT, @H_UserDefine09    OUTPUT, @H_UserDefine10    OUTPUT
               , @H_TransferKey     OUTPUT, @H_FromStorerKey   OUTPUT, @H_ToStorerKey     OUTPUT
               , @H_OpenQty         OUTPUT, @H_Status          OUTPUT, @H_EffectiveDate   OUTPUT
               , @H_AddDate         OUTPUT, @H_AddWho          OUTPUT, @H_EditDate        OUTPUT
               , @H_EditWho         OUTPUT, @H_Facility        OUTPUT, @H_ToFacility      OUTPUT
               , @D_FromLoc         OUTPUT, @D_FromLot         OUTPUT, @D_FromId          OUTPUT
               , @D_FromQty         OUTPUT, @D_LOTTABLE01      OUTPUT, @D_LOTTABLE02      OUTPUT
               , @D_LOTTABLE03      OUTPUT, @D_LOTTABLE04      OUTPUT, @D_LOTTABLE05      OUTPUT
               , @D_ToLoc           OUTPUT, @D_ToLot           OUTPUT, @D_ToId            OUTPUT
               , @D_ToQty           OUTPUT, @D_tolottable01    OUTPUT, @D_tolottable02    OUTPUT
               , @D_tolottable03    OUTPUT, @D_tolottable04    OUTPUT, @D_tolottable05    OUTPUT
               , @D_UserDefine01    OUTPUT, @D_UserDefine02    OUTPUT, @D_UserDefine03    OUTPUT
               , @D_UserDefine04    OUTPUT, @D_UserDefine05    OUTPUT, @D_UserDefine06    OUTPUT
               , @D_UserDefine07    OUTPUT, @D_UserDefine08    OUTPUT, @D_UserDefine09    OUTPUT
               , @D_UserDefine10    OUTPUT, @D_Lottable06      OUTPUT, @D_Lottable07      OUTPUT
               , @D_Lottable08      OUTPUT, @D_Lottable09      OUTPUT, @D_Lottable10      OUTPUT
               , @D_Lottable11      OUTPUT, @D_Lottable12      OUTPUT, @D_Lottable13      OUTPUT
               , @D_Lottable14      OUTPUT, @D_Lottable15      OUTPUT, @D_ToLottable06    OUTPUT
               , @D_ToLottable07    OUTPUT, @D_ToLottable08    OUTPUT, @D_ToLottable09    OUTPUT
               , @D_ToLottable10    OUTPUT, @D_ToLottable11    OUTPUT, @D_ToLottable12    OUTPUT
               , @D_ToLottable13    OUTPUT, @D_ToLottable14    OUTPUT, @D_ToLottable15    OUTPUT
               , @D_FromChannel     OUTPUT, @D_ToChannel       OUTPUT, @D_FromChannel_ID  OUTPUT
               , @D_ToChannel_ID    OUTPUT, @D_FromSerialNo    OUTPUT, @D_ToSerialNo      OUTPUT
               , @D_FromPalletType  OUTPUT, @D_ToPalletType    OUTPUT, @D_TransferKey     OUTPUT
               , @D_TransferLineNumber OUTPUT, @D_FromStorerKey OUTPUT,@D_FromSku         OUTPUT
               , @D_FromPackKey     OUTPUT, @D_FromUOM         OUTPUT, @D_ToStorerKey     OUTPUT
               , @D_ToSku           OUTPUT, @D_ToPackKey       OUTPUT, @D_ToUOM           OUTPUT
               , @D_Status          OUTPUT, @D_EffectiveDate   OUTPUT, @D_AddDate         OUTPUT
               , @D_AddWho          OUTPUT, @D_EditDate        OUTPUT, @D_EditWho         OUTPUT
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
            SET @c_SQL2 = @c_SQL2 + IIF(@c_SQL2<>'',' OR ','') + 'ISNULL(' + @c_Long + ','''')<>ISNULL(@D_' + @c_Long + ','''')'
         END
      END
      CLOSE CUR_UPDATE_DET
      DEALLOCATE CUR_UPDATE_DET

      IF ISNULL(@c_SQL,'')<>'' AND ISNULL(@c_SQL2,'')<>''
      BEGIN
         SET @c_SQL = 'UPDATE dbo.TRANSFERDETAIL WITH(ROWLOCK)'
           +' SET Trafficcop=NULL' + @c_SQL
           +' WHERE TransferKey = N''' + ISNULL(REPLACE(@c_TrfKey,'''',''''''),'') + ''''
           +' AND TransferLineNumber = N''' + ISNULL(REPLACE(@c_TrfLineNumber,'''',''''''),'') + ''''
           +' AND (' + @c_SQL2 + ')'

         IF @b_debug = 1
            SELECT @c_SQL AS [Update Detail Record], @c_SQLParm_UPDDTL AS SQLParam_UPDDTL

         BEGIN TRY
            EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_UPDDTL
               , @D_FromLoc      , @D_FromLot      , @D_FromId
               , @D_FromQty      , @D_LOTTABLE01   , @D_LOTTABLE02
               , @D_LOTTABLE03   , @D_LOTTABLE04   , @D_LOTTABLE05
               , @D_ToLoc        , @D_ToLot        , @D_ToId
               , @D_ToQty        , @D_tolottable01 , @D_tolottable02
               , @D_tolottable03 , @D_tolottable04 , @D_tolottable05
               , @D_UserDefine01 , @D_UserDefine02 , @D_UserDefine03
               , @D_UserDefine04 , @D_UserDefine05 , @D_UserDefine06
               , @D_UserDefine07 , @D_UserDefine08 , @D_UserDefine09
               , @D_UserDefine10 , @D_Lottable06   , @D_Lottable07
               , @D_Lottable08   , @D_Lottable09   , @D_Lottable10
               , @D_Lottable11   , @D_Lottable12   , @D_Lottable13
               , @D_Lottable14   , @D_Lottable15   , @D_ToLottable06
               , @D_ToLottable07 , @D_ToLottable08 , @D_ToLottable09
               , @D_ToLottable10 , @D_ToLottable11 , @D_ToLottable12
               , @D_ToLottable13 , @D_ToLottable14 , @D_ToLottable15
               , @D_FromChannel  , @D_ToChannel    , @D_FromChannel_ID
               , @D_ToChannel_ID , @D_FromSerialNo , @D_ToSerialNo
               , @D_FromPalletType,@D_ToPalletType
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err  = 61075
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Transfer Detail Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
            GOTO QUIT_SP
         END CATCH
      END
   END
   CLOSE CUR_TRF_DTL
   DEALLOCATE CUR_TRF_DTL


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
         SET @c_SQL2 = @c_SQL2 + IIF(@c_SQL2<>'',' OR ','') + 'ISNULL(' + @c_Long + ','''')<>ISNULL(@H_' + @c_Long + ','''')'
      END
   END
   CLOSE CUR_UPDATE_HDR
   DEALLOCATE CUR_UPDATE_HDR

   IF ISNULL(@c_SQL,'')<>'' AND ISNULL(@c_SQL2,'')<>''
   BEGIN
      SET @c_SQL = 'UPDATE dbo.TRANSFER WITH(ROWLOCK)'
        +' SET Trafficcop=NULL' + @c_SQL
        +' WHERE TransferKey = N''' + ISNULL(REPLACE(@c_TransferKey,'''',''''''),'') + ''''
        +' AND (' + @c_SQL2 + ')'

      IF @b_debug = 1
         SELECT @c_SQL AS [Update Header Record], @c_SQLParm_UPDHDR AS SQLParam_UPDHDR

      BEGIN TRY
         EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_UPDHDR
            , @H_Type         , @H_GenerateHOCharges, @H_GenerateIS_HICharges
            , @H_ReLot        , @H_ReasonCode    , @H_CustomerRefNo
            , @H_Remarks      , @H_PrintFlag     , @H_UserDefine01
            , @H_UserDefine02 , @H_UserDefine03  , @H_UserDefine04
            , @H_UserDefine05 , @H_UserDefine06  , @H_UserDefine07
            , @H_UserDefine08 , @H_UserDefine09  , @H_UserDefine10
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err  = 61076
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Transfer Header Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
         GOTO QUIT_SP
      END CATCH
   END

STEP_2:


QUIT_SP:
   IF XACT_STATE() = -1   --(-1 = uncommittable)
      ROLLBACK TRAN

   IF CURSOR_STATUS( 'LOCAL', 'CUR_TRF_DTL') in (0 , 1)
   BEGIN
      CLOSE CUR_TRF_DTL
      DEALLOCATE CUR_TRF_DTL
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
GRANT EXECUTE ON [dbo].[ispPRTRFGP] TO nSQL
GO
