SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_ExtPackInfo_Std                                        */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get custom extended pack info Columbia Storer                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-05-18   1.0  GCH225     FCR-13243 - Display PendAudit as label           */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_ExtPackInfo_Std] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @c_UserID             NVARCHAR(256)     = ''
   , @cLangCode            NVARCHAR(10)      = ''
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  
         , @cExtPackInfoConfig   NVARCHAR(250)
         , @cSQL                 NVARCHAR(MAX)
         , @cSQLParam            NVARCHAR(3000)
         , @cStatus              NVARCHAR(20)

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @cExtPackInfoConfig    = ''
   SET @cStatus              = 'PENDAUDIT'

   DECLARE @dynTable TABLE (
      fieldName  NVARCHAR(50)
    , fieldValue NVARCHAR(250)
   )

   INSERT INTO @dynTable (fieldName, fieldValue)
   SELECT 'CartonType' AS fieldName
        , CartonType AS fieldValue
   FROM PACKINFO (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo
   AND CartonNo = @nCartonNo

   IF EXISTS (SELECT 1
              FROM PACKINFO_AUDITLOG (NOLOCK)
              WHERE PickSlipNo = @cPickSlipNo
              AND CartonNo = @nCartonNo
              AND CartonStatus = @cStatus
   )
   BEGIN
      INSERT INTO @dynTable (fieldName, fieldValue)
      VALUES ('Remarks', @cStatus)
   END

   SELECT fieldName
        , fieldValue
   FROM @dynTable
   
EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
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
      SET @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END