// pragma solidity ^0.6.2;

// import "../../interfaces/IERC777.sol";
// import "../../interfaces/IERC777Recipient.sol";
// import "../../interfaces/IERC777Sender.sol";
// import "../../interfaces/IERC777Regulator.sol";
// import "../../interfaces/IERC20.sol";
// import "../../interfaces/IBaseToken.sol";
// import "../../interfaces/IERC1820Registry.sol";
// import "../ERCs/ERC1820Implementer.sol"; 
// import "../Misc/SafeMath.sol";
// import "../Misc/Address.sol";
// import "../Misc/Context.sol";
// import "../Misc/Controlled.sol";

// /**
//  * @dev Implementation of the {IERC777} interface.
//  *
//  * This implementation is agnostic to the way tokens are created. This means
//  * that a supply mechanism has to be added in a derived contract using {_mint}.
//  *
//  * Support for ERC20 is included in this contract, as specified by the EIP: both
//  * the ERC777 and ERC20 interfaces can be safely used when interacting with it.
//  * Both {IERC777-Sent} and {IERC20-Transfer} events are emitted on token
//  * movements.
//  *
//  * Additionally, the {IERC777-granularity} value is hard-coded to `1`, meaning that there
//  * are no special restrictions in the amount of tokens that created, moved, or
//  * destroyed. This makes integration with ERC20 applications seamless.
//  */

// //  ERC1820Implementer,
// // contract ERC777 is IERC20, IERC777, Context, ERC1820Implementer, Controlled {

// contract ERC777 is IERC20, IERC777, Context, Controlled {
//     // AG: No error when no
//     using SafeMath for uint256;
//     using Address for address;

//     // IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

//     mapping(address => uint256) private _balances;

//     uint256 private _totalSupply;

//     string private _name;
//     string private _symbol;


//     // We inline the result of the following hashes because Solidity doesn't resolve them at compile time.
//     // See https://github.com/ethereum/solidity/issues/4024.

//     // keccak256("ERC20Token")
//     bytes32 constant internal ERC20_TOKENS_INTERFACE_HASH =
//         0xaea199e31a596269b42cdafd93407f14436db6e4cad65417994c2eb37381e05a;

//     // keccak256("ERC777Token")
//     bytes32 constant internal ERC777_TOKENS_INTERFACE_HASH =
//         0xac7fbab5f54a3ca8194167523c6753bfeb96a445279294b6125b68cce2177054;

//     // keccak256("ERC777TokensSender")
//     bytes32 constant internal TOKENS_SENDER_INTERFACE_HASH =
//         0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

//     // keccak256("ERC777TokensRecipient")
//     bytes32 constant internal TOKENS_RECIPIENT_INTERFACE_HASH =
//         0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

//     // This isn't ever read from - it's only used to respond to the defaultOperators query.
//     address[] internal _defaultOperatorsArray;

//     // Immutable, but accounts may revoke them (tracked in __revokedDefaultOperators).
//     mapping(address => bool) internal _defaultOperators;

//     // For each account, a mapping of its operators and revoked default operators.
//     mapping(address => mapping(address => bool)) private _operators;
//     mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

//     // ERC20-allowances
//     mapping (address => mapping (address => uint256)) private _allowances;

//     /**
//      * @dev `defaultOperators` may be an empty array.
//      */
//     function _initERC777(
//         address  tokenOwner,
//         string memory name,
//         string memory symbol,
//         address[] memory defaultOperators
//     ) internal {
//         _initControlled(tokenOwner);
//         _name = name;
//         _symbol = symbol;

//         _defaultOperatorsArray = defaultOperators;
//         for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
//             _defaultOperators[_defaultOperatorsArray[i]] = true;
//         }

//         // register interfaces
//         // ERC1820_REGISTRY.setInterfaceImplementer(address(this), ERC777_TOKENS_INTERFACE_HASH, address(this));
//         // ERC1820_REGISTRY.setInterfaceImplementer(address(this), ERC20_TOKENS_INTERFACE_HASH, address(this));
//     }

//     /**
//      * @dev See {IERC777-name}.
//      */
//     function name() public view override(IERC20, IERC777) returns (string memory) {
//         return _name;
//     }

//     /**
//      * @dev See {IERC777-symbol}.
//      */
//     function symbol() public view override(IERC20, IERC777) returns (string memory) {
//         return _symbol;
//     }

//     /**
//      * @dev See {ERC20Detailed-decimals}.
//      *
//      * Always returns 18, as per the
//      * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
//      */
//     function decimals() public view override returns (uint8) {
//         return 18;
//     }

//     /**
//      * @dev See {IERC777-granularity}.
//      *
//      * This implementation always returns `1`.
//      */
//     function granularity() public view override returns (uint256) {
//         return 1;
//     }

//     /**
//      * @dev See {IERC777-totalSupply}.
//      */
//     function totalSupply() public view override(IERC20, IERC777) returns (uint256) {
//         return _totalSupply;
//     }

//     /**
//      * @dev Returns the amount of tokens owned by an account (`tokenHolder`).
//      */
//     function balanceOf(address tokenHolder) public view override(IERC20, IERC777) returns (uint256) {
//         return _balances[tokenHolder];
//     }

//     /**
//      * @dev See {IERC777-send}.
//      *
//      * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
//      */
//     function send(address recipient, uint256 amount, bytes memory data) public override  {
//         _send(_msgSender(), _msgSender(), recipient, amount, data, "", true);
//     }

//     /**
//      * @dev See {IERC20-transfer}.
//      *
//      * Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient}
//      * interface if it is a contract.
//      *
//      * Also emits a {Sent} event.
//      */
//     function transfer(address recipient, uint256 amount) public override returns (bool) {
//         require(recipient != address(0), "ERC777: transfer to the zero address");

//         address from = _msgSender();

//         _callTokensToSend(from, from, recipient, amount, "", "");
//         _move(from, from, recipient, amount, "", "");
//         _callTokensReceived(from, from, recipient, amount, "", "", false);

//         return true;
//     }

//     /**
//      * @dev See {IERC777-burn}.
//      *
//      * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
//      */
//     function burn(uint256 amount, bytes memory data) public override  {
//         _burn(_msgSender(), _msgSender(), amount, data, "");
//     }

//     /**
//      * @dev See {IERC777-isOperatorFor}.
//      */
//     function isOperatorFor(
//         address operator,
//         address tokenHolder
//     ) public view override returns (bool) {
//         return operator == tokenHolder ||
//             (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
//             _operators[tokenHolder][operator] ;
//     }

//     /**
//      * @dev See {IERC777-authorizeOperator}.
//      */
//     function authorizeOperator(address operator) public override  {
//         require(_msgSender() != operator, "ERC777: authorizing self as operator");

//         if (_defaultOperators[operator]) {
//             delete _revokedDefaultOperators[_msgSender()][operator];
//         } else {
//             _operators[_msgSender()][operator] = true;
//         }

//         emit AuthorizedOperator(operator, _msgSender());
//     }

//     /**
//      * @dev See {IERC777-revokeOperator}.
//      */
//     function revokeOperator(address operator) public override  {
//         require(operator != _msgSender(), "ERC777: revoking self as operator");

//         if (_defaultOperators[operator]) {
//             _revokedDefaultOperators[_msgSender()][operator] = true;
//         } else {
//             delete _operators[_msgSender()][operator];
//         }

//         emit RevokedOperator(operator, _msgSender());
//     }

//     /**
//      * @dev See {IERC777-defaultOperators}.
//      */
//     function defaultOperators() public view override returns (address[] memory) {
//         return _defaultOperatorsArray;
//     }

//     /**
//      * @dev See {IERC777-operatorSend}.
//      *
//      * Emits {Sent} and {IERC20-Transfer} events.
//      */
//     function operatorSend(
//         address sender,
//         address recipient,
//         uint256 amount,
//         bytes memory data,
//         bytes memory operatorData
//     )
//     public override
//     {
//         require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
//         _send(_msgSender(), sender, recipient, amount, data, operatorData, true);
//     }

