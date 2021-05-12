Moralis.initialize("WE03b0zdD7ZxXip7WUvPbpGCaWPP4ApNHHFGbXrQ")
Moralis.serverURL = "https://paapz5dnbgto.moralis.io:2053/server";

async function init() {
    window.web3 = await Moralis.Web3.enable();
    //window.NFTTokencontractInstance = new web3.eth.Contract(thecollectorAbi, addresses["thecollector"]);
    let query = new Moralis.Query('EthTokenBalance');
    let subscription = await query.subscribe();
    subscription.on("update", updateDeployedPortfolio)

    let query2 = new Moralis.Query('EthTokenBalance');
    let subscription2 = await query2.subscribe();
    subscription2.on("create", updateDeployedPortfolio)

    let query3 = new Moralis.Query('EthTokenBalance');
    let subscription3 = await query2.subscribe();
    subscription3.on("delete", updateDeployedPortfolio)
}

init()

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

async function fetchParaswapTokens() {
    //fetch all tokens on paraswap mainnnet
    //const response = await fetch('https://apiv4.paraswap.io/v2/tokens/1');
    //const responsetokens = await response.json();
    //const tokens = responsetokens.tokens; 
    //return JSON.stringify(tokens);

    //fetch all tokens on kyber ropsten
    const response = await fetch('https://ropsten-api.kyber.network/currencies');
    const tokens = await response.json();
    return JSON.stringify(tokens);
}

async function getTokenPairRate(_fromToken, _toToken, _amount) {
    try {

        //fetch token rates on paraswap mainnnet    
        //const response = await fetch(`https://apiv4.paraswap.io/v2/prices/?from=${_fromToken}&to=${_toToken}&amount=${_amount}&network=3`);
        //const responserate = await response.json();
        //const bestrate = responserate["priceRoute"]["others"][0]; 
        //return JSON.stringify(bestrate);

        //fetch token rates on kyber ropsten    
        const response = await fetch(`https://ropsten-api.kyber.network/expectedRate?source=${_fromToken}&dest=${_toToken}&sourceAmount=${_amount}`);
        const rate = await response.json();
        return JSON.stringify(rate);

    } catch (error) { alert(error); }
}

async function swap(_fromToken, _toToken, _amount, _mindestamount, _minRate) {
    try {
        //fetch swapdata from kyber ropsten
        const address = ethereum.selectedAddress;
        const response = await fetch(`https://ropsten-api.kyber.network/trade_data?user_address=${address}&src_id=${_fromToken}&dst_id=${_toToken}&src_qty=${_amount}&min_dst_qty=${_mindestamount}&gas_price=medium`);
        const trade_data = await response.json();

        //fetch gas limit from kyber
        const gasresponse = await fetch(`https://ropsten-api.kyber.network/gas_limit?source=${_fromToken}&dest=${_toToken}&amount=${_amount}`);
        const gasresponsedecoded = await gasresponse.json();
        const gas_limit = gasresponsedecoded["data"];

        sendsettings = {
            from: ethereum.selectedAddress,
            gasLimit: gas_limit,
            gasPrice: '20000000000',
        };

        //setting instance of kybernetwork contract at the to-address from the fetching response
        window.kyberNetworkContractInstance = new web3.eth.Contract(kyberNetworkAbi, "0xd719c34261e099Fdb33030ac8909d5788D3039C4"); //trade_data.data[0]["to"]
        //swapping from eth to token
        if (_fromToken == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
            sendsettingsEthSwap = {
                from: ethereum.selectedAddress,
                gasLimit: gas_limit,
                gasPrice: '20000000000',
                value: _amount
            };
            //const swap = await kyberNetworkContractInstance.methods.tradeWithHintAndFee(
            //    _fromToken, _amount, _toToken, ethereum.selectedAddress, _amount, _minRate, "0xd719c34261e099Fdb33030ac8909d5788D3039C4", 
            //).send(sendsettingsEthSwap);
            const swap = await kyberNetworkContractInstance.methods.swapEtherToToken(_toToken, _minRate).send(sendsettingsEthSwap);
        } else if (_toToken == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
            //setting erc20 contractinstance for token to swap
            window.ERC20ContractInstance = new web3.eth.Contract(erc20ABI, _fromToken);
            const approve = await ERC20ContractInstance.methods.approve("0xd719c34261e099Fdb33030ac8909d5788D3039C4", _amount).send(sendsettings);
            //do the swap
            const swap = await kyberNetworkContractInstance.methods.swapTokenToEther(_fromToken, _amount, _minRate).send(sendsettings);
        } else {
            window.ERC20ContractInstance = new web3.eth.Contract(erc20ABI, _fromToken);
            const approve = await ERC20ContractInstance.methods.approve("0xd719c34261e099Fdb33030ac8909d5788D3039C4", _amount).send(sendsettings);
            const swap = await kyberNetworkContractInstance.methods.swapTokenToToken(_fromToken, _amount, _toToken, _minRate).send(sendsettings);
        }

    } catch (error) { alert(error); }
}

