// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../../contracts/ERC20/AssemblyERC20.sol";

contract AssemblyERC20Test is Test {
    AssemblyERC20 token;
    address deployer;
    address A;
    address B;

    function setUp() external {
        deployer = makeAddr("deployer");

        A = makeAddr("A");

        B = makeAddr("B");

        vm.prank(deployer);
        token = new AssemblyERC20("Assembly ERC20 Token", "AET");
        vm.prank(deployer);
        token.mint(deployer, type(uint256).max);
        vm.label(address(token), "AssemblyToken");
    }

    function testName() external {
        string memory name = token.name();
        assertEq(name, "Assembly ERC20 Token");
    }

    function testSymbol() external {
        string memory name = token.symbol();
        assertEq(name, "AET");
    }

    function testDecimals() external {
        uint8 decimals = token.decimals();
        assertEq(decimals, 18);
    }

    function testTotalSupply() external {
        uint256 totalSupply = token.totalSupply();
        assertEq(totalSupply, type(uint256).max);
    }

    function testBalanceOf() external {
        uint256 deployerBal = token.balanceOf(deployer);
        assertEq(deployerBal, type(uint256).max);
    }

    function testApprove() external {
        vm.prank(deployer);
        bool success = token.approve(address(0xdead), 69 ether);
        assertTrue(success);

        uint256 allowance = token.allowance(deployer, address(0xdead));
        assertEq(allowance, 69 ether);
    }

    function testTransfer() external {
        vm.startPrank(deployer);

        bool resA = token.transfer(A, 1 wei);
        assertTrue(resA);

        vm.expectRevert();
        bool resB = token.transfer(B, type(uint256).max);
        assertFalse(resB);

        vm.stopPrank();
    }

    function testTransferFromSuccess() external {
        // deployer approves A to spend 10 of his tokens
        vm.prank(deployer);
        token.approve(A, 10 ether);

        assertEq(token.allowance(deployer, A), 10 ether);
        assertEq(token.balanceOf(A), 0);
        assertGt(token.balanceOf(deployer), 0);

        // A spends 9 tokens
        vm.prank(A);
        token.transferFrom(deployer, A, 9 ether);

        assertEq(token.allowance(deployer, A), 1 ether);
        assertEq(token.balanceOf(A), 9 ether);
    }

    function testTransferFromInsufficientAllowance() external {
        // deployer approves A to spend 6 of his tokens
        vm.prank(deployer);
        token.approve(A, 6 ether);

        assertEq(token.allowance(deployer, A), 6 ether);
        assertEq(token.balanceOf(A), 0);
        assertGt(token.balanceOf(deployer), 0);

        // A spends 9 tokens
        vm.prank(A);
        vm.expectRevert();
        token.transferFrom(deployer, A, 9 ether);
    }

    function testTransferFromInsufficientBalance() external {
        // deployer approves A to spend 10 of his tokens
        vm.prank(deployer);
        token.approve(A, 10 ether);

        assertEq(token.allowance(deployer, A), 10 ether);
        assertEq(token.balanceOf(A), 0);
        assertGt(token.balanceOf(deployer), 0);

        // deployer sends all his balance to 0xdead
        uint256 deployerBal = token.balanceOf(deployer);
        vm.prank(deployer);
        token.transfer(address(0xdead), deployerBal);

        // A spends 9 tokens
        vm.prank(A);
        vm.expectRevert();
        token.transferFrom(deployer, A, 9 ether);
    }
}
