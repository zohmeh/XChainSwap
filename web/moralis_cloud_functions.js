Moralis.Cloud.define("getEthTransactions", function(request) {
	const address = request.params.address;
    const contracts = request.params.tokens;
  	const query = new Parse.Query("EthTransactions");
	query.equalTo("from_address", address);
    query.containedIn("to_address", contracts);
	query.descending("block_number");
	query.limit(10);
	return query.find();
});

Moralis.Cloud.define("getPolygonTransactions", function(request) {
	const address = request.params.address;
    const contracts = request.params.tokens;
  	const query = new Parse.Query("PolygonTransactions");
	query.equalTo("from_address", address);
  	query.containedIn("to_address", contracts);
  	query.descending("block_number");
	query.limit(10);
	return query.find();
});

Moralis.Cloud.define("getEthTokenBalances", async (request) => {
    const query = new Moralis.Query("EthTokenBalance");
    query.equalTo("address", request.params.address);
    const tokenbalance = await query.find();
    const results = [];
    if (!tokenbalance) return;
    for(let i = 0; i < tokenbalance.length; ++i) {
        if (tokenbalance[i].attributes["balance"] == "0") {
            tokenbalance[i].destroy();
        }
        results.push(tokenbalance[i]);
    }
   return results;
});

Moralis.Cloud.define("getPolygonTokenBalances", async (request) => {
    const query = new Moralis.Query("PolygonTokenBalance");
    query.equalTo("address", request.params.address);
    const tokenbalance = await query.find();
    const results = [];
    if (!tokenbalance) return;
    for(let i = 0; i < tokenbalance.length; ++i) {
        if (tokenbalance[i].attributes["balance"] == "0") {
            tokenbalance[i].destroy();
        }
        results.push(tokenbalance[i]);
    }
   return results;
});

  Moralis.Cloud.define("getEthBalance", async (request) => {
    const query = new Moralis.Query("EthBalance");
    query.equalTo("address", request.params.address);
    const result = await query.first();
    const ethbalance = result.get("balance")
   return ethbalance;
  });

  Moralis.Cloud.define("getBscBalance", async (request) => {
    const query = new Moralis.Query("PolygonBalance");
    query.equalTo("address", request.params.address);
    const result = await query.first();
    const bscbalance = result.get("balance")
   return bscbalance;
  });

  Moralis.Cloud.define("getPolygonBalance", async (request) => {
    const query = new Moralis.Query("PolygonBalance");
    query.equalTo("address", request.params.address);
    const result = await query.first();
    const polygonbalance = result.get("balance")
   return polygonbalance;
  });

  Moralis.Cloud.define("getNewTransactionStatus", async (request) => {
    const query = new Moralis.Query("EthTransactions");
    query.equalTo("hash", request.params.txHash);
    const result = await query.first();
    const status = result.get("confirmed")
   return status;
  });

  Moralis.Cloud.define("getNewEthTokenTransfers", async (request) => {
    const query = new Moralis.Query("EthTokenTransfers");
    query.equalTo("transaction_hash", request.params.txHash);
    const result = await query.first();
    return result;
  });

  Moralis.Cloud.define("getEthTokenSymbol", async (request) => {
    const query = new Moralis.Query("EthTokenBalance");
    query.equalTo("token_address", request.params.tokenAddress);
    const result = await query.first();
    return result;
  });

  Moralis.Cloud.define("getNewPolygonTokenTransfers", async (request) => {
    const query = new Moralis.Query("PolygonTokenTransfers");
    query.equalTo("transaction_hash", request.params.txHash);
    const result = await query.first();
    return result;
  });

  Moralis.Cloud.define("getPolygonTokenSymbol", async (request) => {
    const query = new Moralis.Query("PolygonTokenBalance");
    query.equalTo("token_address", request.params.tokenAddress);
    const result = await query.first();
    return result;
  });

  Moralis.Cloud.define("getJobsById", async (request) => {
    const query = new Moralis.Query("Jobs");
    query.equalTo("objectId", request.params.id);
    const result = await query.first();
    return result;
  });

  Moralis.Cloud.define("getMyJobs", async (request) => {
    const query = new Moralis.Query("Jobs");
    query.equalTo("user", request.params.address);
    const result = await query.find();
    return result;
  });