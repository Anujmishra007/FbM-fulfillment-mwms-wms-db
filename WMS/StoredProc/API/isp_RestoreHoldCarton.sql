SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_RestoreHoldCarton                                     */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author      Purposes                                     */
/* 2025-06-20   1.0  GhChan      Created                                      */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_RestoreHoldCarton] (
   @Workstation NVARCHAR(30),  --Selected Workstation
   @InputJson1 NVARCHAR(MAX),  --CheckCartonDetailRequestPayload
   @InputJson2 NVARCHAR(MAX),  --CheckCartonDetailResponseResult
   @jResult    NVARCHAR( MAX) = '' OUTPUT,
   @b_Success  INT = 1  OUTPUT,
   @n_Err      INT = 0  OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @barcodeObjJson NVARCHAR(MAX)
DECLARE @OutputJson NVARCHAR(MAX)

SET @b_Success = 1
SET @n_Err = 0
SET @c_ErrMsg = ''
--SET @Workstation = 'TW99'
--SET @InputJson1 ='{"StorerKey":"SEPHIL","Facility":"OPDC","Func":"838","ScanNo":"P009252815","cType":"pickslip","UserName":"GCH225","LangCode":"ENG","CartonNo":1,"OrderKey":" "}'
--SET @InputJson2 = '[{"SKU":"EVH4S07N2","Descr":"AC easy home charger 7,4 kW - T2","RetailSKU":"","ManufacturerSKU":"","AltSKU":"3606482107311","QtyToPack":0,"PackedQty":15,"Img":"https://stage-utlweb.ocf.fulfillment.maersk.com/GenericAPI/GetFile?src=unknown","Ecom_CartonType":"","InputWeight":"0.0000","InputCube":"5597.0000","WEIGHT":0.0,"CUBE":0.04490244,"Ecom_Weight":0.0,"Ecom_Cube":0.0,"DynamicColName1":"","DynamicColName2":"","DynamicColValue1":"","DynamicColValue2":"","UCC":"","Lottable":[],"UPC":[],"barcodeObj":[{"barcodeVal":"","AntiDiversionCode":"10234567"},{"barcodeVal":"","AntiDiversionCode":"11234567"},{"barcodeVal":"","AntiDiversionCode":"12234567"},{"barcodeVal":"","AntiDiversionCode":"1234567"},{"barcodeVal":"","AntiDiversionCode":"13234567"},{"barcodeVal":"","AntiDiversionCode":"14234567"},{"barcodeVal":"","AntiDiversionCode":"15234567"},{"barcodeVal":"","AntiDiversionCode":"2234567"},{"barcodeVal":"","AntiDiversionCode":"3234567"},{"barcodeVal":"","AntiDiversionCode":"4234567"},{"barcodeVal":"","AntiDiversionCode":"5234567"},{"barcodeVal":"","AntiDiversionCode":"6234567"},{"barcodeVal":"","AntiDiversionCode":"7234567"},{"barcodeVal":"","AntiDiversionCode":"8234567"},{"barcodeVal":"","AntiDiversionCode":"9234567"}]},{"SKU":"QOB3805288","Descr":"MINIATURE CIRCUIT BREAKER 240V 80A","RetailSKU":"","ManufacturerSKU":"","AltSKU":"3606486145968","QtyToPack":0,"PackedQty":10,"Img":"https://stage-utlweb.ocf.fulfillment.maersk.com/GenericAPI/GetFile?src=unknown","Ecom_CartonType":"","InputWeight":"0.0000","InputCube":"5597.0000","WEIGHT":0.512559,"CUBE":0.000375402,"Ecom_Weight":0.5125589966773987,"Ecom_Cube":0.0,"DynamicColName1":"","DynamicColName2":"","DynamicColValue1":"","DynamicColValue2":"","UCC":"","Lottable":[],"UPC":[],"barcodeObj":[{"barcodeVal":"","AntiDiversionCode":"202506201056"},{"barcodeVal":"","AntiDiversionCode":"202506201057"},{"barcodeVal":"","AntiDiversionCode":"202506201058"},{"barcodeVal":"","AntiDiversionCode":"202506201059"},{"barcodeVal":"","AntiDiversionCode":"202506201060"},{"barcodeVal":"","AntiDiversionCode":"202506201061"},{"barcodeVal":"","AntiDiversionCode":"202506201062"},{"barcodeVal":"","AntiDiversionCode":"202506201063"},{"barcodeVal":"","AntiDiversionCode":"202506201064"},{"barcodeVal":"","AntiDiversionCode":"202506201065"}]}]'

-- Temporary table to store transformed results
    DECLARE @Temp TABLE (
      SKU         NVARCHAR( 20),
      PackedQty   INT,
      [WEIGHT]    FLOAT,
      [CUBE]      FLOAT,
      Lottable    NVARCHAR(MAX), 
      barcodeObj  NVARCHAR(MAX),
      UPC         NVARCHAR(MAX)
    )

    IF ISNULL(@InputJson1,'') = '' OR ISNULL(@InputJson2, '') = '' OR ISNULL(@Workstation,'') = ''
    BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
      SET @c_ErrMsg = 'All the following variables cannot be null or empty. (Workstation, InputJson1 and InputJson2)'
      GOTO QUIT
    END
    -- Parse each item in the input JSON
    INSERT INTO @Temp (SKU, PackedQty, [WEIGHT], [CUBE], Lottable, barcodeObj, UPC)
    SELECT SKU  
         , PackedQty  
         , [WEIGHT]  
         , [CUBE]  
         , Lottable  
         , barcodeObj
         , UPC 
    FROM OPENJSON(@InputJson2)
    WITH (
      SKU         NVARCHAR( 20)  
     ,PackedQty   INT          
     ,[WEIGHT]    FLOAT         
     ,[CUBE]      FLOAT         
     ,Lottable    NVARCHAR(MAX) AS JSON 
     ,barcodeObj  NVARCHAR(MAX) AS JSON 
     ,UPC         NVARCHAR(MAX) AS JSON 
    )

    IF @@ROWCOUNT = 0
    BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
      SET @c_ErrMsg = 'Invalid InputJson2, no record been insert successful to temp table.'
      GOTO QUIT
    END

    SELECT @barcodeObjJson = 
    (
        SELECT 
            SKU,
            PackedQty,
            [Weight],
            [Cube],
            CASE WHEN Lottable <> '[]' THEN JSON_QUERY(Lottable) END AS Lottable,
            CASE WHEN UPC <> '[]' THEN JSON_QUERY(UPC) END AS UPC,
            JSON_QUERY(barcodeObj) AS barcodeObj
        FROM @Temp
        FOR JSON PATH
    )

    SELECT @OutputJson = 
    (
       SELECT *,
       JSON_QUERY(@barcodeObjJson) AS HoldCarton,
       @Workstation AS Workstation
       FROM OPENJSON(@InputJson1)
       WITH (
         StorerKey   NVARCHAR(30),
         Facility    NVARCHAR(30),
         Func        NVARCHAR(5),
         UserName    NVARCHAR(128),
         LangCode    NVARCHAR(3),
         ScanNo      NVARCHAR(30),
         CartonNo    INT,
         cType       NVARCHAR(30)
       )
       FOR JSON PATH
    )

    IF @@ROWCOUNT = 0
    BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
      SET @c_ErrMsg = 'Invalid InputJson1, no OutputJson found.'
      GOTO QUIT
    END

    --SELECT @OutputJson
    EXEC Api.isp_HoldCarton @OutputJson,@jResult OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_Errmsg OUTPUT
QUIT:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_RestoreHoldCarton TO NSQL
GO


