
/************************************************************************/
/* Store procedure: rdt_1642ExtValT                                     */
/*                                                                      */
/* Purpose: Display fINal locatiON                                      */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2015-07-13 1.0  PPA374   Checks that place of loadINg is a door      */
/* 2024-05-28 1.1  TAK047   Add Storerkey as conditiON (CLVN01)         */
/* 2024-06-26 1.2  AGA399   Add Load Sequence as conditiON              */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1642ExtValVLT] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nINputKey    INT,
   @cDropID      NVARCHAR( 20),
   @cMbolKey     NVARCHAR( 10),
   @cDoor        NVARCHAR( 20),
   @cOptiON      NVARCHAR( 1),
   @cRSNCode     NVARCHAR( 10),
   @nAfterStep   INT,
   @nErrNo       INT OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
) AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE
   @Orderkey       NVARCHAR(20),
   @FullyPicked    INT,
   @AtStage        INT,
   @FullyPacked    INT,
   @loadSequenceOk INT,
   @GotSequence    NVARCHAR(10),
   @GotNOSequence  NVARCHAR(10),
   @DropIDSequence NVARCHAR(10),
   @NextSequence   NVARCHAR(10),
   @Storerkey      NVARCHAR(20),
   @Facility       NVARCHAR(20)

SELECT TOP 1 @Storerkey = storerkey FROM rdt.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile
SELECT TOP 1 @Facility = Facility FROM rdt.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile

