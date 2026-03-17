SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtFieldDisplay01                                */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Field Display SP for Carton Type                    */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-02-04   1.0  JWF011     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtFieldDisplay01] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cLangCode            NVARCHAR(10)      = ''
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
   , @cExtFieldCol         NVARCHAR(100)     = ''  OUTPUT
   , @cExtFieldVal         NVARCHAR(1000)    = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  

   SET @b_Success    = 0  
   SET @n_ErrNo      = 0  
   SET @c_ErrMsg     = ''

   IF (SELECT SUM(ExpQty)
       FROM PACKDETAIL (NOLOCK)
       WHERE PickSlipNo = @cPickSlipNo
      ) > 0
   BEGIN
      SET @cExtFieldCol = 'Carton Type'
      SET @cExtFieldVal = (SELECT TOP 1 UPPER(CartonType)
                           FROM PACKINFO (NOLOCK)
                           WHERE PickSlipNo = @cPickSlipNo
                           AND CartonStatus = 'INPROGRESS'
                          )
   END

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

