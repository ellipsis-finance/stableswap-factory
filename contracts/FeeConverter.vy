# @version 0.3.3

interface MetaPool:
    def coins(i: uint256) -> address: view
    def exchange(
        i: int128,
        j: int128,
        dx: uint256,
        min_dy: uint256
    ) -> uint256: nonpayable

interface ERC20:
    def balanceOf(_addr: address) -> uint256: view
    def decimals() -> uint256: view
    def totalSupply() -> uint256: view
    def approve(_spender: address, _amount: uint256): nonpayable

interface FeeDistributor:
    def depositFee(_token: address, _amount: uint256) -> bool: nonpayable

interface Factory:
    def fee_receiver() -> address: view


factory: public(Factory)


@external
def __init__(_factory: Factory):
    """
    @notice Constructor function
    """
    self.factory = _factory


@external
def convert_metapool_fees() -> bool:
    """
    @notice Convert metapool fees and transfer to fee receiver
    @dev All fees are converted to LP token of base pool
    """
    coin: address = MetaPool(msg.sender).coins(0)
    amount: uint256 = ERC20(coin).balanceOf(self)
    if amount > 0:
        ERC20(coin).approve(msg.sender, amount)
        MetaPool(msg.sender).exchange(0, 1, amount, 0)

    coin = MetaPool(msg.sender).coins(1)
    amount = ERC20(coin).balanceOf(self)
    if amount > 0:
        fee_receiver: address = self.factory.fee_receiver()
        ERC20(coin).approve(fee_receiver, amount)
        FeeDistributor(fee_receiver).depositFee(coin, amount)

    return True
