const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("LottaLottery", function () {
  let LottaLottery, lottaLottery, owner, addr1, addr2;

  beforeEach(async function () {
    LottaLottery = await ethers.getContractFactory("LottaLottery");
    [owner, addr1, addr2, _] = await ethers.getSigners();
    lottaLottery = await LottaLottery.deploy(100);
    
  });

  describe("buy_ticket", function () {

    it("Should not allow to buy tickets with insufficient funds", async function () {
      await expect(lottaLottery.connect(addr1).buy_ticket({ value: ethers.parseEther("0") })).to.be.revertedWith("Amount is less than ticket price");
    });

    

    it("Should not allow to buy tickets after the r ound has ended, it should buy ticket for the next round", async function () {
      // Assuming a round lasts 100 blocks
      for(let i = 0; i < 101; i++) {
        await ethers.provider.send("evm_mine");
      }
      await lottaLottery.connect(addr1).buy_ticket({ value: ethers.parseEther("1") });
      expect(await lottaLottery.get_current_round()).to.equal(2);
    }
    );

  });

  describe("withdraw", function () {
    it("Should transfer the balance of the sender to the sender's address", async function () {
      await lottaLottery.connect(addr1).buy_ticket({ value: ethers.parseEther("1") });
      await lottaLottery.connect(addr1).withdraw();
      expect(await ethers.provider.getBalance(addr1.address)).to.be.above(ethers.parseEther("99"));
    });

    // it("Should not allow to withdraw if the sender has no balance", async function () {
    //   await expect(lottaLottery.connect(addr1).withdraw()).to.be.revertedWith("No funds to withdraw");
    // });
  });

  describe('draw_winner', function () {
    it('Should revert if the round has not ended', async function () {
      await expect(lottaLottery.draw_winner(1)).to.be.revertedWith('Round not ended');
    });


    it('Should pick a winner and transfer the balance to the winner', async function () {
      // Buy a ticket for addr1
      await lottaLottery.connect(addr1).buy_ticket({ value: ethers.parseEther('1') });
      // Assuming a round lasts 100 blocks
      for(let i = 0; i < 111; i++) {
        await ethers.provider.send("evm_mine");
      }
      // Assuming that the round has ended
      await lottaLottery.draw_winner(1);

      // Check if the balance of the winner has increased on contract balances using get_balance() function
      // Check if the balance of the winner has increased on contract balances using get_balance() function
  const balance = await lottaLottery.connect(addr1).get_balance();
  expect(balance).to.be.gt(0);



      

    });
  });
});