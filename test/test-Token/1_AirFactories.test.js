const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const TestToken = artifacts.require("./TestToken.sol");
const web3 = require('web3');

async function  assertRevert (promise){
    try {
        await promise;
        assert.fail('Expected revert not received');
    } catch (error) {
        const revertFound = error.message.search('revert') >= 0;
        assert(revertFound, `Expected "revert", got ${error} instead`);
    }
};


contract('TestToken', accounts => {

    beforeEach(async function () {
        this.token = await TestToken.deployed();
    });

    describe('token attributes', function () {

        it('has the correct name', async function () {
            expect(await this.token.name()).to.equal('AirFactories');
        });

        it('has the correct symbol', async function () {
            expect(await this.token.symbol()).to.equal('AF2');
        });

        it('has the correct decimal', async function () {
            expect(await this.token.decimals()).to.be.bignumber.equal('18');
        });

        it("total supply should be 100 000 000 000 tokens", async function () {
            expect(await this.token.totalSupply()).to.be.bignumber.equal(web3.utils.toWei('1000000', 'ether'));
        });

        it("deployer should have the total initial supply", async function () {
            expect(await this.token.balanceOf(accounts[0])).to.be.bignumber.equal(web3.utils.toWei('250000', 'ether'));
        });

        describe("allowance", function () {

            it('allowance works as expected', async function () {
                const success = await this.token.approve.call(accounts[0], accounts[1], 100)
                assert.equal(success, true, 'it returns true')
                const receipt = await this.token.approve(accounts[0], accounts[1], 100)

                assert.equal(receipt.logs.length, 1, 'triggers one event')
                assert.equal(receipt.logs[0].event, 'Approval', 'should be Approval event')
                assert.equal(receipt.logs[0].args['owner'], accounts[0], 'logs the account the tokens are transferred from')
                assert.equal(receipt.logs[0].args['spender'], accounts[1], 'logs the account the tokens are transferred to')
                assert.equal(receipt.logs[0].args.value.toNumber(), 100, 'logs the amount transferred')

                const allowance = await this.token.allowance(accounts[0], accounts[1])
                assert.equal(allowance.toNumber(), 100, 'stores the allowance for delegated transfer');

            });
        });

        describe('transfer', function () {
                var to = accounts[2];

                describe('when the sender does not have enough balance', function () {

                    it('reverts', async function () {
                        await assertRevert(this.token.transfer(to, 100, {from: accounts[1]}));
                    });
                });

                describe('when the sender has enough balance', function () {
                    const amount = 100;

                    it('transfers the requested amount', async function () {
                        await this.token.transfer(accounts[1], amount, {from: accounts[0]});
                        await this.token.transfer(to, amount, {from: accounts[1]});

                        const senderBalance = await this.token.balanceOf(accounts[1]);
                        assert.equal(senderBalance.toString(), 0);

                        const recipientBalance = await this.token.balanceOf(to);
                        assert.equal(recipientBalance.toString(), amount.toString());
                    });

                    it('emits a transfer event', async function () {
                        const {logs} = await this.token.transfer(accounts[1], amount, {from: accounts[0]});

                        assert.equal(logs.length, 1);
                        assert.equal(logs[0].event, 'Transfer');
                        assert.equal(logs[0].args.from, accounts[0]);
                        assert.equal(logs[0].args.to, accounts[1]);
                        assert.equal(logs[0].args.value, amount.toString());
                    });

                    it('emits a transfer event 2 ', async function () {
                        const {logs} = await this.token.transfer(to, amount, {from: accounts[1]});

                        assert.equal(logs.length, 1);
                        assert.equal(logs[0].event, 'Transfer');
                        assert.equal(logs[0].args.from, accounts[1]);
                        assert.equal(logs[0].args.to, to);
                        assert.equal(logs[0].args.value, amount.toString());
                    });
                });
        });

        describe('transfer from', function () {
            const spendingAccount = accounts[4];
            const fromAccount = accounts[5];
            const toAccount = accounts[3];
            const amount = 50;

                describe('when the spender has enough approved balance', function () {
                    beforeEach(async function () {
                        await this.token.transfer(fromAccount, 100, {from: accounts[0]});
                        await this.token.approve(fromAccount, spendingAccount, 100);
                    });

                        it('transfers the requested amount', async function () {
                            await this.token.transferFrom(fromAccount, toAccount, amount, {from: spendingAccount});

                            const senderBalance = await this.token.balanceOf(fromAccount);
                            assert.equal(senderBalance.toString(), 50);

                            const recipientBalance = await this.token.balanceOf(toAccount);
                            assert.equal(recipientBalance.toString(), amount.toString());
                        });

                        it('emits a transfer event', async function () {
                            const {logs} = await this.token.transferFrom(fromAccount, toAccount, amount, {from: spendingAccount});

                            assert.equal(logs.length, 1);
                            assert.equal(logs[0].event, 'Transfer');
                            assert.equal(logs[0].args.from, fromAccount);
                            assert.equal(logs[0].args.to, toAccount);
                            assert.equal(logs[0].args.value, amount.toString());
                        });
                    });
                });
            });
        });

