IF EXISTS (SELECT name FROM sysobjects WHERE name = 'rdt_652ExtUpd01' AND type = 'P')
   DROP PROC rdt.rdt_652ExtUpd01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_652ExtUpd01                                        */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Date        Rev  Author       Purposes                                  */
/* 2024-05-27  1.0  Cuize        FCR-242 Created                           */
/***************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_652ExtUpd01(
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cContainerNo        NVARCHAR( 20), -- rdtSTDEventLog only accept 20 max
   @cAppointmentNo      NVARCHAR( 20),
   @cMenuOption         NVARCHAR( 10),
   @cActionType         NVARCHAR( 10),
   @cRefNo1             NVARCHAR( 10),
   @cDefaultOption      NVARCHAR( 10),
   @cDefaultCursor      NVARCHAR( 10),
   @cActivityStatus     NVARCHAR( 20),
   @nErrNo              INT           OUTPUT,
   @cErrMsg             NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 652
   BEGIN

         IF @nInputKey = 1
         BEGIN

            DECLARE @b_success               INT
            DECLARE @n_err                   INT
            DECLARE @c_errmsg                NVARCHAR(250)
            DECLARE @cPOKey                  NVARCHAR( 10)
            DECLARE @cUSContainerValidation  NVARCHAR( 20)
            DECLARE @cTableName              NVARCHAR( 20)
            DECLARE @cColumnName             NVARCHAR( 20)
            DECLARE @cSQLCustom              NVARCHAR( MAX)
            DECLARE @cSQLCustomParam         NVARCHAR( MAX)
            DECLARE @cUserName               NVARCHAR(18)

            DECLARE @t_SplitValue   TABLE
               (  RowID    INT            IDENTITY(1,1)  PRIMARY KEY
                  ,Value  NVARCHAR(255)  NOT NULL DEFAULT('')
               )

            SET @cUSContainerValidation = rdt.RDTGetConfig( @nFunc, 'USContainerValidation', @cStorerKey)
            IF @cUSContainerValidation = ''
            BEGIN
               GOTO Quit
            END

            INSERT INTO @t_SplitValue (Value)
            SELECT SplitValues = s.[Value]
            FROM STRING_SPLIT(@cUSContainerValidation, '.') AS s


            SELECT @cTableName = ISNULL(Value,'') FROM @t_SplitValue WHERE RowID = 1
            SELECT @cColumnName = ISNULL(Value,'') FROM @t_SplitValue WHERE RowID = 2

            SET @cSQLCustom = ' SELECT TOP 1 @cPOKey = POKey ' +
                              ' FROM '+ @cTableName + ' WITH (NOLOCK) ' +
                              ' WHERE ' + @cColumnName +' = @cContainerNo ' +
                              ' AND StorerKey = @cStorerKey '

            SET @cSQLCustomParam = ' @cContainerNo    NVARCHAR( 20) ' +
                                   ',@cStorerKey      NVARCHAR( 15) ' +
                                   ',@cPOKey          NVARCHAR( 10) OUTPUT '

            EXEC sp_executeSQL @cSQLCustom, @cSQLCustomParam
               ,@cContainerNo = @cContainerNo
               ,@cStorerKey   = @cStorerKey
               ,@cPOKey       = @cPOKey OUTPUT

            IF ISNULL(@cPOKey, '') = ''
            BEGIN
               SET @nErrNo = 215501
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSERT TransLog Fail
               GOTO Quit
            END


            EXEC dbo.ispGenTransmitLog2 'WSONLOTLOG', @cPOKey, @cContainerNo, @cStorerKey, ''
               , @b_success OUTPUT
               , @n_err OUTPUT
               , @c_errmsg OUTPUT

            IF @n_err <> 0
            BEGIN
               SET @nErrNo = 215502
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSERT TransLog Fail
               GOTO Quit
            END

            SELECT @cUserName = UserName
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile

            UPDATE RDT.rdtSTDEventLog SET ContainerNo = @cContainerNo
            WHERE ActionType   = '3'      AND
               userID       = @cUserName  AND
               MobileNo     = @nMobile    AND
               FunctionID   = @nFunc      AND
               Facility     = @cFacility  AND
               StorerKey    = @cStorerKey

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 215503
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INSERT eventlog Fail
               GOTO Quit
            END

         END

   END

   Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_652ExtUpd01 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

