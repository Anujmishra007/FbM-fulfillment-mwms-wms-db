
/************************************************************************/
/* Store procedure: rdt_1812ExtInfo17                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: For BNT SA - FCR-15553 UCC Enable                           */
/*                                                                      */
/* Date        Rev     Author    Purposes                               */
/* 2026-09-03  1.0.0   JackC     FCR-15553 Created                      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtInfo17]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@cExtendedInfo1  NVARCHAR( 20) OUTPUT
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   ,@nAfterStep      INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag INT = 0

   DECLARE @cCaseID NVARCHAR( 20)
   DECLARE @cUOM    NVARCHAR(  5)

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812ExtInfo17'


   IF @nFunc = 1812
   BEGIN
      IF @nAfterStep = 4 --SKU/Qty Screen
      BEGIN
         SELECT @cCaseID = CaseID
               ,@cUOM    = UOM
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskdetailKey

         IF ISNULL(@cCaseID, '') <> '' AND ISNULL(@cUOM, '') = '2'
            SET @cExtendedInfo1 = 'UCC: ' + @cCaseID
      END --st4

      --copy from 1812ExtInfo06
      IF @nAfterStep = 6 OR -- TOLOC
         @nAfterStep = 7    -- Close Pallet
      BEGIN
        -- Get LoadKey
         DECLARE @cLoadKey NVARCHAR(10)
         DECLARE @cStorerkey  NVARCHAR(20)
         DECLARE @nBookingNo NVARCHAR(10)

         SELECT @cLoadKey = LoadKey,
               @cStorerkey = storerkey
         FROM dbo.TaskDetail WITH (NOLOCK) 
         WHERE TaskDetailKey = @cTaskDetailKey

         SELECT @nBookingNo = BookingNo 
         FROM dbo.TMS_shipment TS WITH (NOLOCK) 
         JOIN dbo.tms_shipmentTransOrderLink TTL WITH (NOLOCK) ON TTL.shipmentgid=TS.shipmentgid
         JOIN dbo.tms_transportorder TTO WITH (NOLOCK) ON TTO.ProvshipmentID=TTL.ProvshipmentID
         WHERE TTO.LoadKey = @cLoadKey
         GROUP BY BookingNo
         

         IF EXISTS( SELECT 1 FROM dbo.codelkup WITH (NOLOCK)
                    WHERE ListName = 'TMEXTNLDKY'
                    AND StorerKey = @cstorerkey
                    AND Short ='Y')
         BEGIN
            SELECT @cExtendedInfo1 = LEFT(CONCAT(LP.ExternLoadKey, ' ', @nBookingNo), 20)
            FROM dbo.LoadPlan LP WITH (NOLOCK)
            WHERE LP.LoadKey = @cLoadKey
         END
         ELSE
         BEGIN
            SELECT @cExtendedInfo1 = LEFT(CONCAT(LP.LoadKey, ' ', @nBookingNo), 20)
            FROM dbo.LoadPlan LP WITH (NOLOCK)
            WHERE LP.LoadKey = @cLoadKey
         END
      END-- st6 or 7
   END --1812

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1812ExtInfo17 TO NSQL
GO

