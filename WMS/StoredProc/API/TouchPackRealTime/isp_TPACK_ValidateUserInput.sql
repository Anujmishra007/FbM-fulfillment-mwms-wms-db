SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateUserInput                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Validate user input. Scanned or Manual Type                  */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-06   1.0  GCH225     Created                                          */
/* 2025-11-25   1.1  JWF011     UWP-42902: Add VAS Code QTY validation           */
/* 2025-12-09   1.2  JWF011     UWP-42902: Fix bug of VAS Code QTY validation    */
/* 2026-01-08   1.3  JWF011     UWP-42902: Add Solid SKU rule for VAS            */
/* 2026-01-09   1.4  JWF011     UWP-42902: Update Solid SKU rule for VAS         */
/* 2026-01-15   1.5  JWF011     UWP-42902: Fix MaxSKUCarton Rule                 */
/* 2026-01-21   2.0  GCH225     UWP-45700: Update WoWkOrdUDef1 to SKU            */
/* 2026-02-04   2.1  JWF011     UWP-48247: Add Recartonization check rule        */
/* 2026-02-24   2.2  GCH225     UWP-49353: Fix for Scan SKU into new Carton      */
/* 2026-03-03   2.3  GCH225     UWP-49786: Fix for Block Recartonization         */
/* 2026-03-12   2.4  GCH225     UWP-XXXXX: Skip UCC Carton Check for PreCartonize*/
/* 2026-04-01   3.0  GCH225     UWP-52975: Fine tune performance                 */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_ValidateUserInput] (
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
   , @bIsVASDone           BIT               = 0     
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @nPageIndex           INT               = 0
   , @nPageSize            INT               = 0
   , @c_OperationType      NVARCHAR(60)      = ''  
   , @cResponseJson        NVARCHAR(MAX)     = ''  OUTPUT
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

   DECLARE @cPackDecodeJson      NVARCHAR(MAX)
         , @cDecodedCol          NVARCHAR(100)
         , @cDecodedVal          NVARCHAR(100)               
         , @cPackDetailList      NVARCHAR(MAX)
         , @cSKUList             NVARCHAR(MAX)
         , @cLottableList        NVARCHAR(1000)
         , @bClickAll            BIT  
         , @bClickFirstOnly      BIT
         , @bShowADScreen        BIT
         , @bShowLottableScreen  BIT
         , @bShowNumpadScreen    BIT
         , @bShowVASScreen       BIT
         , @bAutoCloseCarton     BIT
         , @cConfigValue         NVARCHAR(30)
         , @cSQL                 NVARCHAR(MAX)
         , @cSQLParams           NVARCHAR(MAX)
         , @nNumberOfADField     INT
         , @nTtlPSNPackedQty     INT
         , @nTtlPDPackedQty      INT
         , @nRemNoADQty          INT
         , @nDisplayADQty        INT
         , @nPackOtherUnit2      INT
         , @cPackByLottable      NVARCHAR(10)
         , @cLottableNum         NVARCHAR(50)    
         , @cLotLabel            NVARCHAR(50)
         , @cLotDropDownBy       NVARCHAR(50)
         , @cAutoDefaultLot      NVARCHAR(50)
         , @bIsMultiSKU          BIT
         , @nExpectedSKUCnt      INT
         , @nActualSKUCnt        INT
         , @cLotWaveKey          NVARCHAR(30)
         , @cCartonStatus        NVARCHAR(20)
         , @cInProgressBy        NVARCHAR(256)
         , @bIsUCCPack           BIT
         , @nTtlQty              INT
         , @nTtlExpQty           INT
         , @bIsPreCartonize      BIT
         , @bAutoPickOrderFlag   BIT
         , @cAuthority           NVARCHAR(30)

   DECLARE @cVASCodeUDF2         NVARCHAR(60)   = ''
         , @cVASCodeUDF3         NVARCHAR(60)   = ''
         , @nWODQTY              INT            = 0

   DECLARE @oSKUList TABLE (
      SKU NVARCHAR(20) PRIMARY KEY
   )

   CREATE TABLE #oOrderKeyList (
      OrderKey NVARCHAR(10) PRIMARY KEY
   )

   DECLARE @tLottableList TABLE (    
            sku      NVARCHAR(20)
         , lottable  NVARCHAR(30)   
   )


   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  

   SET @bClickAll             = 0
   SET @bClickFirstOnly       = 1
   SET @bShowADScreen         = 0
   SET @bShowLottableScreen   = 0
   SET @bShowNumpadScreen     = 0
   SET @bShowVASScreen        = 0
   SET @bAutoCloseCarton      = 0
   SET @cResponseJson         = ''
   SET @cPackDetailList       = ''
   SET @cConfigValue          = ''
   SET @cSQL                  = ''
   SET @cSQLParams            = ''
   SET @nNumberOfADField      = 0
   SET @nTtlPSNPackedQty      = 0
   SET @nTtlPDPackedQty       = 0
   SET @nRemNoADQty           = 0
   SET @nDisplayADQty         = 0
   SET @nPackOtherUnit2       = 0
   SET @cPackByLottable       = ''
   SET @cLottableNum          = ''
   SET @cLotLabel             = ''
   SET @cLotDropDownBy        = ''
   SET @cAutoDefaultLot       = ''
   SET @bIsMultiSKU           = 0
   SET @nExpectedSKUCnt       = 0
   SET @nActualSKUCnt         = 0
   SET @cLotWaveKey           = ''
   SET @cCartonStatus         = ''
   SET @cInProgressBy         = ''
   SET @bIsUCCPack            = 0
   SET @nTtlQty               = 0
   SET @nTtlExpQty            = 0
   SET @bIsPreCartonize       = 0
   SET @bAutoPickOrderFlag    = 0
   SET @cAuthority            = ''

   IF @cLoadKey <> ''
   BEGIN
      INSERT INTO #oOrderKeyList (OrderKey)
      SELECT DISTINCT OrderKey
      FROM LOADPLANDETAIL (NOLOCK)
      WHERE LoadKey = @cLoadKey
   END

   --For Tote Conso Order and required to auto pick the orderkey and pickslip when user scan the SKU.
   IF @cType = 'toteid'
   AND @cPickSlipNo = '' 
   AND @cOrderKey = '' 
   AND @cLoadKey = ''
   AND @cDropID <> ''
   BEGIN
      SELECT TOP 1 @cPickSlipNo = PIF.PickSlipNo
      FROM PACKINFO PIF(NOLOCK)
      WHERE PIF.CartonNo = @nCartonNo
      AND PIF.EditWho = @c_UserID
      AND EXISTS (SELECT 1
                  FROM PACKDETAIL PD (NOLOCK)
                  WHERE PD.PickSlipNo = PIF.PickSlipNo
                  AND PD.CartonNo = PIF.CartonNo
                  AND PD.DropID = @cDropID
      )

      IF @@ROWCOUNT = 0 OR @cPickSlipNo = ''
      BEGIN
         SET @bAutoPickOrderFlag = 1
         IF @cScanType <> ''
         BEGIN
            GOTO SKIP_CARTON_CHECK
         END
         ELSE
         BEGIN
            GOTO SKIP_2ND_CHECK
         END
      END
      ELSE
      BEGIN
         IF @cOrderKey = ''
         BEGIN
            SELECT @cOrderKey = OrderKey
            FROM PICKHEADER (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo
         END
      END
   END

   --Check is the carton under inprogress status or closed status.
   IF @nCartonNo > 0 
   AND EXISTS (SELECT 1
               FROM PACKINFO (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
   )
   BEGIN
      SELECT @cCartonStatus = CartonStatus
           , @cInProgressBy = EditWho
           , @bIsUCCPack = IIF(ISNULL(UCCNo, '') <> '', 1, 0)
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo

      IF @@ROWCOUNT = 0
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11519
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PackInfo Detail Found(Abnoraml process). Kindly seek help from support team.'
         GOTO EXIT_SP
      END

      IF EXISTS(SELECT 1
                FROM PACKDETAIL (NOLOCK)
                WHERE PickSlipNo = @cPickSlipNo
                AND CartonNo = @nCartonNo
                AND ExpQty > 0
      )
      BEGIN
         SET @bIsPreCartonize = 1
      END

      IF @cCartonStatus <> 'INPROGRESS' AND LEN(@cCartonStatus) > 0
      BEGIN
         INSERT INTO @oSKUList (SKU)
         SELECT DISTINCT SKU 
         FROM (
            SELECT PD.SKU AS SKU
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND PD.SKU = @cInputValue1
            UNION ALL
            SELECT PD.SKU AS SKU
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND EXISTS (SELECT 1 
                        FROM SKU S (NOLOCK)
                        WHERE S.StorerKey = PD.StorerKey
                        AND S.SKU = PD.SKU
                        AND S.AltSKU = @cInputValue1
                        )
            UNION ALL
            SELECT PD.SKU AS SKU
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND EXISTS (SELECT 1 
                        FROM SKU S (NOLOCK)
                        WHERE S.StorerKey = PD.StorerKey
                        AND S.SKU = PD.SKU
                        AND S.RetailSKU = @cInputValue1
                        )
            UNION ALL
            SELECT PD.SKU AS SKU
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND EXISTS (SELECT 1 
                        FROM SKU S (NOLOCK)
                        WHERE S.StorerKey = PD.StorerKey
                        AND S.SKU = PD.SKU
                        AND S.ManufacturerSKU = @cInputValue1
                        )
            UNION ALL
            SELECT PD.SKU AS SKU
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND EXISTS (SELECT 1 
                        FROM UPC U (NOLOCK)
                        WHERE U.StorerKey = PD.StorerKey
                        AND U.SKU = PD.SKU
                        AND U.UPC = @cInputValue1
                        AND U.UOM IN ('EA','EACH','PCS', '6')
                        )
            UNION ALL
            SELECT PD.SKU AS SKU
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND EXISTS (SELECT 1 
                        FROM UCC U (NOLOCK)
                        WHERE U.StorerKey = PD.StorerKey
                        AND U.SKU = PD.SKU
                        AND U.UCCNo = @cInputValue1
                        )
            UNION ALL
            SELECT PD.SKU AS SKU
            FROM PACKDETAIL PD (NOLOCK)
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.CartonNo = @nCartonNo
            AND EXISTS (SELECT 1 
                        FROM PackSerialNo PSN (NOLOCK)
                        WHERE PSN.StorerKey = PD.StorerKey
                        AND PSN.PickSlipNo = PD.PickSlipNo
                        AND PSN.CartonNo = PD.CartonNo
                        AND PSN.LabelNo = PD.LabelNo
                        AND PSN.LabelLine = PD.LabelLine
                        AND PSN.SKU = PD.SKU
                        AND PSN.SerialNo = @cInputValue1
                        )
         )x

         IF (SELECT COUNT(1) FROM @oSKUList ) = 0
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11513
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + @cCartonStatus + ' carton. (' + @cInputValue1 + ')' --Packing Not Allow! SKU not found in current <cartonstatus> carton.
            GOTO EXIT_SP
         END
         ELSE
         BEGIN
            GOTO SEARCHSKU
         END
      END

      IF @cInProgressBy <> @c_UserID
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11520
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInProgressBy + ')'--'Failed to Perform Packing. Current in progress carton is in use by this user.' 
         GOTO EXIT_SP
      END

      IF @bIsUCCPack = 1 
      AND @bIsPreCartonize = 0
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11522
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Perform Packing. Current Carton already been packed by UCC.' 
         GOTO EXIT_SP
      END
   END

SKIP_CARTON_CHECK:

   --Determine whether is SKU or UPC or UCC or SerialNo or AD
   --After that determine whether need to prompt the AD screen
   IF @cScanType <> '' AND @cScanType IN ('sku','retailsku', 'manusku', 'altsku', 'upc', 'ucc', 'serialno', 'decode')
   BEGIN
      IF @cSKU = ''
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11501
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'SKU cannot be empty if ScanType not empty.  '
         GOTO EXIT_SP
      END

      INSERT INTO @oSKUList (SKU) 
      VALUES(@cSKU)

      IF @cInputValue3 <> '' OR @cInputValue2 <> ''
      BEGIN
         IF ISJSON(@cInputValue2) = 0
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11514
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--InputValue2 is not a valid JSON Array type.
            GOTO EXIT_SP
         END

         GOTO SKIP_VALIDATE
      END
      ELSE
      BEGIN
         GOTO SKIP_FINDSCANTYPE
      END
   END

SKIP_2ND_CHECK:

   IF EXISTS(SELECT 1
             FROM SKU (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND SKU = @cInputValue1
   )
   BEGIN
      SET @cScanType = 'sku'
      INSERT INTO @oSKUList (SKU)
      SELECT SKU
      FROM SKU (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND SKU = @cInputValue1
   END
   ELSE IF EXISTS(SELECT 1
             FROM SKU (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND AltSKU = @cInputValue1
   )
   BEGIN
      SET @cScanType = 'altsku'

      INSERT INTO @oSKUList (SKU)
      SELECT DISTINCT SKU
      FROM SKU (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND AltSKU = @cInputValue1 
   END
   ELSE IF EXISTS(SELECT 1
             FROM SKU (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND RetailSKU = @cInputValue1
   )
   BEGIN
      SET @cScanType = 'retailsku'
      INSERT INTO @oSKUList (SKU)
      SELECT DISTINCT SKU
      FROM SKU (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND RetailSKU = @cInputValue1
   END
   ELSE IF EXISTS(SELECT 1
             FROM SKU (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND ManufacturerSKU = @cInputValue1
   )
   BEGIN
      SET @cScanType = 'manusku'
      INSERT INTO @oSKUList (SKU)
      SELECT DISTINCT SKU
      FROM SKU (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND ManufacturerSKU = @cInputValue1
   END
   ELSE IF EXISTS(SELECT 1
             FROM UPC (NOLOCK)
             WHERE StorerKey = @cStorerKey
             AND UPC = @cInputValue1
             AND UOM IN ('EA','EACH','PCS', '6')
   )
   BEGIN
      SET @cScanType = 'upc'

      INSERT INTO @oSKUList (SKU)
      SELECT SKU 
      FROM UPC (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND UPC = @cInputValue1
      AND UOM IN ('EA','EACH','PCS', '6')
   END
   ELSE
   BEGIN
      IF EXISTS(SELECT 1
                  FROM SERIALNO (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND SerialNo = @cInputValue1
      )
      BEGIN
         SET @cScanType = 'serialno'

         IF EXISTS ( SELECT 1 
                     FROM SERIALNO(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                     AND SerialNo = @cInputValue1
                     AND [Status] >= '6'
         )
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11503
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'SerialNo. already been in used.  '
            GOTO EXIT_SP
         END

         INSERT INTO @oSKUList (SKU)
         SELECT DISTINCT SKU
         FROM SERIALNO(NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND SerialNo = @cInputValue1
      END
      ELSE 
      BEGIN
         EXEC nspGetRight    
            @c_Facility  = @cFacility    
            , @c_StorerKey = @cStorerKey   
            , @c_sku       = ''    
            , @c_ConfigKey = 'TPS-GetUCC'    
            , @c_authority = @cAuthority        OUTPUT    
            , @b_Success   = @b_Success         OUTPUT
            , @n_err       = @n_ErrNo           OUTPUT
            , @c_errmsg    = @c_ErrMsg          OUTPUT

         IF @b_Success = 0
         BEGIN    
            SET @n_Continue  = 3  
            GOTO EXIT_SP
         END

         IF @cAuthority = '1'
         AND EXISTS ( SELECT 1
                        FROM UCC (NOLOCK)
                        WHERE Storerkey = @cStorerKey
                        AND UCCNo = @cInputValue1
         )
         BEGIN
            SET @cScanType = 'ucc'

            IF EXISTS ( SELECT 1
                        FROM UCC (NOLOCK)
                        WHERE Storerkey = @cStorerKey
                        AND UCCNo = @cInputValue1
                        AND [Status] NOT IN ('1','2','3','4','5')
            )
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11504
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'UCCNo. already been in used.  '
               GOTO EXIT_SP
            END

            IF EXISTS(SELECT 1 
                      FROM PACKINFO (NOLOCK)
                      WHERE PickSlipNo = @cPickSlipNo
                      AND CartonNo = @nCartonNo
            )
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11521
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Pack UCC Failed. Current carton already been used for Non-UCC item.'
               GOTO EXIT_SP
            END

            INSERT INTO @oSKUList (SKU)
            SELECT DISTINCT SKU 
            FROM UCC (NOLOCK)
            WHERE Storerkey = @cStorerKey
            AND UCCNo = @cInputValue1

            SELECT @nQty = SUM(Qty)
            FROM UCC (NOLOCK)
            WHERE Storerkey = @cStorerKey
            AND UCCNo = @cInputValue1
         END
         ELSE
         BEGIN
            IF NOT EXISTS( SELECT 1 
                           FROM STORERCONFIG (NOLOCK) 
                           WHERE StorerKey = @cStorerKey 
                           AND ConfigKey = 'TPS-PackDecode' 
            )
            BEGIN
               SET @n_Continue  = 3
               SET @n_ErrNo = 11505
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cInputValue1 + ')' --'Invalid Barcode Scan. No Records Found. '
               GOTO EXIT_SP
            END

            SET @cScanType = 'decode'

            --for Barcode that required to decode
            --CheckPackConfig
            EXEC [API].[isp_TPACK_PackDecode_Wrapper]
                  @cType             = @cType            
               , @bIsDiscrete       = @bIsDiscrete      
               , @bIsCustom         = @bIsCustom        
               , @cPickSlipNo       = @cPickSlipNo       
               , @cOrderKey         = @cOrderKey         
               , @cLoadKey          = @cLoadKey          
               , @cDropID           = @cDropID  
               , @cStorerKey        = @cStorerKey        
               , @cFacility         = @cFacility      
               , @cInputValue1      = @cInputValue1
               , @cInputValue2      = @cInputValue2   OUTPUT
               , @cInputValue3      = @cInputValue3   OUTPUT
               , @c_UserID          = @c_UserID
               , @cLangCode         = @cLangCode
               , @cSKU              = @cSKU           OUTPUT
               , @nQty              = @nQty           OUTPUT
               , @b_Success         = @b_Success      OUTPUT
               , @n_ErrNo           = @n_ErrNo        OUTPUT
               , @c_ErrMsg          = @c_ErrMsg       OUTPUT

            IF @b_Success = 0
            BEGIN
               SET @n_Continue  = 3    
               GOTO EXIT_SP
            END

            INSERT INTO @oSKUList (SKU)
            VALUES (@cSKU)
         END
      END
   END

SKIP_FINDSCANTYPE:

   --Check number of SKU Count,  if more than 1 and is altSKU scanType and configkey enabled then proceed, else error
   SELECT @nExpectedSKUCnt = COUNT(1) 
   FROM @oSKUList

   IF @nExpectedSKUCnt > 1 
   BEGIN
      SET @bIsMultiSKU = 1

      IF @cScanType = 'altsku'
      BEGIN
         GOTO VALIDATE_SKU
      END

      SET @n_Continue  = 3
      SET @n_ErrNo = 11506
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + @cScanType --'Not allow more than 1 SKU found in following ScanType. '
      GOTO EXIT_SP
   END

VALIDATE_SKU:
   --Check the SKU make sure it exists in PickDetail with the orderkey
   IF @bIsDiscrete = 1
   BEGIN
      IF @cType = 'toteid'
      BEGIN
         -- only tote and b2c
         DELETE t
         FROM @oSKUList t 
         WHERE NOT EXISTS (SELECT 1 
                           FROM PICKDETAIL PD (NOLOCK)
                           WHERE PD.DropID = @cDropID
                           AND (@cOrderKey = '' OR PD.OrderKey = @cOrderKey)
                           AND PD.StorerKey = @cStorerKey
                           AND PD.SKU = t.SKU
                           AND NOT (
                              (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                              AND PD.[Status] = '9'
                           )
         )
      END
      ELSE
      BEGIN
         DELETE t
         FROM @oSKUList t 
         WHERE NOT EXISTS (SELECT 1 
                        FROM PICKDETAIL PD (NOLOCK)
                        WHERE PD.OrderKey = @cOrderKey
                        AND (@cDropID = '' OR PD.DropID = @cDropID)
                        AND PD.StorerKey = @cStorerKey
                        AND PD.SKU = t.SKU)
      END
   END
   ELSE
   BEGIN
      IF @cLoadKey = '' AND @cDropID = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11529
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to Perform Check SKU, LoadKey and DropID both are empty.
         GOTO EXIT_SP
      END

      IF @cType = 'toteid'
      BEGIN
         -- only tote and b2c
         DELETE t 
         FROM @oSKUList t 
         WHERE NOT EXISTS (SELECT 1 
                           FROM PICKDETAIL PD (NOLOCK)
                           WHERE (@cLoadKey = ''
                              OR EXISTS ( SELECT 1 
                                          FROM #oOrderKeyList OB
                                          WHERE OB.OrderKey = PD.OrderKey
                                       )
                              )
                           AND (@cOrderKey = '' OR PD.OrderKey = @cOrderKey)
                           AND PD.DropID = @cDropID
                           AND PD.StorerKey = @cStorerKey
                           AND t.SKU = PD.SKU
                           AND NOT (
                              (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                              AND PD.[Status] = '9'
                           )
         )
      END
      ELSE
      BEGIN
         DELETE t 
         FROM @oSKUList t 
         WHERE NOT EXISTS (SELECT 1 
                           FROM PICKDETAIL PD (NOLOCK)
                           WHERE (@cLoadKey = ''
                              OR EXISTS ( SELECT 1 
                                          FROM #oOrderKeyList OB
                                          WHERE OB.OrderKey = PD.OrderKey
                                       )
                              )
                           AND (@cDropID = '' OR PD.DropID = @cDropID)
                           AND PD.StorerKey = @cStorerKey
                           AND t.SKU = PD.SKU
                           )
      END
   END

   SELECT @nActualSKUCnt = COUNT(1) 
   FROM @oSKUList

   IF @nActualSKUCnt = 1
   BEGIN
      SET @bIsMultiSKU = 0
      SELECT @cSKU = SKU FROM @oSKUList
   END

   IF (@nExpectedSKUCnt = 1 AND @nActualSKUCnt <> 1)
   OR (@nExpectedSKUCnt > 1 AND @nActualSKUCnt < 1)
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = CASE @cType WHEN 'toteid'     THEN 11516
                                 WHEN 'order'      THEN 11517
                                 WHEN 'pickslip'   THEN 11507
                                 ELSE  11518
                                 END

      --11516 SKU not match with current Tote ID.
      --11517 SKU not match with current PickSlipNo.
      --11507 SKU not match with current OrderKey.
      --11518 SKU not found with Unknown cType.
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')
      GOTO EXIT_SP
   END

   --Check Multi SKU Selection
   EXEC [API].[isp_TPACK_CheckMultiSKUSelection]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cInputValue1      = @cInputValue1
      , @cInputValue2      = @cInputValue2
      , @cInputValue3      = @cInputValue3
      , @cScanType         = @cScanType
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @bIsMultiSKU       = @bIsMultiSKU
      , @bClickAll         = @bClickAll         OUTPUT
      , @bClickFirstOnly   = @bClickFirstOnly   OUTPUT
      , @b_Success         = @b_Success         OUTPUT
      , @n_ErrNo           = @n_ErrNo           OUTPUT
      , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue  = 3    
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
      IF @bClickAll = 1
      BEGIN
         GOTO SEARCHSKU
      END
   END

SKIP_VALIDATE:
   EXEC nspGetRight    
      @c_Facility  = @cFacility    
      , @c_StorerKey = @cStorerKey   
      , @c_sku       = ''    
      , @c_ConfigKey = 'TPS-PackQtyIndicator'    
      , @c_authority = @cAuthority        OUTPUT    
      , @b_Success   = @b_Success         OUTPUT
      , @n_err       = @n_ErrNo           OUTPUT
      , @c_errmsg    = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cAuthority = '1'
   BEGIN
      SELECT @nQty = ISNULL(PackQtyIndicator, 1) * @nQty 
      FROM SKU (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU
   END

   --If @bAutoPickOrderFlag is turn on, means need to temporarily auto assign the orderkey and pickslipno for subsequent packing process.
   IF @bAutoPickOrderFlag = 1
   BEGIN
      SELECT TOP 1 
         @cOrderKey = ISNULL(PH.OrderKey, '')
       , @cPickSlipNo = ISNULL(PH.PickHeaderKey, '')
      FROM PICKHEADER PH (NOLOCK)
      WHERE EXISTS ( SELECT 1 
                     FROM PICKDETAIL PD (NOLOCK)
                     WHERE PD.OrderKey = PH.OrderKey
                     AND PD.DropID = @cDropID
                     AND PD.SKU = @cSKU
                     AND NOT (
                        (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                        AND PD.[Status] = '9'
                     )
                  )
      AND NOT EXISTS (SELECT 1
                      FROM PACKHEADER PH2 (NOLOCK)
                      WHERE PH2.OrderKey = PH.OrderKey
                      AND PH2.PickSlipNo = PH.PickHeaderKey        
                      AND PH2.[Status] = '9'              
                  )
      ORDER BY PH.OrderKey ASC
      
      IF @@ROWCOUNT = 0 OR @cOrderKey = '' OR @cPickSlipNo = ''
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11530
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to auto assign Order and PickSlip for current Tote. No matching record found in PickDetail.'
         GOTO EXIT_SP
      END
   END
   -- Perform Check the Qty
   EXEC [API].[isp_TPACK_ValidateQtyPack]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey         
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID  
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility  
      , @cInputValue1      = @cInputValue1
      , @cScanType         = @cScanType
      , @cSKU              = @cSKU
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @nQty              = @nQty
      , @b_Success         = @b_Success   OUTPUT
      , @n_ErrNo           = @n_ErrNo     OUTPUT
      , @c_ErrMsg          = @c_ErrMsg    OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue  = 3    
      GOTO EXIT_SP
   END

   -- Recartonization Check Rule

   EXEC nspGetRight    
      @c_Facility  = @cFacility    
      , @c_StorerKey = @cStorerKey   
      , @c_sku       = ''    
      , @c_ConfigKey = 'TPS-RecartonBlocked'    
      , @c_authority = @cAuthority        OUTPUT    
      , @b_Success   = @b_Success         OUTPUT
      , @n_err       = @n_ErrNo           OUTPUT
      , @c_errmsg    = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cAuthority = '1'
   AND @nCartonNo = 0
   BEGIN
      
      SELECT  @nTtlQty = SUM(QTY)
            , @nTtlExpQty = SUM(ExpQty) 
      FROM PACKDETAIL (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND ExpQty > 0
      
      IF @nTtlExpQty > 0
      AND NOT EXISTS (  SELECT 1
                        FROM WorkOrderDetail WOD (NOLOCK)
                        JOIN CODELKUP CL (NOLOCK)
                        ON CL.Code = WOD.Type
                        WHERE WOD.ExternWorkOrderKey = @cOrderKey
                        AND CL.Listname = 'WKORDType'
                        AND CL.UDF02 IN ('ExactQTY', 'MAXQTY')
                        AND WOD.QTY > 0
                        AND WOD.Sku = @cSKU
                        AND EXISTS (SELECT 1 FROM PICKDETAIL PID (NOLOCK)
                                    WHERE PID.OrderKey = @cOrderKey
                                    AND PID.OrderLineNumber = WOD.ExternLineNo
                        )
      )
      BEGIN
         IF @nTtlQty = @nTtlExpQty
         BEGIN
            SET @n_ErrNo = 11527 --'Not Allow Recartonization'
         END
         ELSE
         BEGIN
            SET @n_ErrNo = 11528 --'Not allow to pack into a new carton. Please pack into the original pre carton.'
         END
         SET @n_Continue  = 3
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')
         GOTO EXIT_SP
      END  
   END
   -- Recartonization Check Rule (END)

   --VAS Code QTY Validation
   --Solid SKU Rule
   IF EXISTS ( SELECT 1 FROM PACKDETAIL (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
               AND SKU <> @cSKU
   )
   BEGIN
      IF EXISTS ( SELECT 1
                  FROM WorkOrderDetail WOD (NOLOCK)
                  JOIN CODELKUP CL (NOLOCK)
                     ON CL.Code = WOD.Type
                  WHERE WOD.ExternWorkOrderKey = @cOrderKey
                  AND CL.Listname = 'WKORDType'
                  AND CL.UDF02 IN ('ExactQTY', 'MAXQTY')
                  AND EXISTS (SELECT 1 FROM PICKDETAIL PID (NOLOCK)
                              WHERE PID.OrderKey = @cOrderKey
                              AND PID.OrderLineNumber = WOD.ExternLineNo
                  )
                  AND WOD.QTY > 0
                  AND WOD.Sku IN(SELECT SKU
                                 FROM PACKDETAIL (NOLOCK)
                                 WHERE PickSlipNo = @cPickSlipNo
                                 AND CartonNo = @nCartonNo
                                 AND SKU <> @cSKU
                                 UNION ALL
                                 SELECT @cSKU
                  )
      )
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11526
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Not allow to pack different SKU in a carton'
         GOTO EXIT_SP
      END
   END
   --Solid SKU Rule (END)

   DECLARE CUR_VAS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT CL.UDF02
        , CL.UDF03
        , WOD.QTY
   FROM WorkOrderDetail WOD (NOLOCK)
   JOIN CODELKUP CL (NOLOCK)
      ON CL.Code = WOD.Type
   WHERE WOD.ExternWorkOrderKey = @cOrderKey
   AND CL.Listname = 'WKORDType'
   AND (
         (WOD.ExternLineNo = '0H'
         AND CL.UDF02 = 'MaxSKUCarton'
         )  
      OR (
         EXISTS ( SELECT 1 FROM PICKDETAIL PID (NOLOCK)
                  WHERE PID.OrderKey = @cOrderKey
                  AND PID.OrderLineNumber = WOD.ExternLineNo
         )
         AND WOD.Sku = @cSKU
         AND WOD.QTY > 0
         AND CL.UDF02 IN ('ExactQTY', 'MAXQTY')
      )
   )
   OPEN CUR_VAS
   FETCH NEXT FROM CUR_VAS INTO @cVASCodeUDF2
                              , @cVASCodeUDF3
                              , @nWODQTY
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @cVASCodeUDF2 in ('ExactQTY', 'MAXQTY')
      BEGIN
         IF ISNULL( (SELECT SUM(QTY)
                     FROM PACKDETAIL (NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                     AND CartonNo = @nCartonNo
                     AND SKU = @cSKU)
                     , 0) + @nQty > @nWODQTY
         BEGIN
            SET @n_Continue  = 3
            IF @cVASCodeUDF2 = 'ExactQTY'
            BEGIN
               SET @n_ErrNo = 11523
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'QTY in a carton is more than VAS ExactQTY'
            END
            ELSE IF @cVASCodeUDF2 = 'MAXQTY'
            BEGIN
               SET @n_ErrNo = 11524
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'QTY in a carton is more than VAS MAXQTY'
            END
            GOTO EXIT_SP
         END
      END
      IF @cVASCodeUDF2 = 'MaxSKUCarton'
         AND TRY_CAST(ISNULL(@cVASCodeUDF3, '') AS INT) > 0
      BEGIN
         IF (SELECT COUNT(DISTINCT SKU) + 
               IIF(EXISTS(SELECT 1 FROM PACKDETAIL (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                        AND SKU = @cSKU
                        ), 0, 1)
            FROM PACKDETAIL (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
         ) > TRY_CAST(ISNULL(@cVASCodeUDF3, '') AS INT)
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11525
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Number of different SKU in a carton is more than VAS MaxSKUCarton'
            GOTO EXIT_SP
         END
      END

      FETCH NEXT FROM CUR_VAS INTO @cVASCodeUDF2
                                 , @cVASCodeUDF3
                                 , @nWODQTY
   END
   CLOSE CUR_VAS
   DEALLOCATE CUR_VAS
   --VAS Code QTY Validation (END)

   IF @c_OperationType = 'TPACK_SCANHANDLER'
   BEGIN
      EXEC nspGetRight    
           @c_Facility  = @cFacility    
         , @c_StorerKey = @cStorerKey   
         , @c_sku       = ''    
         , @c_ConfigKey = 'TPS-ShowNumpadScreen'    
         , @c_authority = @cAuthority        OUTPUT    
         , @b_Success   = @b_Success         OUTPUT
         , @n_err       = @n_ErrNo           OUTPUT
         , @c_errmsg    = @c_ErrMsg          OUTPUT

      IF @b_Success = 0
      BEGIN    
         SET @n_Continue  = 3  
         GOTO EXIT_SP
      END

      IF @cAuthority = '1'
      BEGIN
         SET @bShowNumpadScreen = 1
         GOTO SEARCHSKU
      END
      
      EXEC nspGetRight    
           @c_Facility  = @cFacility    
         , @c_StorerKey = @cStorerKey   
         , @c_sku       = ''    
         , @c_ConfigKey = 'TPS-ScanToSearch'    
         , @c_authority = @cAuthority        OUTPUT    
         , @b_Success   = @b_Success         OUTPUT
         , @n_err       = @n_ErrNo           OUTPUT
         , @c_errmsg    = @c_ErrMsg          OUTPUT

      IF @b_Success = 0
      BEGIN    
         SET @n_Continue  = 3  
         GOTO EXIT_SP
      END

      IF @cAuthority = '1'
      BEGIN
         GOTO SEARCHSKU
      END
   END

   --Perform AntiDiversion(ADBARCODE) Step
   IF ISJSON(@cInputValue2) = 1
   AND EXISTS (SELECT 1 FROM OPENJSON(@cInputValue2)) -- if InputValue2 already got value then skip AD logic step.
   BEGIN
      GOTO SKIP_AD
   END
   ELSE
   BEGIN
      IF NOT EXISTS(  SELECT 1 
                  FROM CODELKUP (NOLOCK) 
                  WHERE Listname = 'REQEXP'
                  AND Code = 'ADBARCODE'
                  AND StorerKey = @cStorerKey
      ) 
      OR 
      NOT EXISTS ( SELECT 1 
                   FROM SKU (NOLOCK) 
                   WHERE  StorerKey = @cStorerKey
                   AND SKU = @cSKU
                   AND SUSR4 = 'AD'
      )
      BEGIN
         GOTO SKIP_AD
      END

      SELECT @cConfigValue = RTRIM(sValue)
      FROM STORERCONFIG (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND ConfigKey = 'TPS-ExtSkipSKUADScn'

      IF @@ROWCOUNT <> 0
      BEGIN
         IF EXISTS(  SELECT 1 
                     FROM dbo.sysobjects 
                     WHERE name = @cConfigValue 
                     AND type = 'P'
         )
         BEGIN
            SET @cSQL = 'EXEC [API].[' + @cConfigValue + ']' + CHAR(13)
                      + '  @cType                ' + CHAR(13)
                      + ', @bIsDiscrete          ' + CHAR(13)
                      + ', @bIsCustom            ' + CHAR(13)
                      + ', @cPickSlipNo          ' + CHAR(13)
                      + ', @cOrderKey            ' + CHAR(13)
                      + ', @cLoadKey             ' + CHAR(13)
                      + ', @cDropID              ' + CHAR(13)
                      + ', @cStorerKey           ' + CHAR(13)
                      + ', @cFacility            ' + CHAR(13)    
                      + ', @c_UserID             ' + CHAR(13)
                      + ', @cLangCode            ' + CHAR(13)
                      + ', @cSkipSKUADScn OUTPUT ' + CHAR(13)    
                      + ', @b_Success     OUTPUT ' + CHAR(13)    
                      + ', @n_ErrNo       OUTPUT ' + CHAR(13)    
                      + ', @c_ErrMsg      OUTPUT ' + CHAR(13)      
                         
            SET @cSQLParams = '  @cType         NVARCHAR(30)          ' + CHAR(13)
                            + ', @bIsDiscrete   BIT                   ' + CHAR(13)
                            + ', @bIsCustom     BIT                   ' + CHAR(13)
                            + ', @cPickSlipNo   NVARCHAR(10)          ' + CHAR(13)
                            + ', @cOrderKey     NVARCHAR(10)          ' + CHAR(13)
                            + ', @cLoadKey      NVARCHAR(10)          ' + CHAR(13)
                            + ', @cDropID       NVARCHAR(20)          ' + CHAR(13)
                            + ', @cStorerKey    NVARCHAR(15)          ' + CHAR(13)
                            + ', @cFacility     NVARCHAR(5)           ' + CHAR(13)  
                            + ', @c_UserID      NVARCHAR(256)         ' + CHAR(13)
                            + ', @cLangCode     NVARCHAR(3)           ' + CHAR(13)
                            + ', @cSkipSKUADScn NVARCHAR(1)    OUTPUT ' + CHAR(13)  
                            + ', @b_Success     INT            OUTPUT ' + CHAR(13)  
                            + ', @n_ErrNo       INT            OUTPUT ' + CHAR(13)  
                            + ', @c_ErrMsg      NVARCHAR(20)   OUTPUT ' + CHAR(13)

            EXEC sp_ExecuteSQL  @cSQL
                              , @cSQLParams
                              , @cType
                              , @bIsDiscrete
                              , @bIsCustom
                              , @cPickSlipNo
                              , @cOrderKey    
                              , @cLoadKey
                              , @cDropID
                              , @cStorerKey
                              , @cFacility
                              , @c_UserID
                              , @cLangCode
                              , @cConfigValue OUTPUT    
                              , @b_Success    OUTPUT    
                              , @n_ErrNo      OUTPUT    
                              , @c_ErrMsg     OUTPUT    

            IF @b_Success = 0    
            BEGIN    
               SET @n_Continue  = 3
               SET @n_ErrNo = @n_ErrNo    
               SET @c_ErrMsg = @c_ErrMsg    
               GOTO EXIT_SP    
            END    
         END

         IF @cConfigValue = '1'
         BEGIN
            GOTO SKIP_AD
         END
      END

      EXEC nspGetRight    
         @c_Facility  = @cFacility    
         , @c_StorerKey = @cStorerKey   
         , @c_sku       = ''    
         , @c_ConfigKey = 'TPS-SkipUCCADScn'    
         , @c_authority = @cAuthority        OUTPUT    
         , @b_Success   = @b_Success         OUTPUT
         , @n_err       = @n_ErrNo           OUTPUT
         , @c_errmsg    = @c_ErrMsg          OUTPUT

      IF @b_Success = 0
      BEGIN    
         SET @n_Continue  = 3  
         GOTO EXIT_SP
      END

      IF @cAuthority = '1'
      AND @cScanType = 'ucc'
      BEGIN
         GOTO SKIP_AD
      END

      EXEC [API].[isp_TPACK_GetTotalADCount]
              @cType            = @cType            
            , @bIsDiscrete      = @bIsDiscrete      
            , @bIsCustom        = @bIsCustom        
            , @cPickSlipNo      = @cPickSlipNo       
            , @cOrderKey        = @cOrderKey
            , @cLoadKey         = @cLoadKey          
            , @cDropID          = @cDropID
            , @cStorerKey       = @cStorerKey        
            , @cFacility        = @cFacility   
            , @cInputValue1     = @cInputValue1
            , @cInputValue2     = @cInputValue2
            , @cInputValue3     = @cInputValue3
            , @cScanType        = @cScanType
            , @cSKU             = @cSKU
            , @nCartonNo        = @nCartonNo
            , @nQty             = @nQty
            , @c_UserID         = @c_UserID
            , @cLangCode        = @cLangCode
            , @nNumberOfADField = @nNumberOfADField   OUTPUT
            , @nDisplayADQty    = @nDisplayADQty      OUTPUT
            , @b_Success         = @b_Success         OUTPUT
            , @n_ErrNo           = @n_ErrNo           OUTPUT
            , @c_ErrMsg          = @c_ErrMsg          OUTPUT

         IF @b_Success = 0
         BEGIN
            SET @n_Continue  = 3    
            GOTO EXIT_SP
         END

      IF @nNumberOfADField >= 1
      BEGIN
         SET @bShowADScreen = 1
         GOTO SEARCHSKU
      END
   END

SKIP_AD:
   --Perform Lottable(PackByLottable) Step
   IF @cInputValue3 <> '' -- if InputValue3 already got value then skip lottable logic step.
   BEGIN
      GOTO SKIP_LOTTABLE
   END
   ELSE
   BEGIN
      EXEC nspGetRight    
            @c_Facility   = @cFacility    
         ,  @c_StorerKey  = @cStorerKey    
         ,  @c_sku        = ''    
         ,  @c_ConfigKey  = 'PackByLottable'    
         ,  @b_Success    = @b_Success       OUTPUT    
         ,  @c_authority  = @cPackByLottable OUTPUT    
         ,  @n_err        = @n_ErrNo         OUTPUT    
         ,  @c_errmsg     = @c_ErrMsg        OUTPUT 
         ,  @c_Option1    = @cLottableNum    OUTPUT    
         ,  @c_Option2    = @cLotLabel       OUTPUT    
         ,  @c_Option3    = @cLotDropDownBy  OUTPUT    
         ,  @c_Option4    = @cAutoDefaultLot OUTPUT   
   
      IF NOT (@cPackByLottable ='1' 
      AND @cAutoDefaultLot <> ''
      )
      BEGIN
         GOTO SKIP_LOTTABLE
      END

      IF @cLotDropDownBy IN('DROPDOWNBYPICKSLIP','DROPDOWNBYLOAD')
      BEGIN
         IF @bIsDiscrete = 1
         BEGIN
            INSERT INTO @tLottableList
            SELECT DISTINCT  PD.SKU AS sku
                           , CASE @cLottableNum WHEN '01' THEN LA.Lottable01    
                                                WHEN '02' THEN LA.Lottable02    
                                                WHEN '03' THEN LA.Lottable03    
                                                WHEN '04' THEN CONVERT(NVARCHAR,LA.Lottable04,121)    
                                                WHEN '05' THEN CONVERT(NVARCHAR,LA.Lottable05,121)    
                                                WHEN '06' THEN LA.Lottable06    
                                                WHEN '07' THEN LA.Lottable07    
                                                WHEN '08' THEN LA.Lottable08    
                                                WHEN '09' THEN LA.Lottable09    
                                                WHEN '10' THEN LA.Lottable10    
                                                WHEN '11' THEN LA.Lottable11    
                                                WHEN '12' THEN LA.Lottable12    
                                                WHEN '13' THEN CONVERT(NVARCHAR,LA.Lottable13,121)    
                                                WHEN '14' THEN CONVERT(NVARCHAR,LA.Lottable14,121)    
                                                WHEN '15' THEN CONVERT(NVARCHAR,LA.Lottable15,121)    
                                                END AS lottable
            FROM PICKDETAIL PD (NOLOCK)    
            JOIN LOTATTRIBUTE LA (NOLOCK) 
            ON PD.Lot = LA.Lot    
            WHERE PD.Orderkey = @cOrderKey    
            AND EXISTS (SELECT 1
                        FROM @oSKUList t
                        WHERE t.SKU = PD.SKU)
         END
         ELSE
         BEGIN
            INSERT INTO @tLottableList
            SELECT DISTINCT  PD.SKU AS sku
                           , CASE @cLottableNum WHEN '01' THEN LA.Lottable01    
                                                WHEN '02' THEN LA.Lottable02    
                                                WHEN '03' THEN LA.Lottable03    
                                                WHEN '04' THEN CONVERT(NVARCHAR,LA.Lottable04,121)    
                                                WHEN '05' THEN CONVERT(NVARCHAR,LA.Lottable05,121)    
                                                WHEN '06' THEN LA.Lottable06    
                                                WHEN '07' THEN LA.Lottable07    
                                                WHEN '08' THEN LA.Lottable08    
                                                WHEN '09' THEN LA.Lottable09    
                                                WHEN '10' THEN LA.Lottable10    
                                                WHEN '11' THEN LA.Lottable11    
                                                WHEN '12' THEN LA.Lottable12    
                                                WHEN '13' THEN CONVERT(NVARCHAR,LA.Lottable13,121)    
                                                WHEN '14' THEN CONVERT(NVARCHAR,LA.Lottable14,121)    
                                                WHEN '15' THEN CONVERT(NVARCHAR,LA.Lottable15,121)    
                                                END AS lottable
            FROM LOADPLANDETAIL LPD (NOLOCK)    
            JOIN PICKDETAIL PD (NOLOCK) 
            ON LPD.Orderkey = PD.Orderkey    
            JOIN LOTATTRIBUTE LA (NOLOCK) 
            ON PD.Lot = LA.Lot    
            WHERE LPD.Loadkey = @cLoadKey       
            AND EXISTS (SELECT 1
                        FROM @oSKUList t
                        WHERE t.SKU = PD.SKU)
         END
      END
      ELSE IF @cLotDropDownBy = 'DROPDOWNBYWAVE' 
      BEGIN
         SELECT TOP 1 @cLotWaveKey = WD.Wavekey    
         FROM PICKHEADER PH (NOLOCK)    
         JOIN ORDERS O (NOLOCK) 
         ON PH.Orderkey = O.Orderkey    
         JOIN WAVEDETAIL WD (NOLOCK) 
         ON O.Orderkey = WD.Orderkey    
         WHERE PH.Pickheaderkey = @cPickSlipNo 

         IF ISNULL(@cLotWaveKey,'') = ''
         BEGIN
            SELECT TOP 1 @cLotWaveKey = WD.Wavekey    
            FROM PICKHEADER PH (NOLOCK)    
            JOIN LOADPLANDETAIL LPD (NOLOCK) 
            ON PH.Externorderkey = LPD.Loadkey    
            JOIN WAVEDETAIL WD (NOLOCK) 
            ON LPD.Orderkey = WD.Orderkey    
            WHERE PH.Pickheaderkey = @cPickSlipNo    
            AND ISNULL(PH.Orderkey,'') = ''    
         END

         IF ISNULL(@cLotWaveKey,'') <> ''    
         BEGIN    
            INSERT INTO @tLottableList    
            SELECT DISTINCT  PD.SKU AS sku  
                           , CASE @cLottableNum WHEN '01' THEN LA.Lottable01    
                                                WHEN '02' THEN LA.Lottable02    
                                                WHEN '03' THEN LA.Lottable03    
                                                WHEN '04' THEN CONVERT(NVARCHAR,LA.Lottable04,121)    
                                                WHEN '05' THEN CONVERT(NVARCHAR,LA.Lottable05,121)    
                                                WHEN '06' THEN LA.Lottable06    
                                                WHEN '07' THEN LA.Lottable07    
                                                WHEN '08' THEN LA.Lottable08    
                                                WHEN '09' THEN LA.Lottable09    
                                                WHEN '10' THEN LA.Lottable10    
                                                WHEN '11' THEN LA.Lottable11    
                                                WHEN '12' THEN LA.Lottable12    
                                                WHEN '13' THEN CONVERT(NVARCHAR,LA.Lottable13,121)    
                                                WHEN '14' THEN CONVERT(NVARCHAR,LA.Lottable14,121)    
                                                WHEN '15' THEN CONVERT(NVARCHAR,LA.Lottable15,121)    
                                                END AS lottable      
            FROM WAVEDETAIL WD (NOLOCK)    
            JOIN PICKDETAIL PD (NOLOCK) 
            ON WD.Orderkey = PD.Orderkey    
            JOIN LOTATTRIBUTE LA (NOLOCK) 
            ON PD.Lot = LA.Lot    
            WHERE WD.Wavekey = @cLotWaveKey    
            AND EXISTS (SELECT 1
                        FROM @oSKUList t
                        WHERE t.SKU = PD.SKU)
         END 
      END   

      IF EXISTS(SELECT 1 
                  FROM @tLottableList l
                  WHERE EXISTS (SELECT 1 FROM @oSKUList s WHERE l.sku = s.sku)
                  AND l.lottable <> ''
      )
      BEGIN
         SET @cLottableList = JSON_QUERY(( SELECT sku, lottable
                                             FROM @tLottableList t
                                             WHERE t.lottable <> '' AND t.lottable IS NOT NULL
                                             FOR JSON PATH))
         SET @bShowLottableScreen = 1
         GOTO SEARCHSKU
      END
   END

SKIP_LOTTABLE:

   IF @bIsVASDone = 1
   BEGIN
      GOTO SKIP_VAS
   END
   ELSE
   BEGIN
      --Perform VAS step, if configured.
      IF EXISTS(  SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-VAS'
                  AND sValue IN ('1', '3')
                  AND (OPTION2 = '' OR OPTION2 IS NULL)
      ) 
      BEGIN
         SET @bShowVASScreen = 1
         GOTO SEARCHSKU
      END
   END

SKIP_VAS:

   --Perform Validate Input Step, if configured.
   EXEC [API].[isp_TPACK_ValidateInput_Wrapper]
           @cType             = @cType            
         , @bIsDiscrete       = @bIsDiscrete      
         , @bIsCustom         = @bIsCustom        
         , @cPickSlipNo       = @cPickSlipNo       
         , @cOrderKey         = @cOrderKey
         , @cLoadKey          = @cLoadKey          
         , @cDropID           = @cDropID
         , @cStorerKey        = @cStorerKey        
         , @cFacility         = @cFacility   
         , @cInputValue1      = @cInputValue1
         , @cInputValue2      = @cInputValue2
         , @cInputValue3      = @cInputValue3
         , @cScanType         = @cScanType
         , @cSKU              = @cSKU
         , @nCartonNo         = @nCartonNo
         , @nQty              = @nQty
         , @c_UserID          = @c_UserID
         , @cLangCode         = @cLangCode
         , @b_Success         = @b_Success    OUTPUT
         , @n_ErrNo           = @n_ErrNo      OUTPUT
         , @c_ErrMsg          = @c_ErrMsg     OUTPUT
   
   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3
      GOTO EXIT_SP
   END

   --PACK SKU
   EXEC [API].[isp_TPACK_Pack_SKU]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cInputValue1      = @cInputValue1
      , @cInputValue2      = @cInputValue2
      , @cInputValue3      = @cInputValue3
      , @cScanType         = @cScanType
      , @cSKU              = @cSKU
      , @nQty              = @nQty
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @nCartonNo         = @nCartonNo   OUTPUT
      , @b_Success         = @b_Success   OUTPUT
      , @n_ErrNo           = @n_ErrNo     OUTPUT
      , @c_ErrMsg          = @c_ErrMsg    OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue  = 3    
      GOTO EXIT_SP
   END
   ELSE
   BEGIN
      IF @cType = 'toteid'
      AND @nCartonNo > 0
      AND (EXISTS (SELECT 1
                  FROM ORDERS (NOLOCK)
                  WHERE OrderKey = @cOrderKey
                  AND DocType = 'E'
                  AND ECOM_SINGLE_Flag ='S'
         )
         OR
         (( SELECT SUM(QTY) 
            FROM PICKDETAIL (NOLOCK) 
            WHERE DropID = @cDropID
            AND OrderKey = @cOrderKey
         ) = 1
         AND  
         (( SELECT SUM(QTY) 
            FROM PACKDETAIL (NOLOCK) 
            WHERE PickSlipNo = @cPickSlipNo
            AND CartonNo = @nCartonNo
         ) = 1
         )
      ))
      BEGIN
         SET @bAutoCloseCarton = 1
      END

      GOTO GET_PACKDETAIL_LIST
   END

SEARCHSKU:
   --Search SKU
   SET @cSKUList = ISNULL((SELECT SKU FROM @oSKUList FOR JSON AUTO),'')

GET_PACKDETAIL_LIST:

   EXEC [API].[isp_TPACK_GetPackDetail]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cScanType         = @cScanType
      , @cSKUList          = @cSKUList
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @nCartonNo         = @nCartonNo
      , @nPageIndex        = @nPageIndex
      , @nPageSize         = @nPageSize
      , @cLottableList     = @cLottableList  
      , @cPackDetailList   = @cPackDetailList   OUTPUT
      , @b_Success         = @b_Success         OUTPUT
      , @n_ErrNo           = @n_ErrNo           OUTPUT
      , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue  = 3    
      GOTO EXIT_SP
   END

   -- Wait until capture the AD only close the carton only for ucc scan type.
   IF @bShowADScreen = 0 
   AND @bShowLottableScreen = 0 
   AND @bShowNumpadScreen = 0
   AND @bShowVASScreen = 0
   AND @cScanType = 'ucc'
   BEGIN
      SET @bAutoCloseCarton = 1 
   END

   SET @cResponseJson = ISNULL ((SELECT 
                                     JSON_QUERY((SELECT  @cScanType           AS cScanType
                                                       , @bClickAll           AS bClickAll
                                                       , @bClickFirstOnly     AS bClickFirstOnly
                                                       , @bShowADScreen       AS bShowADScreen
                                                       , @bShowLottableScreen AS bShowLottableScreen
                                                       , @bShowNumpadScreen   AS bShowNumpadScreen
                                                       , @bShowVASScreen      AS bShowVASScreen
                                                       , @bAutoCloseCarton    AS bAutoCloseCarton
                                                       , @nCartonNo           AS nCartonNo
                                                       , @nNumberOfADField    AS nNumberOfADField
                                                       , @nDisplayADQty       AS nDisplayADQty
                                                       , @nQty                AS nActualQty
                                     FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                                    )) AS meta
                                  , JSON_QUERY(CASE WHEN ISJSON(@cPackDetailList) = 1
                                                      THEN @cPackDetailList
                                                      ELSE '[]'
                                                      END) AS cPackDetailList
                                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ),'')

EXIT_SP:
   DROP TABLE IF EXISTS #oOrderKeyList

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
