SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_GetTotalADCount                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get Number of AD Fields and Display Qty for Frontend         */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-07   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_GetTotalADCount] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cInputValue1         NVARCHAR(128)     = ''
   , @cInputValue2         NVARCHAR(MAX)     = ''
   , @cInputValue3         NVARCHAR(128)     = ''
   , @cScanType            NVARCHAR(20)      = ''
   , @cSKU                 NVARCHAR(20)      = ''
   , @nCartonNo            INT               = 0
   , @nQty                 INT               = 0       
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @nNumberOfADField     INT               = 0   OUTPUT
   , @nDisplayADQty        INT               = 0   OUTPUT
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
         
   DECLARE @nPackOtherUnit2      INT
         , @nTtlPSNPackedQty     INT
         , @nTtlPDPackedQty      INT
         , @nRemNoADQty          INT
   
   DECLARE @PickQtyStatus TABLE(
        TtlPickedQty INT
      , [Status] NVARCHAR(10) 
   )

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @nPackOtherUnit2    = 0
   SET @nTtlPSNPackedQty   = 0
   SET @nTtlPDPackedQty    = 0
   SET @nRemNoADQty        = 0

   IF (  SELECT COUNT (DISTINCT P.PackKey)
         FROM PACK P (NOLOCK) 
         INNER JOIN SKU S (NOLOCK)
         ON P.PackKey = S.PackKey
         WHERE S.StorerKey = @cStorerKey
         AND S.SKU = @cSKU
   ) > 1
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 12251      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'More than 1 PackKey Detected. '
      GOTO EXIT_SP
   END

   SELECT @nPackOtherUnit2 = ISNULL(OtherUnit2,0)
   FROM PACK P (NOLOCK) 
   INNER JOIN SKU S (NOLOCK)
   ON P.PackKey = S.PackKey
   WHERE S.StorerKey = @cStorerKey
   AND S.SKU = @cSKU

   IF @nPackOtherUnit2 < 1
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 12252      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'OtherUnit2 in Pack Table cannot be less than 1.'
      GOTO EXIT_SP
   END
         
   IF @nCartonNo > 0
   BEGIN
      SELECT  @nTtlPSNPackedQty = ISNULL(SUM(Qty),0)
      FROM PACKSERIALNO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND SKU = @cSKU

      SELECT @nTtlPDPackedQty = ISNULL(SUM(Qty),0)
      FROM PACKDETAIL (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND (@cDropID = '' OR DropID = @cDropID)
      AND CartonNo = @nCartonNo
      AND SKU = @cSKU
            
      SET @nRemNoADQty = @nTtlPDPackedQty - @nTtlPSNPackedQty
      IF @nRemNoADQty < 0
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 12253      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current PickSlip with CartonNo got abnormal data in backend. Please stop packing this pickslip and seek support help. '
         GOTO EXIT_SP
      END
   END
   SET @nRemNoADQty = @nRemNoADQty + @nQty

   SET @nNumberOfADField = FLOOR(@nRemNoADQty / @nPackOtherUnit2)

   IF @nNumberOfADField >= 1
   BEGIN
      SET @nDisplayADQty = @nPackOtherUnit2 * @nNumberOfADField
   END

PROCEED:

EXIT_SP:
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
END



