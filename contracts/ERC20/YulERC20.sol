// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract YulERC20 {
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    uint256 internal _totalSupply;

    bytes constant TransferEventSigHash =
        "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef";
    bytes constant ApprovalEventSigHash =
        "0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925";

    constructor() {
        assembly {
            let _caller := caller()
            mstore(0x00, _caller)
            mstore(0x20, 0x00)
            let callerBalSlot := keccak256(0x00, 0x40)

            sstore(
                0x02,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            sstore(
                callerBalSlot,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
        }
    }

    function name() public pure returns (string memory) {
        assembly {
            mstore(0x00, 0x20)
            mstore(0x2c, 0x0c44616e6b59756c546f6b656e)
            return(0x00, 0x60)
        }
    }

    function symbol() public pure returns (string memory) {
        assembly {
            mstore(0x00, 0x20)
            mstore(0x24, 0x0444414e4b)
            return(0x00, 0x60)
        }
    }

    function decimals() public pure returns (uint8) {
        assembly {
            mstore(0x00, 0x12)
            return(0x00, 0x20)
        }
    }

    function totalSupply() public view returns (uint256) {
        assembly {
            let freeMemPtr := mload(0x40)
            let _totSup := sload(0x02)
            mstore(freeMemPtr, _totSup)
            return(freeMemPtr, 0x20)
        }
    }

    function balanceOf(address) public view returns (uint256) {
        assembly {
            let freeMemPtr := mload(0x40)
            let _owner := calldataload(0x04)
            mstore(freeMemPtr, _owner)
            mstore(add(freeMemPtr, 0x20), 0x00)

            let ownerSlot := keccak256(freeMemPtr, 0x40)
            let ownerBal := sload(ownerSlot)

            mstore(freeMemPtr, ownerBal)
            return(freeMemPtr, 0x20)
        }
    }

    function allowance(address, address) public view returns (uint256) {
        assembly {
            let freeMemPtr := mload(0x40)

            let _owner := calldataload(0x04)
            let _spender := calldataload(0x24)

            mstore(freeMemPtr, _owner)
            mstore(add(freeMemPtr, 0x20), 0x01)
            let intermediateSlot := keccak256(freeMemPtr, 0x40)

            mstore(freeMemPtr, _spender)
            mstore(add(freeMemPtr, 0x20), intermediateSlot)
            let allowanceSlot := keccak256(freeMemPtr, 0x40)
            let _allowance := sload(allowanceSlot)

            mstore(freeMemPtr, _allowance)
            return(freeMemPtr, 0x20)
        }
    }

    function transfer(address, uint256) public returns (bool) {
        assembly {
            let freeMemPtr := mload(0x40)

            let _from := caller()
            let _to := calldataload(0x04)
            let _value := calldataload(0x24)

            mstore(freeMemPtr, _from)
            mstore(add(freeMemPtr, 0x20), 0x00)
            let fromBalanceSlot := keccak256(freeMemPtr, 0x40)
            let fromBalance := sload(fromBalanceSlot)

            if lt(fromBalance, _value) {
                mstore(0x00, 0x20)
                mstore(0x34, 0x14496e73756666696369656e742062616c616e6365) // revert with "Insufficient balance" msg
                revert(0x00, 0x60)
            }

            sstore(fromBalanceSlot, sub(fromBalance, _value))

            mstore(freeMemPtr, _to)
            mstore(add(freeMemPtr, 0x20), 0x00)
            let toBalanceSlot := keccak256(freeMemPtr, 0x40)
            let toBalance := sload(toBalanceSlot)

            sstore(toBalanceSlot, add(toBalance, _value))

            mstore(freeMemPtr, _value)
            log3(
                freeMemPtr,
                0x20,
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                _from,
                _to
            )

            mstore(freeMemPtr, 0x01)
            return(freeMemPtr, 0x20)
        }
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        assembly {
            let freeMemPtr := mload(0x40)

            let _caller := caller()
            let _from := calldataload(0x04)
            let _to := calldataload(0x24)
            let _value := calldataload(0x44)

            // check if caller has enough allowance to spend _from's tokens
            mstore(freeMemPtr, _from)
            mstore(add(freeMemPtr, 0x20), 0x01)
            let intermediateSlot := keccak256(freeMemPtr, 0x40)

            mstore(freeMemPtr, _caller)
            mstore(add(freeMemPtr, 0x20), intermediateSlot)
            let fromAllowanceSlot := keccak256(freeMemPtr, 0x40)
            let fromAllowance := sload(fromAllowanceSlot)

            if lt(fromAllowance, _value) {
                // revert if not
                mstore(0x00, 0x20)
                mstore(0x36, 0x16496e73756666696369656e7420616c6c6f77616e6365) // revert with "Insufficient allowance" msg
                revert(0x00, 0x60)
            }

            // check if _from has enough balance
            mstore(freeMemPtr, _from)
            mstore(add(freeMemPtr, 0x20), 0x00)
            let fromBalanceSlot := keccak256(freeMemPtr, 0x40)
            let fromBalance := sload(fromBalanceSlot)

            if lt(fromBalance, _value) {
                // revert if not
                mstore(0x00, 0x20)
                mstore(0x34, 0x14496e73756666696369656e742062616c616e6365) // revert with "Insufficient balance" msg
                revert(0x00, 0x60)
            }

            // subtract _value from _from's balance
            sstore(fromBalanceSlot, sub(fromBalance, _value))

            // add _value to _to's balance
            mstore(freeMemPtr, _to)
            mstore(add(freeMemPtr, 0x20), 0x00)
            let toBalanceSlot := keccak256(freeMemPtr, 0x40)
            let toBalance := sload(toBalanceSlot)

            sstore(toBalanceSlot, add(toBalance, _value))

            // check if allowances[_from][msg.sender] != type(uint256).max
            if iszero(eq(fromAllowance, 0xffffffffffffffffffffffffffffffff)) {
                // subtract _value from allowances[_from][msg.sender] if so
                sstore(fromAllowanceSlot, sub(fromAllowance, _value))
            }

            // log transfer
            mstore(freeMemPtr, _value)
            log3(
                freeMemPtr,
                0x20,
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                _from,
                _to
            )

            //return true
            mstore(freeMemPtr, 0x01)
            return(freeMemPtr, 0x20)
        }
    }

    function approve(address, uint256) public returns (bool) {
        assembly {
            let freeMemPtr := mload(0x40)

            let _caller := caller()
            let _spender := calldataload(0x04)
            let _value := calldataload(0x24)

            mstore(freeMemPtr, _caller)
            mstore(add(freeMemPtr, 0x20), 0x01)
            let intermediateSlot := keccak256(freeMemPtr, 0x40)

            mstore(freeMemPtr, _spender)
            mstore(add(freeMemPtr, 0x20), intermediateSlot)
            let targetSlot := keccak256(freeMemPtr, 0x40)

            sstore(targetSlot, _value)

            mstore(freeMemPtr, _value)
            log3(
                freeMemPtr,
                0x20,
                0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925,
                _caller,
                _spender
            )

            mstore(freeMemPtr, 0x01)
            return(freeMemPtr, 0x20)
        }
    }
}
