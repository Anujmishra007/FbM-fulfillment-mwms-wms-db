SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* [VN] LogiReport Create new BI View VNWMS - PreallocatePickDetail		   */
/* https://maersk-tools.atlassian.net/browse/WMS-24325                     */
/* Creation Date: 06-Dec-2023                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date          Author		 Ver.  Purposes                                 */
/* 07-Dec-2023   ZiWei      1.0   Created                                  */
/***************************************************************************/

CREATE OR ALTER VIEW BI.V_UTILIZATION_VNA_LOCATION_NIKE
AS
SELECT rd.VNA,
       sum(rd.balanceqty)+cast(ISNULL(ul.UTILITY_loc, 0) AS int) AS USAGE,
       COUNT(rd.loc) AS allloc
FROM
  (SELECT substring(l.loc, 1, 4) AS VNA,
          l.Loc AS loc,
          lt.loc AS loc_check,
          CASE
              WHEN sum(isnull(lt.qty, 0))='0' THEN 0
              ELSE 1
          END AS balanceqty
   FROM BI.V_loc l (nolock)
   LEFT JOIN BI.V_LOTxLOCxID lt ON l.Loc=lt.Loc
   WHERE l.loc like 'VN%' 
and l.locationgroup = 'VNA' and l.facility = 'BPI01' 
and l.hostwhcode = 'NIKE'
   GROUP BY l.Loc,
            lt.loc) AS rd
LEFT JOIN
  (SELECT code AS VNA,
          ISNULL(long,0) AS UTILITY_loc
   FROM BI.v_codelkup
   WHERE LISTNAME='NIKEDB'
     AND storerkey='NIKETH'
     AND udf05='BPI01'
     AND udf04='R') AS ul ON rd.VNA=ul.VNA
GROUP BY rd.VNA,
         ul.UTILITY_loc
GO

GRANT SELECT ON  BI.V_UTILIZATION_VNA_LOCATION_NIKE TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JreportUserTH'
EXEC AS LOGIN = 'Tabrpt'
SELECT SUSER_SNAME()
SELECT TOP (1000) * FROM [BI].[V_UTILIZATION_VNA_LOCATION_NIKE]

REVERT;
*/

