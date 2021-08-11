//goerli Testnet
//Moralis.initialize("x0ful1XMWL36Q4W8hD45fkTBo9t645QJWfpoNRo0")
//Moralis.serverURL = "https://cexjnpsqzkbg.moralis.io:2053/server";
//const Moralis = require('moralis');
//mainNet
Moralis.initialize("dOiVpAxnylme9VPx99olzmbyQzB4Jk2TgL0g1Y5A")
Moralis.serverURL = "https://kuuj059ugtmh.usemoralis.com:2053/server";

async function init() {
    window.web3 = await Moralis.Web3.enable();

    //window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0");
    //const allowance = await ERC20TokencontractInstance.methods.approve("0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0", "1").send({from: "0xC4e2c53664d929e1D7D0AE9fBC848690EF3f81C1"});
}

init()

async function loggedIn() {
    try {
        user = await Moralis.User.current();
        //let name = user.get("username");
        //let avatar = user.get("avatar");
        return user.attributes.username;
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

/*async function fetch1InchTokens(_chain) {
    //_chain = 1 => Ethereum
    //_chain = 56 => BSC
    //fetch all tokens on 1inch eth-mainnnet
    try {
        const response = await fetch(`https://api.1inch.exchange/v3.0/${_chain}/tokens`);
        const tokens = await response.json();
        return JSON.stringify(tokens["tokens"]);
    } catch (error) { console.log(error); }
}*/

/*async function getQuote(_fromToken, _toToken, _amount, _chain) {
    try {
        const response = await fetch(`https://api.1inch.exchange/v3.0/${_chain}/quote?fromTokenAddress=${_fromToken}&toTokenAddress=${_toToken}&amount=${_amount}`);
        const quote = await response.json();
        return JSON.stringify(quote);
    } catch (error) { console.log(error); }
}*/

async function bridgingEth(_jobId, _newFromToken) {
    try {
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

        const maticPosEthBack = new Matic.MaticPOSClient({
            network: "mainnet", //"testnet",
            version: "v1", //"mumbai",
            parentProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/mainnet", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/eth/goerli",
            maticProvider: window.web3,
        });

        if (job.attributes.fromChain == 0 && job.attributes.toChain == 2) {
            //Deposit Ether from Ether to Polygon
            let txHash = await maticPos.depositEtherForUser(_userAddress, job.attributes.amount, { from: _userAddress });
            job.set("txHash", txHash.transactionHash);
            job.set("status", "ethbridged");
            job.set("fromTokenAddress", _newFromToken);
            await job.save();
            return "ethbridged";
        }
        else if (job.attributes.fromChain == 2 && job.attributes.toChain == 0) {
            //Deposit Ether from Polygon to Ether
            let burnTxHash = await maticPosEthBack.burnERC20(job.attributes.fromTokenAddress, job.attributes.amount, { from: _userAddress });

            job.set("txHash", burnTxHash.transactionHash);
            job.set("status", "ethbridged");
            job.set("fromTokenAddress", _newFromToken);
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

async function bridgingMatic(_jobId, _newFromToken) {
    try {
        user = await Moralis.User.current();
        const _userAddress = user.attributes.ethAddress;

        const params = { id: _jobId };
        let job = await Moralis.Cloud.run("getJobsById", params);

        const maticPlasma = new Matic({
            network: "mainnet", //"testnet",
            version: "v1", //"mumbai",
            parentProvider: window.web3,
            maticProvider: "https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mainnet", //"https://speedy-nodes-nyc.moralis.io/cff6f789838e10c4008b1baa/polygon/mumbai", 
        });

        //Approve Polygon
        await maticPlasma.approveERC20TokensForDeposit(/*"0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae"*/ "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0", job.attributes.amount, { from: _userAddress });
        //Deposit ERC20
        let txHash = await maticPlasma.depositERC20ForUser(/*"0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae"*/ "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0", _userAddress, job.attributes.amount, { from: _userAddress });
        //Setting transactionHash for Job
        job.set("txHash", txHash.transactionHash);
        job.set("fromTokenAddress", _newFromToken);
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

async function _checkSwapAmount(_jobId, _chain, _fromTokenAddress, _toTokenAddress, _amount, _userAddress, _slippage) {
  if(_fromTokenAddress == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
    try {
          let chain = ["1", "56", "137"];
          //find job by id
          const params = { id: _jobId };
          let job = await Moralis.Cloud.run("getJobsById", params);

          //getting the balance of native currency
          let balanceResponse = await getBalancesByAddress(_fromTokenAddress, _chain);
          let balance = balanceResponse[1];
          //calculation Tx cost => gas * gasprice
          let txResponse = await fetch(`https://api.1inch.exchange/v3.0/${chain[_chain]}/swap?fromTokenAddress=${_fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${(parseInt(_amount) * 0.75).toString()}&fromAddress=${_userAddress}&slippage=${_slippage}`);
          let txData = await txResponse.json();
          let gas = txData.tx.gas;
          let gasPrice = txData.tx.gasPrice;

          if(parseInt(_amount) + (gas * gasPrice * 1.25) > parseInt(balance)) {
              let newAmount = parseInt(_amount) - (gas * gasPrice * 1.25);
              job.set("amount", newAmount);
          }
    } catch (error) { console.log(error); }
  }   
}


async function doSwap(_jobId, _step) {

    let chain = ["1", "56", "137"];
    user = await Moralis.User.current();
    const _userAddress = user.attributes.ethAddress;

    //find job by id
    const params = { id: _jobId };
    let job = await Moralis.Cloud.run("getJobsById", params);

    let _toTokenAddress;
    //decide if there is a swap to eth before bridging
    if (_step == 0) { _toTokenAddress = job.attributes.toTokenAddress; };
    if (_step == 1) { _toTokenAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"; };
    if (_step == 2) { _toTokenAddress = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619".toLowerCase(); };

    window.ERC20TokencontractInstance = new web3.eth.Contract(erc20ABI, job.attributes.fromTokenAddress);
    //Approve 1inch to spend token
    if (job.attributes.fromTokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
        const approve = await ERC20TokencontractInstance.methods.approve("0x11111112542d85b3ef69ae05771c2dccff4faa26", job.attributes.amount).send({ from: _userAddress });
    }
    //get TX Data for swap to sign and to do the swap            
    let response;
    if (_step == 0) { 
      await _checkSwapAmount(_jobId, job.attributes.toChain, job.attributes.fromTokenAddress, _toTokenAddress, job.attributes.amount, _userAddress);
      response = await fetch(`https://api.1inch.exchange/v3.0/${chain[job.attributes.toChain]}/swap?fromTokenAddress=${job.attributes.fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${job.attributes.amount}&fromAddress=${_userAddress}&slippage=${job.attributes.slippage}`); }
    if (_step == 1 || _step == 2) { 
      await _checkSwapAmount(_jobId, job.attributes.fromChain, job.attributes.fromTokenAddress, _toTokenAddress, job.attributes.amount, _userAddress, job.attributes.slippage);
      response = await fetch(`https://api.1inch.exchange/v3.0/${chain[job.attributes.fromChain]}/swap?fromTokenAddress=${job.attributes.fromTokenAddress}&toTokenAddress=${_toTokenAddress}&amount=${job.attributes.amount}&fromAddress=${_userAddress}&slippage=${job.attributes.slippage}`); }

    const swap = await response.json();
    const send = await web3.eth.sendTransaction(swap.tx);

    job.set("txHash", send.transactionHash);
    job.set("status", "swapped");
    job.set("amount", swap["toTokenAmount"]);
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

async function getMyBalances() {
    try {
        user = await Moralis.User.current();
        const params = { address: user.attributes.ethAddress };
        const response = await Moralis.Cloud.run("getMyBalances", params);
  
        //Variante Preise gebundelt mit einer Anfrage bei Coingecko anfragen, ist etwas schneller, ABER Coingecko verlangt irgendwann geld
        //Fetching token prices
        let priceResponse = await Promise.all([
          axios.get(`https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=ethereum&order=market_cap_desc&per_page=100&page=1&sparkline=false`),
          axios.get(`https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=matic-network&order=market_cap_desc&per_page=100&page=1&sparkline=false`),
          axios.get(`https://api.coingecko.com/api/v3/simple/token_price/ethereum?contract_addresses=${response[2]}&vs_currencies=usd`),
          axios.get(`https://api.coingecko.com/api/v3/simple/token_price/polygon-pos?contract_addresses=${response[3]}&vs_currencies=usd`),
          axios.get(`https://api.1inch.exchange/v3.0/1/tokens`),
          axios.get(`https://api.1inch.exchange/v3.0/137/tokens`),
        ]);

        //Setting Ether Price
        response[0][0]["price"] = priceResponse[0].data[0].current_price
  
        //Setting Matic price
        response[0][1]["price"] = priceResponse[1].data[0].current_price
  
        const ethTokenPrices = priceResponse[2].data;
        const polygonTokenPrices = priceResponse[3].data;
        const tokenBalances = response[1].map(function (value) {
          let imageUrl;
          if(priceResponse[4].data.tokens[value.tokenAddress]) imageUrl = priceResponse[4].data.tokens[value.tokenAddress]["logoURI"];
          else if(priceResponse[5].data.tokens[value.tokenAddress]) imageUrl = priceResponse[5].data.tokens[value.tokenAddress]["logoURI"];
          else imageUrl = "No Image";       
          //Variante Preise für jeden Token einzeln bei Moralis anfragen, dauert etwas länger
          //const apiKey = {
          //  "X-API-Key": "ldVQIU0NlXxbxYlA0vedMT2rroif0TjuoCr149Hv4PkWo5KYeFTCmcnEr4xLsaXy"
          //}; 
          //let price = await axios.get(`https://deep-index.moralis.io/api/token/ERC20/${value.tokenAddress}/price?chain=${value.chain}&chain_name=mainnet`, { headers: apiKey });
          //price.data.usdPrice
          return {
            name: value.name,
            symbol: value.symbol,
            balance: value.balance,
            decimals: value.decimals,
            tokenAddress: value.tokenAddress,
            image: imageUrl,
            chain: value.chain,
            price: ethTokenPrices[value.tokenAddress] ? ethTokenPrices[value.tokenAddress].usd : polygonTokenPrices[value.tokenAddress].usd,  
          };
        });
  
        const balances = [response[0][0], response[0][1], ...tokenBalances];
        const returnBalances = balances.map(function(value) {
          return JSON.stringify(value); 
        });        
        return returnBalances;
      } catch (error) {
        console.log(error);
      }
}

async function getMyEthTransactions() {
    try {
      user = await Moralis.User.current();
      mappedPoSTokensEth.push(
        "0xA0c68C638235ee32657e8f720a23ceC1bFc77C77".toLowerCase(),
        "0x401F6c983eA34274ec46f84D70b31C151321188b".toLowerCase(),
        "0x11111112542d85b3ef69ae05771c2dccff4faa26".toLowerCase()
      );
      const paramsTx = {
        address: user.attributes.ethAddress,
        tokens: mappedPoSTokensEth,
      };
      const responseTransactions = await Moralis.Cloud.run(
        "getEthTransactions2",
        paramsTx
      );
      let methode;
      for (var i = 0; i < responseTransactions.length; i++) {
        if (
          responseTransactions[i]["method"].substring(0, 10) ===
          window.web3.eth.abi.encodeFunctionSignature(
            "depositEtherFor(address)"
          )
        ) {
          methode = "Deposit Ether For";
        } else if (
          responseTransactions[i]["method"].substring(0, 10) ===
          window.web3.eth.abi.encodeFunctionSignature("exit(bytes)")
        ) {
          methode = "Exit";
        } else if (
          responseTransactions[i]["method"].substring(0, 10) === "0x8b9e4f93"
        ) {
          methode = "Deposit ERC20 For User";
        } else if (
          responseTransactions[i]["method"].substring(0, 10) === "0x2e95b6c8"
        ) {
          methode = "Swap";
        } else {
          methode = responseTransactions[i]["method"].substring(0, 10);
        }
        responseTransactions[i]["method"] = methode;
      }
      const returnTransactions = responseTransactions.map(function(value) {
        return JSON.stringify(value); 
      });  
      return returnTransactions;
    } catch (error) {
      console.log(error);
    }
  }

async function getMyPolygonTransactions() {
  try {
    user = await Moralis.User.current();
    mappedPoSTokensPolygon.push(
      "0x11111112542d85b3ef69ae05771c2dccff4faa26"
    );
    const paramsTx = {
      address: user.attributes.ethAddress,
      tokens: mappedPoSTokensPolygon,
    };
    const responseTransactions = await Moralis.Cloud.run(
      "getPolygonTransactions2",
      paramsTx
    );
    let methode;
    for (var i = 0; i < responseTransactions.length; i++) {
      if (
        responseTransactions[i]["method"].substring(0, 10) ===
        window.web3.eth.abi.encodeFunctionSignature("withdraw(uint256)")
      ) {
        methode = "Withdraw";
      } else if (
        responseTransactions[i]["method"].substring(0, 10) === "0x7c025200"
      ) {
        methode = "Swap";
      }
      responseTransactions[i]["method"] = methode;
    }
    const returnTransactions = responseTransactions.map(function(value) {
      return JSON.stringify(value); 
    });  
    return returnTransactions;
  } catch (error) {
    console.log(error);
  }
}

async function storeJobData(_fromTokenAddress, _toTokenAddress, _amount, _fromChain, _toChain, _slippage) {
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
    job.set("slippage", _slippage);

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

async function getBalancesByAddress(_tokenAddress, _chain) {
    try {
        let amount;
        let balance;
        user = await Moralis.User.current();
        const params = { tokenAddress: _tokenAddress, address: user.attributes.ethAddress };
    
        if(_chain == 0 && _tokenAddress == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
            let token = await Moralis.Cloud.run("getEthBalance", params);
            balance = parseInt(token) / Math.pow(10, 18);
            amount = token;
        }
        
        else if(_chain == 0 && _tokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
            let token = await Moralis.Cloud.run("getEthTokenBalance", params);
            balance = parseInt(token.attributes.balance) / Math.pow(10, parseInt(token.attributes.decimals));
            amount = token.attributes.balance;
        }
    
        else if(_chain == 2 && _tokenAddress == "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
            let token = await Moralis.Cloud.run("getPolygonBalance", params);
            balance = parseInt(token) / Math.pow(10, 18);
            amount = token;
        }
        
        else if(_chain == 2 && _tokenAddress != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
            let token = await Moralis.Cloud.run("getPolygonTokenBalance", params);
            balance = parseInt(token.attributes.balance) / Math.pow(10, parseInt(token.attributes.decimals));
            amount = token.attributes.balance;
        }
        return ([balance.toString(), amount]);

    } catch (error) { console.log(error); }
}