//     /**
//      * @dev See {IERC777-operatorBurn}.
//      *
//      * Emits {Burned} and {IERC20-Transfer} events.
//      */
//      // AG: To Do: Check the burn operator
//     function operatorBurn(address account, uint256 amount, bytes memory data, bytes memory operatorData) public virtual override {
//         require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
//         _burn(_msgSender(), account, amount, data, operatorData);
//     }

//     /**
//      * @dev See {IERC20-allowance}.
//      *
//      * Note that operator and allowance concepts are orthogonal: operators may
//      * not have allowance, and accounts with allowance may not be operators
//      * themselves.
//      */
//     function allowance(address holder, address spender) public view override returns (uint256) {
//         return _allowances[holder][spender];
//     }

//     /**
//      * @dev See {IERC20-approve}.
//      *
//      * Note that accounts cannot have allowance issued by their operators.
//      */
//     function approve(address spender, uint256 value) public override returns (bool) {
//         address holder = _msgSender();
//         _approve(holder, spender, value);
//         return true;
//     }

//    /**
//     * @dev See {IERC20-transferFrom}.
//     *
//     * Note that operator and allowance concepts are orthogonal: operators cannot
//     * call `transferFrom` (unless they have allowance), and accounts with
//     * allowance cannot call `operatorSend` (unless they are operators).
//     *
//     * Emits {Sent}, {IERC20-Transfer} and {IERC20-Approval} events.
//     */
//     function transferFrom(address holder, address recipient, uint256 amount) public override returns (bool) {
//         require(recipient != address(0), "ERC777: transfer to the zero address");
//         require(holder != address(0), "ERC777: transfer from the zero address");

//         address spender = _msgSender();

//         _callTokensToSend(spender, holder, recipient, amount, "", "");

//         _move(spender, holder, recipient, amount, "", "");
//         _approve(holder, spender, _allowances[holder][spender].sub(amount, "ERC777: transfer amount exceeds allowance"));

//         _callTokensReceived(spender, holder, recipient, amount, "", "", false);

//         return true;
//     }

//     function mint(address to, uint256 amount,  bytes calldata userData, bytes calldata operatorData) external override {
//         require(isOperatorFor(_msgSender(), to), "ERC777: caller is not an operator for holder");
//         _mint(_msgSender(), to, amount, userData, operatorData);
//     }

//     /**
//      * @dev Creates `amount` tokens and assigns them to `account`, increasing
//      * the total supply.
//      *
//      * If a send hook is registered for `account`, the corresponding function
//      * will be called with `operator`, `data` and `operatorData`.
//      *
//      * See {IERC777Sender} and {IERC777Recipient}.
//      *
//      * Emits {Minted} and {IERC20-Transfer} events.
//      *
//      * Requirements
//      *
//      * - `account` cannot be the zero address.
//      * - if `account` is a contract, it must implement the {IERC777Recipient}
//      * interface.
//      */
//     function _mint(
//         address operator,
//         address account,
//         uint256 amount,
//         bytes memory userData,
//         bytes memory operatorData
//     )
//     internal virtual
//     {
//         require(account != address(0), "ERC777: mint to the zero address");

//         // Update state variables
//         _totalSupply = _totalSupply.add(amount);
//         _balances[account] = _balances[account].add(amount);

//         _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

//         emit Minted(operator, account, amount, userData, operatorData);
//         emit Transfer(address(0), account, amount);
//     }

//     /**
//      * @dev Send tokens
//      * @param operator address operator requesting the transfer
//      * @param from address token holder address
//      * @param to address recipient address
//      * @param amount uint256 amount of tokens to transfer
//      * @param userData bytes extra information provided by the token holder (if any)
//      * @param operatorData bytes extra information provided by the operator (if any)
//      * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
//      */
//     function _send(
//         address operator,
//         address from,
//         address to,
//         uint256 amount,
//         bytes memory userData,
//         bytes memory operatorData,
//         bool requireReceptionAck
//     )
//         internal
//     {
//         require(from != address(0), "ERC777: send from the zero address");
//         require(to != address(0), "ERC777: send to the zero address");

