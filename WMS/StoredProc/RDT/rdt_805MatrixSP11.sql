
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* Store procedure: rdt_805MatrixSP11                                       */
/* Copyright      : Mearsk                                                  */
/* Customer       : JOI_DOLLAR MEXICO                                       */
/*                                                                          */
/* Date       Rev  Author   Purposes                                        */
/* 2020-08-12 1.0  JCH507   FCR-14835 Case UOM display(based on MatrixSP01) */
/****************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_805MatrixSP11] (
    @nMobile    INT
   ,@nFunc      INT
   ,@cLangCode  NVARCHAR( 3)
   ,@nStep      INT
   ,@nInputKey  INT
   ,@cFacility  NVARCHAR( 5)
   ,@cStorerKey NVARCHAR( 15)
   ,@cLight     NVARCHAR( 1)
   ,@cStation1  NVARCHAR( 10)
   ,@cStation2  NVARCHAR( 10)
   ,@cStation3  NVARCHAR( 10)
   ,@cStation4  NVARCHAR( 10)
   ,@cStation5  NVARCHAR( 10)
   ,@cMethod    NVARCHAR( 1)
   ,@cScanID    NVARCHAR( 20)
   ,@cSKU       NVARCHAR( 20)
   ,@nErrNo     INT            OUTPUT
   ,@cErrMsg    NVARCHAR( 20)  OUTPUT
   ,@cResult01  NVARCHAR( 20)  OUTPUT
   ,@cResult02  NVARCHAR( 20)  OUTPUT
   ,@cResult03  NVARCHAR( 20)  OUTPUT
   ,@cResult04  NVARCHAR( 20)  OUTPUT
   ,@cResult05  NVARCHAR( 20)  OUTPUT
   ,@cResult06  NVARCHAR( 20)  OUTPUT
   ,@cResult07  NVARCHAR( 20)  OUTPUT
   ,@cResult08  NVARCHAR( 20)  OUTPUT
   ,@cResult09  NVARCHAR( 20)  OUTPUT
   ,@cResult10  NVARCHAR( 20)  OUTPUT
   ,@nNextPage  INT = NULL     OUTPUT  -- NULL = refresh current page
 )
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag        INT = 0

   DECLARE @bSuccess          INT
   DECLARE @nPTLKey           BIGINT
   DECLARE @cStation          NVARCHAR(10)
   DECLARE @cIPAddress        NVARCHAR(40)
   DECLARE @cPosition         NVARCHAR(10)
   DECLARE @nCounter          INT
   DECLARE @cQTY              NVARCHAR(20)
   DECLARE @nQTY              INT
   DECLARE @cLightMode        NVARCHAR(4)
   DECLARE @cRow              NVARCHAR(2)
   DECLARE @cDeviceID         NVARCHAR(20)
   DECLARE @cUserName         NVARCHAR(18)
   DECLARE @cLoc              NVARCHAR(10)
   DECLARE @nSumqty           INT
   DECLARE @cDeviceIP         NVARCHAR(40)
   DECLARE @nRecOnPage        INT
   DECLARE @nRecCount         INT
   DECLARE @nMaxRecOnPage     INT
   DECLARE @nFirstRecOnPage   INT
   DECLARE @cPackUOM1         NVARCHAR(10)
   DECLARE @nCaseCnt          INT
   DECLARE @nCaseQTY          INT

   DECLARE @tPos TABLE
   (
      Seq       INT IDENTITY(1,1) NOT NULL,
      PTLKey    BIGINT,
      Station   NVARCHAR(10),
      IPAddress NVARCHAR(40),
      Position  NVARCHAR(5),
      Loc       NVARCHAR(10),
      QTY       INT
   )

   IF @nDebugFlag = 1
      SELECT 'Start rdt_805MatrixSP11', @nStep AS Step, @nNextPage AS NextPage, @cScanID AS ScanID, @cSKU AS SKU

   -- Page control
   IF @nStep = 4 -- Matrix screen
   BEGIN
      IF @nInputKey = 1 -- ENTER
         SET @nNextPage = @nNextPage + 1

      IF @nInputKey = 0 -- ESC
         SET @nNextPage = @nNextPage - 1

      IF @nNextPage = 0
         GOTO Quit
   END
   ELSE
      -- Other screens
      SET @nNextPage = 1 -- Always start from 1st page

   SET @nMaxRecOnPage = 9
   SET @nFirstRecOnPage = ((@nNextPage - 1) * @nMaxRecOnPage) + 1
   SET @nRecOnPage = 0
   SET @nRecCount = 0
   SET @nSumQTY = 0

   -- Get login info
   SELECT @cUserName = UserName FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile

   -- Get user info
   SELECT @cLightMode = DefaultLightColor FROM rdt.rdtUser WITH (NOLOCK) WHERE UserName = @cUserName

   -- Lookup Case UOM for the scanned SKU
   SELECT @cPackUOM1 = P.PackUOM1,
          @nCaseCnt  = ISNULL(TRY_CAST( P.CaseCnt AS INT), 0)
   FROM dbo.SKU S WITH (NOLOCK)
   JOIN dbo.PACK P WITH (NOLOCK) ON P.PackKey = S.PACKKey
   WHERE S.Sku        = @cSKU
     AND S.StorerKey  = @cStorerKey

   IF @nCaseCnt IS NULL OR @nCaseCnt = 0
   BEGIN
      SET @nErrNo  = 277701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Case UOM: ' + @cPackUOM1 + ', Case Count: ' + CAST( @nCaseCnt AS NVARCHAR(5))

   -- Loop each PTL tran, insert POS with QTY
   DECLARE @curPTLTran CURSOR
   SET @curPTLTran = CURSOR FOR
      SELECT T.PTLKey, T.IPAddress, T.DevicePosition, T.ExpectedQTY, D.Loc, T.DeviceID
      FROM PTL.PTLTran T WITH (NOLOCK)
         JOIN dbo.DeviceProfile D WITH (NOLOCK) ON (D.DeviceID = T.DeviceID AND D.DevicePosition = T.DevicePosition)
      WHERE D.DeviceID IN (@cStation1, @cStation2, @cStation3, @cStation4, @cStation5)
         AND D.DeviceType = 'STATION'
         AND D.DeviceID <> ''
         AND T.DropID = @cScanID
         AND T.StorerKey = @cStorerKey
         AND T.SKU = @cSKU
         AND T.Status <> '9' -- Due to light on, set PTLTran.Status = 1
      ORDER BY D.LogicalPOS, D.IPAddress, D.DevicePosition

   OPEN @curPTLTran
   FETCH NEXT FROM @curPTLTran INTO @nPTLKey, @cIPAddress, @cPosition, @nQTY, @cLoc, @cDeviceID
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Build Matrix', 'PTLKey: ' + CAST( @nPTLKey AS NVARCHAR(20)) + ', IP: ' + @cIPAddress + ', Pos: ' + @cPosition + ', QTY: ' + CAST( @nQTY AS NVARCHAR(5)) + ', Loc: ' + @cLoc

      SET @nRecCount = @nRecCount + 1

      -- Validate quantity is divisible by case count
      IF @nQTY % @nCaseCnt <> 0
      BEGIN
         SET @nErrNo  = 277702
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END

      SET @nCaseQTY = @nQTY / @nCaseCnt

      IF @nRecCount >= @nFirstRecOnPage AND -- Reach 1st record of the page
         @nRecOnPage < @nMaxRecOnPage       -- Not yet fill up full page
      BEGIN
         BEGIN TRY
            INSERT INTO @tPos (PTLKey, Station, IPAddress, Position, Loc, QTY)
            VALUES ( @nPTLKey, @cDeviceID , @cIPAddress , @cPosition, @cLoc , @nCaseQTY)
         END TRY
         BEGIN CATCH 
            SET @nErrNo  = 277703
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO Quit
         END CATCH

         SET @nRecOnPage = @nRecOnPage + 1
      END

      SET @nSumQTY =  @nSumQTY + @nCaseQTY
      FETCH NEXT FROM @curPTLTran INTO @nPTLKey, @cIPAddress, @cPosition, @nQTY, @cLoc, @cDeviceID
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Total Records: ' + CAST( @nRecCount AS NVARCHAR(5)) + ', Total QTY: ' + CAST( @nSumQTY AS NVARCHAR(5)), '@tPos:'
      SELECT * FROM @tPos
   END

   -- Exit matrix screen
   IF NOT EXISTS( SELECT TOP 1 1 FROM @tPos)
      SET @nNextPage = 0

   SET @cResult01 = ''
   SET @cResult02 = ''
   SET @cResult03 = ''
   SET @cResult04 = ''
   SET @cResult05 = ''
   SET @cResult06 = ''
   SET @cResult07 = ''
   SET @cResult08 = ''
   SET @cResult09 = ''
   SET @cResult10 = ''

   -- 1st line
   SET @cResult01 = 'TOTAL QTY: ' + ISNULL(TRY_CAST(@nSumQTY  AS NVARCHAR(5)), '0')

   -- 2nd line, start listing
   SET @nCounter = 2

   -- Loop light position
   DECLARE @curLightPos CURSOR
   SET @curLightPos = CURSOR FOR
      SELECT PTLKey, Station, IPAddress, Position, Loc, QTY
      FROM @tPos
      WHERE Qty > 0
      ORDER BY Seq
   OPEN @curLightPos
   FETCH NEXT FROM @curLightPos INTO @nPTLKey, @cStation, @cIPAddress, @cPosition, @cLoc, @nQty
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @cQTY = @cLoc + ' | ' + CAST( @nQty AS NVARCHAR( 5))

      -- Calc which row to write
      DECLARE @nWriteRow INT
      SET @nWriteRow = @nCounter

      -- Write to screen
      -- IF @nWriteRow =  1 SET @cResult01 = @cResult01 + @cQTY ELSE
      IF @nWriteRow =  2 SET @cResult02 = @cResult02 + @cQTY ELSE
      IF @nWriteRow =  3 SET @cResult03 = @cResult03 + @cQTY ELSE
      IF @nWriteRow =  4 SET @cResult04 = @cResult04 + @cQTY ELSE
      IF @nWriteRow =  5 SET @cResult05 = @cResult05 + @cQTY ELSE
      IF @nWriteRow =  6 SET @cResult06 = @cResult06 + @cQTY ELSE
      IF @nWriteRow =  7 SET @cResult07 = @cResult07 + @cQTY ELSE
      IF @nWriteRow =  8 SET @cResult08 = @cResult08 + @cQTY ELSE
      IF @nWriteRow =  9 SET @cResult09 = @cResult09 + @cQTY ELSE
      IF @nWriteRow = 10 SET @cResult10 = @cResult10 + @cQTY

      -- Light up location
      IF @cLight = '1' AND @nQTY <> 0
      BEGIN
         IF @nQTY > 99999
            SET @cQTY = '*'
         ELSE
            SET @cQTY = CAST( @nQTY AS NVARCHAR(5))

         EXEC PTL.isp_PTL_LightUpLoc
            @n_Func           = @nFunc
           ,@n_PTLKey         = @nPTLKey
           ,@c_DisplayValue   = @cQTY
           ,@b_Success        = @bSuccess    OUTPUT
           ,@n_Err            = @nErrNo      OUTPUT
           ,@c_ErrMsg         = @cErrMsg     OUTPUT
           ,@c_DeviceID       = @cStation
           ,@c_DevicePos      = @cPosition
           ,@c_DeviceIP       = @cIPAddress
           ,@c_LModMode       = @cLightMode
         IF @nErrNo <> 0
            GOTO Quit
      END

      SET @nCounter = @nCounter + 1
      FETCH NEXT FROM @curLightPos INTO @nPTLKey, @cStation, @cIPAddress, @cPosition, @cLoc, @nQty
   END

   GOTO Quit

Quit:
   IF @nDebugFlag = 1
      SELECT 'End 805MatrixSP11', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nNextPage AS NextPage

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_805MatrixSP11 TO NSQL
GO
