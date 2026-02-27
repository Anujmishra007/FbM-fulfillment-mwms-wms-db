SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode03                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the Pack Decode Config                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-14   1.0  GCH225     Cloned from isp_TPS_DecodeSP03 (WMS-17771)       */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode03] (
	  @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cInputValue1      NVARCHAR(128)     = ''
   , @c_UserID          NVARCHAR(256)     = ''
   , @cLangCode         NVARCHAR(3)       = ''
   , @cSKU              NVARCHAR(20)      = ''  OUTPUT
   , @nQty              INT                     OUTPUT
   , @b_Success         INT               = 0   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @n_Foundpos     INT     
         , @n_LastFoundpos INT  

   SET @b_Success       = 0
   SET @n_Foundpos      = 0      
   SET @n_LastFoundpos  = 0    
     
   WHILE 1=1      
   BEGIN      
      SELECT @n_Foundpos = CHARINDEX('/', @cInputValue1, @n_Foundpos + 1)      
            
      IF @n_Foundpos <= 0
         BREAK      
         
      SET @n_LastFoundpos = @n_Foundpos      
   END       
         
   IF @n_LastFoundpos <= 0      
   BEGIN
      SET @n_ErrNo = 12501
	   SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Barcode. Failed to decode it.'  
      GOTO QUIT
   END
  
   IF NOT EXISTS (SELECT 1
                  FROM SERIALNO (NOLOCK)
                  WHERE SerialNo = @cInputValue1
                  AND StorerKey = @cStorerKey
                  AND [Status] = '1'
   )
   BEGIN
      SET @n_ErrNo = 12502
	   SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Invalid Barcode. Record not found.'  
      GOTO QUIT
   END

   SELECT @cSKU = ISNULL(RTRIM(SKU),'')
   FROM SERIALNO (NOLOCK)
   WHERE SerialNo = @cInputValue1
   AND StorerKey = @cStorerKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @n_ErrNo = 12503
	   SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Decode.'    
      GOTO QUIT
   END  
   
   SET @b_Success = 1

QUIT:
END



