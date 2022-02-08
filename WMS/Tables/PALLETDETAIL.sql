CREATE TABLE [dbo].[PALLETDETAIL]
(
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PalletLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_CaseId] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Loc] DEFAULT ('UNKNOWN'),
[Qty] [int] NOT NULL CONSTRAINT [DF_PALLETDETAIL_Qty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PALLETDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PALLETDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine05] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Trigger: ntrPalletDetailAdd                                          */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Input Parameters: NONE                                               */  
/*                                                                      */  
/* Output Parameters: NONE                                              */  
/*                                                                      */  
/* Return Status: NONE                                                  */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Local Variables:                                                     */  
/*                                                                      */  
/* Called By: When records added                                        */  
/*                                                                      */  
/* PVCS Version: 1.3                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver.  Purposes                                */  
/* 2012-Nov-30  Chew KP   1.1   Auto Gen PalletLinenumber (ChewKP01)    */  
/* 2018-Dec-19  TLTING01  1.2   missing NOLOCK                          */  
/* 31-Mar-2020  kocy      1.3   Skip when data move from Archive (kocy01)*/
/* 12-Jan-2021  Shong     1.4   Performance Tuning, Move the logic to   */ 
/*                              Pre-Add Trigger                         */
/************************************************************************/  
CREATE TRIGGER [dbo].[ntrPalletDetailAdd]  
   ON  [dbo].[PALLETDETAIL]  
 FOR INSERT  
 AS  
 BEGIN  
    SET NOCOUNT ON  
    SET ANSI_NULLS OFF  
    SET QUOTED_IDENTIFIER OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE @b_debug INT  
    SELECT @b_debug = 0  
    DECLARE @b_Success        INT -- Populated by calls to stored procedures - was the proc successful?
           ,@n_err            INT -- Error number returned by stored procedure or this trigger
           ,@n_err2           INT -- For Additional Error Detection
           ,@c_errmsg         NVARCHAR(250) -- Error message returned by stored procedure or this trigger
           ,@n_continue       INT
           ,@n_starttcnt      INT -- Holds the current transaction count
           ,@c_preprocess     NVARCHAR(250) -- preprocess
           ,@c_pstprocess     NVARCHAR(250) -- post process
           ,@n_cnt            INT

    DECLARE 
            @c_CaseID       NVARCHAR(20)   
           ,@c_Status       NVARCHAR(10)
        
    SELECT @n_continue = 1
          ,@n_starttcnt = @@TRANCOUNT  
         /* #INCLUDE <TRPALDA1.SQL> */       
      
    -- kocy01(s)
    IF @n_continue=1 OR @n_continue=2
    BEGIN
        IF EXISTS (SELECT 1 FROM   INSERTED WHERE  ArchiveCop = '9' )
        BEGIN
           SELECT @n_continue = 4
        END
    END
    --kocy01(e)
 

 IF @n_continue=1 OR @n_continue=2
 BEGIN     
     DECLARE CUR_CASEMANIFEST_UPDATE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
     SELECT CM.CaseId 
          , INS.[Status]
     FROM [dbo].[CASEMANIFEST] AS CM WITH (NOLOCK) 
     JOIN INSERTED AS INS ON CM.CaseId = INS.CaseId 
     WHERE INS.CaseID IS NOT NULL
     AND INS.CaseID > ''
     AND INS.Status = '9' 
     
     OPEN CUR_CASEMANIFEST_UPDATE
     
     FETCH FROM CUR_CASEMANIFEST_UPDATE INTO @c_CaseId, @c_Status
     
     WHILE @@FETCH_STATUS = 0
     BEGIN 
        IF @c_Status = '9'
        BEGIN
           UPDATE dbo.CASEMANIFEST
            SET   ShipStatus = '9'
           WHERE  CaseId = @c_CaseID
     
           SELECT @n_err = @@ERROR
                 ,@n_cnt = @@ROWCOUNT
     
           IF @n_err<>0
           BEGIN
               SELECT @n_continue = 3  
               SELECT @c_errmsg = CONVERT(NVARCHAR(250) ,@n_err)
                     ,@n_err = 67601 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
               SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5) ,@n_err)+
                      ': Update Failed On Table CASEMANIFEST. (ntrPalletDetailAdd)'+' ( '+' SQLSvr MESSAGE='+ISNULL(TRIM(@c_errmsg) ,'') 
                     +' ) '
           END           
        END -- IF @c_Status = '9'
        
        FETCH FROM CUR_CASEMANIFEST_UPDATE INTO @c_CaseId, @c_Status
     END
     
     CLOSE CUR_CASEMANIFEST_UPDATE
     DEALLOCATE CUR_CASEMANIFEST_UPDATE
 END
  
 
 /* #INCLUDE <TRPALDA2.SQL> */  
 IF @n_continue=3 -- Error Occured - Process And Return
 BEGIN
     IF @@TRANCOUNT=1
        AND @@TRANCOUNT>=@n_starttcnt
     BEGIN
         ROLLBACK TRAN
     END
     ELSE
     BEGIN
         WHILE @@TRANCOUNT>@n_starttcnt
         BEGIN
             COMMIT TRAN
         END
     END  
     EXECUTE nsp_logerror @n_err,
          @c_errmsg,
          'ntrPalletDetailAdd'
     
     RAISERROR (@c_errmsg ,16 ,1) WITH SETERROR -- SQL2012  
     RETURN
 END
 ELSE
 BEGIN
     WHILE @@TRANCOUNT>@n_starttcnt
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


