// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AssemblyERC20 {
    string private _name;
    string private _symbol;

    address private _owner;

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // First 4 bytes of keccak256("ERC20: transfer from the zero address")
    bytes4 constant public ERROR_TRANSFER_FROM_THE_ZERO_ADDRESS   = 0xbaecc556;
    // First 4 bytes of keccak256("ERC20: transfer to the zero address")
    bytes4 constant public ERROR_TRANSFER_TO_ZERO_ADDRESS         = 0x0557e210;
    // First 4 bytes of keccak256("ERC20: transfer amount exceeds balance")
    bytes4 constant public ERROR_TRANSFER_AMOUNT_EXCEEDS_BALANCE  = 0x4107e8a8;
    // First 4 bytes of keccak256("ERC20: mint to the zero address")
    bytes4 constant public ERROR_MINT_TO_THE_ZERO_ADDRESS         = 0xfc0b381c;
    // Fisrt 4 bytes of keccak256("ERC20: approve to the zero address")
    bytes4 constant public ERROR_APPROVE_TO_THE_ZERO_ADDRESS      = 0x24883cc5;
    // Fisrt 4 bytes of keccak256("ERC20: insufficient allowance")
    bytes4 constant public ERROR_INSUFFICIENT_ALLOWANCE           = 0x3b6607e0;
    // Fisrt 4 bytes of keccak256("ERC20: burn amount exceeds balance")
    bytes4 constant public ERROR_BURN_AMOUNT_EXCEEDS_BALANCE      = 0x149b126e;
    // Fisrt 4 bytes of keccak256("Only owner")
    bytes4 constant public ERROR_CALLER_NOT_OWNER                 = 0x17d9f114;

    constructor(string memory name_, string memory symbol_, address owner_) {
        // _name = name_;
        // _symbol = symbol_;
        // assembly 
    }

    /// @dev return a string or bytes at `slotIndex`
    function _returnStringOrBytes(uint256 slotIndex) internal view {
        assembly {
            // If the string or bytes's length is less than 31 bytes, it will be stored in `slotIndex`,
            // otherwise it will be stored in keccack256(slotIndex) and the following slots
            let slot := sload(slotIndex)
            // The last bit of the slot indicates if the string or bytes is more than 31 bytes
            let isMoreThan31Bytes := shl(255, slot)

            switch iszero(isMoreThan31Bytes)
            case 1 {
                // Length is stored in 249 ~ 254 bits
                // First we shift left 248 bits to extract the last byte, then we
                // shift right 249 bits to extract the length from the last byte
                let length := shr(249, shl(248 , slot))
                // Memory offset 0 ~ 0x3f is a scratch pad, 0x40 ~ 0x5f is the free memory
                // pointer, and 0x60 ~ 0x7f is the zero slot. We don't need them for now,
                // so we start from offset 0 to pack return data to avoid extra memory allocation
                mstore(0, 0x20)     // Offset of the string
                mstore(0x20, length) // The word of the offset stores string or bytes's length
                mstore(0x40, shl(8, shr(8, slot))) // Following the string or bytes's content
                return(0, 0x60)
            } default {
                // If the string or bytes's length is more than 31 bytes,
                // it's length will be stored in 0 ~ 254 bits
                let length := shr(1, slot)
                let loopLength := length
                // keccak256 only takes place in memory, so we first store the index to memory
                mstore(0, slotIndex)
                // Find the start slot that stores the string or bytes's content
                // Equivalent to keccak256(abi.encode(slotIndex))
                let targetSlot := keccak256(0, 0x20)
                // Pack our return data and here we overwrite the first word of memory
                mstore(0, 0x20)
                mstore(0x20, length)
                let i := 0
                // Use `signed greater than` here
                for {} sgt(loopLength, 0) { i := add(i, 1) } {
                    // We store the content from memory offset 0x40
                    mstore(mul(add(i, 2), 0x20), sload(add(targetSlot, i)))
                    loopLength := sub(loopLength, 0x20)
                }
                return(0, add(mul(div(length, 0x20), 0x20), 0x60))
            }
        }
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns(string memory) {
        // Although use a hardcode expression will save more gas, i.e., _name at slot 0,
        // but as a demonstration, it's better to use a more readable expression
        uint256 nameSlot;
        assembly {
            nameSlot := _name.slot
        }
        _returnStringOrBytes(nameSlot);
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        uint256 symbolSlot;
        assembly {
            symbolSlot := _symbol.slot
        }
        _returnStringOrBytes(symbolSlot);
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public pure returns (uint8) {
        // return 18
        assembly {
            mstore(0, 18)
            return(0, 0x20)
        }
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        assembly {
            mstore(0, sload(_totalSupply.slot))
            return(0, 0x20)
        }
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        assembly{
            // Mapping's value of a key is stored in slot keccak256(abi.encode(key, slotIndex))
            mstore(0, account)
            mstore(0x20, _balances.slot)
            mstore(0, sload(keccak256(0, 0x40)))
            return(0, 0x20)
        }
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address, uint256) public returns (bool) {
        assembly {
            // Load calldata
            let from := caller()
            let to := calldataload(0x04)
            let amount := calldataload(0x24)

            if iszero(to) {
                mstore(0, ERROR_TRANSFER_TO_ZERO_ADDRESS)
                revert(0, 0x20)
            }

            // Get from balance slot and from balance
            mstore(0, from)
            mstore(0x20, 3)
            let fromBalanceSlot := keccak256(0, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            if gt(amount, fromBalance) {
                mstore(0, ERROR_TRANSFER_AMOUNT_EXCEEDS_BALANCE)
                revert(0, 0x20)
            }
            sstore(fromBalanceSlot, sub(fromBalance, amount))

            // Get to balance slot and to balance
            mstore(0, to)
            mstore(0x20, 3)
            let toBalanceSlot := keccak256(0, 0x40)
            let toBalance := sload(toBalanceSlot)
            sstore(toBalanceSlot, add(toBalance, amount))
            // return true
            mstore(0, 1)
            return(0, 0x20)
        }
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address, address) public view returns (uint256) {
        assembly {
            let owner := calldataload(0x04)
            let spender := calldataload(0x24)
            let allowancesSlot := _allowances.slot

            mstore(0, owner)
            mstore(0x20, allowancesSlot)
            mstore(0x20, keccak256(0, 0x40))
            mstore(0, spender)
            let accountAllowance := sload(keccak256(0, 0x40))
            mstore(0, accountAllowance)
            return (0, 0x20)
        }
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address, uint256) public returns (bool) {
        assembly {
            let owner := caller()
            let spender := calldataload(0x04)
            if iszero(spender) {
                mstore(0, ERROR_APPROVE_TO_THE_ZERO_ADDRESS)
                revert(0, 0x20)
            }
            let amount := calldataload(0x24)
            let allowancesSlot := _allowances.slot

            mstore(0, owner)
            mstore(0x20, allowancesSlot)
            mstore(0x20, keccak256(0, 0x40))
            mstore(0, spender)
            let accountAllowanceSlot := keccak256(0, 0x40)
            sstore(accountAllowanceSlot, amount)
            // return true
            mstore(0, 1)
            return(0, 0x20)
        }
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address,
        address,
        uint256
    ) public returns (bool) {
        assembly {
            // Load calldata
            let from := calldataload(0x04)
            let to := calldataload(0x24)
            let amount := calldataload(0x44)
            let spender := caller()

            if iszero(to) {
                mstore(0, ERROR_TRANSFER_TO_ZERO_ADDRESS)
                revert(0, 0x20)
            }

            // Check and spend allowance
            let allowancesSlot := _allowances.slot
            mstore(0, from)
            mstore(0x20, allowancesSlot)
            mstore(0x20, keccak256(0, 0x40))
            mstore(0, spender)
            let accountAllowanceSlot := keccak256(0, 0x40)
            let accountAllowance := sload(accountAllowanceSlot)
            if gt(amount, accountAllowance) {
                mstore(0, ERROR_INSUFFICIENT_ALLOWANCE)
                revert(0, 0x20)
            }
            sstore(accountAllowanceSlot, sub(accountAllowance, amount))

            // Get from balance slot and update from balance
            let balanceSlot := _balances.slot
            mstore(0, from)
            mstore(0x20, balanceSlot)
            let fromBalanceSlot := keccak256(0, 0x40)
            let fromBalance := sload(fromBalanceSlot)
            if gt(amount, fromBalance) {
                mstore(0, ERROR_TRANSFER_AMOUNT_EXCEEDS_BALANCE)
                revert(0, 0x20)
            }
            sstore(fromBalanceSlot, sub(fromBalance, amount))

            // Get `to` balance slot and update `to` balance
            mstore(0, to)
            mstore(0x20, balanceSlot)
            let toBalanceSlot := keccak256(0, 0x40)
            let toBalance := sload(toBalanceSlot)
            sstore(toBalanceSlot, add(toBalance, amount))

            // return true
            mstore(0, 1)
            return(0, 0x20)
        }
    }

    function mint(address, uint256) public {
        assembly {
            let account := calldataload(0x04)
            let amount := calldataload(0x24)
            let sender := caller()
            let owner := sload(_owner.slot)

            if iszero(eq(sender, owner)) {
                mstore(0, ERROR_CALLER_NOT_OWNER)
                revert(0, 0x20)
            }

            if iszero(account) {
                mstore(0, ERROR_MINT_TO_THE_ZERO_ADDRESS)
                revert(0, 0x20)
            }
            // Directly use the slot index, i.e., 2 will save some gas
            // but use variable.slot is more readable
            let supplySlot := _totalSupply.slot
            let supply := sload(supplySlot)
            supply := add(supply, amount)
            sstore(supplySlot, supply)

            let balancesSlot := _balances.slot
            mstore(0, account)
            mstore(0x20, balancesSlot)
            let accountBalanceSlot := keccak256(0, 0x40)
            let accountBalance := sload(accountBalanceSlot)
            accountBalance := add(accountBalance, amount)
            sstore(accountBalanceSlot, accountBalance)
        }
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(address, uint256) external {
        assembly {
            let account := calldataload(0x04)
            let amount := calldataload(0x24)
            let sender := caller()
            let owner := sload(_owner.slot)

            if iszero(eq(sender, owner)) {
                mstore(0, ERROR_CALLER_NOT_OWNER)
                revert(0, 0x20)
            }

            if iszero(account) {
                mstore(0, ERROR_MINT_TO_THE_ZERO_ADDRESS)
                revert(0, 0x20)
            }

            // Update account balance
            // Directly use the slot index, i.e., 2 will save some gas
            // but use variable.slot is more readable
            let balancesSlot := _balances.slot
            mstore(0, account)
            mstore(0x20, balancesSlot)
            let accountBalanceSlot := keccak256(0, 0x40)
            let accountBalance := sload(accountBalanceSlot)
            if gt(amount, accountBalance) {
                mstore(0, ERROR_BURN_AMOUNT_EXCEEDS_BALANCE)
                revert(0, 0x20)
            }
            accountBalance := sub(accountBalance, amount)
            sstore(accountBalanceSlot, accountBalance)

            // Update total supply
            let supplySlot := _totalSupply.slot
            let supply := sload(supplySlot)
            supply := sub(supply, amount)
            sstore(supplySlot, supply)
        }
    }
}
