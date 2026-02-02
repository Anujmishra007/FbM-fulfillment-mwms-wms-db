
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: isp_Putaway_EMG03_JCB                               */
/*                                                                      */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2025-08-05  1.0  Agustin  Created - release and putaway dashboard    */
/* 2025-08-06  1.1  Tomas    Amending SP to consider cancelled tasks    */
/* 2025-08-14  1.2  PPA374   Adding required formatting                 */
/************************************************************************/

CREATE OR ALTER PROC [BI].[isp_Putaway_EMG03_JCB]      	  
AS
BEGIN
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   ;WITH itrns AS (
      -- Movimientos manuales: MV desde ENM% con los SourceType indicados
      SELECT DISTINCT
         I.StorerKey,
         I.ToID
      FROM dbo.ITRN I WITH(NOLOCK)
         LEFT JOIN dbo.LOC L WITH(NOLOCK)
         ON I.ToLoc = L.LOC
            AND L.PutawayZone = 'VNA_PDIN'
      WHERE I.TranType = 'MV'
         AND I.FromLoc LIKE 'ENM%'
         AND I.Status IN ('OK', 'HOLD')
         AND L.LOC IS NULL                  
         AND I.ToLoc <> I.FromLoc
         AND I.SourceType IN (
           'rdt_PutawayByID_Confirm',
           'rdtfnc_Move_ID',
           'rdt_TM_PutawayFrom_ReasonCode',
           'rdt_TM_PutawayFrom_Confirm',
           'rdt_TM_PutawayFrom_Confirm_JCB',
           'lsp_Move_Wrapper'
         )
   ),
   itrns_vna AS (
      -- Movimientos VNA: MV ENM% ? PDAGIN-O O PDAGIN-E con Confirm
      SELECT DISTINCT
         I.StorerKey,
         I.ToID
      FROM dbo.ITRN I WITH(NOLOCK)
         INNER JOIN dbo.LOC L WITH(NOLOCK)
         ON I.ToLoc = L.LOC
            AND L.PutawayZone = 'VNA_PDIN'
      WHERE I.TranType = 'MV'
         AND I.FromLoc LIKE 'ENM%'
         AND I.ToLoc <> I.FromLoc
         AND I.SourceType IN (
            'rdt_TM_PutawayFrom_Confirm',
            'rdtfnc_Move_ID',
            'lsp_Move_Wrapper',
            'rdt_TM_PutawayFrom_Confirm_JCB'
         )
         AND I.Status = 'OK'
   ),
   tasks_flags AS (
      -- Flags por pallet en cada recepción: pendiente / cancelada / completada
      SELECT
         rd.storerkey,
         rd.receiptkey,
         td.fromid AS toid,
         MAX(CASE WHEN td.status IN ('0','3','H','S','R') THEN 1 ELSE 0 END) AS has_pending,
         MAX(CASE WHEN td.status = 'X'              THEN 1 ELSE 0 END) AS has_cancelled,
         MAX(CASE WHEN td.status = '9'              THEN 1 ELSE 0 END) AS has_putaway
      FROM dbo.TaskDetail td WITH(NOLOCK)
         INNER JOIN dbo.RECEIPTDETAIL rd WITH(NOLOCK)
         ON rd.storerkey = td.storerkey
            AND rd.toid      = td.fromid
         INNER JOIN dbo.RECEIPT rc WITH(NOLOCK)
         ON rc.storerkey    = rd.storerkey
            AND rc.receiptkey   = rd.receiptkey
            AND rc.ASNStatus    = '9'
            AND rc.StorerKey    = 'JCB'
            AND rc.Facility     = 'EMG03'
            AND rc.UserDefine10 NOT IN ('DL_XDOCK')
            AND rc.FinalizeDate >= DATEADD(DAY, -7, GETDATE())
      WHERE td.tasktype = 'PAF'
      GROUP BY
         rd.storerkey,
         rd.receiptkey,
         td.fromid
   ),
   counts AS (
      SELECT
         rd.storerkey,
         rd.receiptkey,
         /* 1) pallets awaiting release: sin PAF, sin manual mv, sin VNA */
         COUNT(DISTINCT 
	        CASE WHEN rd.toid IS NOT NULL
               AND LTRIM(RTRIM(rd.toid)) <> ''
               AND td.fromid      IS NULL
               AND itrns.toid     IS NULL
               AND itrns_vna.toid IS NULL
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS pallets_awaiting_release,
         /* 2) pallets released awaiting putaway: PAF pendiente, sin manual mv, sin VNA */
         COUNT(DISTINCT 
	        CASE WHEN rd.toid IS NOT NULL
               AND tf.has_pending = 1
               AND itrns.toid     IS NULL
               AND itrns_vna.toid IS NULL
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS pallets_released_awaiting_putaway,
         /* 3) pallets putaway: PAF completada, sin manual mv, sin VNA */
         COUNT(DISTINCT 
	        CASE WHEN rd.toid IS NOT NULL
               AND tf.has_putaway = 1
             --AND itrns.toid     IS NULL
             --AND itrns_vna.toid IS NULL
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS pallets_putaway,
         /* 4) pallets cancelled: PAF cancelada, sin VNA */
         COUNT(DISTINCT 
	        CASE WHEN rd.toid IS NOT NULL
               AND tf.has_cancelled = 1
               AND itrns_vna.toid   IS NULL
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS pallets_cancelled,      
         /* 5) pallets moved by id: movimiento manual */
         COUNT(DISTINCT 
	        CASE WHEN rd.toid IS NOT NULL
               AND itrns.toid = rd.toid
               AND ISNULL(tf.has_putaway,0) = 0
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS pallets_moved_by_id,
         /* 6) total pallets */
         COUNT(DISTINCT 
	        CASE WHEN ISNULL(rd.toid,'')<> ''
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS total_pallets,
         /* 7) pallets only cancelled: cancelada y ni pendiente ni completada ni VNA ni mv manual */
         COUNT(DISTINCT 
	        CASE WHEN rd.toid IS NOT NULL
               AND tf.has_cancelled = 1
               AND tf.has_pending   = 0
               AND tf.has_putaway   = 0
               AND itrns.toid       IS NULL
               AND itrns_vna.toid   IS NULL
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS pallets_only_cancelled,
         /* 8) pallets putaway vía VNA */
         COUNT(DISTINCT 
	        CASE WHEN rd.toid IS NOT NULL
               AND itrns_vna.toid IS NOT NULL
               AND ISNULL(tf.has_putaway,0) = 0
               AND lli.id IS NOT NULL
            THEN rd.toid
            END) AS pallets_putaway_VNA
      FROM dbo.RECEIPTDETAIL rd WITH(NOLOCK)
         INNER JOIN dbo.RECEIPT rc WITH(NOLOCK)
         ON rc.storerkey    = rd.storerkey
            AND rc.receiptkey   = rd.receiptkey
            AND rc.ASNStatus    = '9'
            AND rc.StorerKey    = 'JCB'
            AND rc.Facility     = 'EMG03'
            AND rc.UserDefine10 NOT IN ('DL_XDOCK')
            AND rc.FinalizeDate >= DATEADD(DAY, -7, GETDATE())
         INNER JOIN dbo.LOTxLOCxID lli WITH(NOLOCK) 
	     ON rd.toid=lli.id 
		    AND lli.qty>0 
			AND lli.Id IS NOT NULL 
			AND lli.StorerKey='JCB'
         LEFT JOIN dbo.TaskDetail td WITH(NOLOCK)
         ON td.storerkey = rd.storerkey
            AND td.fromid    = rd.toid
            AND td.tasktype  = 'PAF'
         LEFT JOIN tasks_flags tf 
         ON tf.storerkey  = rd.storerkey
            AND tf.receiptkey = rd.receiptkey
            AND tf.toid       = rd.toid
         LEFT JOIN itrns
         ON itrns.storerkey = rd.storerkey
            AND itrns.toid      = rd.toid
         LEFT JOIN itrns_vna
         ON itrns_vna.storerkey = rd.storerkey
            AND itrns_vna.toid      = rd.toid     
      WHERE rd.QtyReceived>0
      GROUP BY
         rd.storerkey,
         rd.receiptkey
   )
   
   SELECT
      CASE WHEN c.pallets_awaiting_release = c.total_pallets THEN 'Not Released'
      WHEN c.pallets_awaiting_release
         + c.pallets_only_cancelled
         --+ c.pallets_putaway_VNA                 
		 = 0 
	  THEN 'Fully Released'
      ELSE 'Partially Released'
      END  AS Putaway_Status,
      FORMAT(rc.FinalizeDate, 'dd/MM/yyyy HH:mm')           AS Finalize_Date,
      rc.ReceiptKey                                         AS ASN,
      rc.UserDefine05                                       AS Appointment,
      rc.UserDefine08                                       AS Container_ID,
      c.pallets_awaiting_release + c.pallets_only_cancelled AS pallets_awaiting_release,
      c.pallets_released_awaiting_putaway,
      c.pallets_putaway + c.pallets_putaway_VNA             AS pallets_putaway,
    --+ c.pallets_putaway_VNA AS pallets_putaway,
    --c.pallets_putaway_VNA   AS pallets_putaway_VNA,
      c.total_pallets,
      c.pallets_cancelled,
      c.pallets_moved_by_id                                 AS Move_By_ID,
      c.pallets_only_cancelled,                          
      ca.marshall_lane,
      lc.lanes_count
   FROM dbo.RECEIPT rc WITH(NOLOCK)
      INNER JOIN counts c
      ON c.storerkey  = rc.storerkey
         AND c.receiptkey = rc.receiptkey
         AND rc.receiptkey IN (
		    SELECT DISTINCT 
			   ReceiptKey 
			FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
			   INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
			   ON RD.ToId=LLI.Id 
			WHERE LLI.StorerKey='JCB' 
			   AND LLI.Qty>0 
			   AND (
			      LLI.LOC LIKE 'ENM%' 
				  OR LLI.LOC IN (
			         SELECT LOC 
				     FROM dbo.LOC WITH(NOLOCK)
				     WHERE PutawayZone='VNA_PDIN'
			      )
               )
         )
      -- Generar lista de docks
      CROSS APPLY (
         SELECT STRING_AGG(t.toloc, ',') WITHIN GROUP (ORDER BY t.toloc) AS marshall_lane
         FROM (
            SELECT DISTINCT 
		       toloc
            FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
            WHERE storerkey  = rc.storerkey
               AND receiptkey = rc.receiptkey
               AND toloc IS NOT NULL
               AND LTRIM(RTRIM(toloc)) <> ''
         ) AS t
      ) ca
      -- Contar docks distintos
      CROSS APPLY (
         SELECT COUNT(DISTINCT toloc) AS lanes_count
         FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
         WHERE storerkey  = rc.storerkey
            AND receiptkey = rc.receiptkey
            AND toloc IS NOT NULL
            AND LTRIM(RTRIM(toloc)) <> ''
      ) lc
   WHERE
      c.pallets_moved_by_id
      + c.pallets_putaway
      + c.pallets_putaway_VNA       < c.total_pallets
      AND NOT (
         lc.lanes_count = 1
         AND ca.marshall_lane = 'JCB-MAR'
      )
      AND rc.FinalizeDate >= '2025-07-21 06:00'
   ORDER BY
      rc.FinalizeDate DESC;	
END
