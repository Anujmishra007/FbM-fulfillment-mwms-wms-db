SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/**************************************************************************/
/* Store procedure: rdt_1653GetMbolKey04                                  */
/* Copyright      : MAERSK                                                */
/* Customer       : Granite                                               */
/*                                                                        */
/* Called from: rdt_TrackNo_SortToPallet_GetMbolKey                       */
/*                                                                        */
/* Purpose: Get MBOLKey/Lane/Pallet                                       */
/*                                                                        */
/* Modifications log:                                                     */
/* Date        Rev    Author   Purposes                                   */
/* 2024-07-05  1.0    CYU027   FCR 539. Created                           */
/* 2024-09-20  1.1    CYU027   Add Validation TrackNo                     */
/* 2024-10-08  1.2    NLT013   FCR-950 Enhancement                        */
/* 2024-10-08  1.3.0  NLT013   FCR-1084 Enhancement, if no existing pallet */
/*                             leave location as empty                    */
/* 2024-10-08  1.3.1  JCH507   FCR-1084 Fix bugs 1. Wrong Loc suggest      */
/*                             2. Wrong pallet show on remove carton scn  */
/* 2024-12-08  1.3.2  Dennis   FCR-1316 Fix Bugs when wave type =''       */
/* 2024-12-08  1.3.3  Dennis   FCR-1316 Available pallet based on p.status*/
/* 2025-10-24  1.4.0  NickT    FCR-6801 MobileKey is not mandatory        */
/**************************************************************************/
    
