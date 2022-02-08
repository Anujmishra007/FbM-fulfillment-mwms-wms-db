CREATE TABLE [dbo].[PackDetail]
(
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_PackDetail_Qty] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackDetail_Adddate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackDetail_Editdate] DEFAULT (getdate()),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackDetail_RefNo] DEFAULT (' '),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpQty] [int] NULL CONSTRAINT [DF_PackDetail_ExpQty] DEFAULT ((0)),
[UPC] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackDetail_DropID] DEFAULT (' '),
[RefNo2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackDetail_RefNo2] DEFAULT (' '),
[LOTTABLEVALUE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackDetail_LOTTABLEVALUE] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PackDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PackDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackDetail] TO [NSQL]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
/*************************************************************************/    
/* Trigger: ntrPackDetailAdd                                             */    
/* Creation Date:                                                        */    
/* Copyright: IDS                                                        */    
/* Written by:                                                           */    
/*                                                                       */    
/* Purpose:                                                              */    
/*                                                                       */    
/* Input Parameters: NONE                                                */    
/*                                                                       */    
/* Output Parameters: NONE                                               */    
/*                                                                       */    
/* Return Status: NONE                                                   */    
/*                                                                       */    
/* Usage:                                                                */    
/*                                                                       */    
/* Local Variables:                                                      */    
/*                                                                       */    
/* Called By: When records added                                         */    
/*                                                                       */    
/* PVCS Version: 2.9                                                     */    
/*                                                                       */    
/* Version: 5.4                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver.  Purposes                                   */    
/* 2009-Mar-03 James    1.1   Filter by checking labelno = '' to cater   */    
/*                            for DynamicPick parallel picking           */    
/*                            (james01)                                  */    
/* 2009-Jul-02 Shong    1.2   Bug fix for DynamicPick LabelNo(Shong01)   */    
/* 2009-Jul-08 Vicky    1.3   Assign CartonNo to prevent different       */    
/*                            LabelNo being assigned same CartonNo       */    
/*                            (Vicky01)                                  */    
/* 2010-Nov-10 NJOW01   1.4   Fix the MAX(cartonno)                      */    
/* 2011-Jan-12 NJOW02   1.5   201874-Insert copy dropid value from       */    
/*                            previous line                              */    
/* 2013-Jul-17 SHONG    1.6   Update PackDetail with ArchiveCop When     */  
/*                            assign new carton number                   */  
/* 2014-Jan-08 Ung      1.7   Auto assign cartonno when labelno blank    */  
/*                            Fix duplicate cartonno even diff labelno   */  
/*                            Add RDT compatible message                 */  
/* 2014-Apr-14 TLTING   1.8   SQL2012                                    */  
/* 2014-May-06 TLTING   1.8   Deadlock Fix                               */  
/* 2015-Aug-24 NJOW03   1.9   346367-copy lableno to dropid if blank     */   
/* 2015-Nov-30 NJOW04   2.0   356837-fix insert packdetail update to     */  
/*                            packinfo.qty                               */  
/* 2019-Apr-23 TLTING01 2.1   Deadlock tune                              */   
/* 2019-Jul-19 WLChooi  2.2   WMS-9661 & WMS-9663 - Add CartonGID when   */   
/*                            add new carton - Based on storerconfig     */  
/*                            Use nspGetRight to get Storerconfig to     */  
/*                            filter by Facility for Pickslipno start    */  
/*                            with P only (Non-ECOM)                     */  
/*                            For ECOM, will be done in update trigger   */  
/*                            (WL01)                                     */  
/* 2020-Apr-15 WLChooi  2.3   WMS-9661 Fix - Update CartonType (WL02)    */  
/* 2020-May-15 WLChooi  2.4   Insert PACKInfo table with CartonType =    */  
/*                             NULL (WL03)                               */  
/* 2020-Sep-01 NJOW05   2.5   WMS-15009 - call custom stored proc        */  
/* 2021-Jul-30 NJOW06   2.6   WMS-17609 - call custom stored proc to     */  
/*                            generate packinfo trackingno               */ 
/* 2021-Nov-26 Wan01    2.7   WMS-18410 - [RG] Logitech Tote ID Packing  */
/*                            Change Request                             */
/* 2021-Nov-26 Wan01    2.8   DevOps Conbine Script                      */
/* 2021-DEC-15 Wan02    2.9   Add RowLock & fixed Order By               */
/*************************************************************************/    
    
CREATE TRIGGER [dbo].[ntrPackDetailAdd]    
ON  [dbo].[PackDetail]    
FOR INSERT    
AS    
BEGIN    
  SET NOCOUNT ON    
  SET ANSI_NULLS OFF    
  SET QUOTED_IDENTIFIER OFF    
  SET CONCAT_NULL_YIELDS_NULL OFF    
    
DECLARE    
          @b_Success    INT       -- Populated by calls to stored procedures - was the proc successful?    
,         @n_err        INT       -- Error number returned by stored procedure or this trigger    
,         @n_err2       INT       -- For Additional Error Detection    
,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger    
,         @n_continue   INT                     
,         @n_starttcnt  INT       -- Holds the current transaction count    
,         @c_preprocess NVARCHAR(250) -- preprocess    
,         @c_pstprocess NVARCHAR(250) -- post process    
,         @n_cnt        INT                      
    
DECLARE @nMax_CartonNo              INT -- (Vicky01)    
       ,@nCartonNo                  INT    
       ,@cLabelLine                 NVARCHAR(5)    
       ,@cDropID                    NVARCHAR(20) --NJOW02   
       ,@c_Storerkey                NVARCHAR(10) --WL01  
       ,@c_Facility                 NVARCHAR(10) --WL01   
       ,@c_CartonGID                NVARCHAR(50) --WL01  
       ,@c_DefaultPackInfo          NVARCHAR(10) = ''  --WL01  
       ,@c_CapturePackInfo          NVARCHAR(10) = ''  --WL01  
       ,@c_PackCartonGID            NVARCHAR(10) = ''  --WL01  
       ,@c_Pickslipno               NVARCHAR(10) --NJOW06  
       ,@n_CartonNo                 INT --NJOW06  
       ,@c_PackinfoGenTrackingNo_SP NVARCHAR(30) --NJOW06 
                                                 
      ,  @c_AdvancePackGenCartonNo  NVARCHAR(10) = ''    --(Wan01)
                                                         
      DECLARE @t_PackdetailLabel TABLE (RowId BIGINT NOT NULL, PickSlipNo  NVARCHAR(10) NOT NULL DEFAULT (''))       --(Wan01)                                                                                                                      
    
SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT    
      /* #INCLUDE <TRCCA1.SQL> */         
  
IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')    
BEGIN    
   SELECT @n_continue = 4    
