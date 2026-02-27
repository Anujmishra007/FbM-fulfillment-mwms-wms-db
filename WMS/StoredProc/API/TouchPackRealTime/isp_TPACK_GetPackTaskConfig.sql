SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_GetPackTaskConfig                                      */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get Check and Get all the storerconfig                       */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-04   1.0  GCH225     Created                                          */
/* 2025-10-30   1.1  JWF011     UWP-42640: Add config TPS-OffToteConfirm         */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_GetPackTaskConfig] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @c_UserID             NVARCHAR(256)     = ''
   , @cPackTaskConfigJson  NVARCHAR(MAX)     = ''  OUTPUT
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

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  

   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @cPackTaskConfigJson   = ''

   SET @cPackTaskConfigJson = ISNULL ((SELECT ConfigKey AS configKey
                                            , sValue as configVal
                                            , OPTION1 AS configOpt1
                                            , OPTION2 AS configOpt2
                                            , OPTION3 AS configOpt3
                                            , OPTION4 AS configOpt4
                                            , OPTION5 AS configOpt5
                                       FROM STORERCONFIG sc (NOLOCK) 
                                       WHERE StorerKey = @cStorerKey  
                                       AND (ConfigKey LIKE 'TPS%'
                                       OR ConfigKey IN (
                                       'PackCaptureNewLabelno'
                                       ))
                                       FOR JSON PATH
                                       ),'')
   
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
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END