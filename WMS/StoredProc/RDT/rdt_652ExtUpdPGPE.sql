/******************************************************************************/
/* Store procedure: rdt_652ExtUpdPGPE                                         */
/* Copyright      : LF Logistics                                              */
/* Customer       : PGPE                                                      */
/*                                                                            */
/* Purpose: Update Door Dock Booking Status                                   */
/*                                                                            */
/* Activity Tracker      AT Status            DDB Status                      */
/* ------------------    ----------------     ----------                      */
/* 1.- Docking           1.- Arrival          1.- Check in                    */
/* 2.- Unloading         1.- Start            2.- Loading                     */
/* 2.- Unloading         9.- End              3.- Loaded                      */
/* 1.- Docking           9.- Departure        9.- Completed                   */
/* 3.- Loading Docking   1.- Start Loading    4.- Arrived                     */
/* 4.- Loading           1.- Start            2.- Loading                     */
/* 4.- Loading           9.- End              3.- Loaded                      */
/* 3.- Loading Docking   9.- End Loading      9.- Completed                   */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-05-12   MLR024    1.0   RITM9002118/UWP-61807 Created                 */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_652ExtUpdPGPE]
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cStorerKey       NVARCHAR( 15),
   @cFacility        NVARCHAR( 5),
   @cContainerNo     NVARCHAR( 20),
   @cAppointmentNo   NVARCHAR( 20), --Booking No
   @cMenuOption      NVARCHAR( 10),
   @cActionType      NVARCHAR( 10),
   @cRefNo1          NVARCHAR( 10),
   @cDefaultOption   NVARCHAR( 10),
   @cDefaultCursor   NVARCHAR( 10),
   @cActivityStatus  NVARCHAR( 20), --1=Arrival/Start, 9=Departure/End
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_652ExtUpdPGPE

   IF @nFunc = 652
   BEGIN
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cMenuOption = '1' -- Docking
            BEGIN
               IF @cActivityStatus = '1' -- Arrival
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_In WITH (ROWLOCK)
                     SET Status = '1', ArrivedTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275060
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkInArrFail
                     GOTO RollBackTran
                  END CATCH
               END
               IF @cActivityStatus = '9' -- Departure
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_In WITH (ROWLOCK)
                     SET Status = '9', DepartTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275061
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkInDepFail
                     GOTO RollBackTran
                  END CATCH
               END
            END

            IF @cMenuOption = '2' -- Unloading
            BEGIN
               IF @cActivityStatus = '1' -- Start
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_In WITH (ROWLOCK)
                     SET Status = '2', SignInTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275062
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkInStrtFail
                     GOTO RollBackTran
                  END CATCH
               END
               IF @cActivityStatus = '9' -- End
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_In WITH (ROWLOCK)
                     SET Status = '3', UnloadTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275063
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkInEndFail
                     GOTO RollBackTran
                  END CATCH
               END
            END

            IF @cMenuOption = '3' -- Loading Docking
            BEGIN
               IF @cActivityStatus = '1' -- Start Loading
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_Out WITH (ROWLOCK)
                     SET Status = '4', ArrivedTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275064
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkOutArrFail
                     GOTO RollBackTran
                  END CATCH
               END
               IF @cActivityStatus = '9' -- End Loading
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_Out WITH (ROWLOCK)
                     SET Status = '9', DepartTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275065
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkOutDepFail
                     GOTO RollBackTran
                  END CATCH
               END
            END

            IF @cMenuOption = '4' -- Loading
            BEGIN
               IF @cActivityStatus = '1' -- Start
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_Out WITH (ROWLOCK)
                     SET Status = '2', SignInTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275066
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkOutStrtFail
                     GOTO RollBackTran
                  END CATCH
               END
               IF @cActivityStatus = '9' -- End
               BEGIN
                  BEGIN TRY
                     UPDATE dbo.Booking_Out WITH (ROWLOCK)
                     SET Status = '3', UnloadTime = GETDATE()
                     WHERE BookingNo = @cAppointmentNo
                        AND Facility = @cFacility
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 275067
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdBkOutEndFail
                     GOTO RollBackTran
                  END CATCH
               END
            END
         END
      END
   END

   COMMIT TRAN rdt_652ExtUpdPGPE
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_652ExtUpdPGPE
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

GRANT EXECUTE ON [RDT].[rdt_652ExtUpdPGPE] TO [NSQL]
GO
