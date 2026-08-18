SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ispPRKITGP                                                  */
/* Creation Date: 2026-07-21                                            */
/* Copyright: Maersk                                                    */
/* Written by: Michael                                                  */
/*                                                                      */
/* Purpose: Generic SP for PreFinalizeKitSP                             */
/*                                                                      */
/* Called By: ntrKitHeaderUpdate -> ispPreFinalizeKitWrapper            */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 2026-06-02   Michael   1.0 UWP-61992-PreFinalizeKitSP GenericSP(ML01)*/
/************************************************************************/
CREATE OR ALTER PROC ispPRKITGP
  @c_Kitkey      NVARCHAR(10)
, @b_Success     INT = 1  OUTPUT
, @n_err         INT = 0  OUTPUT
, @c_errmsg      NVARCHAR(255) = '' OUTPUT
AS
BEGIN
/* STORERCONFIG
   .ConfigKey = 'PreFinalizeKitSP'
   .SValue    = 'ispPRKITGP'
   .OPTION5   = '@c_ExtPreFinalizeKitSP=xxx'  -- Calling another PreFinalizeKitSP if setup

   CODELKUP
   .ListName  =  'PREKITCFG'
   .Code2     =  'ispPRKITGP'
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
         , @c_SP_Name          NVARCHAR(128) = 'ispPRKITGP'
         , @c_x_KitKey         NVARCHAR(10)
         , @c_x_Type           NVARCHAR(5)
         , @c_x_KitLineNumber  NVARCHAR(5)
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
         , @c_ListName         NVARCHAR(10)  = 'PREKITCFG'
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
         , @c_ExtPreFinalizeKitSP NVARCHAR(MAX) = ''

   DECLARE @H_Type             NVARCHAR(12)
         , @H_EffectiveDate    DATETIME
         , @H_ReasonCode       NVARCHAR(10)
         , @H_CustomerRefNo    NVARCHAR(10)
         , @H_Remarks          NVARCHAR(500)
         , @H_GenerateHOCharges    NVARCHAR(10)
         , @H_GenerateIS_HiCharges NVARCHAR(10)
         , @H_USRDEF1          NVARCHAR(18)
         , @H_USRDEF2          NVARCHAR(18)
         , @H_USRDEF3          NVARCHAR(18)
         , @H_ActionFlag       NVARCHAR(1)
         , @H_ExternKitKey     NVARCHAR(20)
         , @H_USRDEF4          NVARCHAR(30)
         , @H_USRDEF5          NVARCHAR(30)
         , @H_USRDEF6          DATETIME
         , @H_USRDEF7          DATETIME
         , @H_USRDEF8          NVARCHAR(30)
         , @H_USRDEF9          NVARCHAR(30)
         , @H_USRDEF10         NVARCHAR(30)
         , @H_USRDEF11         NVARCHAR(30)
         , @H_USRDEF12         NVARCHAR(30)
         , @H_USRDEF13         NVARCHAR(30)
         , @H_USRDEF14         DATETIME
         , @H_USRDEF15         DATETIME
         , @H_ExternStatus     NVARCHAR(30)

   DECLARE @H_KITKey           NVARCHAR(10)
         , @H_StorerKey        NVARCHAR(15)
         , @H_ToStorerKey      NVARCHAR(15)
         , @H_OpenQty          INT
         , @H_Status           NVARCHAR(10)
         , @H_AddDate          DATETIME
         , @H_AddWho           NVARCHAR(128)
         , @H_EditDate         DATETIME
         , @H_EditWho          NVARCHAR(128)
         , @H_Facility         NVARCHAR(5)
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

   DECLARE @D_Lot              NVARCHAR(10)
         , @D_Loc              NVARCHAR(10)
         , @D_Id               NVARCHAR(18)
         , @D_ExpectedQty      INT
         , @D_Qty              INT
         , @D_LOTTABLE01       NVARCHAR(18)
         , @D_LOTTABLE02       NVARCHAR(18)
         , @D_LOTTABLE03       NVARCHAR(18)
         , @D_LOTTABLE04       DATETIME
         , @D_LOTTABLE05       DATETIME
         , @D_ExternKitKey     NVARCHAR(20)
         , @D_ExternLineNo     NVARCHAR(10)
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
         , @D_UCCNo            NVARCHAR(20)

   DECLARE @D_KITKey           NVARCHAR(10)
         , @D_KITLineNumber    NVARCHAR(5)
         , @D_Type             NVARCHAR(5)
         , @D_StorerKey        NVARCHAR(15)
         , @D_Sku              NVARCHAR(20)
         , @D_PackKey          NVARCHAR(10)
         , @D_UOM              NVARCHAR(10)
         , @D_Status           NVARCHAR(10)
         , @D_EffectiveDate    DATETIME
         , @D_AddDate          DATETIME
         , @D_AddWho           NVARCHAR(128)
         , @D_EditDate         DATETIME
         , @D_EditWho          NVARCHAR(128)
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
   FROM dbo.KIT WITH(NOLOCK)
   WHERE KitKey = @c_KitKey

   -- Extended PreFinalizeKitSP
   SELECT @c_Option5 = SC.Option5
   FROM dbo.fnc_GetRight2(@c_x_Facility, @c_x_Storerkey, '', 'PreFinalizeKitSP') AS SC
   WHERE Authority='ispPRKITGP'

   SELECT @c_ExtPreFinalizeKitSP = dbo.fnc_GetParamValueFromString ('@c_ExtPreFinalizeKitSP', @c_option5, '')

   IF ISNULL(@c_ExtPreFinalizeKitSP,'') NOT IN ('', @c_SP_Name) AND
      EXISTS (SELECT 1 FROM sys.objects WHERE name = @c_ExtPreFinalizeKitSP AND [type] = 'P')
   BEGIN
      SET @c_SQL = N'EXECUTE ' + @c_ExtPreFinalizeKitSP
        + ' @c_KitKey   = @c_KitKey'
        +', @b_Success  = @b_Success OUTPUT'
        +', @n_Err      = @n_Err     OUTPUT'
        +', @c_ErrMsg   = @c_ErrMsg  OUTPUT'

      SET @c_SQLParm =
          N'@c_KitKey  NVARCHAR(10)'
        +', @b_Success INT OUTPUT'
        +', @n_Err     INT OUTPUT'
        +', @c_ErrMsg  NVARCHAR(255) OUTPUT '

      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm
         , @c_KitKey
         , @b_Success OUTPUT
         , @n_Err     OUTPUT
         , @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
         GOTO QUIT_SP
      END
   END

   -- Check existing of PREKITCFG setup
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

   -- Get PREKITCFG setup
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

   IF OBJECT_ID('tempdb..#TMP_KIT_LINE') IS NOT NULL
      DROP TABLE #TMP_KIT_LINE

   CREATE TABLE #TMP_KIT_LINE (
      Row_ID        INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    , KitKey        NVARCHAR(10) NOT NULL DEFAULT('')
    , [Type]        NVARCHAR(5)  NOT NULL DEFAULT('F')
    , KitLineNumber NVARCHAR(5)  NOT NULL DEFAULT('')
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

   ---------------------------------------
   -- Select KIT Detail into Temp Table --
   ---------------------------------------
   SET @c_SQL =
      N'INSERT INTO #TMP_KIT_LINE (KitKey, [Type], KitLineNumber)'
     +' SELECT KITDETAIL.KitKey'
     +      ', KITDETAIL.[Type]'
     +      ', KITDETAIL.KitLineNumber'
     +' FROM dbo.KIT WITH(NOLOCK)'
     +' JOIN dbo.KITDETAIL WITH(NOLOCK) ON KIT.KitKey=KITDETAIL.KitKey'

   IF ISNULL(@c_SEL_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_SEL_JOIN

   SET @c_SQL = @c_SQL
     +' WHERE KIT.KitKey = N''' + ISNULL(REPLACE(@c_KitKey,'''',''''''),'') + ''''
     +  ' AND ISNULL(KITDETAIL.Status,'''') <> ''9'''

   IF ISNULL(@c_SEL_WHERE,'') <> ''
      SET @c_SQL = @c_SQL
        + ' AND (' + @c_SEL_WHERE + ')'

   IF ISNULL(@c_SEL_SORT,'') <> ''
      SET @c_SQL = @c_SQL + ' ORDER BY ' + @c_SEL_SORT
   ELSE
      SET @c_SQL = @c_SQL + ' ORDER BY 1, 2, 3'

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

   IF NOT EXISTS(SELECT TOP 1 1 FROM #TMP_KIT_LINE)
      GOTO STEP_2


   SET @c_HDR_UPD_Fields =
      ',Type,EffectiveDate,ReasonCode,CustomerRefNo,Remarks,GenerateHOCharges,GenerateIS_HiCharges,USRDEF1,USRDEF2,USRDEF3'
     +',ActionFlag,ExternKitKey,USRDEF4,USRDEF5,USRDEF6,USRDEF7,USRDEF8,USRDEF9,USRDEF10,USRDEF11'
     +',USRDEF12,USRDEF13,USRDEF14,USRDEF15,ExternStatus,'

   SET @c_DTL_UPD_Fields =
      ',Lot,Loc,Id,ExpectedQty,Qty,LOTTABLE01,LOTTABLE02,LOTTABLE03,LOTTABLE04,LOTTABLE05'
     +',ExternKitKey,ExternLineNo,Lottable06,Lottable07,Lottable08,Lottable09,Lottable10,Lottable11,Lottable12,Lottable13'
     +',Lottable14,Lottable15,Channel,UCCNo,'

   SET @c_SQLParm_HDR
     =  '@H_Type           NVARCHAR(12)  OUTPUT, @H_EffectiveDate  DATETIME      OUTPUT, @H_ReasonCode     NVARCHAR(10)  OUTPUT'
     +', @H_CustomerRefNo  NVARCHAR(10)  OUTPUT, @H_Remarks        NVARCHAR(500) OUTPUT, @H_GenerateHOCharges NVARCHAR(10) OUTPUT'
     +', @H_GenerateIS_HiCharges NVARCHAR(10) OUTPUT, @H_USRDEF1   NVARCHAR(18)  OUTPUT, @H_USRDEF2        NVARCHAR(18)  OUTPUT'
     +', @H_USRDEF3        NVARCHAR(18)  OUTPUT, @H_ActionFlag     NVARCHAR(1)   OUTPUT, @H_ExternKitKey   NVARCHAR(20)  OUTPUT'
     +', @H_USRDEF4        NVARCHAR(30)  OUTPUT, @H_USRDEF5        NVARCHAR(30)  OUTPUT, @H_USRDEF6        DATETIME      OUTPUT'
     +', @H_USRDEF7        DATETIME      OUTPUT, @H_USRDEF8        NVARCHAR(30)  OUTPUT, @H_USRDEF9        NVARCHAR(30)  OUTPUT'
     +', @H_USRDEF10       NVARCHAR(30)  OUTPUT, @H_USRDEF11       NVARCHAR(30)  OUTPUT, @H_USRDEF12       NVARCHAR(30)  OUTPUT'
     +', @H_USRDEF13       NVARCHAR(30)  OUTPUT, @H_USRDEF14       DATETIME      OUTPUT, @H_USRDEF15       DATETIME      OUTPUT'
     +', @H_ExternStatus   NVARCHAR(30)  OUTPUT'
     +', @H_KITKey         NVARCHAR(10)  OUTPUT, @H_StorerKey      NVARCHAR(15)  OUTPUT, @H_ToStorerKey    NVARCHAR(15)  OUTPUT'
     +', @H_OpenQty        INT           OUTPUT, @H_Status         NVARCHAR(10)  OUTPUT, @H_AddDate        DATETIME      OUTPUT'
     +', @H_AddWho         NVARCHAR(128) OUTPUT, @H_EditDate       DATETIME      OUTPUT, @H_EditWho        NVARCHAR(128) OUTPUT'
     +', @H_Facility       NVARCHAR(5)   OUTPUT'
     +', @H_Temp01         NVARCHAR(MAX) OUTPUT, @H_Temp02         NVARCHAR(MAX) OUTPUT, @H_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp04         NVARCHAR(MAX) OUTPUT, @H_Temp05         NVARCHAR(MAX) OUTPUT, @H_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp07         NVARCHAR(MAX) OUTPUT, @H_Temp08         NVARCHAR(MAX) OUTPUT, @H_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp10         NVARCHAR(MAX) OUTPUT'

   SET @c_SQLParm_DTL
     =  '@D_Lot            NVARCHAR(10)  OUTPUT, @D_Loc            NVARCHAR(10)  OUTPUT, @D_Id             NVARCHAR(18)  OUTPUT'
     +', @D_ExpectedQty    INT           OUTPUT, @D_Qty            INT           OUTPUT, @D_LOTTABLE01     NVARCHAR(18)  OUTPUT'
     +', @D_LOTTABLE02     NVARCHAR(18)  OUTPUT, @D_LOTTABLE03     NVARCHAR(18)  OUTPUT, @D_LOTTABLE04     DATETIME      OUTPUT'
     +', @D_LOTTABLE05     DATETIME      OUTPUT, @D_ExternKitKey   NVARCHAR(20)  OUTPUT, @D_ExternLineNo   NVARCHAR(10)  OUTPUT'
     +', @D_Lottable06     NVARCHAR(30)  OUTPUT, @D_Lottable07     NVARCHAR(30)  OUTPUT, @D_Lottable08     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable09     NVARCHAR(30)  OUTPUT, @D_Lottable10     NVARCHAR(30)  OUTPUT, @D_Lottable11     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable12     NVARCHAR(30)  OUTPUT, @D_Lottable13     DATETIME      OUTPUT, @D_Lottable14     DATETIME      OUTPUT'
     +', @D_Lottable15     DATETIME      OUTPUT, @D_Channel        NVARCHAR(20)  OUTPUT, @D_UCCNo          NVARCHAR(20)  OUTPUT'
     +', @D_KITKey         NVARCHAR(10)  OUTPUT, @D_KITLineNumber  NVARCHAR(5)   OUTPUT, @D_Type           NVARCHAR(5)   OUTPUT'
     +', @D_StorerKey      NVARCHAR(15)  OUTPUT, @D_Sku            NVARCHAR(20)  OUTPUT, @D_PackKey        NVARCHAR(10)  OUTPUT'
     +', @D_UOM            NVARCHAR(10)  OUTPUT, @D_Status         NVARCHAR(10)  OUTPUT, @D_EffectiveDate  DATETIME      OUTPUT'
     +', @D_AddDate        DATETIME      OUTPUT, @D_AddWho         NVARCHAR(128) OUTPUT, @D_EditDate       DATETIME      OUTPUT'
     +', @D_EditWho        NVARCHAR(128) OUTPUT, @D_Channel_ID     BIGINT        OUTPUT, @D_PalletType     NVARCHAR(10)  OUTPUT'
     +', @D_Temp01         NVARCHAR(MAX) OUTPUT, @D_Temp02         NVARCHAR(MAX) OUTPUT, @D_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp04         NVARCHAR(MAX) OUTPUT, @D_Temp05         NVARCHAR(MAX) OUTPUT, @D_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp07         NVARCHAR(MAX) OUTPUT, @D_Temp08         NVARCHAR(MAX) OUTPUT, @D_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp10         NVARCHAR(MAX) OUTPUT'

   SET @c_SQLParm_VAR
     =  '@H_Type           NVARCHAR(12)  OUTPUT, @H_EffectiveDate  DATETIME      OUTPUT, @H_ReasonCode     NVARCHAR(10)  OUTPUT'
     +', @H_CustomerRefNo  NVARCHAR(10)  OUTPUT, @H_Remarks        NVARCHAR(500) OUTPUT, @H_GenerateHOCharges NVARCHAR(10) OUTPUT'
     +', @H_GenerateIS_HiCharges NVARCHAR(10) OUTPUT, @H_USRDEF1   NVARCHAR(18)  OUTPUT, @H_USRDEF2        NVARCHAR(18)  OUTPUT'
     +', @H_USRDEF3        NVARCHAR(18)  OUTPUT, @H_ActionFlag     NVARCHAR(1)   OUTPUT, @H_ExternKitKey   NVARCHAR(20)  OUTPUT'
     +', @H_USRDEF4        NVARCHAR(30)  OUTPUT, @H_USRDEF5        NVARCHAR(30)  OUTPUT, @H_USRDEF6        DATETIME      OUTPUT'
     +', @H_USRDEF7        DATETIME      OUTPUT, @H_USRDEF8        NVARCHAR(30)  OUTPUT, @H_USRDEF9        NVARCHAR(30)  OUTPUT'
     +', @H_USRDEF10       NVARCHAR(30)  OUTPUT, @H_USRDEF11       NVARCHAR(30)  OUTPUT, @H_USRDEF12       NVARCHAR(30)  OUTPUT'
     +', @H_USRDEF13       NVARCHAR(30)  OUTPUT, @H_USRDEF14       DATETIME      OUTPUT, @H_USRDEF15       DATETIME      OUTPUT'
     +', @H_ExternStatus   NVARCHAR(30)  OUTPUT'
     +', @H_KITKey         NVARCHAR(10)  OUTPUT, @H_StorerKey      NVARCHAR(15)  OUTPUT, @H_ToStorerKey    NVARCHAR(15)  OUTPUT'
     +', @H_OpenQty        INT           OUTPUT, @H_Status         NVARCHAR(10)  OUTPUT, @H_AddDate        DATETIME      OUTPUT'
     +', @H_AddWho         NVARCHAR(128) OUTPUT, @H_EditDate       DATETIME      OUTPUT, @H_EditWho        NVARCHAR(128) OUTPUT'
     +', @H_Facility       NVARCHAR(5)   OUTPUT'
     +', @D_Lot            NVARCHAR(10)  OUTPUT, @D_Loc            NVARCHAR(10)  OUTPUT, @D_Id             NVARCHAR(18)  OUTPUT'
     +', @D_ExpectedQty    INT           OUTPUT, @D_Qty            INT           OUTPUT, @D_LOTTABLE01     NVARCHAR(18)  OUTPUT'
     +', @D_LOTTABLE02     NVARCHAR(18)  OUTPUT, @D_LOTTABLE03     NVARCHAR(18)  OUTPUT, @D_LOTTABLE04     DATETIME      OUTPUT'
     +', @D_LOTTABLE05     DATETIME      OUTPUT, @D_ExternKitKey   NVARCHAR(20)  OUTPUT, @D_ExternLineNo   NVARCHAR(10)  OUTPUT'
     +', @D_Lottable06     NVARCHAR(30)  OUTPUT, @D_Lottable07     NVARCHAR(30)  OUTPUT, @D_Lottable08     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable09     NVARCHAR(30)  OUTPUT, @D_Lottable10     NVARCHAR(30)  OUTPUT, @D_Lottable11     NVARCHAR(30)  OUTPUT'
     +', @D_Lottable12     NVARCHAR(30)  OUTPUT, @D_Lottable13     DATETIME      OUTPUT, @D_Lottable14     DATETIME      OUTPUT'
     +', @D_Lottable15     DATETIME      OUTPUT, @D_Channel        NVARCHAR(20)  OUTPUT, @D_UCCNo          NVARCHAR(20)  OUTPUT'
     +', @D_KITKey         NVARCHAR(10)  OUTPUT, @D_KITLineNumber  NVARCHAR(5)   OUTPUT, @D_Type           NVARCHAR(5)   OUTPUT'
     +', @D_StorerKey      NVARCHAR(15)  OUTPUT, @D_Sku            NVARCHAR(20)  OUTPUT, @D_PackKey        NVARCHAR(10)  OUTPUT'
     +', @D_UOM            NVARCHAR(10)  OUTPUT, @D_Status         NVARCHAR(10)  OUTPUT, @D_EffectiveDate  DATETIME      OUTPUT'
     +', @D_AddDate        DATETIME      OUTPUT, @D_AddWho         NVARCHAR(128) OUTPUT, @D_EditDate       DATETIME      OUTPUT'
     +', @D_EditWho        NVARCHAR(128) OUTPUT, @D_Channel_ID     BIGINT        OUTPUT, @D_PalletType     NVARCHAR(10)  OUTPUT'
     +', @H_Temp01         NVARCHAR(MAX) OUTPUT, @H_Temp02         NVARCHAR(MAX) OUTPUT, @H_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp04         NVARCHAR(MAX) OUTPUT, @H_Temp05         NVARCHAR(MAX) OUTPUT, @H_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp07         NVARCHAR(MAX) OUTPUT, @H_Temp08         NVARCHAR(MAX) OUTPUT, @H_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @H_Temp10         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp01         NVARCHAR(MAX) OUTPUT, @D_Temp02         NVARCHAR(MAX) OUTPUT, @D_Temp03         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp04         NVARCHAR(MAX) OUTPUT, @D_Temp05         NVARCHAR(MAX) OUTPUT, @D_Temp06         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp07         NVARCHAR(MAX) OUTPUT, @D_Temp08         NVARCHAR(MAX) OUTPUT, @D_Temp09         NVARCHAR(MAX) OUTPUT'
     +', @D_Temp10         NVARCHAR(MAX) OUTPUT'


   SET @c_SQLParm_UPDDTL
     =  '@D_Lot            NVARCHAR(10) , @D_Loc             NVARCHAR(10) , @D_Id            NVARCHAR(18)'
     +', @D_ExpectedQty    INT          , @D_Qty             INT          , @D_LOTTABLE01    NVARCHAR(18)'
     +', @D_LOTTABLE02     NVARCHAR(18) , @D_LOTTABLE03      NVARCHAR(18) , @D_LOTTABLE04    DATETIME'
     +', @D_LOTTABLE05     DATETIME     , @D_ExternKitKey    NVARCHAR(20) , @D_ExternLineNo  NVARCHAR(10)'
     +', @D_Lottable06     NVARCHAR(30) , @D_Lottable07      NVARCHAR(30) , @D_Lottable08    NVARCHAR(30)'
     +', @D_Lottable09     NVARCHAR(30) , @D_Lottable10      NVARCHAR(30) , @D_Lottable11    NVARCHAR(30)'
     +', @D_Lottable12     NVARCHAR(30) , @D_Lottable13      DATETIME     , @D_Lottable14    DATETIME'
     +', @D_Lottable15     DATETIME     , @D_Channel         NVARCHAR(20) , @D_UCCNo         NVARCHAR(20)'

   SET @c_SQLParm_UPDHDR
     =  '@H_Type           NVARCHAR(12) , @H_EffectiveDate   DATETIME     , @H_ReasonCode    NVARCHAR(10)'
     +', @H_CustomerRefNo  NVARCHAR(10) , @H_Remarks         NVARCHAR(500), @H_GenerateHOCharges NVARCHAR(10)'
     +', @H_GenerateIS_HiCharges NVARCHAR(10), @H_USRDEF1    NVARCHAR(18) , @H_USRDEF2       NVARCHAR(18)'
     +', @H_USRDEF3        NVARCHAR(18) , @H_ActionFlag      NVARCHAR(1)  , @H_ExternKitKey  NVARCHAR(20)'
     +', @H_USRDEF4        NVARCHAR(30) , @H_USRDEF5         NVARCHAR(30) , @H_USRDEF6       DATETIME'
     +', @H_USRDEF7        DATETIME     , @H_USRDEF8         NVARCHAR(30) , @H_USRDEF9       NVARCHAR(30)'
     +', @H_USRDEF10       NVARCHAR(30) , @H_USRDEF11        NVARCHAR(30) , @H_USRDEF12      NVARCHAR(30)'
     +', @H_USRDEF13       NVARCHAR(30) , @H_USRDEF14        DATETIME     , @H_USRDEF15      DATETIME'
     +', @H_ExternStatus   NVARCHAR(30)'

   --------------------------
   -- Select Header Fields --
   --------------------------
   SET @c_SQL = 'SELECT TOP 1'
     + ' @H_Type           = <<KIT.Type>>'
     +', @H_EffectiveDate  = <<KIT.EffectiveDate>>'
     +', @H_ReasonCode     = <<KIT.ReasonCode>>'
     +', @H_CustomerRefNo  = <<KIT.CustomerRefNo>>'
     +', @H_Remarks        = <<KIT.Remarks>>'
     +', @H_GenerateHOCharges    = <<KIT.GenerateHOCharges>>'
     +', @H_GenerateIS_HiCharges = <<KIT.GenerateIS_HiCharges>>'
     +', @H_USRDEF1        = <<KIT.USRDEF1>>'
     +', @H_USRDEF2        = <<KIT.USRDEF2>>'
     +', @H_USRDEF3        = <<KIT.USRDEF3>>'
     +', @H_ActionFlag     = <<KIT.ActionFlag>>'
     +', @H_ExternKitKey   = <<KIT.ExternKitKey>>'
     +', @H_USRDEF4        = <<KIT.USRDEF4>>'
     +', @H_USRDEF5        = <<KIT.USRDEF5>>'
     +', @H_USRDEF6        = <<KIT.USRDEF6>>'
     +', @H_USRDEF7        = <<KIT.USRDEF7>>'
     +', @H_USRDEF8        = <<KIT.USRDEF8>>'
     +', @H_USRDEF9        = <<KIT.USRDEF9>>'
     +', @H_USRDEF10       = <<KIT.USRDEF10>>'
     +', @H_USRDEF11       = <<KIT.USRDEF11>>'
     +', @H_USRDEF12       = <<KIT.USRDEF12>>'
     +', @H_USRDEF13       = <<KIT.USRDEF13>>'
     +', @H_USRDEF14       = <<KIT.USRDEF14>>'
     +', @H_USRDEF15       = <<KIT.USRDEF15>>'
     +', @H_ExternStatus   = <<KIT.ExternStatus>>'
     +', @H_KITKey         = <<KIT.KITKey>>'
     +', @H_StorerKey      = <<KIT.StorerKey>>'
     +', @H_ToStorerKey    = <<KIT.ToStorerKey>>'
     +', @H_OpenQty        = <<KIT.OpenQty>>'
     +', @H_Status         = <<KIT.Status>>'
     +', @H_AddDate        = <<KIT.AddDate>>'
     +', @H_AddWho         = <<KIT.AddWho>>'
     +', @H_EditDate       = <<KIT.EditDate>>'
     +', @H_EditWho        = <<KIT.EditWho>>'
     +', @H_Facility       = <<KIT.Facility>>'
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
     +' FROM dbo.KIT WITH(NOLOCK)'

   IF ISNULL(@c_HDR_JOIN,'') <> ''
      SET @c_SQL = @c_SQL + ' ' + @c_HDR_JOIN

   SET @c_SQL = @c_SQL
     + ' WHERE KIT.KitKey = N''' + ISNULL(REPLACE(@c_KitKey,'''',''''''),'') + ''''

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
         SET @c_Long = '<<' + CASE WHEN @c_Long LIKE '@%' THEN '' ELSE 'KIT.' END + @c_Long + '>>'
         SET @c_SQL = REPLACE(@c_SQL, ISNULL(@c_Long,''), @c_Notes)
      END
   END
   CLOSE CUR_CLK_UPD_HDR
   DEALLOCATE CUR_CLK_UPD_HDR

   SET @c_SQL = REPLACE(REPLACE(@c_SQL, '<<', ''), '>>', '')

   SELECT @H_Type           = NULL, @H_EffectiveDate  = NULL, @H_ReasonCode     = NULL
        , @H_CustomerRefNo  = NULL, @H_Remarks        = NULL, @H_GenerateHOCharges = NULL
        , @H_GenerateIS_HiCharges = NULL, @H_USRDEF1  = NULL, @H_USRDEF2        = NULL
        , @H_USRDEF3        = NULL, @H_ActionFlag     = NULL, @H_ExternKitKey   = NULL
        , @H_USRDEF4        = NULL, @H_USRDEF5        = NULL, @H_USRDEF6        = NULL
        , @H_USRDEF7        = NULL, @H_USRDEF8        = NULL, @H_USRDEF9        = NULL
        , @H_USRDEF10       = NULL, @H_USRDEF11       = NULL, @H_USRDEF12       = NULL
        , @H_USRDEF13       = NULL, @H_USRDEF14       = NULL, @H_USRDEF15       = NULL
        , @H_ExternStatus   = NULL, @H_KITKey         = NULL, @H_StorerKey      = NULL
        , @H_ToStorerKey    = NULL, @H_OpenQty        = NULL, @H_Status         = NULL
        , @H_AddDate        = NULL, @H_AddWho         = NULL, @H_EditDate       = NULL
        , @H_EditWho        = NULL, @H_Facility       = NULL
        , @H_Temp01         = NULL, @H_Temp02         = NULL, @H_Temp03         = NULL
        , @H_Temp04         = NULL, @H_Temp05         = NULL, @H_Temp06         = NULL
        , @H_Temp07         = NULL, @H_Temp08         = NULL, @H_Temp09         = NULL
        , @H_Temp10         = NULL

   IF @b_debug = 1
      SELECT @c_SQL AS [Select Header], @c_SQLParm_HDR AS SQLParam_HDR

   BEGIN TRY
      EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_HDR
         , @H_Type            OUTPUT, @H_EffectiveDate   OUTPUT, @H_ReasonCode      OUTPUT
         , @H_CustomerRefNo   OUTPUT, @H_Remarks         OUTPUT, @H_GenerateHOCharges OUTPUT
         , @H_GenerateIS_HiCharges OUTPUT, @H_USRDEF1    OUTPUT, @H_USRDEF2         OUTPUT
         , @H_USRDEF3         OUTPUT, @H_ActionFlag      OUTPUT, @H_ExternKitKey    OUTPUT
         , @H_USRDEF4         OUTPUT, @H_USRDEF5         OUTPUT, @H_USRDEF6         OUTPUT
         , @H_USRDEF7         OUTPUT, @H_USRDEF8         OUTPUT, @H_USRDEF9         OUTPUT
         , @H_USRDEF10        OUTPUT, @H_USRDEF11        OUTPUT, @H_USRDEF12        OUTPUT
         , @H_USRDEF13        OUTPUT, @H_USRDEF14        OUTPUT, @H_USRDEF15        OUTPUT
         , @H_ExternStatus    OUTPUT, @H_KITKey          OUTPUT, @H_StorerKey       OUTPUT
         , @H_ToStorerKey     OUTPUT, @H_OpenQty         OUTPUT, @H_Status          OUTPUT
         , @H_AddDate         OUTPUT, @H_AddWho          OUTPUT, @H_EditDate        OUTPUT
         , @H_EditWho         OUTPUT, @H_Facility        OUTPUT
         , @H_Temp01          OUTPUT, @H_Temp02          OUTPUT, @H_Temp03          OUTPUT
         , @H_Temp04          OUTPUT, @H_Temp05          OUTPUT, @H_Temp06          OUTPUT
         , @H_Temp07          OUTPUT, @H_Temp08          OUTPUT, @H_Temp09          OUTPUT
         , @H_Temp10          OUTPUT
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @n_err  = 61072
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Select KIT Header Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
      GOTO QUIT_SP
   END CATCH


   --------------------------
   -- Select Detail Fields --
   --------------------------
   DECLARE CUR_KIT_DTL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT KitKey
        , [Type]
        , KitLineNumber
   FROM #TMP_KIT_LINE
   ORDER BY Row_ID

   OPEN CUR_KIT_DTL

   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_KIT_DTL
       INTO @c_x_KitKey, @c_x_Type, @c_x_KitLineNumber

      IF @@FETCH_STATUS<>0
         BREAK

      SET @c_SQL = 'SELECT TOP 1'
        + ' @D_Lot            = <<KITDETAIL.Lot>>'
        +', @D_Loc            = <<KITDETAIL.Loc>>'
        +', @D_Id             = <<KITDETAIL.Id>>'
        +', @D_ExpectedQty    = <<KITDETAIL.ExpectedQty>>'
        +', @D_Qty            = <<KITDETAIL.Qty>>'
        +', @D_LOTTABLE01     = <<KITDETAIL.LOTTABLE01>>'
        +', @D_LOTTABLE02     = <<KITDETAIL.LOTTABLE02>>'
        +', @D_LOTTABLE03     = <<KITDETAIL.LOTTABLE03>>'
        +', @D_LOTTABLE04     = <<KITDETAIL.LOTTABLE04>>'
        +', @D_LOTTABLE05     = <<KITDETAIL.LOTTABLE05>>'
        +', @D_ExternKitKey   = <<KITDETAIL.ExternKitKey>>'
        +', @D_ExternLineNo   = <<KITDETAIL.ExternLineNo>>'
        +', @D_Lottable06     = <<KITDETAIL.Lottable06>>'
        +', @D_Lottable07     = <<KITDETAIL.Lottable07>>'
        +', @D_Lottable08     = <<KITDETAIL.Lottable08>>'
        +', @D_Lottable09     = <<KITDETAIL.Lottable09>>'
        +', @D_Lottable10     = <<KITDETAIL.Lottable10>>'
        +', @D_Lottable11     = <<KITDETAIL.Lottable11>>'
        +', @D_Lottable12     = <<KITDETAIL.Lottable12>>'
        +', @D_Lottable13     = <<KITDETAIL.Lottable13>>'
        +', @D_Lottable14     = <<KITDETAIL.Lottable14>>'
        +', @D_Lottable15     = <<KITDETAIL.Lottable15>>'
        +', @D_Channel        = <<KITDETAIL.Channel>>'
        +', @D_UCCNo          = <<KITDETAIL.UCCNo>>'
        +', @D_KITKey         = <<KITDETAIL.KITKey>>'
        +', @D_KITLineNumber  = <<KITDETAIL.KITLineNumber>>'
        +', @D_Type           = <<KITDETAIL.Type>>'
        +', @D_StorerKey      = <<KITDETAIL.StorerKey>>'
        +', @D_Sku            = <<KITDETAIL.Sku>>'
        +', @D_PackKey        = <<KITDETAIL.PackKey>>'
        +', @D_UOM            = <<KITDETAIL.UOM>>'
        +', @D_Status         = <<KITDETAIL.Status>>'
        +', @D_EffectiveDate  = <<KITDETAIL.EffectiveDate>>'
        +', @D_AddDate        = <<KITDETAIL.AddDate>>'
        +', @D_AddWho         = <<KITDETAIL.AddWho>>'
        +', @D_EditDate       = <<KITDETAIL.EditDate>>'
        +', @D_EditWho        = <<KITDETAIL.EditWho>>'
        +', @D_Channel_ID     = <<KITDETAIL.Channel_ID>>'
        +', @D_PalletType     = <<KITDETAIL.PalletType>>'
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
        +' FROM dbo.KITDETAIL WITH(NOLOCK)'

      IF ISNULL(@c_DTL_JOIN,'') <> ''
         SET @c_SQL = @c_SQL + ' ' + @c_DTL_JOIN

      SET @c_SQL = @c_SQL
        + ' WHERE KITDETAIL.KitKey = N''' + ISNULL(REPLACE(@c_x_KitKey,'''',''''''),'') + ''''
        +   ' AND KITDETAIL.[Type] = N''' + ISNULL(REPLACE(@c_x_Type,'''',''''''),'') + ''''
        +   ' AND KITDETAIL.KitLineNumber = N''' + ISNULL(REPLACE(@c_x_KitLineNumber,'''',''''''),'') + ''''

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
            SET @c_Long = '<<' + CASE WHEN @c_Long LIKE '@%' THEN '' ELSE 'KITDETAIL.' END + @c_Long + '>>'
            SET @c_SQL = REPLACE(@c_SQL, ISNULL(@c_Long,''), @c_Notes)
         END
      END
      CLOSE CUR_CLK_UPD_DTL
      DEALLOCATE CUR_CLK_UPD_DTL

      SET @c_SQL = REPLACE(REPLACE(@c_SQL, '<<', ''), '>>', '')

      SELECT @D_Lot             = NULL, @D_Loc             = NULL, @D_Id              = NULL
           , @D_ExpectedQty     = NULL, @D_Qty             = NULL, @D_LOTTABLE01      = NULL
           , @D_LOTTABLE02      = NULL, @D_LOTTABLE03      = NULL, @D_LOTTABLE04      = NULL
           , @D_LOTTABLE05      = NULL, @D_ExternKitKey    = NULL, @D_ExternLineNo    = NULL
           , @D_Lottable06      = NULL, @D_Lottable07      = NULL, @D_Lottable08      = NULL
           , @D_Lottable09      = NULL, @D_Lottable10      = NULL, @D_Lottable11      = NULL
           , @D_Lottable12      = NULL, @D_Lottable13      = NULL, @D_Lottable14      = NULL
           , @D_Lottable15      = NULL, @D_Channel         = NULL, @D_UCCNo           = NULL
           , @D_KITKey          = NULL, @D_KITLineNumber   = NULL, @D_Type            = NULL
           , @D_StorerKey       = NULL, @D_Sku             = NULL, @D_PackKey         = NULL
           , @D_UOM             = NULL, @D_Status          = NULL, @D_EffectiveDate   = NULL
           , @D_AddDate         = NULL, @D_AddWho          = NULL, @D_EditDate        = NULL
           , @D_EditWho         = NULL, @D_Channel_ID      = NULL, @D_PalletType      = NULL
           , @D_Temp01          = NULL, @D_Temp02          = NULL, @D_Temp03          = NULL
           , @D_Temp04          = NULL, @D_Temp05          = NULL, @D_Temp06          = NULL
           , @D_Temp07          = NULL, @D_Temp08          = NULL, @D_Temp09          = NULL
           , @D_Temp10          = NULL

      IF @b_debug = 1
         SELECT @c_SQL AS [Select Detail], @c_SQLParm_DTL AS SQLParam_DTL

      BEGIN TRY
         EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_DTL
            , @D_Lot             OUTPUT, @D_Loc             OUTPUT, @D_Id              OUTPUT
            , @D_ExpectedQty     OUTPUT, @D_Qty             OUTPUT, @D_LOTTABLE01      OUTPUT
            , @D_LOTTABLE02      OUTPUT, @D_LOTTABLE03      OUTPUT, @D_LOTTABLE04      OUTPUT
            , @D_LOTTABLE05      OUTPUT, @D_ExternKitKey    OUTPUT, @D_ExternLineNo    OUTPUT
            , @D_Lottable06      OUTPUT, @D_Lottable07      OUTPUT, @D_Lottable08      OUTPUT
            , @D_Lottable09      OUTPUT, @D_Lottable10      OUTPUT, @D_Lottable11      OUTPUT
            , @D_Lottable12      OUTPUT, @D_Lottable13      OUTPUT, @D_Lottable14      OUTPUT
            , @D_Lottable15      OUTPUT, @D_Channel         OUTPUT, @D_UCCNo           OUTPUT
            , @D_KITKey          OUTPUT, @D_KITLineNumber   OUTPUT, @D_Type            OUTPUT
            , @D_StorerKey       OUTPUT, @D_Sku             OUTPUT, @D_PackKey         OUTPUT
            , @D_UOM             OUTPUT, @D_Status          OUTPUT, @D_EffectiveDate   OUTPUT
            , @D_AddDate         OUTPUT, @D_AddWho          OUTPUT, @D_EditDate        OUTPUT
            , @D_EditWho         OUTPUT, @D_Channel_ID      OUTPUT, @D_PalletType      OUTPUT
            , @D_Temp01          OUTPUT, @D_Temp02          OUTPUT, @D_Temp03          OUTPUT
            , @D_Temp04          OUTPUT, @D_Temp05          OUTPUT, @D_Temp06          OUTPUT
            , @D_Temp07          OUTPUT, @D_Temp08          OUTPUT, @D_Temp09          OUTPUT
            , @D_Temp10          OUTPUT
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err  = 61073
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Select KIT Detail Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
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
               , @H_Type            OUTPUT, @H_EffectiveDate   OUTPUT, @H_ReasonCode      OUTPUT
               , @H_CustomerRefNo   OUTPUT, @H_Remarks         OUTPUT, @H_GenerateHOCharges OUTPUT
               , @H_GenerateIS_HiCharges OUTPUT, @H_USRDEF1    OUTPUT, @H_USRDEF2         OUTPUT
               , @H_USRDEF3         OUTPUT, @H_ActionFlag      OUTPUT, @H_ExternKitKey    OUTPUT
               , @H_USRDEF4         OUTPUT, @H_USRDEF5         OUTPUT, @H_USRDEF6         OUTPUT
               , @H_USRDEF7         OUTPUT, @H_USRDEF8         OUTPUT, @H_USRDEF9         OUTPUT
               , @H_USRDEF10        OUTPUT, @H_USRDEF11        OUTPUT, @H_USRDEF12        OUTPUT
               , @H_USRDEF13        OUTPUT, @H_USRDEF14        OUTPUT, @H_USRDEF15        OUTPUT
               , @H_ExternStatus    OUTPUT, @H_KITKey          OUTPUT, @H_StorerKey       OUTPUT
               , @H_ToStorerKey     OUTPUT, @H_OpenQty         OUTPUT, @H_Status          OUTPUT
               , @H_AddDate         OUTPUT, @H_AddWho          OUTPUT, @H_EditDate        OUTPUT
               , @H_EditWho         OUTPUT, @H_Facility        OUTPUT
               , @D_Lot             OUTPUT, @D_Loc             OUTPUT, @D_Id              OUTPUT
               , @D_ExpectedQty     OUTPUT, @D_Qty             OUTPUT, @D_LOTTABLE01      OUTPUT
               , @D_LOTTABLE02      OUTPUT, @D_LOTTABLE03      OUTPUT, @D_LOTTABLE04      OUTPUT
               , @D_LOTTABLE05      OUTPUT, @D_ExternKitKey    OUTPUT, @D_ExternLineNo    OUTPUT
               , @D_Lottable06      OUTPUT, @D_Lottable07      OUTPUT, @D_Lottable08      OUTPUT
               , @D_Lottable09      OUTPUT, @D_Lottable10      OUTPUT, @D_Lottable11      OUTPUT
               , @D_Lottable12      OUTPUT, @D_Lottable13      OUTPUT, @D_Lottable14      OUTPUT
               , @D_Lottable15      OUTPUT, @D_Channel         OUTPUT, @D_UCCNo           OUTPUT
               , @D_KITKey          OUTPUT, @D_KITLineNumber   OUTPUT, @D_Type            OUTPUT
               , @D_StorerKey       OUTPUT, @D_Sku             OUTPUT, @D_PackKey         OUTPUT
               , @D_UOM             OUTPUT, @D_Status          OUTPUT, @D_EffectiveDate   OUTPUT
               , @D_AddDate         OUTPUT, @D_AddWho          OUTPUT, @D_EditDate        OUTPUT
               , @D_EditWho         OUTPUT, @D_Channel_ID      OUTPUT, @D_PalletType      OUTPUT
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
            SET @c_SQL2 = @c_SQL2 + IIF(@c_SQL2<>'',' OR ','') + 'ISNULL(' + @c_Long + ','''')<>ISNULL(@D_' + @c_Long +','''')'
         END
      END
      CLOSE CUR_UPDATE_DET
      DEALLOCATE CUR_UPDATE_DET

      IF ISNULL(@c_SQL,'')<>'' AND ISNULL(@c_SQL2,'')<>''
      BEGIN
         SET @c_SQL = 'UPDATE dbo.KITDETAIL WITH(ROWLOCK)'
           +' SET Trafficcop=NULL' + @c_SQL
           +' WHERE KitKey = N''' + ISNULL(REPLACE(@c_x_KitKey,'''',''''''),'') + ''''
           +  ' AND [Type] = N''' + ISNULL(REPLACE(@c_x_Type,'''',''''''),'') + ''''
           +  ' AND KitLineNumber = N''' + ISNULL(REPLACE(@c_x_KitLineNumber,'''',''''''),'') + ''''
           +  ' AND (' + @c_SQL2 + ')'

         IF @b_debug = 1
            SELECT @c_SQL AS [Update Detail Record], @c_SQLParm_UPDDTL AS SQLParam_UPDDTL

         BEGIN TRY
            EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_UPDDTL
               , @D_Lot          , @D_Loc         , @D_Id
               , @D_ExpectedQty  , @D_Qty         , @D_LOTTABLE01
               , @D_LOTTABLE02   , @D_LOTTABLE03  , @D_LOTTABLE04
               , @D_LOTTABLE05   , @D_ExternKitKey, @D_ExternLineNo
               , @D_Lottable06   , @D_Lottable07  , @D_Lottable08
               , @D_Lottable09   , @D_Lottable10  , @D_Lottable11
               , @D_Lottable12   , @D_Lottable13  , @D_Lottable14
               , @D_Lottable15   , @D_Channel     , @D_UCCNo
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @n_err  = 61075
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update KIT Detail Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
            GOTO QUIT_SP
         END CATCH
      END
   END
   CLOSE CUR_KIT_DTL
   DEALLOCATE CUR_KIT_DTL


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
         SET @c_SQL2 = @c_SQL2 + IIF(@c_SQL2<>'',' OR ','') + 'ISNULL(' + @c_Long + ','''')<>ISNULL(@H_' + @c_Long +','''')'
      END
   END
   CLOSE CUR_UPDATE_HDR
   DEALLOCATE CUR_UPDATE_HDR

   IF ISNULL(@c_SQL,'')<>'' AND ISNULL(@c_SQL2,'')<>''
   BEGIN
      SET @c_SQL = 'UPDATE dbo.KIT WITH(ROWLOCK)'
        +' SET Trafficcop=NULL' + @c_SQL
        +' WHERE KitKey = N''' + ISNULL(REPLACE(@c_KitKey,'''',''''''),'') + ''''
        +' AND (' + @c_SQL2 + ')'

      IF @b_debug = 1
         SELECT @c_SQL AS [Update Header Record], @c_SQLParm_UPDHDR AS SQLParam_UPDHDR

      BEGIN TRY
         EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm_UPDHDR
            , @H_Type         , @H_EffectiveDate , @H_ReasonCode
            , @H_CustomerRefNo, @H_Remarks       , @H_GenerateHOCharges
            , @H_GenerateIS_HiCharges, @H_USRDEF1, @H_USRDEF2
            , @H_USRDEF3      , @H_ActionFlag    , @H_ExternKitKey
            , @H_USRDEF4      , @H_USRDEF5       , @H_USRDEF6
            , @H_USRDEF7      , @H_USRDEF8       , @H_USRDEF9
            , @H_USRDEF10     , @H_USRDEF11      , @H_USRDEF12
            , @H_USRDEF13     , @H_USRDEF14      , @H_USRDEF15
            , @H_ExternStatus
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @n_err  = 61076
         SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update KIT Header Error (' + ISNULL(ERROR_MESSAGE(),'') +'). (' + ISNULL(@c_SP_Name,'') + ')'
         GOTO QUIT_SP
      END CATCH
   END

STEP_2:


QUIT_SP:
   IF XACT_STATE() = -1   --(-1 = uncommittable)
      ROLLBACK TRAN

   IF CURSOR_STATUS( 'LOCAL', 'CUR_KIT_DTL') in (0 , 1)
   BEGIN
      CLOSE CUR_KIT_DTL
      DEALLOCATE CUR_KIT_DTL
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
END
GO
GRANT EXECUTE ON [dbo].[ispPRKITGP] TO nSQL
GO