END    
   --Get Facility and Configkey (WL01 Start)  
   IF @n_continue = 1 or @n_continue = 2    
   BEGIN   
      SELECT TOP 1 @c_Storerkey = PACKHEADER.StorerKey  
      FROM INSERTED  
      JOIN PACKHEADER (NOLOCK) ON INSERTED.PickSlipNo = PACKHEADER.PickSlipNo   
  
      SELECT TOP 1 @c_Facility = Facility  
      FROM INSERTED  
      JOIN PACKHEADER (NOLOCK) ON INSERTED.PickSlipNo = PACKHEADER.PickSlipNo   
      JOIN ORDERS (NOLOCK) ON PACKHEADER.StorerKey = ORDERS.StorerKey AND PACKHEADER.OrderKey = ORDERS.OrderKey  
        
      IF(ISNULL(@c_Facility,'') = '')  
      BEGIN  
         SELECT TOP 1 @c_Facility = ORDERS.Facility  
         FROM INSERTED  
         JOIN PACKHEADER (NOLOCK) ON INSERTED.PickSlipNo = PACKHEADER.PickSlipNo   
         JOIN LOADPLANDETAIL (NOLOCK) ON LOADPLANDETAIL.LOADKEY = PACKHEADER.LOADKEY  
         JOIN ORDERS (NOLOCK) ON ORDERS.ORDERKEY = LOADPLANDETAIL.ORDERKEY  
      END  
  
      EXEC nspGetRight     
         @c_Facility          -- facility    
      ,  @c_Storerkey         -- Storerkey    
      ,  NULL                 -- Sku    
      ,  'Default_PackInfo'   -- Configkey    
      ,  @b_Success           OUTPUT     
      ,  @c_DefaultPackInfo   OUTPUT     
      ,  @n_Err               OUTPUT     
      ,  @c_ErrMsg            OUTPUT   
  
      IF @b_success <> 1    
      BEGIN    
         SET @n_continue = 3    
         SET @n_err = 83049     
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing nspGetRight. (ntrPackdetailAdd)'     
                     + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '      
      END  
        
      EXEC nspGetRight     
         @c_Facility          -- facility    
      ,  @c_Storerkey         -- Storerkey    
      ,  NULL                 -- Sku    
      ,  'PackCartonGID'      -- Configkey    
      ,  @b_Success           OUTPUT     
      ,  @c_PackCartonGID     OUTPUT     
      ,  @n_Err               OUTPUT     
      ,  @c_ErrMsg            OUTPUT   
        
      IF @b_success <> 1    
      BEGIN    
         SET @n_continue = 3    
         SET @n_err = 83050     
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing nspGetRight. (ntrPackdetailAdd)'     
                     + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '     
      END   
   END  
   --(WL01 End)  
     
   --NJOW05  
   IF @n_continue=1 or @n_continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM INSERTED i  
                 JOIN storerconfig s WITH (NOLOCK) ON  i.storerkey = s.storerkey  
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue  
                 WHERE  s.configkey = 'PackdetailTrigger_SP')  
      BEGIN  
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL  
            DROP TABLE #INSERTED  
  
          SELECT *  
          INTO #INSERTED  
          FROM INSERTED  
  
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL  
            DROP TABLE #DELETED  
  
          SELECT *  
          INTO #DELETED  
          FROM DELETED  
  
         EXECUTE dbo.isp_PackdetailTrigger_Wrapper  
                   'INSERT'  --@c_Action  
                 , @b_Success  OUTPUT  
                 , @n_Err      OUTPUT  
                 , @c_ErrMsg   OUTPUT  
  
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3  
                  ,@c_errmsg = 'ntrPackDetailAdd ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  
         END  
  
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL  
            DROP TABLE #INSERTED  
  
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL  
            DROP TABLE #DELETED  
      END  
   END  
    
   IF @n_continue = 1 or @n_continue = 2    
   BEGIN    
      /*    
          IF Exists (SELECT 1     
                     FROM PackDetail With (NOLOCK), INSERTED    
                     WHERE PackDetail.PickSlipNo = INSERTED.PickSlipNo    
                     AND PackDetail.LabelNo = INSERTED.LabelNo    
                     AND PackDetail.CartonNo <> INSERTED.CartonNo     
                     AND INSERTED.LabelNo <> '')   -- (james01)    
      */    
          
      --NJOW02    
      IF Exists (SELECT 1 FROM INSERTED WITH (NOLOCK) WHERE ISNULL(INSERTED.dropid,'') = '')    
      BEGIN    
         SELECT @cDropID = MAX(PACKDETAIL.DropID)  --NJOW01    
              FROM PACKDETAIL WITH (NOLOCK)    
              JOIN INSERTED WITH (NOLOCK) ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo      
                                              AND   PACKDETAIL.CartonNo = INSERTED.CartonNo    -- tlting01  
                                              AND PACKDETAIL.LabelNo = INSERTED.LabelNo)    
         IF ISNULL(@cDropID,'') <> ''    
         BEGIN    
             UPDATE PACKDETAIL    
             SET DropID = @cDropID    
             FROM INSERTED WITH (NOLOCK)    
             WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
             AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
             AND   PACKDETAIL.CartonNo = INSERTED.CartonNo    -- tlting01  
             AND   ISNULL(PACKDETAIL.DropID,'') = ''    
         END                                                      
      END    
        
      --NJOW03  
      IF EXISTS (SELECT 1   
                 FROM INSERTED   
                 JOIN STORERCONFIG SC (NOLOCK) ON INSERTED.Storerkey = SC.Storerkey AND SC.Configkey = 'PackCopyLabelNoToDropId' AND SC.Svalue = '1'  
                 AND ISNULL(INSERTED.DropID,'')='')    
      BEGIN  
          UPDATE PACKDETAIL    
          SET PACKDETAIL.DropID = PACKDETAIL.Labelno  
          FROM INSERTED WITH (NOLOCK)    
          JOIN STORERCONFIG SC (NOLOCK) ON INSERTED.Storerkey = SC.Storerkey AND SC.Configkey = 'PackCopyLabelNoToDropId' AND SC.Svalue = '1'                
          WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
          AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
          AND   PACKDETAIL.CartonNo = INSERTED.CartonNo    -- tlting01  
          AND   ISNULL(PACKDETAIL.DropID,'') = ''    
      END 
      
      --(Wan01) - START
      SELECT @c_AdvancePackGenCartonNo = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'AdvancePackGenCartonNo')  
      IF @c_AdvancePackGenCartonNo = '1'
      BEGIN
         INSERT INTO PACKDETAILLABEL (PickSlipNo, LabelNo, CartonNo) OUTPUT INSERTED.RowID, INSERTED.PickSlipNo INTO @t_PackdetailLabel
         SELECT i.PickSlipNo, i.LabelNo, i.CartonNo
         FROM INSERTED i
         GROUP BY i.PickSlipNo, i.LabelNo, i.CartonNo
      END
      --(Wan01) - END           
                                       
      IF Exists (SELECT 1 FROM INSERTED WITH (NOLOCK) WHERE INSERTED.CartonNo = 0 AND LabelNo = '')  
      BEGIN    
              SELECT @nMax_CartonNo = MAX(PACKDETAIL.CartonNo)  
              FROM PACKDETAIL WITH (NOLOCK)    
              JOIN INSERTED WITH (NOLOCK) ON PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
  
              UPDATE PACKDETAIL    
               SET CartonNo = @nMax_CartonNo + 1,    
                   LabelLine = CASE WHEN INSERTED.LabelLine = '' THEN '00001' ELSE INSERTED.LabelLine END,   
                   ArchiveCop = NULL  
              FROM INSERTED WITH (NOLOCK)    
              WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
              AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
              AND   PACKDETAIL.CartonNo = 0   
              AND   PACKDETAIL.LabelNo = ''  
  
              IF EXISTS ( SELECT 1   
                 FROM PACKDETAIL (NOLOCK)   
                 JOIN INSERTED WITH (NOLOCK) ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo AND     
                                                 PACKDETAIL.LabelNo = INSERTED.LabelNo)    
                 WHERE PACKDETAIL.CartonNo = @nMax_CartonNo + 1   
                 HAVING COUNT( 1) > 1)   
              BEGIN  
                 SELECT @n_err = 83051    
                 SELECT @n_continue = 3    
                 SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+ ': CartonNo repeated (ntrPackdetailAdd)'  
              END  
      END  
      ELSE  
      -- (Vicky01) - Start    
      IF Exists (SELECT 1 FROM INSERTED WITH (NOLOCK) WHERE INSERTED.CartonNo = 0)    
      BEGIN    
         SELECT @nCartonNo = MAX(PACKDETAIL.CartonNo)  --NJOW01    
         FROM PACKDETAIL WITH (NOLOCK)    
         JOIN INSERTED WITH (NOLOCK) ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo AND     
                                          PACKDETAIL.LabelNo = INSERTED.LabelNo)    
    
         IF @nCartonNo = 0    
         BEGIN    
            SELECT @nMax_CartonNo = MAX(PACKDETAIL.CartonNo)  
            FROM PACKDETAIL WITH (NOLOCK)    
            JOIN INSERTED WITH (NOLOCK) ON PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo  
    
            SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( INSERTED.LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)    
            FROM PACKDETAIL WITH (NOLOCK)    
            JOIN INSERTED WITH (NOLOCK) ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo AND     
                                             PACKDETAIL.LabelNo = INSERTED.LabelNo)    

            --(Wan01) - START
            IF @c_AdvancePackGenCartonNo = '1'
            BEGIN
               SELECT TOP 1 @nMax_CartonNo = pdl.CartonNo
               FROM PACKDETAILLABEL pdl WITH (NOLOCK)
               JOIN @t_PackdetailLabel AS tpl ON tpl.PickSlipNo = pdl.PickSlipNo
               WHERE pdl.RowId < tpl.RowId
               AND CartonNo > 0
               ORDER BY pdl.CartonNo DESC          --Wan02
               --ORDER BY pdl.RowID DESC              --Wan02
               
               ;WITH GC AS 
               ( SELECT pdl.RowID 
                     ,  pdl.PickSlipNo
                     ,  pdl.LabelNo
                     ,  CartonNo = @nMax_CartonNo + ROW_NUMBER() OVER (ORDER BY pdl.RowId)
                 FROM PACKDETAILLABEL pdl WITH (NOLOCK)
                 JOIN @t_PackdetailLabel AS tpl ON tpl.PickSlipNo = pdl.PickSlipNo
                 WHERE pdl.CartonNo = 0
               )
               
               UPDATE pdl WITH (ROWLOCK)           --Wan02
                  SET CartonNo  = GC.CartonNo 
                  ,   EditWho = SUSER_SNAME()         --Wan02  
                  ,   EditDate = GETDATE()            --Wan02    
               FROM GC
               JOIN PACKDETAILLABEL pdl ON GC.RowID = pdl.RowID
               JOIN INSERTED ON  INSERTED.PickSlipNo = pdl.PickSlipNo
                             AND INSERTED.LabelNo = pdl.LabelNo    
               WHERE pdl.CartonNo = 0 
               
               UPDATE PACKDETAIL    
                  SET CartonNo  = pdl.CartonNo  
                     ,LabelLine = @cLabelLine  
                     ,ArchiveCop = NULL 
               FROM PACKDETAILLABEL pdl WITH (NOLOCK)  
               JOIN INSERTED ON  INSERTED.PickSlipNo = pdl.PickSlipNo
                             AND INSERTED.LabelNo = pdl.LabelNo    
               WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
               AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
               AND   PACKDETAIL.CartonNo = 0                         
            END 
            ELSE 
            BEGIN
               --Original Update for AdvancePackGenCartonNo turn off
               UPDATE PACKDETAIL    
                  SET CartonNo = @nMax_CartonNo + 1,    
                        LabelLine = @cLabelLine  
                        ,ArchiveCop = NULL  -- 2013-Jul-17  SHONG  
               FROM INSERTED WITH (NOLOCK)    
               WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
               AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
               AND   PACKDETAIL.CartonNo = 0    
            END
            --(Wan01) - END
            
            IF EXISTS ( SELECT 1   
               FROM PACKDETAIL (NOLOCK)   
               JOIN INSERTED WITH (NOLOCK) ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo)    
               WHERE PACKDETAIL.CartonNo = @nMax_CartonNo + 1   
               HAVING COUNT( DISTINCT PACKDETAIL.LabelNo) > 1)   
            BEGIN  
               SELECT @n_err = 83052    
               SELECT @n_continue = 3    
               SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+ ': CartonNo repeated (ntrPackdetailAdd)'  
            END  
         END    
         ELSE    
         BEGIN    
            SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PACKDETAIL.LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)    
            FROM PACKDETAIL WITH (NOLOCK)    
            JOIN INSERTED WITH (NOLOCK) ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo AND     
                                             PACKDETAIL.LabelNo = INSERTED.LabelNo)    
            WHERE PACKDETAIL.CartonNo = @nCartonNo    
                      
            UPDATE PACKDETAIL    
               SET CartonNo = @nCartonNo,    
                     LabelLine = @cLabelLine,   
                     ArchiveCop = NULL -- 2013-Jul-17  SHONG  
            FROM INSERTED WITH (NOLOCK)    
            WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
            AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
            AND   PACKDETAIL.CartonNo = 0    
         END    
      END    
      -- (Vicky01) - End    
      ELSE IF Exists (SELECT 1     
                  FROM INSERTED With (NOLOCK)     
                      LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo    
                      WHERE ( ( PackDetail.LabelNo = INSERTED.LabelNo AND PackDetail.CartonNo <> INSERTED.CartonNo) OR     
                              ( PackDetail.LabelNo <> INSERTED.LabelNo AND PackDetail.CartonNo = INSERTED.CartonNo) )     
                             AND INSERTED.LabelNo <> '')   -- (Shong01)    
      BEGIN    
         SELECT @n_continue = 3    
         SELECT @n_err=83053    
      -- SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Same LabelNo Not Allow to have Different CartonNo for Same PickSlip No. (ntrPackDetailAdd)'    
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': LabelNo and CartonNo are not unique for each other. (ntrPackDetailAdd)' -- (Shong01)    
      END      
   END    
     
   --NJOW06  
   IF @n_continue = 1 or @n_continue = 2       
   BEGIN                                               
      EXEC nspGetRight    
           @c_Facility  = @c_Facility,    
           @c_StorerKey = @c_StorerKey,    
           @c_sku       = NULL,    
           @c_ConfigKey = 'PackinfoGenTrackingNo_SP',     
           @b_Success   = @b_Success                  OUTPUT,    
           @c_authority = @c_PackinfoGenTrackingNo_SP OUTPUT,     
           @n_err       = @n_err                      OUTPUT,     
           @c_errmsg    = @c_errmsg                   OUTPUT    
              
      IF EXISTS(SELECT 1 FROM sys.Objects WHERE NAME = @c_PackinfoGenTrackingNo_SP AND TYPE = 'P')     
      BEGIN    
        DECLARE CUR_CTNTRACK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
           SELECT DISTINCT I.Pickslipno, PKD.CartonNo  
           FROM INSERTED I   
           JOIN PACKDETAIL PKD (NOLOCK) ON I.Pickslipno = PKD.Pickslipno AND I.LabelNo = PKD.Labelno  
           LEFT JOIN PACKINFO PIF (NOLOCK) ON I.Pickslipno = PIF.Pickslipno AND PKD.CartonNo = PIF.CartonNo    
           WHERE (PIF.TrackingNo IS NULL   
           OR PIF.TrackingNo = '')  
           ORDER BY I.Pickslipno, PKD.CartonNo  
           
         OPEN CUR_CTNTRACK     
           
         FETCH NEXT FROM CUR_CTNTRACK INTO @c_Pickslipno, @n_Cartonno  
  
         WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)             
         BEGIN                                                           
            SET @b_Success = 0    
              
            EXECUTE isp_PackinfoGenTrackingNo_Wrapper   
                    @c_Pickslipno = @c_Pickslipno  
                  , @n_CartonNo  = @n_CartonNo  
                  , @c_PackinfoGenTrackingNo_SP = @c_PackinfoGenTrackingNo_SP    
                  , @b_Success = @b_Success     OUTPUT    
                  , @n_Err     = @n_err         OUTPUT     
                  , @c_ErrMsg  = @c_errmsg      OUTPUT    
              
            IF @b_Success <> 1  
            BEGIN    
               SELECT @n_continue = 3    
            END    
              
            FETCH NEXT FROM CUR_CTNTRACK INTO @c_Pickslipno, @n_Cartonno     
         END           
         CLOSE CUR_CTNTRACK  
         DEALLOCATE CUR_CTNTRACK  
      END            
   END                                                                                                                                                                                                                        
                                                                                                                                                                                                                        
   --NJOW04  
   IF @n_continue = 1 or @n_continue = 2    
   BEGIN  
      IF EXISTS(SELECT 1 FROM INSERTED WHERE CartonNo = 0) AND EXISTS(SELECT 1 FROM sys.Objects WHERE NAME = @c_PackinfoGenTrackingNo_SP AND TYPE = 'P') --NJOW06  
      BEGIN  
         UPDATE PACKINFO WITH (ROWLOCK)  
         SET PACKINFO.Qty = PACKINFO.Qty + INSERTED.Qty  
         FROM INSERTED  
         CROSS APPLY (SELECT MAX(PKD.CartonNo) AS CartonNo FROM PACKDETAIL PKD (NOLOCK) WHERE PKD.Pickslipno = INSERTED.Pickslipno AND PKD.LabelNo = INSERTED.LabelNo) CTN  
         JOIN PACKINFO ON INSERTED.Pickslipno = PACKINFO.Pickslipno  
                       AND CTN.CartonNo = PACKINFO.CartonNo          
  
         IF (@c_DefaultPackInfo = '1') --(WL01 End)  
         BEGIN  
            UPDATE PACKINFO WITH (ROWLOCK)  
            SET PACKINFO.Weight = PACKINFO.Weight + (INSERTED.Qty * Sku.StdGrossWgt),  
                PACKINFO.Cube = PACKINFO.Cube + CASE WHEN ISNULL(CZ.Cube,0) = 0 THEN INSERTED.Qty * Sku.StdCube ELSE 0 END,  
                PACKINFO.CartonType = CASE WHEN ISNULL(PACKINFO.CartonType,'') = '' THEN ISNULL(CZ.CartonType,'') ELSE PACKINFO.CartonType END   --WL02  
            FROM INSERTED   
            CROSS APPLY (SELECT MAX(PKD.CartonNo) AS CartonNo FROM PACKDETAIL PKD (NOLOCK) WHERE PKD.Pickslipno = INSERTED.Pickslipno AND PKD.LabelNo = INSERTED.LabelNo) CTN              
            JOIN PACKINFO ON INSERTED.Pickslipno = PACKINFO.Pickslipno  
                          AND CTN.CartonNo = PACKINFO.CartonNo                           
            JOIN STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey       
                                        AND STORERCONFIG.ConfigKey = 'Default_PackInfo' AND STORERCONFIG.SValue='1'  
            JOIN STORER (NOLOCK) ON (INSERTED.StorerKey = STORER.StorerKey)  
            JOIN SKU (NOLOCK) ON (INSERTED.Storerkey = SKU.Storerkey AND INSERTED.SKU = SKU.Sku)  
            LEFT JOIN CARTONIZATION CZ (NOLOCK) ON (STORER.CartonGroup = CZ.CartonizationGroup AND CZ.CartonType = PACKINFO.CartonType)   
         END                                                
      END  
      ELSE  
      BEGIN  
         UPDATE PACKINFO WITH (ROWLOCK)  
         SET PACKINFO.Qty = PACKINFO.Qty + INSERTED.Qty  
         FROM INSERTED  
         JOIN PACKINFO ON INSERTED.Pickslipno = PACKINFO.Pickslipno  
                       AND INSERTED.CartonNo = PACKINFO.CartonNo   
           
         --(WL01 Start)  
         --IF EXISTS(SELECT 1  
         --          FROM INSERTED  
         --          JOIN STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey       
         --                                     AND STORERCONFIG.ConfigKey = 'Default_PackInfo' AND STORERCONFIG.SValue='1')  
         IF (@c_DefaultPackInfo = '1') --(WL01 End)  
         BEGIN  
            UPDATE PACKINFO WITH (ROWLOCK)  
            SET PACKINFO.Weight = PACKINFO.Weight + (INSERTED.Qty * Sku.StdGrossWgt),  
                PACKINFO.Cube = PACKINFO.Cube + CASE WHEN ISNULL(CZ.Cube,0) = 0 THEN INSERTED.Qty * Sku.StdCube ELSE 0 END,  
                PACKINFO.CartonType = CASE WHEN ISNULL(PACKINFO.CartonType,'') = '' THEN ISNULL(CZ.CartonType,'') ELSE PACKINFO.CartonType END   --WL02  
            FROM INSERTED   
            JOIN PACKINFO ON INSERTED.Pickslipno = PACKINFO.Pickslipno  
                          AND INSERTED.CartonNo = PACKINFO.CartonNo                           
            JOIN STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey       
                                        AND STORERCONFIG.ConfigKey = 'Default_PackInfo' AND STORERCONFIG.SValue='1'  
            JOIN STORER (NOLOCK) ON (INSERTED.StorerKey = STORER.StorerKey)  
            JOIN SKU (NOLOCK) ON (INSERTED.Storerkey = SKU.Storerkey AND INSERTED.SKU = SKU.Sku)  
            LEFT JOIN CARTONIZATION CZ (NOLOCK) ON (STORER.CartonGroup = CZ.CartonizationGroup AND CZ.CartonType = PACKINFO.CartonType)   
         END  
      END  
  
  
      --(WL01 Start)  
      --IF EXISTS (SELECT 1   
      --           FROM INSERTED   
      --           JOIN STORERCONFIG SC (NOLOCK) ON INSERTED.Storerkey = SC.Storerkey AND SC.Configkey = 'PackCartonGID' AND SC.Svalue = '1')    
      IF (@c_PackCartonGID = '1')  
      BEGIN  
         DECLARE @dt_TimeIn DATETIME, @dt_TimeOut DATETIME  
         SET @dt_TimeIn = GETDATE()  
  
         SELECT @c_CartonGID = CASE WHEN ISNULL(CL.SHORT,'N') = 'Y' AND CAST(CL.LONG AS INT) <> 0 THEN  
                              CL.UDF01 + RIGHT(REPLICATE('0',CL.LONG) + SUBSTRING(PACKDETAIL.LABELNO,CAST(CL.UDF02 AS INT)  
                             ,CAST(CL.UDF03 AS INT) - CAST(CL.UDF02 AS INT) + 1)  
                             ,CAST(CL.LONG AS INT) - LEN(CL.UDF01))  
                              WHEN ISNULL(CL.SHORT,'N') = 'Y' AND CAST(CL.LONG AS INT) = 0 THEN CL.UDF01 + PACKDETAIL.LABELNO ELSE PACKDETAIL.LABELNO END  
         FROM INSERTED  
         LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo  
         OUTER APPLY (SELECT TOP 1 CL.SHORT, CL.LONG, CL.UDF01, CL.UDF02, CL.UDF03, CL.CODE2 FROM  
                      CODELKUP CL WITH (NOLOCK) WHERE (CL.LISTNAME = 'BARCODELEN' AND CL.STORERKEY = PackDetail.STORERKEY AND CL.CODE = 'SUPERHUB' AND  
                     (CL.CODE2 = @c_Facility OR CL.CODE2 = '') ) ORDER BY CASE WHEN CL.CODE2 = '' THEN 2 ELSE 1 END ) AS CL   
         WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
         AND   PACKDETAIL.LabelNo = INSERTED.LabelNo   
         AND   INSERTED.PickSlipNo LIKE 'P%'  
  
         --INSERT INTO TRACEINFO (TraceName, TimeIn, [TimeOut], Step1, Step2, Step3, Col1, Col2, Col3)  
         --SELECT 'ntrPackDetailAdd', NULL, NULL, 'Pickslipno', 'CartonNo', 'CartonGID', INSERTED.Pickslipno, INSERTED.CartonNo, @c_CartonGID  
         --FROM INSERTED WITH (NOLOCK)    
         --LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo  
         --WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
         --AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
         --AND   INSERTED.PickSlipNo LIKE 'P%'  
  
         IF EXISTS (SELECT 1 FROM INSERTED WITH (NOLOCK) WHERE INSERTED.CartonNo = 0) --From RDT  
         BEGIN  
            SELECT @nCartonNo = MAX(PACKDETAIL.CartonNo)   
            FROM PACKDETAIL WITH (NOLOCK)    
            JOIN INSERTED WITH (NOLOCK) ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo AND     
                                            PACKDETAIL.LabelNo = INSERTED.LabelNo)  
                                                
            INSERT INTO PACKINFO (PickSlipNo, CartonNo, CartonType, [Cube], Qty, Weight, CartonGID)  
            SELECT DISTINCT INSERTED.PickSlipNo, @nCartonNo, NULL, 0, 0, 0, @c_CartonGID   --WL03  
            FROM INSERTED WITH (NOLOCK)    
            LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo  
            WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
            AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
          AND   @nCartonNo NOT IN (SELECT CartonNo FROM PACKINFO (NOLOCK) WHERE PickSlipNo = INSERTED.PickSlipNo)  
            AND   INSERTED.PickSlipNo LIKE 'P%'    
              
            --SET @dt_TimeOut = GETDATE()  
              
            --INSERT INTO TRACEINFO (TraceName, TimeIn, [TimeOut], Step1, Step2, Step3, Col1, Col2, Col3)  
            --SELECT 'ntrPackDetailAdd', @dt_TimeIn, @dt_TimeOut, 'Pickslipno', 'CartonNo', 'CartonGID', INSERTED.Pickslipno, @nCartonNo, @c_CartonGID  
            --FROM INSERTED WITH (NOLOCK)    
            --LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo  
            --WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
            --AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
            --AND   INSERTED.PickSlipNo LIKE 'P%'  
            --END -- ELSE CARTONNO  
         END  
         ELSE --From EXCEED  
         BEGIN  
            INSERT INTO PACKINFO (PickSlipNo, CartonNo, CartonType, [Cube], Qty, Weight, CartonGID)  
            SELECT DISTINCT INSERTED.PickSlipNo, INSERTED.CartonNo, NULL, 0, INSERTED.Qty, 0, @c_CartonGID   --WL02   --WL03  
            FROM INSERTED WITH (NOLOCK)    
            LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo  
            WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
            AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
            AND   INSERTED.CartonNo NOT IN (SELECT CartonNo FROM PACKINFO (NOLOCK) WHERE PickSlipNo = INSERTED.PickSlipNo)  
            AND   INSERTED.PickSlipNo LIKE 'P%'    
              
            --SET @dt_TimeOut = GETDATE()  
              
            --INSERT INTO TRACEINFO (TraceName, TimeIn, [TimeOut], Step1, Step2, Step3, Col1, Col2, Col3)  
            --SELECT 'ntrPackDetailAdd', @dt_TimeIn, @dt_TimeOut, 'Pickslipno', 'CartonNo', 'CartonGID', INSERTED.CartonNo, @nCartonNo, @c_CartonGID  
            --FROM INSERTED WITH (NOLOCK)    
            --LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo  
            --WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo    
            --AND   PACKDETAIL.LabelNo = INSERTED.LabelNo    
            --AND   INSERTED.PickSlipNo LIKE 'P%'  
         END  
           
  
      END--Packcartongid   
      --(WL01 END)  
   END  
     
