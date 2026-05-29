SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_SearchSKU                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Perform checking by keyboard input                           */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-18   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_SearchSKU] (
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

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  
         , @b_sp_Success         INT  
         , @n_sp_err             INT  
         , @c_sp_errmsg          NVARCHAR(250)  = ''
         , @DBUserName           NVARCHAR(100)
         , @b_sp_ExecuteAs       BIT

   DECLARE @cType                NVARCHAR(30)
         , @bIsDiscrete          BIT
         , @bIsCustom            BIT
         , @cLangCode            NVARCHAR(3)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @cKeyboardVal         NVARCHAR(128)
         , @nCartonNo            INT
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @cPackDetailList      NVARCHAR(MAX)
         , @nPageSize            INT
         , @nPageIndex           INT
         , @cSKUList             NVARCHAR(MAX)
         , @cScanType            NVARCHAR(20)
         , @bClickAll            BIT  
         , @bClickFirstOnly      BIT
         , @bIsMultiSKU          BIT
         , @cCartonStatus        NVARCHAR(20)
   
   DECLARE @oUOMList TABLE (
      UOM NVARCHAR(20) PRIMARY KEY
   )
   
   DECLARE @oSKUList TABLE (
      SKU NVARCHAR(20) PRIMARY KEY
   )

   DECLARE @oLoadKeySKUList TABLE (
      SKU NVARCHAR(20) PRIMARY KEY
   )

   DECLARE @oOrderKeyList TABLE (
      OrderKey NVARCHAR(10) PRIMARY KEY
   )
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = ''  
   SET @c_ResponseString   = '' 
   SET @bIsDiscrete        = 1
   SET @bIsCustom          = 0
   SET @cKeyboardVal       = ''
   SET @nCartonNo          = 0
   SET @cPickSlipNo        = ''
   SET @cOrderKey          = ''
   SET @cLoadKey           = ''
   SET @cDropID            = ''
   SET @cPackDetailList    = ''
   SET @nPageIndex         = 0
   SET @nPageSize          = 20
   SET @cSKUList           = ''
   SET @cScanType          = 'sku'  -- set to sku is because after user chosen from the frontend it will always known as 'sku'
   SET @bClickAll          = 0
   SET @bClickFirstOnly    = 0
   SET @bIsMultiSKU        = 0
   SET @cCartonStatus      = ''

   EXEC [API].[isp_ECOMP_ValidateAndSetUser]
        @c_UserID      = @c_UserID
      , @c_DBUserName  = @DBUserName OUTPUT
      , @b_ExecuteAs   = @b_sp_ExecuteAs OUTPUT
      , @b_Success     = @b_sp_Success OUTPUT
      , @n_ErrNo       = @n_sp_err OUTPUT
      , @c_ErrMsg      = @c_sp_errmsg OUTPUT

   IF @b_sp_Success = 0
   BEGIN    
      SET @n_Continue = 3
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

   SELECT  @cType                = cType
         , @bIsDiscrete          = bIsDiscrete
         , @bIsCustom            = bIsCustom
         , @cPickSlipNo          = cPickSlipNo
         , @cOrderKey            = cOrderKey
         , @cLoadKey             = cLoadKey
         , @cDropID              = cDropID
         , @cLangCode            = cLangCode
         , @cStorerKey           = cStorerKey
         , @cFacility            = cFacility
         , @cKeyboardVal         = cKeyboardVal
         , @nCartonNo            = nCartonNo
   FROM OPENJSON(@c_RequestString)
   WITH (
         cType                NVARCHAR(30)
	    , bIsDiscrete          BIT
	    , bIsCustom            BIT
       , cPickSlipNo          NVARCHAR(10)
	    , cOrderKey            NVARCHAR(10)
       , cLoadKey             NVARCHAR(10)
       , cDropID              NVARCHAR(20)
       , cLangCode            NVARCHAR(3)
       , cStorerKey           NVARCHAR(15)
       , cFacility            NVARCHAR(5)
       , cKeyboardVal         NVARCHAR(128)
       , nCartonNo            INT
   )

   IF LEN(@cKeyboardVal) < 4
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 10551
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'cKeyboardVal cannot be less than 4 characters.'
      GOTO EXIT_SP
   END

   --Validate Standard Request Payload
   EXEC [API].[isp_TPACK_ValidateReqPayload]
        @cType             = @cType            
      , @bIsDiscrete       = @bIsDiscrete      
      , @bIsCustom         = @bIsCustom        
      , @cPickSlipNo       = @cPickSlipNo       
      , @cOrderKey         = @cOrderKey
      , @cLoadKey          = @cLoadKey          
      , @cDropID           = @cDropID
      , @cStorerKey        = @cStorerKey        
      , @cFacility         = @cFacility   
      , @cInputValue1      = @cKeyboardVal
      , @cInputValue2      = ''
      , @cInputValue3      = ''
      , @cScanType         = @cScanType
      , @cSKU              = ''
      , @nCartonNo         = @nCartonNo
      , @nQty              = 0
      , @c_UserID          = @c_UserID
      , @cLangCode         = @cLangCode
      , @nPageIndex        = 0
      , @nPageSize         = 20
      , @b_Success         = @b_Success   OUTPUT
      , @n_ErrNo           = @n_ErrNo     OUTPUT
      , @c_ErrMsg          = @c_ErrMsg    OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END

   INSERT INTO @oUOMList (UOM)
   VALUES ('EA'),('EACH'),('PCS'),('6'),('CS'),('CASE'),('CSE')
   IF @cLoadKey <> ''
   BEGIN
      INSERT INTO @oOrderKeyList (OrderKey)
      SELECT OrderKey
      FROM LOADPLANDETAIL (NOLOCK)
      WHERE LoadKey = @cLoadKey
   END
   ELSE IF @cOrderKey <> ''
   BEGIN 
      INSERT INTO @oOrderKeyList (OrderKey)
      VALUES (@cOrderKey)
   END
   ELSE IF @cLoadKey = '' AND @cOrderKey = '' AND @cDropID <> ''
   BEGIN
      INSERT INTO @oOrderKeyList (OrderKey)
      SELECT DISTINCT OrderKey
      FROM PICKDETAIL (NOLOCK)
      WHERE DropID = @cDropID
   END

   --Search the SKU, AltSKU, RetailSKU, ManufacturerSKU, UPC
   IF @nCartonNo > 0
   BEGIN
      IF @cType = 'toteid' AND @cPickSlipNo = ''
      BEGIN
         SELECT @cCartonStatus = ISNULL(PIF.CartonStatus,'')
               ,@cPickSlipNo = PIF.PickSlipNo
         FROM PACKINFO PIF (NOLOCK)
         WHERE EXISTS ( SELECT 1 
                        FROM PACKDETAIL PD (NOLOCK)
                        WHERE PD.PickSlipNo = PIF.PickSlipNo
                        AND PD.CartonNo = @nCartonNo
                        AND PD.DropID = @cDropID
                    )
         AND PIF.CartonNo = @nCartonNo
      END
      ELSE
      BEGIN
         SELECT @cCartonStatus = ISNULL(PIF.CartonStatus,'')
         FROM PACKINFO PIF (NOLOCK)
         WHERE PIF.PickSlipNo = @cPickSlipNo
         AND PIF.CartonNo = @nCartonNo
      END
   END

   IF @cCartonStatus <> 'INPROGRESS' AND LEN(@cCartonStatus) > 0
   BEGIN
      INSERT INTO @oSKUList (SKU)
      SELECT SKU 
      FROM (
         SELECT PD.SKU AS SKU
         FROM PACKDETAIL PD (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.CartonNo = @nCartonNo
         AND PD.SKU LIKE @cKeyboardVal + '%'
         UNION ALL
         SELECT PD.SKU AS SKU
         FROM PACKDETAIL PD (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.CartonNo = @nCartonNo
         AND EXISTS (SELECT 1 
                     FROM SKU S (NOLOCK)
                     WHERE S.StorerKey = PD.StorerKey
                     AND S.SKU = PD.SKU
                     AND S.AltSKU LIKE @cKeyboardVal + '%'
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
                     AND S.RetailSKU LIKE @cKeyboardVal + '%'
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
                     AND S.ManufacturerSKU LIKE @cKeyboardVal + '%'
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
                        AND U.UPC LIKE @cKeyboardVal + '%'
                        AND U.UOM IN (SELECT UOM FROM @oUOMList)
                        )        
      )x
      GROUP BY x.SKU
      ORDER BY LEN(x.SKU) ASC

      IF (SELECT COUNT(1) FROM @oSKUList ) = 0
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 10556
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + @cCartonStatus + ' carton. (' + @cKeyboardVal + ')' --Packing Not Allow! SKU not found in current <cartonstatus> carton.
         GOTO EXIT_SP
      END
   END
   ELSE 
   BEGIN
      IF @bIsDiscrete = 1
      BEGIN
         IF @cType = 'toteid'
         BEGIN
            -- only tote and b2c
            INSERT INTO @oSKUList (SKU)
            SELECT SKU 
            FROM (
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND PD.DropID = @cDropID
               AND PD.SKU LIKE @cKeyboardVal + '%'
               AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND PD.DropID = @cDropID
               AND EXISTS (SELECT 1 
                           FROM SKU S (NOLOCK)
                           WHERE S.StorerKey = PD.StorerKey
                           AND S.SKU = PD.SKU
                           AND S.AltSKU LIKE @cKeyboardVal + '%'
                           )
               AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND PD.DropID = @cDropID
               AND EXISTS (SELECT 1 
                           FROM SKU S (NOLOCK)
                           WHERE S.StorerKey = PD.StorerKey
                           AND S.SKU = PD.SKU
                           AND S.RetailSKU LIKE @cKeyboardVal + '%'
                           )
               AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND PD.DropID = @cDropID
               AND EXISTS (SELECT 1 
                           FROM SKU S (NOLOCK)
                           WHERE S.StorerKey = PD.StorerKey
                           AND S.SKU = PD.SKU
                           AND S.ManufacturerSKU LIKE @cKeyboardVal + '%'
                           )
               AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND PD.DropID = @cDropID
               AND EXISTS (SELECT 1 
                           FROM UPC U (NOLOCK)
                           WHERE U.StorerKey = PD.StorerKey
                           AND U.SKU = PD.SKU
                           AND U.UPC LIKE @cKeyboardVal + '%'
                           AND U.UOM IN (SELECT UOM FROM @oUOMList)
                           )
               AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
            )x
            GROUP BY x.SKU
            ORDER BY LEN(x.SKU) ASC

         END
         ELSE
         BEGIN
            INSERT INTO @oSKUList (SKU)
            SELECT SKU 
            FROM (
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND PD.SKU LIKE @cKeyboardVal + '%'
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND EXISTS (SELECT 1 
                           FROM SKU S (NOLOCK)
                           WHERE S.StorerKey = PD.StorerKey
                           AND S.SKU = PD.SKU
                           AND S.AltSKU LIKE @cKeyboardVal + '%'
                           )
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND EXISTS (SELECT 1 
                           FROM SKU S (NOLOCK)
                           WHERE S.StorerKey = PD.StorerKey
                           AND S.SKU = PD.SKU
                           AND S.RetailSKU LIKE @cKeyboardVal + '%'
                           )
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND EXISTS (SELECT 1 
                           FROM SKU S (NOLOCK)
                           WHERE S.StorerKey = PD.StorerKey
                           AND S.SKU = PD.SKU
                           AND S.ManufacturerSKU LIKE @cKeyboardVal + '%'
                           )
               UNION ALL
               SELECT PD.SKU AS SKU
               FROM PICKDETAIL PD (NOLOCK)
               WHERE PD.OrderKey = @cOrderKey
               AND (@cDropID = '' OR PD.DropID = @cDropID)
               AND EXISTS (SELECT 1 
                           FROM UPC U (NOLOCK)
                           WHERE U.StorerKey = PD.StorerKey
                           AND U.SKU = PD.SKU
                           AND U.UPC LIKE @cKeyboardVal + '%'
                           AND U.UOM IN (SELECT UOM FROM @oUOMList)
                           )
            )x
            GROUP BY x.SKU
            ORDER BY LEN(x.SKU) ASC
         END
      END
      ELSE
      BEGIN
         IF @cLoadKey = '' AND @cDropID = ''
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 10557
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to Perform Check SKU, LoadKey and DropID both are empty.
            GOTO EXIT_SP
         END

         IF @cType = 'toteid'
         BEGIN
            -- only tote and b2c
            INSERT INTO @oLoadKeySKUList (SKU)
            SELECT DISTINCT PD.SKU
            FROM PICKDETAIL PD (NOLOCK)
            WHERE EXISTS ( SELECT 1 
                           FROM @oOrderKeyList O
                           WHERE O.OrderKey = PD.OrderKey
                        )
            AND PD.DropID = @cDropID
            AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
         END
         ELSE
         BEGIN
            INSERT INTO @oLoadKeySKUList (SKU)
            SELECT DISTINCT PD.SKU
            FROM PICKDETAIL PD (NOLOCK)
            WHERE EXISTS ( SELECT 1 
                           FROM @oOrderKeyList O
                           WHERE O.OrderKey = PD.OrderKey
                        )
            AND (@cDropID = '' OR PD.DropID = @cDropID)
         END

         INSERT INTO @oSKUList (SKU)
         SELECT SKU
         FROM (
            SELECT SKU
            FROM @oLoadKeySKUList
            WHERE SKU LIKE @cKeyboardVal + '%'
            UNION ALL
            SELECT SKU
            FROM @oLoadKeySKUList t
            WHERE EXISTS (SELECT 1 
                          FROM SKU S (NOLOCK)
                          WHERE S.StorerKey = @cStorerKey
                          AND S.SKU = t.SKU
                          AND S.AltSKU LIKE @cKeyboardVal + '%'
                         )
            UNION ALL
            SELECT SKU
            FROM @oLoadKeySKUList t
            WHERE EXISTS (SELECT 1 
                          FROM SKU S (NOLOCK)
                          WHERE S.StorerKey = @cStorerKey
                          AND S.SKU = t.SKU
                          AND S.RetailSKU LIKE @cKeyboardVal + '%'
                         )
            UNION ALL
            SELECT SKU
            FROM @oLoadKeySKUList t
            WHERE EXISTS (SELECT 1 
                          FROM SKU S (NOLOCK)
                          WHERE S.StorerKey = @cStorerKey
                          AND S.SKU = t.SKU
                          AND S.ManufacturerSKU LIKE @cKeyboardVal + '%'
                         )
            UNION ALL
            SELECT SKU
            FROM @oLoadKeySKUList t
            WHERE EXISTS (SELECT 1 
                          FROM UPC U (NOLOCK)
                          WHERE U.StorerKey = @cStorerKey
                          AND U.SKU = t.SKU
                          AND U.UPC LIKE @cKeyboardVal + '%'
                          AND U.UOM IN (SELECT UOM FROM @oUOMList)
                         )
         )x
         GROUP BY x.SKU
         ORDER BY LEN(x.SKU) ASC
      END

      IF (SELECT COUNT(1) FROM @oSKUList ) > 1
      BEGIN
         SET @bIsMultiSKU = 1
      END

      IF EXISTS(SELECT 1
                FROM SKU (NOLOCK)
                WHERE StorerKey = @cStorerKey
                AND SKU = @cKeyboardVal
      ) 
      BEGIN
         SET @cScanType = 'sku'
      END
      ELSE IF EXISTS(SELECT 1
                FROM SKU (NOLOCK)
                WHERE StorerKey = @cStorerKey
                AND AltSKU = @cKeyboardVal
      ) 
      BEGIN
         SET @cScanType = 'altsku'
      END
      ELSE IF EXISTS(SELECT 1
                FROM SKU (NOLOCK)
                WHERE StorerKey = @cStorerKey
                AND RetailSKU = @cKeyboardVal
      ) 
      BEGIN
         SET @cScanType = 'retailsku'
      END
      ELSE IF EXISTS(SELECT 1
                FROM SKU (NOLOCK)
                WHERE StorerKey = @cStorerKey
                AND ManufacturerSKU = @cKeyboardVal
      ) 
      BEGIN
         SET @cScanType = 'manusku'
      END
      ELSE IF EXISTS(SELECT 1
                FROM UPC (NOLOCK)
                WHERE StorerKey = @cStorerKey
                AND UPC = @cKeyboardVal
                AND UOM IN (SELECT UOM FROM @oUOMList)
      ) 
      BEGIN
         SET @cScanType = 'upc'
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
         , @cInputValue1      = @cKeyboardVal
         , @cInputValue2      = ''
         , @cInputValue3      = ''
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
         SET @n_Continue = 3    
         GOTO EXIT_SP
      END

      IF (SELECT COUNT(1) FROM @oSKUList ) = 0
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = CASE @cType WHEN 'toteid'     THEN 10552
                                    WHEN 'order'      THEN 10553
                                    WHEN 'pickslip'   THEN 10554
                                    ELSE  10555
                                    END

         --10552 SKU not match with current Tote ID.
         --10553 SKU not match with current PickSlipNo.
         --10554 SKU not match with current OrderKey.
         --10555 SKU not found with Unknown cType.

         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + '(' + @cKeyboardVal + ')'
         GOTO EXIT_SP
      END
   END 

   SET @cSKUList = ISNULL((SELECT SKU FROM @oSKUList FOR JSON AUTO),'')

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
      , @cLottableList     = ''
      , @cPackDetailList   = @cPackDetailList   OUTPUT
      , @b_Success         = @b_Success         OUTPUT
      , @n_ErrNo           = @n_ErrNo           OUTPUT
      , @c_ErrMsg          = @c_ErrMsg          OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue = 3    
      GOTO EXIT_SP
   END

   SET @c_ResponseString = ISNULL ((SELECT 
                                     JSON_QUERY((SELECT  @cScanType           AS cScanType
                                                       , @bClickAll           AS bClickAll
                                                       , @bClickFirstOnly     AS bClickFirstOnly
                                                       , CAST(0 AS BIT)       AS bShowADScreen
                                                       , CAST(0 AS BIT)       AS bShowLottableScreen
                                                       , CAST(0 AS BIT)       AS bShowNumpadScreen
                                                       , CAST(0 AS BIT)       AS bShowVASScreen
                                                       , CAST(0 AS BIT)       AS bAutoCloseCarton
                                                       , @nCartonNo           AS nCartonNo
                                                       , 0                    AS nNumberOfADField
                                                       , 0                    AS nDisplayADQty
                                                       , 0                    AS nActualQty
                                     FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                                    )) AS meta
                                  , JSON_QUERY(CASE WHEN ISJSON(@cPackDetailList) = 1
                                                      THEN @cPackDetailList
                                                      ELSE '[]'
                                                      END) AS cPackDetailList
                                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ),'')

EXIT_SP:
   IF @b_sp_ExecuteAs = 1 REVERT
   EXEC [WM].[lsp_ResetUser]

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