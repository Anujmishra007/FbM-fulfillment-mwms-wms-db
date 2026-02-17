SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PrintDocument_VAS_BySKU                            */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get Repoorts INFO by VAS Code when SKU Scan */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-24   1.0  YLI237     UWP-45422                                        */
/*********************************************************************************/


CREATE OR ALTER PROC [API].[isp_TPACK_PrintDocument_VAS_BySKU] (
    @cType        NVARCHAR(30)   = '',
    @cStorerKey   NVARCHAR(15)   = '',
    @cFacility    NVARCHAR(5)    = '',
    @cOrderKey    NVARCHAR(10)   = '',
    @cPickSlipNo  NVARCHAR(10)   = '',
    @nCartonNo    INT            = 0,
    @cSKU         NVARCHAR(50)   = '',
    @cLangCode    NVARCHAR(3)    = '',
    @isSKUScan    BIT            = 0,
    @bIsAutoPrint BIT            = 0,
    @bIsCartonLevel BIT          = 0,
    @oStatus      INT            = 0 OUTPUT,
    @oMessage     NVARCHAR(250)  = N'' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cModuleID         NVARCHAR(30)   = 'TPPACK'
          , @cTypeFromWOD      NVARCHAR(30)   = ''
          , @cUDF01_WK         NVARCHAR(MAX)  = ''
          , @cUDF04_WK         NVARCHAR(MAX)  = ''
          , @ShortPref         NVARCHAR(30)   = ''
          , @UDF01_Pref        NVARCHAR(MAX)  = ''
          , @UDF02_Pref        NVARCHAR(30)   = ''
          , @Code2_Pref        NVARCHAR(50)   = ''
          , @hasPref           INT            = 0
          , @ConsigneeKey      NVARCHAR(50)   = ''
          , @MarkForKey        NVARCHAR(50)   = ''
          , @BillToKey         NVARCHAR(50)   = ''
          , @FinalUDF01        NVARCHAR(MAX)  = ''
          , @ReportID          NVARCHAR(10)   = ''
          , @ReportLine        NVARCHAR(10)   = ''
          , @SKUGroup          NVARCHAR(50)   = ''
          , @Style             NVARCHAR(50)   = ''

    SELECT TOP 1 @cTypeFromWOD = Type
    FROM WorkOrderDetail (NOLOCK)
    WHERE ExternWorkOrderKey = @cOrderKey AND StorerKey = @cStorerKey AND SKU = @cSKU;

    SELECT
     @cUDF01_WK = UDF01
    ,@cUDF04_WK = UDF04
    FROM CodeLkup (NOLOCK)
    WHERE Listname = 'WKOrdType' AND Code = @cTypeFromWOD AND (StorerKey = '' OR StorerKey = @cStorerKey);

    IF ISNULL(@cUDF01_WK,'') = ''
    BEGIN
        SET @oStatus = 1001;
        SET @oMessage = N'WKOrdType UDF01 empty';
        RETURN;
    END

    IF @isSKUScan = 1 AND UPPER(ISNULL(@cUDF04_WK, '')) <> 'PRICELB'
    BEGIN
        SET @oStatus = 1006;
        SET @oMessage = N'Skipped non-PRICELB for SKU Scan';
        RETURN;
    END

    IF @bIsCartonLevel = 0 AND @bIsAutoPrint = 1 AND UPPER(@cUDF04_WK) = 'PRICELB'
    BEGIN
        SET @oStatus = 1002;
        SET @oMessage = N'Skipped PRICELB in PrintDoc';
        RETURN;
    END

    SELECT @ShortPref = Short, @UDF01_Pref = UDF01, @UDF02_Pref = UDF02, @Code2_Pref = Code2, @hasPref = 1
    FROM CodeLkup (NOLOCK)
    WHERE Listname = 'VASCustPre' AND Code = @cTypeFromWOD AND StorerKey = @cStorerKey;

    IF @hasPref = 1
    BEGIN
        IF ISNULL(@ShortPref,'') = 'Inactive' OR ISNULL(@ShortPref,'') = ''
        BEGIN
            SET @oStatus = 1003;
            SET @oMessage = N'VASCustPre inactive';
            RETURN;
        END
    END

    IF ISNULL(@Code2_Pref,'') <> ''
    BEGIN
        IF @UDF02_Pref = 'Consignee'
        BEGIN
            SELECT @ConsigneeKey = ConsigneeKey, @MarkForKey = MarkForKey, @BillToKey = BillToKey
            FROM Orders (NOLOCK)
            WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey;

            IF @Code2_Pref = @ConsigneeKey OR @Code2_Pref = @MarkForKey OR @Code2_Pref = @BillToKey
                SET @FinalUDF01 = @UDF01_Pref;
            ELSE
                SET @FinalUDF01 = @cUDF01_WK;
        END
        ELSE IF @UDF02_Pref = 'SKU'
        BEGIN
            SELECT @SKUGroup = SKUGroup, @Style = Style
            FROM SKU (NOLOCK)
            WHERE StorerKey = @cStorerKey AND SKU = @cSKU;

            IF @Code2_Pref = @SKUGroup OR @Code2_Pref = @Style
                SET @FinalUDF01 = @UDF01_Pref;
            ELSE
                SET @FinalUDF01 = @cUDF01_WK;
        END
        ELSE
            SET @FinalUDF01 = @cUDF01_WK;
    END
    ELSE
        SET @FinalUDF01 = @cUDF01_WK;

    IF CHARINDEX('_', @FinalUDF01) > 0
    BEGIN
        SET @ReportID = LEFT(@FinalUDF01, CHARINDEX('_', @FinalUDF01) - 1);
        SET @ReportLine = SUBSTRING(@FinalUDF01, CHARINDEX('_', @FinalUDF01) + 1, LEN(@FinalUDF01));
    END
    -- ELSE IF CHARINDEX('/', @FinalUDF01) > 0
    -- BEGIN
    --     SET @ReportID = LEFT(@FinalUDF01, CHARINDEX('/', @FinalUDF01) - 1);
    --     SET @ReportLine = SUBSTRING(@FinalUDF01, CHARINDEX('/', @FinalUDF01) + 1, LEN(@FinalUDF01));
    -- END

    IF @ReportID = '' OR @ReportLine = ''
    BEGIN
        SET @oStatus = 1004;
        SET @oMessage = N'Invalid UDF01 format';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM WMReportDetail WMRD (NOLOCK)
        JOIN WMReport WMR (NOLOCK) ON WMR.ReportID = WMRD.ReportID AND WMR.ModuleID = @cModuleID
        WHERE WMRD.ReportID = @ReportID
          AND WMRD.ReportLineNo = @ReportLine
          AND WMRD.StorerKey = @cStorerKey
          AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)
    )
    BEGIN
        SET @oStatus = 1005;
        SET @oMessage = N'Report detail not found';
        RETURN;
    END

    SELECT WMR.ReportID,
           WMRD.ReportLineNo,
           IIF(WMRD.PrintType = 'LOGIREPORT', 'JReport', 'WMReport') AS PrintSource,
           ISNULL(WMRD.DefaultPrinterID, '') AS DefaultPrinterID,
           WMRD.IsPaperPrinter,
           ISNULL(WMR.KeyFieldName1, '') AS KeyFieldName1,
           ISNULL(WMR.KeyFieldName2, '') AS KeyFieldName2,
           ISNULL(WMR.KeyFieldName3, '') AS KeyFieldName3,
           ISNULL(WMR.KeyFieldName4, '') AS KeyFieldName4
    FROM WMReportDetail WMRD (NOLOCK)
    JOIN WMReport WMR (NOLOCK) ON WMR.ReportID = WMRD.ReportID AND WMR.ModuleID = @cModuleID
    WHERE WMRD.ReportID = @ReportID
      AND WMRD.ReportLineNo = @ReportLine
      AND WMRD.StorerKey = @cStorerKey
      AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)
      AND ReportType='TPVAS'
END
GO
