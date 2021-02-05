const Oracle = artifacts.require("Oracle")

contract('Oracle', accounts => {
	it('Should accept propositions', async () => {
		let instance = await Oracle.deployed()
	    await instance.provide(10)
        let propositions = await instance.getProposedValues()
        console.log(propositions)
        assert.equal(propositions.valueOf().length, 1);
	})

//	it('Should perform calculation', async () => {
//	    let instance = await Oracle.deployed()
//	    await instance.setInterval(1)
//		for(let i=0; i<10; i++) {
//            Oracle.web3.from = accounts[i]
//		    await instance.provide(i)
//		}
//		let val = await instance.retrieve()
//		console.log(val.valueOf())
////		assert.equal(val.valueOf())
//	})

})
