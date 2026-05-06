SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1856CaptureInf02                                   */
/* Copyright      : Mearsk WMS                                             */
/* Customer       : INDIGO AVIATION                                        */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2025-11-24 1.0  NickT   FCR-8525. Created                               */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1856CaptureInf02](
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cType        NVARCHAR( 10),
   @cMBOLKey     NVARCHAR( 10),
   @cOrderkey    NVARCHAR( 10),
   @cLoadKey     NVARCHAR( 10),
   @cRefNo1      NVARCHAR( 20),
   @cRefNo2      NVARCHAR( 20),
   @cRefNo3      NVARCHAR( 20),
   @cData1       NVARCHAR( 60),
   @cData2       NVARCHAR( 60),
   @cData3       NVARCHAR( 60),
   @cData4       NVARCHAR( 60),
   @cData5       NVARCHAR( 60),
   @cInField01   NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,
   @cInField02   NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,
   @cInField03   NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,
   @cInField04   NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,
   @cInField05   NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,
   @cInField06   NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,
   @cInField07   NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,
   @cInField08   NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,
   @cInField09   NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,
   @cInField10   NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,
   @cInField11   NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,
   @cInField12   NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,
   @cInField13   NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,
   @cInField14   NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,
   @cInField15   NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,
   @tCaptureVar  VariableTable READONLY,
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCode          NVARCHAR( 10)
   DECLARE @cLabel         NVARCHAR( 20)
   DECLARE @cColumn        NVARCHAR( 20)
   DECLARE @cListName      NVARCHAR( 10)
   DECLARE @cData          NVARCHAR( 20)
   DECLARE @nCursorPos     INT
   DECLARE @curData        CURSOR
   DECLARE @cExternMbolKey NVARCHAR( 30)
   DECLARE @cFieldName     NVARCHAR( 100)
   DECLARE @cFieldValue    NVARCHAR( 100)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   
   IF @cType = 'DISPLAY'
   BEGIN
      SELECT @cInField01 = '', @cOutField01 = ''
      SELECT @cInField02 = '', @cOutField02 = ''
      SELECT @cInField03 = '', @cOutField03 = ''
      SELECT @cInField04 = '', @cOutField04 = ''
      SELECT @cInField05 = '', @cOutField05 = ''
      SELECT @cInField06 = '', @cOutField06 = ''
      SELECT @cInField07 = '', @cOutField07 = ''
      SELECT @cInField08 = '', @cOutField08 = ''
      SELECT @cInField09 = '', @cOutField09 = ''
      SELECT @cInField10 = '', @cOutField10 = ''
      
      SET @cFieldAttr02 = 'O'
      SET @cFieldAttr04 = 'O'
      SET @cFieldAttr06 = 'O'
      SET @cFieldAttr08 = 'O'
      SET @cFieldAttr10 = 'O'

      SET @curData = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT Code, Notes, UDF01, Long
         FROM dbo.CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'RDTExtUpd'
            AND Storerkey = @cStorerKey
            AND Code2 = @nFunc
         ORDER BY Code
      OPEN @curData
      FETCH NEXT FROM @curData INTO @cCode, @cLabel, @cListName, @cFieldName
      WHILE @@FETCH_STATUS = 0
      BEGIN
         IF ISNULL( @cLabel, '') <> ''
         BEGIN
            IF @cCode = '1' SELECT @cOutField01 = @cLabel, @cFieldAttr02 = '' ELSE
            IF @cCode = '2' SELECT @cOutField03 = @cLabel, @cFieldAttr04 = '' ELSE
            IF @cCode = '3' SELECT @cOutField05 = @cLabel, @cFieldAttr06 = '' ELSE
            IF @cCode = '4' SELECT @cOutField07 = @cLabel, @cFieldAttr08 = '' ELSE
            IF @cCode = '5' SELECT @cOutField09 = @cLabel, @cFieldAttr10 = ''

            -- Get default value from CodeLKUP
            IF ISNULL( @cFieldName, '') <> ''
            BEGIN
               SET @cFieldValue = ''
               -- Get from ORDERS table
               SET @cSQL =
                  ' SELECT TOP 1 @cFieldValue = ORM.' +  @cFieldName   +
                  ' FROM dbo.ORDERS ORM WITH(NOLOCK) '    +
                  ' INNER JOIN dbo.MBOLDetail MD WITH(NOLOCK) ' +
                  '   ON ORM.OrderKey = MD.OrderKey ' +
                  ' WHERE StorerKey =  @cStorerKey ' +
                  '   AND MD.MbolKey = @cMBOLKey ' +
                  ' ORDER BY MD.EditDate DESC '

               SET @cSQLParam =
                  ' @cFieldValue          NVARCHAR( 100) OUTPUT, '   +
                  ' @cStorerKey           NVARCHAR( 15), '            +
                  ' @cMBOLKey             NVARCHAR( 10) '

               BEGIN TRY
                  EXEC sp_executesql @cSQL, @cSQLParam,
                     @cFieldValue = @cFieldValue OUTPUT,
                     @cStorerKey = @cStorerKey,
                     @cMBOLKey   = @cMBOLKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 252051
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Run SQL Script Failed
                  GOTO Quit
               END CATCH
            
               -- Set default value
               IF @cFieldValue <> ''
               BEGIN
                  IF @cCode = '1' SELECT @cOutField02 = @cFieldValue ELSE
                  IF @cCode = '2' SELECT @cOutField04 = @cFieldValue ELSE
                  IF @cCode = '3' SELECT @cOutField06 = @cFieldValue ELSE
                  IF @cCode = '4' SELECT @cOutField08 = @cFieldValue ELSE
                  IF @cCode = '5' SELECT @cOutField10 = @cFieldValue
               END
            END
         END

         FETCH NEXT FROM @curData INTO @cCode, @cLabel, @cListName, @cFieldName
      END
      
      IF @nErrNo = 0
      BEGIN
         -- Position on 1st empty field
         IF @cFieldAttr02 = '' EXEC rdt.rdtSetFocusField @nMobile, 2  ELSE
         IF @cFieldAttr04 = '' EXEC rdt.rdtSetFocusField @nMobile, 4  ELSE
         IF @cFieldAttr06 = '' EXEC rdt.rdtSetFocusField @nMobile, 6  ELSE
         IF @cFieldAttr08 = '' EXEC rdt.rdtSetFocusField @nMobile, 8  ELSE
         IF @cFieldAttr10 = '' EXEC rdt.rdtSetFocusField @nMobile, 10
      END 
   END
   
   IF @cType = 'UPDATE'
   BEGIN
      -- Construct update columns TSQL
      SET @curData = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT Code, Notes, UDF01, Long
         FROM dbo.CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'RDTExtUpd'
            AND Storerkey = @cStorerKey
            AND Code2 = @nFunc
         ORDER BY Code

      OPEN @curData
      FETCH NEXT FROM @curData INTO @cCode, @cLabel, @cListName, @cFieldName
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Check require field
         IF @cCode <> ''
         BEGIN
            -- Get data
            IF @cCode = '1' SELECT @cData = @cData1, @nCursorPos = 2  ELSE
            IF @cCode = '2' SELECT @cData = @cData2, @nCursorPos = 4  ELSE
            IF @cCode = '3' SELECT @cData = @cData3, @nCursorPos = 6  ELSE
            IF @cCode = '4' SELECT @cData = @cData4, @nCursorPos = 8  ELSE
            IF @cCode = '5' SELECT @cData = @cData5, @nCursorPos = 10 
            
            -- Check blank
            IF ISNULL( @cData, '') = ''
            BEGIN
               SET @nErrNo = 252052
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Data is required
               EXEC rdt.rdtSetFocusField @nMobile, @nCursorPos
               GOTO Quit
            END

            -- Build update column TSQL
            IF ISNULL( @cFieldName, '') <> ''
               SET @cSQL = @cSQL + @cFieldName + ' = @cData' + @cCode + ', '
         END

         FETCH NEXT FROM @curData INTO @cCode, @cLabel, @cListName, @cFieldName
      END

      IF @cSQL <> ''
      BEGIN
         SET @cSQL = 
            ' UPDATE dbo.ORDERS SET ' + 
               @cSQL + 
               ' EditDate = GETDATE(), ' + 
               ' EditWho = SUSER_SNAME() ' + 
            ' WHERE OrderKey = @cOrderKey '

         SET @cSQLParam = 
            ' @cOrderKey   NVARCHAR(10), ' + 
            ' @cData1      NVARCHAR(60), ' + 
            ' @cData2      NVARCHAR(60), ' + 
            ' @cData3      NVARCHAR(60), ' + 
            ' @cData4      NVARCHAR(60), ' + 
            ' @cData5      NVARCHAR(60) '

         BEGIN TRY
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam 
               ,@cOrderKey
               ,@cData1
               ,@cData2
               ,@cData3
               ,@cData4
               ,@cData5
         END TRY
         BEGIN CATCH
            SET @nErrNo = 252053
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  -- Update PickDetail Failed
            GOTO Quit
         END CATCH
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1856CaptureInf02 TO NSQL
GO