//goerli Testnet
//Moralis.initialize("x0ful1XMWL36Q4W8hD45fkTBo9t645QJWfpoNRo0")
//Moralis.serverURL = "https://cexjnpsqzkbg.moralis.io:2053/server";

//mainNet
Moralis.initialize("ThhtsVE4amxBv91PmwzvbMsO63EOba1yPwa9Hcvm")
Moralis.serverURL = "https://8qei4hdfzsnk.moralis.io:2053/server";

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

async function bridgingEth(_amount, _fromChain, _toChain, _jobId) {
    try {
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;

        const maticPos = new Matic.MaticPOSClient({
            network: "mainnet", //"testnet",
            version: "v1", //"mumbai",
            parentProvider: window.web3,
            maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai",
        });

        const maticPosEthBack = new Matic.MaticPOSClient({
            network: "mainnet", //"testnet",
            version: "v1", //"mumbai",
            parentProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli",
            maticProvider: window.web3,
        });

        if (_fromChain == 0 && _toChain == 2) {
            //Deposit Ether from Ether to Polygon
            let txHash = await maticPos.depositEtherForUser(_userAddress, _amount, { from: _userAddress });
            const params = { id: _jobId };
            let job = await Moralis.Cloud.run("getJobsById", params);
            job.set("txHash", txHash.transactionHash);
            job.set("status", "ethbridged");
            await job.save();
            return "ethbridged";
        }
        else if (_fromChain == 2 && _toChain == 0) {
            //Deposit Ether from Polygon to Ether
            let burnTxHash = await maticPosEthBack.burnERC20(/*"0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa"*/ "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619", _amount, { from: _userAddress });
            const params = { id: _jobId };
            let job = await Moralis.Cloud.run("getJobsById", params);
            job.set("txHash", burnTxHash.transactionHash);
            job.set("status", "ethbridged");
            await job.save();
            return "ethbridged";
        }
    } catch (error) { console.log(error); }
}

async function erc20Exit(_jobId) {
    user = await Moralis.User.current();
    const _userAddress = user.attributes.ethAddress;
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);
    const maticPos = new Matic.MaticPOSClient({
        network: "mainnet", //"testnet",
        version: "v1", //"mumbai",
        parentProvider: window.web3,
        maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai",
    });
    await maticPos.exitERC20(job.attributes.txHash, { from: _userAddress });
    job.set("status", "erc20Exit");
    await job.save();
    return "erc20Exit";
}

async function bridgingMatic(_amount, _jobId) {
    try {
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;

        const maticPlasma = new Matic({
            network: "mainnet", //"testnet",
            version: "v1", //"mumbai",
            parentProvider: window.web3,
            maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai", 
        });

        //Approve Polygon
        await maticPlasma.approveERC20TokensForDeposit(/*"0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae"*/ "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0", _amount, { from: _userAddress });
        //Deposit ERC20
        let txHash = await maticPlasma.depositERC20ForUser(/*"0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae"*/ "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0", _userAddress, _amount, { from: _userAddress });
        //Setting transactionHash for Job
        const params = { id: _jobId };
        let job = await Moralis.Cloud.run("getJobsById", params);
        job.set("txHash", txHash.transactionHash);
        job.set("status", "maticbridged");
        await job.save();

        return "maticbridged";

    } catch (error) { console.log(error); }
}

async function checkForInclusion(_jobId) {
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);
    await checkInclusion(job.attributes.txHash, /*"0x2890ba17efe978480615e330ecb65333b880928e"*/ "0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287");
    job.set("status", "erc20Ethcompleted");
    await job.save();
    console.log("Inclusion Check");
    return "erc20Ethcompleted";
}

async function checkEthCompleted(_jobId) {
    let deposit = false
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);
    while (!deposit) {
        deposit = await depositCompletedEth(job.attributes.txHash);
    }
    job.set("status", "ethcompleted");
    await job.save();
    return "ethcompleted";
}

async function checkMaticCompleted(_jobId) {
    let deposit;
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);
    while (!deposit) {
        deposit = await depositCompletedMatic(job.attributes.txHash);
    }
    job.set("status", "maticcompleted");
    await job.save();
    return "maticcompleted";
}

async function doSwap(_fromTokenAddress, _toTokenAddress, _amount, _fromChain, _jobId) {
    
    let chain = ["1", "56", "137"];
    user = await Moralis.User.current();
    const _userAddress = user.attributes.ethAddress;

    window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, _fromTokenAddress);
    //Approve 1inch to spend token
    if (_fromTokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
        const allowance = await ERC20TokencontractInstance.methods.allowance(_userAddress, "0x11111112542d85b3ef69ae05771c2dccff4faa26").call();
        if (allowance < web3.utils.toBN(parseFloat(_amount))) {
            const approve = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", _amount).send({ from: _userAddress });
        }
    }
    //get TX Data for swap to sign and to do the swap            
    const response = await fetch(`https://api.1inch.exchange/v3.0/${chain[_fromChain]}/swap?fromTokenAddress=${_fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${_amount}&fromAddress=${_userAddress}&slippage=1`);
    const swap = await response.json();
    const send = await web3.eth.sendTransaction(swap.tx);
        
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);
    job.set("txHash", send.transactionHash);
    job.set("status", "swapped");
    await job.save();
    return ["swapped", swap["toTokenAmount"]];
}

