const Dex = artifacts.require("Dex")
const Link = artifacts.require("Link")
var truffleAssert = require("truffle-assertions");

contract ("Dex", accounts =>{

	it("there should be eth balance available to raise the buy limit order", async () =>{
        let dex = await Dex.deployed();
        let link = await Link.deployed();
		let amount = 100;
		let price = 2;
		
		await dex.depositEth({value: 1000});
		// await dex.createLimitOrder(accounts[0], 1, "LINK", 100, 2);
		
		let ethbalance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        
		assert.isAbove(ethbalance.toNumber(), amount*price , "You don't have enough Eth balance to raise this buy order" );
		
	})
	
		

}
