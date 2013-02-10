create table memes (
  id serial8 primary key,
  title varchar(50) not null,
  description varchar(255),
  vid_url varchar(500) not null,
  genre varchar(500),
  fav boolean
)