//ropsten Testnet
//Moralis.initialize("WE03b0zdD7ZxXip7WUvPbpGCaWPP4ApNHHFGbXrQ")
//Moralis.serverURL = "https://paapz5dnbgto.moralis.io:2053/server";

//mainNet
Moralis.initialize("ThhtsVE4amxBv91PmwzvbMsO63EOba1yPwa9Hcvm")
Moralis.serverURL = "https://8qei4hdfzsnk.moralis.io:2053/server";

async function init() {
    window.web3 = await Moralis.Web3.enable();
    //window.NFTTokencontractInstance = new web3.eth.Contract(thecollectorAbi, addresses["thecollector"]);
    //let query = new Moralis.Query('EthTokenBalance');
    //let subscription = await query.subscribe();
    //subscription.on("update", updateDeployedPortfolio)

    //let query2 = new Moralis.Query('EthTokenBalance');
    //let subscription2 = await query2.subscribe();
    //subscription2.on("create", updateDeployedPortfolio)

    //let query3 = new Moralis.Query('EthTokenBalance');
    //let subscription3 = await query2.subscribe();
    //subscription3.on("delete", updateDeployedPortfolio)


}

init()

async function getSwaps() {
    var allSwaps = [];
    const swaps = await Moralis.Cloud.run("getLatestSwaps");
    //fetch token infos 
    const response = await fetch('https://api.1inch.exchange/v3.0/1/tokens');
    const tokens = await response.json();
    for (var i = 0; i < swaps.length; i++) {
        if (tokens["tokens"][swaps[i]["srcToken"].toLowerCase()] && tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]) {swaps[i]["srcTokenName"] = tokens["tokens"][swaps[i]["srcToken"].toLowerCase()]["symbol"]; swaps[i]["dstTokenName"] = tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]["symbol"];}
        //if (tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]) {swaps[i]["dstTokenName"] = tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]["symbol"];}
        if (tokens["tokens"][swaps[i]["srcToken"].toLowerCase()] && tokens["tokens"][swaps[i]["srcToken"].toLowerCase()]["decimals"]) {swaps[i]["srcTokenDecimals"] = tokens["tokens"][swaps[i]["srcToken"].toLowerCase()]["decimals"];}
        if (tokens["tokens"][swaps[i]["dstToken"].toLowerCase()] && tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]["decimals"]) {swaps[i]["dstTokenDecimals"] = tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]["decimals"];}
        if (tokens["tokens"][swaps[i]["srcToken"].toLowerCase()] && tokens["tokens"][swaps[i]["srcToken"].toLowerCase()]["logoURI"]) {swaps[i]["srcTokenSymbol"] = tokens["tokens"][swaps[i]["srcToken"].toLowerCase()]["logoURI"];}
        if (tokens["tokens"][swaps[i]["dstToken"].toLowerCase()] && tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]["logoURI"]) {swaps[i]["dstTokenSymbol"] = tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]["logoURI"];}
        if (tokens["tokens"][swaps[i]["srcToken"].toLowerCase()] && tokens["tokens"][swaps[i]["dstToken"].toLowerCase()]){
        var swap = JSON.stringify(swaps[i]);
        allSwaps.push(swap);}
    }
    return allSwaps;
}

async function loggedIn() {
    try {
        user = await Moralis.User.current();
        let name = user.get("username");
        let avatar = user.get("avatar");
        return [name, avatar];
    } catch (error) { console.log(error); }
}

async function login() {
    try {
        user = await Moralis.User.current();
        if (!user) {
            var user = await Moralis.Web3.authenticate();
        }
        let name = user.get("username");
        let avatar = user.get("avatar");
        return [name, avatar];
    } catch (error) { console.log(error); }
}

async function logout() {
    try {
        user = await Moralis.User.logOut();
        return (Moralis.User.current());
    } catch (error) { console.log(error); }
}

async function setUserData(_file, _username) {
    user = await Moralis.User.current();
    let file = [];
    for (var i = 0; i < _file.length; i++) {
        file.push(_file[i]);
    }
    try {
        if (user) {
            user.set("username", _username);
            user.set("avatar", file);
            return _username;
        }
    } catch (error) { console.log(error); }
}

async function fetch1InchTokens(_chain) {
    //_chain = 1 => Ethereum
    //_chain = 56 => BSC
    //fetch all tokens on 1inch eth-mainnnet
    try {
        const response = await fetch(`https://api.1inch.exchange/v3.0/${_chain}/tokens`);
        const tokens = await response.json();
        return JSON.stringify(tokens["tokens"]);
    } catch (error) { console.log(error); }
}

async function getQuote(_fromToken, _toToken, _amount, _chain) {
    try {
        const response = await fetch(`https://api.1inch.exchange/v3.0/${_chain}/quote?fromTokenAddress=${_fromToken}&toTokenAddress=${_toToken}&amount=${_amount}`);
        const quote = await response.json();
        return JSON.stringify(quote);
    } catch (error) { console.log(error); }
}

async function swap(_fromToken, _toToken, _amount) {
    try {
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;
        const response = await fetch(`https://api.1inch.exchange/v3.0/1/swap?fromTokenAddress=${_fromToken}&toTokenAddress=${_toToken}&amount=${_amount}&fromAddress=${_userAddress}&slippage=1`);
        const swap = await response.json();
        console.log(swap);
    } catch (error) { console.log(error); }
}

async function getTokenBalances() {
    let tokenBalances = [];
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const balances = await Moralis.Cloud.run("getTokenBalances", params);
    for (var i = 0; i < balances.length; i++) {
        let balance = JSON.stringify(balances[i]);
        tokenBalances.push(balance);
    }
    return tokenBalances;
}

async function getEthBalance() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const ethbalance = await Moralis.Cloud.run("getEthBalance", params);
    return ethbalance;
}

async function getBscBalance() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const bscbalance = await Moralis.Cloud.run("getBscBalance", params);
    return bscbalance;
}

async function getMyTransactions() {
    const query = new Moralis.Query("EthTransactions");
    query.equalTo("from_address", ethereum.selectedAddress.toLowerCase());
    query.limit(10);
    query.descending("createdAt")
    const transactions = await query.find();
    return JSON.stringify(transactions);
}

async function getMyNFT() {
    try {
        let nfts = [];
        user = await Moralis.User.current();
        const params = { address: user.attributes.ethAddress };
        const nftbalances = await Moralis.Cloud.run("getNFTBalance", params);
        for (var i = 0; i < nftbalances.length; i++) {
            const nftbalance = JSON.stringify(nftbalances[i]);
            nfts.push(nftbalance);
        }
        return nfts;
    } catch (error) { console.log(error); }
}