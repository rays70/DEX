const Dex = artifacts.require("Dex")
const Link = artifacts.require("Link")
const truffleAssert = require('truffle-assertions'); 

contract ("Dex", accounts =>{

    it("When creating a SELL market order, the seller needs to have enough tokens for the trade", async () =>{
    
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]})

        await link.approve(dex.address, 5000)

        await link.transfer(accounts[0], 1000)
        await link.transfer(accounts[1], 1000)
        await link.transfer(accounts[2], 1000)
        await link.transfer(accounts[3], 1000)
        await link.transfer(accounts[4], 1000)

        await link.approve(dex.address, 1000, {from: accounts[0]})
        await link.approve(dex.address, 1000, {from: accounts[1]})
        await link.approve(dex.address, 1000, {from: accounts[2]})
        await link.approve(dex.address, 1000, {from: accounts[3]})
        await link.approve(dex.address, 1000, {from: accounts[4]})


        await dex.deposit(400, web3.utils.fromUtf8("LINK"), {from: accounts[0]})
        await dex.deposit(500, web3.utils.fromUtf8("LINK"), {from: accounts[1]})
        await dex.deposit(600, web3.utils.fromUtf8("LINK"), {from: accounts[2]})
        await dex.deposit(700, web3.utils.fromUtf8("LINK"), {from: accounts[3]})
        await dex.deposit(800, web3.utils.fromUtf8("LINK"), {from: accounts[4]})

        await dex.depositEth({value: 30000});

        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 25, 200, {from: accounts[1]})
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 15, 250, {from: accounts[2]})
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 20, 150, {from: accounts[3]})
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 20, 100, {from: accounts[4]})


        await truffleAssert.passes(dex.createMarketOrder(web3.utils.fromUtf8("LINK"), 0, 60))
               
    })
    it("When creating a BUY market order, the buyer needs to have enough ETH for the trade", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        let ethBalance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        
        console.log("Eth Balance of accounts[0] is " + ethBalance)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1)
        console.log("Orderbook length for sell is " + orderbook.length)
        console.log(orderbook)

        let linkBalance = await dex.balances(accounts[1], web3.utils.fromUtf8("LINK"));
        console.log("LINK balance of account[1] is " + linkBalance)

        linkBalance = await dex.balances(accounts[2], web3.utils.fromUtf8("LINK"));
        console.log("LINK balance of account[2] is " + linkBalance)

        await truffleAssert.passes(dex.createMarketOrder(web3.utils.fromUtf8("LINK"), 0, 50 ))    
    })
    it("Market Orders should be filled until the order book is empty or the market order is 100% filled", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 25, 50, {from: accounts[1]})
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 15, 60, {from: accounts[2]})

        await dex.createMarketOrder(web3.utils.fromUtf8("LINK"), 0, 40 )

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1)
        console.log("Orderbook length for sell is " + orderbook.length)
        console.log(orderbook)
        assert( orderbook.length == 0, "Sell Limit Order book should be empty")
              
    })
    it("The Eth and LINK balance of the buyer and seller should change correctly", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        let ethBalance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        let linkBalance = await dex.balances(accounts[1], web3.utils.fromUtf8("ETH"));

        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 20, 50, {from: accounts[1]})
        await dex.createMarketOrder(web3.utils.fromUtf8("LINK"), 0, 40 )

        let ethBalanceNew = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        let linkBalanceNew = await dex.balances(accounts[1], web3.utils.fromUtf8("ETH"));

        assert(ethBalance = ethBalanceNew + 1000, "Buyer's Eth Balance not decreased correctly")
        assert(linkBalanceNew = linkBalance -20, "Seller's Link balance not decreased correctly")
    })
   
   
})
