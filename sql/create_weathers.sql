create table if not exists weathers (
  id int primary key, 
  pref varchar(32),
  area varchar(32),
  latitude numeric,
  longitude numeric,
  url varchar(64),
  xpath varchar(64)
)