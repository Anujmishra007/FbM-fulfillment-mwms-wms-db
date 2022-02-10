IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_JobCapture_Confirm]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_JobCapture_Confirm]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/    
/* Store procedure: rdt_JobCapture_Confirm                              */    
/* Copyright      : LFLogistics                                         */    
/*                                                                      */    
/* Date       Rev  Author    Purposes                                   */    
/* 30-08-2018 1.0  Ung       WMS-6051 Created                           */    
/* 13-02-2019 1.1  James     WMS-7795 Add capture reference (james01)   */    
/* 11-04-2019 1.2  James     WMS-8603 Add rdtstdeventlog.status = '3'   */     
/*                           when capture UDF (james02)                 */    
/* 02-07-2019 1.3  James     WMS-9493 Enhance UDF insert (james03)      */     
/* 16-08-2019 1.4  James     WMS-10170 Check duplicate records (james04)*/     
/* 04-03-2021 1.5  LZG       INC1440390 - Fixed bug (ZG01)              */ 
/* 10-09-2020 1.6  YeeKung   WMS-15084 Change username and loc length   */
/*                             (yeekung01)                              */ 
/* 24-09-2019 1.7  James     INC0844782-Bug fix on UDF insert (james05) */
/************************************************************************/    
    
      
CREATE PROC [RDT].[rdt_JobCapture_Confirm] (      
   @nMobile       INT,      
   @nFunc         INT,      
   @cLangCode     NVARCHAR( 3),      
   @nStep         INT,      
   @nInputKey     INT,      
   @cStorerKey    NVARCHAR( 15),       
   @cFacility     NVARCHAR( 5),       
   @cType         NVARCHAR( 10), -- START/END      
   @cUserID       NVARCHAR( 30) = '',  --(yeekung01)
   @cJobType      NVARCHAR( 20) = '', 
   @cLOC          NVARCHAR( 30) = '',  --(yeekung01)     
   @cQTY          NVARCHAR( 5)  = '',      
   @cStart        NVARCHAR( 10) = '' OUTPUT,       
   @cEnd          NVARCHAR( 10) = '' OUTPUT,       
   @cDuration     NVARCHAR( 5)  = '' OUTPUT,       
   @nErrNo        INT           = '' OUTPUT,      
   @cErrMsg       NVARCHAR( 20) = '' OUTPUT,      
   @cRef01        NVARCHAR( 60) = '',      
   @cRef02        NVARCHAR( 60) = '',      
   @cRef03        NVARCHAR( 60) = '',      
   @cRef04        NVARCHAR( 60) = '',      
   @cRef05        NVARCHAR( 60) = ''      
      
) AS      
BEGIN      
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
      
   DECLARE @nRowRef  INT      
   DECLARE @dStart   DATETIME      
   DECLARE @dEnd     DATETIME      
   DECLARE @nMinutes INT      
   DECLARE @cField01 NVARCHAR( 60)      
   DECLARE @cField02 NVARCHAR( 60)      
   DECLARE @cField03 NVARCHAR( 60)      
   DECLARE @cField04 NVARCHAR( 60)      
   DECLARE @cField05 NVARCHAR( 60)      
   DECLARE @cField   NVARCHAR( 60)      
   DECLARE @cRefVal  NVARCHAR( 60)      
   DECLARE @n        INT      
   DECLARE @cExtendedValidateSP NVARCHAR( 20),          
           @cCustomSQL          NVARCHAR( MAX),      
           @cStartSQL           NVARCHAR( MAX),      
           @cExcludeSQL         NVARCHAR( MAX),      
           @cEndSQL             NVARCHAR( MAX),      
           @cExecStatements     NVARCHAR( MAX),      
           @cExecArguments      NVARCHAR( MAX)      
         
   IF @cType = 'START'      
   BEGIN      
      IF EXISTS ( SELECT 1 FROM rdt.rdtWATLog WITH (NOLOCK)      
                  WHERE Module = 'JOBCAPTURE'      
                  AND   UserName = @cUserID      
                  AND   StorerKey = @cStorerKey      
                  AND   Facility = @cFacility      
                  AND   Status = '0')                  
      BEGIN      
         SET @nErrNo = 128555      
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Record Exists      
         GOTO Quit      
      END      
            
      SET @dStart = GETDATE()      
            
      INSERT INTO rdt.rdtWATLog (Module, UserName, TaskCode, Location, StartDate, EndDate, Status, StorerKey, Facility,      
                                 UDF01, UDF02, UDF03, UDF04, UDF05)      
      VALUES ('JOBCAPTURE', @cUserID, @cJobType, @cLOC, @dStart, @dStart, '0', @cStorerKey, @cFacility,      
     @cRef01, @cRef02, @cRef03, @cRef04, @cRef05)      
      SELECT @nRowRef = SCOPE_IDENTITY(), @nErrNo = @@ERROR      
      IF @@ERROR <> 0      
      BEGIN      
         SET @nErrNo = 128551      
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS LOG Fail      
         GOTO Quit      
      END      
      
      -- EventLog      
      EXEC RDT.rdt_STD_EventLog      
         @dtEventDateTime = @dStart,       
         @cActionType   = '3',      
         @cUserID         = @cUserID,      
         @nMobileNo       = @nMobile,      
         @nFunctionID     = @nFunc,      
         @cFacility       = @cFacility,      
         @cStorerKey      = @cStorerkey,       
         @cRefNo1         = @nRowRef,       
         @cRefNo2         = @cJobType,       
         @cLocation       = @cLOC,       
         @cStatus         = '0'      
      
      -- DD HH:MMAM      
      SET @cStart = SUBSTRING( CONVERT( NVARCHAR(30), @dStart, 0), 5, 2) + ' ' + RIGHT( CONVERT( NVARCHAR(20), @dStart, 0), 7)      
      SET @cEnd = ''      
      SET @cDuration = ''      
   END      
      
   ELSE IF @cType = 'UDF'      
   BEGIN      
      SET @dStart = GETDATE()      
            
      -- UDF type need insert multiple times, need check if it exists START already      
      IF NOT EXISTS (       
         SELECT 1      
         FROM rdt.rdtWATLog WITH (NOLOCK)      
         WHERE Module = 'JOBCAPTURE'      
            AND UserName = @cUserID      
            AND StorerKey = @cStorerKey      
            AND Facility = @cFacility      
            AND TaskCode = @cJobType      
            AND Status = '0'      
            AND (( UDF01 = '') OR ( UDF01 = @cRef01))  -- (james03)/(james05)
            AND (( UDF02 = '') OR ( UDF02 = @cRef02))
            AND (( UDF03 = '') OR ( UDF03 = @cRef03))
            AND (( UDF04 = '') OR ( UDF04 = @cRef04))
            AND (( UDF05 = '') OR ( UDF05 = @cRef05)))
      BEGIN      
         INSERT INTO rdt.rdtWATLog (Module, UserName, TaskCode, Location, StartDate, EndDate, Status, StorerKey, Facility,      
                                    UDF01, UDF02, UDF03, UDF04, UDF05)      
         VALUES ('JOBCAPTURE', @cUserID, @cJobType, @cLOC, @dStart, @dStart, '0', @cStorerKey, @cFacility,      
                  @cRef01, @cRef02, @cRef03, @cRef04, @cRef05)      
         SELECT @nRowRef = SCOPE_IDENTITY(), @nErrNo = @@ERROR      
         IF @@ERROR <> 0      
         BEGIN      
            SET @nErrNo = 128554      
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS LOG Fail      
            GOTO Quit      
         END      
      
         -- EventLog      
         EXEC RDT.rdt_STD_EventLog      
            @dtEventDateTime = @dStart,       
            @cActionType     = '3',      
            @cUserID         = @cUserID,      
            @nMobileNo       = @nMobile,      
            @nFunctionID     = @nFunc,      
            @cFacility       = @cFacility,      
            @cStorerKey      = @cStorerkey,       
            @cRefNo1         = @nRowRef,       
            @cRefNo2         = @cJobType,       
            @cLocation       = @cLOC,       
            @cStatus         = '0'      
      END      
      ELSE      
      BEGIN      
         SELECT TOP 1       
            @nRowRef = RowRef      
         FROM rdt.rdtWATLog WITH (NOLOCK)      
         WHERE Module = 'JOBCAPTURE'      
            AND UserName = @cUserID      
            AND StorerKey = @cStorerKey      
            AND Facility = @cFacility      
            AND TaskCode = @cJobType      
            AND Status = '0'      
         ORDER BY 1      
      END      
      
      -- Get job info      
      IF EXISTS (SELECT 1      
         FROM CodeLKUP WITH (NOLOCK)      
         WHERE ListName = 'JOBCapType'      
            AND Code = @cJobType      
            AND StorerKey = @cStorerKey      
            AND Code2 = @cFacility      
            AND UDF03 = '1')      
      BEGIN      
         SELECT @cField01 = UDF01,       
                @cField02 = UDF02,       
                @cField03 = UDF03,       
                @cField04 = UDF04,       
                @cField05 = UDF05      
         FROM dbo.CodeLKUP WITH (NOLOCK)      
         WHERE ListName = 'JOBCapCol'      
         AND   Code = @cJobType      
         AND   StorerKey = @cStorerKey      
         AND   Code2 = @cFacility      
      
         SET @n = 1      
         SET @cStartSQL = ''      
         SET @cCustomSQL = ''      
      
         WHILE @n < 6      
         BEGIN      
            IF @n = 1 SET @cField = @cField01      
            IF @n = 2 SET @cField = @cField02      
            IF @n = 3 SET @cField = @cField03      
            IF @n = 4 SET @cField = @cField04      
            IF @n = 5 SET @cField = @cField05      
      
            IF @n = 1 AND ISNULL( @cField01, '') <> '' SET @cRefVal = @cRef01      
  IF @n = 2 AND ISNULL( @cField02, '') <> '' SET @cRefVal = @cRef02      
            IF @n = 3 AND ISNULL( @cField03, '') <> '' SET @cRefVal = @cRef03      
            IF @n = 4 AND ISNULL( @cField04, '') <> '' SET @cRefVal = @cRef04      
            IF @n = 5 AND ISNULL( @cField05, '') <> '' SET @cRefVal = @cRef05      
      
            IF @cField <> ''      
            BEGIN      
               --SET @cCustomSQL = char(13) + ',@c' + @cCustomSQL + @cField + ' = ' + '''' + @cRefVal + ''''   -- ZG01      
               SET @cCustomSQL = @cCustomSQL + char(13) + ',@c' + @cField + ' = ' + '''' + @cRefVal + ''''     -- ZG01      
            END      
                  
            SET @n = @n + 1      
            SET @cField = ''      
         END      
      END      
      
      SET @cStartSQL = '      
        EXEC RDT.rdt_STD_EventLog      
            @dtEventDateTime = @dStart,       
            @cActionType     = ''3'',      
            @cUserID         = @cUserID,      
            @nMobileNo       = @nMobile,      
            @nFunctionID     = @nFunc,      
            @cFacility       = @cFacility,      
            @cStorerKey      = @cStorerkey,       
            @cRefNo1         = @nRowRef,       
            @cRefNo2         = @cJobType,       
            @cLocation       = @cLOC,       
            @cStatus         = ''3'' '      -- (james02)      
      
      SET @cExecStatements = @cStartSQL + @cCustomSQL       
      
      SET @cExecArguments =  N'@dStart          DATETIME,      ' +      
                              '@cUserID         NVARCHAR( 15), ' +      
                              '@nMobile         INT,  ' +       
                              '@nFunc           INT,  ' +      
                              '@cFacility       NVARCHAR( 5),  ' +      
                              '@cStorerkey      NVARCHAR( 15), ' +      
                              '@nRowRef         INT,  ' +      
                              '@cJobType        NVARCHAR( 20), ' +      
                              '@cLOC            NVARCHAR( 10)  '      
      
      EXEC sp_ExecuteSql @cExecStatements      
                        ,@cExecArguments      
                        ,@dStart      
                        ,@cUserID      
                        ,@nMobile      
                        ,@nFunc      
                        ,@cFacility      
                        ,@cStorerkey      
                        ,@nRowRef      
                        ,@cJobType      
                        ,@cLOC      
      -- DD HH:MMAM      
      SET @cStart = SUBSTRING( CONVERT( NVARCHAR(30), @dStart, 0), 5, 2) + ' ' + RIGHT( CONVERT( NVARCHAR(20), @dStart, 0), 7)      
      SET @cEnd = ''      
      SET @cDuration = ''      
   END      
            
   ELSE IF @cType = 'END'      
   BEGIN      
      -- Get job info      
      SELECT       
         @nRowRef = RowRef,       
         @dStart = StartDate      
      FROM rdt.rdtWATLog WITH (NOLOCK)      
      WHERE Module = 'JOBCAPTURE'      
         AND UserName = @cUserID      
         AND StorerKey = @cStorerKey      
         AND Facility = @cFacility    
         AND TaskCode = @cJobType      
         AND Status = '0'      
      
      -- Check missing start      
      IF @@ROWCOUNT =0  --(yeekung01)    
      BEGIN      
         SET @nErrNo = 128552      
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --REC NOT FOUND      
         GOTO Quit      
      END      
      
      SET @dEnd = GETDATE()      
  
      DECLARE c_Watlog CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT   
          RowRef  
      FROM rdt.rdtWATLog WITH (NOLOCK)  
      WHERE Module = 'JOBCAPTURE'  
         AND UserName = @cUserID  
         AND StorerKey = @cStorerKey  
         AND Facility = @cFacility  
         AND TaskCode = @cJobType  
         AND Status = '0'  
      OPEN c_Watlog        
      FETCH NEXT FROM c_Watlog INTO  @nRowRef        
      WHILE (@@FETCH_STATUS <> -1)        
      BEGIN        
           
         UPDATE rdt.rdtWATLog SET  
            Status = '9',   
            QTY = @cQTY,   
            EndDate = @dEnd,   
            EditWho = SUSER_SNAME(),   
            EditDate = @dEnd  
         WHERE RowRef = @nRowRef  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 128553  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS LOG Fail  
            GOTO Quit  
         END  
  
         -- EventLog  
         EXEC RDT.rdt_STD_EventLog  
            @dtEventDateTime = @dEnd,   
            @cActionType     = '3',  
            @cUserID         = @cUserID,  
            @nMobileNo       = @nMobile,  
            @nFunctionID     = @nFunc,  
            @cFacility       = @cFacility,  
            @cStorerKey      = @cStorerkey,   
            @cRefNo1         = @nRowRef,   
            @cRefNo2         = @cJobType,   
            @cLocation       = @cLOC,   
            @nQTY            = @cQTY,   
            @cStatus         = '9'  
  
         FETCH NEXT FROM c_Watlog INTO  @nRowRef        
        
      END        
      CLOSE c_Watlog        
      DEALLOCATE c_Watlog   
      -- DD HH:MMAM      
      SET @cStart = SUBSTRING( CONVERT( NVARCHAR(30), @dStart, 0), 5, 2) + ' ' + RIGHT( CONVERT( NVARCHAR(20), @dStart, 0), 7)      
      SET @cEnd = SUBSTRING( CONVERT( NVARCHAR(30), @dEnd, 0), 5, 2) + ' ' + RIGHT( CONVERT( NVARCHAR(20), @dEnd, 0), 7)      
      
      SELECT @nMinutes = DATEDIFF( mi, @dStart, @dEnd)            
            
      -- HH:MM      
      IF @nMinutes > 2435 -- 2535 = 99h:59m      
         SET @cDuration = '*'      
      ELSE      
         SET @cDuration = RIGHT( '0' + CAST( @nMinutes / 60 AS NVARCHAR(2)), 2) + ':' +  -- HH      
                          RIGHT( '0' + CAST( @nMinutes % 60 AS NVARCHAR(2)), 2)          -- MM      
   END      
      
Quit:      
      
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_JobCapture_Confirm] TO NSQL
GO