async function getAllBalances() {
    const balances = [];
    const query = new Moralis.Query("EthTokenBalance");
    query.equalTo("address", ethereum.selectedAddress);
    const tokenbalance = await query.find();
    for (let i = 0; i < tokenbalance.length; i++) {
        if (tokenbalance[i].attributes["balance"] == "0") {
            tokenbalance[i].destroy();
        }
        balances.push(tokenbalance[i]);

    }
    //const balances = await Moralis.Web3.getTokenBalances({chain: 'Eth'});
    //console.log(balances);
    return JSON.stringify(balances);
}

async function getEthBalance() {
    user = await Moralis.User.current();
    const userAddress = user.get("ethAddress");
    const query = new Moralis.Query("_EthAddress");
    query.equalTo("objectId", userAddress)
    const result = await query.first();
    const balance = result.get("balanceEth");
    return balance;
}

async function getMyTransactions() {
    const query = new Moralis.Query("EthTransactions");
    query.equalTo("from_address", ethereum.selectedAddress.toLowerCase());
    query.limit(10);
    query.descending("createdAt")
    const transactions = await query.find();
    return JSON.stringify(transactions);
}

async function updateDeployedPortfolio() {
    const user = Moralis.User.current();
    const query = new Moralis.Query("UserPortfolios");
    query.equalTo("user", user);
    const result = await query.first();
    if (result) {
        const balances = await getAllBalances();
        result.set("portfolio", JSON.parse(balances));
        result.save();
    }
}

async function deployPortfolio() {
    const balances = await getAllBalances();
    const portfolioObj = JSON.parse(balances);

    const Portfolio = Moralis.Object.extend("UserPortfolios");
    const portfolio = new Portfolio();

    portfolio.set("user", Moralis.User.current());
    portfolio.set("portfolio", portfolioObj);

    portfolio.save();
}

async function getDeployedPortfolios() {
    const allPortfolios = [];
    const query = new Moralis.Query("UserPortfolios");
    const portfolios = await query.find();
    for (var i = 0; i < portfolios.length; i++) {
        let portfolio = {
            "portfolioId": portfolios[i].id,
            "user": portfolios[i].attributes["user"].attributes.username,
            "portfolio": portfolios[i].attributes["portfolio"]
        }
        allPortfolios.push(portfolio);
    }
    return JSON.stringify(allPortfolios);
}

async function followPortfolio(_portfolioId) {
    var myportfolios = [];
    user = await Moralis.User.current();

    //store all portfolios the user is already following
    if (user.get("portfolio")) {
        myportfolios = user.get("portfolios");
    }

    //adding the new portfolio to the old portfolios
    myportfolios.push(_portfolioId);

    user.set("portfolios", myportfolios);
    user.save();
}

async function getFollowedPortfolios() {
    var myportfolioIds = [];
    var myportfolios = [];
    user = await Moralis.User.current();
    if (user.get("portfolios")) {
        myportfolioIds = user.get("portfolios");
        for (var i = 0; i < myportfolioIds.length; i++) {
            const query = new Moralis.Query("UserPortfolios");
            query.equalTo("objectId", myportfolioIds[i]);
            const portfolios = await query.first();
            if (portfolios) {
                let portfolio = {
                    "portfolioId": portfolios.id,
                    "user": portfolios.attributes["user"].attributes.username,
                    "portfolio": portfolios.attributes["portfolio"]
                }
                myportfolios.push(portfolio);
            }
        }
    }
    return JSON.stringify(myportfolios);
}

async function getMyNFT() {
    try {
        user = await Moralis.User.current();
        let userItems = [];
        const query = new Moralis.Query("EthNFTTokenOwners");
        query.equalTo("owner_of", user.attributes.ethAddress);
        const ownedItems = await query.find();
        for (var i = 0; i < ownedItems.length; i++) {
            useritem = JSON.stringify(ownedItems[i]);
            userItems.push(useritem);
        }
        return userItems;
    } catch (error) { console.log(error); }
}