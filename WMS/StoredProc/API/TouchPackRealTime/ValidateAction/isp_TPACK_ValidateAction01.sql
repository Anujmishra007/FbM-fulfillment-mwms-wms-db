SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateAction01                                   */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-05   1.0  JWF011     FCR-13553: Created                               */
/* 2026-08-07   1.1  JWF011     FCR-13553: Update ErrMsg                         */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateAction01] (
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

   DECLARE @n_Continue          INT            = 1  
         , @n_StartCnt          INT            = @@TRANCOUNT  

   DECLARE @bSuccess            BIT
         , @bRequireInteraction BIT
         , @cInteractionCode    NVARCHAR(30)
         , @cInteractionType    NVARCHAR(30)
         , @cTitle              NVARCHAR(100)
         , @cMessage            NVARCHAR(250)
         , @arrButtons          NVARCHAR(MAX)

   DECLARE @cSKUToValidate      NVARCHAR(20)
         , @cStyleColor         NVARCHAR(20)
         , @cTempSKU            NVARCHAR(20)
         , @nPackQty            INT
         , @nPickQty            INT

   DECLARE @cType               NVARCHAR(30)
         , @cLangCode           NVARCHAR(3)
         , @cStorerKey          NVARCHAR(15)
         , @cFacility           NVARCHAR(5)
         , @bIsDiscrete         BIT
         , @bIsCustom           BIT
         , @cPickSlipNo         NVARCHAR(10)
         , @cOrderKey           NVARCHAR(10)
         , @cLoadKey            NVARCHAR(10)
         , @cDropID             NVARCHAR(20)
         , @nCartonNo           INT
         , @cScannerVal         NVARCHAR(128)
         , @cInputValue1        NVARCHAR(128)
         , @cInputValue2        NVARCHAR(MAX)
         , @cInputValue3        NVARCHAR(128)
         , @cScanType           NVARCHAR(30)
         , @cSKU                NVARCHAR(20)
         , @nQty                INT
         , @bIsADInput          BIT
         , @bIsVASDone          BIT

   SET @bSuccess             = 1
   SET @bRequireInteraction  = 0
   SET @cInteractionCode     = ''
   SET @cInteractionType     = ''
   SET @cTitle               = ''
   SET @cMessage             = ''

   SET @cSKUToValidate       = ''
   SET @cStyleColor          = ''
   SET @cTempSKU             = ''
   SET @nPackQty             = 0
   SET @nPickQty             = 0

   SET @cType                = ''
   SET @cLangCode            = ''
   SET @cStorerKey           = ''
   SET @cFacility            = ''
   SET @bIsDiscrete          = 0
   SET @bIsCustom            = 0
   SET @cPickSlipNo          = ''
   SET @cOrderKey            = ''
   SET @cLoadKey             = ''
   SET @cDropID              = ''
   SET @nCartonNo            = 0
   SET @cScannerVal          = ''
   SET @cInputValue1         = ''
   SET @cInputValue2         = ''
   SET @cInputValue3         = ''
   SET @cScanType            = ''
   SET @bIsADInput           = 0
   SET @bIsVASDone           = 0
   SET @cSKU                 = ''
   SET @nQty                 = 0

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
   BEGIN
      SET @cInputValue1 = @cScannerVal
   END

   IF ( ISNULL(@cSKU, '') <> ''
      OR ISNULL(@cInputValue1, '') <> ''
   )
   BEGIN
      IF @cSKU <> ''
      AND EXISTS (SELECT 1
                  FROM SKU (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU
      )
      AND EXISTS (SELECT 1
                  FROM PICKDETAIL (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND OrderKey = @cOrderKey
                  AND SKU = @cSKU
      )
      BEGIN
         GOTO ValidateSKU
      END

      IF @cInputValue1 <> ''
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM SKU (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND SKU = @cInputValue1 
         )
         BEGIN
            SET @cSKU = @cInputValue1
            GOTO ValidateSKU
         END
         IF EXISTS ( SELECT 1
                     FROM UPC (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND UPC = @cInputValue1
                     AND UOM IN ('EA','EACH','PCS', '6', 'CS', 'CASE', 'CSE')
         )
         BEGIN
            SET @cSKU = (SELECT TOP 1 SKU
                           FROM UPC (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND UPC = @cInputValue1
                           AND UOM IN ('EA','EACH','PCS', '6', 'CS', 'CASE', 'CSE')
                        )
            GOTO ValidateSKU
         END
         IF EXISTS ( SELECT 1
                     FROM SKU (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND AltSKU = @cInputValue1 
         )
         BEGIN
            SET @cSKU = (SELECT TOP 1 SKU
                           FROM SKU (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND AltSKU = @cInputValue1
                        )
            GOTO ValidateSKU
         END
         IF EXISTS ( SELECT 1
                     FROM SKU (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND RetailSKU = @cInputValue1 
         )
         BEGIN
            SET @cSKU = (SELECT TOP 1 SKU
                           FROM SKU (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND RetailSKU = @cInputValue1
                        )
            GOTO ValidateSKU
         END
         IF EXISTS ( SELECT 1
                     FROM SKU (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND ManufacturerSKU = @cInputValue1 
         )
         BEGIN
            SET @cSKU = (SELECT TOP 1 SKU
                           FROM SKU (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND ManufacturerSKU = @cInputValue1
                        )
            GOTO ValidateSKU
         END
      END

      ValidateSKU:
      IF @cSKU <> ''
      BEGIN
         DECLARE CUR_SKU CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT(SKU)
         FROM PACKDETAIL (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND PickSlipNo = @cPickSlipNo
         AND CHARINDEX('_', SKU) > 0
         AND LEN(SKU) - LEN(REPLACE(SKU, '-', '')) < 2
         OPEN CUR_SKU
         FETCH NEXT FROM CUR_SKU INTO @cSKUToValidate
         WHILE @@FETCH_STATUS = 0
         BEGIN
            --SKU Format Check
            IF CHARINDEX('-', @cSKUToValidate) > 0
            AND CHARINDEX('-', @cSKUToValidate) > CHARINDEX('_', @cSKUToValidate)
            BEGIN
               GOTO NEXT_SKU
            END
            SET @cTempSKU = REPLACE(@cSKUToValidate, '-', '_')
            IF LEN(@cTempSKU) - LEN(REPLACE(@cTempSKU, '_', '')) <> 2
            OR CHARINDEX('_', @cTempSKU) <= 1
            OR CHARINDEX('_', @cTempSKU, CHARINDEX('_', @cTempSKU) + 1) <= CHARINDEX('_', @cTempSKU) + 1
            OR LEN(@cTempSKU) <= CHARINDEX('_', @cTempSKU, CHARINDEX('_', @cTempSKU) + 1)
            BEGIN
               GOTO NEXT_SKU
            END
            --Same Style Color Check
            SELECT @cStyleColor = LEFT(@cSKUToValidate, LEN(@cSKUToValidate) - CHARINDEX('_', REVERSE(@cSKUToValidate)))
            IF @cStyleColor = LEFT(@cSKU, LEN(@cSKU) - CHARINDEX('_', REVERSE(@cSKU)))
            BEGIN
               GOTO NEXT_SKU
            END
            --QTY Check
            SET @nPackQty = ( SELECT COALESCE(SUM(QTY), 0)
                              FROM PACKDETAIL (NOLOCK)
                              WHERE StorerKey = @cStorerKey
                              AND PickSlipNo = @cPickSlipNo
                              AND SKU LIKE @cStyleColor + '_%'
                           )
            IF @nPackQty > 0
            BEGIN
               SET @nPickQty = ( SELECT COALESCE(SUM(QTY), 0)
                                 FROM PICKDETAIL (NOLOCK)
                                 WHERE StorerKey = @cStorerKey
                                 AND OrderKey = @cOrderKey
                                 AND SKU LIKE @cStyleColor + '_%'
                              )
               IF @nPackQty <> @nPickQty
               BEGIN
                  SET @bSuccess = 1
                  SET @bRequireInteraction = 1
                  SET @cInteractionCode = 'PACK_SKU_CONFIRM'
                  SET @cInteractionType = 'CONFIRM'
                  SET @cTitle = 'PACK SKU'
                  SET @cMessage = API.TouchPadGetMessage(16401, @cLangCode, 'DSP') + '(' + @cStyleColor + ')' --Are you sure you want to pack this SKU? The previous SKU with different style color has not been fully packed. (@cStyleColor)
                  SET @arrButtons = '[{"cCode":"YES","cText":"Yes","cStyle":"PRIMARY"},{"cCode":"NO","cText":"No","cStyle":"SECONDARY"}]'
                  GOTO QUIT_CUR
               END
            END
            NEXT_SKU:
            FETCH NEXT FROM CUR_SKU INTO @cSKUToValidate
         END
         QUIT_CUR:
         CLOSE CUR_SKU
         DEALLOCATE CUR_SKU
      END
   END

   SET @c_ResponseString = ISNULL ((SELECT  @bSuccess                   AS bSuccess
                                          , @bRequireInteraction        AS bRequireInteraction
                                          , @cInteractionCode           AS cInteractionCode
                                          , @cInteractionType           AS cInteractionType
                                          , @cTitle                     AS cTitle
                                          , @cMessage                   AS cMessage
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
GRANT EXECUTE ON [API].[isp_TPACK_ValidateAction01] TO NSQL
GO