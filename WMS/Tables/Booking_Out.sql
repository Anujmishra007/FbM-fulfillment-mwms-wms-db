CREATE TABLE [dbo].[Booking_Out]
(
[BookingNo] [int] NOT NULL,
[RouteAuth] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_RouteAuth] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_Facility] DEFAULT (''),
[BookingDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_Out_BookingDate] DEFAULT (getdate()),
[EndTime] [datetime] NOT NULL,
[Duration] [datetime] NOT NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_Type] DEFAULT (''),
[SCAC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_SCAC] DEFAULT (''),
[DriverName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LicenseNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_LoadKey] DEFAULT (' '),
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_MbolKey] DEFAULT (' '),
[CBOLKey] [int] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_Status] DEFAULT ('0'),
[ALTReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_ALTReference] DEFAULT (''),
[VehicleContainer] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_VehicleContainer] DEFAULT (''),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine10] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_Out_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_Out_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivedTime] [datetime] NULL,
[SignInTime] [datetime] NULL,
[UnloadTime] [datetime] NULL,
[DepartTime] [datetime] NULL,
[CallTime] [datetime] NULL,
[Loc2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrierkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_FinalizeFlag] DEFAULT ('N'),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOOKING_OUT_ToLoc] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrBooking_OutAdd                                           */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: 288370-Create booking audit record                          */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records inserted                                     */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author  Ver.  Purposes                                   */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrBooking_OutAdd]
ON  [dbo].[Booking_Out]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @b_Success              int       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err        int       -- Error number returned by stored procedure or this trigger
   ,         @n_err2       int       -- For Additional Error Detection
   ,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue   int
   ,         @n_starttcnt  int       -- Holds the current transaction count
   ,         @c_preprocess NVARCHAR(250) -- preprocess
   ,         @c_pstprocess NVARCHAR(250) -- post process
   ,         @n_cnt int
   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
      SET @n_continue = 4

   IF EXISTS( SELECT 1 FROM INSERTED WHERE TrafficCop = '9')
      SET @n_continue = 4

   IF @n_continue=1 OR @n_continue=2
   BEGIN      
      INSERT INTO Booking_Audit (BookingNo, BookingType, RouteAuth, Facility, BookingDate, EndTime, Duration, Loc, Type,
                                SCAC, DriverName, LicenseNo, LoadKey, MbolKey, CBOLKey, Status, ALTReference,
                                VehicleContainer, UserDefine01, UserDefine02, UserDefine03, UserDefine04,
                                UserDefine05, UserDefine06, UserDefine07, UserDefine08, UserDefine09,
                                UserDefine10, ArrivedTime, SignInTime, UnloadTime, DepartTime)
      SELECT BookingNo, 'OUT', RouteAuth, Facility, BookingDate, EndTime, Duration, Loc, Type,                                
             SCAC, DriverName, LicenseNo, LoadKey, MbolKey, CBOLKey, Status, ALTReference,                      
             VehicleContainer, UserDefine01, UserDefine02, UserDefine03, UserDefine04,       
             UserDefine05, UserDefine06, UserDefine07, UserDefine08, UserDefine09,           
             UserDefine10, ArrivedTime, SignInTime, UnloadTime, DepartTime
      FROM INSERTED        
   END

   QUIT_TR: 
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      execute nsp_logerror @n_err, @c_errmsg, "ntrBooking_OutAdd"
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrBooking_OutDelete                                        */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose:  SOS#322304 - PH - CPPI WMS Door Booking Enhancement        */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records Deleted                                      */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date       Author    Ver.     Purposes                               */
/* 19MAY2015  YTWan     1.1      SOS#341308 - PH CPPI Allow Deletion for*/
/*                               Finalized Booking (Wan01)              */   
/************************************************************************/

