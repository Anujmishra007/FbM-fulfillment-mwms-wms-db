SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ExtInfo_PGPE                                */
/* Copyright      : Maersk                                              */
/* Customer       : PGPE                                                */
/*                                                                      */
/* Purpose: Displays the Stage (Lane) and Dock Door (loading location)  */
/*          during the picking                                          */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-04-14   FRO014    1.0   RITM9021239/UWP-62598 Created           */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtInfo_PGPE]
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @cTaskDetailKey NVARCHAR( 10),
   @cExtendedInfo1 NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT,
   @nAfterStep     INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey    NVARCHAR( 15)
   DECLARE @cPlaceOfStage NVARCHAR( 15)
   DECLARE @cPlaceOfDoor  NVARCHAR( 15)

   IF @nFunc = 1812
   BEGIN
      IF @nAfterStep IN (2, 3, 4, 6, 7) -- FromLOC / FromID / SKU+QTY / ToLOC / Next task
      BEGIN
         SELECT @cStorerKey = StorerKey
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         SELECT TOP 1
            @cPlaceOfStage = ISNULL(LPLD.LOC, ''),
            @cPlaceOfDoor  = ISNULL(MB.PlaceOfLoading, '')
         FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN dbo.ORDERS O WITH (NOLOCK)
            ON PD.OrderKey = O.OrderKey
         LEFT JOIN dbo.MBOL MB WITH (NOLOCK)
            ON O.MBOLKey = MB.MBOLKey
         LEFT JOIN dbo.LoadPlanLaneDetail LPLD WITH (NOLOCK)
            ON O.LoadKey = LPLD.LoadKey
         WHERE PD.StorerKey      = @cStorerKey
            AND PD.TaskDetailKey = @cTaskDetailKey

         IF ISNULL(@cPlaceOfStage, '') = '' AND ISNULL(@cPlaceOfDoor, '') = ''
            SET @cExtendedInfo1 = 'Stage/Door not cfg'
         ELSE
            SET @cExtendedInfo1 = LEFT(@cPlaceOfStage + ' / ' + @cPlaceOfDoor, 20)
      END
   END

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtInfo_PGPE] TO [NSQL]
GO
