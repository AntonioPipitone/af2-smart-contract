const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const AntoTokenSale = artifacts.require("./AntoTokenSale.sol");
const TestToken = artifacts.require("./TestToken.sol");
const web3 = require('web3');

contract('AntoTokenSale', accounts => {

    beforeEach(async function () {
        this.tokenSale = await AntoTokenSale.deployed();
        this.token = await TestToken.deployed();
    });

    describe('TokenSale contract testing:', function () {

        const admin = accounts[0];
        const buyer = accounts[1];
        const tokensNumber = 10;
        const tokensAvailable = 750000;
        const balanceToCheck = tokensAvailable - tokensNumber;
        const tokenPrice = web3.utils.toWei('0.001', 'ether');
        const numberOfTokens = web3.utils.toWei(tokensNumber.toString(), 'ether');

        describe('test the TokenSale buying functions', function () {

            it('initializes contract with the correct values', async function () {

                const address = await this.tokenSale.address;
                assert.notEqual(address, 0x0, 'has contract address');

                const addressTokenContract = await this.tokenSale.tokenContract();
                assert.notEqual(addressTokenContract, 0x0, 'it has a token contract address');

                const price = await this.tokenSale.tokenPrice();
                assert.equal(price, tokenPrice, 'token price is correct');
            });

            it('test the buyTokens function', async function () {

                const receipt = await this.tokenSale.buyTokens(tokensNumber, {
                    from: buyer,
                    value: tokensNumber * tokenPrice
                })
                assert.equal(receipt.logs.length, 1, 'triggers one event')
                assert.equal(receipt.logs[0].event, 'Sell', 'should be Sell event')
                assert.equal(receipt.logs[0].args._buyer, buyer, 'logs the account that purchased the tokens')
                assert.equal(receipt.logs[0].args._amount.toString(), tokensNumber, 'logs the number of tokens purchased')
            });

            it('check the balance for buyer and contract', async function () {

                const amount = await this.tokenSale.tokensSold();
                assert.equal(amount.toString(), tokensNumber, 'increments the number of tokens sold');
                expect(await this.token.balanceOf(this.tokenSale.address)).to.be.bignumber.equal(web3.utils.toWei(balanceToCheck.toString(), 'ether'));
                expect(await this.token.balanceOf(buyer)).to.be.bignumber.equal(numberOfTokens.toString());
            });

            it('try to buy more tokens than available in the contract sale', async function () {

                try {
                    await this.tokenSale.buyTokens(tokensAvailable, {from: buyer})
                } catch (err) {
                    assert(err.message.includes('revert'), true, 'cannot purchase more tokens than availble in contract sale')
                }
            });
        });

        describe('test the TokenSale end functions', function () {

            it('endSale reverting if performed from buyer', async function () {

                try {
                    await this.tokenSale.endSale({from: buyer})
                } catch (err) {
                    assert(err.message.includes('revert'), true, 'just admin can end the token sale')
                }
            });

            it('perform endSale that returns all unsold token to admin', async function () {

                const result = await this.tokenSale.endSale({from: admin})
                assert.equal(result.receipt.status, true)
            });

            it('check the balance for admin and contract', async function () {

                expect(await this.token.balanceOf(admin)).to.be.bignumber.equal(web3.utils.toWei('999990', 'ether'));
                expect(await this.token.balanceOf(this.tokenSale.address)).to.be.bignumber.equal(web3.utils.toWei('0', 'ether'));
            });
        });
    });
});