IF @nFunc = 1642 AND @nStep = 1 AND @nInputKey = 1
   IF ISNULL(@cDropID,'') <> ''
   BEGIN
      IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
	  BEGIN
         SELECT TOP 1 @Orderkey = OrderKey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE PickHeaderKey = (SELECT TOP 1 PickSlipNo FROM dbo.PackDetail WITH(NOLOCK) WHERE storerkey = @Storerkey AND dropid = @cDropID)
	  END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
	  BEGIN
         IF ISNULL(@Orderkey,'')='' AND EXISTS (SELECT 1 FROM dbo.Dropiddetail WITH(NOLOCK) WHERE Dropid = @cDropID)
         BEGIN
            SELECT TOP 1 @Orderkey = OrderKey FROM dbo.ORDERS O WITH(NOLOCK)
            WHERE StorerKey = @Storerkey AND facility = @Facility
            AND EXISTS (SELECT 1 FROM dbo.PICKHEADER PH WITH(NOLOCK)
            WHERE O.orderkey = PH.OrderKey
            AND EXISTS (SELECT 1 FROM dbo.PackDetail PD WITH(NOLOCK)
            WHERE PD.PickSlipNo = PickHeaderKey AND storerkey = @Storerkey
            AND EXISTS (SELECT ChildId FROM dbo.DropidDetail DD WITH(NOLOCK) WHERE PD.dropid = DD.ChildId AND DD.Dropid = @cDropID)))
            ORDER BY CASE WHEN ISNULL(OrderGroup,'')='' THEN '9999999' ELSE ISNULL(OrderGroup,'') END
         END
      END

      IF ISNULL(@Orderkey,'') = ''
      BEGIN
         SET @nErrNo = 218020
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'No order ID found'
         GOTO Quit
      END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
	  BEGIN
	     SET @FullyPicked = CASE WHEN (SELECT SUM(openqty)-SUM(QtyPicked) FROM dbo.ORDERDETAIL WITH(NOLOCK) WHERE OrderKey = @Orderkey AND StorerKey = @Storerkey) = 0 THEN 1 ELSE 0 END
	  END

      IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
      BEGIN
        SET @FullyPicked = CASE WHEN
        (SELECT SUM(openqty)-SUM(QtyPicked) FROM dbo.ORDERDETAIL OD WITH(NOLOCK) WHERE EXISTS
        (SELECT 1 FROM dbo.PICKDETAIL PID WITH(NOLOCK) WHERE OD.OrderKey = PID.OrderKey
        AND EXISTS (SELECT 1 FROM dbo.PackDetail PAD WITH(NOLOCK) WHERE PID.Dropid = PAD.RefNo2
        AND EXISTS (SELECT 1 FROM dbo.DropidDetail DD WITH(NOLOCK) WHERE PAD.dropid = DD.ChildId AND Dropid = @cDropID)))
        AND StorerKey = @Storerkey) = 0 THEN 1 ELSE 0 END
      END

      SELECT TOP 1 @DropIDSequence = OrderGroup FROM dbo.ORDERS WITH(NOLOCK) WHERE OrderKey = @Orderkey AND StorerKey = @Storerkey

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
	  BEGIN
         SET @AtStage = CASE WHEN EXISTS(
         SELECT Loc FROM dbo.PICKDETAIL PD WITH(NOLOCK)
         WHERE OrderKey = @Orderkey
         AND Storerkey = @Storerkey
         AND LOC NOT IN
         (SELECT OtherReference FROM dbo.MBOL WITH(NOLOCK)
         WHERE Facility = @Facility
         AND MbolKey = (SELECT TOP 1 MbolKey FROM dbo.ORDERS WITH(NOLOCK) WHERE OrderKey = @Orderkey AND StorerKey = @Storerkey))
         ) THEN 0 ELSE 1 END
	  END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
	  BEGIN
	     SET @AtStage = CASE WHEN EXISTS(
         SELECT 1 FROM dbo.PICKDETAIL PD WITH(NOLOCK)
         WHERE OrderKey in 
         (SELECT OrderKey FROM PICKDETAIL PD1 WITH(NOLOCK)
         WHERE EXISTS
         (SELECT childid FROM DropidDetail DD1 WITH(NOLOCK)
         WHERE PD1.Dropid = DD1.ChildId
         AND EXISTS
         (SELECT 1 FROM DropidDetail DD2 WITH(NOLOCK)
         WHERE DD1.dropid = DD2.Dropid
         AND EXISTS
         (SELECT 1 FROM PICKDETAIL PD2 WITH(NOLOCK)
         WHERE DD2.ChildId = PD2.DropID
         AND PD2.OrderKey = @Orderkey
         AND PD2.Storerkey = @Storerkey))))
         AND Storerkey = @Storerkey
         AND LOC NOT IN
         (SELECT OtherReference FROM dbo.MBOL WITH(NOLOCK)
         WHERE Facility = @Facility
         AND MbolKey IN (SELECT MbolKey FROM dbo.ORDERS WITH(NOLOCK) WHERE OrderKey IN 
         (SELECT OrderKey FROM PICKDETAIL PD1 WITH(NOLOCK)
         WHERE EXISTS
         (SELECT childid FROM DropidDetail DD1 WITH(NOLOCK)
         WHERE PD1.Dropid = DD1.ChildId
         AND EXISTS
         (SELECT 1 FROM DropidDetail DD2 WITH(NOLOCK)
         WHERE DD1.dropid = DD2.Dropid
         AND EXISTS
         (SELECT 1 FROM PICKDETAIL PD2 WITH(NOLOCK)
         WHERE DD2.ChildId = PD2.DropID
         AND PD2.OrderKey = @Orderkey
         AND PD2.Storerkey = @Storerkey))))
         AND StorerKey = @Storerkey))
         )THEN 0 ELSE 1 END
      END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
	  BEGIN   
		 SET @FullyPacked = CASE WHEN (
         SELECT ISNULL(SUM(openqty),0) FROM dbo.ORDERDETAIL WITH(NOLOCK)
         WHERE OrderKey = @Orderkey AND StorerKey = @Storerkey
         )=(SELECT ISNULL(SUM(qty),0) FROM dbo.PackDetail WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND PickSlipNo = (SELECT TOP 1 PickSlipNo FROM dbo.PackDetail WITH(NOLOCK) WHERE StorerKey = @Storerkey AND dropid = @cDropID))
         THEN 1 ELSE 0 END
      END

      IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
      BEGIN
	     SET @FullyPacked = CASE WHEN
	     (SELECT ISNULL(SUM(OpenQty),0) FROM dbo.ORDERDETAIL OD WITH(NOLOCK) WHERE EXISTS
		 (SELECT 1 FROM dbo.PICKDETAIL PID WITH(NOLOCK) WHERE OD.OrderKey = PID.OrderKey
		 AND EXISTS (SELECT 1 FROM dbo.PackDetail PAD WITH(NOLOCK) WHERE PID.Dropid = PAD.RefNo2
		 AND EXISTS (SELECT 1 FROM dbo.DropidDetail DD WITH(NOLOCK) WHERE PAD.dropid = DD.ChildId AND Dropid = @cDropID)))
		 AND StorerKey = @Storerkey)
	      =
	     (SELECT ISNULL(SUM(qty),0) FROM dbo.PackDetail PAD WITH(NOLOCK)
	     WHERE StorerKey = @Storerkey AND EXISTS
	     (SELECT PickSlipNo FROM dbo.PackDetail PAD2 WITH(NOLOCK) WHERE PAD.PickSlipNo = PAD2.PickSlipNo AND StorerKey = @Storerkey AND EXISTS
		 (SELECT 1 FROM dbo.DropidDetail DD WITH(NOLOCK) WHERE PAD2.dropid = DD.ChildId AND Dropid = @cDropID)))
	     THEN 1 ELSE 0 END
	   END
      
	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
	  BEGIN
         SET @GotSequence = CASE WHEN EXISTS
	     (SELECT OrderGroup FROM dbo.ORDERS WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND orderkey IN
         (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
         WHERE WaveKey IN
         (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
         JOIN dbo.Orders O WITH(NOLOCK)
         ON O.OrderKey = WD.OrderKey
         JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
         ON PID.OrderKey = O.OrderKey
         JOIN dbo.PackDetail PAD WITH(NOLOCK)
         ON PID.dropid = PAD.RefNo2
         WHERE PAD.DropID = @cDropID
         AND O.Storerkey = @Storerkey)
         AND ISNUMERIC(OrderGroup)=1)
         AND Status < '8'
	     ) THEN 1 ELSE 0 END
	  END

      IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
	  BEGIN
         SET @GotSequence = CASE WHEN EXISTS
	     (SELECT OrderGroup FROM dbo.ORDERS WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND orderkey IN
         (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
         WHERE WaveKey IN
         (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
         JOIN dbo.Orders O WITH(NOLOCK)
         ON O.OrderKey = WD.OrderKey
         JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
         ON PID.OrderKey = O.OrderKey
         JOIN dbo.PackDetail PAD WITH(NOLOCK)
         ON PID.dropid = PAD.RefNo2
         WHERE PAD.DropID = (SELECT TOP 1 ChildId FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)
         AND O.Storerkey = @Storerkey)
         AND ISNUMERIC(OrderGroup)=1)
         AND Status < '8'
	     ) THEN 1 ELSE 0 END
      END

      SET @GotNOSequence = IIF(@GotSequence = 1,0,1)
	  /*CASE WHEN EXISTS
	  (
	  SELECT OrderGroup FROM ORDERS WITH(NOLOCK)
	  WHERE StorerKey = @Storerkey
	  AND orderkey IN
	  (SELECT OrderKey FROM WAVEDETAIL WITH(NOLOCK)
	  WHERE WaveKey IN
	  (SELECT TOP 1 wd.WaveKey FROM WAVEDETAIL WD WITH(NOLOCK)
	  JOIN Orders O WITH(NOLOCK)
	  ON O.OrderKey = WD.OrderKey
	  JOIN PICKDETAIL PID WITH(NOLOCK)
	  ON PID.OrderKey = O.OrderKey
	  JOIN PackDetail PAD WITH(NOLOCK)
	  ON PID.dropid = PAD.RefNo2
	  WHERE PAD.DropID = CASE WHEN (SELECT TOP 1 DropIDType FROM dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B' THEN @cDropID
	  ELSE (SELECT TOP 1 ChildId FROM DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID) END
	  AND O.Storerkey = @Storerkey)
	  AND ISNUMERIC(OrderGroup)=0)
	  AND Status < '8'
	  ) THEN 1 ELSE 0 END*/

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
	  BEGIN
         IF EXISTS
         (SELECT OrderGroup FROM dbo.ORDERS WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND OrderKey IN
         (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
         WHERE WaveKey IN
         (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
         INNER JOIN dbo.Orders O WITH(NOLOCK)
         ON O.OrderKey = WD.OrderKey
         INNER JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
         ON PID.OrderKey = O.OrderKey
         INNER JOIN dbo.PackDetail PAD WITH(NOLOCK)
         ON PID.dropid = PAD.RefNo2
         WHERE PAD.DropID = @cDropID
         AND O.Storerkey = @Storerkey)
         AND ISNUMERIC(OrderGroup)=0
         AND ISNULL(OrderGroup,'') <> ''))
         BEGIN
            SET @nErrNo = 217992
		    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Non-numeric sequence
		    GOTO Quit
	     END
      END

	   IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
	   BEGIN
	      IF EXISTS
          (SELECT OrderGroup FROM dbo.ORDERS WITH(NOLOCK)
          WHERE StorerKey = @Storerkey
          AND OrderKey IN
          (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
          WHERE WaveKey IN
          (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
          INNER JOIN dbo.Orders O WITH(NOLOCK)
          ON O.OrderKey = WD.OrderKey
          INNER JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
          ON PID.OrderKey = O.OrderKey
          INNER JOIN dbo.PackDetail PAD WITH(NOLOCK)
          ON PID.dropid = PAD.RefNo2
          WHERE PAD.DropID = (SELECT TOP 1 ChildId FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)
          AND O.Storerkey = @Storerkey)
          AND ISNUMERIC(OrderGroup)=0
          AND ISNULL(OrderGroup,'') <> ''))
          BEGIN
            SET @nErrNo = 217992
		    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Non-numeric sequence
		    GOTO Quit
	      END
      END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
      BEGIN
	     SELECT TOP 1 @NextSequence = OrderGroup FROM dbo.ORDERS WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND OrderKey IN
         (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
         WHERE WaveKey IN
         (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
         INNER JOIN dbo.Orders O WITH(NOLOCK)
         ON O.OrderKey = WD.OrderKey
         INNER JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
         ON PID.OrderKey = O.OrderKey
         INNER JOIN dbo.PackDetail PAD WITH(NOLOCK)
         ON PID.dropid = PAD.RefNo2
         WHERE PAD.DropID = @cDropID
         AND O.Storerkey = @Storerkey)
         AND Status <'8')
         ORDER BY CASE WHEN ISNULL(OrderGroup,'') = '' THEN 'Y' ELSE ISNULL(OrderGroup,'') END
      END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
	  BEGIN
	     SELECT TOP 1 @NextSequence = OrderGroup FROM dbo.ORDERS WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND OrderKey IN
         (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
         WHERE WaveKey IN
         (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
         INNER JOIN dbo.Orders O WITH(NOLOCK)
         ON O.OrderKey = WD.OrderKey
         INNER JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
         ON PID.OrderKey = O.OrderKey
         INNER JOIN dbo.PackDetail PAD WITH(NOLOCK)
         ON PID.dropid = PAD.RefNo2
         WHERE PAD.DropID = (SELECT TOP 1 ChildId FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)
         AND O.Storerkey = @Storerkey)
         AND Status <'8')
         ORDER BY CASE WHEN ISNULL(OrderGroup,'') = '' THEN 'Y' ELSE ISNULL(OrderGroup,'') END
      END

	  /*IF @GotSequence = 1 AND @GotNOSequence = 1
	  BEGIN
         SET @nErrNo = 217993
		 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MissINg sequence
		 GOTO Quit
	  END*/

      IF @GotNOSequence = 1
      BEGIN
         SET @loadSequenceOk = 1
         GOTO skip1
      END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <> 'B'
	  BEGIN
         IF EXISTS
         (SELECT CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END FROM dbo.ORDERS WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND OrderKey IN
         (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
         WHERE WaveKey IN
         (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
         INNER JOIN dbo.Orders O WITH(NOLOCK)
         ON O.OrderKey = WD.OrderKey
         INNER JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
         ON PID.OrderKey = O.OrderKey
         INNER JOIN dbo.PackDetail PAD WITH(NOLOCK)
         ON PID.dropid = PAD.RefNo2
         WHERE PAD.DropID = @cDropID
         AND O.Storerkey = @Storerkey)
         AND ISNUMERIC(OrderGroup)=1)
         GROUP BY OrderGroup
         HAVING CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END >0)
         BEGIN
            SET @nErrNo = 217994
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Duplicated sequence
            GOTO Quit
         END
      END

	  IF (SELECT DropIDType FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'B'
	  BEGIN
	     IF EXISTS
         (SELECT CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END FROM dbo.ORDERS WITH(NOLOCK)
         WHERE StorerKey = @Storerkey
         AND OrderKey IN
         (SELECT OrderKey FROM dbo.WAVEDETAIL WITH(NOLOCK)
         WHERE WaveKey IN
         (SELECT TOP 1 wd.WaveKey FROM dbo.WAVEDETAIL WD WITH(NOLOCK)
         INNER JOIN dbo.Orders O WITH(NOLOCK)
         ON O.OrderKey = WD.OrderKey
         INNER JOIN dbo.PICKDETAIL PID WITH(NOLOCK)
         ON PID.OrderKey = O.OrderKey
         INNER JOIN dbo.PackDetail PAD WITH(NOLOCK)
         ON PID.dropid = PAD.RefNo2
         WHERE PAD.DropID = (SELECT TOP 1 ChildId FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)
         AND O.Storerkey = @Storerkey)
         AND ISNUMERIC(OrderGroup)=1)
         GROUP BY OrderGroup
         HAVING CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END >0)
         BEGIN
            SET @nErrNo = 217994
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Duplicated sequence
            GOTO Quit
         END
      END

	  IF @DropIDSequence <> @NextSequence
      BEGIN
         SET @loadSequenceOk = 0
      END

      skip1:
      IF @nStep = 1 AND (SELECT TOP 1 LocationType FROM dbo.LOC WITH(NOLOCK) WHERE loc = @cDoor AND Facility = @Facility) <> 'DOOR'
      BEGIN
         SET @nErrNo = 217995
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc is NOT a door
         GOTO Quit
      END

      ELSE IF @nStep = 1 AND @FullyPicked = 0
      BEGIN
         SET @nErrNo = 217996
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NOT all items picked
         GOTO Quit
      END

      ELSE IF @nStep = 1 AND @AtStage = 0
      BEGIN
         SET @nErrNo = 217997
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NOT fully staged
         GOTO Quit
      END

      ELSE IF @nStep = 1 AND @FullyPacked = 0
      AND (1 IN (SELECT Short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQPCKALL' AND Storerkey = @Storerkey)
      AND 0 NOT IN (SELECT Short FROM dbo.CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'HUSQPCKALL' AND Storerkey = @Storerkey))
      BEGIN
         SET @nErrNo = 217998
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NOT all items packed
         GOTO Quit
      END

      --Error mesg IN CASE Load sequence is NOT correct
      IF @nStep = 1 AND @loadSequenceOk = 0
      BEGIN
         SET @nErrNo = 217999
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Out of Sequence
         GOTO Quit
      END

   Quit:

END
END

GRANT EXECUTE ON [RDT].[rdt_1642ExtValVLT] TO [NSQL]
GO
