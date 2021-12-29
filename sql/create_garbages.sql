create table if not exists garbages (
  id int primary key, 
  type varchar(32),
  area varchar(32),
  wday varchar(32),
  nweek int
)