/* #INCLUDE <TRCCA2.SQL> */    
   IF @n_continue=3  -- Error Occured - Process And Return    
   BEGIN  
      DECLARE @n_IsRDT INT    
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT    
       
      IF @n_IsRDT = 1    
      BEGIN    
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here    
         -- Instead we commit and raise an error back to parent, let the parent decide    
       
         -- Commit until the level we begin with    
         WHILE @@TRANCOUNT > @n_starttcnt    
            COMMIT TRAN    
       
         -- Raise error with severity = 10, instead of the default severity 16.     
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger    
         RAISERROR (@n_err, 10, 1) WITH SETERROR     
       
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten    
      END    
      ELSE    
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPackDetailAdd'    
         --RAISERROR @n_err @c_errmsg    
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
         RETURN    
         END    
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

/************************************************************************/        
/* Trigger: ntrPackDetailDelete                                         */        
/* Creation Date:                                                       */        
/* Copyright: IDS                                                       */        
/* Written by:                                                          */        
/*                                                                      */        
/* Purpose:                                                             */        
/*                                                                      */        
/* Usage:                                                               */        
/*                                                                      */        
/* Called By: When records delete from PackDetail                       */        
/*                                                                      */        
/* PVCS Version: 2.0                                                    */        
/*                                                                      */        
/* Version: 5.4                                                         */        
/*                                                                      */        
/* Modifications:                                                       */        
/* Date         Author  Ver.  Purposes                                  */    
/* 2011-May-12  KHLim01 1.1   Insert Delete log                         */
/* 2011-Apr-08  AQSKC   1.2   SOS210154 - Auto Shortpick When ExpQty    */
/*                            Reduced (Kc01)                            */
/* 2011-Jul-14  KHLim02 1.3   GetRight for Delete log                   */
/* 2012-Aug-03  TLTING011.4   Add New Col to DELLOG                     */  
/* 2013-Nov-13  NJOW01  1.5   293687 - Anti Diversity LOR Delete        */
/*                            SerialNo                                  */
/* 2015-Nov-17  NJOW02  1.6   Delete packinfo carton if the carton is   */
/*                            deleted                                   */
/* 2015-Nov-30  NJOW03  1.7   356837-fix delete packdetail update to    */
/*                            packinfo.qty                              */
/* 2017-May-29  Ung     1.8   WMS-1919 Add serial no                    */
/* 2019-Mar-13  Ung     1.9   WMS-8134 Add PackDetailInfo               */
/* 2020-Sep-01  NJOW04  1.10  WMS-15009 - call custom stored proc       */  
/* 2020-AUG-06  Wan01   2.0   WMS-14315 - [CN] NIKE_O2_Ecom Packing_CR  */
/* 2020-SEP-12  NJOW05  2.1   WMS-15001 - reverse serial# when del for  */
/*                            config ADAllowInsertExistingSerialNo and  */
/*                            Option1=NotAllowInsertNewSerialNo         */
/* 2021-Nov-26  Wan02   2.2   WMS-18410 - [RG] Logitech Tote ID Packing */
/*                            Change Request                            */
/* 2021-Nov-26  Wan02   2.2   DevOps Conbine Script                     */
/************************************************************************/        
CREATE TRIGGER [dbo].[ntrPackDetailDelete] ON [dbo].[PackDetail]      
FOR  DELETE      
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
          
 DECLARE @b_Success          INT -- Populated by calls to stored procedures - was the proc successful?      
        ,@n_err              INT -- Error number returned by stored procedure or this trigger      
        ,@n_err2             INT -- For Additional Error Detection      
        ,@c_errmsg           NVARCHAR(250) -- Error message returned by stored procedure or this trigger      
        ,@n_continue         INT      
        ,@n_starttcnt        INT -- Holds the current transaction count      
        ,@c_preprocess       NVARCHAR(250) -- preprocess      
        ,@c_pstprocess       NVARCHAR(250) -- post process      
        ,@n_cnt              INT      
        ,@n_PackDetailSysId  INT      
        ,@c_authority        NVARCHAR(1)      
        ,@c_Facility         NVARCHAR(5)      
        ,@c_Storerkey        NVARCHAR(15)      
 
 DECLARE @c_Pickdetailkey     NVARCHAR(10)    --(Kc01)
         ,@n_ShortPackQty     INT            --(Kc01)
       
   DECLARE @n_PackQRFKey      BIGINT         --(Wan01)
         , @cur_PQRF          CURSOR         --(Wan01)

 SELECT @n_continue = 1      
       ,@n_starttcnt = @@TRANCOUNT      
                  
 IF (SELECT COUNT(*) FROM   DELETED) =      
    (SELECT COUNT(*) FROM   DELETED WHERE  DELETED.ArchiveCop = '9')      
 BEGIN      
     SELECT @n_continue = 4      
 END       
   --NJOW04  
   IF @n_continue=1 or @n_continue=2            
   BEGIN  
      IF EXISTS (SELECT 1 FROM DELETED d    
                 JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey      
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue  
                 WHERE  s.configkey = 'PackdetailTrigger_SP')    
      BEGIN             
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL  
            DROP TABLE #INSERTED  
     
        SELECT *   
        INTO #INSERTED  
        FROM INSERTED  
              
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL  
            DROP TABLE #DELETED  
     
        SELECT *   
        INTO #DELETED  
        FROM DELETED  
     
         EXECUTE dbo.isp_PackdetailTrigger_Wrapper  
                   'DELETE'  --@c_Action  
                 , @b_Success  OUTPUT    
                 , @n_Err      OUTPUT     
                 , @c_ErrMsg   OUTPUT    
     
         IF @b_success <> 1    
         BEGIN    
            SELECT @n_continue = 3    
                  ,@c_errmsg = 'ntrPackDetailDelete ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  
         END    
           
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL  
            DROP TABLE #INSERTED  
     
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL  
            DROP TABLE #DELETED  
      END  
   END     

   --(Kc01) - start
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN  
        IF EXISTS(SELECT 1 FROM DELETED WHERE Qty > 0 OR ExpQty > 0) 
      BEGIN
         SELECT TOP 1 @c_Storerkey = Storerkey FROM DELETED   
         SELECT @b_success = 0       
         
         EXECUTE nspGetRight NULL, -- facility        
            @c_Storerkey, -- Storerkey        
            NULL, -- Sku        
            'AutoShortPick', -- Configkey        
            @b_success OUTPUT,       
            @c_authority OUTPUT,       
            @n_err OUTPUT,       
            @c_errmsg OUTPUT        
         
         IF @b_success <> 1      
         BEGIN      
             SELECT @n_continue = 3      
                   ,@c_errmsg = 'ntrPackDetailDelete' + dbo.fnc_RTrim(@c_errmsg)      
         END      
         
         IF @c_authority = '1'      
         BEGIN      
             SET @c_Pickdetailkey = ''
             SET @n_ShortPackQty = 0
             SELECT  @n_ShortPackQty = DELETED.ExpQty FROM DELETED
                      
         
             SELECT TOP 1 @c_Pickdetailkey = ISNULL(PK.Pickdetailkey,'')
                FROM DELETED
                JOIN PACKDETAIL PACKD WITH (NOLOCK)
                  ON PACKD.pickslipno = DELETED.pickslipno
                 AND PACKD.cartonno = DELETED.cartonno 
                 AND PACKD.labelno = DELETED.labelno 
                 AND PACKD.labelline = DELETED.labelline 
                 AND PACKD.sku = DELETED.sku
                JOIN PACKHEADER PH WITH (NOLOCK) on (PACKD.pickslipno = PH.pickslipno and PH.Status < '9')
                JOIN ORDERDETAIL OD WITH (NOLOCK) on (PH.orderkey = OD.orderkey and PACKD.sku = OD.sku and OD.openqty >= PACKD.expqty)
                JOIN PICKDETAIL PK WITH (NOLOCK) on (OD.orderkey = PK.orderkey and OD.orderlinenumber = PK.orderlinenumber and PK.Status <= '5')
                order by OD.openqty 
         
             IF @c_Pickdetailkey <> ''
             BEGIN
                UPDATE PICKDETAIL WITH (ROWLOCK)
                SET QTY = QTY - @n_ShortPackQty
                   ,UOMQTY = UOMQTY - @n_ShortPackQty
                WHERE Pickdetailkey = @c_Pickdetailkey
         
                SELECT @n_err = @@ERROR
                IF @n_err <> 0
                BEGIN
                   SELECT @n_continue = 3
                   SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 61811  
                   SELECT @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Update Failed On PICKDETAIL. (ntrPackDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
                END
             END          
             ELSE
             BEGIN
                SELECT @n_continue = 3
                SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 61812
                SELECT @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Unable To Find Pickdetail to Auto Unallocate. (ntrPackDetailDelete)" 
             END
        END
      END
   END
   --(Kc01) - end
       
-- Serial no
IF @n_continue=1 OR @n_continue=2   
BEGIN
   IF EXISTS( SELECT TOP 1 1 
      FROM DELETED D
         JOIN PackSerialNo PSNO ON (D.PickSlipNo = PSNO.PickSlipNo AND D.CartonNo = PSNO.CartonNo AND D.LabelNo = PSNO.LabelNo AND D.LabelLine = PSNO.LabelLine))
   BEGIN
      DECLARE @n_PackSerialNoKey BIGINT
      DECLARE @curPSNO CURSOR
      SET @curPSNO = CURSOR FOR
         SELECT PSNO.PackSerialNoKey
         FROM DELETED D
            JOIN PackSerialNo PSNO ON (D.PickSlipNo = PSNO.PickSlipNo AND D.CartonNo = PSNO.CartonNo AND D.LabelNo = PSNO.LabelNo AND D.LabelLine = PSNO.LabelLine)
         ORDER BY PSNO.PackSerialNoKey
      OPEN @curPSNO      
      FETCH NEXT FROM @curPSNO INTO @n_PackSerialNoKey    
      WHILE @@FETCH_STATUS = 0 
      BEGIN
         DELETE PackSerialNo WHERE PackSerialNoKey = @n_PackSerialNoKey
         SELECT @n_err = @@ERROR      
         IF @n_err <> 0      
         BEGIN      
            SELECT @n_continue = 3      
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 61813
            SELECT @c_errmsg='NSQL'+CONVERT(char(6), @n_err)+': Delete Failed On Table PackSerialNo. (ntrPackDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '      
            BREAK
         END  
         FETCH NEXT FROM @curPSNO INTO @n_PackSerialNoKey
      END
   END
END

-- PackDetailInfo
IF @n_continue=1 OR @n_continue=2   
BEGIN
   IF EXISTS( SELECT TOP 1 1 
      FROM DELETED D
         JOIN PackDetailInfo PDInfo ON (D.PickSlipNo = PDInfo.PickSlipNo AND D.CartonNo = PDInfo.CartonNo AND D.LabelNo = PDInfo.LabelNo AND D.LabelLine = PDInfo.LabelLine))
   BEGIN
      DECLARE @n_PackDetailInfoKey BIGINT
      DECLARE @curPDInfo CURSOR
      SET @curPDInfo = CURSOR FOR
         SELECT PDInfo.PackDetailInfoKey
         FROM DELETED D
            JOIN PackDetailInfo PDInfo ON (D.PickSlipNo = PDInfo.PickSlipNo AND D.CartonNo = PDInfo.CartonNo AND D.LabelNo = PDInfo.LabelNo AND D.LabelLine = PDInfo.LabelLine)
         ORDER BY PDInfo.PackDetailInfoKey
      OPEN @curPDInfo      
      FETCH NEXT FROM @curPDInfo INTO @n_PackDetailInfoKey    
      WHILE @@FETCH_STATUS = 0 
      BEGIN
         DELETE PackDetailInfo WHERE PackDetailInfoKey = @n_PackDetailInfoKey
         SELECT @n_err = @@ERROR      
         IF @n_err <> 0      
         BEGIN      
            SELECT @n_continue = 3      
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 61818
            SELECT @c_errmsg='NSQL'+CONVERT(char(6), @n_err)+': Delete Failed On Table PackDetailInfo. (ntrPackDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '      
            BREAK
         END  
         FETCH NEXT FROM @curPDInfo INTO @n_PackDetailInfoKey
      END
   END
END

--(Wan01) - START PackQRF
IF @n_continue=1 OR @n_continue=2   
BEGIN
   IF EXISTS(  SELECT TOP 1 1 
               FROM DELETED D
               JOIN PackQRF PQRF ON D.PickSlipNo = PQRF.PickSlipNo
                                AND D.CartonNo  = PQRF.CartonNo 
                                AND D.LabelLine = PQRF.LabelLine
            )
   BEGIN
      SET @cur_PQRF = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
      SELECT PQRF.PackQRFKey
      FROM DELETED D
      JOIN PackQRF PQRF ON D.PickSlipNo = PQRF.PickSlipNo 
                        AND D.CartonNo  = PQRF.CartonNo 
                        AND D.LabelLine = PQRF.LabelLine
      ORDER BY PQRF.PackQRFKey

      OPEN @cur_PQRF  
          
      FETCH NEXT FROM @cur_PQRF INTO @n_PackQRFKey  
        
      WHILE @@FETCH_STATUS = 0 
      BEGIN
         DELETE PackQRF WHERE PackQRFKey = @n_PackQRFKey

         SET @n_err = @@ERROR      
         
         IF @n_err <> 0      
         BEGIN      
            SET @n_continue = 3      
            SET @c_errmsg = CONVERT(char(250),@n_err)
            SET @n_err = 61819
            SET @c_errmsg='NSQL'+CONVERT(char(6), @n_err)+': Delete Failed On Table PackQRF. (ntrPackDetailDelete)' 
                         + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '      
            BREAK
         END  
         FETCH NEXT FROM @cur_PQRF INTO @n_PackQRFKey
      END
      CLOSE @cur_PQRF
      DEALLOCATE @cur_PQRF
   END
END
--(Wan01) - END PackQRF

 IF @n_continue=1 OR @n_continue=2   
 BEGIN      
     SELECT TOP 1 @c_Storerkey = Storerkey FROM DELETED   
     SELECT @b_success = 0       
     EXECUTE nspGetRight NULL, -- facility        
     @c_Storerkey, -- Storerkey        
     NULL, -- Sku        
     'AutoDelPHeader', -- Configkey        
     @b_success OUTPUT,       
     @c_authority OUTPUT,       
     @n_err OUTPUT,       
     @c_errmsg OUTPUT        
     IF @b_success <> 1      
     BEGIN      
         SELECT @n_continue = 3      
               ,@c_errmsg = 'ntrPackDetailDelete' + dbo.fnc_RTrim(@c_errmsg)      
     END      
  
     IF @c_authority = '1'      
     BEGIN      
       IF EXISTS ( SELECT 1   
                   FROM PackHeader with (NOLOCK)  
                        JOIN DELETED on DELETED.PickSlipNo = PackHeader.PickSlipNo  
                   WHERE NOT EXISTS ( SELECT 1 FROM PackDetail with (NOLOCK)  
                                      WHERE PackDetail.PickSlipNo = PackHeader.PickSlipNo ) )  
       BEGIN  
          DELETE PackHeader   
          FROM PackHeader   
               JOIN DELETED on DELETED.PickSlipNo = PackHeader.PickSlipNo  
          WHERE NOT EXISTS ( SELECT 1 FROM PackDetail (NOLOCK)  
                             WHERE PackDetail.PickSlipNo = PackHeader.PickSlipNo )  
          SELECT @n_err = @@ERROR,@n_cnt = @@ROWCOUNT    
          IF @n_err <> 0  
          BEGIN      
              SELECT @n_continue = 3      
                    ,@n_err = 61814        
              SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+      
               ": Deletion of PackHeader not allowed. (ntrPackDetailDelete)"      
          END  
       END  
     END   -- END StorerConfig   
 END  
       
   -- Start (KHLim01) 
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
               ,@c_errmsg = 'ntrPackDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
            -- tlting01  
         INSERT INTO dbo.PackDetail_DELLOG ( PickSlipNo, CartonNo, LabelNo, LabelLine, Storerkey, SKU, QTY )     
         SELECT PickSlipNo, CartonNo, LabelNo, LabelLine, Storerkey, SKU, QTY FROM DELETED  
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61815
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PackDetail Failed. (ntrPackDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01) 

 --NJOW01
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
     DELETE SerialNo 
     FROM SerialNo
     JOIN PACKHEADER PH (NOLOCK) ON SerialNo.Orderkey = PH.Orderkey AND SerialNo.Storerkey = PH.Storerkey
     JOIN DELETED ON PH.PickslipNo = DELETED.PickslipNo
                    AND SerialNo.Sku = DELETED.Sku 
                    AND SerialNo.OrderLineNumber = LTRIM(CAST(DELETED.Cartonno AS NVARCHAR(5)))                    
     JOIN SKU (NOLOCK) ON DELETED.Storerkey = SKU.Storerkey AND DELETED.Sku = SKU.Sku
     LEFT JOIN STORERCONFIG SC (NOLOCK) ON PH.Storerkey = SC.Storerkey AND SC.Configkey = 'ADAllowInsertExistingSerialNo' AND SC.Option1 = 'NotAllowInsertNewSerialNo' AND SC.Svalue = '1' --NJOW05
     WHERE SKU.Susr4 = 'AD'     
     AND SC.SValue IS NULL  --NJOW05
           
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61816
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PackDetail Failed. (ntrPackDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
    END        
    
    --NJOW05
    UPDATE SERIALNO WITH (ROWLOCK)
    SET SERIALNO.Orderkey = '',
        SERIALNO.OrderLineNumber = '',
        SERIALNO.Status = '1',
        SERIALNO.Trafficcop = NULL
    FROM SERIALNO 
    JOIN PACKHEADER PH (NOLOCK) ON SerialNo.Orderkey = PH.Orderkey AND SerialNo.Storerkey = PH.Storerkey
    JOIN DELETED ON PH.PickslipNo = DELETED.PickslipNo
                    AND SerialNo.Sku = DELETED.Sku 
                    AND SerialNo.OrderLineNumber = LTRIM(CAST(DELETED.Cartonno AS NVARCHAR(5)))                    
    JOIN SKU (NOLOCK) ON DELETED.Storerkey = SKU.Storerkey AND DELETED.Sku = SKU.Sku
    JOIN STORERCONFIG SC (NOLOCK) ON PH.Storerkey = SC.Storerkey AND SC.Configkey = 'ADAllowInsertExistingSerialNo' AND SC.Option1 = 'NotAllowInsertNewSerialNo' AND SC.Svalue = '1' --Fix
    WHERE SKU.Susr4 = 'AD'     

    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61817
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PackDetail Failed. (ntrPackDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
    END             
 END     
  
--(Wan02) - START
IF @n_continue = 1 or @n_continue = 2
BEGIN
   ;WITH pdl AS
    ( SELECT PACKDETAILLABEL.RowID
      FROM PACKDETAILLABEL WITH (NOLOCK)
      JOIN DELETED ON PACKDETAILLABEL.Pickslipno = DELETED.Pickslipno AND PACKDETAILLABEL.labelNo = DELETED.labelNo
      LEFT JOIN PACKDETAIL (NOLOCK) ON PACKDETAILLABEL.Pickslipno = PACKDETAIL.Pickslipno AND PACKDETAILLABEL.labelNo = PACKDETAIL.labelNo
      WHERE PACKDETAIL.labelNo IS NULL
    )
   DELETE p WITH (ROWLOCK)
   FROM pdl
   JOIN PACKDETAILLABEL p ON p.RowID = pdl.RowID

   SET @n_err = @@ERROR
   IF @n_err <> 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61817
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PACKDETAILLABEL Failed. (ntrPackDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
   END
END
--(Wan02) - END
 
 --NJOW02
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
     DELETE PACKINFO
     FROM PACKINFO
     JOIN DELETED ON PACKINFO.Pickslipno = DELETED.Pickslipno AND PACKINFO.Cartonno = DELETED.Cartonno
     LEFT JOIN PACKDETAIL (NOLOCK) ON PACKINFO.Pickslipno = PACKDETAIL.Pickslipno AND PACKINFO.Cartonno = PACKDETAIL.Cartonno
     WHERE PACKDETAIL.Cartonno IS NULL

    SELECT @n_err = @@ERROR
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 61817
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PackInfo Failed. (ntrPackDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
    END
 END

 --NJOW03
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
    UPDATE PACKINFO WITH (ROWLOCK)
    SET PACKINFO.Qty = PACKINFO.Qty - DELETED.Qty
    FROM DELETED
    JOIN PACKINFO ON DELETED.Pickslipno = PACKINFO.Pickslipno
                  AND DELETED.CartonNo = PACKINFO.CartonNo                         

     IF EXISTS(SELECT 1
               FROM DELETED
               JOIN STORERCONFIG (NOLOCK) ON DELETED.StorerKey = STORERCONFIG.StorerKey     
                                         AND STORERCONFIG.ConfigKey = 'Default_PackInfo' AND STORERCONFIG.SValue='1')
    BEGIN
       UPDATE PACKINFO WITH (ROWLOCK)
       SET PACKINFO.Weight = PACKINFO.Weight - (DELETED.Qty * Sku.StdGrossWgt),
           PACKINFO.Cube = PACKINFO.Cube - CASE WHEN ISNULL(CZ.Cube,0) = 0 THEN DELETED.Qty * Sku.StdCube ELSE 0 END
       FROM DELETED 
       JOIN PACKINFO ON DELETED.Pickslipno = PACKINFO.Pickslipno
                     AND DELETED.CartonNo = PACKINFO.CartonNo                         
       JOIN STORERCONFIG (NOLOCK) ON DELETED.StorerKey = STORERCONFIG.StorerKey     
                                   AND STORERCONFIG.ConfigKey = 'Default_PackInfo' AND STORERCONFIG.SValue='1'
         JOIN STORER (NOLOCK) ON (DELETED.StorerKey = STORER.StorerKey)
       JOIN SKU (NOLOCK) ON (DELETED.Storerkey = SKU.Storerkey AND DELETED.SKU = SKU.Sku)
         LEFT JOIN CARTONIZATION CZ (NOLOCK) ON (STORER.CartonGroup = CZ.CartonizationGroup AND CZ.CartonType = PACKINFO.CartonType) 
    END
 END 
 
 IF @n_continue=3 -- Error Occured - Process And Return      
 BEGIN      
     IF @@TRANCOUNT = 1      
     AND @@TRANCOUNT >= @n_starttcnt      
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
     EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPackDetailDelete"       
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
/* Trigger: ntrPackDetailUpdate                                         */
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
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.6                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 2005-JAN-07  Shong           Bug fixing                              */
/* 2005-Jun-15  June             Script merging : SOS18664 done by Wanyt*/
/* 2007-July-26 Wanyt           SOS#80943 - Not to Delete Qty = 0 for   */
/*                              Pre-Cartonize                           */
/* 2008-Oct-22  James     1.1   Change @@TRANCOUNT >= @n_starttcnt      */
/* 2008-Dec-17  NJOW      1.2   SOS124169 remove label# from pickdetail */
/*                              when the line deleted at packdetail     */
/* 2011-Apr-08  AQSKC     1.3   SOS210154 - Auto Shortpick When ExpQty  */
/*                              Reduced (Kc01)                          */
/* 2011-Nov-14  Ung       1.4   Add RDT compatible message              */
/* 2012-Apr-05  KHLim01   1.6   move up EditDate & check PK value change*/
/* 2013-Jul-13  TLTING    1.7   ArchiveCop for keep trigger script      */
/* 28-Oct-2013  TLTING    1.8   Review Editdate column update           */
/* 30-Nov-2015  NJOW01    1.9   356837-fix edit packdetail.qty update to*/
/*                              packinfo.qty                            */
/* 14-JUN-2017  Wan01     2.0   WMS-1816 - CN_DYSON_Exceed_ECOM PACKING */
/* 19-Sep-2017  TLTING01  2.1   perfromance tune - catonno 0, no dellog */
/* 19-Jul-2019  WLChooi   2.2   WMS-9661 & WMS-9663 - Add CartonGID when*/ 
/*                              add new carton - Based on storerconfig  */
/*                              Use nspGetRight to get Storerconfig to  */
/*                              filter by Facility for Pickslipno start */
/*                              with P only (Non-ECOM)                  */
/*                              For ECOM, will be done in update trigger*/
/*                              (WL01)                                  */
/* 01-Sep-2020  NJOW02    2.3   WMS-15009 - call custom stored proc     */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPackDetailUpdate] ON [dbo].[PackDetail]
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

     DECLARE @b_Success             int,       -- Populated by calls to stored procedures - was the proc successful?
             @n_err                 int,       -- Error number returned by stored procedure or this trigger
             @c_errmsg              NVARCHAR(250), -- Error message returned by stored procedure or this trigger
             @n_continue            int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
             @n_starttcnt           int,       -- Holds the current transaction count
             @n_cnt                 int        -- Holds the number of rows affected by the Update statement that fired this trigger.
            ,@c_authority           NVARCHAR(1)     -- KHLim01
            ,@c_Storerkey           NVARCHAR(10) --WL01
            ,@c_Facility            NVARCHAR(10) --WL01 
            ,@c_CartonGID           NVARCHAR(50) --WL01
            ,@c_DefaultPackInfo     NVARCHAR(10) = ''  --WL01
            ,@c_PackCartonGID       NVARCHAR(10) = ''  --WL01

     SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_success=0, @n_err=0, @c_errmsg=""

     DECLARE @c_Pickdetailkey NVARCHAR(10)    --(Kc01)
           , @n_ShortPackQty     int            --(KC01)

      DECLARE @c_TracePSNo    NVARCHAR(10) --L01
            , @c_ArchiveCop   NVARCHAR(10)

      SELECT @c_TracePSNo = PickSlipNo
           , @c_ArchiveCop = ArchiveCop
      FROM INSERTED

      IF UPDATE(ArchiveCop) AND EXISTS ( Select 1 FROM INSERTED WHERE ARCHIVECOP = '9' )
      BEGIN
         SELECT @n_continue = 4
      END

      --Get Facility and Configkey (WL01 Start)
      IF @n_continue = 1 or @n_continue = 2  
      BEGIN 
         SELECT TOP 1 @c_Storerkey = PACKHEADER.StorerKey
         FROM INSERTED
         JOIN PACKHEADER (NOLOCK) ON INSERTED.PickSlipNo = PACKHEADER.PickSlipNo 
      
         SELECT TOP 1 @c_Facility = Facility
         FROM INSERTED
         JOIN PACKHEADER (NOLOCK) ON INSERTED.PickSlipNo = PACKHEADER.PickSlipNo 
         JOIN ORDERS (NOLOCK) ON PACKHEADER.StorerKey = ORDERS.StorerKey AND PACKHEADER.OrderKey = ORDERS.OrderKey
         
         IF(ISNULL(@c_Facility,'') = '')
         BEGIN
            SELECT TOP 1 @c_Facility = ORDERS.Facility
            FROM INSERTED
            JOIN PACKHEADER (NOLOCK) ON INSERTED.PickSlipNo = PACKHEADER.PickSlipNo 
            JOIN LOADPLANDETAIL (NOLOCK) ON LOADPLANDETAIL.LOADKEY = PACKHEADER.LOADKEY
            JOIN ORDERS (NOLOCK) ON ORDERS.ORDERKEY = LOADPLANDETAIL.ORDERKEY
         END
      
         EXEC nspGetRight   
            @c_Facility          -- facility  
         ,  @c_Storerkey         -- Storerkey  
         ,  NULL                 -- Sku  
         ,  'Default_PackInfo'   -- Configkey  
         ,  @b_Success           OUTPUT   
         ,  @c_DefaultPackInfo   OUTPUT   
         ,  @n_Err               OUTPUT   
         ,  @c_ErrMsg            OUTPUT 
      
         IF @b_success <> 1  
         BEGIN  
            SET @n_continue = 3  
            SET @n_err = 83049   
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing nspGetRight. (ntrPackdetailAdd)'   
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '    
         END
         
         EXEC nspGetRight   
            @c_Facility          -- facility  
         ,  @c_Storerkey         -- Storerkey  
         ,  NULL                 -- Sku  
         ,  'PackCartonGID'      -- Configkey  
         ,  @b_Success           OUTPUT   
         ,  @c_PackCartonGID     OUTPUT   
         ,  @n_Err               OUTPUT   
         ,  @c_ErrMsg            OUTPUT 
         
         IF @b_success <> 1  
         BEGIN  
            SET @n_continue = 3  
            SET @n_err = 83050   
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing nspGetRight. (ntrPackdetailAdd)'   
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '   
         END 
      END
      --(WL01 End)

      -- KHLim01 Start
      -- Added by YokeBeen on 19-Sep-2003 - Start
      IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
      BEGIN
         UPDATE PACKDETAIL with (ROWLOCK)
            SET EditDate = GetDate() ,
                EditWho = sUser_sName()
               ,ArchiveCop = NULL            -- KHLim01
           FROM PACKDETAIL
           JOIN INSERTED ON (INSERTED.PickSlipNo = PACKDETAIL.PickSlipNo AND
                             INSERTED.CartonNo   = PACKDETAIL.CartonNo AND
                             INSERTED.LabelNo    = PACKDETAIL.LabelNo  AND
                             INSERTED.LabelLine  = PACKDETAIL.LabelLine)
        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
        IF @n_err <> 0
        BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=90001   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Update Failed On PACKDETAIL. (ntrPackDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
        END

      END
      -- Added by YokeBeen on 19-Sep-2003 - End
      
      IF UPDATE(PickSlipNo) OR UPDATE(CartonNo) OR UPDATE(LabelNo) OR UPDATE(LabelLine)   -- KHLim01
      BEGIN
         IF EXISTS(SELECT 1 FROM DELETED
                   WHERE DELETED.CartonNo > 0   -- tlting01
                   AND NOT EXISTS ( SELECT 1 FROM INSERTED
                                      WHERE INSERTED.PickSlipNo = DELETED.PickSlipNo
                                      AND   INSERTED.CartonNo  = DELETED.CartonNo
                                      AND   INSERTED.LabelNo   = DELETED.LabelNo
                                      AND   INSERTED.LabelLine = DELETED.LabelLine
                                     )
                  )
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
                     ,@c_errmsg = 'ntrPackDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)
            END
            ELSE
            IF @c_authority = '1'
            BEGIN
               INSERT INTO dbo.PackDetail_DELLOG ( PickSlipNo, CartonNo, LabelNo, LabelLine, Storerkey, SKU, QTY  )
               SELECT PickSlipNo, CartonNo, LabelNo, LabelLine, Storerkey, SKU, QTY
                  FROM DELETED
                   WHERE DELETED.CartonNo > 0   --tlting01
                   AND NOT EXISTS ( SELECT 1 FROM INSERTED
                                      WHERE INSERTED.PickSlipNo = DELETED.PickSlipNo
                                      AND   INSERTED.CartonNo  = DELETED.CartonNo
                                      AND   INSERTED.LabelNo   = DELETED.LabelNo
                                      AND   INSERTED.LabelLine = DELETED.LabelLine
                                     )

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Trigger On Table PackDetail Failed. (ntrPackDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
               END
            END
         END
      END
      -- KHLim01 end

     /*-------------------------------------------------------------*/
     /* 16 Feb 2004 WANYT SOS#:18664 Archiving & Archive Parameters  */
     /*-------------------------------------------------------------*/

     IF UPDATE(ArchiveCop)
     BEGIN
         SELECT @n_continue = 4
     END

     --NJOW02
     IF @n_continue=1 or @n_continue=2
     BEGIN
        IF EXISTS (SELECT 1 FROM DELETED d
                   JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey
                   JOIN sys.objects sys WITH (NOLOCK) ON sys.type = 'P' AND sys.name = s.Svalue
                   WHERE  s.configkey = 'PackdetailTrigger_SP')
        BEGIN
           IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
              DROP TABLE #INSERTED
     
            SELECT *
            INTO #INSERTED
            FROM INSERTED
     
           IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
              DROP TABLE #DELETED
     
            SELECT *
            INTO #DELETED
            FROM DELETED
     
           EXECUTE dbo.isp_PackdetailTrigger_Wrapper
                     'UPDATE'  --@c_Action
                   , @b_Success  OUTPUT
                   , @n_Err      OUTPUT
                   , @c_ErrMsg   OUTPUT
     
           IF @b_success <> 1
           BEGIN
              SELECT @n_continue = 3
                    ,@c_errmsg = 'ntrPackDetailUpdate ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))
           END
     
           IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
              DROP TABLE #INSERTED
     
           IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
              DROP TABLE #DELETED
        END
     END      

     /*-------------------------------------------------------------*/
     /* 16 Feb 2004 WANYT SOS#:18664 Archiving & Archive Parameters  */
     /*-------------------------------------------------------------*/

      --(Wan01) - START
      DECLARE @cur_PD CURSOR
      DECLARE @c_Storerkey_Prev  NVARCHAR(15)
          --  , @c_Storerkey       NVARCHAR(15) --(WL01)
            , @c_PickSlipNo      NVARCHAR(10)
            , @n_CartonNo        INT
            , @c_LabelNo         NVARCHAR(20)
            , @c_LabelLine       NVARCHAR(5)

            , @c_CopyLBLToDropID NVARCHAR(30)

      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         SET @c_Storerkey_Prev = ''

         SET @cur_PD =  CURSOR FAST_FORWARD READ_ONLY FOR
                        SELECT PACKDETAIL.PickSlipNo
                              ,PACKDETAIL.CartonNo
                              ,PACKDETAIL.LabelNo
                              ,PACKDETAIL.LabelLine
                              ,PACKDETAIL.Storerkey
                        FROM PACKDETAIL WITH (NOLOCK)
                        JOIN INSERTED   ON (PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo)
                                          AND(PACKDETAIL.CartonNo = INSERTED.CartonNo)
                        WHERE ISNULL(RTRIM(PACKDETAIL.DropID),'') = ''
                        AND   ISNULL(RTRIM(PACKDETAIL.LabelNo),'')<>''
                        ORDER BY PACKDETAIL.Storerkey

         OPEN @cur_PD
         FETCH NEXT FROM @cur_PD INTO @c_PickSlipNo
                                    , @n_CartonNo
                                    , @c_LabelNo
                                    , @c_LabelLine
                                    , @c_Storerkey
         WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @c_Storerkey_Prev <> @c_Storerkey
            BEGIN
               SELECT @c_CopyLBLToDropID = SC.Svalue
               FROM STORERCONFIG SC (NOLOCK)
               WHERE SC.Storerkey = @c_Storerkey
               AND   SC.Configkey = 'PackCopyLabelNoToDropId'
               AND   SC.Svalue = '1'
            END

            IF @c_CopyLBLToDropID = '1'
            BEGIN
               UPDATE PACKDETAIL
               SET PACKDETAIL.DropID = @c_LabelNo
               FROM INSERTED WITH (NOLOCK)
               WHERE PACKDETAIL.PickSlipNo= @c_PickSlipNo
               AND   PACKDETAIL.CartonNo  = @n_CartonNo
               AND   PACKDETAIL.LabelLine = @c_LabelLine

               SET @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SET @n_continue = 3
                  SET @c_errmsg = CONVERT(char(250),@n_err)
                  SET @n_err=90014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SET @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Update Failed On PACKDETAIL. (ntrPackDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
               END
            END

            SET @c_Storerkey_Prev = @c_Storerkey
            FETCH NEXT FROM @cur_PD INTO @c_PickSlipNo
                                       , @n_CartonNo
                                       , @c_LabelNo
                                       , @c_LabelLine
                                       , @c_Storerkey
         END
      END
      --(Wan02) - END

      --(Kc01) - start
      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         IF EXISTS(SELECT 1
             FROM   INSERTED
             JOIN   DELETED
               ON   INSERTED.PickSlipNo = DELETED.PickSlipNo
              AND   INSERTED.CartonNo = DELETED.CartonNo
              AND   INSERTED.LabelNo = DELETED.LabelNo
              AND   INSERTED.LabelLine = DELETED.LabelLine
             JOIN   STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey
                    AND STORERCONFIG.ConfigKey = 'AutoShortPick' AND STORERCONFIG.SValue='1'
             WHERE INSERTED.ExpQty < DELETED.ExpQty)
         BEGIN
            SET @c_Pickdetailkey = ''
            SET @n_ShortPackQty = 0
            SELECT @n_ShortPackQty = DELETED.ExpQty - INSERTED.ExpQty
               FROM INSERTED
               JOIN DELETED
               ON (INSERTED.PickSlipNo = DELETED.PickSlipNo AND
                    INSERTED.CartonNo   = DELETED.CartonNo AND
                    INSERTED.LabelNo    = DELETED.LabelNo  AND
                    INSERTED.LabelLine  = DELETED.LabelLine)

            SELECT TOP 1 @c_Pickdetailkey = ISNULL(PK.Pickdetailkey,'')
               FROM INSERTED
               JOIN PACKDETAIL PACKD WITH (NOLOCK)
                  ON PACKD.pickslipno = INSERTED.pickslipno
                  AND PACKD.cartonno = INSERTED.cartonno
                  AND PACKD.labelno = INSERTED.labelno
                  AND PACKD.labelline = INSERTED.labelline
                  AND PACKD.sku = INSERTED.sku
               JOIN PACKHEADER PH WITH (NOLOCK) on (PACKD.pickslipno = PH.pickslipno and PH.Status < '9')
               JOIN ORDERDETAIL OD WITH (NOLOCK) on (PH.orderkey = OD.orderkey and PACKD.sku = OD.sku and OD.openqty >= PACKD.expqty)
               JOIN PICKDETAIL PK WITH (NOLOCK) on (OD.orderkey = PK.orderkey and OD.orderlinenumber = PK.orderlinenumber and PK.Status <= '5')
               order by OD.openqty

            IF @c_Pickdetailkey <> ''
            BEGIN
               UPDATE PICKDETAIL WITH (ROWLOCK)
               SET QTY = QTY - @n_ShortPackQty
                  ,UOMQTY = UOMQTY - @n_ShortPackQty,
                  EditDate = GETDATE(),   --tlting
                  EditWho = SUSER_SNAME()
               WHERE Pickdetailkey = @c_Pickdetailkey

               SELECT @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=90011   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Update Failed On PICKDETAIL. (ntrPackDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
               END
            END
            ELSE
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=90012   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Unable To Find Pickdetail to Auto Unallocate. (ntrPackDetailUpdate)"
            END
         END
      END
      --(Kc01) - end

      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         /*----------------------------------------------------------------------------------*/
         /* 2007-July-26 Wanyt SOS#80943 - Not to Delete Qty = 0 for pre-cartonise - (START) */
         /*                                Where Expqty > 0                                  */
         /*----------------------------------------------------------------------------------*/
        IF EXISTS(SELECT 1 FROM INSERTED WHERE Qty = 0 AND ExpQty = 0)
        BEGIN
             -- NJOW 17-DEC-2008 SOS124169

             IF (SELECT COUNT(SValue)
                        FROM  STORERCONFIG (NOLOCK) JOIN PACKHEADER (NOLOCK) ON (STORERCONFIG.Storerkey = PACKHEADER.Storerkey)
                        JOIN INSERTED ON (PACKHEADER.PickSlipNo = INSERTED.PickSlipNo)
                     WHERE Configkey = 'AssignPackLabelToOrdCfg'
                     AND SValue = '1') > 0
               BEGIN
                  UPDATE PICKDETAIL WITH (ROWLOCK)
                  SET PICKDETAIL.DropId = '',
                     EditDate = GETDATE(),   --tlting
                     EditWho = SUSER_SNAME()
                  FROM PICKDETAIL INNER JOIN INSERTED ON (PICKDETAIL.Sku = INSERTED.Sku
                  AND PICKDETAIL.Dropid = INSERTED.LabelNo)
                  WHERE INSERTED.Qty = 0
                  SELECT @n_err = @@ERROR
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=90011   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Update Failed On PICKDETAIL. (ntrPackDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
                  END
            END
            -- END SOS124169

            DELETE PackDetail
            FROM   PACKDETAIL
            JOIN INSERTED ON (INSERTED.PickSlipNo = PACKDETAIL.PickSlipNo  AND
                                INSERTED.CartonNo   = PACKDETAIL.CartonNo AND
                                INSERTED.LabelNo    = PACKDETAIL.LabelNo  AND
                                INSERTED.LabelLine  = PACKDETAIL.LabelLine)
            WHERE INSERTED.Qty = 0
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=90001   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg="NSQL"+CONVERT(char(5), @n_err)+": Delete Failed On PACKDETAIL. (ntrPackDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
            END
         END
         /*----------------------------------------------------------------------------------*/
         /* 2007-July-26 Wanyt SOS#80943 - Not to Delete Qty = 0 for pre-cartonise - (END)   */
         /*----------------------------------------------------------------------------------*/
      END

      --NJOW01
      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
          IF UPDATE(Qty)
          BEGIN
              UPDATE PACKINFO WITH (ROWLOCK)
              SET PACKINFO.Qty = PACKINFO.Qty + (INSERTED.Qty - DELETED.Qty)
              FROM INSERTED
              JOIN DELETED ON INSERTED.PickSlipNo = DELETED.PickSlipNo
                         AND INSERTED.CartonNo = DELETED.CartonNo
                         AND INSERTED.LabelNo = DELETED.LabelNo
                         AND INSERTED.LabelLine = DELETED.LabelLine
            JOIN PACKINFO ON INSERTED.Pickslipno = PACKINFO.Pickslipno
                          AND INSERTED.CartonNo = PACKINFO.CartonNo
            WHERE INSERTED.Qty <> DELETED.Qty

             IF EXISTS(SELECT 1
                       FROM INSERTED
                      JOIN DELETED ON INSERTED.PickSlipNo = DELETED.PickSlipNo
                                   AND INSERTED.CartonNo = DELETED.CartonNo
                                   AND INSERTED.LabelNo = DELETED.LabelNo
                                   AND INSERTED.LabelLine = DELETED.LabelLine
                       JOIN STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey
                                                 AND STORERCONFIG.ConfigKey = 'Default_PackInfo' AND STORERCONFIG.SValue='1'
                      WHERE INSERTED.Qty <> DELETED.Qty)
            BEGIN
                 UPDATE PACKINFO WITH (ROWLOCK)
                 SET PACKINFO.Weight = PACKINFO.Weight + ((INSERTED.Qty - DELETED.Qty) * Sku.StdGrossWgt),
                     PACKINFO.Cube = PACKINFO.Cube + CASE WHEN ISNULL(CZ.Cube,0) = 0 THEN (INSERTED.Qty - DELETED.Qty) * Sku.StdCube ELSE 0 END
                 FROM INSERTED
                 JOIN DELETED ON INSERTED.PickSlipNo = DELETED.PickSlipNo
                            AND INSERTED.CartonNo = DELETED.CartonNo
                            AND INSERTED.LabelNo = DELETED.LabelNo
                            AND INSERTED.LabelLine = DELETED.LabelLine
               JOIN PACKINFO ON INSERTED.Pickslipno = PACKINFO.Pickslipno
                             AND INSERTED.CartonNo = PACKINFO.CartonNo
               JOIN STORERCONFIG (NOLOCK) ON INSERTED.StorerKey = STORERCONFIG.StorerKey
                                           AND STORERCONFIG.ConfigKey = 'Default_PackInfo' AND STORERCONFIG.SValue='1'
               JOIN STORER (NOLOCK) ON (INSERTED.StorerKey = STORER.StorerKey)
               JOIN SKU (NOLOCK) ON (INSERTED.Storerkey = SKU.Storerkey AND INSERTED.SKU = SKU.Sku)
               LEFT JOIN CARTONIZATION CZ (NOLOCK) ON (STORER.CartonGroup = CZ.CartonizationGroup AND CZ.CartonType = PACKINFO.CartonType)
               WHERE INSERTED.Qty <> DELETED.Qty
            END
          END
      END

      --WL01 Start
      IF (@n_continue = 1 OR @n_continue = 2) AND (@c_PackCartonGID = 1)
      BEGIN
         
         DECLARE @dt_TimeIn DATETIME, @dt_TimeOut DATETIME
         SET @dt_TimeIn = GETDATE()

         --IF UPDATE(Pickslipno)
         BEGIN
            SELECT @c_CartonGID = CASE WHEN ISNULL(CL.SHORT,'N') = 'Y' AND CAST(CL.LONG AS INT) <> 0 THEN
                                 CL.UDF01 + RIGHT(REPLICATE('0',CL.LONG) + SUBSTRING(PACKDETAIL.LABELNO,CAST(CL.UDF02 AS INT)
                                ,CAST(CL.UDF03 AS INT)-CAST(CL.UDF02 AS INT)+1)
                                ,CAST(CL.LONG AS INT)-LEN(CL.UDF01))
                                 WHEN ISNULL(CL.SHORT,'N') = 'Y' AND CAST(CL.LONG AS INT) = 0 THEN CL.UDF01 + PACKDETAIL.LABELNO ELSE PACKDETAIL.LABELNO END
            FROM INSERTED
            LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo
            OUTER APPLY (SELECT TOP 1 CL.SHORT, CL.LONG, CL.UDF01, CL.UDF02, CL.UDF03, CL.CODE2 FROM
                         CODELKUP CL WITH (NOLOCK) WHERE (CL.LISTNAME = 'BARCODELEN' AND CL.STORERKEY = PackDetail.STORERKEY AND CL.CODE = 'SUPERHUB' AND
                        (CL.CODE2 = @c_Facility OR CL.CODE2 = '') ) ORDER BY CASE WHEN CL.CODE2 = '' THEN 2 ELSE 1 END ) AS CL 
            WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo  
            AND   PACKDETAIL.LabelNo = INSERTED.LabelNo 

            IF EXISTS (SELECT 1 FROM PACKINFO (NOLOCK) JOIN INSERTED ON PACKINFO.Pickslipno = INSERTED.Pickslipno AND PACKINFO.CartonNo = INSERTED.CartonNo)
            BEGIN
               UPDATE PACKINFO WITH (ROWLOCK)
               SET CartonGID = @c_CartonGID
               FROM PACKINFO 
               JOIN INSERTED ON (PACKINFO.Pickslipno = INSERTED.Pickslipno AND PACKINFO.CartonNo = INSERTED.CartonNo)
            END
            --SET @dt_TimeOut = GETDATE()

            --Debug Start
            --INSERT INTO TRACEINFO (TraceName, TimeIn, [TimeOut], Step1, Step2, Step3, Col1, Col2, Col3)
            --SELECT 'ntrPackDetailUpdate', @dt_TimeIn, @dt_TimeOut, 'Pickslipno', 'CartonNo', 'CartonGID', INSERTED.Pickslipno, INSERTED.CartonNo, @c_CartonGID
            --FROM INSERTED
            --LEFT OUTER JOIN PackDetail with (NOLOCK) ON PackDetail.PickSlipNo = INSERTED.PickSlipNo
            --WHERE PACKDETAIL.PickSlipNo = INSERTED.PickSlipNo  
            --AND   PACKDETAIL.LabelNo = INSERTED.LabelNo 
            --Debug End

         END
      END
      --WL01 End

     IF @n_continue = 3 -- Error occured - Process and return
     BEGIN
         DECLARE @n_IsRDT INT
         EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

         IF @n_IsRDT = 1
         BEGIN
            -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
            -- Instead we commit and raise an error back to parent, let the parent decide

            -- Commit until the level we begin with
            WHILE @@TRANCOUNT > @n_starttcnt
               COMMIT TRAN

            -- Raise error with severity = 10, instead of the default severity 16.
            -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
            RAISERROR (@n_err, 10, 1) WITH SETERROR

            -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
         END
         ELSE
         BEGIN
            SELECT @b_success = 0
            IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt -- Edit by James, @@TRANCOUNT shd always >= @n_starttcnt
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
            EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPackDetailUpdate"
            RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         END
     END
     ELSE
     BEGIN
         SELECT @b_success = 1
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
             COMMIT TRAN
         END
     END
 END
GO
ALTER TABLE [dbo].[PackDetail] ADD CONSTRAINT [PKPackDetail] PRIMARY KEY CLUSTERED ([PickSlipNo], [CartonNo], [LabelNo], [LabelLine]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_DROPID] ON [dbo].[PackDetail] ([DropID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_LblNo_SKU] ON [dbo].[PackDetail] ([LabelNo], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_RefNo2] ON [dbo].[PackDetail] ([RefNo2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_StorerKey_RefNo] ON [dbo].[PackDetail] ([StorerKey], [RefNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackDetail_Pickslipno_Storer_Sku] ON [dbo].[PackDetail] ([StorerKey], [SKU], [PickSlipNo]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PackDetail] WITH NOCHECK ADD CONSTRAINT [FK_PackDetail_PackHeader] FOREIGN KEY ([PickSlipNo]) REFERENCES [dbo].[PackHeader] ([PickSlipNo])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton No.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Label.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'LabelNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pickslip No.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reference No.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'RefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PackDetail', 'COLUMN', N'StorerKey'
GO
