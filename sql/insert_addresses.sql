insert into addresses (id, pref, municipalities, townblock) values 
(0, '愛知県', '名古屋市', '西区浅間一丁目'),
(1, '愛知県', '名古屋市', '西区浅間二丁目')on conflict (id) do update set pref = excluded.pref, municipalities = excluded.municipalities, townblock = excluded.townblock;


