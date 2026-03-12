SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: isp_TPS_ExtREPrint03                                      */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */  
/* 2025-06-23   1.0  GCH225     FCR-5588 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPS_ExtREPrint03] (
	@cStorerKey      NVARCHAR( 15), 
   @cFacility       NVARCHAR( 5),  
   @nFunc           INT,           
   @cUserName       NVARCHAR( 128),
   @cLangCode       NVARCHAR( 3),  
   @cScanNo         NVARCHAR( 50), 
   @cpickslipNo     NVARCHAR( 30), 
   @cDropID         NVARCHAR( 50), 
   @cOrderKey       NVARCHAR( 10), 
   @nCartonNo       INT,    
   @cType           NVARCHAR( 30), 
   @cWorkstation    NVARCHAR( 30),  
   @PrinterType     NVARCHAR( 20), 
   @cPrintAllLbl    NVARCHAR (20), 
   @nPrintPackList  NVARCHAR (1),
   @cReporttype     NVARCHAR (20),
   @cLabelJobID     NVARCHAR ( 30) OUTPUT,
   @cPackingJobID   NVARCHAR ( 30) OUTPUT,
   @b_Success       INT            OUTPUT,
   @n_Err           INT            OUTPUT,
   @c_ErrMsg        NVARCHAR( 255)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelPrinter  NVARCHAR ( 30)
   DECLARE @cPaperPrinter  NVARCHAR ( 30)
   DECLARE @cPrinter       NVARCHAR ( 20)
   DECLARE @cSQL           NVARCHAR ( MAX)
   DECLARE @cSQLParam      NVARCHAR ( MAX)
   DECLARE @cNewPaperPrinter NVARCHAR(20)
   DECLARE @cNewLabelPrinter NVARCHAR(20)
   DECLARE @cPrinterInGroup NVARCHAR(10) 
   DECLARE @groupByFields NVARCHAR(MAX) = ''
   DECLARE @cCurOrderkey NVARCHAR(10)
   DECLARE @cLoadKey NVARCHAR(10)

   DECLARE @c_ModuleID           NVARCHAR(30) ='TPPack'
         , @c_ReportID           NVARCHAR(10) 
         , @c_PrinterID          NVARCHAR(30)  
         , @c_JobIDs             NVARCHAR(50)   = ''         --(Wan03) -- May return multiple jobs ID.JobID seperate by '|'
         , @c_PrintSource        NVARCHAR(20)
         , @c_AutoPrint          NVARCHAR(1)    = 'N'        --(Wan07)

   DECLARE  @cFieldName1 NVARCHAR(max),
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
   
   DECLARE @cCurLabel CURSOR  
   DECLARE @cCurPaper CURSOR 
   DECLARE @cCurOrderList CURSOR

   set @cLabelJobID = ''
   set @cPackingJobID = ''
   SET @b_Success = 1

   SELECT @cPaperPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Paper'
   SELECT @cLabelPrinter = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND printerType = 'Label'
   
	IF ISNULL(@cPickSlipNo,'') = ''  
   BEGIN  
      SET @b_Success = 0
      SET @n_Err = 1003051
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'PickSlipNo cannot be empty. Function : isp_TPS_ExtREPrint03'
      GOTO Quit
   END  

   --IF ISNULL(@cOrderkey,'') = ''  
   --BEGIN  
   --   SET @b_Success = 0
   --   SET @n_Err = 1003052
   --   SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'OrderKey cannot be empty. Function : isp_TPS_ExtREPrint03'
   --   GOTO Quit
   --END 

    
   IF @PrinterType = 'Label'
   BEGIN
      SET @cCurLabel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
      SELECT reporttype  
      FROM WMReport WMR WITH (NOLOCK)  
         JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid  
      WHERE  Storerkey = @cStorerkey  
         AND ispaperprinter <> 'Y'
         AND WMR.moduleid = @c_ModuleID
         AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
         AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  
      ORDER BY WMR.reportid
      OPEN @cCurLabel  
      FETCH NEXT FROM @cCurLabel INTO @cReportType  
      WHILE @@FETCH_STATUS = 0  
      BEGIN  

         SELECT   @c_ReportID = WMR.reportid,  
                  @c_PrintSource = CASE WHEN printtype = 'LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,  
                  @cNewLabelPrinter = Defaultprinterid,  
                  @cFieldName1  = keyFieldname1,  
                  @cFieldName2  = keyFieldname2,  
                  @cFieldName3  = keyFieldname3,  
                  @cFieldName4  = keyFieldname4  
         FROM WMReport WMR (NOLOCK)  
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid  
         WHERE Storerkey = @cStorerkey  
            AND reporttype = @cReportType  
            AND ModuleID =@c_ModuleID 
            AND ispaperprinter <> 'Y'  
            AND (WMRD.username = '' OR WMRD.username = @cUsername)  
            AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)  
            AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)    

         IF @@ROWCOUNT = 0
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1003053
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_TPS_ExtREPrint03'
            GOTO Quit
         END

         IF ISNULL(@cFieldName1,'') = ''
         BEGIN
            SET @b_Success = 0
            SET @n_Err = 1003054
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_TPS_ExtREPrint03'
            GOTO Quit
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

         SET  @cSQL = ' SELECT  @cParams1 = '+ @cFieldName1    
               SELECT @cSQL= CASE WHEN ISNULL(@cFieldName2,'') <> ''THEN @cSQL +',@cParams2 = ' + @cFieldName2  ELSE  @cSQL END   
               SELECT @cSQL= CASE WHEN ISNULL(@cFieldName3,'') <> ''THEN @cSQL +',@cParams3 = '  + @cFieldName3  ELSE  @cSQL END  
               SELECT @cSQL= CASE WHEN ISNULL(@cFieldName4,'') <> ''THEN @cSQL +',@cParams4 = '  + @cFieldName4  ELSE  @cSQL END  
         SET @cSQL = @cSQL +' FROM PackDetail (NOLOCK) '
            + ' WHERE Storerkey = @cstorerkey '
            + ' AND Pickslipno = @cPickslipno '
            + ' AND CartonNo = @nCartonno '  

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
         ' @cFieldName1 NVARCHAR(max),  
         @cFieldName2 NVARCHAR(max),  
         @cFieldName3 NVARCHAR(max),  
         @cFieldName4 NVARCHAR(max),  
         @cParams1    NVARCHAR(max) OUTPUT,  
         @cParams2    NVARCHAR(max) OUTPUT,  
         @cParams3    NVARCHAR(max) OUTPUT,  
         @cParams4  NVARCHAR(max) OUTPUT,  
         @cstorerkey  NVARCHAR(20),  
         @cPickslipno NVARCHAR(20),  
         @nCartonno   INT'  

         EXEC sp_ExecuteSQL @cSQL,@cSQLParam,@cFieldName1,@cFieldName2,@cFieldName3,@cFieldName4,  
         @cParams1 OUTPUT,@cParams2 OUTPUT,@cParams3 OUTPUT,@cParams4 OUTPUT,@cstorerkey,@cPickslipno,@nCartonno   

         IF ISNULL(@cNewLabelPrinter,'') = ''
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
                     SET @b_Success = 0
                     SET @n_Err = 1003055  
                     SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Label Printer setup not done. Please setup the Label Printer. Function : isp_TPS_ExtREPrint03
                     GOTO Quit  
                  END  
               END  
               SET @cNewLabelPrinter = @cPrinterInGroup
            END
         END 

         EXEC  [WM].[lsp_WM_Print_Report]  
            @c_ModuleID      = @c_ModuleID             
         , @c_ReportID     = @c_ReportID           
         , @c_Storerkey    = @cStorerkey           
         , @c_Facility     = @cFacility          
         , @c_UserName     = @cUsername     
         , @c_ComputerName = @cWorkstation  
         , @c_PrinterID    = @cNewLabelPrinter           
         , @n_NoOfCopy     = '1'       
         , @c_KeyValue1    = @cParams1          
         , @c_KeyValue2    = @cParams2          
         , @c_KeyValue3    = @cParams3       
         , @c_KeyValue4    = @cParams4         
         , @b_Success      = @b_Success         OUTPUT        
         , @n_Err          = @n_Err             OUTPUT  
         , @c_ErrMsg       = @c_ErrMsg          OUTPUT  
         , @c_PrintSource  = @c_PrintSource          
         , @b_SCEPreView   = 0           
         , @c_JobIDs       = @c_JobIDs         OUTPUT      
         , @c_AutoPrint    = 'N'       

         SET @cLabelJobID = @cLabelJobID + @c_JobIDs  

         FETCH NEXT FROM @cCurLabel INTO @cReportType  
      END  
      CLOSE @cCurLabel  
      DEALLOCATE @cCurLabel  
   END
   ELSE IF @PrinterType = 'Paper'
   BEGIN
      IF @nPrintPackList <> 'Y'  
      BEGIN  
         GOTO QUIT
      END  
      SELECT @cOrderKey = OrderKey,
             @cLoadKey = LoadKey
      FROM PACKHEADER (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo

      SET @cCurOrderList = CURSOR LOCAL READ_ONLY READ_ONLY FAST_FORWARD FOR  
      SELECT DISTINCT O.OrderKey
      FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN Orders O WITH (NOLOCK) 
      ON PD.Orderkey = O.Orderkey AND PD.Storerkey = O.Storerkey
      WHERE PD.StorerKey = @cStorerKey
      AND (@cOrderKey = '' OR O.OrderKey = @cOrderKey)
      AND (@cLoadKey = '' OR O.LoadKey = @cLoadKey)
      ORDER BY O.OrderKey ASC

      OPEN @cCurOrderList  
      FETCH NEXT FROM @cCurOrderList INTO @cCurOrderkey  
      WHILE @@FETCH_STATUS = 0  
      BEGIN 
         --Skip Print Packing List if all Pick Detail Status still below 5
         IF EXISTS(SELECT 1 FROM PICKDETAIL (NOLOCK) WHERE OrderKey = @cOrderKey AND Status < '5')
         BEGIN
            --SET @b_Success = 0
            --SET @n_Err = 1002909  
            --SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- Function : isp_TPS_ExtREPrint03
            GOTO NEXTITEM
         END

         SET @cCurPaper = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
         SELECT reporttype
         FROM WMReport WMR WITH (NOLOCK)
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid = WMRD.reportid
         WHERE  Storerkey = @cStorerkey
               AND ispaperprinter = 'Y'
               AND WMR.moduleid = @c_ModuleID
               AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  
         OPEN @cCurPaper
         FETCH NEXT FROM @cCurPaper INTO @cReportType
         WHILE @@FETCH_STATUS = 0
         BEGIN
            SELECT   @c_ReportID = WMR.reportid,
                     @c_PrintSource = CASE WHEN printtype = 'LOGIREPORT' THEN 'JReport' ELSE 'WMReport' END,
                     @cNewPaperPrinter = Defaultprinterid,
                     @cFieldName1  = keyFieldname1,
                     @cFieldName2  = keyFieldname2,
                     @cFieldName3  = keyFieldname3,
                     @cFieldName4  = keyFieldname4
            FROM WMReport WMR (NOLOCK)
            JOIN WMReportdetail WMRD (NOLOCK) ON WMR.reportid =WMRD.reportid
            WHERE Storerkey = @cStorerkey
               AND reporttype = @cReportType --(yeekung05)
               AND ModuleID = @c_ModuleID
               AND ispaperprinter = 'Y'
               and (WMRD.username = '' OR WMRD.username = @cUsername)
               AND (ISNULL(ComputerName,'') ='' OR ComputerName = @cWorkstation)
               AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)  

            IF @@ROWCOUNT = 0
            BEGIN
               SET @b_Success = 0
               SET @n_Err = 1003056
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No records found in WMReport. Function : isp_TPS_ExtREPrint03'
               GOTO Quit
            END

            IF ISNULL(@cFieldName1,'') = ''
            BEGIN
               SET @b_Success = 0
               SET @n_Err = 1003057
               SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'No value found in table(WMReport); column(keyFieldname1), this column cannot be empty or null. Function : isp_TPS_ExtREPrint03'
               GOTO Quit
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
            SET @cSQL = ''
            SET @cSQLParam = ''

            SET  @cSQL =
            'SELECT  @cParams1='+ @cFieldName1  
                     SELECT @cSQL = CASE WHEN ISNULL(@cFieldName2,'') <> ''THEN @cSQL +',@cParams2 = '  + @cFieldName2  ELSE  @cSQL END 
                     SELECT @cSQL = CASE WHEN ISNULL(@cFieldName3,'') <> ''THEN @cSQL +',@cParams3 = '  + @cFieldName3  ELSE  @cSQL END
                     SELECT @cSQL = CASE WHEN ISNULL(@cFieldName4,'') <> ''THEN @cSQL +',@cParams4 = '  + @cFieldName4  ELSE  @cSQL END
            SET @cSQL = @cSQL +' FROM Packdetail (NOLOCK)
               WHERE Storerkey = @cstorerkey
                  AND Pickslipno = @cPickslipno
                  AND CartonNO = @nCartonno '

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
                        SET @n_Err = 1003058  
                        SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Paper Printer setup not done. Please setup the Paper Printer. Function : isp_TPS_ExtREPrint03  
                        GOTO Quit  
                     END  
                  END  
                  SET @cNewPaperPrinter = @cPrinterInGroup
               END
            END

            EXEC  [WM].[lsp_WM_Print_Report]
               @c_ModuleID    = @c_ModuleID           
            , @c_ReportID     = @c_ReportID         
            , @c_Storerkey    = @cStorerkey         
            , @c_Facility     = @cFacility        
            , @c_UserName     = @cUsername     
            , @c_ComputerName = @cWorkstation
            , @c_PrinterID    = @cNewPaperPrinter         
            , @n_NoOfCopy     = '1'     
            , @c_KeyValue1    = @cParams1        
            , @c_KeyValue2    = @cParams2     
            , @c_KeyValue3    = @cParams3 
            , @c_KeyValue4    = @cParams4
            , @b_Success      = @b_Success         OUTPUT      
            , @n_Err          = @n_Err             OUTPUT
            , @c_ErrMsg       = @c_ErrMsg          OUTPUT
            , @c_PrintSource  = @c_PrintSource        
            , @b_SCEPreView   = 0         
            , @c_JobIDs       = @c_JobIDs         OUTPUT    
            , @c_AutoPrint    = 'N'   

            SET @cPackingJobID = @cPackingJobID + @c_JobIDs

            FETCH NEXT FROM @cCurPaper INTO @cReportType
         END
         CLOSE @cCurPaper  
         DEALLOCATE @cCurPaper 

NEXTITEM:
         FETCH NEXT FROM @cCurOrderList INTO @cCurOrderkey  
      END
      CLOSE @cCurOrderList  
      DEALLOCATE @cCurOrderList  
   END

Quit:
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtREPrint03 TO NSQL
GO