if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_640CartonPos01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [RDT].[rdt_640CartonPos01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_640CartonPos01                                  */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Show carton position                                        */
/*                                                                      */
/* Called from: rdtfnc_TM_ClusterPick                                   */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 2021-07-15   1.0  James    WMS-17429 Created                         */
/************************************************************************/

CREATE PROC [RDT].[rdt_640CartonPos01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cGroupKey      NVARCHAR( 10),
   @cTaskDetailKey NVARCHAR( 10),
   @cCartonID      NVARCHAR( 20),
   @cPosition      NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SELECT @cPosition = 'POS: ' + StatusMsg
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE Storerkey = @cStorerKey
   AND   TaskType = 'CPK'
   AND   Caseid = @cCartonID
   AND   [Status] < '9'
   AND   Groupkey = @cGroupKey
   
   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_640CartonPos01 TO NSQL
GO