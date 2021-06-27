//ropsten Testnet
//Moralis.initialize("WE03b0zdD7ZxXip7WUvPbpGCaWPP4ApNHHFGbXrQ")
//Moralis.serverURL = "https://paapz5dnbgto.moralis.io:2053/server";

//mainNet
Moralis.initialize("x0ful1XMWL36Q4W8hD45fkTBo9t645QJWfpoNRo0")
Moralis.serverURL = "https://cexjnpsqzkbg.moralis.io:2053/server";

async function init() {
    window.web3 = await Moralis.Web3.enable();
    
    //window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0");
    //const allowance = await ERC20TokencontractInstance.methods.approve("0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0", "1").send({from: "0xC4e2c53664d929e1D7D0AE9fBC848690EF3f81C1"});
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

async function swap(_fromTokenAddress, _toTokenAddress, _amount, _fromChain, _toChain) {
    try {
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;

        let posRootERC20 = "0x655F2166b0709cd575202630952D71E2bB0d61Af"
        //let posChildERC20 =
        //let posWETH =
        //let rootChainWETH =
        let MATIC_RPC = "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai";
        let ETHEREUM_RPC = "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli";
        //let VERSION = 
        let NETWORK = "testnet";
        let MATIC_CHAINID = 80001;
        let ETHEREUM_CHAINID = 5;


        const maticPosClient = new Matic.MaticPOSClient({
            network: "testnet",
            version: "mumbai",
            parentProvider: window.web3,
            maticProvider: MATIC_RPC
        });

        //Deposit ERC20 test tokens from görli to mumbai testnet
        await maticPosClient.approveERC20ForDeposit(posRootERC20, "1000000000000000000", {from: _userAddress});
        await maticPosClient.depositERC20ForUser(posRootERC20, _userAddress, "1000000000000000000", {from: _userAddress});
        
        /*console.log(_fromTokenAddress);
        console.log(_toTokenAddress);
        console.log(_amount);
        console.log(_fromChain);
        console.log(_toChain);
        
        let chain = ["1", "56", "137"];
        
        //direct swap without any token bridging
        if(_fromChain == _toChain) {
            window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, _fromTokenAddress);
            //Approve 1inch to spend token
            if(_fromTokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
                const allowance = await ERC20TokencontractInstance.methods.allowance(_userAddress, "0x11111112542d85b3ef69ae05771c2dccff4faa26").call();
                if(allowance < web3.utils.toBN(parseFloat(_amount))) {
                    const approve = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", _amount).send({from: _userAddress});
                }
            }       
            //get TX Data for swap to sign and to do the swap            
            const response = await fetch(`https://api.1inch.exchange/v3.0/${chain[_fromChain]}/swap?fromTokenAddress=${_fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${_amount}&fromAddress=${_userAddress}&slippage=1`);
            const swap = await response.json();
            const send = await web3.eth.sendTransaction(swap.tx);
        }
        
        //bridging from ether to polygon
        if(_fromChain == 0 && _toChain == 2) {
            window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, _fromTokenAddress);
            window.PolygonBridgecontractInstance = new web3.eth.Contract(polygonBridgeABI, "0x401F6c983eA34274ec46f84D70b31C151321188b");
            //Approve Polygonbridge to spent my tokens
            //if(_fromTokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
                //Approve Polygon
                //const allowancePolygon = await ERC20TokencontractInstance.methods.allowance(_userAddress, "0x401F6c983eA34274ec46f84D70b31C151321188b6").call();
                //if(allowancePolygon < web3.utils.toBN(parseFloat(_amount))) {
                    //const approve = await ERC20TokencontractInstance.methods.approve("0xd505C3822C787D51d5C2B1ae9aDB943B2304eB23", _amount).send({from: _userAddress});
                //}
                //Approve 1Inch
                //const allowance1Inch = await ERC20TokencontractInstance.methods.allowance(_userAddress, "0x11111112542d85b3ef69ae05771c2dccff4faa26").call();
                //if(allowance1Inch < web3.utils.toBN(parseFloat(_amount))) {
                //    const approve1 = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", _amount).send({from: _userAddress});
                //}
            //}
            //Deposit Token
            //if(_fromTokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
                const deposit = await PolygonBridgecontractInstance.methods.depositERC20ForUser(_fromTokenAddress, _userAddress, _amount).send({from: _userAddress});
            //}  else {
            //    const deposit = await PolygonBridgecontractInstance.methods.depositEther().send({from: _userAddress, value: _amount});
            //}
        }*/
    } catch (error) { console.log(error); }
}

async function getEthTokenBalances() {
    let tokenBalances = [];
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const ethTokenBalances = await Moralis.Cloud.run("getEthTokenBalances", params);
    for (var i = 0; i < ethTokenBalances.length; i++) {
        let balance = JSON.stringify(ethTokenBalances[i]);
        tokenBalances.push(balance);
    }
    return tokenBalances;
}

async function getPolygonTokenBalances() {
    let tokenBalances = [];
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const polygonTokenBalances = await Moralis.Cloud.run("getPolygonTokenBalances", params);
    for (var i = 0; i < polygonTokenBalances.length; i++) {
        let balance = JSON.stringify(polygonTokenBalances[i]);
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

async function getPolygonBalance() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const polygonbalance = await Moralis.Cloud.run("getPolygonBalance", params);
    return polygonbalance;
}

async function getMyTransactions() {
    const query = new Moralis.Query("EthTransactions");
    query.equalTo("from_address", ethereum.selectedAddress.toLowerCase());
    query.limit(10);
    query.descending("createdAt")
    const transactions = await query.find();
    return JSON.stringify(transactions);
}

/*async function getMyNFT() {
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
}*/