CREATE TRIGGER [dbo].[ntrBooking_OutDelete]
ON  [dbo].[Booking_Out]
FOR DELETE
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
            @b_Success        int       -- Populated by calls to stored procedures - was the proc successful?
   ,        @n_err            int       -- Error number returned by stored procedure or this trigger
   ,        @c_errmsg         NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,        @n_continue       int
   ,        @n_starttcnt      int       -- Holds the current transaction count

   ,        @n_BookingNo            INT
   ,        @c_Loadkey              NVARCHAR(10)   --(Wan01)
   ,        @c_finalizeflag         NVARCHAR(10)   --(Wan01)

   ,        @c_Facility             NVARCHAR(5)    --(Wan01)
   ,        @c_StorerKey            NVARCHAR(15)   --(Wan01)
   ,        @c_AllowDelFinalizedBKO NVARCHAR(10)   --(Wan01)
 
   SET @n_continue=1
   SET @n_starttcnt=@@TRANCOUNT

   IF (SELECT COUNT(1) FROM DELETED) =
      (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SET @n_continue = 4
   END
    
   IF (@n_continue=1 OR @n_continue=2) 
   BEGIN
      --(Wan01) - START  
      SET @n_BookingNo=0
      SET @c_Facility = ''
      SET @c_finalizeflag = ''
      SELECT @n_BookingNo    = ISNULL(DELETED.BookingNo,0)
            ,@c_Facility     = ISNULL(Facility,'')
            ,@c_finalizeflag = ISNULL(DELETED.finalizeflag,'N')
      FROM DELETED

      IF @c_finalizeflag = 'Y'
      BEGIN
         IF NOT EXISTS  (  SELECT 1       
                           FROM LOADPLAN WITH (NOLOCK)
                           WHERE LOADPLAN.BookingNo = @n_BookingNo
                        )
         BEGIN
            SET @n_continue = 3
            SET @n_err=74905   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Not allow to delete finalized booking. (ntrBooking_OutDelete)'
            GOTO QUIT_TR
         END
      END
   END


   IF (@n_continue=1 OR @n_continue=2) 
   BEGIN
--   
--      UPDATE LOADPLAN WITH (ROWLOCK)
--      SET BookingNo  = 0 
--        , TrafficCop = NULL
--        , EditDate   = GETDATE()
--        , EditWho    = SUSER_NAME()      
--      WHERE BookingNo = @n_BookingNo 
--     
--      IF @@ERROR <> 0
--      BEGIN
--         SET @n_continue = 3
--         SET @c_errmsg = CONVERT(CHAR(250),@n_err)
--         SET @n_err=74910   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
--         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Error on Booking_Out. (ntrBooking_OutDelete)'
--                      + ' ( ' + ' SQLSvr MESSAGE=' + RTrim(ISNULL(@c_errmsg,'')) + ' ) '
--         GOTO QUIT_TR
--      END

      DECLARE CUR_LOAD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Loadkey
      FROM LOADPLAN WITH (NOLOCK)  
      WHERE BookingNo = @n_BookingNo 

      OPEN CUR_LOAD

      FETCH NEXT FROM CUR_LOAD INTO @c_Loadkey
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF @c_finalizeflag = 'Y'
         BEGIN
            SET @c_Storerkey= ''
            SELECT TOP 1 @c_Storerkey = ORDERS.Storerkey
            FROM ORDERS WITH (NOLOCK)  
            WHERE ORDERS.Loadkey = @c_Loadkey

            SET @b_success = 0
            Execute nspGetRight 
                    @c_facility 
                  , @c_StorerKey               -- Storer
                  , ''                         -- Sku
                  , 'AllowDelFinalizedBKO'     -- ConfigKey
                  , @b_success                  OUTPUT 
                  , @c_AllowDelFinalizedBKO     OUTPUT 
                  , @n_err                      OUTPUT 
                  , @c_errmsg                   OUTPUT
            
            IF @b_success <> 1
            BEGIN
               SET @n_continue = 3
               SET @n_err = 74910
               SET @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Error getting Storerconfig AllowDelFinalizedBKO:' 
                             + RTRIM(@c_errmsg) + '. (ntrBooking_OutDelete)'
               GOTO QUIT_TR
            END
        
            IF @c_AllowDelFinalizedBKO = '1'
            BEGIN
               IF EXISTS (SELECT 1
                          FROM TASKDETAIL WITH (NOLOCK)
                          WHERE Loadkey = @c_Loadkey
                          AND Status <> 'X'
                         )
               BEGIN
                  SET @n_continue = 3
                  SET @n_err=74915  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Loadkey Released. Not allow to delete booking.'
                               +' (ntrBooking_OutDelete)'
                  GOTO QUIT_TR 
               END
            END
            ELSE
            BEGIN
               SET @n_continue = 3
               SET @n_err=74920  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Not allow to delete finalized booking.'
                            +' (ntrBooking_OutDelete)'
               GOTO QUIT_TR   
            END
         END

         SET @b_Success = 0  
         EXEC dbo.ispBookingOutLoadDelete 
                 @c_Loadkey = @c_Loadkey
               , @b_Success = @b_Success     OUTPUT  
               , @n_Err     = @n_err         OUTPUT   
               , @c_ErrMsg  = @c_errmsg      OUTPUT  

         IF @n_err <> 0 OR @b_Success <> 1 
         BEGIN 
            SET @n_Continue= 3 
            SET @b_Success = 0
            SET @n_err  = 74925
            SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Fail to Exec ispBookingOutLoadDelete.'
                          + '(' + @c_errmsg + ') (ntrBooking_OutDelete)'

            GOTO QUIT_TR
         END   

         FETCH NEXT FROM CUR_LOAD INTO @c_Loadkey
      END
      CLOSE CUR_LOAD
      DEALLOCATE CUR_LOAD 
      ----(Wan01) - END               
   END
   QUIT_TR:

   IF CURSOR_STATUS('LOCAL' , 'CUR_LOAD') in (0 , 1)
   BEGIN
      CLOSE CUR_LOAD
      DEALLOCATE CUR_LOAD
   END
   
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
          WHILE @@TRANCOUNT > @n_starttcnt
          BEGIN
             COMMIT TRAN
          END
      END

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrBooking_OutDelete'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
       COMMIT TRAN
      END
      RETURN
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrBooking_OutUpdate                                        */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records Updated                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.    Purposes                              */
/* 25-SEP-2013 NJOW01  1.0   288370-Create booking audit record         */   
/* 28-Oct-2013  TLTING    1.1     Review Editdate column update         */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrBooking_OutUpdate]
ON  [dbo].[Booking_Out]
FOR UPDATE
AS
BEGIN
	IF @@ROWCOUNT = 0
	BEGIN
		RETURN
	END   
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @b_Success              int       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err        int       -- Error number returned by stored procedure or this trigger
   ,         @n_err2       int       -- For Additional Error Detection
   ,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue   int
   ,         @n_starttcnt  int       -- Holds the current transaction count
   ,         @c_preprocess NVARCHAR(250) -- preprocess
   ,         @c_pstprocess NVARCHAR(250) -- post process
   ,         @n_cnt int
   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 OR @n_continue = 2   
   BEGIN  
      --NJOW01  
      INSERT INTO Booking_Audit (BookingNo, BookingType, RouteAuth, Facility, BookingDate, EndTime, Duration, Loc, Type,  
                                SCAC, DriverName, LicenseNo, LoadKey, MbolKey, CBOLKey, Status, ALTReference,  
                                VehicleContainer, UserDefine01, UserDefine02, UserDefine03, UserDefine04,  
                                UserDefine05, UserDefine06, UserDefine07, UserDefine08, UserDefine09,  
                                UserDefine10, ArrivedTime, SignInTime, UnloadTime, DepartTime)  
      SELECT BookingNo, 'OUT', RouteAuth, Facility, BookingDate, EndTime, Duration, Loc, Type,                                  
             SCAC, DriverName, LicenseNo, LoadKey, MbolKey, CBOLKey, Status, ALTReference,                        
             VehicleContainer, UserDefine01, UserDefine02, UserDefine03, UserDefine04,         
             UserDefine05, UserDefine06, UserDefine07, UserDefine08, UserDefine09,             
             UserDefine10, ArrivedTime, SignInTime, UnloadTime, DepartTime  
      FROM INSERTED          
   END  
      
   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE BOOKING_OUT with (ROWLOCK)
      SET EditWho = sUser_sName(),
          EditDate = GetDate()
      FROM BOOKING_OUT 
      JOIN INSERTED ON BOOKING_OUT.BookingNo = INSERTED.BookingNo
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BOOKING_OUT. (ntrBooking_OutUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END      
   END
   
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
	   IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
	   BEGIN
	  	 ROLLBACK TRAN
	   END
	   ELSE
	   BEGIN
	  	 WHILE @@TRANCOUNT > @n_starttcnt
	  	 BEGIN
	  		 COMMIT TRAN
	  	 END
	   END
   
	   EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrBooking_OutUpdate"
	   RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
	   RETURN
   END
   ELSE
   BEGIN
	   WHILE @@TRANCOUNT > @n_starttcnt
	   BEGIN
	  	 COMMIT TRAN
	   END
	   RETURN
   END
END

GO
ALTER TABLE [dbo].[Booking_Out] ADD CONSTRAINT [PK_Booking_Out] PRIMARY KEY CLUSTERED ([BookingNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Booking_Out] ADD CONSTRAINT [FK_Booking_Out_LOC] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
GRANT SELECT ON  [dbo].[Booking_Out] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[Booking_Out] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Booking_Out] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Booking_Out] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Booking_Out] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Loc', 'SCHEMA', N'dbo', 'TABLE', N'Booking_Out', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To Loc', 'SCHEMA', N'dbo', 'TABLE', N'Booking_Out', 'COLUMN', N'ToLoc'
GO
