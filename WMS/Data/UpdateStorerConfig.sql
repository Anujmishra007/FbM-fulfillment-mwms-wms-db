        UPDATE dbo.StorerConfig
        SET SValue = '0'
        WHERE ConfigKey = 'RealTimeShip'
          AND SValue = '1'  and StorerKey='FMCGB2B';