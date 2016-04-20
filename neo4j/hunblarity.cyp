CREATE INDEX ON :t(hunblarityRank);
CREATE INDEX ON :t(hunblarityPos);

MATCH (n:TUMBLR) WITH max(n.reblogRank) as maxrbl, max(n.originalRank) as maxorig
MATCH (n:TUMBLR) WITH n as n, n.reblogRank/maxrbl as mr, n.originalRank/maxorig as mo
SET n.hunblarityRank = mr*40000*CASE WHEN n.original THEN 1 ELSE 0.75 END + mo*60000;

MATCH (n:TUMBLR) WITH n ORDER BY n.hunblarityRank DESC
WITH collect(n) as tumblrs
UNWIND range(0, size(tumblrs)-1) as pos
SET (tumblrs[pos]).hunblarityPos = pos+1;
