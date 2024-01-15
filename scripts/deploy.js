const hre = require("hardhat");

async function main() {
    // We get the contract to deploy
    const LottaLottery = await hre.ethers.getContractFactory("LottaLottery");
    const lottaLottery = await LottaLottery.deploy(100);

    await lottaLottery.deployed();

    console.log("LottaLottery deployed to:", lottaLottery.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });