
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_AT_CheckIN_HY                                      */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author     Purposes                                     */
/* 2025-10-17 1.0  yeekung    FCR-8146 Created (copied from PI)            */
/* 2026-08-13 2.0  nick-tang  FCR-13165 HYFUN FOODS: added RDTVASLOG       */
/*                            status pre-validation at Step_2 for          */
/*                            Check-In (Status=4) and Check-Out (Status=3) */
/***************************************************************************/

CREATE OR ALTER PROC rdt.rdt_AT_CheckIN_HY (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cOption       NVARCHAR( 1),
   @cRef1         NVARCHAR( 20),
   @cInput01      NVARCHAR( 20),
   @cInput02      NVARCHAR( 20),
   @cInput03      NVARCHAR( 20),
   @cInput04      NVARCHAR( 20),
   @cActivityStatus NVARCHAR(20),
   @nStep         INT          OUTPUT,
   @nScn          INT          OUTPUT,
   @cOutField01  NVARCHAR( 20) OUTPUT,
   @cOutField02  NVARCHAR( 20) OUTPUT,
   @cOutField03  NVARCHAR( 20) OUTPUT,
   @cOutField04  NVARCHAR( 20) OUTPUT,
   @cOutField05  NVARCHAR( 20) OUTPUT,
   @cOutField06  NVARCHAR( 20) OUTPUT,
   @cOutField07  NVARCHAR( 20) OUTPUT,
   @cOutField08  NVARCHAR( 20) OUTPUT,
   @cOutField09  NVARCHAR( 20) OUTPUT,
   @cOutField10  NVARCHAR( 20) OUTPUT,
   @cOutField11  NVARCHAR( 20) OUTPUT,
   @cFieldAttr01  NVARCHAR( 1) OUTPUT,
   @cFieldAttr02  NVARCHAR( 1) OUTPUT,
   @cFieldAttr03  NVARCHAR( 1) OUTPUT,
   @cFieldAttr04  NVARCHAR( 1) OUTPUT,
   @cFieldAttr05  NVARCHAR( 1) OUTPUT,
   @cFieldAttr06  NVARCHAR( 1) OUTPUT,
   @cFieldAttr07  NVARCHAR( 1) OUTPUT,
   @cFieldAttr08  NVARCHAR( 1) OUTPUT,
   @cFieldAttr09  NVARCHAR( 1) OUTPUT,
   @cFieldAttr10  NVARCHAR( 1) OUTPUT,
   @cFieldAttr11  NVARCHAR( 1) OUTPUT,
   @cExtendedinfo NVARCHAR(20)  OUTPUT,
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cDoorBooking NVARCHAR(20),
           @cUserName    NVARCHAR(20),
           @cBookStatus  NVARCHAR(20),
           @cApptNO      NVARCHAR(20),
           @cNewStatus   NVARCHAR(20),
           @cLong        NVARCHAR(20),
           @cEventCode   NVARCHAR(20),
           @cMenuOption  NVARCHAR(1)
   DECLARE @cGroup       NVARCHAR(20)
   DECLARE @cLabel       NVARCHAR(20)
   DECLARE @nCounter     INT = 0
   DECLARE @nIsValid     INT = 0
   DECLARE @curLabel     CURSOR
   DECLARE @curSearch    CURSOR
   DECLARE @cUDF02       NVARCHAR(20)
   DECLARE @cColumnName  NVARCHAR(20)
   DECLARE @cTableName   NVARCHAR(20)
   DECLARE @nRowCount    INT
   DECLARE @cSQL         NVARCHAR( MAX)
   DECLARE @cSQLParam    NVARCHAR( MAX)
   DECLARE @curRD        CURSOR
   DECLARE @cReceiptKey  NVARCHAR(10)
   DECLARE @cLatestStatus NVARCHAR(1)    -- FCR-13165: latest RDTVASLOG Status for HYFUN validation

   SELECT @cUserName = username,
          @cMenuOption = V_string5
   FROM rdt.rdtmobrec (NOLOCK)
   WHERE mobile = @nMobile

   IF @nStep = 1
   BEGIN
      -- Get event to capture
      SELECT
         @cOutField01 = udf01,
         @cOutField04 = udf02,
         @cOutField05 = udf03
      FROM dbo.CodeLkup WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND ListName  = 'RDTAcTrack'
         AND code      = @cOption

      GOTO Quit
   END

   IF @nStep = 2
   BEGIN
      IF @nInputKey = '1'
      BEGIN

         -- FCR-13165: HYFUN FOODS pre-validation — check RDTVASLOG status before processing
         SELECT TOP 1 @cLatestStatus = Status
         FROM rdt.RDTVASLOG (NOLOCK)
         WHERE Ref1 = @cRef1
         ORDER BY AddDate DESC

         SET @cLatestStatus = ISNULL(@cLatestStatus, '')

         -- Check-In validation: latest RDTVASLOG Status must be 4 (Checked Out)
         IF @cOption = '1'
         BEGIN
            IF @cLatestStatus <> '4'
            BEGIN
               SET @nErrNo  = 278051
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- CtrNotChkOut
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit
            END
         END

         -- Check-Out validation: latest record must be End Unloading (Status=3)
         IF @cOption = '9'
         BEGIN
            IF @cLatestStatus <> '3'
            BEGIN
               SET @nErrNo  = 278052
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- CtrNotUnload
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit
            END
         END

         SET @curSearch = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT Code, Long
            FROM dbo.CodeLKUP WITH (NOLOCK)
            WHERE ListName  = 'REFNOLKUP'
               AND StorerKey = @cStorerKey
               AND Code2     = @cFacility
               AND Notes2    = @nFunc
            ORDER BY Short
         OPEN @curSearch
         FETCH NEXT FROM @curSearch INTO @cColumnName, @cTableName
         WHILE @@FETCH_STATUS = 0
         BEGIN

            -- Check column valid
            IF NOT EXISTS (SELECT 1
               FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME  = @cTableName
                  AND COLUMN_NAME = @cColumnName
                  AND DATA_TYPE   = 'nvarchar')
            BEGIN
               SET @nErrNo  = 278053
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid Table Column
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit
            END

            SET @cSQL =
               ' SELECT ' +
                  ' @cReceiptKey = Receipt.ReceiptKey ' +
               ' FROM dbo.Receipt Receipt WITH (NOLOCK)  LEFT JOIN ' +
               '      dbo.PO  PO WITH (NOLOCK) ON PO.POKey = Receipt.POKey AND PO.StorerKey = Receipt.StorerKey ' +
               ' WHERE Receipt.Facility = @cFacility ' +
                  ' AND Receipt.StorerKey = @cStorerKey ' +
                  ' AND ' + @cTableName + '.' + @cColumnName + ' = @cRef1 '

            SET @cSQLParam =
               ' @cFacility      NVARCHAR(5),  ' +
               ' @cStorerKey     NVARCHAR(15), ' +
               ' @cRef1          NVARCHAR(60) OUTPUT, ' +
               ' @cReceiptKey    NVARCHAR(10) OUTPUT, ' +
               ' @nRowCount      INT          OUTPUT, ' +
               ' @nErrNo         INT          OUTPUT  '
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @cFacility,
               @cStorerKey,
               @cRef1        OUTPUT,
               @cReceiptKey  OUTPUT,
               @nRowCount    OUTPUT,
               @nErrNo       OUTPUT

            IF @cReceiptKey <> ''
               BREAK

            FETCH NEXT FROM @curSearch INTO @cColumnName, @cTableName
         END
         CLOSE  @curSearch
         DEALLOCATE @curSearch

         IF ISNULL(@cReceiptKey, '') = ''
                  AND EXISTS (SELECT 1
                              FROM dbo.CodeLKUP WITH (NOLOCK)
                              WHERE ListName  = 'REFNOLKUP'
                                 AND StorerKey = @cStorerKey
                                 AND Code2     = @cFacility
                                 AND Notes2    = @nFunc
                                 AND UDF01     = '1')
         BEGIN
            SET @nErrNo  = 278054
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InvApptNo
            EXEC rdt.rdtSetFocusField @nMobile, 2
            GOTO Quit
         END

         SELECT TOP 1 @cBookStatus = Status
         FROM rdt.RDTVASLOG (NOLOCK)
         WHERE Ref1 = @cRef1
         ORDER BY AddDate DESC

         SET @cBookStatus = CASE WHEN ISNULL(@cBookStatus, '0') = '0' THEN '0'
                                 ELSE @cBookStatus
                            END

         IF NOT EXISTS (SELECT 1
               FROM dbo.CODELKUP (NOLOCK)
               WHERE Listname  = 'BkStatusI'
                  AND storerkey = @cStorerKey
                  AND Notes2    = @nFunc
                  AND code IN ('1', '4')
                  AND udf01     = @cBookStatus
                  AND notes     = @cActivityStatus
               )
         BEGIN
            SET @nErrNo  = 278055
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InvStatus
            EXEC rdt.rdtSetFocusField @nMobile, 2
            GOTO Quit
         END

         SELECT @cNewStatus = code
         FROM dbo.CODELKUP (NOLOCK)
         WHERE Listname  = 'BkStatusI'
            AND storerkey = @cStorerKey
            AND Notes2    = @nFunc
            AND code IN ('1', '4')
            AND @cBookStatus IN (udf01, udf02)
            AND notes = @cActivityStatus

         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutField04 = ''
         SET @cOutField05 = ''
         SET @cOutField06 = ''
         SET @cOutField07 = ''
         SET @cOutField08 = ''
         SET @cOutField09 = ''
         SET @cOutField10 = ''

         IF NOT EXISTS (SELECT 1
                        FROM dbo.CODELKUP (NOLOCK)
                        WHERE Listname  = 'RDTATrack'
                           AND StorerKey = @cStorerKey
                           AND UDF01     = @cNewStatus
                        )
         BEGIN

            BEGIN TRY
               INSERT INTO rdt.RDTVASLOG (Type, UserName, Facility, StartDate, EndDate, Status, qty, ref1)
               VALUES (@cActivityStatus, SUSER_SNAME(), @cFacility, GETDATE(), GETDATE(), @cNewStatus, 1, @cRef1)
            END TRY
            BEGIN CATCH
               SET @nErrNo  = 278056
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InsBEFail
               EXEC rdt.rdtSetFocusField @nMobile, 2
               GOTO Quit
            END CATCH

            IF @cActivityStatus = '1' -- Check IN
            BEGIN

               SET @curSearch = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT Code, Long
                  FROM dbo.CodeLKUP WITH (NOLOCK)
                  WHERE ListName  = 'REFNOLKUP'
                     AND StorerKey = @cStorerKey
                     AND Code2     = @cFacility
                     AND Notes2    = @nFunc
                  ORDER BY Short
               OPEN @curSearch
               FETCH NEXT FROM @curSearch INTO @cColumnName, @cTableName
               WHILE @@FETCH_STATUS = 0
               BEGIN

                  SET @cSQL =
                     ' SELECT ' +
                        ' Receipt.ReceiptKey ' +
                     ' FROM dbo.Receipt Receipt WITH (NOLOCK)  LEFT JOIN ' +
                     '      dbo.PO  PO WITH (NOLOCK) ON PO.POKey = Receipt.POKey AND PO.StorerKey = Receipt.StorerKey ' +
                     ' WHERE Receipt.Facility = @cFacility ' +
                        ' AND Receipt.StorerKey = @cStorerKey ' +
                        ' AND ' + @cTableName + '.' + @cColumnName + ' = @cRef1 '

                  -- Open cursor
                  SET @cSQL =
                     ' SET @curRD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' +
                        @cSQL +
                     ' OPEN @curRD '

                  SET @cSQLParam =
                     ' @curRD          CURSOR OUTPUT, ' +
                     ' @cFacility      NVARCHAR(5),  ' +
                     ' @cStorerKey     NVARCHAR(15), ' +
                     ' @cRef1          NVARCHAR(60) OUTPUT, ' +
                     ' @cReceiptKey    NVARCHAR(10) OUTPUT, ' +
                     ' @nErrNo         INT          OUTPUT  '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @curRD        OUTPUT,
                     @cFacility,
                     @cStorerKey,
                     @cRef1        OUTPUT,
                     @cReceiptKey  OUTPUT,
                     @nErrNo       OUTPUT

                  -- Loop Receipt
                  FETCH NEXT FROM @curRD INTO @cReceiptKey
                  WHILE @@FETCH_STATUS = 0
                  BEGIN

                     BEGIN TRY
                        UPDATE dbo.Receipt WITH (ROWLOCK)
                        SET ASNStatus = 'VA'
                        WHERE ReceiptKey = @cReceiptKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo  = 278057
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UpdRecptFail
                        GOTO Quit
                     END CATCH

                     FETCH NEXT FROM @curRD INTO @cReceiptKey
                  END
                  CLOSE  @curRD
                  DEALLOCATE @curRD

                  FETCH NEXT FROM @curSearch INTO @cColumnName, @cTableName
               END
               CLOSE  @curSearch
               DEALLOCATE @curSearch
            END

            SELECT @cGroup = OpsPosition
            FROM rdt.rdtuser (NOLOCK)
            WHERE USERNAME = @cUserName

            -- Prepare next screen var
            SELECT @cOutField01 = '1-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '1' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField02 = '2-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '2' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField03 = '3-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '3' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField04 = '4-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '4' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField05 = '5-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '5' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField06 = '6-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '6' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField07 = '7-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '7' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField08 = '8-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '8' AND CHARINDEX(@cGroup, short) <> '0'
            SELECT @cOutField09 = '9-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '9' AND CHARINDEX(@cGroup, short) <> '0'

            SET @nStep = @nStep - 1
            SET @nScn  = @nScn  - 1

            GOTO Quit

         END
         ELSE
         BEGIN
            SET @cFieldAttr04 = 'O'
            SET @cFieldAttr06 = 'O'
            SET @cFieldAttr08 = 'O'
            SET @cFieldAttr10 = 'O'

            SET @curLabel = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT Long
            FROM dbo.CODELKUP (NOLOCK)
            WHERE Listname  = 'RDTATrack'
               AND StorerKey = @cStorerKey
               AND UDF01     = @cNewStatus
            OPEN @curLabel

            FETCH NEXT FROM @curLabel INTO @cLabel
            WHILE @@FETCH_STATUS = 0
            BEGIN
               IF @nCounter = 0
               BEGIN
                  SET @cOutField03  = @cLabel
                  SET @cFieldAttr04 = ''
               END
               ELSE IF @nCounter = 1
               BEGIN
                  SET @cOutField05  = @cLabel
                  SET @cFieldAttr06 = ''
               END
               ELSE IF @nCounter = 2
               BEGIN
                  SET @cOutField07  = @cLabel
                  SET @cFieldAttr08 = ''
               END
               ELSE IF @nCounter = 3
               BEGIN
                  SET @cOutField09  = @cLabel
                  SET @cFieldAttr10 = ''
               END

               SET @nCounter = @nCounter + 1

               FETCH NEXT FROM @curLabel INTO @cLabel
            END

            EXEC rdt.rdtSetFocusField @nMobile, 4

            SET @nStep = @nStep + 2
            SET @nScn  = @nScn  + 2

         END
      END
      ELSE
      BEGIN

         SELECT @cGroup = OpsPosition
         FROM rdt.rdtuser (NOLOCK)
         WHERE USERNAME = @cUserName

         -- Prepare next screen var
         SELECT @cOutField01 = '1-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '1' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField02 = '2-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '2' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField03 = '3-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '3' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField04 = '4-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '4' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField05 = '5-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '5' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField06 = '6-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '6' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField07 = '7-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '7' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField08 = '8-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '8' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField09 = '9-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '9' AND CHARINDEX(@cGroup, short) <> '0'

         SET @nStep = @nStep - 1
         SET @nScn  = @nScn  - 1
      END

      GOTO Quit
   END

   IF @nStep = 4
   BEGIN
      IF @nInputKey = '1'
      BEGIN
         SELECT TOP 1 @cBookStatus = Status
         FROM rdt.RDTVASLOG (NOLOCK)
         WHERE Ref1 = @cRef1
         ORDER BY AddDate DESC

         SET @cBookStatus = CASE WHEN ISNULL(@cBookStatus, '0') = '0' THEN '0'
                                 ELSE @cBookStatus
                            END

         SELECT @cNewStatus = code
         FROM dbo.CODELKUP (NOLOCK)
         WHERE Listname  = 'BkStatusI'
            AND storerkey = @cStorerKey
            AND Notes2    = @nFunc
            AND code IN ('1', '4')
            AND @cBookStatus IN (udf01, udf02)
            AND notes = @cActivityStatus

         SET @curLabel = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT Long, UDF02
         FROM dbo.CODELKUP (NOLOCK)
         WHERE Listname  = 'RDTATrack'
            AND StorerKey = @cStorerKey
            AND UDF01     = @cNewStatus
         OPEN @curLabel

         FETCH NEXT FROM @curLabel INTO @cLabel, @cUDF02
         WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @nIsValid = 0

            IF @nCounter = 0
            BEGIN
               IF ISNULL(@cInput01, '') = ''
               BEGIN
                  SET @nErrNo  = 278058
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InvalidFormat
                  EXEC rdt.rdtSetFocusField @nMobile, 4
                  GOTO Quit
               END

               -- FLOAT validation
               IF @cUDF02 = 'Float' AND (ISNUMERIC(@cInput01) = 1 OR CHARINDEX('.', @cInput01) = 1)
                  SET @nIsValid = 1;

               -- INT validation
               ELSE IF @cUDF02 = 'INT' AND ISNUMERIC(@cInput01) = 1
                  SET @nIsValid = 1;

               -- CHAR validation
               ELSE IF @cUDF02 IN ('CHAR', 'VARCHAR')
                  SET @nIsValid = 1;

               IF @nIsValid = 0
               BEGIN
                  SET @nErrNo  = 278059
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InvalidFormat
                  EXEC rdt.rdtSetFocusField @nMobile, 4
                  GOTO Quit
               END

               SET @cOutField04 = @cInput01
            END
            ELSE IF @nCounter = 1
            BEGIN
               IF ISNULL(@cInput02, '') = ''
               BEGIN
                  SET @nErrNo  = 278060
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Column Can not be Null
                  EXEC rdt.rdtSetFocusField @nMobile, 6
                  GOTO Quit
               END

               -- FLOAT validation
               IF @cUDF02 = 'Float' AND (ISNUMERIC(@cInput02) = 1 OR CHARINDEX('.', @cInput02) = 1)
                  SET @nIsValid = 1;

               -- INT validation
               ELSE IF @cUDF02 = 'INT' AND ISNUMERIC(@cInput02) = 1
                  SET @nIsValid = 1;

               -- CHAR validation
               ELSE IF @cUDF02 IN ('CHAR', 'VARCHAR')
                  SET @nIsValid = 1;

               IF @nIsValid = 0
               BEGIN
                  SET @nErrNo  = 278059
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InvalidFormat
                  EXEC rdt.rdtSetFocusField @nMobile, 6
                  GOTO Quit
               END

               SET @cOutField06 = @cInput02
            END
            ELSE IF @nCounter = 2
            BEGIN
               IF ISNULL(@cInput03, '') = ''
               BEGIN
                  SET @nErrNo  = 278061
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Column Can not be Null
                  EXEC rdt.rdtSetFocusField @nMobile, 8
                  GOTO Quit
               END

               -- FLOAT validation
               IF @cUDF02 = 'Float' AND (ISNUMERIC(@cInput03) = 1 OR CHARINDEX('.', @cInput03) = 1)
                  SET @nIsValid = 1;

               -- INT validation
               ELSE IF @cUDF02 = 'INT' AND ISNUMERIC(@cInput03) = 1
                  SET @nIsValid = 1;

               -- CHAR validation
               ELSE IF @cUDF02 IN ('CHAR', 'VARCHAR')
                  SET @nIsValid = 1;

               IF @nIsValid = 0
               BEGIN
                  SET @nErrNo  = 278062
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InvalidFormat
                  EXEC rdt.rdtSetFocusField @nMobile, 8
                  GOTO Quit
               END

               SET @cOutField08 = @cInput03
            END
            ELSE IF @nCounter = 3
            BEGIN
               IF ISNULL(@cInput04, '') = ''
               BEGIN
                  SET @nErrNo  = 278063
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Column Can not be Null
                  EXEC rdt.rdtSetFocusField @nMobile, 10
                  GOTO Quit
               END

               -- FLOAT validation
               IF @cUDF02 = 'Float' AND (ISNUMERIC(@cInput04) = 1 OR CHARINDEX('.', @cInput04) = 1)
                  SET @nIsValid = 1;

               -- INT validation
               ELSE IF @cUDF02 = 'INT' AND ISNUMERIC(@cInput04) = 1
                  SET @nIsValid = 1;

               -- CHAR validation
               ELSE IF @cUDF02 IN ('CHAR', 'VARCHAR')
                  SET @nIsValid = 1;

               IF @nIsValid = 0
               BEGIN
                  SET @nErrNo  = 278064
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InvalidFormat
                  EXEC rdt.rdtSetFocusField @nMobile, 10
                  GOTO Quit
               END

               SET @cOutField10 = @cInput04
            END

            SET @nCounter = @nCounter + 1

            FETCH NEXT FROM @curLabel INTO @cLabel, @cUDF02
         END


         IF @cOption = '1'
         BEGIN

            BEGIN TRY
               INSERT INTO rdt.RDTVASLOG (Type, UserName, Facility, StartDate, EndDate, Ref1, Ref2, Ref3, Ref4, Ref5, Status, QTY)
               VALUES (@cActivityStatus, SUSER_SNAME(), @cFacility, GETDATE(), GETDATE(), @cRef1, @cInput01, @cInput02, @cInput03, @cInput04, @cNewStatus, 1)
            END TRY
            BEGIN CATCH
               SET @nErrNo  = 278065
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- InsBEFail
               GOTO Quit
            END CATCH

            IF @cActivityStatus = '1' -- Check IN
            BEGIN

               SET @curSearch = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT Code, Long
                  FROM dbo.CodeLKUP WITH (NOLOCK)
                  WHERE ListName  = 'REFNOLKUP'
                     AND StorerKey = @cStorerKey
                     AND Code2     = @cFacility
                     AND Notes2    = @nFunc
                  ORDER BY Short
               OPEN @curSearch
               FETCH NEXT FROM @curSearch INTO @cColumnName, @cTableName
               WHILE @@FETCH_STATUS = 0
               BEGIN

                  SET @cSQL =
                     ' SELECT ' +
                        ' Receipt.ReceiptKey ' +
                     ' FROM dbo.Receipt Receipt WITH (NOLOCK)  LEFT JOIN ' +
                     '      dbo.PO  PO WITH (NOLOCK) ON PO.POKey = Receipt.POKey AND PO.StorerKey = Receipt.StorerKey ' +
                     ' WHERE Receipt.Facility = @cFacility ' +
                        ' AND Receipt.StorerKey = @cStorerKey ' +
                        ' AND ' + @cTableName + '.' + @cColumnName + ' = @cRef1 '

                  -- Open cursor
                  SET @cSQL =
                     ' SET @curRD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' +
                        @cSQL +
                     ' OPEN @curRD '

                  SET @cSQLParam =
                     ' @curRD          CURSOR OUTPUT, ' +
                     ' @cFacility      NVARCHAR(5),  ' +
                     ' @cStorerKey     NVARCHAR(15), ' +
                     ' @cRef1          NVARCHAR(60) OUTPUT, ' +
                     ' @cReceiptKey    NVARCHAR(10) OUTPUT, ' +
                     ' @nErrNo         INT          OUTPUT  '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @curRD        OUTPUT,
                     @cFacility,
                     @cStorerKey,
                     @cRef1        OUTPUT,
                     @cReceiptKey  OUTPUT,
                     @nErrNo       OUTPUT

                  -- Loop Receipt
                  FETCH NEXT FROM @curRD INTO @cReceiptKey
                  WHILE @@FETCH_STATUS = 0
                  BEGIN

                     BEGIN TRY
                        UPDATE dbo.Receipt WITH (ROWLOCK)
                        SET ASNStatus = 'VA'
                        WHERE ReceiptKey = @cReceiptKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo  = 278066
                        SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UpdRecptFail
                        GOTO Quit
                     END CATCH

                     FETCH NEXT FROM @curRD INTO @cReceiptKey
                  END
                  CLOSE  @curRD
                  DEALLOCATE @curRD

                  FETCH NEXT FROM @curSearch INTO @cColumnName, @cTableName
               END
               CLOSE  @curSearch
               DEALLOCATE @curSearch
            END
         END

         SET @cOutField01  = ''
         SET @cOutField02  = ''
         SET @cOutField03  = ''
         SET @cOutField04  = ''
         SET @cOutField05  = ''
         SET @cOutField06  = ''
         SET @cOutField07  = ''
         SET @cOutField08  = ''
         SET @cOutField09  = ''
         SET @cOutField10  = ''
         SET @cOutField11  = ''
         SET @cFieldAttr04 = ''
         SET @cFieldAttr06 = ''
         SET @cFieldAttr08 = ''
         SET @cFieldAttr10 = ''

         SELECT @cGroup = OpsPosition
         FROM rdt.rdtuser (NOLOCK)
         WHERE USERNAME = @cUserName

         -- Prepare next screen var
         SELECT @cOutField01 = '1-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '1' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField02 = '2-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '2' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField03 = '3-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '3' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField04 = '4-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '4' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField05 = '5-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '5' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField06 = '6-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '6' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField07 = '7-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '7' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField08 = '8-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '8' AND CHARINDEX(@cGroup, short) <> '0'
         SELECT @cOutField09 = '9-' + Description FROM dbo.CodeLkup WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ListName = 'RDTAcTrack' AND code = '9' AND CHARINDEX(@cGroup, short) <> '0'

         -- Screen mapping
         SET @nScn  = @nScn  - 3
         SET @nStep = @nStep - 3

      END
      ELSE
      BEGIN
         SET @cOutField01  = ''
         SET @cOutField02  = ''
         SET @cOutField03  = ''
         SET @cOutField04  = ''
         SET @cOutField05  = ''
         SET @cOutField06  = ''
         SET @cOutField07  = ''
         SET @cOutField08  = ''
         SET @cOutField09  = ''
         SET @cOutField10  = ''
         SET @cOutField11  = ''
         SET @cFieldAttr04 = ''
         SET @cFieldAttr06 = ''
         SET @cFieldAttr08 = ''
         SET @cFieldAttr10 = ''

         -- Get event to capture
         SELECT
            @cOutField01 = udf01,
            @cOutField04 = udf02,
            @cOutField05 = udf03
         FROM dbo.CodeLkup WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND ListName  = 'RDTAcTrack'
            AND code      = @cMenuOption

         -- Screen mapping
         SET @nScn  = @nScn  - 2
         SET @nStep = @nStep - 2
      END

      GOTO Quit
   END


Quit:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_AT_CheckIN_HY TO NSQL
GO
