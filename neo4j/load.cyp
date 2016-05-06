CREATE CONSTRAINT ON (b:Blog) ASSERT b.name IS UNIQUE;
CREATE INDEX ON :Blog(reblogRank);
CREATE INDEX ON :Blog(threadRank);
CREATE INDEX ON :Blog(commentRank);
CREATE INDEX ON :Blog(likeRank);

CREATE CONSTRAINT ON (t:Thread) ASSERT t.id IS UNIQUE;
CREATE INDEX ON :Thread(type);

CREATE CONSTRAINT ON (c:Comment) ASSERT c.id IS UNIQUE;

MATCH (n)
OPTIONAL MATCH (n)-[r]-()
DELETE n,r;

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///blog.csv' AS line
CREATE (t:Blog{name:line.name});

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///thread.csv' AS line
MERGE (t:Thread{id:toint(line.id)})
ON CREATE set
  t.type = line.type,
  t.internal = case line.internal WHEN 'true' THEN true ELSE false END;

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///thread.csv' AS line
MATCH (b:Blog{name:line.from})
MATCH (t:Thread{id:toint(line.id)})
MERGE (b)-[p:POSTED]->(t);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///comment.csv' AS line
MERGE (t:Comment{id:toint(line.id)})
ON CREATE set
  t.type = line.type,
  t.comment = line.comment;

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///comment.csv' AS line
MATCH (b:Blog{name:line.from})
MATCH (c:Comment{id:toint(line.id)})
MERGE (b)-[cc:COMMENTED]->(c);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///comment.csv' AS line
MATCH (t:Thread{id:toint(line.thread_id)})
MATCH (c:Comment{id:toint(line.id)})
MERGE (c)-[cc:IS_COMMENT_OF]->(t);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///comment.csv' AS line
MATCH (p:Comment{id:toint(line.parent_id)})
MATCH (c:Comment{id:toint(line.id)})
MERGE (c)-[cc:IS_REPLY_OF]->(p);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///like.csv' AS line
MATCH (b1:Blog{name:line.from})
MATCH (b2:Blog{name:line.blog_name})
MERGE (b1)-[l:LIKED_BLOG]->(b2)
ON CREATE SET
  l.photo = 0 + CASE line.type WHEN 'photo' THEN 1 ELSE 0 END,
  l.audio = 0 + CASE line.type WHEN 'audio' THEN 1 ELSE 0 END,
  l.video = 0 + CASE line.type WHEN 'video' THEN 1 ELSE 0 END,
  l.link = 0 + CASE line.type WHEN 'link' THEN 1 ELSE 0 END,
  l.chat = 0 + CASE line.type WHEN 'chat' THEN 1 ELSE 0 END,
  l.text = 0 + CASE line.type WHEN 'text' THEN 1 ELSE 0 END,
  l.quote = 0 + CASE line.type WHEN 'quote' THEN 1 ELSE 0 END,
  l.answer = 0 + CASE line.type WHEN 'answer' THEN 1 ELSE 0 END,
  l.total = 1
ON MATCH SET
  l.photo = l.photo + CASE line.type WHEN 'photo' THEN 1 ELSE 0 END,
  l.audio = l.audio + CASE line.type WHEN 'audio' THEN 1 ELSE 0 END,
  l.video = l.video + CASE line.type WHEN 'video' THEN 1 ELSE 0 END,
  l.link = l.link + CASE line.type WHEN 'link' THEN 1 ELSE 0 END,
  l.chat = l.chat + CASE line.type WHEN 'chat' THEN 1 ELSE 0 END,
  l.text = l.text + CASE line.type WHEN 'text' THEN 1 ELSE 0 END,
  l.quote = l.quote + CASE line.type WHEN 'quote' THEN 1 ELSE 0 END,
  l.answer = l.answer + CASE line.type WHEN 'answer' THEN 1 ELSE 0 END,
  l.total = l.total + 1;

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///like.csv' AS line
MATCH (b:Blog{name:line.from})
MATCH (c:Comment{id:toint(line.comment_id)})
MERGE (b)-[l:LIKED_COMMENT]->(c);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///like.csv' AS line
MATCH (b:Blog{name:line.from})
MATCH (t:Thread{id:toint(line.thread_id)})
MERGE (b)-[l:LIKED_THREAD]->(t);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///reblog.csv' AS line
MATCH (b:Blog{name:line.from})
MATCH (c:Comment{id:toint(line.comment_id)})
MERGE (b)-[r:REBLOGGED_COMMENT]->(c);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///reblog.csv' AS line
MATCH (b:Blog{name:line.from})
MATCH (t:Thread{id:toint(line.thread_id)})
MERGE (b)-[r:REBLOGGED_THREAD]->(t);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///reblog.csv' AS line
MATCH (b1:Blog{name:line.from})
MATCH (b2:Blog{name:line.blog_name})
MERGE (b1)-[r:REBLOGGED_BLOG]->(b2)
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

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///reblog.csv' AS line
MATCH (b1:Blog{name:line.from})
MATCH (b2:Blog{name:line.thread_starter_name})
MERGE (b1)-[r:REBLOGGED_THREAD_OF]->(b2)
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

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///reblog.csv' AS line
MATCH (b1:Blog{name:line.from})
MATCH (b2:Blog{name:line.comment_poster_name})
MERGE (b1)-[r:REBLOGGED_COMMENT_OF]->(b2)
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
