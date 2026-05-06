
/************************************************************************/              
/* Store procedure: [API].[isp_ECOMP_API_UpdateVasActivity]             */              
/* Creation Date: 30-MAR-2023                                           */
/* Copyright: Maersk                                                    */
/* Written by: Alex Keoh                                                */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: SCEAPI                                                    */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date           Author   Purposes                                     */
/* 30-MAR-2023    Alex     #JIRA PAC-4 Initial                          */
/* 23-Jul-2025    Sean     #UWP-38247 - Compatible with Login User      */
/* 24-Mar-2026    Sean01   #UWP-52654 - replace RevertUser with ResetUser*/
/************************************************************************/

CREATE OR ALTER PROC [API].[isp_ECOMP_API_UpdateVasActivity](
     @b_Debug           INT            = 0
   , @c_Format          VARCHAR(10)    = ''
   , @c_UserID          NVARCHAR(256)  = ''
   , @c_OperationType   NVARCHAR(60)   = ''
   , @c_RequestString   NVARCHAR(MAX)  = ''
   , @b_Success         INT            = 0   OUTPUT
   , @n_ErrNo           INT            = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF 
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @n_Continue                    INT            = 1
         , @n_StartCnt                    INT            = @@TRANCOUNT

         , @c_ComputerName                NVARCHAR(30)   = ''

         , @c_TaskBatchID                 NVARCHAR(10)   = ''
         , @c_DropID                      NVARCHAR(20)   = ''
         , @c_OrderKey                    NVARCHAR(10)   = ''

         , @c_PickSlipNo                  NVARCHAR(10)   = ''

         , @c_OrderLineNumber             NVARCHAR(15)   = ''
         , @n_Qty                         INT
         , @c_Facility                    NVARCHAR(15)   = ''

         , @b_sp_Success                  INT
         , @n_sp_err                      INT
         , @c_sp_errmsg                   NVARCHAR(250)= ''

   SET @b_Success                         = 0
   SET @n_ErrNo                           = 0
   SET @c_ErrMsg                          = ''
   SET @c_ResponseString                  = ''

   -- UWP-38247 - Compatible with Login User S

   DECLARE @DBUserName NVARCHAR(100),
        @b_sp_ExecuteAs BIT

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID,
        @c_DBUserName  = @DBUserName OUTPUT,
        @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT,
        @b_Success     = @b_sp_Success OUTPUT,
        @n_ErrNo       = @n_sp_err OUTPUT,
        @c_ErrMsg      = @c_sp_errmsg OUTPUT;

   IF @b_sp_Success = 0
   BEGIN
      SET @b_Success = 0      
      SET @n_ErrNo = @n_sp_err      
      SET @c_ErrMsg = @c_sp_errmsg     
      GOTO QUIT
   END

   IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName
   END

   -- UWP-38247 - Compatible with Login User E   

   SELECT @c_Orderkey         = ISNULL(RTRIM(Orderkey     ), '')
         ,@c_OrderLineNumber  = ISNULL(RTRIM(OrderLineNumber    ), '')
         ,@n_Qty              = ISNULL(RTRIM(Qty         ), '')
   FROM OPENJSON (@c_RequestString)
   WITH ( 
      Orderkey        NVARCHAR(10)  '$.Orderkey',
      OrderLineNumber NVARCHAR(15)  '$.OrderLineNumber',
      Qty             INT           '$.QTY'
   )

   IF @c_Orderkey <> ''
   BEGIN
      SET @b_sp_Success = 0
      SET @n_sp_err     = 0
      SET @c_sp_errmsg  = ''

      EXEC [dbo].[isp_EPackVas_Update]
            @c_Orderkey          = @c_Orderkey        
         ,  @c_OrderLineNumber   = @c_OrderLineNumber      
         ,  @n_Qty               = @n_Qty        
         ,  @b_Success           = @b_sp_Success   OUTPUT 
         ,  @n_err               = @n_sp_err       OUTPUT 
         ,  @c_errmsg            = @c_sp_errmsg    OUTPUT  

      IF @b_sp_Success <> 1
      BEGIN
         SET @n_Continue = 3      
         SET @n_ErrNo = 51900      
         SET @c_ErrMsg = CONVERT(char(5),@n_ErrNo)+': ' 
                       + CONVERT(char(5),@n_sp_err) + ' - ' + @c_sp_errmsg     
         GOTO QUIT  
      END
   END

   SET @c_ResponseString = ISNULL(( 
                              SELECT CAST ( 1 AS BIT )   AS 'Success'
                              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ), '')

   QUIT:

   IF @b_sp_ExecuteAs = 1 REVERT --Sean01
   EXEC [WM].[lsp_ResetUser] --Sean01
   
   IF @n_Continue= 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END -- Procedure  