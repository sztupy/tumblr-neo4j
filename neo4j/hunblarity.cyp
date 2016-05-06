CREATE INDEX ON :t(hunblarityRank);
CREATE INDEX ON :t(hunblarityPos);

MATCH (n:Blog) WITH
  max(n.reblogRank) as maxrbl,
  max(n.threadRank) as maxthread,
  max(n.commentRank) as maxcomment,
  max(n.likeRank) as maxlike
MATCH (n:Blog) WITH
  n as n,
  n.reblogRank/maxrbl as mr,
  n.threadRank/maxthread as mt,
  n.commentRank/maxcomment as mc,
  n.likeRank/maxlike as ml
SET n.hunblarityRank = ml*10000+mr*15000+mc*30000+mt*45000;

MATCH (n:Blog) WITH n ORDER BY n.hunblarityRank DESC
WITH collect(n) as tumblrs
UNWIND range(0, size(tumblrs)-1) as pos
SET (tumblrs[pos]).hunblarityPos = pos+1;
