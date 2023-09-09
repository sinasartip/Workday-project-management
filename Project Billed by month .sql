SELECT projectname, 
    LEFT( CAST( date as varchar(50) ), 6 ) as monthyear,
    sum(hoursworked) as billed
FROM landing_timeentries
group by projectname, LEFT( CAST( date as varchar(50) ), 6 )