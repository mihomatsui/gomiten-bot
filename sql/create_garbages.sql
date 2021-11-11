create table if not exists garbages (
  id int primary key, 
  nth varchar(32),
  wday varchar(32),
  foreign key (category_id) references category(id)
)