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

async function bridgingEth(_amount, _fromChain, _toChain) {
    try {
        let chain = [5, 5, 80001];
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;

        const maticPos = new Matic.MaticPOSClient({
            network: "testnet", //"mainnet",
            version: "mumbai", //"v1",
            parentProvider: window.web3,
            maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet",
        });

        const maticPosEthBack = new Matic.MaticPOSClient({
            network: "testnet", //"mainnet",
            version: "mumbai", //"v1",
            parentProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet",
            maticProvider: window.web3,
        });

        if (_fromChain == 0 && _toChain == 2) {
            //Deposit Ether from Ether to Polygon
            let txHash = await maticPos.depositEtherForUser(_userAddress, _amount, { from: _userAddress });
            //let deposit = false
            //while (!deposit) {
            //    deposit = await depositCompletedEth(txHash.transactionHash);
            //}
            return txHash.transactionHash;
        }
        else if (_fromChain == 2 && _toChain == 0) {
            //Deposit Ether from Polygon to Ether
            let burnTxHash = await maticPosEthBack.burnERC20("0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa", _amount, { from: _userAddress });
            //await checkInclusion(burnTxHash.transactionHash, "0x2890ba17efe978480615e330ecb65333b880928e");
            //await networkCheck(chain[_toChain]);
            //await maticPos.exitERC20(burnTxHash.transactionHash, { from: _userAddress });
            return burnTxHash.transactionHash;
        }
    } catch (error) { console.log(error); }
}

async function erc20Exit(txHash) {
    user = await Moralis.User.current();
    const _userAddress = user.attributes.ethAddress;
    const maticPos = new Matic.MaticPOSClient({
        network: "testnet", //"mainnet",
        version: "mumbai", //"v1",
        parentProvider: window.web3,
        maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet",
    });
    let exit = await maticPos.exitERC20(txHash, { from: _userAddress });
    return exit.transactionHash;
}

async function bridgingMatic(_amount) {
    try {
        let chain = [5, 5, 80001];
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;

        const maticPlasma = new Matic({
            network: "testnet", //"mainnet"
            version: "mumbai", //"v1"
            parentProvider: window.web3,
            maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet", 
        });


        const maticPlasmaEthBack = new Matic({
            network: "testnet", //"mainnet",
            version: "mumbai", //"v1",
            parentProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet",
            maticProvider: window.web3,
        });

        //Approve Polygon
        await maticPlasma.approveERC20TokensForDeposit("0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae", _amount, { from: _userAddress });
        //Deposit ERC20
        let txHash = await maticPlasma.depositERC20ForUser("0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae", _userAddress, _amount, { from: _userAddress });
        //let deposit = false

        //while (!deposit) {
        //    deposit = await depositCompletedMatic(txHash.transactionHash);
        //}

        return txHash.transactionHash;

    } catch (error) { console.log(error); }
}

async function checkForInclusion(txHash) {
    let check = await checkInclusion(txHash, "0x2890ba17efe978480615e330ecb65333b880928e");
    return check;
}

async function checkEthCompleted(txHash) {
    let deposit = false
    while (!deposit) {
        deposit = await depositCompletedEth(txHash);
    }
    return deposit;
}

async function checkMaticCompleted(txHash) {
    let deposit;

    while (!deposit) {
        deposit = await depositCompletedMatic(txHash);
    }

    return deposit;
}

