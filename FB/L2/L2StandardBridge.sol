// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import { StandardBridge } from "../StandardBridge.sol";
import { LEGACY_ERC20_ETH } from "../LEGACY_ERC20_ETH.sol";
import { OptimismMintableERC20 } from "../OptimismMintableERC20.sol";

contract L2StandardBridge is StandardBridge {


    address public immutable WETH;

    event WithdrawalInitiated(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256 amount
    );

    event DepositFinalized(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256 amount
    );


    constructor(address _owner,address _weth) {
        owner = _owner;
        WETH = _weth;
    }


    function withdraw(
        address _l2Token,
        uint256 _amount
    )
        external
        payable
        virtual
        
    {
        _initiateWithdrawal(_l2Token, msg.sender, msg.sender, _amount);
    }


    function withdrawTo(
        address _l2Token,
        address _to,
        uint256 _amount
    )
        external
        payable
        virtual
    {
        _initiateWithdrawal(_l2Token, msg.sender, _to, _amount);
    }

   
    function finalizeDeposit(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _amount
    )
        external
        payable
        virtual
    {
        if (_l1Token == address(0) && _l2Token == WETH) {
            finalizeBridgeETH(WETH,_from, _to, _amount);
        } else {
            finalizeBridgeERC20(_l2Token, _l1Token, _from, _to, _amount);
        }    
    }



    function _initiateWithdrawal(
        address _l2Token,
        address _from,
        address _to,
        uint256 _amount
    )
        internal
    {
        if (_l2Token == WETH) {
            _initiateBridgeETH(_from, _to, _amount);
        } else {
            address l1Token = OptimismMintableERC20(_l2Token).l1Token();
            _initiateBridgeERC20(_l2Token, l1Token, _from, _to, _amount);
        }
    }


    function _emitETHBridgeInitiated(
        address _from,
        address _to,
        uint256 _amount
    )
        internal
        override
    {
        emit WithdrawalInitiated(address(0), WETH, _from, _to, _amount);
        super._emitETHBridgeInitiated(_from, _to, _amount);
    }


    function _emitETHBridgeFinalized(
        address _from,
        address _to,
        uint256 _amount
    )
        internal
        override
    {
        emit DepositFinalized(address(0), WETH, _from, _to, _amount);
        super._emitETHBridgeFinalized(_from, _to, _amount);
    }

  
    function _emitERC20BridgeInitiated(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _amount
    )
        internal
        override
    {
        emit WithdrawalInitiated(_remoteToken, _localToken, _from, _to, _amount);
        super._emitERC20BridgeInitiated(_localToken, _remoteToken, _from, _to, _amount);
    }

    function _emitERC20BridgeFinalized(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _amount
    )
        internal
        override
    {
        emit DepositFinalized(_remoteToken, _localToken, _from, _to, _amount);
        super._emitERC20BridgeFinalized(_localToken, _remoteToken, _from, _to, _amount);
    }
}