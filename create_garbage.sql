create table garbage (
  id int primary key, 
  address_id int references addresses(id),
  week int,
  wday int,
  category int
)