CREATE OR ALTER PROC [RDT].[rdt_1653GetMbolKey04] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cTrackNo       NVARCHAR( 40),
   @cOrderKey      NVARCHAR( 20),
   @cPalletKey     NVARCHAR( 20) OUTPUT,
   @cMBOLKey       NVARCHAR( 10) OUTPUT,
   @cLane          NVARCHAR( 20) OUTPUT, --Pallet Location
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
    
   DECLARE @cCur_ShipperKey               NVARCHAR( 15) = ''
   DECLARE @cNew_ShipperKey               NVARCHAR( 15) = ''
   DECLARE @cCur_OrderKey                 NVARCHAR( 10) = ''
   DECLARE @cPalletNotAllowMixShipperKey  NVARCHAR( 1)

   DECLARE
      @cWaveKey                           NVARCHAR(10),
      @cCODELKUPUdf01                     NVARCHAR(60),
      @cCODELKUPUdf02                     NVARCHAR(60),
      @cCODELKUPUdf03                     NVARCHAR(60),
      @cCODELKUPUdf04                     NVARCHAR(60),
      @cCODELKUPUdf05                     NVARCHAR(60),
      @cCODELKUPUdf01Value                NVARCHAR(60),
      @cCODELKUPUdf02Value                NVARCHAR(60),
      @cCODELKUPUdf03Value                NVARCHAR(60),
      @cCODELKUPUdf04Value                NVARCHAR(60),
      @cCODELKUPUdf05Value                NVARCHAR(60),
      @cWaveType                          NVARCHAR(18),
      @cSQLString                         NVARCHAR(MAX),
      @cSQLParam                          NVARCHAR(MAX)

   SELECT @cNew_ShipperKey = ShipperKey
   FROM dbo.ORDERS WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey
    
   SET @cMBOLKey = ''

   SELECT @cMBOLKey = MbolKey
   FROM dbo.MBOLDETAIL WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey

   IF @cMBOLKey = ''
   BEGIN
      SELECT @cPalletKey = Palletkey
      FROM dbo.PalletDetail WITH(NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND Orderkey = @cOrderKey
         AND Status = '0'

      IF ISNULL(@cPalletKey, '') <> ''
      BEGIN
         SELECT TOP 1 @cLane = LOC
         FROM PALLETDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND PalletKey = @cPalletKey
      END
      ELSE
      BEGIN
         SELECT TOP 1 @cLane = LOC
         FROM dbo.PALLETDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND Orderkey = @cOrderKey
            AND Status = '0'
         ORDER BY EditDate DESC
      END
   END
   ELSE
   BEGIN
      IF EXISTS ( SELECT 1 FROM MBOL WITH (NOLOCK)
                  WHERE MbolKey = @cMBOLKey
                  AND   [Status] = '9')
      BEGIN
         SET @nErrNo = 219102
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL Shipped
         GOTO Quit
      END

      --FCR-950 --BEGIN
      SET @cPalletKey = ''
      SELECT @cWaveKey = ISNULL(UserDefine09, '')
      FROM dbo.ORDERS WITH(NOLOCK)
      WHERE OrderKey = @cOrderKey
         AND StorerKey = @cStorerKey

      SELECT @cWaveType = WaveType
      FROM dbo.Wave WITH(NOLOCK)
      WHERE WaveKey = @cWaveKey

      IF TRIM(@cWaveType) IN ('', '0')
      BEGIN
         SET @cPalletKey = ''
         SELECT TOP 1
            @cPalletKey = PD.PalletKey
         FROM dbo.PALLETDETAIL PD WITH (NOLOCK)
         JOIN dbo.Pallet P WITH (NOLOCK) ON P.PalletKey = PD.PalletKey AND P.StorerKey = PD.StorerKey
         WHERE PD.StorerKey = @cStorerKey
            AND ISNULL(UserDefine01, '') = @cMBOLKey
            AND P.Status = '0'
         ORDER BY PD.EditDate DESC
      END
      ELSE
      BEGIN
         SELECT TOP 1
            @cCODELKUPUdf01 = TRIM(UDF01),
            @cCODELKUPUdf02 = TRIM(UDF02),
            @cCODELKUPUdf03 = TRIM(UDF03),
            @cCODELKUPUdf04 = TRIM(UDF04),
            @cCODELKUPUdf05 = TRIM(UDF05)
         FROM dbo.CODELKUP WITH(NOLOCK)
         WHERE LISTNAME = 'WAVETYPE'
            AND StorerKey = @cStorerKey 
            AND Code = @cWaveType

         IF @cCODELKUPUdf01 IS NULL OR TRIM(@cCODELKUPUdf01) = ''
         BEGIN
            SET @nErrNo = 219108
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PLT Group logic missing
            GOTO Quit
         END

         BEGIN TRY
            SET @cSQLString = 
               ' SELECT  @cCODELKUPUdf01Value = ' + @cCODELKUPUdf01 + ' ' +
               IIF(@cCODELKUPUdf02 <> '',   ', @cCODELKUPUdf02Value = ' + @cCODELKUPUdf02 + ' ', '') +
               IIF(@cCODELKUPUdf03 <> '',   ', @cCODELKUPUdf03Value = ' + @cCODELKUPUdf03 + ' ', '') +
               IIF(@cCODELKUPUdf04 <> '',   ', @cCODELKUPUdf04Value = ' + @cCODELKUPUdf04 + ' ', '') +
               IIF(@cCODELKUPUdf05 <> '',   ', @cCODELKUPUdf05Value = ' + @cCODELKUPUdf05 + ' ', '') +
               ' FROM dbo.ORDERS WITH(NOLOCK) '     +
               ' WHERE OrderKey =  @cOrderKey' +
               ' AND StorerKey = @cStorerKey'

            SET @cSQLParam =  '@cOrderKey       NVARCHAR(20), ' +
                              '@cStorerKey      NVARCHAR(20), ' +
                              '@cCODELKUPUdf01Value  NVARCHAR(60) OUTPUT, ' +
                              '@cCODELKUPUdf02Value  NVARCHAR(60) OUTPUT, ' +
                              '@cCODELKUPUdf03Value  NVARCHAR(60) OUTPUT, ' +
                              '@cCODELKUPUdf04Value  NVARCHAR(60) OUTPUT, ' +
                              '@cCODELKUPUdf05Value  NVARCHAR(60) OUTPUT ' 
                  
            EXEC sp_executesql @cSQLString, @cSQLParam, 
               @cOrderKey = @cOrderKey, 
               @cStorerKey = @cStorerKey,
               @cCODELKUPUdf01Value = @cCODELKUPUdf01Value OUTPUT, 
               @cCODELKUPUdf02Value = @cCODELKUPUdf02Value OUTPUT, 
               @cCODELKUPUdf03Value = @cCODELKUPUdf03Value OUTPUT, 
               @cCODELKUPUdf04Value = @cCODELKUPUdf04Value OUTPUT, 
               @cCODELKUPUdf05Value = @cCODELKUPUdf05Value OUTPUT
         END TRY
         BEGIN CATCH
            SET @nErrNo = 219109
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Execute SQL Statement Fail
            GOTO Quit
         END CATCH

         --V1.3.1 If carton already on a pallet, then return that palletkey to remove carton screen
         SET @cPalletKey = ''

         SELECT TOP 1
            @cPalletKey = PD.PalletKey
         FROM dbo.PALLETDETAIL PD WITH (NOLOCK)
         JOIN dbo.Pallet P WITH (NOLOCK) ON P.PalletKey = PD.PalletKey AND P.StorerKey = PD.StorerKey
         WHERE PD.StorerKey = @cStorerKey
            AND PD.CaseId = @cTrackNo
            AND P.Status <> '9'

         IF @@ROWCOUNT = 0
         BEGIN
            SELECT 
               @cPalletKey = PD.PalletKey
            FROM dbo.PALLETDETAIL PD WITH(NOLOCK) 
            JOIN dbo.Pallet P WITH (NOLOCK) ON P.PalletKey = PD.PalletKey AND P.StorerKey = PD.StorerKey
            WHERE PD.StorerKey = @cStorerKey
               AND ISNULL(UserDefine01, '') = @cCODELKUPUdf01Value
               AND ISNULL(UserDefine02, '') LIKE IIF(@cCODELKUPUdf02 = '', '%%', @cCODELKUPUdf02Value)
               AND ISNULL(UserDefine03, '') LIKE IIF(@cCODELKUPUdf03 = '', '%%', @cCODELKUPUdf03Value)
               AND ISNULL(UserDefine04, '') LIKE IIF(@cCODELKUPUdf04 = '', '%%', @cCODELKUPUdf04Value)
               AND ISNULL(UserDefine05, '') LIKE IIF(@cCODELKUPUdf05 = '', '%%', @cCODELKUPUdf05Value)
               AND P.Status = '0' -- 0 means pallet is open, 9 means pallet is closed.
         END
         --V1.3.1 If carton already on a pallet, then return that palletkey to remove carton screen END
      END

      --FCR-950 --END
    
      -- SET @cPalletKey = ''    
      -- SELECT TOP 1     
      --    @cPalletKey = PalletKey
      -- FROM dbo.PALLETDETAIL WITH (NOLOCK)
      -- WHERE StorerKey = @cStorerKey    
      -- AND   UserDefine01 = @cMBOLKey
      -- AND   Status = '0'
      -- ORDER BY EditDate DESC


      SET @cLane = ''

      --1.3.1 start
      IF @cPalletKey <> '' AND @cPalletKey IS NOT NULL
      BEGIN
         SELECT TOP 1 @cLane = LOC
         FROM PALLETDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND PalletKey = @cPalletKey
      END
      ELSE
      BEGIN
         SELECT TOP 1 @cLane = LOC
         FROM dbo.PALLETDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND UserDefine01 = @cMBOLKey
         ORDER BY EditDate DESC
      END
      --1.3.1 END
   END
   
   SET @cPalletNotAllowMixShipperKey = rdt.RDTGetConfig( @nFunc, 'PalletNotAllowMixShipperKey', @cStorerkey)
   IF @cPalletNotAllowMixShipperKey = '0'
      SET @cPalletNotAllowMixShipperKey = ''
   
   -- 1 pallet 1 shipperkey    
   IF @cPalletNotAllowMixShipperKey = '1' AND @cPalletKey <> ''
   BEGIN    
      -- Get orderkey from existing pallet
      SELECT TOP 1 
         @cCur_OrderKey = Orderkey,
         @cLane = LOC
      FROM dbo.PALLETDETAIL PD WITH (NOLOCK)
      INNER JOIN dbo.Pallet P WITH (NOLOCK) ON P.PalletKey = PD.PalletKey AND P.StorerKey = PD.StorerKey
      WHERE PD.PalletKey = @cPalletKey
         AND PD.StorerKey = @cStorerKey
         AND P.Status = '0'
      ORDER BY 1
   
      -- Get shipperkey from orders on existing pallet
      SELECT @cCur_ShipperKey = ShipperKey
      FROM dbo.ORDERS WITH (NOLOCK)
      WHERE OrderKey = @cCur_OrderKey
      AND StorerKey = @cStorerKey
   
      -- Validate if same shipperkey
      IF @cCur_ShipperKey <> @cNew_ShipperKey
      BEGIN
         SET @cMBOLKey = ''
         SET @cPalletKey = ''
         SET @cLane = ''
         GOTO Quit
      END
   END

   IF @cPalletKey = ''
   BEGIN
      SET @cPalletKey = 'NEW PALLET'
      SET @cLane = ''
   END
Quit:
END 
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1653GetMbolKey04 TO NSQL
GO
