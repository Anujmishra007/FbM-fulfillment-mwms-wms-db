CREATE TABLE [dbo].[WMS_Connection_Sum]
(
[SEQ] [int] NOT NULL IDENTITY(1, 1),
[datetime] [datetime] NOT NULL CONSTRAINT [DF_WMS_Connection_Sum_datetime] DEFAULT (getdate()),
[the_database] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_user_process] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[total_database_connections] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WMS_Connection_Sum] ADD CONSTRAINT [PK__WMS_Conn__CA1938C091839A76] PRIMARY KEY CLUSTERED ([SEQ]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMS_Connection_Sum] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_Connection_Sum] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_Connection_Sum] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_Connection_Sum] TO [NSQL]
GO