async function doSwap(_fromTokenAddress, _toTokenAddress, _amount, _fromChain) {
    let chain = ["1", "56", "137"];

    if (await window.web3.eth.net.getId() != chain[_fromChain]) {
        alert("Please Change Network on Metamask to the right Network and than press OK");
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
    const response = await fetch(`https://api.1inch.exchange/v3.0/${chain[_fromChain]}/swap?fromTokenAddress=${_fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${_amount}&fromAddress=${_userAddress}&slippage=1`);
    const swap = await response.json();
    const send = await web3.eth.sendTransaction(swap.tx);
    return send;
}

async function networkCheck(_networkId) {
    let network = await window.web3.eth.net.getId();
    if (network != _networkId) {
        alert("Please Change Network in Metamask and then press OK");
    }
}

async function swap(_fromTokenAddress, _toTokenAddress, _amount, _fromChain, _toChain) {
    let chain = [5, 5, 80001];

    if (_fromChain == _toChain) {
        await networkCheck(chain[_fromChain]);
        //Direct swap with 1inch
        //await _doSwap(_fromTokenAddress, _toTokenAddress, _amount, _fromChain);
        console.log("Do direct swap");
    }

    else {
        if (_fromChain == 0 && _toChain == 2) {
            //Check if the FromToken is ETH or Matic, beacause these will be bridged directly
            if (_fromTokenAddress == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
                await networkCheck(chain[_fromChain]);
                let bridging = await bridgingEth(_amount, _fromChain, _toChain);
                let _newFromTokenAddress = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
                await networkCheck(chain[_toChain]);
                //await _doSwap(_newFromTokenAddress, _toTokenAddress, _amount, _toChain);
                console.log("Do swap");
                console.log(bridging);
                return bridging;
            }
            else if (_fromTokenAddress == "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0".toLowerCase()) {
                await networkCheck(chain[_fromChain]);
                let bridging = await bridgingMatic(_amount);
                let _newFromTokenAddress = "0x0000000000000000000000000000000000001010";
                await networkCheck(chain[_toChain]);
                //await _doSwap(_newFromTokenAddress, _toTokenAddress, _amount, _toChain);
                console.log("Do swap");
                return bridging;
            }
            //all other FromTokens will first be swapped into Eth on Eth and then bridged to Polygon and again swapped into the final Token on Polygon
            else {
                await networkCheck(chain[_fromChain]);
                await doSwap(_fromTokenAddress, "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", _amount, _fromChain);
                //getting the swapped amount in eth
                let _ethBridgingAmount = "";
                await bridgingEth(_ethBridgingAmount, _fromChain, _toChain);
                let _newFromTokenAddress = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
                await networkCheck(chain[_toChain]);
                await doSwap(_newFromTokenAddress, _toTokenAddress, _ethBridgingAmount, _toChain);
            }
        }
        else if (_fromChain == 2 && _toChain == 0) {
            //Check if FromToken is WETH this will be bridged directly
            if (_fromTokenAddress == "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase()) {
                await networkCheck(chain[_fromChain]);
                let bridging = await bridgingEth(_amount, _fromChain, _toChain);
                let _newFromTokenAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
                await networkCheck(chain[_toChain]);
                //await _doSwap(_newFromTokenAddress, _toTokenAddress, _amount, _toChain);
                console.log("Do swap");
                return bridging;
            }
            else {
                await networkCheck(chain[_fromChain]);
                await doSwap(_fromTokenAddress, "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase(), _amount, _fromChain);
                //getting the swapped amount in eth
                let _ethBridgingAmount = "";
                await bridgingEth(_ethBridgingAmount, _fromChain, _toChain);
                let _newFromTokenAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
                await networkCheck(chain[_toChain]);
                await doSwap(_newFromTokenAddress, _toTokenAddress, _ethBridgingAmount, _toChain);
            }
        }
    }
}

async function checkInclusion(txHash, rootChainAddress) {
    // For mainnet, use the matic mainnet RPC: <Sign up for a dedicated free RPC URL at https://rpc.maticvigil.com/ or other hosted node providers.>
    const child_provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai" //Get a free RPC URL from https://rpc.maticvigil.com/ or other hosted node providers.
    );

    const child_web3 = new Web3(child_provider);

    // For mainnet, use Ethereum RPC
    const provider = new window.web3.providers.WebsocketProvider(
        "wss://goerli.infura.io/ws/v3/134eb24f9b9d410baa2acac76d2a7be3"
    );
    const web3 = new Web3(provider);

    let txDetails = await child_web3.eth.getTransactionReceipt(txHash);

    block = txDetails.blockNumber;
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
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli"
    );
    const web3 = new Web3(provider);

    // For mainnet, use the matic mainnet RPC: <Sign up for a dedicated free RPC URL at https://rpc.maticvigil.com/ or other hosted node providers.>
    const child_provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai" //Get a free RPC URL from https://rpc.maticvigil.com/ or other hosted node providers.
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
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli"
    );
    const web3 = new Web3(provider);

    // For mainnet, use the matic mainnet RPC: <Sign up for a dedicated free RPC URL at https://rpc.maticvigil.com/ or other hosted node providers.>
    const child_provider = new window.web3.providers.HttpProvider(
        "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai" //Get a free RPC URL from https://rpc.maticvigil.com/ or other hosted node providers.
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
    let root_counter = web3.utils.hexToNumberString(tx.logs[1].topics[1]);
    return child_counter >= root_counter;
}


