
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_rePrint                                               */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2020-04-14   1.0  Chermaine  Created                                       */
/* 2021-08-17   1.1  Chermaine  TPS-623 use pass in b2b pickslipNo (cc01)     */
/* 2021-09-05   1.2  Chermaine  TPS-11 ErrMsg add to rdtmsg (cc02)            */
/* 2021-12-08   1.3  Chermaine  TPS-600 Split Print button (cc03)             */
/* 2023-05-30   1.4  yeekung    TPS-708 All print all config                  */
/* 2023-06-23   1.5  yeekung    TPS-690 Add Reprint SP (yeekung02)            */
/* 2023-09-12   1.6  YeeKung    TPS-773/TPS-740 New print (yeekung3)          */
/* 2023-12-11   1.7  YeeKung    TPS-826 Add params for paper (yeekung12)      */
/* 2024-01-18   1.8  YeeKung    Add group by labelno (yeekung4)               */
/* 2024-02-09   1.9  YeeKung    TPS-821 Add reporttpe (yeekung05)             */  
/* 2025-02-14   2.0  yeekung    TPS-995 Change Error Message (yeekung06)      */
/* 2025-02-25   2.1  YeeKung    TPS-970 Fix Orderkey reprint (yeekung07)      */
/* 2025-04-22   2.2  GCH225     UWP-33066 FCR-4039 Fix Group By (Gh01)        */
/* 2025-04-23   2.3  GCH225     FCR-4207 Fix DynamicPrinter (Gh02)            */
/* 2025-07-22   2.4  GCH225     UWP-38184 Enhanced the lsp_SetUser logic      */ 
/* 2025-09-18   2.5  GCH225     FCR-7558 Support for ToteID Print             */ 
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_rePrint] (
   @json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) ='' OUTPUT,
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

   DECLARE
      @nMobile          INT,
      @nStep            INT,
      @cLangCode        NVARCHAR( 3),
      @nInputKey        INT,
      @cScanNoType      NVARCHAR( 30),
      @cLot             NVARCHAR( 30),
      @CalOrderSKU      NVARCHAR( 1),
      @cDynamicRightName1  NVARCHAR( 30),
      @cDynamicRightValue1 NVARCHAR( 30),
      @cReporttype      NVARCHAR(20),

      @cStorerKey       NVARCHAR( 15),
	   @cFacility        NVARCHAR( 5),
	   @nFunc            NVARCHAR( 5),
	   @cUserName        NVARCHAR( 128),
	   @c_UserName       NVARCHAR( 128),
      @cScanNo          NVARCHAR( 50),
      @cDropID          NVARCHAR( 50),
      @cPickSlipNo      NVARCHAR( 30),
      @nCartonNo        INT,
      @cCartonID        NVARCHAR( 20),
      @cType            NVARCHAR( 30),
      @nQTY             INT,
      @cSKU             NVARCHAR( 20),
      @cCube            FLOAT,
      @cWeight          FLOAT,
      @cCartonWeight    FLOAT,
      @cCartonCube      FLOAT,
      @cOrderKey        NVARCHAR( 10),
      @cOrderKeyPrint   NVARCHAR( 10),
      @nPickQty         INT,
      @nPackQty         INT,

      @cUPC             NVARCHAR( 30),
      @cLabelLine       NVARCHAR(5),
      @PrinterType      NVARCHAR(10), --(cc03)

      @bSuccess         INT,
      @nErrNo           INT,
      @cErrMsg          NVARCHAR(250),
      @nTranCount       INT,
      @curPD            CURSOR,
      @GetCartonID      NVARCHAR( MAX),
      @cShipLabel       NVARCHAR( 10),
      @cWorkstation     NVARCHAR( 30),
      @pickSkuDetailJson   NVARCHAR( MAX),
      @nPrintPackList      NVARCHAR( 1),
      @cSQL                NVARCHAR( MAX),
      @cSQLParam        NVARCHAR(MAX)

   DECLARE @nOutputCount INT
   DECLARE @b_ExecuteAs BIT
   
   SET @nPrintPackList = 'N'
   SET @b_ExecuteAs = 0

   --decode json
   select @cStorerKey = StorerKey, @cFacility = Facility,@nFunc = Func,@cUserName = UserName,@cLangCode = LangCode
   ,@cScanNo = ScanNo,@nCartonNo = CartonNo, @cType = ctype,  @cWorkstation = Workstation, @cOrderKeyPrint = OrderKey
   ,@PrinterType = PrinterType,@cReporttype = ReportType  --(cc03)
      FROM OPENJSON(@json)
      WITH (
	      StorerKey      NVARCHAR( 30),
	      Facility       NVARCHAR( 30),
         Func           NVARCHAR( 5),
         UserName       NVARCHAR( 128),
         LangCode       NVARCHAR( 3),
         ScanNo         NVARCHAR( 30),
         CartonNo       INT,
         cType          NVARCHAR( 30),
         Workstation    NVARCHAR( 30),
         OrderKey       NVARCHAR( 10),
         PrinterType    NVARCHAR( 10),
         ReportType     NVARCHAR( 20)
      )

      --SELECT @cUserName AS cUserNameb4
   --SELECT @cStorerKey AS StorerKey, @cFacility AS Facility,@nFunc AS Func,@cUserName AS UserName,@cScanNo AS ScanNo,@nCartonNo AS CartonNo,@ctype AS ctype,@cWeight AS cWeight, @cCube AS cCube
   SET @c_UserName = @cUserName

   SET @n_Err = 0

   SET @cSQL = 'EXEC WM.lsp_SetUser @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT';

   SET @cSQLParam =  N'@c_UserName NVARCHAR(128) OUTPUT,' +
				    N'@n_Err INT OUTPUT, ' + 
				    N'@c_ErrMsg NVARCHAR(125) OUTPUT'
   --convert login
   SELECT @nOutputCount=COUNT(1) FROM sys.parameters p (NOLOCK)
		   JOIN sys.objects o (NOLOCK) 
		      ON p.object_id = o.object_id
		   WHERE o.name = 'lsp_SetUser'
		   AND p.is_output = 1
   IF @nOutputCount = 4 
   BEGIN
     SET @cSQL = @cSQL + ', @b_ExecuteAs OUTPUT '
     SET @cSQLParam = @cSQLParam + ', @b_ExecuteAs BIT OUTPUT'

     EXEC sp_executesql @cSQL, @cSQLParam, @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT, @b_ExecuteAs OUTPUT;
   END
   ELSE
   BEGIN
     EXEC sp_executesql @cSQL, @cSQLParam, @c_UserName OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
   END

      IF @n_Err <> 0
      BEGIN
         --INSERT INTO @errMsg(nErrNo,cErrMsg)
         SET @b_Success = 0
         SET @n_Err = @n_Err
      --   SET @c_ErrMsg = @c_ErrMsg
         GOTO EXIT_SP
      END

   IF @nOutputCount = 4
   BEGIN
     IF @b_ExecuteAs = 1
	    GOTO ExecuteAs
     ELSE
     BEGIN
	    IF SESSION_CONTEXT(N'mwms_user_name') IS NULL
	    BEGIN
		   SET @b_Success = 0
		   SET @n_Err = 1001463
		   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No Session context found. Function : isp_rePrint'
		   GOTO EXIT_SP
	    END            
     END
   END
   ELSE
   BEGIN
     IF @c_UserName LIKE '%' + @cUserName + '%'
     BEGIN
   ExecuteAs:
	    EXECUTE AS LOGIN = @c_UserName
	    SET @cUserName = @c_UserName
     END
   END


   --SELECT @cUserName AS cUserName
   --SELECT SUSER_NAME() AS sname

   --SELECT @cUserName AS cUserName, @cScanNo AS cScanNo, @c_OriUserName AS c_UserName
   --search pickslipNo
   IF ISNULL(@cOrderKeyPrint,'') = ''
   BEGIN

	   --b2b
      IF @cType <> 'pickslip' --(cc01)
      BEGIN
         SELECT @cPickSlipNo = ISNULL(PickSlipNo,'') FROM api.appSection WITH (NOLOCK) WHERE userID = @cUserName AND scanNo = @cScanNo

         IF @cPickSlipNo = '' OR @@ROWCOUNT = 0
         BEGIN
            SELECT TOP 1 @cPickSlipNo = PickSlipNo 
            FROM PACKDETAIL (NOLOCK) 
            WHERE StorerKey = @cStorerKey
            AND DropID = @cScanNo
         END
      END
      ELSE IF LEFT (@cScanNo,1) <>'P'
      BEGIN
         SELECT @cPickSlipNo = PickSlipNo FROM packHeader WITH (NOLOCK) WHERE orderkey = @cScanNo AND storerKey = @cStorerKey
         SET @cScanNo = @cPickSlipNo
      END
      ELSE
      BEGIN
         SET @cPickSlipNo = @cScanNo
      END

	   IF EXISTS (SELECT TOP 1 1 FROM packHeader WHERE pickslipNo = @cPickSlipNo AND STATUS = 9)
	   BEGIN
		   SET @nPrintPackList = 'Y'
	   END
   END
   ELSE
   BEGIN
	   --b2c
	   SELECT @cPickSlipNo = PickSlipNo FROM packHeader WITH (NOLOCK) WHERE orderkey = @cOrderKeyPrint AND storerKey = @cStorerKey
	   IF EXISTS (SELECT TOP 1 1 FROM packHeader WHERE pickslipNo = @cPickSlipNo AND orderKey = @cOrderKeyPrint AND STATUS = 9)
	   BEGIN
		   SET @nPrintPackList = 'Y'
	   END
   END

   SELECT @cPickSlipNo AS picksliNo, @nPrintPackList '@nPrintPackList'


   --lookup printer
   DECLARE @cLabelPrinter NVARCHAR ( 30)
   DECLARE @cPaperPrinter NVARCHAR ( 30)
   DECLARE @cLabelJobID   NVARCHAR ( 30)
   DECLARE @cPackingJobID NVARCHAR ( 30)
   DECLARE @cExtendedRePrintSP NVARCHAR ( 30)
   DECLARE @curPrint      CURSOR
   DECLARE @cPrintAllLbl  NVARCHAR( 30)
   DECLARE @cPrinterInGroup NVARCHAR(10) 
   DECLARE @groupByFields NVARCHAR(MAX) = ''

   -- Common params ofr printing
   --DECLARE @tShipLabel AS VariableTable

   DECLARE   @c_ModuleID           NVARCHAR(30) ='TPPack'
            , @c_ReportID           NVARCHAR(10) 
            , @c_PrinterID          NVARCHAR(30)  
            , @c_JobIDs             NVARCHAR(50)   = ''         --(Wan03) -- May return multiple jobs ID.JobID seperate by '|'
            , @c_PrintSource        NVARCHAR(20)
            , @c_AutoPrint          NVARCHAR(1)    = 'N'        --(Wan07)

   DECLARE @cFieldName1 NVARCHAR(max),
           @cFieldName2 NVARCHAR(max),
           @cFieldName3 NVARCHAR(max),
           @cFieldName4 NVARCHAR(max),
           @cParams1    NVARCHAR(max),
           @cParams2    NVARCHAR(max),
           @cParams3    NVARCHAR(max),
           @cParams4    NVARCHAR(max),
           @IsAggregate1 BIT = 0,
           @IsAggregate2 BIT = 0,
           @IsAggregate3 BIT = 0,
           @IsAggregate4 BIT = 0

   DECLARE @cNewPaperPrinter NVARCHAR(20)
   DECLARE @cNewLabelPrinter NVARCHAR(20)

   set @cLabelJobID = ''
   set @cPackingJobID = ''
   SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
   SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'

   SELECT @cPrintAllLbl = 1 FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPS-PrintAllLbl' AND sValue = '1'

   -- Extended Print  --(cc10)  
   SELECT @cExtendedRePrintSP = svalue FROM storerConfig WITH (NOLOCK) WHERE storerKey = @cStorerKey AND configKey = 'TPSExtRePrintSP'  
   IF ISNULL(@cExtendedRePrintSP,'') <> ''
   BEGIN    
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedRePrintSP AND type = 'P')    
      BEGIN    
         SET @cSQL = 'EXEC API.' + RTRIM( @cExtendedRePrintSP) +  
            ' @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo, ' +   
            ' @cpickslipNo, @cDropID, @cOrderKey,  ' +  
            ' @nCartonNO, @cType, @cWorkstation, @PrinterType,@cPrintAllLbl,@nPrintPackList,@cReporttype,'+
            ' @cLabelJobID OUTPUT, @cPackingJobID OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT ' 
         SET @cSQLParam =     
            '@cStorerKey      NVARCHAR( 15), ' +  
            '@cFacility       NVARCHAR( 5),  ' +   
            '@nFunc           INT,           ' +  
            '@cUserName       NVARCHAR( 128),' +  
            '@cLangCode       NVARCHAR( 3),  ' +  
            '@cScanNo         NVARCHAR( 50), ' +  
            '@cpickslipNo     NVARCHAR( 30), ' +  
            '@cDropID         NVARCHAR( 50), ' +  
            '@cOrderKey       NVARCHAR( 10), ' +  
            '@nCartonNo       INT,    ' +  
            '@cType           NVARCHAR( 30), ' +   
            '@cWorkstation    NVARCHAR( 30), ' +    
            '@PrinterType     NVARCHAR( 20),  ' +  
            '@cPrintAllLbl   NVARCHAR (20),   ' +
            '@nPrintPackList  NVARCHAR (1),  ' +
            '@cReporttype     NVARCHAR (20),  ' +
            '@cLabelJobID     NVARCHAR ( 30) OUTPUT,  ' +
            '@cPackingJobID   NVARCHAR ( 30) OUTPUT,  ' +
            '@b_Success       INT            OUTPUT, ' +
            '@n_Err           INT            OUTPUT, ' +
            '@c_ErrMsg        NVARCHAR(255)  OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @cStorerKey, @cFacility, @nFunc, @cUserName, @cLangCode, @cScanNo,
            @cpickslipNo, @cDropID, @cOrderKeyPrint, 
            @nCartonNo, @cType, @cWorkstation, @PrinterType,@cPrintAllLbl,@nPrintPackList,@cReporttype, 
            @cLabelJobID OUTPUT,@cPackingJobID OUTPUT, @b_Success OUTPUT, @n_Err OUTPUT, @c_ErrMsg OUTPUT
    
         IF @b_Success <> 1  
         BEGIN  
            SET @b_Success = 0   
            SET @n_Err = @n_Err  
            SET @c_ErrMsg = @c_ErrMsg  
            GOTO EXIT_SP  
         END             
      END    
   END   
   ELSE
   BEGIN

      IF ISNULL(@cPrintAllLbl,'') <> ''
      BEGIN
         --Close: packDetail  
         SET @curPrint = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT  cartonno 
         FROM packdetail WITH (NOLOCK) 
         WHERE pickslipno = @cPickSlipNo
            AND storerKey = @cStorerKey
         group by cartonno
         order by CAST(cartonno AS  INT)
         OPEN @curPrint  
         FETCH NEXT FROM @curPrint INTO @nCartonNo  
         WHILE @@FETCH_STATUS <> -1  
         BEGIN  

            --select @cStorerKey,@cPickSlipNo,@nCartonNo

            --INSERT INTO @tShipLabel (Variable, Value) VALUES
            --   ( '@c_StorerKey',     @cStorerKey),
            --   ( '@c_PickSlipNo',    @cPickSlipNo),
            --   ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
            --   ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))


            IF @PrinterType = 'Label' --(cc03)
            BEGIN
               -- Print label
               IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                           JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
                           WHERE Storerkey = @cStorerKey 
                              AND (reporttype = @cReporttype OR reporttype ='TPSHIPPLBL'))  
               BEGIN
	               IF ISNULL(@cLabelPrinter,'') = ''
	               BEGIN
		               SET @b_Success = 0
                     SET @n_Err = 1001451
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_rePrint'
                     GOTO EXIT_SP
	               END
	               ELSE
	               BEGIN
		               --EXEC API.isp_Print @cLangCode, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                 --    'TPSHIPPLBL', -- Report type
                 --    @tShipLabel, -- Report params
                 --    'API.isp_RePrint', --source Type
                 --    @n_Err  OUTPUT,
                 --    @c_ErrMsg OUTPUT,
                 --    '1', --noOfCopy
                 --    '', --@cPrintCommand
                 --    @nJobID OUTPUT,
                    --    @cUsername
                     SELECT   @c_ReportID = WMR.reportid,
                        @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
                        @cNewLabelPrinter = Defaultprinterid,
                        @cFieldName1  = keyFieldname1,
                        @cFieldName2  = keyFieldname2,
                        @cFieldName3  = keyFieldname3,
                        @cFieldName4  = keyFieldname4
                     FROM WMReport WMR (NOLOCK)
                     JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
                     WHERE Storerkey = @cStorerkey
                        AND Reporttype =  CASE WHEN ISNULL(@cReporttype,'') <> '' THEN  @cReporttype ELSE   'TPSHIPPLBL' END
                        AND ModuleID ='TPPack'
                        AND ispaperprinter <> 'Y'
                        and (WMRD.username = '' OR WMRD.username = @cUsername)
                        AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = 1001452
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_rePrint'
                     GOTO EXIT_SP
                  END

                  IF ISNULL(@cFieldName1,'') = ''
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = 1001453
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_rePrint'
                     GOTO EXIT_SP
                  END

                     --Start Gh01
                  SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
                                      UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName1) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName1) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
                                      UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName2) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName2) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
                                      UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName3) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName3) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
                                      UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName4) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName4) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

 
                     SET  @cSQL =
                     'SELECT  @cParams1='+ @cFieldName1  
                              SELECT @cSQL= CASE WHEN ISNULL(@cFieldName2,'') <> '' THEN @cSQL +',@cParams2='  + @cFieldName2  ELSE  @cSQL END 
                              SELECT @cSQL= CASE WHEN ISNULL(@cFieldName3,'') <> '' THEN @cSQL +',@cParams3='  + @cFieldName3  ELSE  @cSQL END
                              SELECT @cSQL= CASE WHEN ISNULL(@cFieldName4,'') <> '' THEN @cSQL +',@cParams4='  + @cFieldName4  ELSE  @cSQL END
                     SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
                        WHERE Storerkey = @cstorerkey
                           AND Pickslipno = @cPickslipno
                           AND CartonNo = @nCartonno '

                     SET @groupByFields = ''

                     IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
                        SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

                     IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
                        SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

                     IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
                         SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

                     IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
                         SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

                     -- If any valid fields found, append GROUP BY
                     IF LEN(@groupByFields) > 0
                         SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields
                     --End Gh01

                     SET @cSQLParam = 
                     ' @cFieldName1 NVARCHAR(max),
                        @cFieldName2 NVARCHAR(max),
                        @cFieldName3 NVARCHAR(max),
                        @cFieldName4 NVARCHAR(max),
                        @cParams1    NVARCHAR(max) OUTPUT,
                        @cParams2    NVARCHAR(max) OUTPUT,
                        @cParams3    NVARCHAR(max) OUTPUT,
                        @cParams4    NVARCHAR(max) OUTPUT,
                        @cstorerkey  NVARCHAR(20),
                        @cPickslipno NVARCHAR(20),
                        @nCartonno   INT'

                     EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
                        @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 

                     IF ISNULL(@cNewLabelPrinter,'')= ''
                     BEGIN
                         SET @cNewLabelPrinter = @cLabelPrinter
                        -- Check if printer is a group  
                        IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cLabelPrinter)  
                        BEGIN  
                           SET @cPrinterInGroup = ''  
  
                           -- Check if report print to a specific printer in group  
                           SELECT @cPrinterInGroup = PrinterID  
                           FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
                           WHERE Function_ID = @nFunc  
                              AND StorerKey = @cStorerKey  
                              AND ReportType = @cReportType  
                              AND PrinterGroup = @cLabelPrinter  
  
                           IF @cPrinterInGroup = ''  
                           BEGIN  
                              -- Get default printer in the group  
                              SELECT @cPrinterInGroup = PrinterID  
                              FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
                              WHERE PrinterGroup = @cLabelPrinter  
                                 AND DefaultPrinter = 1  
  
                              -- Check no default printer  
                              IF @cPrinterInGroup = ''  
                              BEGIN  
                                 SET @n_Err = 1001454  
                                 SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Label Printer setup not done. Please setup the Label Printer. Function : isp_rePrint
                                 GOTO EXIT_SP  
                              END  
                           END  
                           SET @cNewLabelPrinter = @cPrinterInGroup
                        END 
                     END

                    EXEC  [WM].[lsp_WM_Print_Report]
                       @c_ModuleID = @c_ModuleID           
                     , @c_ReportID = @c_ReportID         
                     , @c_Storerkey = @cStorerkey         
                     , @c_Facility  = @cFacility        
                     , @c_UserName  = @cUsername   
                     , @c_ComputerName = ''
                     , @c_PrinterID = @cNewLabelPrinter         
                     , @n_NoOfCopy  = '1'     
                     , @c_KeyValue1 = @cParams1        
                     , @c_KeyValue2 = @cParams2        
                     , @c_KeyValue3 = @cParams3     
                     , @c_KeyValue4 = @cParams4    
                     , @b_Success   = @b_Success         OUTPUT      
                     , @n_Err       = @n_Err             OUTPUT
                     , @c_ErrMsg    = @c_ErrMsg          OUTPUT
                     , @c_PrintSource  = @c_PrintSource        
                     , @b_SCEPreView   = 0         
                     , @c_JobIDs      = @cLabelJobID         OUTPUT    
                     , @c_AutoPrint  = 'N'     

                     IF @n_Err <> 0
                     BEGIN
                        SET @b_Success = 0
                        SET @n_Err = @n_Err
                        SET @c_ErrMsg = @c_ErrMsg
                        GOTO EXIT_SP
                     END
	               END
               END
            END

            --delete @tShipLabel

            FETCH NEXT FROM @curPrint INTO @nCartonNo  
         END
         CLOSE @curPrint
         DEALLOCATE  @curPrint
      END
      ELSE
      BEGIN
         IF ISNULL(@cOrderKeyPrint,'') = ''
         BEGIN
	         --b2b
	         IF @cType <> 'pickslip' --(cc01)
	         BEGIN
		         SELECT @cPickSlipNo = PickSlipNo FROM api.appSection WITH (NOLOCK) WHERE userID = @cUserName AND scanNo = @cScanNo
	         END
	         ELSE
	         BEGIN
		         SET @cPickSlipNo = @cScanNo
	         END

	         IF EXISTS (SELECT TOP 1 1 FROM packHeader WHERE pickslipNo = @cPickSlipNo AND STATUS = 9)
	         BEGIN
		         SET @nPrintPackList = 'Y'
	         END
         END
         ELSE
         BEGIN
	         --b2c
	         SELECT @cPickSlipNo = PickSlipNo FROM packHeader WITH (NOLOCK) WHERE orderkey = @cOrderKeyPrint AND StorerKey = @cStorerKey
	         IF EXISTS (SELECT TOP 1 1 FROM packHeader WHERE pickslipNo = @cPickSlipNo AND OrderKey = @cOrderKeyPrint AND STATUS = 9)
	         BEGIN
		         SET @nPrintPackList = 'Y'
	         END
         END

         SELECT @cPickSlipNo AS picksliNo, @nPrintPackList '@nPrintPackList'


         --INSERT INTO @tShipLabel (Variable, Value) VALUES
         --   ( '@c_StorerKey',     @cStorerKey),
         --   ( '@c_PickSlipNo',    @cPickSlipNo),
         --   ( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
         --   ( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))

         set @cLabelJobID = ''
         set @cPackingJobID = ''
         SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
         SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'

         IF @PrinterType = 'Label' --(cc03)
         BEGIN
            -- Print label
               -- Print label
            IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                        JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
                        WHERE Storerkey = @cStorerKey 
                           AND (reporttype = @cReporttype OR reporttype ='TPSHIPPLBL'))  
            BEGIN
	            IF ISNULL(@cLabelPrinter,'') = ''
	            BEGIN
                  SET @b_Success = 0
                  SET @n_Err = 1001455
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Label Printer setup not done. Please setup the Label Printer. Function : isp_rePrint'

                  GOTO EXIT_SP
	            END
	            ELSE
	            BEGIN
                  SELECT   @c_ReportID = WMR.reportid,
                        @c_PrintSource = CASE WHEN printtype = 'LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
                        @cNewLabelPrinter = Defaultprinterid,
                        @cFieldName1  = keyFieldname1,
                        @cFieldName2  = keyFieldname2,
                        @cFieldName3  = keyFieldname3,
                        @cFieldName4  = keyFieldname4
                     FROM WMReport WMR (NOLOCK)
                     JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
                     WHERE Storerkey = @cStorerkey
                        AND Reporttype =  CASE WHEN ISNULL(@cReporttype,'') <> '' THEN  @cReporttype ELSE   'TPSHIPPLBL' END
                        AND ModuleID ='TPPack'
                        AND ispaperprinter <> 'Y'
                        and (WMRD.username = '' OR WMRD.username = @cUsername)
                        AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = 1001456
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_rePrint'
                     GOTO EXIT_SP
                  END

                  IF ISNULL(@cFieldName1,'') = ''
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = 1001457
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_rePrint'
                     GOTO EXIT_SP
                  END
                  
                  SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
                                      UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName1) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName1) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
                                      UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName2) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName2) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
                                      UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName3) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName3) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
                                      UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName4) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName4) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET  @cSQL =
                  'SELECT  @cParams1='+ @cFieldName1  
                           SELECT @cSQL= CASE WHEN ISNULL(@cFieldName2,'') <> ''THEN @cSQL +',@cParams2='  + @cFieldName2  ELSE  @cSQL END 
                           SELECT @cSQL= CASE WHEN ISNULL(@cFieldName3,'') <> ''THEN @cSQL +',@cParams3='  + @cFieldName3  ELSE  @cSQL END
                           SELECT @cSQL= CASE WHEN ISNULL(@cFieldName4,'') <> ''THEN @cSQL +',@cParams4='  + @cFieldName4  ELSE  @cSQL END
                  SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
                     WHERE Storerkey = @cstorerkey
                        AND Pickslipno = @cPickslipno
                        AND CartonNo = @nCartonno '

                  SET @groupByFields = ''

                  IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
                     SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

                  IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
                     SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

                  IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
                        SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

                  IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
                        SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

                  -- If any valid fields found, append GROUP BY
                  IF LEN(@groupByFields) > 0
                        SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

                     SET @cSQLParam = 
                     '  @cFieldName1 NVARCHAR(max),
                        @cFieldName2 NVARCHAR(max),
                        @cFieldName3 NVARCHAR(max),
                        @cFieldName4 NVARCHAR(max),
                        @cParams1    NVARCHAR(max) OUTPUT,
                        @cParams2    NVARCHAR(max) OUTPUT,
                        @cParams3    NVARCHAR(max) OUTPUT,
                        @cParams4    NVARCHAR(max) OUTPUT,
                        @cstorerkey  NVARCHAR(20),
                        @cPickslipno NVARCHAR(20),
                        @nCartonno   INT'

                     EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
                        @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 

                     IF ISNULL(@cNewLabelPrinter,'')= ''
                     BEGIN
                         SET @cNewLabelPrinter = @cLabelPrinter
                        -- Check if printer is a group  
                        IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cLabelPrinter)  
                        BEGIN  
                           SET @cPrinterInGroup = ''  
  
                           -- Check if report print to a specific printer in group  
                           SELECT @cPrinterInGroup = PrinterID  
                           FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
                           WHERE Function_ID = @nFunc  
                              AND StorerKey = @cStorerKey  
                              AND ReportType = @cReportType  
                              AND PrinterGroup = @cLabelPrinter  
  
                           IF @cPrinterInGroup = ''  
                           BEGIN  
                              -- Get default printer in the group  
                              SELECT @cPrinterInGroup = PrinterID  
                              FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
                              WHERE PrinterGroup = @cLabelPrinter  
                                 AND DefaultPrinter = 1  
  
                              -- Check no default printer  
                              IF @cPrinterInGroup = ''  
                              BEGIN  
                                 SET @n_Err = 1001458  
                                 SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Label Printer setup not done. Please setup the Label Printer. Function : isp_rePrint
                                 GOTO EXIT_SP  
                              END  
                           END  
                           SET @cNewLabelPrinter = @cPrinterInGroup
                        END 
                     END

                     EXEC  [WM].[lsp_WM_Print_Report]
                       @c_ModuleID = @c_ModuleID           
                     , @c_ReportID = @c_ReportID         
                     , @c_Storerkey = @cStorerkey         
                     , @c_Facility  = @cFacility        
                     , @c_UserName  = @cUsername   
                     , @c_ComputerName = ''
                     , @c_PrinterID = @cNewLabelPrinter         
                     , @n_NoOfCopy  = '1'     
                     , @c_KeyValue1 = @cParams1        
                     , @c_KeyValue2 = @cParams2        
                     , @c_KeyValue3 = @cParams3     
                     , @c_KeyValue4 = @cParams4    
                     , @b_Success   = @b_Success         OUTPUT      
                     , @n_Err       = @n_Err             OUTPUT
                     , @c_ErrMsg    = @c_ErrMsg          OUTPUT
                     , @c_PrintSource  = @c_PrintSource        
                     , @b_SCEPreView   = 0         
                     , @c_JobIDs      = @cLabelJobID         OUTPUT    
                     , @c_AutoPrint  = 'N'     
             
                  IF @n_Err <> 0
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = @n_Err
                     SET @c_ErrMsg = @c_ErrMsg
                     GOTO EXIT_SP
                  END
	            END
            END
         END
      END

      ---- Common params ofr printing
      --DECLARE @tPackList AS VariableTable
      --INSERT INTO @tPackList (Variable, Value) VALUES
      --( '@c_StorerKey',     @cStorerKey),
      --( '@c_PickSlipNo',    @cPickSlipNo),
      --( '@c_StartCartonNo', CAST( @nCartonNo AS NVARCHAR(10))),
      --( '@c_EndCartonNo',   CAST( @nCartonNo AS NVARCHAR(10)))

      IF @PrinterType = 'Paper' --(cc03)
      BEGIN
	      IF @nPrintPackList = 'Y'
         BEGIN
            IF EXISTS (SELECT  TOP 1 1 FROM dbo.WMReport WMR WITH (NOLOCK) 
                        JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
                        WHERE Storerkey = @cStorerKey 
                        AND (reporttype = @cReporttype OR reporttype ='TPPACKLIST'))  
            BEGIN
	            IF ISNULL(@cPaperPrinter,'') = ''
	            BEGIN
		            SET @b_Success = 0
                  SET @n_Err = 1001459
                  SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Paper Printer setup not done. Please setup the Paper Printer. Function : isp_rePrint'

                  GOTO EXIT_SP
	            END
	            ELSE
	            BEGIN
                  SELECT   @c_ReportID = WMR.reportid,
                     @c_PrintSource = CASE WHEN printtype='LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
                     @cNewPaperPrinter = Defaultprinterid,
                     @cFieldName1  = keyFieldname1,
                     @cFieldName2  = keyFieldname2,
                     @cFieldName3  = keyFieldname3,
                     @cFieldName4  = keyFieldname4
                  FROM WMReport WMR (NOLOCK)
                  JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
                  WHERE Storerkey = @cStorerkey
                     AND Reporttype =  CASE WHEN ISNULL(@cReporttype,'') <> '' THEN  @cReporttype ELSE   'TPPACKLIST' END
                     AND ModuleID ='TPPack'
                     AND ispaperprinter = 'Y'
                     and (WMRD.username = '' OR WMRD.username = @cUsername)
                     AND (ISNULL(ComputerName,'') ='' OR ComputerName= @cWorkstation)

                  IF @@ROWCOUNT = 0
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = 1001460
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_rePrint'
                     GOTO EXIT_SP
                  END

                  IF ISNULL(@cFieldName1,'') = ''
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = 1001461
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_rePrint'
                     GOTO EXIT_SP
                  END

                  SET @IsAggregate1 = CASE WHEN ISNULL(@cFieldName1,'') <> '' AND (
                                      UPPER(@cFieldName1) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName1) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName1) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName1) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName1) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate2 = CASE WHEN ISNULL(@cFieldName2,'') <> '' AND (
                                      UPPER(@cFieldName2) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName2) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName2) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName2) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName2) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate3 = CASE WHEN ISNULL(@cFieldName3,'') <> '' AND (
                                      UPPER(@cFieldName3) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName3) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName3) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName3) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName3) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END

                  SET @IsAggregate4 = CASE WHEN ISNULL(@cFieldName4,'') <> '' AND (
                                      UPPER(@cFieldName4) LIKE '%SUM(%' OR 
                                      UPPER(@cFieldName4) LIKE '%AVG(%' OR
                                      UPPER(@cFieldName4) LIKE '%COUNT(%' OR
                                      UPPER(@cFieldName4) LIKE '%MIN(%' OR
                                      UPPER(@cFieldName4) LIKE '%MAX(%' COLLATE SQL_Latin1_General_CP1_CS_AS
                                  ) THEN 1 ELSE 0 END
 
                  SET  @cSQL =
                  'SELECT  @cParams1='+ @cFieldName1  
                           SELECT @cSQL= CASE WHEN ISNULL(@cFieldName2,'')<>''THEN @cSQL +',@cParams2='  + @cFieldName2  ELSE  @cSQL END 
                           SELECT @cSQL= CASE WHEN ISNULL(@cFieldName3,'')<>''THEN @cSQL +',@cParams3='  + @cFieldName3  ELSE  @cSQL END
                           SELECT @cSQL= CASE WHEN ISNULL(@cFieldName4,'')<>''THEN @cSQL +',@cParams4='  + @cFieldName4  ELSE  @cSQL END
                  SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
                     WHERE Storerkey = @cstorerkey
                        AND Pickslipno = @cPickslipno
                        AND CartonNo = @nCartonno '

                  SET @groupByFields = ''

                  IF ISNULL(@cFieldName1, '') <> '' AND @IsAggregate1 = 0 AND ISNUMERIC(@cFieldName1) = 0
                     SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName1

                  IF ISNULL(@cFieldName2, '') <> '' AND @IsAggregate2 = 0 AND ISNUMERIC(@cFieldName2) = 0
                     SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName2

                  IF ISNULL(@cFieldName3, '') <> '' AND @IsAggregate3 = 0 AND ISNUMERIC(@cFieldName3) = 0
                        SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName3

                  IF ISNULL(@cFieldName4, '') <> '' AND @IsAggregate4 = 0 AND ISNUMERIC(@cFieldName4) = 0
                        SET @groupByFields = @groupByFields + CASE WHEN LEN(@groupByFields) > 0 THEN ', ' ELSE '' END + @cFieldName4

                  -- If any valid fields found, append GROUP BY
                  IF LEN(@groupByFields) > 0
                        SET @cSQL = @cSQL + ' GROUP BY ' + @groupByFields

                  SET @cSQLParam = 
                     '  @cFieldName1 NVARCHAR(max),
                        @cFieldName2 NVARCHAR(max),
                        @cFieldName3 NVARCHAR(max),
                        @cFieldName4 NVARCHAR(max),
                        @cParams1    NVARCHAR(max) OUTPUT,
                        @cParams2    NVARCHAR(max) OUTPUT,
                        @cParams3    NVARCHAR(max) OUTPUT,
                        @cParams4    NVARCHAR(max) OUTPUT,
                        @cstorerkey  NVARCHAR(20),
                        @cPickslipno NVARCHAR(20),
                        @nCartonno   INT'

                     EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,
                        @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno 

                  IF ISNULL(@cNewPaperPrinter,'')= ''
                  BEGIN
                     SET @cNewPaperPrinter = @cPaperPrinter
                     -- Check if printer is a group  
                     IF EXISTS( SELECT TOP 1 1 FROM rdt.rdtPrinterGroup WITH (NOLOCK) WHERE PrinterGroup = @cPaperPrinter)  
                     BEGIN  
                        SET @cPrinterInGroup = ''  
  
                        -- Check if report print to a specific printer in group  
                        SELECT @cPrinterInGroup = PrinterID  
                        FROM rdt.rdtReportToPrinter WITH (NOLOCK)  
                        WHERE Function_ID = @nFunc  
                           AND StorerKey = @cStorerKey  
                           AND ReportType = @cReportType  
                           AND PrinterGroup = @cPaperPrinter  
  
                        IF @cPrinterInGroup = ''  
                        BEGIN  
                           -- Get default printer in the group  
                           SELECT @cPrinterInGroup = PrinterID  
                           FROM rdt.rdtPrinterGroup WITH (NOLOCK)  
                           WHERE PrinterGroup = @cPaperPrinter  
                              AND DefaultPrinter = 1  
  
                           -- Check no default printer  
                           IF @cPrinterInGroup = ''  
                           BEGIN  
                              SET @n_Err = 1001462  
                              SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Paper Printer setup not done. Please setup the Paper Printer. Function : isp_rePrint  
                              GOTO EXIT_SP
                           END  
                        END  
                        SET @cNewPaperPrinter = @cPrinterInGroup
                     END
                  END


                  EXEC  [WM].[lsp_WM_Print_Report]
                    @c_ModuleID = @c_ModuleID           
                  , @c_ReportID = @c_ReportID         
                  , @c_Storerkey = @cStorerkey         
                  , @c_Facility  = @cFacility        
                  , @c_UserName  = @cUsername     
                  , @c_ComputerName = ''
                  , @c_PrinterID = @cNewPaperPrinter         
                  , @n_NoOfCopy  = '1'     
                  , @c_KeyValue1 = @cParams1        
                  , @c_KeyValue2 = @cParams2    
                  , @c_KeyValue3 = @cParams3    
                  , @c_KeyValue4 = @cParams4    
                  , @b_Success   = @b_Success         OUTPUT      
                  , @n_Err       = @n_Err             OUTPUT
                  , @c_ErrMsg    = @c_ErrMsg          OUTPUT
                  , @c_PrintSource  = @c_PrintSource        
                  , @b_SCEPreView   = 0         
                  , @c_JobIDs      = @cPackingJobID         OUTPUT    
                  , @c_AutoPrint  = 'N'   

                  IF @n_Err <> 0
                  BEGIN
                     SET @b_Success = 0
                     SET @n_Err = @n_Err
                     SET @c_ErrMsg = @c_ErrMsg
                     GOTO EXIT_SP
                  END
	            END
            END
         END
      END
   END

   --set @cPackingJobID = 'test123'
   SET @b_Success = 1
   SET @jResult = (select @cLabelJobID as LabelJobID, @cPackingJobID as PackingJobID FOR JSON PATH )
   SET @n_Err = 0
   SET @c_ErrMsg = ''
   GOTO EXIT_SP



EXIT_SP:
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'lsp_RevertUser' AND type = 'P') AND SESSION_CONTEXT(N'mwms_user_name') IS NOT NULL
BEGIN
   EXEC [WM].[lsp_RevertUser]
END
REVERT

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_rePrint TO NSQL
GO