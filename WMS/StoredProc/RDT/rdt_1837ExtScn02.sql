SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_1837ExtScn02                                    */
/*                                                                      */
/* Purpose:       Extended Screen Logic for Post Pack Sort              */
/*                                                                      */
/* Date        Rev   Author     Purposes                                */
/* 2026-01-22  1.0   Dennis     FCR-10136                               */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1837ExtScn02] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nScn         INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15), 

   @tExtScnData   VariableTable READONLY,

   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,  
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT, 
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT, 
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT, 
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT, 
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT, 
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT, 
   @nAfterScn        INT            OUTPUT, 
   @nAfterStep       INT            OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 1024)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag      INT = 0

   --Standard ExtScn variables
   DECLARE
      @nTempScn      INT,
      @nTempStep     INT
   --Standard ExtScn variables end
   
   DECLARE @nOrignStep    INT
   DECLARE @nOrignScn     INT
   DECLARE @tClosePallet         VariableTable
   DECLARE @tPrintLabelParam     VariableTable
   DECLARE @cAutoCompASTMV       NVARCHAR(1)
   DECLARE @cTaskDetailKey       NVARCHAR(10)
   DECLARE @cToLoc               NVARCHAR(10)
   DECLARE @nTranCount           INT

   -- Extracted Variables
   DECLARE @cCartonID           NVARCHAR( 20)
   DECLARE @cPalletID           NVARCHAR( 20)
   DECLARE @cLoadKey            NVARCHAR( 10)
   DECLARE @cPPS_Loc            NVARCHAR( 10)
   DECLARE @cPickDetailCartonID NVARCHAR( 20)
   DECLARE @cLabelPrinter       NVARCHAR( 10)
   DECLARE @cPaperPrinter       NVARCHAR( 10)
   DECLARE @cUserName           NVARCHAR( 18)
   DECLARE @nMOBRECStep         INT
   DECLARE @nMOBRECScn          INT,
   @cDocType                    NVARCHAR(10),
   @cWAVEKey                    NVARCHAR(10),
   @cDecodeSP           NVARCHAR( 20), 
   @cExtendedInfo       NVARCHAR( 20),
   @cExtendedInfoSP     NVARCHAR( 20),
   @cExtendedUpdateSP   NVARCHAR( 20),
   @cExtendedValidateSP NVARCHAR( 20),
   @cBarcode            NVARCHAR( Max), 
   @cConsigneeKey       NVARCHAR(10),
   @cOption             NVARCHAR( 1), 
   @cPickConfirmStatus  NVARCHAR( 1),
   @cDefaultWeight      NVARCHAR( 1),  
   @tExtValidate        VariableTable, 
   @tExtUpdate          VariableTable, 
   @tExtInfo            VariableTable, 
   @tPostPackSortCfm    VariableTable, 
   @cReportType         NVARCHAR( 20),
   @nPABookingKey       INT,
   @nNoOfCheck          INT,
   @cOrderKey           NVARCHAR( 10),
   @nRowCount           INT,
   @nSuccess            INT,
   @cNewTaskDetailKey   NVARCHAR( 10),
   @cPriority           NVARCHAR( 10),
   @cCheckOrderMustPickComplete  NVARCHAR( 1)
   DECLARE @cErrMsg01        NVARCHAR( 20),
           @cErrMsg02        NVARCHAR( 20),
           @cErrMsg03        NVARCHAR( 20)
   DECLARE 
   @cSQL           NVARCHAR(MAX), 
   @cSQLParam      NVARCHAR(MAX)
   -- Screen constant
   DECLARE
      @nStep_FromCarton    INT,  @nScn_FromCarton     INT,
      @nStep_ToPallet      INT,  @nScn_ToPallet       INT,
      @nStep_ClosePallet   INT,  @nScn_ClosePallet    INT,
      @nStep_Message       INT,  @nScn_Message        INT,
      @nStep_ExtendedScreen  INT

   SELECT
      @nStep_FromCarton  = 1,  @nScn_FromCarton   = 5590,
      @nStep_ToPallet    = 2,  @nScn_ToPallet     = 5591,
      @nStep_ClosePallet = 3,  @nScn_ClosePallet  = 5592,
      @nStep_Message     = 4,  @nScn_Message      = 5593,
      @nStep_ExtendedScreen = 99
   SELECT 
      @nMOBRECStep     = Step,
      @nMOBRECScn      = Scn,
      @cLoadKey       = V_LoadKey,
      @cPPS_Loc       = V_Loc,
   
      @cExtendedUpdateSP   = V_String1,
      @cExtendedValidateSP = V_String2,
      @cExtendedInfoSP     = V_String3,
      @cCartonID           = V_String4,
      @cPalletID           = V_String5,
      @cPickDetailCartonID = V_String6,
      @cPickConfirmStatus  = V_String7,
      @cCheckOrderMustPickComplete = V_String8,

      @cLabelPrinter  = Printer,
      @cPaperPrinter  = Printer_Paper,
      @cUserName      = UserName
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile 

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Entering rdt_1837ExtScn02'
      SELECT @nMobile        AS nMobile,
             @nFunc          AS nFunc,
             @cLangCode      AS cLangCode,
             @nStep          AS nStep,
             @nInputKey      AS nInputKey,
             @cFacility      AS cFacility,
             @cStorerKey     AS cStorerKey,
             @cCartonID      AS cCartonID, 
             @cPalletID      AS cPalletID, 
             @cLoadKey       AS cLoadKey, 
             @cPPS_Loc       AS cPPS_Loc
   END

   IF @nFunc = 1837
   BEGIN
      IF @nStep = 1
      BEGIN
         SET @nAfterStep = 99
         GOTO Quit
      END
      IF @nMOBRECStep = 99
      BEGIN
         IF @nMOBRECScn = 6818 --Print packslip
         BEGIN
            IF @nInputKey = 1
            BEGIN
               IF @cInField02 NOT IN ( '1' ,'9')-- YES
               BEGIN
                  SET @nErrNo = 256954
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Input
                  GOTO QUIT
               END
               IF @cInField02 = '1' -- YES
               BEGIN
                  SET @cSQL = 
                     ' SELECT TOP 1 @cOrderKey = OrderKey' + 
                     ' FROM dbo.PickDetail WITH (NOLOCK) ' + 
                     ' WHERE StorerKey = @cStorerKey ' + 
                        ' AND Status = ''' + @cPickConfirmStatus + '''' +  
                        ' AND QTY > 0 ' + 
                        ' AND ' + RTRIM( @cPickDetailCartonID) + ' = @cCartonID ' +
                        ' ORDER BY 1 ' +
                        ' SET @nRowCount = @@ROWCOUNT '

                  SET @cSQLParam = 
                     ' @cStorerKey  NVARCHAR( 15), ' + 
                     ' @cCartonID   NVARCHAR( 20), ' + 
                     ' @cOrderKey   NVARCHAR( 10)  OUTPUT, ' + 
                     ' @nRowCount   INT            OUTPUT '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam
                     ,@cStorerKey
                     ,@cCartonID 
                     ,@cOrderKey OUTPUT
                     ,@nRowCount OUTPUT

                  SELECT @cReportType = CASE WHEN O.UserDefine03 <> 'CPL' THEN CL1.UDF01 ELSE CL2.UDF03 END
                  FROM ORDERS O (NOLOCK) 
                  LEFT JOIN CODELKUP CL1 (NOLOCK) ON O.UserDefine03 = CL1.Code AND CL1.ListName = 'CSPACKSLIP' AND CL1.StorerKey = @cStorerKey
                  LEFT JOIN CODELKUP CL2 (NOLOCK) ON O.BillToKey = CL2.Code2 AND CL2.ListName = 'CSCCUSTMAT' AND CL2.StorerKey = @cStorerKey                 
                  WHERE O.OrderKey = @cOrderKey AND O.StorerKey = @cStorerKey

                  DECLARE @tReportParam VariableTable
                  DELETE FROM @tReportParam
                  INSERT INTO @tReportParam (Variable, Value)
                  VALUES
                     ( '@cStorerKey', @cStorerKey),
                     ( '@cLabelNo', @cCartonID)

                  -- Print label
                  EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter,
                     @cReportType,   -- Report type
                     @tReportParam, -- Report params
                     'rdt_1837ExtScn02',
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit

                  UPDATE PACKHEADER SET ManifestPrinted = '1'
                  WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey
               END

               -- Prepare next screen var
               SET @cOutField01 = @cCartonID
               SET @cOutField02 = @cLoadKey
               SET @cOutField03 = @cPPS_Loc
               SET @cOutField04 = ''

               SET @nAfterScn = @nScn_ToPallet
               SET @nAfterStep = 99
               GOTO QUIT
            END
            IF @nInputKey = 0
            BEGIN
               SET @cOutField01 = '' 
               SET @cOutField02 = '' 
               EXEC rdt.rdtSetFocusField @nMobile, 1
               SET @nAfterScn = 5590
               SET @nAfterStep = 99
               GOTO QUIT
            END
         END
         IF @nMOBRECScn = 5590 -- From Carton
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Screen mapping
               SET @cCartonID = @cInField01
               SET @cPalletID = @cInField02

               -- Check blank
               IF ISNULL( @cCartonID, '') = '' AND ISNULL( @cPalletID, '') = ''
               BEGIN
                  SET @nErrNo = 144301
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Value req
                  GOTO QUIT
               END

               IF ISNULL( @cCartonID, '') <> '' AND ISNULL( @cPalletID, '') <> ''
               BEGIN
                  SET @nErrNo = 144312
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Only Either 1
                  GOTO QUIT
               END

               SET @cPPS_Loc = ''

               IF ISNULL( @cCartonID, '') <> '' 
               BEGIN
                  SET @cSQL = 
                     ' SELECT TOP 1 @cOrderKey = OrderKey' + 
                     ' FROM dbo.PickDetail WITH (NOLOCK) ' + 
                     ' WHERE StorerKey = @cStorerKey ' + 
                        ' AND Status = ''' + @cPickConfirmStatus + '''' +  
                        ' AND QTY > 0 AND LOC IN( ''CONVEYOR'',''CSCHOSP'')' + 
                        ' AND ' + RTRIM( @cPickDetailCartonID) + ' = @cCartonID ' +
                        ' ORDER BY 1 ' +
                        ' SET @nRowCount = @@ROWCOUNT '

                  SET @cSQLParam = 
                     ' @cStorerKey  NVARCHAR( 15), ' + 
                     ' @cCartonID   NVARCHAR( 20), ' + 
                     ' @cOrderKey   NVARCHAR( 10)  OUTPUT, ' + 
                     ' @nRowCount   INT            OUTPUT '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam
                     ,@cStorerKey
                     ,@cCartonID 
                     ,@cOrderKey OUTPUT
                     ,@nRowCount OUTPUT

                  IF @nRowCount = 0 OR ISNULL( @cOrderKey, '') = ''
                  BEGIN
                     SET @nErrNo = 144302
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Ctn
                     GOTO QUIT
                  END

                  SELECT @cDocType = DocType,
                  @cWAVEKey = USERDEFINE09,
                  @cLoadKey = LoadKey,
                  @cConsigneeKey = ConsigneeKey
                  FROM ORDERS WITH (NOLOCK)
                  WHERE OrderKey = @cOrderKey
                  AND   StorerKey = @cStorerKey

                  IF @nDebugFlag = 1 
                  BEGIN
                     SELECT '@cDocType' = @cDocType,
                            '@cWAVEKey' = @cWAVEKey,
                            '@cLoadKey' = @cLoadKey,
                            '@cConsigneeKey' = @cConsigneeKey
                  END

                  IF @cDocType = 'E' --B2C
                  BEGIN
                     IF ISNULL(@cWaveKey ,'') = ''
                     BEGIN
                        SET @nErrNo = 256956
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Wavekey
                        GOTO QUIT
                     END
                     IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE WAVEKEY = @cWAVEKey)
                     BEGIN
                        SELECT TOP 1 @cPPS_Loc = Loc
                        FROM dbo.Loc LOC WITH (NOLOCK)
                        WHERE Facility = @cFacility
                        AND   LocationCategory = 'PPS'
                        AND   [Status] = 'OK'
                        AND   LocationType <> 'PPSH'
                        AND NOT EXISTS (
                           SELECT 1 FROM rdt.rdtSortLaneLocLog SL WITH (NOLOCK) 
                           WHERE LOC.LOC = SL.LOC
                           AND   SL.Status = '1')
                        ORDER BY 1
                     END
                     ELSE
                     BEGIN
                        SELECT TOP 1 @cPPS_Loc = Loc
                        FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) 
                        WHERE WAVEKEY = @cWAVEKey
                     END
                  END
                  ELSE IF @cDocType = 'N' --B2B
                  BEGIN
                     IF EXISTS (
                        SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                        WHERE PD.StorerKey = @cStorerKey
                        AND (
                           (@cPickDetailCartonID = 'DROPID' AND PD.DROPID = @cCartonID)
                           OR 
                           (@cPickDetailCartonID = 'CASEID' AND PD.CaseID = @cCartonID)
                        )
                        AND EXISTS (
                           SELECT 1 FROM PICKDETAIL PD1 
                           WHERE PD1.STATUS = '4' 
                           AND PD1.OrderKey = PD.OrderKey 
                           AND PD1.StorerKey = PD.StorerKey
                        )
                     )
                     BEGIN
                        IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = 'HOSPITAL' AND OrderKey = @cStorerKey)
                        BEGIN
                           SELECT TOP 1 @cPPS_Loc = Loc
                           FROM dbo.Loc LOC WITH (NOLOCK)
                           WHERE Facility = @cFacility
                           AND   LocationCategory = 'PPS'
                           AND   [Status] = 'OK'
                           AND   LocationType = 'PPSH'
                           AND NOT EXISTS (
                              SELECT 1 FROM rdt.rdtSortLaneLocLog SL WITH (NOLOCK) 
                              WHERE LOC.LOC = SL.LOC
                              AND   SL.Status = '1')
                           ORDER BY 1
                        END
                        ELSE
                        BEGIN
                           SELECT @cPPS_Loc = LOC FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = 'HOSPITAL' AND OrderKey = @cStorerKey
                        END
                     END
                     ELSE IF EXISTS ( SELECT 1 FROM PICKDETAIL PD WHERE (
                           (@cPickDetailCartonID = 'DROPID' AND PD.DROPID = @cCartonID)
                           OR 
                           (@cPickDetailCartonID = 'CASEID' AND PD.CaseID = @cCartonID)
                        ) AND STATUS < '4' AND StorerKey = @cStorerKey)
                     BEGIN
                        SET @nErrNo = 256951
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Picking Not Complete
                        GOTO QUIT
                     END
                     ELSE
                     BEGIN -- ALL 5
                        IF ISNULL(@cLoadKey ,'') = '' OR ISNULL(@cConsigneeKey ,'') = ''
                        BEGIN
                           SET @nErrNo = 256957
                           SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --Invalid LoadKeyOrConsigneeKey
                           GOTO QUIT
                        END
                        IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND ConsigneeKey = @cConsigneeKey)
                        BEGIN
                           SELECT TOP 1 @cPPS_Loc = Loc
                           FROM dbo.Loc LOC WITH (NOLOCK)
                           WHERE Facility = @cFacility
                           AND   LocationCategory = 'PPS'
                           AND   [Status] = 'OK'
                           AND   LocationType <> 'PPSH'
                           AND NOT EXISTS (
                              SELECT 1 FROM rdt.rdtSortLaneLocLog SL WITH (NOLOCK) 
                              WHERE LOC.LOC = SL.LOC
                              AND   SL.Status = '1')
                           ORDER BY 1
                        END
                        ELSE
                        BEGIN
                           SELECT @cPPS_Loc = LOC FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND ConsigneeKey = @cConsigneeKey
                        END
                     END
                  END

                  IF ISNULL(@cPPS_Loc,'') = ''
                  BEGIN
                     SET @nErrNo = 256952
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PPSLOCNOTFOUND
                     GOTO QUIT
                  END

                  IF EXISTS ( SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) 
                     WHERE LOC = @cPPS_Loc
                     AND   Lane = ''
                     AND   [Status] = '9')
                  BEGIN
                     DELETE FROM rdt.rdtSortLaneLocLog WITH (ROWLOCK)
                     WHERE LOC = @cPPS_Loc
                     AND   Lane = ''
                     AND   [Status] = '9'
                  END

                  IF @cDocType = 'E' --B2C
                  BEGIN
                     IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE WAVEKEY = @cWAVEKey)
                     BEGIN
                        INSERT INTO rdt.rdtSortLaneLocLog 
                        ( Lane, LOC, ID, OrderKey, ConsigneeKey, Status, AddWho, AddDate, EditWho, EditDate, WAVEKEY)
                        VALUES
                        ( '', @cPPS_Loc, '', '', '', '1', @cUserName, GETDATE(), @cUserName, GETDATE(), @cWAVEKey)
                     END
                     ELSE IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE WAVEKEY = @cWAVEKey AND Status = '9')
                     BEGIN
                        UPDATE rdt.rdtSortLaneLocLog WITH (ROWLOCK) SET 
                           Status = '1',
                           Id = '',
                           EditWho = @cUserName,
                           EditDate = GETDATE()
                        WHERE LOC = @cPPS_Loc
                        AND   Lane = ''
                        AND   [Status] = '9' 
                        AND   WAVEKEY = @cWAVEKey
                     END
                  END
                  ELSE IF @cDocType = 'N' --B2B
                  BEGIN
                     IF EXISTS (
                        SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                        WHERE PD.StorerKey = @cStorerKey
                        AND (
                           (@cPickDetailCartonID = 'DROPID' AND PD.DROPID = @cCartonID)
                           OR 
                           (@cPickDetailCartonID = 'CASEID' AND PD.CaseID = @cCartonID)
                        )
                        AND EXISTS (
                           SELECT 1 FROM PICKDETAIL PD1 
                           WHERE PD1.STATUS = '4' 
                           AND PD1.OrderKey = PD.OrderKey 
                           AND PD1.StorerKey = PD.StorerKey
                        )
                     )
                     BEGIN
                        IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = 'HOSPITAL' AND OrderKey = @cStorerKey)
                        BEGIN
                           INSERT INTO rdt.rdtSortLaneLocLog 
                           ( Lane, LOC, ID, ConsigneeKey, Status, AddWho, AddDate, EditWho, EditDate, LoadKey,OrderKey)
                           VALUES
                           ( '', @cPPS_Loc, '',  '', '1', @cUserName, GETDATE(), @cUserName, GETDATE(), 'HOSPITAL',@cStorerKey)
                        END
                        ELSE IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE  LoadKey = 'HOSPITAL' AND OrderKey = @cStorerKey AND Status = '9')
                        BEGIN
                           UPDATE rdt.rdtSortLaneLocLog WITH (ROWLOCK) SET 
                              Status = '1',
                              Id = '',
                              EditWho = @cUserName,
                              EditDate = GETDATE()
                           WHERE LOC = @cPPS_Loc
                           AND   Lane = ''
                           AND   [Status] = '9' 
                           AND   LoadKey = 'HOSPITAL' 
                           AND   OrderKey = @cStorerKey
                        END
                     END
                     ELSE
                     BEGIN -- ALL 5
                        IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND ConsigneeKey = @cConsigneeKey)
                        BEGIN
                           INSERT INTO rdt.rdtSortLaneLocLog 
                           ( Lane, LOC, ID, OrderKey, ConsigneeKey, Status, AddWho, AddDate, EditWho, EditDate, LoadKey)
                           VALUES
                           ( '', @cPPS_Loc, '', '', @cConsigneeKey, '1', @cUserName, GETDATE(), @cUserName, GETDATE(), @cLoadKey)
                        END
                        ELSE IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND ConsigneeKey = @cConsigneeKey AND Status = '9')
                        BEGIN
                           UPDATE rdt.rdtSortLaneLocLog WITH (ROWLOCK) SET 
                              Status = '1',
                              Id = '',
                              EditWho = @cUserName,
                              EditDate = GETDATE()
                           WHERE LOC = @cPPS_Loc
                           AND   Lane = ''
                           AND   [Status] = '9' 
                           AND   LoadKey = @cLoadKey 
                           AND   ConsigneeKey = @cConsigneeKey
                        END
                     END
                  END
               END

               IF ISNULL( @cPalletID, '') <> ''
               BEGIN
                  IF NOT EXISTS ( SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK)
                                 WHERE ID = @cPalletID
                                 AND   [Status] = '1')
                  BEGIN
                     SET @nErrNo = 144311
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet
                     GOTO QUIT
                  END
               END

               -- Extended validate
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' + 
                        ' @cCartonID, @cPalletID, @cLoadKey, @cLoc, @cOption, @tExtValidate, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT '

                     SET @cSQLParam =
                        ' @nMobile        INT,           ' +
                        ' @nFunc          INT,           ' +
                        ' @cLangCode      NVARCHAR( 3),  ' +
                        ' @nStep          INT,           ' +
                        ' @nInputKey      INT,           ' +
                        ' @cFacility      NVARCHAR( 5),  ' +
                        ' @cStorerKey     NVARCHAR( 15), ' +
                        ' @cCartonID      NVARCHAR( 20), ' +
                        ' @cPalletID      NVARCHAR( 20), ' +
                        ' @cLoadKey       NVARCHAR( 10), ' +
                        ' @cLoc           NVARCHAR( 10), ' +
                        ' @cOption        NVARCHAR( 1), ' +
                        ' @tExtValidate   VariableTable READONLY, ' + 
                        ' @nErrNo         INT           OUTPUT, ' +
                        ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                        @cCartonID, @cPalletID, @cLoadKey, @cPPS_Loc, @cOption, @tExtValidate, 
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0 
                        GOTO QUIT
                  END
               END

               -- (james02)
               -- Extended validate
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' + 
                        ' @cCartonID, @cPalletID, @cLoadKey, @cLoc, @cOption, @tExtUpdate, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT '

                     SET @cSQLParam =
                        ' @nMobile        INT,           ' +
                        ' @nFunc          INT,           ' +
                        ' @cLangCode      NVARCHAR( 3),  ' +
                        ' @nStep          INT,           ' +
                        ' @nInputKey      INT,           ' +
                        ' @cFacility      NVARCHAR( 5),  ' +
                        ' @cStorerKey     NVARCHAR( 15), ' +
                        ' @cCartonID      NVARCHAR( 20), ' +
                        ' @cPalletID      NVARCHAR( 20), ' +
                        ' @cLoadKey       NVARCHAR( 10), ' +
                        ' @cLoc           NVARCHAR( 10), ' +
                        ' @cOption        NVARCHAR( 1), ' +
                        ' @tExtUpdate     VariableTable READONLY, ' + 
                        ' @nErrNo         INT           OUTPUT, ' +
                        ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                        @cCartonID, @cPalletID, @cLoadKey, @cPPS_Loc, @cOption, @tExtUpdate, 
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0 
                        GOTO QUIT
                  END
               END

               IF @nErrNo <> 0
                  GOTO QUIT               

               SET @cUDF01 = @cCartonID
               SET @cUDF02 = @cLoadKey
               SET @cUDF03 = @cPPS_Loc
               SET @cUDF04 = @cPalletID

               IF EXISTS ( SELECT 1 FROM PACKHEADER (NOLOCK) 
                  WHERE OrderKey = @cOrderKey 
                     AND StorerKey = @cStorerKey 
                     AND ManifestPrinted <> '1'
               ) AND NOT EXISTS (SELECT 1 FROM PICKDETAIL (NOLOCK) 
               WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey AND Status < '5')
               AND EXISTS (SELECT 1 FROM ORDERS O (NOLOCK) 
               JOIN CODELKUP CL (NOLOCK) ON O.UserDefine03 = CL.Code AND CL.ListName = 'CSPACKSLIP' AND CL.StorerKey = @cStorerKey 
               WHERE O.OrderKey = @cOrderKey AND O.StorerKey = @cStorerKey 
               )
               BEGIN
                  SET @cOutField01 = @cOrderKey
                  SET @nAfterScn = 6818
                  SET @nAfterStep = 99
                  GOTO QUIT
               END

               IF ISNULL( @cPalletID, '') <> ''
               BEGIN
                  SET @cOutField01 = ''

                  -- Go to next screen
                  SET @nAfterScn = @nScn_ClosePallet
                  SET @nAfterStep = 99
                  GOTO Quit
               END

               -- Prepare next screen var
               SET @cOutField01 = @cCartonID
               SET @cOutField02 = @cLoadKey
               SET @cOutField03 = @cPPS_Loc
               SET @cOutField04 = ''

               -- Go to next screen
               SET @nAfterScn = @nScn_ToPallet
               SET @nAfterStep = 99

               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     DELETE FROM @tExtValidate
                     INSERT INTO @tExtValidate ( Variable, Value )
                     VALUES ( '@cDocType', @cDocType ),
                            ( '@cWAVEKey', @cWAVEKey ),
                            ( '@cConsigneeKey', @cConsigneeKey ),
                            ( '@nScn', CONCAT(@nAfterScn,'') )
                     SET @cExtendedInfo = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' + 
                        ' @cCartonID, @cPalletID, @cLoadKey, @cLoc, @cOption, @tExtValidate, ' +
                        ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '

                     SET @cSQLParam =
                        ' @nMobile        INT,           ' +
                        ' @nFunc          INT,           ' +
                        ' @cLangCode      NVARCHAR( 3),  ' +
                        ' @nStep          INT,           ' +
                        ' @nInputKey      INT,           ' +
                        ' @cFacility      NVARCHAR( 5),  ' +
                        ' @cStorerKey     NVARCHAR( 15), ' +
                        ' @cCartonID      NVARCHAR( 20), ' +
                        ' @cPalletID      NVARCHAR( 20), ' +
                        ' @cLoadKey       NVARCHAR( 10), ' +
                        ' @cLoc           NVARCHAR( 10), ' +
                        ' @cOption        NVARCHAR( 1), ' +
                        ' @tExtValidate   VariableTable READONLY, ' + 
                        ' @cExtendedInfo  NVARCHAR( 20) OUTPUT, ' +
                        ' @nErrNo         INT           OUTPUT, ' +
                        ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                        @cCartonID, @cPalletID, @cLoadKey, @cPPS_Loc, @cOption, @tExtValidate, 
                        @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                     BEGIN
                        GOTO QUIT
                     END
                  END
               END
            END
         END
         IF @nMOBRECScn = @nScn_ToPallet -- to Pallet
         BEGIN
            IF @nInputKey = 1
            BEGIN
               -- Prepare next screen var
               SET @cPalletID = @cInField04 

               IF ISNULL( @cPalletID, '') = ''
               BEGIN
                  SET @nErrNo = 144305
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Value req
                  GOTO QUIT  
               END

               IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'ID', @cPalletID) = 0  
               BEGIN
                  SET @nErrNo = 144306
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Invalid Format
                  GOTO QUIT  
               END

               -- Check if pallet id has inventory but not in PPS
               IF EXISTS ( SELECT 1 FROM dbo.LotxLocxID LLI WITH (NOLOCK) 
                           JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.LOC
                           WHERE LOC.Facility = @cFacility
                           AND   LOC.LocationCategory <> 'PPS'
                           AND   LLI.ID = @cPalletID
                           AND   QTY > 0)
               OR EXISTS (SELECT 1 FROM TASKDETAIL 
                           WHERE FromID = @cPalletID AND Status < '9'
                           AND SourceType = 'rdt_1837ExtScn02')
               BEGIN
                  SET @nErrNo = 144308
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --ID In Use
                  GOTO QUIT  
               END

               SET @cSQL = 
                     ' SELECT @cDocType = DocType,
                        @cWAVEKey = USERDEFINE09,
                        @cLoadKey = LoadKey,
                        @cConsigneeKey = ConsigneeKey
                     FROM ORDERS O WITH (NOLOCK)
                     JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey
                     WHERE PD.' + RTRIM( @cPickDetailCartonID) + '= @cCartonID
                     AND   O.StorerKey = @cStorerKey 
                     
                     SET @nRowCount = @@ROWCOUNT 
                     '

               SET @cSQLParam = 
                  ' @cStorerKey  NVARCHAR( 15), ' + 
                  ' @cCartonID   NVARCHAR( 20), ' + 
                  ' @cDocType   NVARCHAR( 10)   OUTPUT, ' + 
                  ' @cWAVEKey   NVARCHAR( 10)   OUTPUT, ' + 
                  ' @cLoadKey   NVARCHAR( 10)   OUTPUT, ' + 
                  ' @cConsigneeKey   NVARCHAR( 10)   OUTPUT, ' + 
                  ' @nRowCount   INT            OUTPUT '

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam
                  ,@cStorerKey
                  ,@cCartonID 
                  ,@cDocType OUTPUT
                  ,@cWAVEKey OUTPUT
                  ,@cLoadKey OUTPUT
                  ,@cConsigneeKey OUTPUT
                  ,@nRowCount OUTPUT

               IF @cDocType = 'E' --B2C
               BEGIN
                  IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE WAVEKEY = @cWAVEKey)
                  BEGIN
                     -- Check if the id already scanned to different loc
                     IF EXISTS ( SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK)
                                 WHERE ID = @cPalletID
                                 AND   Status = '1')
                     BEGIN
                        SET @nErrNo = 144307
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --ID In Use
                        GOTO QUIT  
                     END
                  END
                  ELSE IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE WAVEKEY = @cWAVEKey AND ID = @cPalletID AND Status = '9')
                  OR EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE WAVEKEY = @cWAVEKey AND ID <> @cPalletID AND ID <> '' AND STATUS < '9' )
                  BEGIN
                     SET @nErrNo = 256953
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Scan Another ID
                     GOTO QUIT
                  END
               END
               ELSE IF @cDocType = 'N' --B2B
               BEGIN
                  IF EXISTS (
                     SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                     WHERE PD.StorerKey = @cStorerKey
                     AND (
                        (@cPickDetailCartonID = 'DROPID' AND PD.DROPID = @cCartonID)
                        OR 
                        (@cPickDetailCartonID = 'CASEID' AND PD.CaseID = @cCartonID)
                     )
                     AND EXISTS (
                        SELECT 1 FROM PICKDETAIL PD1 
                        WHERE PD1.STATUS = '4' 
                        AND PD1.OrderKey = PD.OrderKey 
                        AND PD1.StorerKey = PD.StorerKey
                     )
                  )
                  BEGIN
                     IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = 'HOSPITAL' AND OrderKey = @cStorerKey)
                     BEGIN
                        IF EXISTS ( SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK)
                                 WHERE ID = @cPalletID
                                 AND   Status = '1')
                        BEGIN
                           SET @nErrNo = 144307
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --ID In Use
                           GOTO QUIT  
                        END
                     END
                     ELSE IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = 'HOSPITAL' AND OrderKey = @cStorerKey AND STATUS = '9' AND ID = @cPalletID)
                     OR EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE  LoadKey = 'HOSPITAL' AND OrderKey = @cStorerKey AND ID <> @cPalletID AND ID <> '' AND STATUS < '9' )
                     BEGIN
                        SET @nErrNo = 256953
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Scan Another ID
                        GOTO QUIT
                     END
                  END
                  ELSE
                  BEGIN -- ALL 5
                     IF NOT EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND ConsigneeKey = @cConsigneeKey)
                     BEGIN
                        IF EXISTS ( SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK)
                                 WHERE ID = @cPalletID
                                 AND   Status = '1')
                        BEGIN
                           SET @nErrNo = 144307
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --ID In Use
                           GOTO QUIT  
                        END
                     END
                     ELSE IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND ConsigneeKey = @cConsigneeKey AND STATUS = '9' AND ID = @cPalletID)
                     OR EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE LoadKey = @cLoadKey AND ConsigneeKey = @cConsigneeKey AND ID <> @cPalletID AND ID <> '' AND STATUS < '9' )
                     BEGIN
                        SET @nErrNo = 256953
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --Scan Another ID
                        GOTO QUIT
                     END
                  END
               END

               EXEC rdt.rdt_PostPackSort_Confirm
                  @nMobile             = @nMobile,    
                  @nFunc               = @nFunc,    
                  @cLangCode           = @cLangCode,    
                  @cStorerKey          = @cStorerKey,    
                  @cFacility           = @cFacility,     
                  @cCartonID           = @cCartonID, 
                  @cPalletID           = @cPalletID, 
                  @cLoadKey            = @cLoadKey, 
                  @cLoc                = @cPPS_Loc, 
                  @cOption             = @cOption, 
                  @cPickDetailCartonID = @cPickDetailCartonID,    
                  @tPostPackSortCfm    = @tPostPackSortCfm,    
                  @nErrNo              = @nErrNo            OUTPUT,    
                  @cErrMsg             = @cErrMsg           OUTPUT 
               
               IF @nErrNo <> 0
                  GOTO QUIT

               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' + 
                        ' @cCartonID, @cPalletID, @cLoadKey, @cLoc, @cOption, @tExtUpdate, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT '

                     SET @cSQLParam =
                        ' @nMobile        INT,           ' +
                        ' @nFunc          INT,           ' +
                        ' @cLangCode      NVARCHAR( 3),  ' +
                        ' @nStep          INT,           ' +
                        ' @nInputKey      INT,           ' +
                        ' @cFacility      NVARCHAR( 5),  ' +
                        ' @cStorerKey     NVARCHAR( 15), ' +
                        ' @cCartonID      NVARCHAR( 20), ' +
                        ' @cPalletID      NVARCHAR( 20), ' +
                        ' @cLoadKey       NVARCHAR( 10), ' +
                        ' @cLoc           NVARCHAR( 10), ' +
                        ' @cOption        NVARCHAR( 1), ' +
                        ' @tExtUpdate     VariableTable READONLY, ' + 
                        ' @nErrNo         INT           OUTPUT, ' +
                        ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                        @cCartonID, @cPalletID, @cLoadKey, @cPPS_Loc, @cOption, @tExtUpdate, 
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0 
                        GOTO Quit
                  END
               END

               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     DELETE FROM @tExtValidate
                     INSERT INTO @tExtValidate ( Variable, Value )
                     VALUES ( '@cDocType', @cDocType ),
                            ( '@cWAVEKey', @cWAVEKey ),
                            ( '@cConsigneeKey', @cConsigneeKey ),
                            ( '@nScn', CONCAT(@nMOBRECScn,'') )
                     SET @cExtendedInfo = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' + 
                        ' @cCartonID, @cPalletID, @cLoadKey, @cLoc, @cOption, @tExtValidate, ' +
                        ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '

                     SET @cSQLParam =
                        ' @nMobile        INT,           ' +
                        ' @nFunc          INT,           ' +
                        ' @cLangCode      NVARCHAR( 3),  ' +
                        ' @nStep          INT,           ' +
                        ' @nInputKey      INT,           ' +
                        ' @cFacility      NVARCHAR( 5),  ' +
                        ' @cStorerKey     NVARCHAR( 15), ' +
                        ' @cCartonID      NVARCHAR( 20), ' +
                        ' @cPalletID      NVARCHAR( 20), ' +
                        ' @cLoadKey       NVARCHAR( 10), ' +
                        ' @cLoc           NVARCHAR( 10), ' +
                        ' @cOption        NVARCHAR( 1), ' +
                        ' @tExtValidate   VariableTable READONLY, ' + 
                        ' @cExtendedInfo  NVARCHAR( 20) OUTPUT, ' +
                        ' @nErrNo         INT           OUTPUT, ' +
                        ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                        @cCartonID, @cPalletID, @cLoadKey, @cPPS_Loc, @cOption, @tExtValidate, 
                        @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                     BEGIN
                        GOTO QUIT
                     END
                  END
               END
            END
            -- Prepare next screen var
            SET @cOutField01 = '' 
            SET @cOutField02 = '' 
            --SET @cOutField15 = @cExtendedInfo

            EXEC rdt.rdtSetFocusField @nMobile, 1

            SET @nAfterStep = 99
            SET @nAfterScn = @nScn_FromCarton
            GOTO QUIT
         END
         IF @nMOBRECScn = @nScn_ClosePallet
         BEGIN
            IF @nInputKey = 1
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField01

               -- Validate blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 144309
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OptionRequired
                  GOTO QUIT
               END

               -- Validate option
               IF @cOption <> '1' AND @cOption <> '2'
               BEGIN
                  SET @nErrNo = 144310
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO QUIT
               END

               IF @cOption = '1'  -- Yes
               BEGIN
                  SELECT @cPPS_LOC = LOC FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE @cPalletID = ID AND [Status] = '1'
                  SELECT TOP 1 @cWaveKey = O.USERDEFINE09,@cDocType = O.DocType FROM ORDERS O WITH (NOLOCK)
                  JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey
                  WHERE PD.ID = @cPalletID AND PD.StorerKey = @cStorerKey
                  ORDER BY PD.EditDate DESC

                  --HOSPITAL PALLET
                  IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH (NOLOCK) WHERE @cPalletID = ID AND [Status] = '1' AND LoadKey = 'HOSPITAL')
                  BEGIN 
                     SELECT TOP 1 @cToLoc = LOC.LOC 
                     FROM LOC LOC (NOLOCK)
                     LEFT JOIN LotxLocxID LLI (NOLOCK) ON LOC.LOC = LLI.LOC AND LLI.StorerKey = @cStorerKey AND (QTY - QtyPicked>0)
                     WHERE LOC.Facility = @cFacility
                     AND LOC.LocationType = 'HOSP'
                     GROUP BY LOC.LOC
                     HAVING COUNT(DISTINCT LLI.ID) < MAX(LOC.MaxPallet)
                     ORDER BY LOC.LOC

                     IF ISNULL(@cToLoc,'') = ''
                     BEGIN
                        SET @nErrNo = 256955
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No QC Location
                        GOTO QUIT
                     END

                     -- Get new TaskDetailKeys      
                     SET @nSuccess = 1
                     EXECUTE dbo.nspg_getkey      
                        'TASKDETAILKEY'      
                        , 10      
                        , @cNewTaskDetailKey OUTPUT      
                        , @nSuccess          OUTPUT      
                        , @nErrNo            OUTPUT      
                        , @cErrMsg           OUTPUT      
                     IF @nSuccess <> 1      
                     BEGIN      
                        SET @nErrNo = 233355      
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey      
                        GOTO Quit      
                     END

                     SET @cPriority = '9'
                     -- Insert final task
                     INSERT INTO TaskDetail (
                        TaskDetailKey, TaskType, Status, UserKey, FromLOC, LogicalFromLoc, FromID, ToLOC, LogicalToLoc, ToID, 
                        QTY, CaseID, AreaKey, UOMQty, PickMethod, StorerKey, SKU, LOT, ListKey, SourceType, SourceKey, WaveKey, 
                        Priority, TrafficCop)
                     VALUES (
                        @cNewTaskDetailKey, 'ASTMV', '0', '', @cPPS_Loc, @cPPS_Loc, @cPalletID, @cToLoc, @cToLoc, @cPalletID, 
                        0, '', '', 0, 'FP', @cStorerKey, '', '',  '', 'rdt_1837ExtScn02',  '', @cWaveKey, 
                        @cPriority, NULL)
                  END
                  --B2B PALLET TO VAS:
                  ELSE IF EXISTS (SELECT 1 FROM PickDetail PD (NOLOCK) 
                  JOIN WorkOrderDetail WOD (NOLOCK) ON PD.OrderKey = WOD.Externworkorderkey AND PD.OrderLineNumber = WOD.Externlineno AND WOD.reason LIKE '%VAS%'
                  WHERE PD.ID = @cPalletID AND PD.Status = '5' AND PD.StorerKey = @cStorerKey)
                  OR --B2B PALLET TO OUTBOUND AUDIT
                  EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) 
                  JOIN ORDERS O (NOLOCK) ON PD.OrderKey = O.OrderKey AND PD.StorerKey = O.StorerKey
                  JOIN PICKHEADER PH (NOLOCK) ON O.OrderKey = PH.OrderKey AND O.StorerKey = PH.StorerKey
                  JOIN PACKINFO PI (NOLOCK) ON PI.PickSlipNo = PH.PickHeaderKey AND CartonStatus = 'PENDAUDIT'
                  WHERE PD.ID = @cPalletID AND PD.STATUS = '5' AND PD.StorerKey = @cStorerKey)
                  OR --UPS Label
                  EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) 
                  JOIN ORDERS O (NOLOCK) ON PD.OrderKey = O.OrderKey AND PD.StorerKey = O.StorerKey AND O.DocType = 'N' AND O.ShipperKey = 'UPS'
                  WHERE PD.ID = @cPalletID AND PD.STATUS = '5' AND PD.StorerKey = @cStorerKey)
                  BEGIN
                     SELECT TOP 1 @cToLoc = LOC.LOC 
                     FROM LOC LOC (NOLOCK)
                     LEFT JOIN LotxLocxID LLI (NOLOCK) ON LOC.LOC = LLI.LOC AND LLI.StorerKey = @cStorerKey
                     WHERE LOC.Facility = @cFacility
                     AND LOC.LocationType = 'VAS'
                     GROUP BY LOC.LOC
                     HAVING COUNT(DISTINCT LLI.ID) < MAX(LOC.MaxPallet)
                     ORDER BY LOC.LOC

                     -- Get new TaskDetailKeys      
                     SET @nSuccess = 1
                     EXECUTE dbo.nspg_getkey      
                        'TASKDETAILKEY'      
                        , 10      
                        , @cNewTaskDetailKey OUTPUT      
                        , @nSuccess          OUTPUT      
                        , @nErrNo            OUTPUT      
                        , @cErrMsg           OUTPUT      
                     IF @nSuccess <> 1      
                     BEGIN      
                        SET @nErrNo = 233355      
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey      
                        GOTO Quit      
                     END

                     SET @cPriority = '9'
                     -- Insert final task
                     INSERT INTO TaskDetail (
                        TaskDetailKey, TaskType, Status, UserKey, FromLOC, LogicalFromLoc, FromID, ToLOC, LogicalToLoc, ToID, 
                        QTY, CaseID, AreaKey, UOMQty, PickMethod, StorerKey, SKU, LOT, ListKey, SourceType, SourceKey, WaveKey, 
                        Priority, TrafficCop)
                     VALUES (
                        @cNewTaskDetailKey, 'ASTMV', '0', '', @cPPS_Loc, @cPPS_Loc, @cPalletID, @cToLoc, @cToLoc, @cPalletID, 
                        0, '', '', 0, 'FP', @cStorerKey, '', '',  '', 'rdt_1837ExtScn02',  '', @cWaveKey, 
                        @cPriority, NULL)
                  END
                  --B2B PALLET TO MARSHALLING LANE
                  ELSE IF EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) 
                  JOIN ORDERS O (NOLOCK) ON PD.OrderKey = O.OrderKey AND PD.StorerKey = O.StorerKey AND O.DocType <> 'E'
                  JOIN MBOL M (NOLOCK) ON O.MBOLKey = M.MBOLKey
                  WHERE PD.ID = @cPalletID AND PD.STATUS = '5' AND PD.StorerKey = @cStorerKey AND M.PlaceOfLoading <> '')
                  BEGIN
                     SELECT TOP 1 @cToLoc = M.PlaceOfLoading
                     FROM PICKDETAIL PD (NOLOCK) 
                     JOIN ORDERS O (NOLOCK) ON PD.OrderKey = O.OrderKey AND PD.StorerKey = O.StorerKey
                     JOIN MBOL M (NOLOCK) ON O.MBOLKey = M.MBOLKey
                     WHERE PD.ID = @cPalletID AND PD.STATUS = '5' AND PD.StorerKey = @cStorerKey AND M.PlaceOfLoading <> ''

                     -- Get new TaskDetailKeys      
                     SET @nSuccess = 1
                     EXECUTE dbo.nspg_getkey      
                        'TASKDETAILKEY'      
                        , 10      
                        , @cNewTaskDetailKey OUTPUT      
                        , @nSuccess          OUTPUT      
                        , @nErrNo            OUTPUT      
                        , @cErrMsg           OUTPUT      
                     IF @nSuccess <> 1      
                     BEGIN      
                        SET @nErrNo = 233355      
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey      
                        GOTO Quit      
                     END

                     SET @cPriority = '9'
                     -- Insert final task
                     INSERT INTO TaskDetail (
                        TaskDetailKey, TaskType, Status, UserKey, FromLOC, LogicalFromLoc, FromID, ToLOC, LogicalToLoc, ToID, 
                        QTY, CaseID, AreaKey, UOMQty, PickMethod, StorerKey, SKU, LOT, ListKey, SourceType, SourceKey, WaveKey, 
                        Priority, TrafficCop)
                     VALUES (
                        @cNewTaskDetailKey, 'ASTMV', '0', '', @cPPS_Loc, @cPPS_Loc, @cPalletID, @cToLoc, @cToLoc, @cPalletID, 
                        0, '', '', 0, 'FP', @cStorerKey, '', '',  '', 'rdt_1837ExtScn02',  '', @cWaveKey, 
                        @cPriority, NULL)
                  END
                  ELSE IF EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) 
                  JOIN ORDERS O (NOLOCK) ON PD.OrderKey = O.OrderKey AND PD.StorerKey = O.StorerKey AND O.DocType <> 'E'
                  WHERE PD.ID = @cPalletID AND PD.STATUS = '5' AND PD.StorerKey = @cStorerKey)
                  --B2B PALLET TO PACK & HOLD LOCATION:
                  BEGIN
                     SELECT @cLoadKey = LoadKey
                     FROM RDT.rdtSortLaneLocLog WITH (NOLOCK)
                     WHERE ID = @cPalletID AND STATUS = '1'

                     -- Find friend ( same loadkey)
                     SELECT TOP 1 @cToLoc = TD.ToLoc
                     FROM dbo.TaskDetail TD WITH (NOLOCK)
                     JOIN dbo.LOC LOC WITH (NOLOCK) ON ( TD.ToLoc = LOC.Loc)
                     WHERE TD.LoadKey = @cLoadKey
                     AND   TD.[Status] < '9'
                     AND   TD.TaskType = 'ASTMV'
                     AND   TD.Storerkey = @cStorerKey
                     AND   TD.PickMethod = 'FP'
                     AND   LOC.LocationCategory = 'PACK&HOLD'
                     AND   LOC.Facility = @cFacility
                     AND   LOC.STATUS = 'OK'
                     GROUP BY LOC.PALogicalLoc, TD.ToLoc, LOC.MaxPallet
                     HAVING LOC.MaxPallet >= ( COUNT( DISTINCT TD.ToID) + 1)
                     ORDER BY LOC.PALogicalLoc, TD.ToLoc
                     
                     IF ISNULL( @cToLoc, '') = ''
                        -- Search Empty Location 
                        SELECT TOP 1 @cToLoc = LOC.LOC
                        FROM LOC LOC WITH (NOLOCK)
                        LEFT OUTER JOIN LOTxLOCxID LLI WITH (NOLOCK) ON ( LOC.loc = LLI.LOC ) 
                        WHERE LOC.Facility = @cFacility
                        AND   LOC.LocationCategory = 'PACK&HOLD'
                        AND   LOC.LOC <> @cPPS_Loc
                        AND   LOC.STATUS = 'OK'
                        GROUP BY LOC.PALogicalLoc, LOC.LOC
                        HAVING ISNULL(SUM(LLI.QTY+LLI.PendingMoveIn),0)  = 0 
                        ORDER BY LOC.PALogicalLoc, LOC.Loc

                     IF ISNULL( @cToLoc, '') = ''
                     BEGIN
                        SET @nErrNo = 144404
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Pack&Hold
                        GOTO QUIT
                     END  

                     -- Booking
                     SET @nPABookingKey = 0
                     EXEC rdt.rdt_Putaway_PendingMoveIn 
                        @cUserName     = @cUserName
                     ,@cType         = 'LOCK'
                     ,@cFromLOC      = @cPPS_Loc
                     ,@cFromID       = @cPalletID
                     ,@cSuggestedLOC = @cToLOC
                     ,@cStorerKey    = @cStorerKey
                     ,@nErrNo        = @nErrNo  OUTPUT
                     ,@cErrMsg       = @cErrMsg OUTPUT
                     ,@cSKU          = ''
                     ,@nPutawayQTY   = 0
                     ,@cUCCNo        = ''
                     ,@cFromLOT      = ''
                     ,@cToID         = @cPalletID
                     ,@cTaskDetailKey = ''
                     ,@nFunc         = @nFunc
                     ,@nPABookingKey = @nPABookingKey OUTPUT

                     IF @nErrNo <> 0
                     BEGIN
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                        GOTO QUIT
                     END
                  
                     SELECT @nSuccess = 1  
                     EXECUTE dbo.nspg_getkey  
                        @KeyName       = 'TaskDetailKey',
                        @fieldlength   = 10,
                        @keystring     = @cTaskdetailkey   OUTPUT,
                        @b_Success     = @nSuccess         OUTPUT,
                        @n_err         = @nErrNo           OUTPUT,
                        @c_errmsg      = @cErrMsg          OUTPUT  

                     IF NOT @nSuccess = 1 OR ISNULL( @cTaskdetailkey, '') = ''
                     BEGIN
                        SET @nErrNo = 144405
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail
                        GOTO QUIT
                     END

                     INSERT dbo.TASKDETAIL 
                     ( TaskDetailKey, TaskType, Storerkey, Sku, UOM, UOMQty, Qty, SystemQty, Lot,
                     FromLoc, FromID, ToLoc, ToID, SourceType,SourceKey, Priority, SourcePriority,
                     Status, LogicalFromLoc, LogicalToLoc, PickMethod, LoadKey,WAVEKEY)  
                     VALUES  
                     ( @cTaskdetailkey, 'ASTMV', @cStorerkey, '', '', 0, 0, 0, '', 
                     @cPPS_Loc, @cPalletID, @cToLoc, @cPalletID, 'rdt_1837ExtScn02', '', '5', '9',
                     '0', @cPPS_Loc, @cToLoc, 'FP', @cLoadKey,@cWaveKey)
                           
                     IF @@ERROR <> 0  
                     BEGIN
                        SET @nErrNo = 144406
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CreatePATaskFail
                        GOTO QUIT
                     END       
                  END

                  UPDATE rdt.rdtSortLaneLocLog WITH (ROWLOCK) SET 
                     Status = '9'
                  WHERE ID = @cPalletID
                  AND   [Status] = '1'
               END
            END

            SET @cErrMsg01 = ''
            SET @cErrMsg02 = ''
            SET @cErrMsg03 = ''
            SET @cErrMsg01 = 'Pallet Closed'
            SET @cErrMsg02 = 'Successfully'
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
                  @cErrMsg01, @cErrMsg02, @cErrMsg03

            -- Prepare next screen var
            SET @cOutField01 = '' 
            SET @cOutField02 = '' 

            EXEC rdt.rdtSetFocusField @nMobile, 1

            -- Go to next screen
            SET @nAfterScn = @nScn_FromCarton
            SET @nAfterStep = 99
         END
      END
   END -- nFunc = 1837

   GOTO Quit

Quit:
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Exiting rdt_1837ExtScn02'
      SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nAfterScn AS AfterScn, @nAfterStep AS AfterStep
   END

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_1837ExtScn02] TO NSQL
GO