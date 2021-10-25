create table if not exists garbage (
  id int primary key, 
  address_id int references addresses(id),
  nweek integer,
  wday varchar(32),
  category_id int references category(id)
)