async function getTransactionStatus(_txHash) {
    console.log(_txHash);
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

async function getMyEthTransactions() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const transactions = await Moralis.Cloud.run("getEthTransactions", params);
    let transactionsArray = [];
    let transaction;
    //const testABI = [{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"userAddress","type":"address"},{"indexed":false,"internalType":"address payable","name":"relayerAddress","type":"address"},{"indexed":false,"internalType":"bytes","name":"functionSignature","type":"bytes"}],"name":"MetaTransactionExecuted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"tokenType","type":"bytes32"},{"indexed":true,"internalType":"address","name":"predicateAddress","type":"address"}],"name":"PredicateRegistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"previousAdminRole","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"newAdminRole","type":"bytes32"}],"name":"RoleAdminChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":true,"internalType":"address","name":"sender","type":"address"}],"name":"RoleGranted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":true,"internalType":"address","name":"sender","type":"address"}],"name":"RoleRevoked","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"rootToken","type":"address"},{"indexed":true,"internalType":"address","name":"childToken","type":"address"},{"indexed":true,"internalType":"bytes32","name":"tokenType","type":"bytes32"}],"name":"TokenMapped","type":"event"},{"inputs":[],"name":"DEFAULT_ADMIN_ROLE","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"DEPOSIT","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ERC712_VERSION","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ETHER_ADDRESS","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAPPER_ROLE","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAP_TOKEN","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"checkpointManagerAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"childChainManagerAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"childToRootToken","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"address","name":"childToken","type":"address"}],"name":"cleanMapToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"depositEtherFor","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"bytes","name":"depositData","type":"bytes"}],"name":"depositFor","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"userAddress","type":"address"},{"internalType":"bytes","name":"functionSignature","type":"bytes"},{"internalType":"bytes32","name":"sigR","type":"bytes32"},{"internalType":"bytes32","name":"sigS","type":"bytes32"},{"internalType":"uint8","name":"sigV","type":"uint8"}],"name":"executeMetaTransaction","outputs":[{"internalType":"bytes","name":"","type":"bytes"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"bytes","name":"inputData","type":"bytes"}],"name":"exit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getChainId","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"getDomainSeperator","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getNonce","outputs":[{"internalType":"uint256","name":"nonce","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"}],"name":"getRoleAdmin","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"uint256","name":"index","type":"uint256"}],"name":"getRoleMember","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"}],"name":"getRoleMemberCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"grantRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"hasRole","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_owner","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"initializeEIP712","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"address","name":"childToken","type":"address"},{"internalType":"bytes32","name":"tokenType","type":"bytes32"}],"name":"mapToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"processedExits","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"tokenType","type":"bytes32"},{"internalType":"address","name":"predicateAddress","type":"address"}],"name":"registerPredicate","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"address","name":"childToken","type":"address"},{"internalType":"bytes32","name":"tokenType","type":"bytes32"}],"name":"remapToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"renounceRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"revokeRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"rootToChildToken","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"newCheckpointManager","type":"address"}],"name":"setCheckpointManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newChildChainManager","type":"address"}],"name":"setChildChainManagerAddress","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newStateSender","type":"address"}],"name":"setStateSender","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"setupContractId","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"stateSenderAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"tokenToType","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"typeToPredicate","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"stateMutability":"payable","type":"receive"}];
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
        if (transactions[i].attributes.to_address == "0x7850ec290a2e2f40b82ed962eaf30591bb5f5c96") {
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
    //const testABI = [{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"userAddress","type":"address"},{"indexed":false,"internalType":"address payable","name":"relayerAddress","type":"address"},{"indexed":false,"internalType":"bytes","name":"functionSignature","type":"bytes"}],"name":"MetaTransactionExecuted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"tokenType","type":"bytes32"},{"indexed":true,"internalType":"address","name":"predicateAddress","type":"address"}],"name":"PredicateRegistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"previousAdminRole","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"newAdminRole","type":"bytes32"}],"name":"RoleAdminChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":true,"internalType":"address","name":"sender","type":"address"}],"name":"RoleGranted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"role","type":"bytes32"},{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":true,"internalType":"address","name":"sender","type":"address"}],"name":"RoleRevoked","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"rootToken","type":"address"},{"indexed":true,"internalType":"address","name":"childToken","type":"address"},{"indexed":true,"internalType":"bytes32","name":"tokenType","type":"bytes32"}],"name":"TokenMapped","type":"event"},{"inputs":[],"name":"DEFAULT_ADMIN_ROLE","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"DEPOSIT","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ERC712_VERSION","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ETHER_ADDRESS","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAPPER_ROLE","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAP_TOKEN","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"checkpointManagerAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"childChainManagerAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"childToRootToken","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"address","name":"childToken","type":"address"}],"name":"cleanMapToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"depositEtherFor","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"bytes","name":"depositData","type":"bytes"}],"name":"depositFor","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"userAddress","type":"address"},{"internalType":"bytes","name":"functionSignature","type":"bytes"},{"internalType":"bytes32","name":"sigR","type":"bytes32"},{"internalType":"bytes32","name":"sigS","type":"bytes32"},{"internalType":"uint8","name":"sigV","type":"uint8"}],"name":"executeMetaTransaction","outputs":[{"internalType":"bytes","name":"","type":"bytes"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"bytes","name":"inputData","type":"bytes"}],"name":"exit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getChainId","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"getDomainSeperator","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getNonce","outputs":[{"internalType":"uint256","name":"nonce","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"}],"name":"getRoleAdmin","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"uint256","name":"index","type":"uint256"}],"name":"getRoleMember","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"}],"name":"getRoleMemberCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"grantRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"hasRole","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_owner","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"initializeEIP712","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"address","name":"childToken","type":"address"},{"internalType":"bytes32","name":"tokenType","type":"bytes32"}],"name":"mapToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"processedExits","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"tokenType","type":"bytes32"},{"internalType":"address","name":"predicateAddress","type":"address"}],"name":"registerPredicate","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"rootToken","type":"address"},{"internalType":"address","name":"childToken","type":"address"},{"internalType":"bytes32","name":"tokenType","type":"bytes32"}],"name":"remapToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"renounceRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"role","type":"bytes32"},{"internalType":"address","name":"account","type":"address"}],"name":"revokeRole","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"rootToChildToken","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"newCheckpointManager","type":"address"}],"name":"setCheckpointManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newChildChainManager","type":"address"}],"name":"setChildChainManagerAddress","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newStateSender","type":"address"}],"name":"setStateSender","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"setupContractId","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"stateSenderAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"tokenToType","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"typeToPredicate","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"stateMutability":"payable","type":"receive"}];
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
        //if(transactions[i].attributes.input.substring(0, 10) == "0x8b9e4f93") {            
        //    transaction["input"] = "Deposit ERC20 For User";
        //}
        if (transactions[i].attributes.to_address == "0xa6fa4fb5f76172d178d61b04b0ecd319c5d1c0aa") {
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

async function getMyDeposits() {
    user = await Moralis.User.current();
    const params = { address: user.attributes.ethAddress };
    const deposits = await Moralis.Cloud.run("getNewDeposits", params);
    return JSON.stringify(deposits);
}