/***************************************************************************/
/* Trigger:  ntrPalletDetailDelete                                         */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose:  Trigger point upon any Delete on the Container                */
/*                                                                         */
/* Return Status:  None                                                    */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Local Variables:                                                        */
/*                                                                         */
/* Called By: When records Deleted                                         */
/*                                                                         */
/* PVCS Version: 1.2                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author    Ver.  Purposes                                   */
/* 09-Oct-2012  KHLim     1.0   Insert Delete log (KH01)                   */
/* 12-Dec-2018  NJOW01    1.1   WMS-7187 allow supervisor delete carton    */
/* 15-Jun-2020  TLTING01  1.2   bug fix archive skip check                 */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrPalletDetailDelete]
 ON [dbo].[PALLETDETAIL]
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

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              INT,       -- Holds the number of rows affected by the DELETE statement that fired this trigger.
 @c_authority        nvarchar(1),  -- KH01
 @c_issupervisor NVARCHAR(10), --NJOW01
 @c_Username NVARCHAR(18) --NJOW01

 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 if (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
      /* #INCLUDE <TRPALDD1.SQL> */     
 
   IF @n_continue=1 or @n_continue=2
   BEGIN
      --NJOW01
      SET @c_issupervisor = 'N'
      SET @c_username = SUSER_SNAME()
      EXEC isp_CheckSupervisorRole
           @c_username  = @c_username
          ,@c_Flag     = @c_issupervisor OUTPUT
          ,@b_Success  = @b_success      OUTPUT  
          ,@n_Err      = @n_err          OUTPUT  
          ,@c_ErrMsg   = @c_errmsg       OUTPUT
         
      IF @n_continue=1 or @n_continue=2
      BEGIN	        	
        IF EXISTS (SELECT * FROM PALLET, DELETED
                   WHERE PALLET.PalletKey = DELETED.PalletKey
                   AND PALLET.Status = "9")
           AND ISNULL(@c_issupervisor,'N') <> 'Y'  --NJOW01
        BEGIN
           SELECT @n_continue = 3
           SELECT @n_err=67800
           SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": PALLET.Status = 'SHIPPED'. DELETE rejected. (ntrPalletDetailDelete)"
        END
      END
   END 
   
   IF @n_continue=1 or @n_continue=2
   BEGIN
      IF EXISTS (SELECT * FROM DELETED
                 WHERE DELETED.Status = "9")
         AND ISNULL(@c_issupervisor,'N') <> 'Y'  --NJOW01      
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err=67800
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": PALLET.Status = 'SHIPPED'. DELETE rejected. (ntrPalletDetailDelete)"
      END
   END
 
   IF @n_continue = 1 or @n_continue = 2  --KH01 start
   BEGIN
      SELECT @b_success = 0
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
               ,@c_errmsg = 'ntrPalletDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.PALLETDETAIL_DELLOG ( PalletKey, PalletLineNumber )
         SELECT PalletKey, PalletLineNumber FROM DELETED
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 67801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PALLETDETAIL Failed. (ntrPalletDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END   --KH01 end

      /* #INCLUDE <TRPALDD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPalletDetailDelete"
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
/* Trigger: ntrPalletDetailPreAdd                                       */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* Output Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records Inserted                                     */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  ver  Purposes                                   */
/* 2012-Nov-30  Chew KP   1.1   Auto Gen PalletLinenumber (ChewKP01)    */  
/* 2018-Dec-19  TLTING01  1.2   missing NOLOCK                          */  
/* 31-Mar-2020  kocy      1.3   Skip when data move from Archive (kocy01)*/
/* 12-Jan-2021  Shong     1.4   Performance Tuning, Move the logic from */ 
/*                              Pre-Add Trigger                         */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrPalletDetailPreAdd]
ON  [dbo].[PALLETDETAIL]
INSTEAD OF INSERT  
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_Success              INT -- Populated by calls to stored procedures - was the proc successful?
          ,@n_err                  INT -- Error number returned by stored procedure or this trigger
          ,@n_err2                 INT -- For Additional Error Detection
          ,@c_errmsg               NVARCHAR(250) -- Error message returned by stored procedure or this trigger
          ,@n_Continue             INT
          ,@n_StartTCnt            INT -- Holds the current transaction count@n_StorerMinShelfLife_Per
          ,@c_preprocess           NVARCHAR(250) -- preprocess
          ,@c_pstprocess           NVARCHAR(250) -- post process
          ,@n_cnt                  INT
            

    DECLARE @c_StorerKey    NVARCHAR(15)
           ,@c_Sku          NVARCHAR(20)
           ,@n_Qty          INT
           ,@c_PalletKey    NVARCHAR(30)
           ,@c_CaseID       NVARCHAR(20)   
           ,@c_Status       NVARCHAR(10)
           ,@cPalletLine    NVARCHAR(5)   -- (ChewKP01) 

   SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT


   DECLARE @t_PalletDetail TABLE (
	[PalletKey] [nvarchar](30) NOT NULL,
	[PalletLineNumber] [nvarchar](5) NOT NULL,
	[CaseId] [nvarchar](20) NULL DEFAULT '',
	[StorerKey] [nvarchar](15) NOT NULL DEFAULT '',
	[Sku] [nvarchar](20) NOT NULL DEFAULT '',
	[Loc] [nvarchar](10) NOT NULL DEFAULT '',
	[Qty] [int] NOT NULL DEFAULT 0,
	[Status] [nvarchar](10) NOT NULL DEFAULT '0',
	[AddDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[AddWho] [nvarchar](128) NOT NULL DEFAULT SUSER_SNAME(),
	[EditDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[EditWho] [nvarchar](128) NOT NULL DEFAULT SUSER_SNAME(),
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[TimeStamp] [nvarchar](18) NULL,
	[UserDefine01] [nvarchar](30) NULL,
	[UserDefine02] [nvarchar](30) NULL,
	[UserDefine03] [nvarchar](30) NULL,
	[UserDefine04] [nvarchar](30) NULL,
	[UserDefine05] [nvarchar](30) NULL )
   
   INSERT INTO @t_PalletDetail
   (
      PalletKey,     PalletLineNumber, CaseId,        StorerKey,
      Sku,           Loc,              Qty,           [Status],
      AddDate,       AddWho,           EditDate,      EditWho,
      TrafficCop,    ArchiveCop,       [TimeStamp],   UserDefine01,
      UserDefine02,  UserDefine03,     UserDefine04,  UserDefine05
   )
   SELECT       
      PalletKey,     PalletLineNumber, CaseId,        StorerKey,
      Sku,           Loc,              Qty,           [Status],
      AddDate,       AddWho,           EditDate,      EditWho,
      TrafficCop,    ArchiveCop,       [TimeStamp],   UserDefine01,
      UserDefine02,  UserDefine03,     UserDefine04,  UserDefine05
   FROM INSERTED

   IF EXISTS( SELECT 1 FROM @t_PalletDetail WHERE ArchiveCop = '9')
      SELECT @n_Continue = 4
         

    IF @n_Continue=1 OR @n_Continue=2
    BEGIN
        IF EXISTS ( SELECT 1 FROM dbo.PALLET AS P WITH (NOLOCK)
                    JOIN  @t_PalletDetail PD ON P.PalletKey = PD.PalletKey
                    WHERE P.Status = '9' )
        BEGIN
            SELECT @n_Continue = 3  
            SELECT @n_err = 67600  
            SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5) ,@n_err)+
                   ': PALLET.Status = ''SHIPPED''. UPDATE rejected. (ntrPalletDetailPreAdd)'
        END
    END
    
    IF @n_Continue=1 OR @n_Continue=2
    BEGIN
        IF EXISTS (SELECT 1
                   FROM @t_PalletDetail AS PD 
                   WHERE PD.StorerKey IS NULL OR PD.StorerKey = ''
                      OR PD.Sku IS NULL OR PD.SKU = '' )        
        BEGIN
            SELECT @n_Continue = 3  
            SELECT @n_err = 67604  
            SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5) ,@n_err)+
                   ': PALLETDETAIL.StorerKey or PALLETDETAIL.Sku can not be blank. (ntrPalletDetailPreAdd)'
        END
    END
 
    IF @n_Continue=1 OR @n_Continue=2
    BEGIN
        IF EXISTS ( SELECT 1 FROM @t_PalletDetail AS PD
                    WHERE NOT EXISTS (
                          SELECT 1
                          FROM  dbo.SKU S WITH (NOLOCK)
                          WHERE S.StorerKey = PD.StorerKey
                            AND S.Sku = PD.Sku
                      )
           )
        BEGIN
            SELECT @n_Continue = 3  
            SELECT @n_err = 67605  
            SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5) ,@n_err)+
                   ': Bad PALLETDETAIL.StorerKey or PALLETDETAIL.Sku. (ntrPalletDetailPreAdd)'
        END
    END
 
 IF @n_Continue=1 OR @n_Continue=2
 BEGIN     
     DECLARE CUR_CASEMANIFEST_UPDATE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
     SELECT CM.StorerKey
          , CM.Sku
          , CM.Qty
          , PD.PalletKey
          , CM.CaseId 
          , PD.[Status]
     FROM [dbo].[CASEMANIFEST] AS CM WITH (NOLOCK) 
     JOIN @t_PalletDetail AS PD ON CM.CaseId = PD.CaseId 
     WHERE PD.CaseID IS NOT NULL
     AND PD.CaseID > ''
     
     OPEN CUR_CASEMANIFEST_UPDATE
     
     FETCH FROM CUR_CASEMANIFEST_UPDATE INTO @c_StorerKey, @c_Sku, @n_Qty, @c_PalletKey, @c_CaseId, @c_Status
     
     WHILE @@FETCH_STATUS = 0
     BEGIN 
        IF @n_Qty = 0
           SET @n_Qty = 1
           
        UPDATE @t_PalletDetail 
        SET    TrafficCop = NULL
              ,StorerKey = @c_StorerKey
              ,Sku = @c_Sku
              ,Qty = @n_Qty
              ,EditDate = GETDATE()
              ,EditWho = SUSER_SNAME()
        WHERE PalletKey = @c_PalletKey
          AND CaseId = @c_CaseId
     
        SELECT @n_err = @@ERROR
              ,@n_cnt = @@ROWCOUNT
     
        IF @n_err<>0
        BEGIN
            SELECT @n_Continue = 3  
            SELECT @c_errmsg = CONVERT(NVARCHAR(250) ,@n_err)
                  ,@n_err = 67603 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5) ,@n_err)+
                   ': Update Failed On Table PALLETDETAIL. (ntrPalletDetailPreAdd)'+' ( '+' SQLSvr MESSAGE='+ISNULL(TRIM(@c_errmsg),'') 
                  +' ) '
        END

        FETCH FROM CUR_CASEMANIFEST_UPDATE INTO @c_StorerKey, @c_Sku, @n_Qty, @c_PalletKey, @c_CaseId, @c_Status
     END
     
     CLOSE CUR_CASEMANIFEST_UPDATE
     DEALLOCATE CUR_CASEMANIFEST_UPDATE
 END
  
 
   IF @n_Continue=1 or @n_Continue=2  
   BEGIN  
      -- (ChewKP01) - Start      
      IF EXISTS (SELECT 1 FROM @t_PalletDetail AS tPD WHERE tPD.PalletLineNumber = '0')  
      BEGIN  
         WHILE 1=1
         BEGIN
            SET @c_PalletKey = ''
         
            SELECT TOP 1 @c_PalletKey = PalletKey 
            FROM @t_PalletDetail AS tPD
            WHERE tPD.PalletLineNumber = '0'
            ORDER BY PalletKey 
         
            IF @c_PalletKey <> ''
            BEGIN
               SELECT @cPalletLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PD.PalletLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)  
               FROM dbo.PalletDetail AS PD WITH (NOLOCK)    
               WHERE PD.PalletKey = @c_PalletKey                  
                 
               UPDATE @t_PalletDetail  
                  SET PalletLineNumber = @cPalletLine    
               WHERE PalletKey = @c_PalletKey
               AND PalletLineNumber = '0'                 
            
            END 
            ELSE 
               BREAK            
            
         END -- While 1=1 
                    
      END  
      -- (ChewKP01) - End  
    END            
            
   IF @n_Continue=1 or @n_Continue=2 OR @n_Continue = 4 
   BEGIN     
      INSERT INTO dbo.PALLETDETAIL 
      (
         PalletKey,     PalletLineNumber, CaseId,        StorerKey,
         Sku,           Loc,              Qty,           [Status],
         AddDate,       AddWho,           EditDate,      EditWho,
         TrafficCop,    ArchiveCop,       [TimeStamp],   UserDefine01,
         UserDefine02,  UserDefine03,     UserDefine04,  UserDefine05
      )
         SELECT       
         PalletKey,     PalletLineNumber, CaseId,        StorerKey,
         Sku,           Loc,              Qty,           [Status],
         AddDate,       AddWho,           EditDate,      EditWho,
         TrafficCop,    ArchiveCop,       [TimeStamp],   UserDefine01,
         UserDefine02,  UserDefine03,     UserDefine04,  UserDefine05
      FROM @t_PalletDetail 
   END 
  
 IF @n_Continue=3 -- Error Occured - Process And Return
 BEGIN
     IF @@TRANCOUNT=1
        AND @@TRANCOUNT>=@n_StartTCnt
     BEGIN
         ROLLBACK TRAN
     END
     ELSE
     BEGIN
         WHILE @@TRANCOUNT>@n_StartTCnt
         BEGIN
             COMMIT TRAN
         END
     END  
     EXECUTE dbo.nsp_logerror @n_err= @n_err,
             @c_errmsg= @c_errmsg, @c_module='ntrPalletDetailPreAdd'
     
     RAISERROR (@c_errmsg ,16 ,1) WITH SETERROR 
     RETURN
 END
 ELSE
 BEGIN
     WHILE @@TRANCOUNT>@n_StartTCnt
     BEGIN
         COMMIT TRAN
     END 
     RETURN
 END            
   
END -- Trigger
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [dbo].[ntrPalletDetailUpdate]
 ON  [dbo].[PALLETDETAIL]
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
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger
 ,         @n_err2 int              -- For Additional Error Detection
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 ,         @n_continue int                 
 ,         @n_starttcnt int                -- Holds the current transaction count
 ,         @c_preprocess NVARCHAR(250)         -- preprocess
 ,         @c_pstprocess NVARCHAR(250)         -- post process
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
      /* #INCLUDE <TRPALDU1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS ( SELECT *
 FROM INSERTED
 WHERE NOT EXISTS ( SELECT *
 FROM SKU
 WHERE SKU.StorerKey = INSERTED.StorerKey
 AND SKU.Sku = INSERTED.Sku )
 AND NOT dbo.fnc_LTrim(dbo.fnc_RTrim(Sku)) IS NULL )
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=67703
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Bad PALLETDETAIL.StorerKey or PALLETDETAIL.Sku. (ntrPalletDetailUpdate)"
 END
 END
 IF @n_continue =1 or @n_continue =2
 BEGIN
 UPDATE PALLETDETAIL
 SET  StorerKey = CASEMANIFEST.StorerKey,
 Sku = CASEMANIFEST.Sku ,
 Qty = CASEMANIFEST.Qty
 FROM PALLETDETAIL, INSERTED, CASEMANIFEST
 WHERE PALLETDETAIL.PalletKey = INSERTED.PalletKey
 AND PALLETDETAIL.CaseId = INSERTED.CaseId
 AND CASEMANIFEST.CaseId = INSERTED.CaseId
 AND dbo.fnc_LTrim(dbo.fnc_RTrim(INSERTED.Caseid)) IS NOT NULL
 END
 IF @n_continue=1 or @n_continue=2
 BEGIN
 UPDATE CASEMANIFEST
 SET ShipStatus = "9",
      EditDate = GETDATE(),   --tlting
      EditWho = SUSER_SNAME()
 FROM CASEMANIFEST, INSERTED
 WHERE CASEMANIFEST.CaseId = INSERTED.CaseId
 AND INSERTED.Status = "9"
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=67701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table CASEMANIFEST. (ntrPalletDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN
 UPDATE PALLETDETAIL with (ROWLOCK)
 SET  EditDate = GETDATE(),
 EditWho = SUSER_SNAME()
 FROM PALLETDETAIL, INSERTED
 WHERE PALLETDETAIL.PalletKey = INSERTED.PalletKey
 AND PALLETDETAIL.PalletLineNumber = INSERTED.PalletLineNumber
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=67702   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table PALLETDETAIL. (ntrPalletDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRPALDU2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrPalletDetailUpdate"
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
ALTER TABLE [dbo].[PALLETDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_PALLETDETAIL_Status] CHECK (([Status]>='0' AND [Status]<='9'))
GO
ALTER TABLE [dbo].[PALLETDETAIL] ADD CONSTRAINT [PKPalletDetail] PRIMARY KEY CLUSTERED ([PalletKey], [PalletLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PalletDetail01] ON [dbo].[PALLETDETAIL] ([StorerKey], [CaseId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PALLETDETAIL] ADD CONSTRAINT [FK_PALLETDETAIL_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
GRANT SELECT ON  [dbo].[PALLETDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'CaseId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'PalletKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'PalletLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'TrafficCop'
GO
