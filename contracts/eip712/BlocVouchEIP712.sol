pragma solidity 0.8.20;
import {Vouch} from "../vouch/VouchStructs.sol";

contract BlocVouchEIP712 {
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 internal constant VOUCH_HASH =
        keccak256("Vouch(address recipient,address signer,uint256 nonce)");

    bytes32 public DOMAIN_SEPARATOR;

    function hashVouch(Vouch memory vouch) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    VOUCH_HASH,
                    vouch.recipient,
                    vouch.signer,
                    vouch.nonce
                )
            );
    }
}
