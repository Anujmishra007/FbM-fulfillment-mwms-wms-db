SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: isp_Bartender_MLPN_CabsCaseID_Label_Head_RPrint         */
/* Creation Date: 15-01-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: AGM046                                                        */
/*                                                                           */
/* Purpose: 	 													         */
/*                                                                           */
/* Called By: EMG03_JCB_Cabs_Kitting_General_Label_001.btw      		     */ 
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purposes                                       */
/* 15-01-2025   AGM046   1.0                                                 */
/*                                                                           */ 
/*****************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[isp_Bartender_MLPN_CabsCaseID_Label_Head_RPrint](  
   @c_Sparm01 NVARCHAR(250),	-- DropID                  
   @c_Sparm02 NVARCHAR(250),	-- Not used	                  
   @c_Sparm03 NVARCHAR(250),	-- Not used	                  
   @c_Sparm04 NVARCHAR(250),	-- Not used                  
   @c_Sparm05 NVARCHAR(250),	-- Not used                  
   @c_Sparm06 NVARCHAR(250),	-- Not used                  
   @c_Sparm07 NVARCHAR(250),	-- Not used                  
   @c_Sparm08 NVARCHAR(250),	-- Not used                  
   @c_Sparm09 NVARCHAR(250),	-- Not used                  
   @c_Sparm10 NVARCHAR(250),	-- Not used                  
   @b_debug   INT = 0                             
)
AS  
BEGIN
   --
   SET NOCOUNT ON                     
   SET ANSI_NULLS OFF                 
   SET QUOTED_IDENTIFIER OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF    
   --
   DECLARE @To_loc            NVARCHAR(200),          
		   @c_CaseID          NVARCHAR(20)
		   
   --
   SET @c_CaseID = @c_Sparm01
   -- Raw pick lines summarized by SKU
   DECLARE @tempTable TABLE
   (
      ID INT IDENTITY(0,1),
      LabelHeader NVARCHAR(100),
      OrderName NVARCHAR(100),
      OrderID NVARCHAR(100),
      WaveID NVARCHAR(100),
      [Delivery_Date&Time] NVARCHAR(100),
      [Date&Time_Picked] NVARCHAR(100),
      ToLocation NVARCHAR(100),
      UID NVARCHAR(100),
      DataCheck NVARCHAR(100),
      CaseID NVARCHAR(100)
   );
     
   -- get data from pickdetail
   INSERT INTO @tempTable	
   SELECT 
	  'CABS Tote Label'AS LabelHeader,
	  orm.ExternOrderKey,
	  orm.OrderKey,
	  pd.WaveKey,
	  FORMAT(orm.DeliveryDate,'dd/MM/yyyy hh:mm tt'),
	  FORMAT(MIN(pd.EditDate),'dd-MM-yyyy hh:mm tt'),
	  pd.Loc,
	  pd.EditWho,
	  '' AS DataCheck,
	  @c_CaseID
   FROM dbo.PICKDETAIL pd WITH (NOLOCK)
	  INNER JOIN dbo.ORDERS orm WITH (NOLOCK)
	     ON orm.StorerKey = pd.StorerKey AND orm.OrderKey = pd.OrderKey
   WHERE pd.StorerKey = 'JCB'
      AND pd.CaseID = @c_CaseID 
   GROUP BY 
      orm.ExternOrderKey, 
	  orm.OrderKey, 
      orm.[Type], 				   
	  pd.WaveKey, 
	  orm.DeliveryDate, 
	  pd.Loc, 
	  pd.EditWho  				    				   				   
   ORDER BY FORMAT(MIN(pd.EditDate),'dd-MM-yyyy hh:mm tt'); 
			  
   -- Get Satge Outbounds
   SELECT  @To_loc = STRING_AGG(Short, ', ') WITHIN GROUP (ORDER BY Short) 
   FROM (		
      SELECT DISTINCT ck.Short 
	  FROM dbo.pickdetail pd WITH (NOLOCK)
	     INNER JOIN dbo.orders orm WITH (NOLOCK)
		    ON pd.OrderKey = orm.OrderKey
			AND pd.Storerkey = orm.StorerKey
		 INNER JOIN dbo.codelkup ck WITH (NOLOCK)
		    ON orm.storerkey = ck.storerkey
			AND orm.c_company = ck.long	   
      WHERE ck.listname LIKE 'jcb%ml'
	     AND pd.CaseID = @c_CaseID
		 AND pd.Storerkey = 'JCB'		
   ) x;
	 								 
   -- Output table declaration: BarTender expects many generic columns
   DECLARE @Result TABLE
   (
      ID INT IDENTITY(1,1),
      Col01 NVARCHAR(80), Col02 NVARCHAR(80), Col03 NVARCHAR(80), Col04 NVARCHAR(80),
      Col05 NVARCHAR(80), Col06 NVARCHAR(80), Col07 NVARCHAR(80), Col08 NVARCHAR(80),
      Col09 NVARCHAR(80), Col10 NVARCHAR(80), Col11 NVARCHAR(80), Col12 NVARCHAR(80),
      Col13 NVARCHAR(80), Col14 NVARCHAR(80), Col15 NVARCHAR(80), Col16 NVARCHAR(80),
      Col17 NVARCHAR(80), Col18 NVARCHAR(80), Col19 NVARCHAR(80), Col20 NVARCHAR(80),
      Col21 NVARCHAR(80), Col22 NVARCHAR(80), Col23 NVARCHAR(80), Col24 NVARCHAR(80),
      Col25 NVARCHAR(80), Col26 NVARCHAR(80), Col27 NVARCHAR(80), Col28 NVARCHAR(80),
      Col29 NVARCHAR(80), Col30 NVARCHAR(80), Col31 NVARCHAR(80), Col32 NVARCHAR(80),
      Col33 NVARCHAR(80), Col34 NVARCHAR(80), Col35 NVARCHAR(80), Col36 NVARCHAR(80),
      Col37 NVARCHAR(80), Col38 NVARCHAR(80), Col39 NVARCHAR(80), Col40 NVARCHAR(80),
      Col41 NVARCHAR(80), Col42 NVARCHAR(80), Col43 NVARCHAR(80), Col44 NVARCHAR(80),
      Col45 NVARCHAR(80), Col46 NVARCHAR(80), Col47 NVARCHAR(80), Col48 NVARCHAR(80),
      Col49 NVARCHAR(80), Col50 NVARCHAR(80), Col51 NVARCHAR(80), Col52 NVARCHAR(80),
      Col53 NVARCHAR(80), Col54 NVARCHAR(80), Col55 NVARCHAR(80), Col56 NVARCHAR(80),
      Col57 NVARCHAR(80), Col58 NVARCHAR(80), Col59 NVARCHAR(80), Col60 NVARCHAR(80)
   );
   -- Return an error message if there is no data
   IF NOT EXISTS (SELECT 1 FROM @tempTable)
   BEGIN
      INSERT INTO @Result (Col01, Col09)
      VALUES ('Kitting Label', 'No data found for CaseID');
	  SELECT * FROM @Result;
	     RETURN;
   END;
   ELSE
   BEGIN		   
      INSERT INTO @Result (
	     Col01,
		 Col02,
		 Col03,
		 Col04,
		 Col05,
		 Col06,
		 Col07,
		 Col08,
		 Col10
      )
	  SELECT 
	     OrderName,
		 OrderID,
		 WaveID,
		 [Delivery_Date&Time],
		 [Date&Time_Picked],
		 @To_loc,
		 UID,
		 CaseID,
		 LabelHeader
      FROM @tempTable WHERE ID = 0;
   END;
   --Final output
    SELECT * FROM @Result ORDER BY ID;
END;
