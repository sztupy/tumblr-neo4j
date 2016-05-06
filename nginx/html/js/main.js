"use strict";

(function() {
  var neo4jSettingsVersionKeyName = 'neo4j-tumblr.version';
  var neo4jSettingsVersionCurrentValue = 1;
  var neo4jSettingsKeyName = 'neo4j.settings';
  var neo4jDefaultInitCommand = 'MATCH (n:Blog) RETURN n, rand() as r ORDER BY r LIMIT 1';

  var ajaxCall = function(url, callback, data, x) {
  	try {
  		x = new(window.XMLHttpRequest || ActiveXObject)('MSXML2.XMLHTTP.3.0');
  		x.open(data ? 'POST' : 'GET', url, 1);
  		x.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
  		x.setRequestHeader('Content-type', 'application/json');
      x.setRequestHeader('Accept', 'application/json');
  		x.onreadystatechange = function () {
  			x.readyState > 3 && callback && callback(x.responseText, x);
  		};
  		x.send(data);
  	} catch (e) {
  		window.console && console.log(e);
  	}
  };

  var getParameterByName = function(name) {
    name = name.replace(/[\[\]]/g, "\\$&");
    var url = window.location.href;
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)", "i"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  }

  var fillInHunblarityValues = function(name) {
    var newName = sanitizeTumblrName(name);
    document.getElementById('hunblarity_form').hunblarity_name.value = newName;
    if (name && Modernizr.json) {
      ajaxCall('/db/data/transaction', function(response) {
          var result = JSON.parse(response);
          ajaxCall(result.commit.replace('http://neo4j-tumblr:7474',''), function(newResponse) {
            var newResult = JSON.parse(newResponse);
            var data = newResult.results;

            if (data) {
              data = data[0].data[0]
              var hunblarityRank = data.row[0];
              var hunblarityPos = data.row[1];

              document.getElementById('hunblarity_rank').textContent = Math.round(hunblarityRank);
              document.getElementById('hunblarity_pos').textContent = hunblarityPos;

              if (!document.getElementById('hunblarity_rank').textContent) {
                document.getElementById('hunblarity_rank').innerText = Math.round(hunblarityRank);
                document.getElementById('hunblarity_pos').innerText = hunblarityPos;
              }

              document.getElementById('hunblarity_result').style.display = 'block';
            }
          },'{"statements":[{"statement":"MATCH (n:Blog{name:\\"'+newName+'\\"}) RETURN n.hunblarityRank, n.hunblarityPos","resultDataContents":["row","graph"],"includeStats":true}]}');
      },'{"statements":[]}');
    }
  }

  var changeNeo4JCommand = function(command) {
    if (Modernizr.localstorage && Modernizr.json) {
      var newConfig,
          oldConfig = localStorage.getItem(neo4jSettingsKeyName);

      if (!oldConfig) {
        newConfig = generateSettingForNeo4J(command);
      } else {
        newConfig = JSON.parse(oldConfig);
        newConfig.initCmd = command;
      }
      localStorage.setItem(neo4jSettingsKeyName, JSON.stringify(newConfig));
    }
  }

  var generateSettingForNeo4J = function(initCommand) {
      return {
        "cmdchar": ":",
        "endpoint": {
          "console": "/db/manage/server/console",
          "version": "/db/manage/server/version",
          "jmx": "/db/manage/server/jmx/query",
          "rest": "/db/data",
          "cypher": "/db/data/cypher",
          "transaction": "/db/data/transaction",
          "authUser": "/user"
        },
        "docs": {
          "developer": "http://neo4j.com/developer-manual/",
          "operations": "http://neo4j.com/operations-manual/"
        },
        "host": "",
        "maxExecutionTime": 3600,
        "heartbeat": 60,
        "maxFrames": 50,
        "maxHistory": 100,
        "maxNeighbours": 25,
        "initialNodeDisplay": 50,
        "maxRows": 100,
        "filemode": false,
        "maxRawSize": 1000,
        "scrollToTop": true,
        "showVizDiagnostics": false,
        "acceptsReplies": false,
        "enableMotd": false,
        "initCmd": initCommand,
        "refreshInterval": 10,
        "userName": "Graph Friend",
        "theme": "normal",
        "retainConnectionCredentials": true,
        "shouldReportUdc": false,
        "experimentalFeatures": false,
        "useBolt": false,
        "boltHost": "",
        "shownTermsAndPrivacy": false,
        "acceptedTermsAndPrivacy": false
      }
  };

  var loadCypherResultInNewWindow = function(command) {
    changeNeo4JCommand(command);
    window.open("/browser/","_blank");
  }

  var installClickHandler = function(where, callback) {
    var form = document.getElementById(where);

    form.onsubmit = function() {
      var command = callback(form);
      if (command) {
        loadCypherResultInNewWindow(command);
      }
      return false;
    }
  }

  var sanitizeTumblrName = function(name) {
    return (name+"").replace(/[^a-zA-Z0-9-]/g,"").toLowerCase();
  }

  if (Modernizr.localstorage && Modernizr.json) {
    // automatically install or update the default config in case it is deemed too old
    var currentSettingsVersion = localStorage.getItem(neo4jSettingsVersionKeyName);
    if (!currentSettingsVersion || +currentSettingsVersion < neo4jSettingsVersionCurrentValue || !localStorage.getItem(neo4jSettingsKeyName)) {
      localStorage.setItem(neo4jSettingsVersionKeyName, neo4jSettingsVersionCurrentValue);
      localStorage.setItem(neo4jSettingsKeyName, JSON.stringify(generateSettingForNeo4J(neo4jDefaultInitCommand)));
    }
  }

  installClickHandler("statistics_random_form",function(form) {
    return "MATCH (n:Blog) RETURN n, rand() as r ORDER BY r LIMIT 10";
  });

  installClickHandler("statistics_yourself_form",function(form) {
    var name = sanitizeTumblrName(form.name.value);
    if (name) {
      return "MATCH (n:Blog{name:'"+name+"'}) RETURN n";
    }
  });

  installClickHandler("statistics_relationship_form",function(form) {
    var name1 = sanitizeTumblrName(form.name_from.value);
    var name2 = sanitizeTumblrName(form.name_to.value);
    if (name1 && name2) {
      return "MATCH (n:Blog{name:'"+name1+"'}),(k:Blog{name:'"+name2+"'}),(x),(k)--(x)--(n) RETURN k,x,n";
    }
  });

  installClickHandler("statistics_distance_form",function(form) {
    var name1 = sanitizeTumblrName(form.name_from.value);
    var name2 = sanitizeTumblrName(form.name_to.value);
    if (name1 && name2) {
      return "MATCH (from:Blog{name:'"+name1+"'}),(to:Blog{name:'"+name2+"'}),path=shortestPath((from)-[:REBLOG*]->(to)) RETURN path";
    }
  });


  if (getParameterByName('hunblarity_name')) {
      fillInHunblarityValues(getParameterByName('hunblarity_name'));
  }

})();
