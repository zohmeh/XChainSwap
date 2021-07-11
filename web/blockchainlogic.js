//goerli Testnet
Moralis.initialize("x0ful1XMWL36Q4W8hD45fkTBo9t645QJWfpoNRo0")
Moralis.serverURL = "https://cexjnpsqzkbg.moralis.io:2053/server";

//mainNet
//Moralis.initialize("ThhtsVE4amxBv91PmwzvbMsO63EOba1yPwa9Hcvm")
//Moralis.serverURL = "https://8qei4hdfzsnk.moralis.io:2053/server";

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

async function swap(/*_fromTokenAddress, _toTokenAddress, _amount, _fromChain, _toChain*/) {
    try {
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;

        const maticPlasma = new Matic({
            network: "testnet", //"mainnet"
            version: "mumbai", //"v1"
            parentProvider: window.web3,
            maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet", 
        });
        const maticPos = new Matic.MaticPOSClient({
            network: "testnet", //"mainnet",
            version: "mumbai", //"v1",
            parentProvider: window.web3,
            maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet",
        });

        const maticPlasmaEthBack = new Matic({
            network: "testnet", //"mainnet",
            version: "mumbai", //"v1",
            parentProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet",
            maticProvider: window.web3,
        });
        const maticPosEthBack = new Matic.MaticPOSClient({
            network: "testnet", //"mainnet",
            version: "mumbai", //"v1",
            parentProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet",
            maticProvider: window.web3,
        });

        //Deposit Ether from Ether to Polygon
        //let txHash = await maticPos.depositEtherForUser(_userAddress, "50000000000000000", { from: _userAddress });
        //console.log(txHash);
        //let complete = await depositCompleted(txHash.transactionHash);
        //console.log(complete);

        //POS
        //Deposit DummyERC20 rom Ether to Polygon
        //Approve Polygon
        //await maticPos.approveERC20ForDeposit("0x655F2166b0709cd575202630952D71E2bB0d61Af", "1000000000000000000", { from: _userAddress });
        //Deposit ERC20
        //let txHash = await maticPos.depositERC20ForUser("0x655F2166b0709cd575202630952D71E2bB0d61Af", _userAddress, "1000000000000000000", { from: _userAddress });

        //Plasma
        //Deposit DummyERC20 rom Ether to Polygon
        //Approve Polygon
        await maticPlasma.approveERC20TokensForDeposit("0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae", "100000000000000000", { from: _userAddress });
        //Deposit ERC20
        let txHash = await maticPlasma.depositERC20ForUser("0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae", _userAddress, "100000000000000000", { from: _userAddress });
        return txHash.transactionHash;

        //Get Token from Polygon to Ether 
        //Plasma
        //await maticPlasmaEthBack.startWithdraw("0x0000000000000000000000000000000000001010", "1000000000000000000", { from: _userAddress });
        //await maticPlasmaEthBack.processExits("0x0000000000000000000000000000000000001010", { from: _userAddress });

        //Get Token from Polygon to Ether 
        //POS
        //await maticPosEthBack.burnERC20("0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa","100000000000000000", { from: _userAddress });
        //await maticPlasmaEthBack.processExits("0x0000000000000000000000000000000000001010", { from: _userAddress });

        /*        console.log(_fromTokenAddress);
                console.log(_toTokenAddress);
                console.log(_amount);
                console.log(_fromChain);
                console.log(_toChain);
        
                let chain = ["1", "56", "137"];
        
                //direct swap without any token bridging
                if (_fromChain == _toChain) {
                    let network = await web3.eth.net.getId();
                    if (network != chain[_fromChain]) {
                        alert("Please switch network");
                        return;
                    }
                    window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, _fromTokenAddress);
                    //Approve 1inch to spend token
                    if (_fromTokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
                        const allowance = await ERC20TokencontractInstance.methods.allowance(_userAddress, "0x11111112542d85b3ef69ae05771c2dccff4faa26").call();
                        if (allowance < web3.utils.toBN(parseFloat(_amount))) {
                            const approve = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", _amount).send({ from: _userAddress });
                        }
                    }
                    //get TX Data for swap to sign and to do the swap            
                    const response = await fetch(`https://api.1inch.exchange/v3.0/${chain[_toChain]}/swap?fromTokenAddress=${_fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${_amount}&fromAddress=${_userAddress}&slippage=1`);
                    const swap = await response.json();
                    const send = await web3.eth.sendTransaction(swap.tx);
                }
        
                //bridging from ether to polygon
                if (_fromChain == 0 && _toChain == 2) {
                    let network = await web3.eth.net.getId();
                    let _fromTokenAfterDeposit;
                    if (network != chain[_fromChain]) {
                        alert("Please switch network");
                        return;
                    }
                    //Deposit Token on Polygon
                    if (_fromTokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
                        //Approve Polygon
                        _fromTokenAddress == "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0" ? await maticPlasma.approveERC20TokensForDeposit(_fromTokenAddress, _amount, { from: _userAddress }) : await maticPos.approveERC20ForDeposit(_fromTokenAddress, _amount, { from: _userAddress });
                        //Deposit ERC20
                        _fromTokenAddress == "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0" ? await maticPlasma.depositERC20ForUser(_fromTokenAddress, _userAddress, _amount, { from: _userAddress }) : await maticPos.depositERC20ForUser(_fromTokenAddress, _userAddress, _amount, { from: _userAddress });;
                        //Approve 1Inch
                        _fromTokenAfterDeposit = "0x0000000000000000000000000000000000001010";
                        window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, _fromTokenAfterDeposit);
                        const approve1 = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", _amount).send({ from: _userAddress });
                    }
                    //Deposit Ether on Polygon
                    else {
                        await maticPos.depositEtherForUser(_userAddress, _amount, { from: _userAddress });
                        _fromTokenAfterDeposit = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
                        //Swich Metamasknetwork to Polygon
                        alert("Switch Network to Polygon");
                        window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, _fromTokenAfterDeposit);
                        const approve1 = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", _amount).send({ from: _userAddress });
                        //????? Wait until Ether is on Polygon ?????
                    }
                    //Getting swap Data for swap on Polygon     
                    const response = await fetch(`https://api.1inch.exchange/v3.0/${chain[_toChain]}/swap?fromTokenAddress=${_fromTokenAfterDeposit}&toTokenAddress=${_toTokenAddress}&amount=${_amount}&fromAddress=${_userAddress}&slippage=1`);
                    const swap = await response.json();
                    const send = await web3.eth.sendTransaction(swap.tx);
                }
                        //bridging from polygon to ether
                        if (_fromChain == 2 && _toChain == 0) {
                            //Burn Token
                            let burnTxHash;
                            _fromTokenAddress == "0x0000000000000000000000000000000000001010" ? burnTxHash = await maticPlasmaEthBack.startWithdraw(_fromTokenAddress, _amount, { from: _userAddress }) : burnTxHash = await maticPosEthBack.burnERC20(_fromTokenAddress, _amount, { from: _userAddress });
                            //Exit Token
                            _fromTokenAddress == "0x0000000000000000000000000000000000001010" ? await maticPlasmaEthBack.processExits(_fromTokenAddress, { from: _userAddress }) : await maticPosEthBack.exitERC20(burnTxHash, { from: _userAddress });;
                            //Approve 1Inch
                            const _fromTokenAfterDeposit = "0x0000000000000000000000000000000000001010";
                            window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, _fromTokenAfterDeposit);
                            const approve1 = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", _amount).send({ from: _userAddress });
                            //Getting swap Data for swap on Polygon     
                            const response = await fetch(`https://api.1inch.exchange/v3.0/${chain[_toChain]}/swap?fromTokenAddress=${_fromTokenAfterDeposit}&toTokenAddress=${_toTokenAddress}&amount=${_amount}&fromAddress=${_userAddress}&slippage=1`);
                            const swap = await response.json();
                            const send = await web3.eth.sendTransaction(swap.tx);
                        }*/
    } catch (error) { console.log(error); }
}

async function getDepositStatus(_txHash) {
    console.log(_txHash);
    let status = false;
    const params = {txHash: _txHash};
    while (!status) {
        status = await Moralis.Cloud.run("getNewDepositStatus", params);
    }
    console.log(status);
    return status;

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

async function getMyDeposits() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const deposits = await Moralis.Cloud.run("getNewDeposits", params);
    return JSON.stringify(deposits);
}