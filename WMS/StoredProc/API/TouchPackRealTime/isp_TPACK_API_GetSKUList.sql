SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetSKUList                                     */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the list of sku per each order or loadkey in pickdetail  */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-09-25   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER  PROC [API].[isp_TPACK_API_GetSKUList] (
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
         , @cPickSlipNo          NVARCHAR(10)
         , @cOrderKey            NVARCHAR(10)
         , @cLoadKey             NVARCHAR(10)
         , @cDropID              NVARCHAR(20)
         , @cStorerKey           NVARCHAR(15)
         , @cFacility            NVARCHAR(5)
         , @nPageIndex           INT
         , @nPageSize            INT
         , @nOffset              INT
         , @cSearchValue         NVARCHAR(128)
   
   DECLARE @InitialSKUList TABLE (
      SKU               NVARCHAR(20)
    , DESCR             NVARCHAR(60)
    , MANUFACTURERSKU   NVARCHAR(20)
    , RETAILSKU         NVARCHAR(20)
    , ALTSKU            NVARCHAR(20)
    , SKUGROUP          NVARCHAR(10)
    , PACKKey           NVARCHAR(10)
    , nPickQty          INT
   )

   DECLARE @SKUList TABLE (
      cSKU        NVARCHAR(20)
    , cSKUDescr   NVARCHAR(60)
    , cSKUGroup   NVARCHAR(10)
    , cPackKey    NVARCHAR(10)
    , nPickQty    INT
    , nPackQty    INT
   )

   DECLARE @oOrderKeyList TABLE (
      OrderKey    NVARCHAR(10) PRIMARY KEY
   )
   
   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''  
   SET @c_ResponseString      = '' 
   SET @bIsDiscrete           = 1
   SET @bIsCustom             = 0
   SET @cLangCode             = ''
   SET @cPickSlipNo           = ''
   SET @cOrderKey             = ''
   SET @cLoadKey              = ''
   SET @cDropID               = ''
   SET @cStorerKey            = ''
   SET @cFacility             = ''
   SET @nPageIndex            = 0
   SET @nPageSize             = 20
   SET @nOffset               = 0
   SET @cSearchValue          = ''

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
   
   --Decode Json Format
   SELECT  @cType             = cType
         , @bIsDiscrete       = bIsDiscrete
         , @bIsCustom         = bIsCustom
         , @cPickSlipNo       = cPickSlipNo
         , @cOrderKey         = cOrderKey
         , @cLoadKey          = cLoadKey
         , @cDropID           = cDropID
         , @cLangCode         = cLangCode
         , @cStorerKey        = cStorerKey
         , @cFacility         = cFacility
         , @nPageIndex        = nPageIndex
         , @cSearchValue      = cSearchValue
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
       , cSearchValue         NVARCHAR(128)
       , nPageIndex           INT
   )

   SET @nOffset = ISNULL(@nPageIndex, 0)
   
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

   IF @bIsDiscrete = 1
   BEGIN
      IF @cType = 'toteid'
      BEGIN
         -- only tote and b2c
         INSERT INTO @InitialSKUList
         SELECT  S.SKU
               , S.DESCR 
               , S.MANUFACTURERSKU 
               , S.RETAILSKU 
               , S.ALTSKU 
               , S.SKUGROUP 
               , S.PACKKey 
               , SUM(PD.Qty) AS nPickQty
         FROM PICKDETAIL PD (NOLOCK)
         INNER JOIN SKU S (NOLOCK)
         ON PD.StorerKey = S.StorerKey
         AND PD.SKU = S.SKU
         WHERE PD.StorerKey = @cStorerKey
         AND PD.DropID = @cDropID
         AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
         AND (@cSearchValue = '' 
         OR ( 
               S.SKU LIKE CONCAT(@cSearchValue, '%') 
            OR S.DESCR LIKE CONCAT(@cSearchValue, '%') 
            OR S.SKUGROUP LIKE CONCAT(@cSearchValue, '%') 
            OR S.PACKKey LIKE CONCAT(@cSearchValue, '%')
            OR S.MANUFACTURERSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.RETAILSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.ALTSKU LIKE CONCAT(@cSearchValue, '%')
            OR EXISTS ( SELECT 1 
                        FROM UPC (NOLOCK)
                        WHERE UPC.StorerKey = @cStorerKey
                        AND UPC.SKU = S.SKU
                        AND UPC.PackKey = S.PACKKey
                        AND UPC.UPC LIKE CONCAT(@cSearchValue, '%')
                        AND UPC.UOM IN ('EA','EACH','PCS', '6')
                        )
            OR EXISTS ( SELECT 1 
                        FROM UCC (NOLOCK)
                        WHERE UCC.StorerKey = @cStorerKey
                        AND UCC.SKU = S.SKU
                        AND UCC.UCCNo LIKE CONCAT(@cSearchValue, '%')
                        )
         ))
         GROUP BY   S.SKU
                  , S.DESCR
                  , S.MANUFACTURERSKU 
                  , S.RETAILSKU 
                  , S.ALTSKU
                  , S.SKUGROUP
                  , S.PACKKey
      END
      ELSE
      BEGIN
         INSERT INTO @InitialSKUList
         SELECT  S.SKU
               , S.DESCR 
               , S.MANUFACTURERSKU 
               , S.RETAILSKU 
               , S.ALTSKU 
               , S.SKUGROUP 
               , S.PACKKey 
               , SUM(PD.Qty) AS nPickQty
         FROM PICKDETAIL PD (NOLOCK)
         INNER JOIN SKU S (NOLOCK)
         ON PD.StorerKey = S.StorerKey
         AND PD.SKU = S.SKU
         WHERE PD.StorerKey = @cStorerKey
         AND PD.OrderKey = @cOrderKey
         AND (@cDropID = '' OR PD.DropID = @cDropID)
         AND (@cSearchValue = '' 
         OR ( 
               S.SKU LIKE CONCAT(@cSearchValue, '%') 
            OR S.DESCR LIKE CONCAT(@cSearchValue, '%') 
            OR S.SKUGROUP LIKE CONCAT(@cSearchValue, '%') 
            OR S.PACKKey LIKE CONCAT(@cSearchValue, '%')
            OR S.MANUFACTURERSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.RETAILSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.ALTSKU LIKE CONCAT(@cSearchValue, '%')
            OR EXISTS ( SELECT 1 
                        FROM UPC (NOLOCK)
                        WHERE UPC.StorerKey = @cStorerKey
                        AND UPC.SKU = S.SKU
                        AND UPC.PackKey = S.PACKKey
                        AND UPC.UPC LIKE CONCAT(@cSearchValue, '%')
                        AND UPC.UOM IN ('EA','EACH','PCS', '6')
                        )
            OR EXISTS ( SELECT 1 
                        FROM UCC (NOLOCK)
                        WHERE UCC.StorerKey = @cStorerKey
                        AND UCC.SKU = S.SKU
                        AND UCC.UCCNo LIKE CONCAT(@cSearchValue, '%')
                        )
         ))
         GROUP BY   S.SKU
                  , S.DESCR
                  , S.MANUFACTURERSKU 
                  , S.RETAILSKU 
                  , S.ALTSKU
                  , S.SKUGROUP
                  , S.PACKKey
      END
   END
   ELSE
   BEGIN
      IF @cType = 'toteid'
      BEGIN
         -- only tote and b2c
         INSERT INTO @InitialSKUList
         SELECT  S.SKU
               , S.DESCR 
               , S.MANUFACTURERSKU 
               , S.RETAILSKU 
               , S.ALTSKU 
               , S.SKUGROUP 
               , S.PACKKey 
               , SUM(PD.Qty) AS nPickQty
         FROM PICKDETAIL PD (NOLOCK)
         INNER JOIN SKU S (NOLOCK)
         ON PD.StorerKey = S.StorerKey
         AND PD.SKU = S.SKU
         WHERE PD.StorerKey = @cStorerKey
         AND EXISTS (SELECT 1 
                     FROM @oOrderKeyList O 
                     WHERE O.OrderKey = PD.OrderKey
                     )
         AND PD.DropID = @cDropID
         AND NOT (
                  (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
                  AND PD.[Status] = '9'
               )
         AND (@cSearchValue = '' 
         OR ( 
               S.SKU LIKE CONCAT(@cSearchValue, '%') 
            OR S.DESCR LIKE CONCAT(@cSearchValue, '%') 
            OR S.SKUGROUP LIKE CONCAT(@cSearchValue, '%') 
            OR S.PACKKey LIKE CONCAT(@cSearchValue, '%')
            OR S.MANUFACTURERSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.RETAILSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.ALTSKU LIKE CONCAT(@cSearchValue, '%')
            OR EXISTS ( SELECT 1 
                        FROM UPC (NOLOCK)
                        WHERE UPC.StorerKey = @cStorerKey
                        AND UPC.SKU = S.SKU
                        AND UPC.PackKey = S.PACKKey
                        AND UPC.UPC LIKE CONCAT(@cSearchValue, '%')
                        AND UPC.UOM IN ('EA','EACH','PCS', '6')
                        )
            OR EXISTS ( SELECT 1 
                        FROM UCC (NOLOCK)
                        WHERE UCC.StorerKey = @cStorerKey
                        AND UCC.SKU = S.SKU
                        AND UCC.UCCNo LIKE CONCAT(@cSearchValue, '%')
                        )
         ))
         GROUP BY   S.SKU
                  , S.DESCR
                  , S.MANUFACTURERSKU 
                  , S.RETAILSKU 
                  , S.ALTSKU
                  , S.SKUGROUP
                  , S.PACKKey
      END
      ELSE
      BEGIN
         INSERT INTO @InitialSKUList
         SELECT  S.SKU
               , S.DESCR 
               , S.MANUFACTURERSKU 
               , S.RETAILSKU 
               , S.ALTSKU 
               , S.SKUGROUP 
               , S.PACKKey 
               , SUM(PD.Qty) AS nPickQty
         FROM PICKDETAIL PD (NOLOCK)
         INNER JOIN SKU S (NOLOCK)
         ON PD.StorerKey = S.StorerKey
         AND PD.SKU = S.SKU
         WHERE PD.StorerKey = @cStorerKey
         AND EXISTS (SELECT 1 
                     FROM @oOrderKeyList O 
                     WHERE O.OrderKey = PD.OrderKey
                  )
         AND (@cDropID = '' OR PD.DropID = @cDropID)
         AND (@cSearchValue = '' 
         OR ( 
               S.SKU LIKE CONCAT(@cSearchValue, '%') 
            OR S.DESCR LIKE CONCAT(@cSearchValue, '%') 
            OR S.SKUGROUP LIKE CONCAT(@cSearchValue, '%') 
            OR S.PACKKey LIKE CONCAT(@cSearchValue, '%')
            OR S.MANUFACTURERSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.RETAILSKU LIKE CONCAT(@cSearchValue, '%')
            OR S.ALTSKU LIKE CONCAT(@cSearchValue, '%')
            OR EXISTS ( SELECT 1 
                        FROM UPC (NOLOCK)
                        WHERE UPC.StorerKey = @cStorerKey
                        AND UPC.SKU = S.SKU
                        AND UPC.PackKey = S.PACKKey
                        AND UPC.UPC LIKE CONCAT(@cSearchValue, '%')
                        AND UPC.UOM IN ('EA','EACH','PCS', '6')
                        )
            OR EXISTS ( SELECT 1 
                        FROM UCC (NOLOCK)
                        WHERE UCC.StorerKey = @cStorerKey
                        AND UCC.SKU = S.SKU
                        AND UCC.UCCNo LIKE CONCAT(@cSearchValue, '%')
                        )
         ))
         GROUP BY   S.SKU
                  , S.DESCR
                  , S.MANUFACTURERSKU 
                  , S.RETAILSKU 
                  , S.ALTSKU
                  , S.SKUGROUP
                  , S.PACKKey
      END
   END

   IF @@ROWCOUNT = 0
   BEGIN
      GOTO PROCEED
   END
   
   IF @bIsCustom = 1 AND @cType = 'order'
   BEGIN
      INSERT INTO @SKUList
      SELECT  Y.SKU 
            , Y.DESCR 
            , Y.SKUGROUP
            , Y.PACKKey 
            , Y.nPickQty
            , SUM(Y.nPackQty) AS nPackQty
      FROM (
         SELECT  X.SKU 
               , X.DESCR 
               , X.SKUGROUP
               , X.PACKKey 
               , X.nPickQty 
               , IIF(SUM(ISNULL(PD3.Qty,-999)) = -999  -- if pickdetail not found, then return 0 as pack qty
                     , 0
                     , IIF(SUM(ISNULL(PD2.Qty,0)) > X.nPickQty
                        , SUM(ISNULL(PD3.Qty, 0))
                        , SUM(ISNULL(PD2.Qty, 0))
                        )
                     ) AS nPackQty
         FROM @InitialSKUList X
         LEFT JOIN PACKDETAIL PD2 (NOLOCK)
         ON PD2.StorerKey = @cStorerKey
         AND PD2.PickSlipNo = @cPickSlipNo
         AND PD2.SKU = X.SKU
         AND EXISTS (SELECT 1 
                     FROM PACKINFO PKI (NOLOCK)
                     WHERE PKI.PickSlipNo = PD2.PickSlipNo
                     AND PKI.CartonNo = PD2.CartonNo
                     AND PKI.CartonStatus IN ('HOLD', 'CLOSED')
                     )
         LEFT JOIN PICKDETAIL PD3 (NOLOCK)
         ON PD3.OrderKey = @cOrderKey
         AND PD3.CaseID = PD2.LabelNo
         AND PD3.SKU = PD2.SKU
         GROUP BY   X.SKU
                  , X.DESCR
                  , X.SKUGROUP
                  , X.PACKKey
                  , X.nPickQty
         UNION ALL
         SELECT  X.SKU
               , X.DESCR 
               , X.SKUGROUP
               , X.PACKKey
               , X.nPickQty
               , SUM(ISNULL(PD2.Qty,0)) AS nPackQty
         FROM @InitialSKUList X
         LEFT JOIN PACKDETAIL PD2 (NOLOCK)
         ON PD2.StorerKey = @cStorerKey
         AND PD2.PickSlipNo = @cPickSlipNo
         AND PD2.SKU = X.SKU
         AND EXISTS (SELECT 1 
                        FROM PACKINFO PKI (NOLOCK)
                        WHERE PKI.PickSlipNo = PD2.PickSlipNo
                        AND PKI.CartonNo = PD2.CartonNo
                        AND PKI.CartonStatus NOT IN ('HOLD', 'CLOSED')
                        )
         GROUP BY   X.SKU
                  , X.DESCR
                  , X.SKUGROUP
                  , X.PACKKey
                  , X.nPickQty
      ) Y
      GROUP BY   Y.SKU 
               , Y.DESCR 
               , Y.SKUGROUP
               , Y.PACKKey 
               , Y.nPickQty
   END
   ELSE
   BEGIN
      IF @cPickSlipNo = '' AND @cDropID = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11952
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Failed to Perform Check SKU, PickSlipNo and DropID both are empty.
         GOTO EXIT_SP
      END
      
      INSERT INTO @SKUList
      SELECT  X.SKU
            , X.DESCR 
            , X.SKUGROUP
            , X.PACKKey
            , X.nPickQty
            , SUM(ISNULL(PD2.Qty,0))
      FROM @InitialSKUList X
      LEFT JOIN PACKDETAIL PD2 (NOLOCK)
      ON PD2.StorerKey = @cStorerKey
      AND (@cPickSlipNo = '' OR PD2.PickSlipNo = @cPickSlipNo)
      AND PD2.SKU = X.SKU
      AND (@cDropID = '' OR PD2.DropID = @cDropID)
      GROUP BY   X.SKU
               , X.DESCR
               , X.SKUGROUP
               , X.PACKKey
               , X.nPickQty
   END

PROCEED:
   SET @c_ResponseString = ISNULL ((SELECT  cSKU     
                                          , cSKUDescr
                                          , cSKUGroup
                                          , cPackKey 
                                          , nPickQty 
                                          , nPackQty 
                                    FROM @SKUList 
                                    ORDER BY cSKU DESC
                                    OFFSET ISNULL(@nOffset,0) ROWS
                                    FETCH NEXT ISNULL(@nPageSize,20) ROWS ONLY
                                    FOR JSON AUTO, ROOT('SKUs')
                                    ),'{"SKUs":[]}')

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