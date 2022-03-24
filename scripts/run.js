const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
        ['Darth Vader', 'Hulk', 'Goku'],
        [
            'https://upload.wikimedia.org/wikipedia/en/0/0b/Darth_Vader_in_The_Empire_Strikes_Back.jpg',
            'https://upload.wikimedia.org/wikipedia/en/a/aa/Hulk_%28circa_2019%29.png',
            'https://upload.wikimedia.org/wikipedia/en/thumb/3/33/Three_Super_Saiyan_Stages_of_Son_Goku.PNG/175px-Three_Super_Saiyan_Stages_of_Son_Goku.PNG'
        ],

        [100, 250, 400],
        [50, 25, 40]
    );
    await gameContract.deployed();
    console.log('Contract deployed to: ', gameContract.address);

    let txn;
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log('Token URI:', returnedTokenUri)
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();