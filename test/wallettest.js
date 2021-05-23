const Dex = artifacts.require("Dex")
const Link = artifacts.require("Link")
var truffleAssert = require("truffle-assertions");

contract ("Dex", accounts =>{

    it("should be possible only for owner to add token", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await truffleAssert.passes(
            dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]})
        )
        await truffleAssert.reverts(
            dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[1]})
        )

    })
    it("should handle deposits correctly", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await link.approve(dex.address, 500)
        await dex.deposit(100, web3.utils.fromUtf8("LINK"))
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"));
        assert.equal( balance.toNumber(),100)

    })
    it("should handle faulty withdrawals correctly", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await truffleAssert.reverts(dex.withdraw(500, web3.utils.fromUtf8("LINK")))
    })
    it("should handle correct withdrawals correctly", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await truffleAssert.passes(dex.withdraw(100, web3.utils.fromUtf8("LINK")))
    })
   
    it("should have enough balance to place the order", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await link.approve(dex.address, 500)
        await dex.deposit(100, web3.utils.fromUtf8("LINK"))
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"));
        await truffleAssert.passes(dex.withdraw(100, web3.utils.fromUtf8("LINK")))
    })
    it("should deposit correct amount of Eth", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        dex.depositEth({value: 1000});
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        assert.equal(balance.toNumber(), 1000);
        
    })
    it("should withdraw correct amount of Eth", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        dex.withdrawEth(500);
        let balancenew = await dex.balances(accounts[0], web3.utils.fromUtf8("ETH"));
        assert.equal(balancenew.toNumber(), (balance.toNumber() - 500));
        
    })
    it("should not allow over deposition of Eth", async () =>{
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        
    })

})