async function networkCheck(_networkId) {

    let network = await window.web3.eth.net.getId();
    if (network != _networkId && network == 1) {
        alert("Please Change Network in Metamask to Polygon and then press OK");
    }
    else if (network != _networkId && network == 137) {
        alert("Please Change Network in Metamask to Ethereum and then press OK");
    }
}

async function checkInclusion(txHash, rootChainAddress) {
    // For mainnet, use the matic mainnet RPC: <Sign up for a dedicated free RPC URL at https://rpc.maticvigil.com/ or other hosted node providers.>
    const child_provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet" // "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai" //Get a free RPC URL from https://rpc.maticvigil.com/ or other hosted node providers.
    );

    const child_web3 = new Web3(child_provider);

    // For mainnet, use Ethereum RPC
    const provider = new window.web3.providers.WebsocketProvider(
        "wss://mainnet.infura.io/ws/v3/134eb24f9b9d410baa2acac76d2a7be3" //"wss://goerli.infura.io/ws/v3/134eb24f9b9d410baa2acac76d2a7be3"
    );
    const web3 = new Web3(provider);

    let txDetails = await child_web3.eth.getTransactionReceipt(txHash);

    block = txDetails.blockNumber;
    console.log(block);
    return new Promise(async (resolve, reject) => {
        web3.eth.subscribe(
            "logs",
            {
                address: rootChainAddress,
            },
            async (error, result) => {
                if (error) {
                    reject(error);
                }
                console.log(result);
                if (result.data) {
                    let transaction = web3.eth.abi.decodeParameters(
                        ["uint256", "uint256", "bytes32"],
                        result.data
                    );

                    if (block <= transaction["1"]) {
                        resolve(result);
                        provider.disconnect();
                    }
                }
            }
        );
    });
}

async function depositCompletedMatic(txHash) {
    // For mainnet, use Ethereum RPC
    const provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet" //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli"
    );
    const web3 = new Web3(provider);

    // For mainnet, use the matic mainnet RPC: <Sign up for a dedicated free RPC URL at https://rpc.maticvigil.com/ or other hosted node providers.>
    const child_provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet" //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai" //Get a free RPC URL from https://rpc.maticvigil.com/ or other hosted node providers.
    );

    const child_web3 = new Web3(child_provider);

    const contractInstance = new child_web3.eth.Contract(
        [
            {
                constant: true,
                inputs: [],
                name: "lastStateId",
                outputs: [
                    {
                        internalType: "uint256",
                        name: "",
                        type: "uint256",
                    },
                ],
                payable: false,
                stateMutability: "view",
                type: "function",
            },
        ],
        "0x0000000000000000000000000000000000001001"
    );
    let tx = await window.web3.eth.getTransactionReceipt(txHash);
    let child_counter = await contractInstance.methods.lastStateId().call();
    let root_counter = web3.utils.hexToNumberString(tx.logs[2].topics[1]);
    return child_counter >= root_counter;
}

async function depositCompletedEth(txHash) {
    // For mainnet, use Ethereum RPC
    const provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet" //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli"
    );
    const web3 = new Web3(provider);

    // For mainnet, use the matic mainnet RPC: <Sign up for a dedicated free RPC URL at https://rpc.maticvigil.com/ or other hosted node providers.>
    const child_provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet" //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai" //Get a free RPC URL from https://rpc.maticvigil.com/ or other hosted node providers.
    );

    const child_web3 = new Web3(child_provider);

    const contractInstance = new child_web3.eth.Contract(
        [
            {
                constant: true,
                inputs: [],
                name: "lastStateId",
                outputs: [
                    {
                        internalType: "uint256",
                        name: "",
                        type: "uint256",
                    },
                ],
                payable: false,
                stateMutability: "view",
                type: "function",
            },
        ],
        "0x0000000000000000000000000000000000001001"
    );
    let tx = await window.web3.eth.getTransactionReceipt(txHash);
    console.log(txHash);
    let child_counter = await contractInstance.methods.lastStateId().call();
    let root_counter = web3.utils.hexToNumberString(tx.logs[1].topics[1]);
    return child_counter >= root_counter;
}

async function getTransactionStatus(_txHash) {
    let status = false;
    const params = { txHash: _txHash };
    while (!status) {
        status = await Moralis.Cloud.run("getNewTransactionStatus", params);
    }
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

async function getPolygonBalance() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const polygonbalance = await Moralis.Cloud.run("getPolygonBalance", params);
    return polygonbalance;
}

