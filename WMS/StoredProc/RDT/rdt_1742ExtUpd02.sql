SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1742ExtUpd02                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Update wave staging LOC                                     */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2023-10-13  1.0  Ung      WMS-23390 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1742ExtUpd02]
(
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR(3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR(5),
   @cStorerKey       NVARCHAR(15),
   @cDropID          NVARCHAR(20),
   @cSuggLOC         NVARCHAR(10),
   @cPickAndDropLOC  NVARCHAR(10),
   @cToLOC           NVARCHAR(10),
   @nErrNo           INT OUTPUT,
   @cErrMsg          NVARCHAR(200) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON

   IF @nFunc = 1742
   BEGIN
      IF @nStep IN (2, 3)
      BEGIN
         IF EXISTS (
            SELECT 1
            FROM dbo.LOC WITH (NOLOCK)
            WHERE LOC = @cToLOC
              AND LOCATIONTYPE = 'LANE'
              AND FACILITY = @cFacility
         )
         BEGIN
            DECLARE
               @n_Exists           INT = 0,
               @c_PreSale_Flag     NVARCHAR(50),
               @c_Status           NVARCHAR(50),
               @c_SOStatus         NVARCHAR(50),
               @c_Orderkey         NVARCHAR(50),
               @c_Type             NVARCHAR(50),
               @c_ConsigneeKey     NVARCHAR(50),
               @c_ShipperKey       NVARCHAR(50),
               @c_MBOLKey          NVARCHAR(50),
               @cLoadKey           NVARCHAR(50),
               @cIntermodalVehicle NVARCHAR(50),
               @cTrackingNo        NVARCHAR(50),
               @b_Success          INT,
               @n_Err              INT,
               @n_RecordId         NVARCHAR(10),
               @c_ErrMsg           NVARCHAR(1000)

            -- Fetch order data
            SELECT TOP 1
               @n_Exists           = 1,
               @c_PreSale_Flag     = ISNULL(RTRIM(O.ECOM_PRESALE_FLAG), ''),
               @c_Status           = ISNULL(RTRIM(O.Status), ''),
               @c_SOStatus         = ISNULL(RTRIM(O.SOStatus), ''),
               @c_Orderkey         = ISNULL(RTRIM(O.OrderKey), ''),
               @c_Type             = ISNULL(RTRIM(O.Type), ''),
               @c_ConsigneeKey     = ISNULL(RTRIM(O.ConsigneeKey), ''),
               @c_ShipperKey       = ISNULL(RTRIM(O.ShipperKey), ''),
               @c_MBOLKey          = ISNULL(RTRIM(O.MBOLKey), ''),
               @cLoadKey           = ISNULL(RTRIM(O.LoadKey), ''),
               @cFacility          = ISNULL(RTRIM(O.Facility), ''),
               @cIntermodalVehicle = ISNULL(RTRIM(O.IntermodalVehicle), ''),
               @cTrackingNo        = ISNULL(RTRIM(O.TrackingNo), '')
            FROM dbo.Orders O WITH (NOLOCK)
            JOIN dbo.ORDERDETAIL OD WITH (NOLOCK)
               ON O.STORERKEY = OD.STORERKEY
              AND O.ORDERKEY = OD.ORDERKEY
            JOIN dbo.PICKDETAIL PD WITH (NOLOCK)
               ON OD.STORERKEY = PD.STORERKEY
              AND OD.ORDERKEY = PD.ORDERKEY
              AND OD.SKU = PD.SKU
            WHERE PD.DropID = @cDropID
              AND PD.Status = '5'
              AND ISNULL(O.MBOLKEY, '') = ''

            IF @n_Exists = 1
            BEGIN
               SET @c_MBOLKey = NULL
               SET @n_Exists = 0

               -- Check existing MBOL
               SELECT TOP 1
                  @n_Exists  = 1,
                  @c_MBOLKey = MbolKey
               FROM dbo.MBOL WITH (NOLOCK)
               WHERE Carrieragent = @c_ShipperKey
                 AND UserDefine01 = @c_ConsigneeKey
                 AND UserDefine03 = @c_Type
                 AND Status = '0'
                 AND Facility = @cFacility
                 AND ISNULL(FinalizeFlag, '') <> 'Y'

               -- Create new MBOL if not exists
               IF @n_Exists = 0
               BEGIN
                  EXEC dbo.nspg_getkey
                     'MBOL',
                     10,
                     @c_MBOLKey OUTPUT,
                     @b_Success OUTPUT,
                     @n_Err OUTPUT,
                     @c_ErrMsg OUTPUT

                  IF @b_Success = 0
                  BEGIN
                     SET @nErrNo = 90004
                     SET @cErrMsg = 'Unable To Get MBOLKey'
                     RETURN
                  END

                  INSERT INTO dbo.MBOL (
                     MbolKey, Status, Facility, ExternMbolKey,
                     Carrieragent, UserDefine01, UserDefine03,
                     UserDefine04, UserDefine05
                  )
                  VALUES (
                     @c_MBOLKey, '0', @cFacility, '',
                     @c_ShipperKey, @c_ConsigneeKey, @c_Type,
                     @cIntermodalVehicle, @cTrackingNo
                  )

                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 68115
                     SET @cErrMsg = 'Insert MBOL failed'
                     RETURN
                  END
               END

               -- Get next line number
               SELECT @n_RecordId = RIGHT('00000' +
                  CAST(ISNULL(MAX(CAST(MBOLLineNumber AS INT)), 0) + 1 AS NVARCHAR), 5)
               FROM dbo.MBOLDETAIL WITH (NOLOCK)
               WHERE MBOLKEY = @c_MBOLKey

               -- Insert MBOL detail
               INSERT INTO dbo.MBOLDETAIL (
                  MBOLKey,
                  MBOLLineNumber,
                  OrderKey,
                  LoadKey,
                  AddWho,
                  EditWho
               )
               VALUES (
                  @c_MBOLKey,
                  @n_RecordId,
                  @c_Orderkey,
                  @cLoadKey,
                  SUSER_SNAME(),
                  SUSER_SNAME()
               )

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 68115
                  SET @cErrMsg = 'Insert MBOLDetail failed'
                  RETURN
               END
            END
         END
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1742ExtUpd02] TO NSQL
GO
