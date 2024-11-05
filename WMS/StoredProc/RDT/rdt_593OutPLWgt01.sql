
/****** Object:  StoredProcedure [RDT].[rdt_593OutPLWgt01]    Script Date: 7/1/2024 9:48:34 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593OutPLWeight01                                      */
/*                                                                            */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author           Purposes                                  */
/* 2024-05-31 1.0  Xiaotong Guan     UWP-21389 Created                        */
/* 2024-11-05 1.1  Bruce Ping        UWP-21389 Updated                        */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593OutPLWgt01] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR(20),  -- PalletWeight
   @cParam2    NVARCHAR(20),  -- PalletQty
   @cParam3    NVARCHAR(20),  -- Mbol Key
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success      INT
   DECLARE @n_Err          INT
   DECLARE @c_ErrMsg       NVARCHAR( 250)

   DECLARE @cPalletWeight        NVARCHAR( 20)
   DECLARE @cPalletQty           NVARCHAR( 20)
   DECLARE @cMbolKey             NVARCHAR( 20)
   DECLARE @cStatus              NVARCHAR( 20)
   DECLARE @cPalletCnt           NVARCHAR( 20)
   DECLARE @cContainerKey        NVARCHAR( 20)
   DECLARE @cContainerLineNumber NVARCHAR(5)
   DECLARE @cID                  INT
   DECLARE @c_weight             FLOAT
   DECLARE @c_RemainWeight       FLOAT

   DECLARE @ContainerDtl TABLE(  
     RowID                INT IDENTITY(1,1) NOT NULL,  
     containerkey         NVARCHAR(20)  NOT NULL,
     containerlinenumber  nvarchar(5) NOT NULL
     )

   -- Parameter mapping
   SET @cPalletWeight = @cParam1
   SET @cPalletQty    = @cParam2
   SET @cMbolKey      = @cParam3

   -- Check blank
   IF @cPalletWeight = '' or TRY_CAST(@cPalletWeight as FLOAT) IS NULL or @cPalletWeight = 0
   BEGIN
      SET @nErrNo = 218751
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') 
      GOTO Quit
   END

   IF @cPalletQty = '' OR TRY_CAST(@cPalletQty as INT) IS NULL OR @cPalletQty = 0
   BEGIN
      SET @nErrNo = 218752
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') 
      GOTO Quit
   END

   IF @cMbolKey = ''
   BEGIN
      SET @nErrNo = 218753
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') 
      GOTO Quit
   END
   
   -- Mbol Key exists
   SELECT @cStatus = Status
   FROM dbo.MBOL WITH (NOLOCK)
   WHERE MbolKey = @cMbolKey

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 218754
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Mbol Not Exists
      GOTO Quit
   END

   IF @cStatus = '9'
   BEGIN
      SET @nErrNo = 218755
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Mbol Shipped
      GOTO Quit
   END

   -- PalletQty = Count of MbolDetail
   SELECT @cPalletCnt = count(dtl.PalletKey)
   FROM dbo.CONTAINERDETAIL dtl WITH(NOLOCK)
   INNER JOIN dbo.CONTAINER ctn WITH(NOLOCK) ON dtl.ContainerKey = ctn.ContainerKey
   WHERE ctn.MbolKey = @cMbolKey

   IF @cPalletQty <> @cPalletCnt
   BEGIN
      SET @nErrNo = 218756
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')   ---- Bad Pallet Qty
      GOTO Quit
   END

   INSERT INTO @ContainerDtl
              (containerkey,
               containerlinenumber)
      SELECT ctn.ContainerKey,
            dtl.ContainerLineNumber
      FROM dbo.CONTAINER ctn WITH(NOLOCK)
      INNER JOIN CONTAINERDETAIL dtl WITH(NOLOCK) ON ctn.ContainerKey = dtl.ContainerKey
      WHERE ctn.MBOLKey = @cMbolKey
      ORDER BY ctn.ContainerKey,
               dtl.ContainerLineNumber

   SET @cID = 0
   SET @c_RemainWeight = @cPalletWeight
   WHILE(1=1)
   BEGIN 
      SELECT TOP 1
            @cID = RowID,
            @cContainerKey = containerkey,
            @cContainerLineNumber = containerlinenumber
      FROM @ContainerDtl
      WHERE RowID > @cID
      ORDER BY RowID

      IF @@ROWCOUNT = 0 
      BEGIN
          BREAK
      END


      IF @cPalletQty = @cID
      BEGIN
         SELECT @c_weight = @c_RemainWeight
      END
      ELSE
      BEGIN
         SELECT @c_weight = FLOOR(CAST(@cPalletWeight AS FLOAT) / CAST(@cPalletQty AS INT ))

         SELECT @c_RemainWeight = @c_RemainWeight - @c_weight
      END

      UPDATE dbo.CONTAINERDETAIL WITH (ROWLOCK)
         SET Userdefine01 = @c_weight
       WHERE ContainerKey = @cContainerKey
         AND ContainerLineNumber = @cContainerLineNumber
   END


   Quit:

END -- END SP
GO

GRANT EXECUTE ON  [RDT].[rdt_593OutPLWgt01] TO [NSQL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
