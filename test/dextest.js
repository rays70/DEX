const Dex = artifacts.require("Dex")
const Link = artifacts.require("Link")
const truffleAssert = require('truffle-assertions'); 

contract ("Dex", accounts =>{

     it("should revert a limit buy order if ETH balance is not enough", async () =>{
         let dex = await Dex.deployed()
         let link = await Link.deployed()
        
         dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]})
         await link.approve(dex.address, 5000)
         
         await truffleAssert.reverts(dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 0, 2, 200))
     })
     it("should pass a limit buy order if ETH balance is enough ", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await dex.depositEth({value: 3000});
        await truffleAssert.passes(dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 0, 2, 100))
    })
    it("should fail a limit sell order if token balance balance is not enough", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await truffleAssert.reverts(dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 2, 100))
    })
    it("should pass a limit sell order if token balance balance is enough", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await dex.deposit(1000, web3.utils.fromUtf8("LINK"))
        await truffleAssert.passes(dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 2, 200))
    })
    it("The BUY order book should be ordered on price from highest to lowest starting at index 0", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 0, 1, 200)
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 0, 1, 300)
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 0, 1, 100)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0)
        
        for (i = 0; i < (orderbook.length -2); i++){

            assert(orderbook[i].price > orderbook[i+1].price, "Limit Buy Order not sorted correctly" )

        }
            
        
    })
    it("The SELL order book should be ordered on price from lowest to highest starting at index 0", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 1, 200)
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 1, 300)
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 1, 100)
        await dex.createLimitOrder(web3.utils.fromUtf8("LINK"), 1, 1, 400)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1)
        
        for (i = 0; i < (orderbook.length -2); i++){

            assert(orderbook[i].price < orderbook[i+1].price, "Limit Sell Order not sorted correctly" )

        }
        
    })
       

 })
