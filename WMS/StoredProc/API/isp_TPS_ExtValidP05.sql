
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP05                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2024-12-23    1.0  YeeKung  FCR_1822 Created                               */
/* 2024-01-21    1.1  YeeKung  FCR-2268 Add UCC Validation                    */
/* 2025-02-18    1.2  YeeKung  FCR-2162 Valid UCC (yeekung02)                 */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP05] (
	@json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1        OUTPUT,
   @n_Err      INT = 0        OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
BEGIN
	DECLARE
		@cStorerKey   NVARCHAR ( 15),
      @cFacility    NVARCHAR ( 5),
      @nFunc        INT,
      @cBarcode     NVARCHAR( 60),
      @cUserName    NVARCHAR( 30),
      @cLangCode    NVARCHAR( 3),
      @cSKU         NVARCHAR( 30),
      @cADCode      NVARCHAR( 20)
    
   DECLARE @cSkipUCCADScn     NVARCHAR( 20) 

   EXEC nspGetRight    
      @c_Facility   = @cFacility   
   ,  @c_StorerKey  = @cStorerKey   
   ,  @c_sku        = ''    
   ,  @c_ConfigKey  = 'TPS-SkipUCCADScn'    
   ,  @b_Success    = @b_Success       OUTPUT    
   ,  @c_authority  = @cSkipUCCADScn   OUTPUT    
   ,  @n_err        = @n_Err           OUTPUT    
   ,  @c_errmsg     = @c_ErrMsg        OUTPUT  

	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5),
      Func        INT,
      Barcode     NVARCHAR( 60),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3)
   )

   SET @b_Success = 1

   IF EXISTS(  SELECT 1 
               FROM UCC (NOLOCK)
               WHERE UCCNo = @cBarcode
                  AND UCC.Storerkey = @cStorerkey)
   BEGIN
      IF (  SELECT COUNT(1)
                  FROM UCC (NOLOCK)
                  WHERE UCCNo = @cBarcode
                     AND Storerkey = @cStorerkey
                     AND Status <='6'
                  ) > 1
      BEGIN
         SET @n_Err = 1001851
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Multi UCCNO Record.: isp_TPS_ExtValidP05' 
         SET @jResult = (SELECT '' AS SKU
         FOR JSON PATH,INCLUDE_NULL_VALUES )    
         SET @b_Success = 0
         GOTO QUIT
            
      END

      SELECT @cADCode = susr4
      FROM UCC UCC(NOLOCK)
         JOIN SKU SKU (NOLOCK) ON UCC.SKU = SKU.SKU AND UCC.Storerkey = SKU.Storerkey
      WHERE UCCNo = @cBarcode
         AND UCC.Storerkey = @cStorerkey


      IF @cSkipUCCADScn = '1' AND
            NOT EXISTS (   SELECT 1
                           FROM SerialNO (NOLOCK)
                           WHERE Userdefine01 = @cBarcode    
                              AND Status in ('0','1')
                              AND Storerkey = @cStorerkey)
            AND @cADCode ='AD'
      BEGIN
         SET @n_Err = 1001852
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'UCCNO No SerialNO: isp_TPS_ExtValidP05' 
         SET @jResult = (SELECT '' AS SKU
         FOR JSON PATH,INCLUDE_NULL_VALUES )    
         SET @b_Success = 0
         GOTO QUIT
      END
      
   END
   ELSE
   BEGIN
      IF SUBSTRING(@cBarcode,1,1) NOT IN ('Y','y') AND LEN(@cBarcode) <> 18
      BEGIN
         SET @n_Err = 1001853
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Invalid SerialNO.: isp_TPS_ExtValidP05'  

         SET @jResult = (SELECT '' AS SKU
         FOR JSON PATH,INCLUDE_NULL_VALUES )    
         SET @b_Success = 0
         GOTO QUIT
            
      END
   END
   
   SET @jResult = (SELECT @cBarcode AS SerialNo
   FOR JSON PATH,INCLUDE_NULL_VALUES )    
      SET @b_Success = 1

   GOTO QUIT


   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'
   QUIT:

END

