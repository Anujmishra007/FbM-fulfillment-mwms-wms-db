IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_FinalizeIQC_Wrapper]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_FinalizeIQC_Wrapper]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: WMS                                                 */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Dynamic lottable                                            */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/************************************************************************/
CREATE PROCEDURE [WM].[lsp_FinalizeIQC_Wrapper]
      @c_QC_Key NVARCHAR(10)
    , @c_QCLineNo NVARCHAR(5)=''   
    , @b_Success INT=1 OUTPUT
    , @n_Err INT=0 OUTPUT
    , @c_ErrMsg NVARCHAR(250)='' OUTPUT
    , @n_WarningNo INT = 0       OUTPUT
    , @c_ProceedWithWarning CHAR(1) = 'N' 
    , @c_UserName NVARCHAR(128)=''
    , @n_ErrGroupKey INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF
       
    SET @n_Err = 0 
    EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
    
    EXECUTE AS LOGIN = @c_UserName
       
    IF @n_Err <> 0 
    BEGIN
      GOTO EXIT_SP
    END

    declare @n_err2                 int 
          , @n_continue             int   
          , @n_StartTCnt            INT = @@TRANCOUNT                                 
          , @c_StorerKey            NVARCHAR(15) 
          , @c_Facility             NVARCHAR(5) 
          , @c_FinalizeFlag         NVARCHAR(1)
          , @c_OriginalQCLineNo     NVARCHAR(5)

          , @c_TableName            NVARCHAR(50)
          , @c_SourceKey            NVARCHAR(15) 
          , @c_SourceType           NVARCHAR(30) 

         ,  @c_FinalizeIQC          NVARCHAR(10) = '' 

   SET @n_continue   = 1
   SET @c_TableName = 'InventoryQCDetail'
   SET @c_SourceType = 'lsp_FinalizeIQC_Wrapper'
   SET @n_ErrGroupKey = 0
   SET @c_OriginalQCLineNo = @c_QCLineNo

    -- Validation before finalize
   DECLARE @c_IQCStatus NVARCHAR(10)
    
   IF @c_QCLineNo <> ''
   BEGIN
      SELECT @c_FinalizeFlag = IQC.FinalizeFlag, 
            @c_StorerKey = IQC.StorerKey, 
            @c_Facility  = IQC.From_Facility
         , @c_IQCStatus = RTRIM(IQCD.Status)
      FROM InventoryQC AS IQC WITH(NOLOCK)
      JOIN InventoryQCDetail IQCD WITH (NOLOCK) ON IQCD.QC_Key = IQC.QC_Key and IQCD.QCLineNo = @c_QCLineNo
      WHERE IQC.QC_Key = @c_QC_Key

   END
   ELSE
   BEGIN
      SET @c_IQCStatus = ''
      SELECT @c_FinalizeFlag = IQC.FinalizeFlag, 
               @c_StorerKey = IQC.StorerKey, 
               @c_Facility  = IQC.From_Facility  
      FROM InventoryQC AS IQC WITH(NOLOCK)
      WHERE IQC.QC_Key = @c_QC_Key          
   END

   IF @c_FinalizeFlag = 'Y'
   BEGIN
      SET @n_continue = 3
      SET @n_err = 551701
      SET @c_ErrMsg = 'The Selected IQC Has Been Finalized. Not Allow To Finalize'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey = @n_ErrGroupKey output,
            @c_TableName   = @c_TableName,
            @c_SourceType  = @c_SourceType,
            @c_Refkey1     = @c_QC_Key,
            @c_Refkey2     = @c_QCLineNo,
            @c_Refkey3     = '',
            @n_err2        = @n_err,
            @c_errmsg2     = @c_errmsg,
            @b_Success     = @b_Success   OUTPUT,
            @n_err         = @n_err       ,
            @c_errmsg      = @c_errmsg     

      GOTO EXIT_SP
   END
   ELSE IF @c_IQCStatus is NULL
   BEGIN
      SET @n_continue = 3
      SET @n_err = 551702
      SET @c_ErrMsg = 'QC_Key Or QC Line No Not Exists!'


      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey = @n_ErrGroupKey output,
            @c_TableName   = @c_TableName,
            @c_SourceType  = @c_SourceType,
            @c_Refkey1     = @c_QC_Key,
            @c_Refkey2     = @c_QCLineNo,
            @c_Refkey3     = '',
            @n_err2        = @n_err,
            @c_errmsg2     = @c_errmsg,
            @b_Success     = @b_Success   OUTPUT ,
            @n_err         = @n_err       ,
            @c_errmsg      = @c_errmsg       

      GOTO EXIT_SP      
   END

   SELECT @c_FinalizeIQC = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'FinalizeIQC')

   IF @c_FinalizeIQC <> '1'
   BEGIN 
      SET @n_continue =3
      SET @n_err = 551706
      SET @c_ErrMsg = 'Storer Not Set to enable finalize IQC.'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey = @n_ErrGroupKey output 
         ,  @c_TableName   = @c_TableName 
         ,  @c_SourceType  = @c_SourceType 
         ,  @c_Refkey1     = @c_QC_Key 
         ,  @c_Refkey2     = '' 
         ,  @c_Refkey3     = '' 
         ,  @n_err2        = @n_err 
         ,  @c_errmsg2     = @c_errmsg 
         ,  @b_Success     = @b_Success   OUTPUT 
         ,  @n_err         = @n_err       
         ,  @c_errmsg      = @c_errmsg    

      GOTO EXIT_SP 
   END
 
   -- Pre Finalize Validation from exceed
   IF EXISTS(SELECT 1 FROM InventoryQCDetail AS IQC WITH(NOLOCK)
               WHERE IQC.QC_Key = @c_QC_Key 
               AND   IQC.ToQty <= 0 
               AND   IQC.QCLineNo = CASE WHEN ISNULL(RTRIM(@c_QCLineNo),'') = '' THEN IQC.QCLineNo ELSE @c_QCLineNo END)
   BEGIN
      SET @n_continue =3
      SET @n_err = 551703
      SET @c_ErrMsg = 'To Qty is required for finalize!'


      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey = @n_ErrGroupKey output,
            @c_TableName   = @c_TableName,
            @c_SourceType  = @c_SourceType,
            @c_Refkey1     = @c_QC_Key,
            @c_Refkey2     = @c_QCLineNo,
            @c_Refkey3     = '',
            @n_err2        = @n_err,
            @c_errmsg2     = @c_errmsg,
            @b_Success     = @b_Success OUTPUT,
            @n_err         = @n_err ,
            @c_errmsg      = @c_errmsg 

      GOTO EXIT_SP 
   END
   IF EXISTS(SELECT 1 FROM InventoryQCDetail AS IQC WITH(NOLOCK)
               WHERE IQC.QC_Key = @c_QC_Key 
               AND   (IQC.ToLOC ='' OR IQC.ToLoc IS NULL) 
               AND   IQC.QCLineNo = CASE WHEN ISNULL(RTRIM(@c_QCLineNo),'') = '' THEN IQC.QCLineNo ELSE @c_QCLineNo END)
   BEGIN
      SET @n_continue =3
      SET @n_err = 551704
      SET @c_ErrMsg = 'To Loc Cannot be BLANK!'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey = @n_ErrGroupKey output,
            @c_TableName   = @c_TableName,
            @c_SourceType  = @c_SourceType,
            @c_Refkey1     = @c_QC_Key,
            @c_Refkey2     = @c_QCLineNo,
            @c_Refkey3     = '',
            @n_err2        = @n_err,
            @c_errmsg2     = @c_errmsg,
            @b_Success     = @b_Success OUTPUT,
            @n_err         = @n_err ,
            @c_errmsg      = @c_errmsg 

      GOTO EXIT_SP 
   END    

   IF EXISTS (
               SELECT 1
               FROM INVENTORYQCDETAIL IQCD WITH (NOLOCK)
               WHERE IQCD.QC_key = @c_QC_Key
               AND   ( IQCD.QCLineNo = @c_QCLineNo OR ISNULL(RTRIM(@c_QCLineNo),'') = '' )
               AND   IQCD.Qty > (   SELECT ISNULL(SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked),0)
                                    FROM LOTxLOCxID LLI WITH (NOLOCK)
                                    WHERE LLI.Lot = IQCD.FromLot
                                    AND   LLI.Loc = IQCD.FromLoc
                                    AND   LLI.ID  = IQCD.FromID
                                 )
            )
   BEGIN
      SET @n_continue =3                                                             
      SET @n_Err     = 551705
      SET @c_ErrMsg  = 'NSQL' + CONVERT(CHAR(6), @n_Err)
                     + ': Inadequate system available Qty to Move found.'

      EXEC [WM].[lsp_WriteError_List] 
            @i_iErrGroupKey = @n_ErrGroupKey output,
            @c_TableName   = @c_TableName,
            @c_SourceType  = @c_SourceType,
            @c_Refkey1     = @c_QC_Key,
            @c_Refkey2     = @c_QCLineNo,
            @c_Refkey3     = '',
            @n_err2        = @n_err,
            @c_errmsg2     = @c_errmsg,
            @b_Success     = @b_Success OUTPUT,
            @n_err         = @n_err ,
            @c_errmsg      = @c_errmsg 

      GOTO EXIT_SP 
   END                  

   IF @n_continue = 1
   BEGIN
      BEGIN TRY
         EXEC ispFinalizeIQC
            @c_qc_key  = @c_QC_Key,
            @b_Success = @b_Success OUTPUT,
            @n_err     = @n_err     OUTPUT,
            @c_ErrMsg  = @c_ErrMsg  OUTPUT         
      END TRY 
      BEGIN CATCH
         IF @n_err = 0 
         BEGIN
            IF @@TRANCOUNT > @n_StartTCnt
            BEGIN
               ROLLBACK TRAN
            END 
            SET  @n_continue = 3
            SELECT @n_err = ERROR_NUMBER(), 
                   @c_ErrMsg = ERROR_MESSAGE()

            GOTO EXIT_SP
         END
      END CATCH      
   END
         
   EXIT_SP:       

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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_FinalizeIQC_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN 
      BEGIN TRAN
   END

   REVERT  
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_FinalizeIQC_Wrapper] TO nSQL 
GO
