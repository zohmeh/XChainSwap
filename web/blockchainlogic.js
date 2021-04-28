Moralis.initialize("7f8EaHQAku0a5aDkxXaVbgVIfskAP3QqddLmpHIL")
Moralis.serverURL = "https://x3f87iwahifo.moralis.io:2053/server";


async function init() {
    window.web3 = await Moralis.Web3.enable();
    window.NFTAuctioncontractInstance = new web3.eth.Contract(marketplaceAbi, addresses["marketplace"]);
    window.NFTTokencontractInstance = new web3.eth.Contract(thecollectorAbi, addresses["thecollector"]);
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
  fetch('https://apiv4.paraswap.io/v2/tokens/3')
    .then(response => response.json())
    .then(data => console.log(data.tokens));
}