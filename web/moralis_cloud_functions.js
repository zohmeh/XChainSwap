Moralis.Cloud.define("getTransactions", function(request) {
	const address = request.params.address;
  	const query = new Parse.Query("EthTransactions");
	query.equalTo("to_address", address);
	query.descending("block_number");
	query.limit(10);
	return query.find();
});

Moralis.Cloud.define("getTokenBalances", async (request) => {
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

  Moralis.Cloud.define("getEthBalance", async (request) => {
    const query = new Moralis.Query("EthBalance");
    query.equalTo("address", request.params.address);
    const result = await query.first();
    const ethbalance = result.get("balance")
   return ethbalance;
  });

  Moralis.Cloud.define("getBscBalance", async (request) => {
    const query = new Moralis.Query("BscBalance");
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

  Moralis.Cloud.define("getNFTBalance", async (request) => {
    const query = new Moralis.Query("EthNFTTokenOwners");
    query.equalTo("owner_of", request.params.address);
    const nftbalance = await query.find();
   return nftbalance;
  });

Moralis.Cloud.beforeConsume('NewSwap', function (object) {
    if(object.amount > 100000000000){
        return true;
    }
    return false;
})

Moralis.Cloud.define("getLatestSwaps", async (request) => {
  let allSwaps = [];
  const query = new Moralis.Query("NewSwap");
  query.descending("createdAt");
  const swaps = await query.find();
  for (var i = 0; i < swaps.length; i++) {
    let swap = {
      "srcToken": swaps[i].attributes.srcToken,
      "srcTokenName": "",
      "srcTokenSymbol": "",
      "srcTokenDecimals": 0,
      "dstToken": swaps[i].attributes.dstToken,
      "dstTokenName": "",
      "dstTokenSymbol": "",
      "dstTokenDecimals": 0,
      "amount": swaps[i].attributes.amount,
      "minReturnAmount": swaps[i].attributes.minReturnAmount
    }
    allSwaps.push(swap);
  }
  return allSwaps;
});