async function getMyEthTransactions() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const transactions = await Moralis.Cloud.run("getEthTransactions", params);
    let transactionsArray = [];
    let transaction;
    for (var i = 0; i < transactions.length; i++) {
        transaction = {
            "hash": transactions[i].attributes.hash,
            "from_address": transactions[i].attributes.from_address,
            "to_address": transactions[i].attributes.to_address,
            "value": transactions[i].attributes.value,
            "input": transactions[i].attributes.input.substring(0, 10),
            "confirmed": transactions[i].attributes.confirmed,
            "tokenamount": "0",
            "token_symbol": "",
        }
        if (transactions[i].attributes.input.substring(0, 10) == window.web3.eth.abi.encodeFunctionSignature("depositEtherFor(address)")) {
            transaction["input"] = "Deposit Ether For";
        }
        if (transactions[i].attributes.input.substring(0, 10) == window.web3.eth.abi.encodeFunctionSignature("exit(bytes)")) {
            transaction["input"] = "Exit";
        }
        if (transactions[i].attributes.input.substring(0, 10) == "0x8b9e4f93") {
            transaction["input"] = "Deposit ERC20 For User";
        }
        if (transactions[i].attributes.input.substring(0, 10) == "0x2e95b6c8") {
            transaction["input"] = "Swap";
        }
        if (transactions[i].attributes.to_address == /*"0x7850ec290a2e2f40b82ed962eaf30591bb5f5c96"*/ "0x401F6c983eA34274ec46f84D70b31C151321188b") {
            const params = { txHash: transactions[i].attributes.hash };
            const tokenTransactions = await Moralis.Cloud.run("getNewEthTokenTransfers", params);
            const params2 = { tokenAddress: tokenTransactions.attributes.token_address };
            const tokensymbol = await Moralis.Cloud.run("getEthTokenSymbol", params2);
            transaction["tokenamount"] = tokenTransactions.attributes.value;
            transaction["token_symbol"] = tokensymbol.attributes.symbol;
        }
        transactionsArray.push(transaction);
    }
    return JSON.stringify(transactionsArray);
}

async function getMyPolygonTransactions() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const transactions = await Moralis.Cloud.run("getPolygonTransactions", params);
    let transactionsArray = [];
    let transaction;
    for (var i = 0; i < transactions.length; i++) {
        transaction = {
            "hash": transactions[i].attributes.hash,
            "from_address": transactions[i].attributes.from_address,
            "to_address": transactions[i].attributes.to_address,
            "value": transactions[i].attributes.value,
            "input": transactions[i].attributes.input.substring(0, 10),
            "confirmed": transactions[i].attributes.confirmed,
            "tokenamount": "0",
            "token_symbol": "",
        }
        if (transactions[i].attributes.input.substring(0, 10) == window.web3.eth.abi.encodeFunctionSignature("withdraw(uint256)")) {
            transaction["input"] = "Withdraw";
        }
        //if(transactions[i].attributes.input.substring(0, 10) == window.web3.eth.abi.encodeFunctionSignature("exit(bytes)")) {            
        //    transaction["input"] = "Exit";
        //}
        if(transactions[i].attributes.input.substring(0, 10) == "0x7c025200") {            
            transaction["input"] = "Swap";
        }
        if (transactions[i].attributes.to_address == /*"0xa6fa4fb5f76172d178d61b04b0ecd319c5d1c0aa"*/ "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase()) {
            const params = { txHash: transactions[i].attributes.hash };
            const tokenTransactions = await Moralis.Cloud.run("getNewPolygonTokenTransfers", params);
            const params2 = { tokenAddress: tokenTransactions.attributes.token_address };
            const tokensymbol = await Moralis.Cloud.run("getPolygonTokenSymbol", params2);
            transaction["tokenamount"] = tokenTransactions.attributes.value;
            transaction["token_symbol"] = tokensymbol.attributes.symbol;
        }
        transactionsArray.push(transaction);
    }
    return JSON.stringify(transactionsArray);
}

async function storeJobData(_fromTokenAddress, _toTokenAddress, _amount, _fromChain, _toChain) {
    user = await Moralis.User.current();
    const _userAddress = user.attributes.ethAddress;
    const Jobs = Moralis.Object.extend("Jobs");
    const job = new Jobs();

    job.set("user", _userAddress);
    job.set("fromTokenAddress", _fromTokenAddress);
    job.set("toTokenAddress", _toTokenAddress);
    job.set("amount", _amount);
    job.set("fromChain", _fromChain);
    job.set("toChain", _toChain);
    job.set("txHash", "");
    job.set("status", "open");

    await job.save();

    return job.id;
}

async function getMyJobs() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const myJobs = await Moralis.Cloud.run("getMyJobs", params);
    return JSON.stringify(myJobs);
}

async function getJobById(_jobId) {
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);
    return JSON.stringify(job);
}

async function deleteJobById(_jobId) {
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);
    await job.destroy();
}