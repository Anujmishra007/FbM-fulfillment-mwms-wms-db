SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1721SuggestLoc02                                */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Move                                      */
/*                                                                      */
/* Purpose: Suggest staging loc for DropID via CHANNELSTG CODELKUP      */
/*          If DropLoc.LocType = POSTPICK, fetch suggested loc from     */
/*          CODELKUP based on Wave attributes and UoM.                  */
/*          Otherwise, return empty (as-is process applies).            */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-07-01  1.0  Dennis   FCR-12996 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1721SuggestLoc02] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @cStorer         NVARCHAR( 15),
   @nStep           INT,
   @cID             NVARCHAR( 20),
   @cSuggestLoc     NVARCHAR( 15) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN

   SET @cSuggestLoc = ''

   DECLARE
      @cDropLoc      NVARCHAR( 10),
      @cLocType      NVARCHAR( 10),
      @cChildID      NVARCHAR( 20),
      @cWaveKey      NVARCHAR( 10),
      @cUoM          NVARCHAR( 10),
      @cUserDefine03 NVARCHAR( 30),
      @cUserDefine05 NVARCHAR( 30)

   -- Check LocationType of the DropID's DropLoc
   SELECT TOP 1
      @cDropLoc = D.Droploc,
      @cLocType = L.LocationType
   FROM DROPID D WITH (NOLOCK)
   INNER JOIN LOC L WITH (NOLOCK) ON L.Loc = D.Droploc
   WHERE D.DropID = @cID

   -- If not POSTPICK, as-is process applies, return empty
   IF ISNULL(@cLocType, '') <> 'POSTPICK'
      GOTO Quit

   -- Get first ChildID from DROPIDDETAIL
   SELECT TOP 1 @cChildID = ChildID
   FROM DROPIDDETAIL WITH (NOLOCK)
   WHERE DropID = @cID
   ORDER BY ChildID

   IF ISNULL(@cChildID, '') = ''
      GOTO Quit

   -- Get WaveKey and UoM from PICKDETAIL via ChildID
   SELECT TOP 1
      @cWaveKey = WaveKey,
      @cUoM     = UoM
   FROM PICKDETAIL WITH (NOLOCK)
   WHERE DropID    = @cChildID
   AND   StorerKey = @cStorer

   IF ISNULL(@cWaveKey, '') = ''
      GOTO Quit

   -- Get Wave attributes used for CODELKUP matching
   SELECT
      @cUserDefine03 = UserDefine03,
      @cUserDefine05 = UserDefine05
   FROM WAVE WITH (NOLOCK)
   WHERE WaveKey = @cWaveKey

   -- Try exact match: UDF02 = UserDefine05 AND UDF03 = UoM
   SELECT TOP 1 @cSuggestLoc = UDF04
   FROM CODELKUP WITH (NOLOCK)
   WHERE LISTNAME  = 'CHANNELSTG'
   AND   STORERKEY = @cStorer
   AND   UDF01     = @cUserDefine03
   AND   UDF02     = @cUserDefine05
   AND   UDF03     = @cUoM
   ORDER BY CODE

   -- Fallback: match on empty UDF02 and UDF03
   IF ISNULL(@cSuggestLoc, '') = ''
   BEGIN
      SELECT TOP 1 @cSuggestLoc = UDF04
      FROM CODELKUP WITH (NOLOCK)
      WHERE LISTNAME       = 'CHANNELSTG'
      AND   STORERKEY      = @cStorer
      AND   UDF01          = @cUserDefine03
      AND   ISNULL(UDF02, '') = ''
      AND   ISNULL(UDF03, '') = ''
      ORDER BY CODE
   END

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1721SuggestLoc02 TO NSQL
GO
