CREATE CONSTRAINT ON (t:TUMBLR) ASSERT t.name IS UNIQUE;
CREATE INDEX ON :t(original);
CREATE INDEX ON :t(gpoy);
CREATE INDEX ON :t(reblogRank);
CREATE INDEX ON :t(originalRank);

MATCH (n)
OPTIONAL MATCH (n)-[r]-()
DELETE n,r;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///tumblrs.csv' AS line
MERGE (t:TUMBLR{name:line.name})
ON CREATE SET t.original = (line.original = 'true'), t.gpoy = (line.gpoy = 'true'), t.reblogRank = 0, t.originalRank = 0
ON MATCH SET t.original = t.original OR (line.original = 'true'), t.gpoy = t.gpoy OR (line.gpoy = 'true');

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///relations.csv' AS line
MATCH (from:TUMBLR{name:line.from}), (to:TUMBLR{name:line.to})
MERGE (to)-[r:REBLOG]->(from)
ON CREATE SET
  r.photo = 0 + CASE line.type WHEN 'photo' THEN 1 ELSE 0 END,
  r.audio = 0 + CASE line.type WHEN 'audio' THEN 1 ELSE 0 END,
  r.video = 0 + CASE line.type WHEN 'video' THEN 1 ELSE 0 END,
  r.link = 0 + CASE line.type WHEN 'link' THEN 1 ELSE 0 END,
  r.chat = 0 + CASE line.type WHEN 'chat' THEN 1 ELSE 0 END,
  r.text = 0 + CASE line.type WHEN 'text' THEN 1 ELSE 0 END,
  r.quote = 0 + CASE line.type WHEN 'quote' THEN 1 ELSE 0 END,
  r.answer = 0 + CASE line.type WHEN 'answer' THEN 1 ELSE 0 END,
  r.total = 1
ON MATCH SET
  r.photo = r.photo + CASE line.type WHEN 'photo' THEN 1 ELSE 0 END,
  r.audio = r.audio + CASE line.type WHEN 'audio' THEN 1 ELSE 0 END,
  r.video = r.video + CASE line.type WHEN 'video' THEN 1 ELSE 0 END,
  r.link = r.link + CASE line.type WHEN 'link' THEN 1 ELSE 0 END,
  r.chat = r.chat + CASE line.type WHEN 'chat' THEN 1 ELSE 0 END,
  r.text = r.text + CASE line.type WHEN 'text' THEN 1 ELSE 0 END,
  r.quote = r.quote + CASE line.type WHEN 'quote' THEN 1 ELSE 0 END,
  r.answer = r.answer + CASE line.type WHEN 'answer' THEN 1 ELSE 0 END,
  r.total = r.total + 1;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///original.csv' AS line
MATCH (from:TUMBLR{name:line.from}), (to:TUMBLR{name:line.to})
MERGE (to)-[r:ORIGINAL]->(from)
ON CREATE SET
  r.photo = 0 + CASE line.type WHEN 'photo' THEN 1 ELSE 0 END,
  r.audio = 0 + CASE line.type WHEN 'audio' THEN 1 ELSE 0 END,
  r.video = 0 + CASE line.type WHEN 'video' THEN 1 ELSE 0 END,
  r.link = 0 + CASE line.type WHEN 'link' THEN 1 ELSE 0 END,
  r.chat = 0 + CASE line.type WHEN 'chat' THEN 1 ELSE 0 END,
  r.text = 0 + CASE line.type WHEN 'text' THEN 1 ELSE 0 END,
  r.quote = 0 + CASE line.type WHEN 'quote' THEN 1 ELSE 0 END,
  r.answer = 0 + CASE line.type WHEN 'answer' THEN 1 ELSE 0 END,
  r.total = 1
ON MATCH SET
  r.photo = r.photo + CASE line.type WHEN 'photo' THEN 1 ELSE 0 END,
  r.audio = r.audio + CASE line.type WHEN 'audio' THEN 1 ELSE 0 END,
  r.video = r.video + CASE line.type WHEN 'video' THEN 1 ELSE 0 END,
  r.link = r.link + CASE line.type WHEN 'link' THEN 1 ELSE 0 END,
  r.chat = r.chat + CASE line.type WHEN 'chat' THEN 1 ELSE 0 END,
  r.text = r.text + CASE line.type WHEN 'text' THEN 1 ELSE 0 END,
  r.quote = r.quote + CASE line.type WHEN 'quote' THEN 1 ELSE 0 END,
  r.answer = r.answer + CASE line.type WHEN 'answer' THEN 1 ELSE 0 END,
  r.total = r.total + 1;
