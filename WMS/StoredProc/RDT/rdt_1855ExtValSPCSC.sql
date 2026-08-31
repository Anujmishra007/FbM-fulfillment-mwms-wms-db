/************************************************************************/
/* Store procedure: rdt_1855ExtValSPCSC                                */
/* Purpose: Validate cart id prefix value & Not allow DropID  in use    */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2021-08-13 1.0  James      WMS-17335. Created                        */
/* 2026-04-11 1.1  SKE140     Add DropID validation by WaveKey          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1855ExtValSPCSC] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cGroupKey      NVARCHAR( 10),
   @cTaskDetailKey NVARCHAR( 10),
   @cPickZone      NVARCHAR( 10),
   @cCartId        NVARCHAR( 10),
   @cMethod        NVARCHAR( 1),
   @cFromLoc       NVARCHAR( 10),
   @cCartonId      NVARCHAR( 20),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cOption        NVARCHAR( 1),
   @cToLOC         NVARCHAR( 10),
   @tExtValidate   VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPickMethod    NVARCHAR( 10)
   DECLARE @cCartonType    NVARCHAR( 10)
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @cCode          NVARCHAR( 10)
   DECLARE @cWaveKey       NVARCHAR( 10)

   SELECT @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nStep = 2
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SELECT TOP 1
            @cPickMethod = TD.PickMethod,
            @cCode = CL.Code
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         JOIN dbo.CODELKUP CL WITH (NOLOCK)
            ON TD.PickMethod = CL.Long
         WHERE TD.Storerkey = @cStorerKey
         AND   TD.TaskType = 'ASTCPK'
         AND   TD.Status = '3'
         AND   TD.Groupkey = @cGroupKey
         AND   TD.UserKey = @cUserName
         AND   TD.DeviceID = @cCartID
         AND   TD.DropID = ''
         ORDER BY CL.Code, TD.TaskDetailKey

         SELECT @cCartonType = UDF01
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE LISTNAME = 'TMPICKMTD'
         AND   Storerkey = @cStorerKey
         AND   Long = @cPickMethod

         IF CHARINDEX( LEFT( @cCartonId, 1), @cCartonType) = 0
         BEGIN
            SET @nErrNo = 173301
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InvCartPrefix
            GOTO Quit
         END

         SELECT TOP 1
            @cWaveKey = TD.WaveKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         WHERE TD.Storerkey = @cStorerKey
         AND   TD.TaskType = 'ASTCPK'
         AND   TD.Status = '3'
         AND   TD.Groupkey = @cGroupKey
         AND   TD.UserKey = @cUserName
         AND   TD.DeviceID = @cCartID
         ORDER BY TD.TaskDetailKey

         IF ISNULL(@cWaveKey, '') <> ''
         BEGIN
            IF EXISTS
            (
               SELECT 1
               FROM dbo.PICKDETAIL PD WITH (NOLOCK)
               JOIN dbo.Orders O WITH (NOLOCK)
                  ON O.OrderKey = PD.OrderKey
                 AND O.StorerKey = PD.StorerKey
               WHERE PD.Storerkey = @cStorerKey
               AND   PD.DropID = @cCartonID
               AND   ISNULL(PD.WaveKey, '') <> @cWaveKey
               AND   ISNULL(O.Status, '0') <> '9'
            )
            BEGIN
               SET @nErrNo = 171832
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Tote In Use
               GOTO Quit
            END
         END
      END
   END

Quit:
