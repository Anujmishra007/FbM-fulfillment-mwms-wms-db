SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************************/
/* Store procedure: isp_TPACK_GetVasInfo_Std                                            */
/* Copyright      : Maersk                                                              */
/*                                                                                      */
/* Purpose        : Standard Get VAS Info from WorkOrder table                          */
/*                                                                                      */
/* Date         Rev  Author     Purposes                                                */
/* 2025-11-25   1.0  GCH225     Created                                                 */
/* 2025-12-26   2.0  GCH225     UWP-46021 Fix at line 143 only                          */
/* 2026-01-09   3.0  GCH225     UWP-46666 Fix 0H display during Carton level            */
/* 2026-01-09   3.1  GCH225     UWP-46652 Fix 0H display first scan in every new carton */
/* 2026-01-14   4.0  GCH225     UWP-47007 Fix 0H display during Carton level            */
/* 2026-01-21   5.0  GCH225     UWP-45700 Update WoWkOrdUDef1 to SKU                    */
/* 2026-01-26   6.0  GCH225     UWP-47606 Fix 0H display first scan in exists carton    */
/* 2026-01-28   7.0  GCH225     UWP-47815 Fix Codelkup Short Show VAS issue             */
/* 2026-02-12   8.0  GCH225     UWP-48885 Fix 0H Header flag for PreCartonize case      */
/* 2026-02-27   8.1  JWF011     UWP-49173 Fix Order Header VAS display 2 times          */
/* 2026-04-03   8.2  GCH225     UWP-53582 Fix Print Type that Short column ='Y'         */
/****************************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_GetVasInfo_Std] (
	  @cType          NVARCHAR(30)   = ''
   , @bIsDiscrete    BIT            = 0
   , @bIsCustom      BIT            = 0
   , @cPickSlipNo    NVARCHAR(10)   = ''
   , @cOrderKey      NVARCHAR(10)   = ''
   , @cLoadKey       NVARCHAR(10)   = ''
   , @cDropID        NVARCHAR(20)   = ''
   , @cStorerKey     NVARCHAR(15)   = ''
   , @cFacility      NVARCHAR(5)    = ''
   , @nCartonNo      INT            = 0
   , @cSKU           NVARCHAR(20)   = ''      
   , @c_UserID       NVARCHAR(256)  = ''  
   , @cLangCode      NVARCHAR(3)    = ''
   , @cResponseJson  NVARCHAR(MAX)  = ''  OUTPUT
   , @b_Success      INT            = 0   OUTPUT
   , @n_ErrNo        INT            = 0   OUTPUT
   , @c_ErrMsg       NVARCHAR(250)  = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue  INT            = 1  
         , @n_StartCnt  INT            = @@TRANCOUNT   

         , @cTPSVAS              NVARCHAR(30) 
         , @c_Option1            NVARCHAR(50)
         , @c_Option2            NVARCHAR(50)
         , @c_Option3            NVARCHAR(50)
         , @c_Option4            NVARCHAR(50)
         , @c_Option5            NVARCHAR(4000)

         , @bShowOrderHeaderVAS  BIT
         , @nCheckQty            INT

   DECLARE @VASInfo TABLE(
      nRowRef           BIGINT PRIMARY KEY IDENTITY(1,1)
    , cSKU              NVARCHAR(20)
    , cCode             NVARCHAR(100)
    , cDescr            NVARCHAR(250)
    , fPrice            DECIMAL(10,2)
    , cType             NVARCHAR(100)
    , cPrintDocID       NVARCHAR(50)
    , bIsMandatory      BIT
    , cStatus           NVARCHAR(10)
    , bShowFlag         BIT
    , cExternLineNo     NVARCHAR(5)
   )

   DECLARE @OrderList TABLE(
      OrderKey NVARCHAR(10) PRIMARY KEY
   )
   SET @b_Success             = 0  
   SET @n_ErrNo               = 0  
   SET @c_ErrMsg              = ''
   SET @bShowOrderHeaderVAS   = 0
   SET @nCheckQty             = 0
   SET @cResponseJson = '{"VASs":[]}'

   -- Get VAS Info for specific SKU only.
   IF NOT EXISTS (SELECT 1 
                  FROM WORKORDER (NOLOCK)
                  WHERE ExternWorkOrderKey = @cOrderKey
                  AND StorerKey = @cStorerKey
                  AND Facility = @cFacility
                  AND [Type] IN('PACK', 'VAS')
   )
   BEGIN
      GOTO EXIT_SP
   END

   EXEC nspGetRight    
        @c_Facility  = @cFacility    
      , @c_StorerKey = @cStorerKey   
      , @c_sku       = ''    
      , @c_ConfigKey = 'TPS-VAS'    
      , @c_authority = @cTPSVAS     OUTPUT    
      , @b_Success   = @b_Success   OUTPUT    
      , @n_err       = @n_ErrNo     OUTPUT    
      , @c_errmsg    = @c_ErrMsg    OUTPUT
      , @c_Option1   = @c_Option1   OUTPUT
      , @c_Option2   = @c_Option2   OUTPUT
      , @c_Option3   = @c_Option3   OUTPUT
      , @c_Option4   = @c_Option4   OUTPUT
      , @c_Option5   = @c_Option5   OUTPUT

   IF @b_Success = 0
   BEGIN    
      SET @n_Continue  = 3  
      GOTO EXIT_SP
   END

   IF @cOrderKey <> ''
   BEGIN
      INSERT INTO @OrderList (OrderKey)
      VALUES (@cOrderKey)

      IF (@nCartonNo = 0 
      OR (@nCartonNo > 0 
         AND NOT EXISTS(SELECT 1 
                        FROM PACKINFO (NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                        AND CartonNo = @nCartonNo
                       )
      )) OR (@nCartonNo = 1
            AND ( SELECT SUM(PD.Qty) 
                  FROM PACKDETAIL PD (NOLOCK)
                  WHERE PD.PickSlipNo = @cPickSlipNo
                  AND PD.CartonNo = @nCartonNo
                  AND PD.ExpQty > 0
            ) = 0
      )
      BEGIN
         SET @bShowOrderHeaderVAS = 1
      END

      --SELECT @nCheckQty = ISNULL(SUM(Qty),0)
      --FROM PACKINFO (NOLOCK)
      --WHERE PickSlipNo = @cPickSlipNo

      --IF @@ROWCOUNT <= 1 AND @nCheckQty = 0 AND @nCartonNo <= 1
      --BEGIN
      --   SET @bShowOrderHeaderVAS = 1
      --END
   END
   ELSE IF @cLoadKey <> ''
   BEGIN
      INSERT INTO @OrderList (OrderKey)
      SELECT OrderKey
      FROM LOADPLANDETAIL (NOLOCK)
      WHERE LoadKey = @cLoadKey
   END

   INSERT INTO @VASInfo ( cSKU
                        , cCode
                        , cDescr
                        , fPrice
                        , cType
                        , cPrintDocID
                        , bIsMandatory
                        , cStatus
                        , bShowFlag
                        , cExternLineNo
                        )
                  SELECT  IIF(WOD.ExternLineNo = '0H', @cSKU, WOD.Sku)
                        , WOD.[Type]
                        , CLK.[Description]
                        , WOD.Price
                        , IIF(CLK.UDF01 <> '', 'print', '')
                        , IIF(CLK.UDF01 <> '', CLK.UDF01, '')
                        , @c_Option1
                        , WOD.[Status]
                        , IIF(CLK.Short = 'Y', 0, 1)
                        , WOD.ExternLineNo
                  FROM WORKORDERDETAIL WOD (NOLOCK)
                  LEFT JOIN CODELKUP CLK (NOLOCK)
                  ON WOD.[Type] = CLK.Code
                  WHERE CLK.LISTNAME = 'WKOrdType'
                  AND CLK.Short <> 'Y'  -- Not equal to Y means required to show VAS.
                  AND EXISTS (SELECT 1
                              FROM WORKORDER WO (NOLOCK)
                              WHERE EXISTS ( SELECT 1 
                                             FROM @OrderList t
                                             WHERE t.OrderKey = WO.ExternWorkOrderKey
                                             )
                              AND StorerKey = @cStorerKey
                              AND Facility = @cFacility
                              AND WO.[Type] IN('PACK', 'VAS')
                              AND WO.WorkOrderKey = WOD.WorkOrderKey
                              )
                  ORDER BY CASE WOD.ExternLineNo WHEN '0H' THEN 0 ELSE 1 END
                            , WOD.WorkOrderLineNumber     
   
   INSERT INTO @VASInfo ( cSKU
                        , cCode
                        , cDescr
                        , fPrice
                        , cType
                        , cPrintDocID
                        , bIsMandatory
                        , cStatus
                        , bShowFlag
                        , cExternLineNo
                        )
                  SELECT  COALESCE(NULLIF(WOD.Sku,''), @cSKU)
                        , WOD.[Type]
                        , CLK.[Description]
                        , WOD.Price
                        , 'print'
                        , CLK.UDF01
                        , @c_Option1
                        , WOD.[Status]
                        , 0
                        , ''
                  FROM WORKORDERDETAIL WOD (NOLOCK)
                  LEFT JOIN CODELKUP CLK (NOLOCK)
                  ON WOD.[Type] = CLK.Code
                  WHERE CLK.LISTNAME = 'WKOrdType'
                  AND CLK.UDF04 = 'PRICELB' -- Get the VAS info with Price for label printing, no matter it's mandatory or not, showflag is 0 as it won't display in VAS list but only used for label printing.
                  AND CLK.UDF01 <> '' -- Only get the VAS with print doc ID for label printing.
                  AND EXISTS (SELECT 1
                              FROM WORKORDER WO (NOLOCK)
                              WHERE EXISTS ( SELECT 1 
                                             FROM @OrderList t
                                             WHERE t.OrderKey = WO.ExternWorkOrderKey
                                             )
                              AND StorerKey = @cStorerKey
                              AND Facility = @cFacility
                              AND WO.[Type] IN('PACK', 'VAS')
                              AND WO.WorkOrderKey = WOD.WorkOrderKey
                              )

   IF @cSKU <> '' -- for SKU Level VAS Display
   BEGIN
      IF @bShowOrderHeaderVAS = 0
      BEGIN
         DELETE FROM @VASInfo
         WHERE cExternLineNo = '0H'
      END

      DELETE FROM @VASInfo
      WHERE cSKU <> @cSKU        

   END
   ELSE -- For Carton Level VAS display
   BEGIN
      DELETE t
      FROM @VASInfo t
      WHERE cSKU <> '' 
      AND NOT EXISTS (SELECT 1 
                        FROM PACKDETAIL PD (NOLOCK)
                        WHERE PD.PickSlipNo = @cPickSlipNo
                        AND PD.CartonNo = @nCartonNo
                        AND PD.SKU = t.cSKU
      )

      --Remains the 0H and remove other unwanted.
      DELETE t
      FROM @VASInfo t
      WHERE cSKU = ''
      AND cExternLineNo <> '0H'
   END

   DELETE FROM @VASInfo
   WHERE cType <> 'print'
   AND bShowFlag = 0

   ;WITH CTE AS
   (
      SELECT ROW_NUMBER() OVER(
                              PARTITION BY  cSKU
                                          , cCode
                                          , cDescr
                                          , cType
                                          , cPrintDocID 
                              ORDER BY nRowRef
                              ) AS rn
      FROM @VASInfo
      WHERE cType = 'print'
   )
   DELETE FROM CTE
   WHERE rn > 1

   SET @cResponseJson = ISNULL ((SELECT  nRowRef     
                                       , cSKU        
                                       , cCode       
                                       , cDescr      
                                       , fPrice      
                                       , cType       
                                       , cPrintDocID 
                                       , bIsMandatory
                                       , cStatus     
                                       , bShowFlag   
                                 FROM @VASInfo
                                 FOR JSON AUTO, ROOT('VASs')
                        ),'{"VASs":[]}')
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
