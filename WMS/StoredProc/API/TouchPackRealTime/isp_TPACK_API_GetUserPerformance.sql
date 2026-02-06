SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetUserPerformance                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the user performance info                                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_GetUserPerformance] (
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
         , @b_sp_Success                  INT  
         , @n_sp_err                      INT  
         , @c_sp_errmsg                   NVARCHAR(250)  = ''
         , @DBUserName                    NVARCHAR(100)
         , @b_sp_ExecuteAs                BIT

   DECLARE
      @cLangCode           NVARCHAR( 3)
    , @nFunc               INT
    , @dTodayDate          DATE

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''  
   SET @c_ResponseString   = '' 
   SET @dTodayDate         = CAST(GETDATE() AS DATE)

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
      GOTO EXIT_SP
   END

   IF @b_sp_ExecuteAs = 1 OR @DBUserName LIKE '%' + @c_UserID + '%'
   BEGIN
      EXECUTE AS LOGIN = @DBUserName
      SET @c_UserID = @DBUserName

      IF OBJECT_ID('dbo.fnc_GetUserName', 'FN') IS NOT NULL
      BEGIN
         IF dbo.fnc_GetUserName() NOT IN ('WMConnect', '')
         BEGIN
            SET @c_UserID = dbo.fnc_GetUserName()
         END
      END
   END

   --Decode Json Format
   SELECT @nFunc = Func
       , @cLangCode = LangCode
   FROM OPENJSON(@c_RequestString)
   WITH (
	      Func        INT
       , LangCode    NVARCHAR(3)
   )

   DECLARE @cCartonPacked     NVARCHAR(5)
         , @cPickSlipPacked   NVARCHAR(5)

   SELECT @cPickSlipPacked = COUNT(DISTINCT PickSlipNo) 
   FROM PACKINFO (NOLOCK) 
   WHERE (EditDate >= @dTodayDate
   AND EditDate < @dTodayDate)
   AND (AddWho = @c_UserID 
   OR EditWho = @c_UserID)

   SELECT @cCartonPacked = COUNT(CartonNo) 
   FROM PACKINFO (NOLOCK) 
   WHERE (EditDate >= @dTodayDate
   AND EditDate < @dTodayDate)
   AND (AddWho = @c_UserID 
   OR EditWho = @c_UserID)


   SET @b_Success = 1
   SET @c_ResponseString = ISNULL((
                             SELECT JSON_QUERY( '["ORDERS PROCESSED",' 
                             + '"' + @cPickSlipPacked + '",'
                             + '"CARTON PACKED",'
                             + '"' + @cPickSlipPacked +'",'
                             + '"",'
                             + '"",'
                             + '""'
                             + ']')
                           ), '') 

   IF ISNULL(@c_RequestString, '') = ''
      SET @c_RequestString = '[]'

EXIT_SP:
   REVERT
END



