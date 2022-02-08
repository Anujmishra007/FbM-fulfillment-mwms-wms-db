CREATE TABLE [dbo].[FACILITY]
(
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine05] DEFAULT (' '),
[UserDefine06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine06] DEFAULT (' '),
[UserDefine07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine07] DEFAULT (' '),
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine10] DEFAULT (' '),
[UserDefine11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine11] DEFAULT (' '),
[UserDefine12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine12] DEFAULT (' '),
[UserDefine13] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine13] DEFAULT (' '),
[UserDefine14] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine14] DEFAULT (' '),
[UserDefine15] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine15] DEFAULT (' '),
[UserDefine16] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine16] DEFAULT (' '),
[UserDefine17] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine17] DEFAULT (' '),
[UserDefine18] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine18] DEFAULT (' '),
[UserDefine19] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine19] DEFAULT (' '),
[UserDefine20] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_UserDefine20] DEFAULT (' '),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FACILITY_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_FACILITY_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FACILITY_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_FACILITY_EditDate] DEFAULT (getdate()),
[TMS_Interface] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Facility_TMS_Interface] DEFAULT (' '),
[Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FACILITY_Type] DEFAULT (' '),
[SqFeet] [int] NOT NULL CONSTRAINT [DF_FACILITY_SqFeet] DEFAULT ((0)),
[Longitude] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_Longitude] DEFAULT (' '),
[Latitude] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_Latitude] DEFAULT (' '),
[NoOfDoors] [int] NULL CONSTRAINT [DF_Facility_NoOfDoors] DEFAULT ('0'),
[LeaseType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationHours] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FacilityFor] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FACILITY_FacilityFor] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrFACILITYDelete                                           */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  Facility delete trigger                                    */
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
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author     Ver.  Purposes                               */
/* 14-Jul-2011  KHLim02    1.0   GetRight for Delete log                */
/* 02-May-2018  NJOW01     1.1   WMS-4914 facility delete validation    */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrFACILITYDelete]
ON [dbo].[FACILITY]
FOR DELETE
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
           ,@c_authority   NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
-- if (select count(*) from DELETED) =
-- (select count(*) from DELETED where DELETED.ArchiveCop = '9')
-- BEGIN
--    SELECT @n_continue = 4
-- END
      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrFACILITYDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.FACILITY_DELLOG ( Facility )
         SELECT Facility FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table FACILITY Failed. (ntrFACILITYDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
 
   --NJOW01
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
   	  IF EXISTS(SELECT 1 
   	            FROM DELETED 
   	            JOIN LOC (NOLOCK) ON DELETED.Facility = LOC.Facility)
   	  BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Facility refer by location. Not allow to delete. (ntrFACILITYDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
   	  END          
   END
   
      /* #INCLUDE <TRCOND2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrFACILITYDelete'
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
/* Trigger: ntrFacilityUpdate                                           */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Update Facility.                                           */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */
/* 28-Oct-2013  TLTING   1.1  Review Editdate column update             */  
/* 26-Jun-2018  NJOW01   1.0  WMS-5221 disallow update type to PHYSICAL */
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrFacilityUpdate]  
ON  [dbo].[FACILITY]   
FOR UPDATE  
AS  
BEGIN  
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET ANSI_WARNINGS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF   
   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err int              -- Error number returned by stored procedure or this trigger  
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND UPDATE(Type) --NJOW01
   BEGIN  
   	  IF EXISTS (SELECT 1 
   	             FROM INSERTED
   	             WHERE Type = 'PHYSICAL')
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': PHYSICAL is not allowed for facility type. (ntrFacilityUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN  
      UPDATE Facility  with (RowLock)
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME()
        FROM Facility, INSERTED  
       WHERE Facility.Facility = INSERTED.Facility  
 
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table Facility. (ntrFacilityUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
   /* END Added */
  
   /* #INCLUDE <TRPU_2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrFacilityUpdate'  
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
ALTER TABLE [dbo].[FACILITY] ADD CONSTRAINT [PK_FACILITY] PRIMARY KEY CLUSTERED ([Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[FACILITY] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[FACILITY] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[FACILITY] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[FACILITY] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[FACILITY] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A facility is also known as a warehouse, distribution center, satellite etc.', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address 1', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address 2', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Address 3', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'address 4', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contact Person 1', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contact Person 2', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the facility', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Email Address', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Email1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Email Address', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Email2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key that identifies the warehouse   or distribution center', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Phone number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Phone number', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transportation management interface code', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'TMS_Interface'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. It is used to store the flag to indicated whether Pallet ID is required', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Indicates the facility type', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Default the TO LOCATION', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Stores the sub inventory code', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fixed. Stores the facility description', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine16'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine17'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine18'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine19'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The user defined fields are used for different purposes depending on the usage', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'UserDefine20'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip/ Postal', 'SCHEMA', N'dbo', 'TABLE', N'FACILITY', 'COLUMN', N'Zip'
GO