//         _callTokensToSend(operator, from, to, amount, userData, operatorData);

//         _move(operator, from, to, amount, userData, operatorData);

//         _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
//     }

//     /**
//      * @dev Burn tokens
//      * @param operator address operator requesting the operation
//      * @param from address token holder address
//      * @param amount uint256 amount of tokens to burn
//      * @param data bytes extra information provided by the token holder
//      * @param operatorData bytes extra information provided by the operator (if any)
//      */
//     function _burn(
//         address operator,
//         address from,
//         uint256 amount,
//         bytes memory data,
//         bytes memory operatorData
//     )
//         internal virtual
//     {
//         require(from != address(0), "ERC777: burn from the zero address");

//         _callTokensToSend(operator, from, address(0), amount, data, operatorData);

//         // Update state variables
//         _balances[from] = _balances[from].sub(amount, "ERC777: burn amount exceeds balance");
//         _totalSupply = _totalSupply.sub(amount);

//         emit Burned(operator, from, amount, data, operatorData);
//         emit Transfer(from, address(0), amount);
//     }

//     function _move(
//         address operator,
//         address from,
//         address to,
//         uint256 amount,
//         bytes memory userData,
//         bytes memory operatorData
//     )
//         private
//     {
//         _beforeTokenTransfer(operator, from, to, amount);

//         _balances[from] = _balances[from].sub(amount, "ERC777: transfer amount exceeds balance");
//         _balances[to] = _balances[to].add(amount);

//         emit Sent(operator, from, to, amount, userData, operatorData);
//         emit Transfer(from, to, amount);
//     }

//     function _approve(address holder, address spender, uint256 value) internal {
//         require(holder != address(0), "ERC777: approve from the zero address");
//         require(spender != address(0), "ERC777: approve to the zero address");

//         _allowances[holder][spender] = value;
//         emit Approval(holder, spender, value);
//     }

//     /**
//      * @dev Call from.tokensToSend() if the interface is registered
//      * @param operator address operator requesting the transfer
//      * @param from address token holder address
//      * @param to address recipient address
//      * @param amount uint256 amount of tokens to transfer
//      * @param userData bytes extra information provided by the token holder (if any)
//      * @param operatorData bytes extra information provided by the operator (if any)
//      */
//     function _callTokensToSend(
//         address operator,
//         address from,
//         address to,
//         uint256 amount,
//         bytes memory userData,
//         bytes memory operatorData
//     )
//         internal
//     {
//         // address implementer = ERC1820_REGISTRY.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
//         // if (implementer != address(0)) {
//         //     IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
//         // }
//     }

//     /**
//      * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
//      * tokensReceived() was not registered for the recipient
//      * @param operator address operator requesting the transfer
//      * @param from address token holder address
//      * @param to address recipient address
//      * @param amount uint256 amount of tokens to transfer
//      * @param userData bytes extra information provided by the token holder (if any)
//      * @param operatorData bytes extra information provided by the operator (if any)
//      * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
//      */
//     function _callTokensReceived(
//         address operator,
//         address from,
//         address to,
//         uint256 amount,
//         bytes memory userData,
//         bytes memory operatorData,
//         bool requireReceptionAck
//     )
//         internal
//     {
//         // address implementer = ERC1820_REGISTRY.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
//         // if (implementer != address(0)) {
//         //     IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
//         // } else if (requireReceptionAck) {
//         //     require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
//         // }
//     }

//     /**
//      * @dev Hook that is called before any token transfer. This includes
//      * calls to {send}, {transfer}, {operatorSend}, minting and burning.
//      *
//      * Calling conditions:
//      *
//      * - when `from` and `to` are both non-zero, `from`'s `tokenId` will be
//      * transferred to `to`.
//      * - when `from` is zero, `tokenId` will be minted for `to`.
//      * - when `to` is zero, `from`'s `tokenId` will be burned.
//      * - `from` and `to` are never both zero.
//      *
//      * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].
//      */
//     function _beforeTokenTransfer(address operator, address from, address to, uint256 tokenId) internal virtual { }

// }

