SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateAction02                                   */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-14   1.0  GCH225     UWP-27783: Created                               */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateAction02] (
     @cAction           NVARCHAR(200) = ''
   , @objData           NVARCHAR(MAX) = ''
   , @c_UserID          NVARCHAR(256) = ''
   , @b_Success         INT           = 0   OUTPUT  
   , @n_ErrNo           INT           = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250) = ''  OUTPUT
   , @c_ResponseString  NVARCHAR(MAX) = ''  OUTPUT     
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

   DECLARE @bSuccess             BIT
         , @bRequireInteraction  BIT
         , @cInteractionCode     NVARCHAR(30)
         , @cInteractionType     NVARCHAR(30)
         , @cTitle               NVARCHAR(100)
         , @cMessage             NVARCHAR(250)
         , @arrButtons           NVARCHAR(MAX)

   DECLARE @cSKUToValidate       NVARCHAR(20)
         , @cStyleColor          NVARCHAR(20)
         , @cTempSKU             NVARCHAR(20)
         , @nPackQty             INT
         , @nPickQty             INT

   DECLARE @cType                NVARCHAR(30)
         , @cLangCode            NVARCHAR(3)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @bIsDiscrete          BIT
         , @bIsCustom            BIT
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @nCartonNo            INT
         , @cScannerVal          NVARCHAR(128)
         , @cInputValue1         NVARCHAR(128)
         , @cInputValue2         NVARCHAR(MAX)
         , @cInputValue3         NVARCHAR(128)
         , @cScanType            NVARCHAR(30)
         , @cSKU                 NVARCHAR(20)
         , @nQty                 INT
         , @bIsADInput           BIT
         , @bIsVASDone           BIT

   DECLARE @cSerialNo            NVARCHAR(50)
         , @cSerialNoType        NVARCHAR(1)
         , @nPallet              FLOAT
         , @nCaseCnt             FLOAT
         , @cBUSR7               NVARCHAR(50)
         , @nPalletQty           FLOAT
         , @nCtnPerPL            INT
         , @nTrackingQty         INT

   SET @bSuccess              = 1
   SET @bRequireInteraction   = 0
   SET @cInteractionCode      = 'PACK_SKU_CONFIRM'
   SET @cInteractionType      = 'CONFIRM'
   SET @cTitle                = 'VALIDATE PALLET QTY vs SN QTY'
   SET @cMessage              = API.TouchPadGetMessage(16601, @cLangCode, 'DSP') --SerialNo Qty does not match with Pallet Qty. Are you sure you want to proceed to pack?
   SET @arrButtons = '[{"cCode":"YES","cText":"Yes","cStyle":"PRIMARY"},{"cCode":"NO","cText":"No","cStyle":"SECONDARY"}]'

   SET @cSKUToValidate        = ''
   SET @cStyleColor           = ''
   SET @cTempSKU              = ''
   SET @nPackQty              = 0
   SET @nPickQty              = 0

   SET @cType                 = ''
   SET @cLangCode             = ''
   SET @cStorerKey            = ''
   SET @cFacility             = ''
   SET @bIsDiscrete           = 0
   SET @bIsCustom             = 0
   SET @cPickSlipNo           = ''
   SET @cOrderKey             = ''
   SET @cLoadKey              = ''
   SET @cDropID               = ''
   SET @nCartonNo             = 0
   SET @cScannerVal           = ''
   SET @cInputValue1          = ''
   SET @cInputValue2          = ''
   SET @cInputValue3          = ''
   SET @cScanType             = ''
   SET @bIsADInput            = 0
   SET @bIsVASDone            = 0
   SET @cSKU                  = ''
   SET @nQty                  = 0
   SET @nPallet               = 0
   SET @nCaseCnt              = 0
   SET @cBUSR7                = ''
   SET @nPalletQty            = 0
   SET @nCtnPerPL             = 0
   SET @nTrackingQty          = 0  
   
   SELECT  @cType         = cType
         , @bIsDiscrete   = bIsDiscrete
         , @bIsCustom     = bIsCustom
         , @cPickSlipNo   = cPickSlipNo
         , @cOrderKey     = cOrderKey
         , @cLoadKey      = cLoadKey
         , @cDropID       = cDropID
         , @cLangCode     = cLangCode
         , @cStorerKey    = cStorerKey
         , @cFacility     = cFacility
         , @nCartonNo     = nCartonNo

         -- ScanHandler
         , @cScannerVal   = cScannerVal

         -- Extended Pack / Pack SKU
         , @cInputValue1  = cInputValue1
         , @cInputValue2  = cInputValue2
         , @cInputValue3  = cInputValue3
         , @cScanType     = cScanType

         -- Common
         , @cSKU          = cSKU
         , @nQty          = nQty

         -- Extended Pack only
         , @bIsADInput    = bIsADInput

         -- Pack SKU only
         , @bIsVASDone    = bIsVASDone
   FROM OPENJSON(@objData)
   WITH (
         cType         NVARCHAR(30)
      , bIsDiscrete   BIT
      , bIsCustom     BIT
      , cPickSlipNo   NVARCHAR(10)
      , cOrderKey     NVARCHAR(10)
      , cLoadKey      NVARCHAR(10)
      , cDropID       NVARCHAR(20)
      , cLangCode     NVARCHAR(3)
      , cStorerKey    NVARCHAR(15)
      , cFacility     NVARCHAR(5)
      , nCartonNo     INT

      , cScannerVal   NVARCHAR(128)

      , cInputValue1  NVARCHAR(128)
      , cInputValue2  NVARCHAR(MAX) AS JSON
      , cInputValue3  NVARCHAR(128)
      , cScanType     NVARCHAR(20)

      , cSKU          NVARCHAR(20)
      , nQty          INT

      , bIsADInput    BIT
      , bIsVASDone    BIT
   );

   IF @cAction = 'TPACK_SCANHANDLER'
   AND @cScannerVal NOT LIKE '%' + CHAR(9) + '%'
   BEGIN
      GOTO EXIT_SP
   END

   IF @cScannerVal <> ''
   BEGIN
      SET @cSKU = RTRIM(LEFT(@cScannerVal, CHARINDEX(CHAR(9), @cScannerVal) - 1));
      SET @cSerialNo = UPPER(LTRIM(SUBSTRING(@cScannerVal, CHARINDEX(CHAR(9), @cScannerVal) + 1, LEN(@cScannerVal))));
      SET @cInputValue2 = '[' + @cSerialNo + ']';
   END

   IF @cSKU = ''
   OR (ISJSON(@cInputValue2) = 0
   AND NOT EXISTS (
      SELECT 1 
      FROM OPENJSON(@cInputValue2)
   ))
   BEGIN
      GOTO EXIT_SP
   END 

   IF @cSerialNo = ''
   BEGIN
      SELECT @cSerialNo = ISNULL([value], '') 
      FROM OPENJSON(@cInputValue2)
      WITH ([value] NVARCHAR(100) '$') J
   END

   SET @cSerialNoType = RIGHT(RTRIM(@cSerialNo),1) 

   EXEC [API].[isp_TPACK_ValidateInput12]
        @cType        = @cType
      , @bIsDiscrete  = @bIsDiscrete
      , @bIsCustom    = @bIsCustom
      , @cPickSlipNo  = @cPickSlipNo
      , @cOrderKey    = @cOrderKey
      , @cLoadKey     = @cLoadKey
      , @cDropID      = @cDropID
      , @cStorerKey   = @cStorerKey
      , @cFacility    = @cFacility
      , @cInputValue1 = @cInputValue1
      , @cInputValue2 = @cInputValue2
      , @cInputValue3 = @cInputValue3
      , @cScanType    = ''
      , @cSKU         = @cSKU
      , @nCartonNo    = 0
      , @nQty         = @nQty 
      , @c_UserID     = @c_UserID
      , @cLangCode    = @cLangCode
      , @b_Success    = @b_Success OUTPUT
      , @n_ErrNo      = @n_ErrNo   OUTPUT
      , @c_ErrMsg     = @c_ErrMsg  OUTPUT

   IF @b_Success = 0
   BEGIN 
      SET @n_Continue = 3
      GOTO EXIT_SP
   END

   IF @cSerialNoType <> 'P'
   BEGIN
      GOTO EXIT_SP
   END

   SELECT @nCtnPerPL = COUNT(TID.TrackingID)
         ,@nTrackingQty = SUM(TID.Qty)
   FROM TRACKINGID TID WITH (NOLOCK)
   WHERE TID.ParentTrackingID = @cSerialNo
   AND TID.Storerkey = @cStorerKey
   AND TID.PickMethod <> 'loose'              
   AND TID.[Status] >= 1 AND TID.[Status] <= 9

   SELECT @nPalletQty = P.CaseCnt * @nCtnPerPL
   FROM SKU S WITH (NOLOCK)
   JOIN PACK P WITH (NOLOCK) 
   ON S.Packkey = P.Packkey
   WHERE S.Storerkey = @cStorerKey
   AND S.Sku = @cSKU
   AND S.BUSR7 = 'Yes'

   IF @nPalletQty = @nTrackingQty
   BEGIN
      GOTO EXIT_SP
   END

   SET @bSuccess = 1
   SET @bRequireInteraction = 1
   
   SET @c_ResponseString = ISNULL ((SELECT  @bSuccess             AS bSuccess
                                          , @bRequireInteraction  AS bRequireInteraction
                                          , @cInteractionCode     AS cInteractionCode
                                          , @cInteractionType     AS cInteractionType
                                          , @cTitle               AS cTitle
                                          , @cMessage             AS cMessage
                                          , JSON_QUERY(CASE WHEN ISJSON(@arrButtons) = 1
                                                            THEN @arrButtons
                                                            ELSE '[]'
                                                            END
                                          )                             AS arrButtons
                                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                                    ), '')

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
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_ValidateAction02] TO NSQL
GO