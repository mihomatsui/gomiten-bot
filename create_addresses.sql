create table addresses (
  id int primary key, 
  pref varchar(32),
  municipalities varchar(32),
  townblock varchar(32),
  latitude numeric,
  longitude numeric,
)